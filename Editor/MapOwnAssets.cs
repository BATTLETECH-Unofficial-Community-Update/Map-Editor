// UCU Map Kit: a saved copy of a map gets its own terrain (work item map-kit, SAVEAS; .hermes/reports/map-kit-saveas-20261123/final.md).
// Unity's File > Save As writes a new scene whose Terrain, TerrainCollider and SplatMapInfo still point at the source map's
// assets. The kit writes two of them in place: sculpting writes the TerrainData (its heightmap and alphamap sub-assets), and the
// terrain-type paint tool and Roads write the seven mask PNGs (TerrainTypePaint.WritePending). So after a Save As, working on the
// copy changed the original and every other copy. When a scene is saved and one of those assets is named for another map whose
// scene uses it too, this copies the asset beside the saved scene (AssetDatabase.CopyAsset keeps the alphamap sub-assets),
// repoints the scene and saves it again. The other scene is never opened or changed.
// Everything else the kit keeps per map is named for the scene, so a copy starts without it: the preview, moods (a Moods folder
// beside the scene), the retail GI reference, the layer-links and dialogue files, and the lighting data a bake writes under the
// scene's own name (MapBake.IsStale). The terrain material is only re-filled from the biome by HBS's TerrainMaterialSetup and
// the kit never saves it; it stays shared. What the copy does take is the id of the retail map it came from, written into its
// new layer-links file (Split), because the scene's own name is no longer a retail id (map-kit A1 D17).
// shortcut: "another scene uses it" is asked of one scene, the map the asset is named for (<map>_terrain..., <map>_mask_...),
// with one GetDependencies call. Reading every scene's dependencies costs about a second per 200 MB of scene (51 s on the 50-scene
// kit project), so an asset under any other name is not found, here or by Map Check. Upgrade to a cached index if that matters.
// shortcut: edits made to the shared asset before the Save As (an unsaved sculpt, unwritten paint) are already in the original's
// asset and stay there; the hook warns. Save the sculpt first, then Save As.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using BattleTech;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;
using Debug = UnityEngine.Debug;

namespace UCU.MapKit
{
    /// <summary>One per-map asset the open scene uses that the map it is named for also uses.</summary>
    public class SharedMapAsset
    {
        public string kind, path, dest;
        /// <summary>The scene the asset is named for.</summary>
        public string scene;
        internal Action<UnityEngine.Object> repoint;
    }

    public static class MapOwnAssets
    {
        static bool busy;
        /// <summary>Evidence: what the last Find cost and how many scenes it read.</summary>
        public static double LastFindMs;
        public static int LastScenesRead;

        [InitializeOnLoadMethod]
        static void Hook() => EditorSceneManager.sceneSaved += OnSaved;

        static void OnSaved(Scene scene)
        {
            if (busy || !scene.IsValid() || !scene.path.StartsWith("Assets/", StringComparison.Ordinal)) return;
            var shared = Find(scene);
            if (shared.Count == 0) return;
            busy = true;
            try
            {
                Split(scene, shared);
                EditorSceneManager.SaveScene(scene);
            }
            catch (Exception e) { Debug.LogError($"UCU Map Kit: giving {scene.name} its own terrain failed: {e.Message}\n{e}"); }
            finally { busy = false; }
        }

        class Use
        {
            public string kind, path, dest, owner;
            public List<Action<UnityEngine.Object>> repoint = new List<Action<UnityEngine.Object>>();
        }

        static readonly (string name, Func<SplatMapInfo, Texture2D> get, Action<SplatMapInfo, Texture2D> set)[] Masks =
        {
            ("water", s => s.waterMask, (s, t) => s.waterMask = t), ("deepWater", s => s.deepWaterMask, (s, t) => s.deepWaterMask = t),
            ("forest", s => s.forestMask, (s, t) => s.forestMask = t), ("rough", s => s.roughMask, (s, t) => s.roughMask = t),
            ("custom", s => s.customMask, (s, t) => s.customMask = t), ("road", s => s.roadMask, (s, t) => s.roadMask = t),
            ("impassable", s => s.impassableMask, (s, t) => s.impassableMask = t),
        };
        static readonly Regex TerrainName = new Regex(@"^(.+)_terrain(_x\d+_y\d+)?$");
        static readonly Regex MaskName = new Regex(@"^(.+)_mask_(water|deepWater|forest|rough|custom|road|impassable)$");

        /// <summary>The scene's TerrainData and mask textures that are named for another map whose scene uses them too. A scene whose
        /// assets are its own (a plain Save) reads no other scene.</summary>
        public static List<SharedMapAsset> Find(Scene scene)
        {
            var sw = Stopwatch.StartNew();
            LastScenesRead = 0;
            var result = new List<SharedMapAsset>();
            var dir = Path.GetDirectoryName(scene.path).Replace('\\', '/');
            var map = scene.name;
            var uses = new Dictionary<string, Use>();
            void Add(string kind, UnityEngine.Object o, string dest, Regex named, Action<UnityEngine.Object> repoint)
            {
                var p = o == null ? null : AssetDatabase.GetAssetPath(o);
                if (string.IsNullOrEmpty(p) || !p.StartsWith("Assets/", StringComparison.Ordinal)) return;
                var m = named.Match(Path.GetFileNameWithoutExtension(p));
                if (!m.Success || m.Groups[1].Value == map) return;   // not named for a map, or named for this one
                if (!uses.TryGetValue(p, out var u)) uses[p] = u = new Use { kind = kind, path = p, dest = dest, owner = m.Groups[1].Value };
                u.repoint.Add(repoint);
            }
            foreach (var t in UnityEngine.Object.FindObjectsByType<Terrain>(FindObjectsInactive.Include).Where(t => t.gameObject.scene == scene))
                Add("TerrainData", t.terrainData, $"{dir}/{map}_terrain.asset", TerrainName, o => t.terrainData = (TerrainData)o);
            foreach (var c in UnityEngine.Object.FindObjectsByType<TerrainCollider>(FindObjectsInactive.Include).Where(c => c.gameObject.scene == scene))
                Add("TerrainData", c.terrainData, $"{dir}/{map}_terrain.asset", TerrainName, o => c.terrainData = (TerrainData)o);
            foreach (var s in UnityEngine.Object.FindObjectsByType<SplatMapInfo>(FindObjectsInactive.Include).Where(s => s.gameObject.scene == scene))
                foreach (var (name, get, set) in Masks)
                    Add(name + " mask", get(s), $"{dir}/{map}_mask_{name}.png", MaskName, o => set(s, (Texture2D)o));

            if (uses.Count > 0)
            {
                var scenes = AssetDatabase.FindAssets("t:Scene", new[] { "Assets" }).Select(AssetDatabase.GUIDToAssetPath)
                    .Where(p => p != scene.path).ToLookup(Path.GetFileNameWithoutExtension);
                foreach (var byOwner in uses.Values.GroupBy(u => u.owner))
                    foreach (var ownerScene in scenes[byOwner.Key])
                    {
                        LastScenesRead++;
                        var deps = new HashSet<string>(AssetDatabase.GetDependencies(ownerScene, false));
                        foreach (var u in byOwner.Where(u => deps.Contains(u.path)))
                            result.Add(new SharedMapAsset { kind = u.kind, path = u.path, dest = u.dest, scene = ownerScene, repoint = o => u.repoint.ForEach(r => r(o)) });
                    }
            }
            LastFindMs = sw.Elapsed.TotalMilliseconds;
            return result;
        }

        /// <summary>Copies each asset beside the scene and points the scene at the copy, and records the retail map the copy comes from
        /// (the source scene's own retail map, RetailMaps.SourceMap) in its layer-links file, for Prepare Lighting from Retail and
        /// Rebuild Terrain-Type Masks (map-kit A1 D17). Leaves the scene dirty; returns the new paths.</summary>
        public static List<string> Split(Scene scene, List<SharedMapAsset> shared)
        {
            var from = shared.Select(s => RetailMaps.SourceMap(s.scene)).FirstOrDefault(m => m != null);
            if (from != null && RetailMaps.SourceMap(scene.path) == null)
            {
                ContractLayers.SetCopiedFrom(scene, from);
                Debug.Log($"UCU Map Kit: {scene.name} records that it was saved from the retail map {from}.");
            }
            var made = new List<string>();
            foreach (var s in shared)
            {
                if (EditorUtility.IsDirty(AssetDatabase.LoadMainAssetAtPath(s.path)))
                    Debug.LogWarning($"UCU Map Kit: {s.path} has unsaved changes made before this copy existed; they stay with the original. Save before Save As next time.");
                var dest = AssetDatabase.GenerateUniqueAssetPath(s.dest);
                if (!AssetDatabase.CopyAsset(s.path, dest)) throw new InvalidOperationException($"Copying {s.path} to {dest} failed.");
                s.repoint(AssetDatabase.LoadMainAssetAtPath(dest));
                made.Add(dest);
                Debug.Log($"UCU Map Kit: {scene.name} now has its own {s.kind}, {dest} (a copy of {s.path}, which {Path.GetFileNameWithoutExtension(s.scene)} still uses).");
            }
            EditorSceneManager.MarkSceneDirty(scene);
            return made;
        }

        public const string CheckName = "shared-map-asset";

        /// <summary>Map Check: a TerrainData or mask this map shares with the map it is named for. Fix = this map takes its own copy.</summary>
        public static void AddCheckEntries(Scene scene, List<MapCheckEntry> entries)
        {
            if (string.IsNullOrEmpty(scene.path) || !scene.path.StartsWith("Assets/", StringComparison.Ordinal)) return;
            foreach (var s in Find(scene))
            {
                var other = Path.GetFileNameWithoutExtension(s.scene);
                var one = s;
                entries.Add(new MapCheckEntry
                {
                    severity = MapCheckSeverity.Warning, check = CheckName, target = AssetDatabase.LoadMainAssetAtPath(s.path),
                    message = $"The {s.kind} {Path.GetFileName(s.path)} is shared with {other}: sculpting or painting this map changes {other} too. Fix gives this map its own copy.",
                    detail = $"{s.path} is named for {other} and is listed in the dependencies of {s.scene}.",
                    fixTip = $"Copy {s.path} to {s.dest} and point this map at the copy (the copy stays if you Undo; save the scene to keep it).",
                    fix = () => Split(scene, new List<SharedMapAsset> { one }),
                });
            }
        }
    }
}
