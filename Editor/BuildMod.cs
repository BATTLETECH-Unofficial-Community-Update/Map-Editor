// UCU Map Kit: "Build Mod…". Turns the open map scene into a mod folder under <project>/MapKitOutput/<map>/: the map data
// (Export Map Data), a Skirmish icon, the scene AssetBundle, mapkit-map.json (the rows the shared MapKitLoader mod writes
// into the game's map database), the map's moods with mapkit-moods.json when it has any (Moods.cs), the map's contracts
// (data/<map>_<contract>.json, ContractWriter.cs), and mod.json. Writes
// nothing to the scene. Each step is named in the Console; the first failure stops the build and names its step.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    /// <summary>mapkit-map.json: the Map row and its EncounterLayer rows. MapKitLoader reads the same field names.</summary>
    [Serializable]
    public class MapKitMapFile
    {
        public string id;
        public string displayName;
        public string scenePath;
        public string biome;
        public string[] tags;
        public int weight;
        public MapKitLayerRow[] layers;
    }

    [Serializable]
    public class MapKitLayerRow
    {
        public string guid;
        public string name;
        public string friendlyName;
        public int contractTypeId;
        public string contractType;
    }

    [Serializable]
    public class ModManifestEntry
    {
        public string Type;
        public string Id;
        public string Path;
        public ModManifestEntry(string type, string id, string path) { Type = type; Id = id; Path = path; }
    }

    /// <summary>The ModTek mod.json fields a kit map uses. No DLL: MapKitLoader registers the map.</summary>
    [Serializable]
    public class ModJson
    {
        public string Name;
        public bool Enabled = true;
        public string Description;
        public string[] DependsOn;
        public ModManifestEntry[] Manifest;
    }

    public class BuildModResult
    {
        public string map;
        public string outputDir;
        public string failedStep;
        public string error;
        public List<string> steps = new List<string>();
        public List<string> files = new List<string>();
    }

    public static class BuildMod
    {
        public const string LoaderMod = "MapKitLoader";
        public const string MapFile = "mapkit-map.json";
        // Retail's Skirmish icons (the staged *_icon.dds) are all 542x305.
        public const int IconWidth = 542, IconHeight = 305;

        [MenuItem("UCU Map Kit/Build Mod…")]
        static void BuildMenu() => Build();

        public static BuildModResult Build()
        {
            var r = new BuildModResult();
            string step = null;
            try
            {
                step = "1/6 Map id";
                var scene = SceneManager.GetActiveScene();
                if (string.IsNullOrEmpty(scene.path))
                    throw new InvalidOperationException("The open scene has never been saved. Save the map scene first.");
                // The bundle is built from the scene file, the map data from the open scene: they must be the same.
                if (scene.isDirty)
                    throw new InvalidOperationException("The scene has unsaved changes. Save it first, so the bundle and the map data come from the same scene.");
                r.map = scene.name;
                var scenePath = scene.path;
                if (r.map.Contains(" "))
                    throw new InvalidOperationException($"Map id [{r.map}] contains a space. Rename the scene file.");
                // HBS marks every manifest entry whose id contains "template" as a template and never loads it
                // (VersionManifestEntry.cs:152, LoadRequest.TryCreateAndAddLoadRequest).
                if (r.map.IndexOf("template", StringComparison.OrdinalIgnoreCase) >= 0)
                    throw new InvalidOperationException($"Map id [{r.map}] contains \"template\": the game skips any file whose id contains it, so the map would not load. Rename the scene file.");
                r.outputDir = Path.Combine(Path.GetDirectoryName(Application.dataPath), "MapKitOutput", r.map);
                Done(r, step, r.map);

                step = "2/6 Check and export";
                // Map Check (UCU Map Kit/Map Check) first: its errors stop the build, its warnings are listed and pass.
                var check = MapCheck.Run();
                var errors = check.Where(e => e.severity == MapCheckSeverity.Error).ToList();
                if (errors.Count > 0)
                    throw new InvalidOperationException($"Map Check found {errors.Count} error(s); open UCU Map Kit/Map Check to fix them. {string.Join(" ", errors.Select(e => e.ToString()))}");
                foreach (var w in check.Where(e => e.severity == MapCheckSeverity.Warning))
                    Debug.LogWarning($"UCU Map Kit: Build Mod: Map Check {w}");
                // The folder is the kit's own output; it is replaced whole, so no file is written through an old link.
                if (Directory.Exists(r.outputDir))
                    Directory.Delete(r.outputDir, true);
                var export = MapExport.Export(validate: true);
                if (export.validation.Count > 0)
                    throw new InvalidOperationException($"{export.validation.Count} validation error(s): {string.Join("; ", export.validation)}");
                var dataDir = Path.Combine(r.outputDir, "data");
                Directory.CreateDirectory(dataDir);
                foreach (var f in export.files)
                    File.Move(Path.Combine(export.outputDir, f), Path.Combine(dataDir, f));
                var rows = ReadRows(scene);
                Done(r, step, $"Map Check 0 errors, {check.Count} warnings; {export.files.Count} files, {rows.layers.Length} layers");

                step = "3/6 Icon";
                var icon = $"{r.map}_icon.png";
                var preview = MapSettings.PreviewPath(scene);
                if (preview != null && File.Exists(preview))
                    Done(r, step, $"{IconWidth}x{IconHeight} from the Map tab's preview picture {preview} ({IconFromPicture(preview, Path.Combine(dataDir, icon))})");
                else
                {
                    RenderIcon(scenePath, Path.Combine(dataDir, icon));
                    Done(r, step, $"{IconWidth}x{IconHeight}, rendered from above (no preview picture)");
                }

                step = "4/6 Bundle";
                var bundleDir = Path.Combine(r.outputDir, "bundle");
                Directory.CreateDirectory(bundleDir);
                var bundleFile = r.map.ToLowerInvariant();
                int stripped = BuildBundleWithoutDesignMasks(scenePath, r.map, bundleDir);
                if (!File.Exists(Path.Combine(bundleDir, bundleFile)))
                    throw new InvalidOperationException("BuildPipeline.BuildAssetBundles built no bundle; the Console lines above it say why.");
                var moods = Moods.MapMoods(scenePath);
                var moodBundle = Moods.BundleName(r.map);
                if (moods.Length > 0 && !File.Exists(Path.Combine(bundleDir, moodBundle)))
                    throw new InvalidOperationException($"BuildPipeline.BuildAssetBundles built no mood bundle {moodBundle}; the Console lines above it say why.");
                Done(r, step, $"bundle/{bundleFile} ({stripped} SplatMapInfo removed from the bundled scene)" + (moods.Length > 0 ? $"; bundle/{moodBundle} ({moods.Length} moods)" : ""));

                step = "5/6 " + MapFile;
                File.WriteAllText(Path.Combine(r.outputDir, MapFile), JsonUtility.ToJson(rows, true));
                var registry = Moods.WriteRegistry(r.outputDir, scenePath, r.map);
                Done(r, step, $"{rows.id}, {rows.biome}, {rows.layers.Length} layers" + (registry != null ? $"; {Moods.RegistryFile}, {moods.Length} moods" : ""));

                step = "6/6 mod.json";
                var entries = new List<ModManifestEntry> { new ModManifestEntry("AssetBundle", r.map, "bundle/" + bundleFile) };
                if (moods.Length > 0)
                    entries.Add(new ModManifestEntry("AssetBundle", moodBundle, "bundle/" + moodBundle));
                foreach (var f in export.files.Where(f => f.EndsWith("_TerrainData.bin")))
                    entries.Add(new ModManifestEntry("TerrainData", Path.GetFileNameWithoutExtension(f), "data/" + f));
                foreach (var f in export.files.Where(f => f.EndsWith("_LayerData.bin")))
                    entries.Add(new ModManifestEntry("LayerData", Path.GetFileNameWithoutExtension(f), "data/" + f));
                entries.Add(new ModManifestEntry("Sprite", Path.GetFileNameWithoutExtension(icon), "data/" + icon));
                // The kit's contracts (ContractWriter.cs), under the type ModTek and retail-shaped mods use for contract files.
                foreach (var f in export.files.Where(f => f.EndsWith(".json")))
                    entries.Add(new ModManifestEntry(ContractWriter.ManifestType, Path.GetFileNameWithoutExtension(f), "data/" + f));
                var mod = new ModJson
                {
                    Name = r.map,
                    Description = $"UCU Map Kit map \"{rows.displayName}\". Needs the {LoaderMod} mod.",
                    DependsOn = new[] { LoaderMod },
                    Manifest = entries.ToArray(),
                };
                File.WriteAllText(Path.Combine(r.outputDir, "mod.json"), JsonUtility.ToJson(mod, true));
                Done(r, step, $"{entries.Count} manifest entries");

                r.files = Directory.GetFiles(r.outputDir, "*", SearchOption.AllDirectories)
                    .Select(p => p.Substring(r.outputDir.Length + 1).Replace('\\', '/')).OrderBy(p => p, StringComparer.Ordinal).ToList();
                Debug.Log($"UCU Map Kit: Build Mod wrote {r.files.Count} files to {r.outputDir}. Copy that folder into <UCU>/Mods/.");
            }
            catch (Exception e)
            {
                r.failedStep = step;
                r.error = e.Message;
                Debug.LogError($"UCU Map Kit: Build Mod stopped at step {step}: {e.Message}");
            }
            return r;
        }

        static void Done(BuildModResult r, string step, string detail)
        {
            r.steps.Add($"{step}: {detail}");
            Debug.Log($"UCU Map Kit: Build Mod step {step}: done ({detail})");
        }

        // The bundle leaves out the SplatMapInfo design masks. They are editor-only
        // design data (read by MapMetaDataExporter and TerrainRayCastHitTester, editor paths), no retail scene carries
        // them, and seven blank 2048 RGB24 masks were 88 MB of a 236 MB bundle (.hermes/reports/map-kit-bundle-size-
        // 20261122/report.md). The map data was exported at step 2 from the scene with its masks, so it is unchanged.
        // The scene file is copied aside, the component is removed and saved only for the build, and the original bytes
        // are put back in finally: the bundled scene keeps its path and name, and the modder's scene is untouched.
        static int BuildBundleWithoutDesignMasks(string scenePath, string map, string bundleDir)
        {
            var full = Path.Combine(Path.GetDirectoryName(Application.dataPath), scenePath);
            var backup = Path.Combine(Path.GetDirectoryName(Application.dataPath), "MapKitOutput", map + ".scene-backup");
            File.Delete(backup); File.Copy(full, backup); // delete, then copy: never write through a hard link
            int removed = 0;
            try
            {
                var scene = EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Single);
                foreach (var splat in UnityEngine.Object.FindObjectsByType<SplatMapInfo>(FindObjectsInactive.Include))
                {
                    UnityEngine.Object.DestroyImmediate(splat);
                    removed++;
                }
                EditorSceneManager.SaveScene(scene);
                if (BuildPipeline.BuildAssetBundles(bundleDir, BundleBuilds(scenePath, map), BuildAssetBundleOptions.UncompressedAssetBundle, BuildTarget.StandaloneWindows64) == null)
                    throw new InvalidOperationException("BuildPipeline.BuildAssetBundles returned no manifest; the Console lines above it say why.");
            }
            finally
            {
                File.Delete(full); File.Copy(backup, full);
                File.Delete(backup);
                AssetDatabase.ImportAsset(scenePath, ImportAssetOptions.ForceSynchronousImport);
                EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Single);
            }
            return removed;
        }

        /// <summary>What step 4 builds: the scene bundle, plus the map's mood bundle when it has moods (Moods.cs). Unity refuses a
        /// scene and other assets in one bundle, so the moods have their own.</summary>
        public static AssetBundleBuild[] BundleBuilds(string scenePath, string map)
        {
            var builds = new List<AssetBundleBuild> { new AssetBundleBuild { assetBundleName = map, assetNames = new[] { scenePath } } };
            var moods = Moods.Bundle(scenePath, map);
            if (moods != null) builds.Add(moods.Value);
            return builds.ToArray();
        }

        static MapKitMapFile ReadRows(Scene scene)
        {
            var exporter = UnityEngine.Object.FindAnyObjectByType<MapMetaDataExporter>(FindObjectsInactive.Include);
            var generator = Terrain.activeTerrain.GetComponent<TerrainGenerator>();
            var parent = exporter.GetComponent<EncounterLayerParent>();
            var layers = new List<MapKitLayerRow>();
            foreach (var layer in parent.EncounterLayerList)
            {
                var type = layer.SupportedContractTypeValue;
                if (type == null || type.IsInvalidUnsetRow)
                    throw new InvalidOperationException($"Encounter layer {layer.name} has no contract type.");
                layers.Add(new MapKitLayerRow { guid = layer.encounterObjectGuid, name = layer.name, friendlyName = layer.encounterName, contractTypeId = type.ID, contractType = type.Name });
            }
            return new MapKitMapFile
            {
                id = scene.name,
                displayName = string.IsNullOrEmpty(exporter.mapName) ? scene.name : exporter.mapName,
                scenePath = scene.path,
                biome = generator.biome.biomeSkin.ToString(),
                // The map's own tag, which its kit contracts require (ContractWriter.MapTag): written to the row only, the scene is unchanged.
                tags = (exporter.mapTags == null ? new string[0] : exporter.mapTags.ToArray()).Concat(new[] { ContractWriter.MapTag(scene.name) }).Distinct().ToArray(),
                weight = exporter.weight,
                layers = layers.ToArray(),
            };
        }

        // The Map tab's preview picture as the icon: copied byte for byte when it is already 542x305, else scaled to it.
        static string IconFromPicture(string picture, string outPath)
        {
            var bytes = File.ReadAllBytes(picture);
            var src = new Texture2D(2, 2);
            try
            {
                if (!src.LoadImage(bytes))
                    throw new InvalidOperationException($"{picture} is not a PNG the kit can read.");
                if (src.width == IconWidth && src.height == IconHeight)
                {
                    File.WriteAllBytes(outPath, bytes);
                    return "copied";
                }
                var rt = RenderTexture.GetTemporary(IconWidth, IconHeight, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
                var active = RenderTexture.active;
                var tex = new Texture2D(IconWidth, IconHeight, TextureFormat.RGB24, false);
                try
                {
                    Graphics.Blit(src, rt);
                    RenderTexture.active = rt;
                    tex.ReadPixels(new Rect(0, 0, IconWidth, IconHeight), 0, 0);
                    tex.Apply();
                    File.WriteAllBytes(outPath, tex.EncodeToPNG());
                }
                finally
                {
                    RenderTexture.active = active;
                    RenderTexture.ReleaseTemporary(rt);
                    UnityEngine.Object.DestroyImmediate(tex);
                }
                return $"scaled from {src.width}x{src.height}";
            }
            finally { UnityEngine.Object.DestroyImmediate(src); }
        }

        // A temporary orthographic camera straight down over the largest encounter boundary, the icon's width across it
        // (the K1d-2 icon recipe). The camera is never saved; if creating it marked the scene dirty, the scene (clean at
        // step 1) is reopened from disk.
        static void RenderIcon(string scenePath, string outPath)
        {
            var rect = UnityEngine.Object.FindObjectsByType<EncounterBoundaryRectGameLogic>(FindObjectsInactive.Include)
                .OrderByDescending(b => (long)b.width * b.height).FirstOrDefault();
            if (rect == null)
                throw new InvalidOperationException("The map has no encounter boundary (EncounterBoundaryRectGameLogic) to frame the icon.");
            var centre = rect.transform.position;
            var go = new GameObject("UCU Map Kit icon camera") { hideFlags = HideFlags.HideAndDontSave };
            var rt = new RenderTexture(IconWidth, IconHeight, 24, RenderTextureFormat.ARGB32);
            Texture2D tex = null;
            try
            {
                var cam = go.AddComponent<Camera>();
                cam.orthographic = true;
                cam.orthographicSize = rect.width / 2f * IconHeight / IconWidth;
                cam.transform.position = new Vector3(centre.x, 1500, centre.z);
                cam.transform.rotation = Quaternion.Euler(90, 0, 0);
                cam.nearClipPlane = 1;
                cam.farClipPlane = 3000;
                cam.clearFlags = CameraClearFlags.SolidColor;
                cam.backgroundColor = Color.black;
                cam.targetTexture = rt;
                cam.Render();
                RenderTexture.active = rt;
                tex = new Texture2D(IconWidth, IconHeight, TextureFormat.RGB24, false);
                tex.ReadPixels(new Rect(0, 0, IconWidth, IconHeight), 0, 0);
                tex.Apply();
                File.WriteAllBytes(outPath, tex.EncodeToPNG());
                cam.targetTexture = null;
            }
            finally
            {
                RenderTexture.active = null;
                rt.Release();
                UnityEngine.Object.DestroyImmediate(rt);
                if (tex != null)
                    UnityEngine.Object.DestroyImmediate(tex);
                UnityEngine.Object.DestroyImmediate(go);
            }
            if (SceneManager.GetActiveScene().isDirty)
                EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Single);
        }
    }
}
