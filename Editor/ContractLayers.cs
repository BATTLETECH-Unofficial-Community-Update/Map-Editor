// UCU Map Kit: encounter layers for other contract types, copied from the retail maps extracted on the modder's own machine
// (map-kit plan U9; design-v2 row 12, D-U2 = a: no retail layout ships in the kit).
// - Index: each extracted map scene under Assets/Level Design/Maps is read as text. Every EncounterLayerData block gives the
//   layer's GUID, its object name and its contract type, read from the component (supportedContractTypeID, or the older
//   supportedContractType enum when that field is empty or a number, as EncounterLayerData.SupportedContractTypeValue reads it),
//   never from the layer's name. The result is cached per scene file size and time.
// - Add: the source map is opened additively and the layer is instantiated into the open map. Every encounter object keeps its
//   GUID, because retail contracts address the objects by GUID (lessons/simplebattle-layers-share-contract-guids); only the layer
//   gets a new one, through HBS's GenerateNewGuid. Every *Ref is pointed at the copies with HBS's UpdateEncounterObjectGameObject,
//   as the template generator does. What points into the source map is cleared and recorded beside the scene for Map Check:
//   region building lists, building team assignments, plot overrides, and any reference or GUID of an object outside the layer. Then the source
//   map is closed, the layer becomes the active one, it is recentred on the open map's play area (kept inside the terrain's edge
//   band where it fits), and its objects are snapped to the hex grid and the ground (EncounterEdit). The whole Add is one Undo step.
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using BattleTech;
using BattleTech.Framework;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    /// <summary>One encounter layer of an extracted retail map.</summary>
    public class ContractLayerSource
    {
        public string map, scenePath, layerName, layerGuid, encounterName, typeName;
        public int typeId;
        public bool supported;
        public string Label => $"{map}  ({layerName})";
    }

    /// <summary>A link the copy cleared because it pointed into the source map. Map Check lists each one.</summary>
    [Serializable]
    public class ContractLayerLink
    {
        /// <summary>objectGuid: Add Ambush's only. The path alone names a different, same-named object once an Add Ambush is undone, so
        /// Map Check resolves by GUID first. Add Contract Layer leaves it empty: its records go with the layer's own GUID.</summary>
        public string layerGuid, layerName, sourceMap, objectPath, objectGuid, component, field, value, what;
    }

    [Serializable]
    class ContractLayerLinkFile
    {
        public List<ContractLayerLink> links = new List<ContractLayerLink>();
        /// <summary>The retail map this map was saved from with File > Save As (MapOwnAssets records it), or empty.</summary>
        public string copiedFrom;
    }

    public class ContractLayerAddResult
    {
        public EncounterLayerData layer;
        public string oldLayerGuid;
        public int objects, refs, refsRepointed, refsMoved, refsEmpty, snapped;
        public Vector3 sourceCentre, targetCentre, shift;
        public List<string> refsUnresolved = new List<string>();
        public List<ContractLayerLink> cleared = new List<ContractLayerLink>();
    }

    public static class ContractLayers
    {
        public const string CheckId = "source-map-link";
        static readonly Regex Header = new Regex(@"^--- !u!(\d+) &(-?\d+)", RegexOptions.Compiled);
        static readonly Regex FileId = new Regex(@"fileID: (-?\d+)", RegexOptions.Compiled);

        public static string MapsFolder => Path.Combine(Application.dataPath, "Level Design", "Maps");
        static string CacheFile => Path.Combine(RetailMaps.CatalogDir, "contract-layers.tsv");

        // ---- Index ----

        /// <summary>Every encounter layer of every extracted map scene, supported or not (supported: a single-player procedural
        /// contract type that is not story or restoration). Scenes whose size and time match the cache are not read again.</summary>
        public static List<ContractLayerSource> Index(bool rebuild = false, Action<string, float> progress = null)
        {
            var cache = rebuild ? new Dictionary<string, List<string[]>>() : ReadCache();
            var rows = new List<string[]>();
            var scriptGuid = EncounterLayerScriptGuid();
            var dirs = Directory.Exists(MapsFolder) ? Directory.GetDirectories(MapsFolder).OrderBy(d => d, StringComparer.Ordinal).ToArray() : new string[0];
            for (int i = 0; i < dirs.Length; i++)
            {
                var id = Path.GetFileName(dirs[i]);
                var file = Path.Combine(dirs[i], id + ".unity");
                if (!File.Exists(file)) continue;
                var info = new FileInfo(file);
                string key = $"{info.Length}\t{info.LastWriteTimeUtc.Ticks}";
                if (cache.TryGetValue(id, out var cached) && cached.Count > 0 && cached[0][1] + "\t" + cached[0][2] == key)
                {
                    rows.AddRange(cached);
                    continue;
                }
                progress?.Invoke(id, (float)i / dirs.Length);
                var found = ReadSceneLayers(file, scriptGuid);
                if (found.Count == 0) rows.Add(new[] { id, info.Length.ToString(), info.LastWriteTimeUtc.Ticks.ToString(), "", "", "", "", "0" });
                foreach (var f in found) rows.Add(new[] { id, info.Length.ToString(), info.LastWriteTimeUtc.Ticks.ToString(), f[0], f[1], f[2], f[3], f[4] });
            }
            Directory.CreateDirectory(RetailMaps.CatalogDir);
            File.WriteAllLines(CacheFile, new[] { "map\tbytes\tticks\tlayerGuid\tlayerName\tencounterName\tsupportedContractTypeID\tsupportedContractType" }
                .Concat(rows.Select(r => string.Join("\t", r))));

            var list = new List<ContractLayerSource>();
            foreach (var r in rows.Where(r => r[3].Length > 0))
            {
                var type = ResolveType(r[6], int.TryParse(r[7], out var e) ? e : 0);
                list.Add(new ContractLayerSource
                {
                    map = r[0], scenePath = $"Assets/Level Design/Maps/{r[0]}/{r[0]}.unity", layerGuid = r[3], layerName = r[4], encounterName = r[5],
                    typeName = type?.Name ?? (r[6].Length > 0 ? r[6] : "?"), typeId = type?.ID ?? 0,
                    supported = type != null && CanAdd(type),
                });
            }
            return list;
        }

        // Skirmish (ArenaSkirmish) is not procedural in HBS's table; a cloned campaign map needs its layer to appear in Skirmish.
        static bool CanAdd(ContractTypeValue t) => !t.IsInvalidUnsetRow && (t.IsSinglePlayerProcedural || t.IsSkirmish) && !t.IsStoryOrRestoration;

        /// <summary>The contract types a modder can add: HBS's single-player procedural types that are not story or restoration, and Skirmish.</summary>
        public static List<ContractTypeValue> SupportedTypes() => ContractTypeEnumeration.ContractTypeValueList
            .Where(CanAdd).OrderBy(t => t.Name, StringComparer.Ordinal).ToList();

        // As EncounterLayerData.SupportedContractTypeValue: the ID string, or the legacy enum's name when the string is empty or a number.
        static ContractTypeValue ResolveType(string id, int legacy)
        {
            var name = string.IsNullOrEmpty(id) || int.TryParse(id, out _) ? ((ContractType)legacy).ToString() : id;
            return ContractTypeEnumeration.ContractTypeValueList.FirstOrDefault(t => t.Name == name);
        }

        static string EncounterLayerScriptGuid()
        {
            foreach (var g in AssetDatabase.FindAssets("EncounterLayerData t:MonoScript"))
            {
                var s = AssetDatabase.LoadAssetAtPath<MonoScript>(AssetDatabase.GUIDToAssetPath(g));
                if (s != null && s.GetClass() == typeof(EncounterLayerData)) return g;
            }
            throw new InvalidOperationException("The EncounterLayerData script was not found in this project, so the extracted maps' layers cannot be read. Run the kit's setup first.");
        }

        // Each EncounterLayerData block of a text scene: guid, GameObject name, encounterName, supportedContractTypeID, supportedContractType.
        static List<string[]> ReadSceneLayers(string file, string scriptGuid)
        {
            var names = new Dictionary<long, string>();
            var layers = new List<(long go, string guid, string encounter, string id, string legacy)>();
            int cls = 0;
            long go = 0;
            bool isLayer = false;
            string guid = "", encounter = "", typeId = "", legacy = "0";
            void Flush() { if (isLayer) layers.Add((go, guid, encounter, typeId, legacy)); isLayer = false; go = 0; guid = encounter = typeId = ""; legacy = "0"; }
            long id = 0;
            foreach (var line in File.ReadLines(file))
            {
                if (line.StartsWith("--- !u!", StringComparison.Ordinal))
                {
                    Flush();
                    var m = Header.Match(line);
                    cls = m.Success ? int.Parse(m.Groups[1].Value) : 0;
                    id = m.Success ? long.Parse(m.Groups[2].Value) : 0;
                    continue;
                }
                if (cls == 1)
                {
                    if (line.StartsWith("  m_Name: ", StringComparison.Ordinal)) names[id] = Unquote(line.Substring(10));
                }
                else if (cls == 114)
                {
                    if (line.StartsWith("  m_GameObject: ", StringComparison.Ordinal)) { var m = FileId.Match(line); if (m.Success) go = long.Parse(m.Groups[1].Value); }
                    else if (line.StartsWith("  m_Script: ", StringComparison.Ordinal)) isLayer = line.Contains("guid: " + scriptGuid);
                    else if (!isLayer) continue;
                    else if (line.StartsWith("  encounterObjectGuid: ", StringComparison.Ordinal)) guid = Unquote(line.Substring(23));
                    else if (line.StartsWith("  encounterName: ", StringComparison.Ordinal)) encounter = Unquote(line.Substring(17));
                    else if (line.StartsWith("  supportedContractTypeID: ", StringComparison.Ordinal)) typeId = Unquote(line.Substring(27));
                    else if (line.StartsWith("  supportedContractType: ", StringComparison.Ordinal)) legacy = line.Substring(25).Trim();
                }
            }
            Flush();
            return layers.Select(l => new[] { l.guid, names.TryGetValue(l.go, out var n) ? n : "", l.encounter, l.id, l.legacy }).ToList();
        }

        static string Unquote(string s)
        {
            s = s.Trim();
            if (s.Length >= 2 && (s[0] == '\'' && s[s.Length - 1] == '\'' || s[0] == '"' && s[s.Length - 1] == '"')) s = s.Substring(1, s.Length - 2);
            return s.Replace("\t", " ");
        }

        static Dictionary<string, List<string[]>> ReadCache()
        {
            var d = new Dictionary<string, List<string[]>>();
            if (!File.Exists(CacheFile)) return d;
            foreach (var line in File.ReadLines(CacheFile).Skip(1))
            {
                var c = line.Split('\t');
                if (c.Length < 8) continue;
                if (!d.TryGetValue(c[0], out var l)) d[c[0]] = l = new List<string[]>();
                l.Add(c);
            }
            return d;
        }

        // ---- Add ----

        /// <summary>Copies the layer into the open map (see the file header). One Undo step; the open scene is left dirty, not saved.</summary>
        public static ContractLayerAddResult Add(ContractLayerSource src)
        {
            var target = SceneManager.GetActiveScene();
            if (string.IsNullOrEmpty(target.path))
                throw new InvalidOperationException("Save the open map first: the copy records what it cleared in a file beside the scene.");
            if (src.scenePath == target.path)
                throw new InvalidOperationException("The open map is the source map. Open the map the layer should go into.");
            var scene = MapPreconditions.Require(forExport: false);
            var parent = scene.parent;
            // Export would refuse the pair (MapPreconditions.DuplicateLayer; kfix10: a template map's own encArena_Skirmish and a copied one). Refused before anything is copied.
            if (EncounterEdit.Layers(parent).Any(l => MapPreconditions.LayerFileKey(l.name) == MapPreconditions.LayerFileKey(src.layerName)))
                throw new InvalidOperationException($"The open map already has a layer named {src.layerName}. Export names each layer's files after the layer, so a second one would overwrite the first one's data. " +
                    "Delete that layer first (select it in the Hierarchy and press Delete), then add this one.");
            var r = new ContractLayerAddResult { targetCentre = PlayCentre(parent, scene.terrain) };
            string label = $"Map Kit: add {src.typeName} layer from {src.map}";
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName(label);
            int group = Undo.GetCurrentGroup();

            GameObject copy = null;
            Scene source = default;
            try
            {
                source = OpenSource(src.scenePath);
                var original = source.GetRootGameObjects().SelectMany(g => g.GetComponentsInChildren<EncounterLayerData>(true))
                    .FirstOrDefault(l => l.encounterObjectGuid == src.layerGuid)
                    ?? throw new InvalidOperationException($"Layer {src.layerName} ({src.layerGuid}) is not in {src.scenePath} any more. Rebuild the index.");
                SceneManager.SetActiveScene(target);
                copy = UnityEngine.Object.Instantiate(original.gameObject); // lands in the active scene, as a root
                copy.name = original.name;

                var inLayer = new HashSet<string>(original.GetComponentsInChildren<EncounterObjectGameLogic>(true).Select(o => o.encounterObjectGuid).Where(g => !string.IsNullOrEmpty(g)));
                var outside = new HashSet<string>(source.GetRootGameObjects().SelectMany(g => g.GetComponentsInChildren<EncounterObjectGameLogic>(true))
                    .Where(o => !o.transform.IsChildOf(original.transform)).Select(o => o.encounterObjectGuid).Where(g => !string.IsNullOrEmpty(g)));
                outside.ExceptWith(inLayer);

                var layer = copy.GetComponent<EncounterLayerData>();
                r.oldLayerGuid = layer.encounterObjectGuid;
                ClearSourceLinks(copy, layer, src, source, outside, r);
                Repoint(copy, r);
                layer.GenerateNewGuid();
                r.layer = layer;
                r.objects = copy.GetComponentsInChildren<EncounterObjectGameLogic>(true).Length;
            }
            catch
            {
                if (copy != null) UnityEngine.Object.DestroyImmediate(copy);
                throw;
            }
            finally
            {
                CloseSource(source);
                SceneManager.SetActiveScene(target);
            }

            // No object GUID: the layer took a new one after the links were recorded, and a removed building team assignment has none left.
            foreach (var link in r.cleared) { link.layerGuid = r.layer.encounterObjectGuid; link.objectGuid = ""; }
            Undo.RegisterCreatedObjectUndo(copy, label);
            try
            {
                Undo.SetTransformParent(copy.transform, parent.transform, label);
                // HBS's SelectEncounterLayerByIndex range-checks against its cached list before it refreshes it, so a new layer's
                // index would read as out of range and leave no layer selected.
                parent.UpdateEncounterLayerList();
                int index = Array.IndexOf(parent.EncounterLayerList, r.layer);
                EncounterEdit.SelectLayer(parent, index);
                Recentre(r, scene.terrain);
                r.snapped = Snap(r.layer);
            }
            catch
            {
                // A half-made Add is taken back whole, so the open map is as it was before the button.
                Undo.RevertAllDownToGroup(group);
                throw;
            }
            Undo.CollapseUndoOperations(group);
            EditorSceneManager.MarkSceneDirty(target);
            WriteLinks(target, r.layer, r.cleared);
            Selection.activeGameObject = copy;
            Debug.Log($"UCU Map Kit: added {src.typeName} layer {copy.name} from {src.map}: {r.objects} encounter objects, {r.refsRepointed} references on the copies, " +
                $"{r.cleared.Count} source-map links cleared (Map Check lists them), moved by ({r.shift.x:0.#}, {r.shift.z:0.#}), {r.snapped} objects snapped.");
            return r;
        }

        // The open map's play area: the centre of the active layer's encounter boundary, else of the first layer that has one, else
        // of the terrain.
        static Vector3 PlayCentre(EncounterLayerParent parent, Terrain terrain)
        {
            var layers = EncounterEdit.Layers(parent);
            foreach (var l in layers.OrderByDescending(l => l.gameObject.activeSelf))
            {
                var rects = l.GetComponentsInChildren<EncounterBoundaryRectGameLogic>(true);
                if (rects.Length > 0) return Centre(rects);
            }
            var t = terrain.transform.position;
            var size = terrain.terrainData.size;
            return new Vector3(t.x + size.x / 2f, 0f, t.z + size.z / 2f);
        }

        static Vector3 Centre(EncounterBoundaryRectGameLogic[] rects)
        {
            var all = rects.Select(r => r.GetRect()).ToArray();
            float x0 = all.Min(r => r.xMin), x1 = all.Max(r => r.xMax), z0 = all.Min(r => r.yMin), z1 = all.Max(r => r.yMax);
            return new Vector3((x0 + x1) / 2f, 0f, (z0 + z1) / 2f);
        }

        // Moves the layer so its play area's centre lands on the open map's, on HBS's 4 m boundary step (EncounterEdit.BoundaryCentreStep),
        // then, where the copied play area fits inside the terrain less HBS's edge band (SplatMapInfo.mapBoundaryWidth), no further out than
        // that: a large arena layer centred on a smaller layer's play area ran off the map (map-kit KFIX7: Split River's 1,500 m arena on
        // Taiga River reached 210 m past the south edge, its lance in the edge band, and Map Check failed the README route).
        static void Recentre(ContractLayerAddResult r, Terrain terrain)
        {
            var rects = r.layer.GetComponentsInChildren<EncounterBoundaryRectGameLogic>(true);
            var t = r.layer.transform;
            r.sourceCentre = rects.Length > 0 ? Centre(rects) : t.position;
            float step = EncounterEdit.BoundaryCentreStep;
            var want = r.targetCentre;
            if (rects.Length > 0 && terrain != null)
            {
                var all = rects.Select(x => x.GetRect()).ToArray();
                float halfX = (all.Max(x => x.xMax) - all.Min(x => x.xMin)) / 2f, halfZ = (all.Max(x => x.yMax) - all.Min(x => x.yMin)) / 2f;
                var o = terrain.transform.position; var size = terrain.terrainData.size; float band = SplatMapInfo.mapBoundaryWidth;
                float Fit(float c, float lo, float hi, float half) => hi - lo < 2f * half ? (lo + hi) / 2f : Mathf.Clamp(c, lo + half, hi - half);
                want = new Vector3(Fit(want.x, o.x + band, o.x + size.x - band, halfX), 0f, Fit(want.z, o.z + band, o.z + size.z - band, halfZ));
            }
            // Round toward the terrain centre, so the 4 m step never pushes a fitted play area back over the band.
            var mid = terrain != null ? terrain.transform.position + terrain.terrainData.size / 2f : Vector3.zero;
            float Step(float v, float m) => (v > m ? Mathf.Floor(v / step) : Mathf.Ceil(v / step)) * step;
            var to = new Vector3(Step(want.x, mid.x), 0f, Step(want.z, mid.z));
            r.shift = new Vector3(to.x - r.sourceCentre.x, 0f, to.z - r.sourceCentre.z);
            Undo.RecordObject(t, "Map Kit: recentre layer");
            t.position += r.shift;
        }

        // Lances with their points, regions and their points, any other world point, and the play-area objects (ground only, the
        // centre stays where the recentre put it). Runs after the layer is active, since HBS lists a lance's points as active children.
        internal static int Snap(Component layer)
        {
            int n = 0;
            var done = new HashSet<Component>();
            foreach (var lance in layer.GetComponentsInChildren<LanceSpawnerGameLogic>(true))
            {
                EncounterEdit.SnapLance(lance);
                done.Add(lance); n++;
                foreach (var p in lance.unitSpawnPointGameLogicList) { done.Add(p); n++; }
            }
            foreach (var region in layer.GetComponentsInChildren<RegionGameLogic>(true))
            {
                EncounterEdit.SnapToHexAndGround(region.transform);
                done.Add(region); n++;
                foreach (var p in region.regionPointList) { EncounterEdit.SnapPoint(p); done.Add(p); n++; }
            }
            foreach (var p in layer.GetComponentsInChildren<WorldPointGameLogic>(true).Where(p => !done.Contains(p)))
            {
                EncounterEdit.SnapPoint(p);
                n++;
            }
            foreach (var rect in layer.GetComponentsInChildren<EncounterBoundaryRectGameLogic>(true))
            {
                EncounterEdit.SnapToGround(rect.transform);
                n++;
            }
            return n;
        }

        // ---- What points into the source map ----

        internal static void ClearSourceLinks(GameObject copy, EncounterLayerData layer, ContractLayerSource src, Scene source, HashSet<string> outside, ContractLayerAddResult r)
        {
            // The exporter fills buildingGuidsInRegion from this map's buildings (MapMetaDataExporter: InitRegionForRayCasting, then
            // AddBuildingGuidToRegion); the copy's list names the source map's.
            foreach (var region in copy.GetComponentsInChildren<RegionGameLogic>(true))
            {
                foreach (var g in region.buildingGuidsInRegion)
                    r.cleared.Add(Link(layer, src, region, "buildingGuidsInRegion", g, "building in the region"));
                region.buildingGuidsInRegion = new List<string>();
            }
            // A building team assignment hands every building with its tags to a team; those buildings are the source map's. An
            // empty tag set would match every building, so the assignment is removed, its team and tags listed.
            foreach (var bta in copy.GetComponentsInChildren<BuildingTeamAssignmentGameLogic>(true))
            {
                r.cleared.Add(Link(layer, src, bta, "requiredTagsOnBuilding", bta.requiredTagsOnBuilding == null ? "" : string.Join(",", bta.requiredTagsOnBuilding.ToArray()),
                    $"building team assignment (team {bta.teamDefinitionGuid})"));
                var go = bta.gameObject;
                bool alone = go.transform.childCount == 0 && go.GetComponents<Component>().Length == 2 && go != copy;
                if (alone) UnityEngine.Object.DestroyImmediate(go);
                else UnityEngine.Object.DestroyImmediate(bta);
            }
            // A plot override switches the source map's urban plots (by plot name) when the layer is selected; HBS's
            // EncounterLayerData.OverridePlots then needs a PlotParent, which a map without those plots does not have (it throws).
            foreach (var po in copy.GetComponentsInChildren<PlotOverride>(true))
            {
                foreach (var e in po.plotOverrideEntryList)
                    r.cleared.Add(Link(layer, src, po, "plotOverrideEntryList", $"{e.plotName} -> {e.plotVariant}", "plot override"));
                if (po.plotOverrideEntryList.Count == 0)
                    r.cleared.Add(Link(layer, src, po, "plotOverrideEntryList", "(empty)", "plot override"));
                UnityEngine.Object.DestroyImmediate(po);
            }
            // Anything else: a scene reference into the source map, or a GUID string of an object outside the layer.
            foreach (var c in copy.GetComponentsInChildren<MonoBehaviour>(true))
            {
                if (c == null) continue;
                var so = new SerializedObject(c);
                var p = so.GetIterator();
                bool changed = false;
                while (p.Next(true))
                {
                    if (p.propertyType == SerializedPropertyType.ObjectReference)
                    {
                        var o = p.objectReferenceValue;
                        if (o == null || EditorUtility.IsPersistent(o)) continue;
                        var go = o as GameObject ?? (o as Component)?.gameObject;
                        if (go == null || go.scene != source) continue;
                        r.cleared.Add(Link(layer, src, c, p.propertyPath, MapCheck.PathOf(go.transform), "reference to an object of the source map"));
                        p.objectReferenceValue = null;
                        changed = true;
                    }
                    else if (p.propertyType == SerializedPropertyType.String && p.propertyPath != "encounterObjectGuid" && outside.Contains(p.stringValue))
                    {
                        if (!p.propertyPath.EndsWith("loadingGuid", StringComparison.Ordinal))
                            r.cleared.Add(Link(layer, src, c, p.propertyPath, p.stringValue, "GUID of an object outside the layer"));
                        p.stringValue = "";
                        changed = true;
                    }
                }
                if (changed) so.ApplyModifiedPropertiesWithoutUndo();
            }
        }

        static ContractLayerLink Link(EncounterLayerData layer, ContractLayerSource src, Component c, string field, string value, string what) => new ContractLayerLink
        {
            layerName = layer.name, sourceMap = src.map, objectPath = RelativePath(layer.transform, c.transform), objectGuid = (c as EncounterObjectGameLogic)?.encounterObjectGuid ?? "", component = c.GetType().Name, field = field, value = value, what = what,
        };

        static string RelativePath(Transform root, Transform t)
        {
            var parts = new List<string>();
            for (; t != null && t != root; t = t.parent) parts.Add(t.name);
            parts.Reverse();
            return string.Join("/", parts);
        }

        // ---- Re-point every *Ref to the copies ----

        // byGuid: the copies by the GUID their references still carry; built here unless the caller gave the copies new GUIDs
        // first (EncounterScripting's Add Ambush passes the copies under their old GUIDs).
        internal static void Repoint(GameObject copy, ContractLayerAddResult r, Dictionary<string, EncounterObjectGameLogic> byGuid = null)
        {
            if (byGuid == null)
            {
                byGuid = new Dictionary<string, EncounterObjectGameLogic>();
                foreach (var o in copy.GetComponentsInChildren<EncounterObjectGameLogic>(true))
                    if (!string.IsNullOrEmpty(o.encounterObjectGuid) && !byGuid.ContainsKey(o.encounterObjectGuid)) byGuid[o.encounterObjectGuid] = o;
            }
            var seen = new HashSet<object>(ReferenceEqualityComparer.Instance);
            foreach (var o in copy.GetComponentsInChildren<EncounterObjectGameLogic>(true))
                Walk(o, o, byGuid, r, seen, 0);
        }

        sealed class ReferenceEqualityComparer : IEqualityComparer<object>
        {
            public static readonly ReferenceEqualityComparer Instance = new ReferenceEqualityComparer();
            public new bool Equals(object a, object b) => ReferenceEquals(a, b);
            public int GetHashCode(object o) => System.Runtime.CompilerServices.RuntimeHelpers.GetHashCode(o);
        }

        static void Walk(object obj, EncounterObjectGameLogic owner, Dictionary<string, EncounterObjectGameLogic> byGuid, ContractLayerAddResult r, HashSet<object> seen, int depth)
        {
            if (obj == null || depth > 4 || !seen.Add(obj)) return;
            foreach (var f in SerializedFields(obj.GetType()))
            {
                var v = f.GetValue(obj);
                if (v == null || v is string || v is UnityEngine.Object) continue;
                if (RefBase(v.GetType()) != null) { Fix(v, owner, f.Name, byGuid, r); continue; }
                if (v is IList list)
                {
                    foreach (var item in list)
                        if (item != null && RefBase(item.GetType()) != null) Fix(item, owner, f.Name, byGuid, r);
                        else if (item != null && IsData(item.GetType())) Walk(item, owner, byGuid, r, seen, depth + 1);
                    continue;
                }
                if (IsData(v.GetType())) Walk(v, owner, byGuid, r, seen, depth + 1);
            }
        }

        static void Fix(object reference, EncounterObjectGameLogic owner, string field, Dictionary<string, EncounterObjectGameLogic> byGuid, ContractLayerAddResult r)
        {
            r.refs++;
            var baseType = RefBase(reference.GetType());
            var guid = (string)baseType.GetField("internalEncounterObjectGuid", BindingFlags.Instance | BindingFlags.NonPublic).GetValue(reference);
            if (string.IsNullOrEmpty(guid)) { r.refsEmpty++; return; }
            if (!byGuid.TryGetValue(guid, out var target))
            {
                r.refsUnresolved.Add($"{owner.name}.{field} -> {guid}");
                return;
            }
            var before = baseType.GetField("encounterObject").GetValue(reference) as UnityEngine.Object;
            baseType.GetMethod("UpdateEncounterObjectGameObject").Invoke(reference, new object[] { target });
            var after = baseType.GetField("encounterObject").GetValue(reference) as UnityEngine.Object;
            if (after == null) { r.refsUnresolved.Add($"{owner.name}.{field} -> {guid} ({target.GetType().Name} does not fit {baseType.GetGenericArguments()[0].Name})"); return; }
            r.refsRepointed++;
            if (before != after) r.refsMoved++;
        }

        static Type RefBase(Type t)
        {
            for (; t != null && t != typeof(object); t = t.BaseType)
                if (t.IsGenericType && t.GetGenericTypeDefinition() == typeof(EncounterObjectRef<>)) return t;
            return null;
        }

        static bool IsData(Type t) => t.IsClass && !typeof(UnityEngine.Object).IsAssignableFrom(t) && t != typeof(string) && t.IsDefined(typeof(SerializableAttribute), false);

        // The fields Unity serializes: instance fields, public or [SerializeField], not [NonSerialized], down the class chain.
        static IEnumerable<FieldInfo> SerializedFields(Type t)
        {
            for (; t != null && t != typeof(MonoBehaviour) && t != typeof(object); t = t.BaseType)
                foreach (var f in t.GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly))
                    if ((f.IsPublic || f.IsDefined(typeof(SerializeField), false)) && !f.IsNotSerialized) yield return f;
        }

        // ---- Opening a source map beside the open one ----

        // HBS's map singletons (MoodController, WeatherController, EncounterLayerParent) are [ExecuteInEditMode], so their Awake runs
        // in the Editor, and an Awake that finds another instance already set calls Destroy on its own object, which Unity refuses in
        // edit mode with an ERROR ("<X>: Destroy may not be called from edit mode!", map-kit A1 D8; measured from Add Ambush's
        // additive open). A source map carries its own of each. So while it opens, the open map's instances are taken out of those
        // static fields (_instance, _hasInstance, _hasCheckedForInstance on the singleton's class chain) and put back at once; they
        // are put back again after the source closes, because HBS's OnDestroy clears the field whoever holds it.
        static readonly string[] SingletonFields = { "_instance", "_hasInstance", "_hasCheckedForInstance" };

        static bool RunsInEditMode(Type t) => t.IsDefined(typeof(ExecuteInEditMode), true) || t.IsDefined(typeof(ExecuteAlways), true);

        // The singleton statics on <paramref name="type"/>'s class chain (the closed generic base holds them for a SceneSingletonBehavior).
        static IEnumerable<FieldInfo> SingletonStatics(Type type)
        {
            for (var t = type; t != null && t != typeof(MonoBehaviour); t = t.BaseType)
                foreach (var f in t.GetFields(BindingFlags.Static | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly))
                    if (SingletonFields.Contains(f.Name) && (f.FieldType == typeof(bool) || f.FieldType.IsAssignableFrom(type))) yield return f;
        }

        static List<(FieldInfo field, object value)> Singletons()
        {
            var held = new List<(FieldInfo, object)>();
            var seen = new HashSet<FieldInfo>();
            var types = UnityEngine.Object.FindObjectsByType<MonoBehaviour>(FindObjectsInactive.Include).Where(m => m != null).Select(m => m.GetType()).Distinct().Where(RunsInEditMode);
            foreach (var type in types)
                foreach (var f in SingletonStatics(type))
                    if (seen.Add(f)) held.Add((f, f.GetValue(null)));
            return held;
        }

        // ---- Singleton lookups left over from the previous scene ----

        // HBS's SceneSingletonBehavior<T> finds its instance with one FindObjectOfType, and only while _hasCheckedForInstance is false; a
        // lookup sets it true whether or not it found anything, and only Awake and OnDestroy reset it. In edit mode neither runs for a class
        // that is not ExecuteInEditMode (DebugConsole), so the first lookup of an Editor session is kept for good: a map opened later, whose
        // EncounterLayerParent.Start asks for the DebugConsole, gets the old scene's destroyed object, or none, and HBS logs "Attempt to
        // access undefined Scene singleton" although the scene has one (map-kit KFIX9 S1; measured on the A1 Editor).
        // So when a scene has finished opening in edit mode the lookups of those classes are forgotten (MetadataDatabaseWarmup, sceneOpened), and the
        // next lookup searches the new scene. Not before it opens: a lookup made while the scene loads, before the new DebugConsole exists, would be
        // kept (measured: a reset in sceneOpening failed the first open after each start or reload; who makes that lookup was not traced).
        // The classes are every SceneSingletonBehavior<T> subclass of the game assembly: DataManagerUnityInstance, DebugConsole,
        // LevelLoadRequestListener, SceneKVPStore, UnityGameInstance and WwiseManager. Their _instance is only a lookup cache in edit mode
        // (Awake does not write it there), so forgetting it loses nothing. EncounterLayerParent is the seventh and is left alone: it is
        // ExecuteInEditMode, its Awake and OnDestroy keep its fields true to the scene, and OpenSource above depends on them.
        internal static List<string> ResetSceneSingletons()
        {
            var reset = new List<string>();
            foreach (var type in typeof(EncounterLayerParent).Assembly.GetTypes())
            {
                if (type.IsAbstract || RunsInEditMode(type)) continue;
                var b = type.BaseType;
                while (b != null && !(b.IsGenericType && b.GetGenericTypeDefinition() == typeof(HBS.SceneSingletonBehavior<>))) b = b.BaseType;
                if (b == null) continue;
                foreach (var f in SingletonStatics(type)) f.SetValue(null, f.FieldType == typeof(bool) ? (object)false : null);
                reset.Add(type.Name);
            }
            return reset;
        }

        static void PutBack(List<(FieldInfo field, object value)> held)
        {
            foreach (var (f, v) in held) f.SetValue(null, v);
        }

        /// <summary>Opens a source map additively without HBS's singletons in it trying to destroy themselves (see above).</summary>
        internal static Scene OpenSource(string scenePath)
        {
            var held = Singletons();
            foreach (var (f, _) in held) f.SetValue(null, f.FieldType == typeof(bool) ? (object)false : null);
            try { return EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Additive); }
            finally { PutBack(held); }
        }

        internal static void CloseSource(Scene source)
        {
            if (!source.IsValid() || !source.isLoaded) return;
            var held = Singletons();
            EditorSceneManager.CloseScene(source, true);
            PutBack(held);
        }

        // ---- The record Map Check reads (and the retail map a Save As copy came from) ----

        public static string LinksFile(Scene scene) => LinksFile(scene.path);
        static string LinksFile(string scenePath) => string.IsNullOrEmpty(scenePath) ? null : $"{Path.GetDirectoryName(scenePath).Replace('\\', '/')}/{Path.GetFileNameWithoutExtension(scenePath)}_layer-links.json";

        static ContractLayerLinkFile ReadLinks(Scene scene) => ReadLinks(scene.path);
        static ContractLayerLinkFile ReadLinks(string scenePath)
        {
            var path = LinksFile(scenePath);
            var full = path == null ? null : Path.Combine(Path.GetDirectoryName(Application.dataPath), path);
            if (full == null || !File.Exists(full)) return new ContractLayerLinkFile();
            return JsonUtility.FromJson<ContractLayerLinkFile>(File.ReadAllText(full)) ?? new ContractLayerLinkFile();
        }

        /// <summary>The retail map the scene at <paramref name="scenePath"/> was saved from (its layer-links record), or null.</summary>
        public static string CopiedFrom(string scenePath)
        {
            var from = ReadLinks(scenePath).copiedFrom;
            return string.IsNullOrEmpty(from) ? null : from;
        }

        /// <summary>Records in the scene's layer-links file the retail map it was saved from (MapOwnAssets, on Save As).</summary>
        internal static void SetCopiedFrom(Scene scene, string retailMap)
        {
            var file = ReadLinks(scene);
            if (file.copiedFrom == retailMap) return;
            file.copiedFrom = retailMap;
            var path = LinksFile(scene);
            File.WriteAllText(Path.Combine(Path.GetDirectoryName(Application.dataPath), path), JsonUtility.ToJson(file, true));
            AssetDatabase.ImportAsset(path);
        }

        // Records of layers no longer in the scene (an undone Add) are dropped when the next Add writes the file. An Add of a whole
        // layer replaces that layer's records; an Add into a layer (Add Ambush, keepLayer) adds to them.
        internal static void WriteLinks(Scene scene, EncounterLayerData layer, List<ContractLayerLink> links, bool keepLayer = false)
        {
            var file = ReadLinks(scene);
            var present = new HashSet<string>(UnityEngine.Object.FindObjectsByType<EncounterLayerData>(FindObjectsInactive.Include).Select(l => l.encounterObjectGuid));
            // An object an undone Add Ambush took away leaves its record behind; it is dropped here (records of old files carry no object GUID and stay).
            var objects = new HashSet<string>(UnityEngine.Object.FindObjectsByType<EncounterObjectGameLogic>(FindObjectsInactive.Include).Select(o => o.encounterObjectGuid));
            file.links = file.links.Where(l => present.Contains(l.layerGuid) && (keepLayer || l.layerGuid != layer.encounterObjectGuid)
                && (string.IsNullOrEmpty(l.objectGuid) || objects.Contains(l.objectGuid))).Concat(links).ToList();
            var path = LinksFile(scene);
            File.WriteAllText(Path.Combine(Path.GetDirectoryName(Application.dataPath), path), JsonUtility.ToJson(file, true));
            AssetDatabase.ImportAsset(path);
        }

        /// <summary>Map Check: one warning per cleared link of a copied layer that is still in the open map.</summary>
        public static void AddCheckEntries(EncounterLayerParent parent, List<MapCheckEntry> entries)
        {
            var file = ReadLinks(SceneManager.GetActiveScene());
            if (file.links.Count == 0) return;
            var layers = EncounterEdit.Layers(parent).ToDictionary(l => l.encounterObjectGuid, l => l);
            foreach (var link in file.links)
            {
                if (!layers.TryGetValue(link.layerGuid, out var layer)) continue;
                var t = !string.IsNullOrEmpty(link.objectGuid)
                    ? layer.GetComponentsInChildren<EncounterObjectGameLogic>(true).FirstOrDefault(o => o.encounterObjectGuid == link.objectGuid)?.transform
                    : string.IsNullOrEmpty(link.objectPath) ? layer.transform : layer.transform.Find(link.objectPath);
                // The object is gone (an undone Add Ambush, which leaves its layer in place): nothing is left to relink.
                if (t == null) continue;
                entries.Add(new MapCheckEntry
                {
                    severity = MapCheckSeverity.Warning, check = CheckId, target = t.gameObject,
                    message = $"{t.name} (layer {layer.name}, copied from {link.sourceMap}): its {link.what} was cleared, because it pointed at {link.sourceMap}'s own map. " +
                        "Link it to an object of this map if the contract needs it.",
                    detail = $"{link.component}.{link.field} = {link.value}",
                });
            }
        }
    }
}
