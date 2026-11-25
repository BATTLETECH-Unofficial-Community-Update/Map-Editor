// UCU Map Kit: Map Check. Lists what would stop the open map from exporting or playing: the exporter's preconditions,
// HBS's EncounterLayerData.Validate on every layer (as Export runs it), the exporter's obstruction-without-renderer case
// (MapMetaDataExporter.MarkCellsForRaycasting), and the kit's own checks (design-v2 § 4.3). HBS code is called, never
// copied. The check is read-only. HBS's Validate refreshes some of its own fields (isValid, a GUID for an object that has
// none), and the check selects each layer as Export does; afterwards it puts the selection, the layers' active state and
// every encounter component's serialized fields back as they were.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    public enum MapCheckSeverity { Error, Warning }

    public class MapCheckEntry
    {
        public MapCheckSeverity severity;
        public string check;
        public string message;
        public string detail;
        public UnityEngine.Object target;
        /// <summary>A one-click repair (one Undo step), or null. Its button reads Fix; fixTip says what it does.</summary>
        public Action fix;
        public string fixTip;

        public string TargetName => target == null ? "(no object)" : target is Component c ? MapCheck.PathOf(c.transform) : target is GameObject g ? MapCheck.PathOf(g.transform) : target.name;
        public override string ToString() => $"{severity} [{check}] {TargetName}: {message}";
    }

    public static class MapCheck
    {
        public const string HbsValidate = "hbs-validate";
        public const string ExportPrecondition = "export-precondition";
        public const string ObstructionNoRenderer = "obstruction-no-renderer";
        public const string SpawnOutsidePlayArea = "spawn-outside-play-area";
        public const string SpawnOnBlockedCell = "spawn-terrain-type";
        public const string PlayAreaInEdgeBand = "play-area-edge-band";
        public const string LanceHexes = "lance-hexes";
        public const string Masks = "masks";
        public const string TreesOutsideForest = "trees-outside-forest";
        public const string MapId = "map-id";
        public const string DisplayName = "display-name";
        public const string CameraStartPlace = "camera-start";

        const string HbsOutsideMap = "is outside of the map boundaries.";
        const string HbsOutsideEncounter = "is outside of the encounter bounds.";

        /// <summary>How many encounter components the last Run put back after HBS's Validate changed them (evidence; 0 on a clean map).</summary>
        public static int LastRestoredCount { get; private set; }

        public static List<MapCheckEntry> Run()
        {
            LastRestoredCount = 0;
            var entries = new List<MapCheckEntry>();
            var problems = MapPreconditions.Check(out var scene);
            foreach (var p in problems)
                entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = ExportPrecondition, target = p.target, detail = p.message, message = PreconditionSentence(p, scene) });

            CheckMapId(entries);
            CheckDisplayName(scene, entries);
            bool masksOk = scene.splat != null && CheckMasks(scene, entries);
            if (masksOk)
                scene.splat.LoadSplatData(); // HBS's own reader; fills a non-serialized cache that the terrain-type lookups read.

            // HBS's Validate dereferences the terrain's biome; the layer checks need the EncounterLayerParent.
            if (scene.terrain != null && scene.generator != null && scene.generator.biome != null && scene.parent != null)
                CheckLayers(scene, masksOk, entries);
            // Links a copied contract layer had into its source map, cleared by Add Contract Layer (ContractLayers.cs).
            if (scene.parent != null)
            {
                ContractLayers.AddCheckEntries(scene.parent, entries);
                // Ambush refs, dialogue camera focus, and chunks the kit's contract does not list (EncounterScripting.cs).
                EncounterScripting.AddCheckEntries(scene.parent, entries);
            }

            CheckObstructions(entries);
            if (scene.terrain != null)
                Roads.AddCheckEntries(scene.terrain, entries);
            if (masksOk)
                CheckTrees(scene, entries);
            // A TerrainData or mask another scene uses too (a Save As made before the kit gave copies their own; MapOwnAssets.cs).
            if (scene.terrain != null)
                MapOwnAssets.AddCheckEntries(scene.terrain.gameObject.scene, entries);
            return entries;
        }

        static string PreconditionSentence(MapProblem p, MapScene scene)
        {
            switch (p.message)
            {
                case MapPreconditions.NoTerrain: return "The open scene has no active terrain. Open a map scene, or make one with UCU Map Kit > New Map from Template.";
                case MapPreconditions.NoGenerator: return $"Terrain {scene.terrain.name} needs a TerrainGenerator component with its biome set. Add it, then pick the biome. The layer checks are skipped until then.";
                case MapPreconditions.NoSplat: return $"Terrain {scene.terrain.name} has no SplatMapInfo, so the map has no terrain types. Add SplatMapInfo and assign its masks.";
                case var m when m.StartsWith(MapPreconditions.DuplicateLayer): return m;
                default:
                    return scene.exporter == null
                        ? "The map has no MapMetaDataExporter. Add one object with EncounterLayerParent, MapMetaDataExporter and InclineMeshBuilder."
                        : $"{scene.exporter.name} is missing {string.Join(" and ", new[] { scene.exporter.GetComponent<EncounterLayerParent>() == null ? "EncounterLayerParent" : null, scene.exporter.GetComponent<InclineMeshBuilder>() == null ? "InclineMeshBuilder" : null }.Where(n => n != null))}. Add it to the same object.";
            }
        }

        // The map id is the scene name (MapMetaDataExporter.GetMapName); it names the bundle (lower case) and every data file.
        static void CheckMapId(List<MapCheckEntry> entries)
        {
            var active = SceneManager.GetActiveScene();
            if (string.IsNullOrEmpty(active.path))
                return; // An unsaved scene has no id yet; saving before Build is a later step's check.
            var id = MapMetaDataExporter.GetMapName();
            var asset = AssetDatabase.LoadAssetAtPath<SceneAsset>(active.path);
            if (id.Contains(" "))
                entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = MapId, target = asset,
                    message = $"Map id \"{id}\" has a space. Rename the scene without spaces: the id names the map's bundle and data files.",
                    detail = "MapMetaDataExporter.GetMapName() = scene name; the layer data names replace spaces with underscores." });
            if (id.IndexOf("template", StringComparison.OrdinalIgnoreCase) >= 0)
                entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = MapId, target = asset,
                    message = $"Map id \"{id}\" contains \"template\". The game skips every file whose id contains it, so the map would not load. Rename the scene.",
                    detail = "VersionManifestEntry: IsTemplate = id.ToLowerInvariant().Contains(\"template\"); LoadRequest skips template entries." });
            var others = AssetDatabase.FindAssets("t:Scene").Select(AssetDatabase.GUIDToAssetPath)
                .Where(p => p != active.path && string.Equals(Path.GetFileNameWithoutExtension(p), id, StringComparison.OrdinalIgnoreCase)).ToArray();
            if (others.Length > 0)
                entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = MapId, target = asset,
                    message = $"Map id \"{id}\" is already used by {string.Join(", ", others)}. Rename one of the scenes: two maps with one id (in any case) share a bundle name.",
                    detail = string.Join("\n", others) });
        }

        // The map list shows MapMetaDataExporter.mapName; Build Mod falls back to the scene name when it is empty. Either way the
        // player would read the raw id ("mapKit_kt" shows as MAPKIT_KT), so a missing name is worth a warning.
        static void CheckDisplayName(MapScene scene, List<MapCheckEntry> entries)
        {
            var exporter = scene.exporter;
            if (exporter == null) return;
            var id = MapMetaDataExporter.GetMapName();
            if (!string.IsNullOrWhiteSpace(exporter.mapName) && !string.Equals(exporter.mapName.Trim(), id, StringComparison.OrdinalIgnoreCase))
                return;
            entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = DisplayName, target = exporter,
                message = $"The map has no display name, so the map list shows its id \"{id}\". Type a readable name in Display name on the Map tab.",
                detail = $"MapMetaDataExporter.mapName is \"{exporter.mapName}\" (empty, or the same as the scene name); the lobby's map list reads it." });
        }

        // The seven masks SplatMapInfo.LoadSplatData reads. They must exist, be readable and be one size, or it fails.
        static bool CheckMasks(MapScene scene, List<MapCheckEntry> entries)
        {
            var s = scene.splat;
            var masks = new (string field, Texture2D tex)[] { ("Water", s.waterMask), ("Deep water", s.deepWaterMask), ("Forest", s.forestMask),
                ("Rough", s.roughMask), ("Custom", s.customMask), ("Road", s.roadMask), ("Impassable", s.impassableMask) };
            const string skipped = " The spawn-point terrain-type and tree checks are skipped until it is fixed.";
            int before = entries.Count;
            foreach (var (field, tex) in masks)
            {
                if (tex == null)
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = Masks, target = s,
                        message = $"The {field} mask is missing on {s.name}'s SplatMapInfo. Assign a mask texture (black means none of that type)." + skipped,
                        detail = $"SplatMapInfo.{field} mask is null; SplatMapInfo.LoadSplatData reads all seven masks." });
                else if (!tex.isReadable)
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = Masks, target = tex,
                        message = $"The {field} mask {tex.name} is not readable. Turn on Read/Write in its import settings." + skipped,
                        detail = "Texture2D.isReadable is false; SplatMapInfo.LoadSplatData calls GetPixels on it." });
                else if (s.waterMask != null && (tex.width != s.waterMask.width || tex.height != s.waterMask.height))
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = Masks, target = tex,
                        message = $"The {field} mask {tex.name} is {tex.width}x{tex.height}, but the Water mask is {s.waterMask.width}x{s.waterMask.height}. Make all seven masks one size." + skipped,
                        detail = "SplatMapInfo.LoadSplatData: \"Splat maps are different dimensions! They need to be the same\"" });
            }
            return entries.Count == before;
        }

        static void CheckLayers(MapScene scene, bool masksOk, List<MapCheckEntry> entries)
        {
            var parent = scene.parent;
            // HBS's list is a cache it does not serialize: an Undo that removes a layer (Add Contract Layer) leaves it stale.
            parent.UpdateEncounterLayerList();
            var layers = parent.EncounterLayerList;
            int selected = parent.SelectedEncounterLayerIndex;
            var active = layers.Select(l => l.gameObject.activeSelf).ToArray();
            // Validate writes to the components it checks; keep their serialized state to put back (EditorJsonUtility).
            var watched = UnityEngine.Object.FindObjectsByType<MonoBehaviour>(FindObjectsInactive.Include)
                .Where(m => m is EncounterObjectGameLogic || m is EncounterLayerParent || m is MapMetaDataExporter)
                .Select(m => (m, json: EditorJsonUtility.ToJson(m))).ToList();
            var grid = new HexGrid(null);
            var hbsSeen = new Dictionary<(UnityEngine.Object, string), (MapCheckEntry entry, List<string> layers, string name)>();
            try
            {
                for (int i = 0; i < layers.Length; i++)
                {
                    // As MapExport does: an unselected layer is inactive, and Validate's objects look up their layer through it.
                    var layer = parent.SelectEncounterLayerByIndex(i);
                    List<EncounterObjectValidationEntry> hbs;
                    try { hbs = layer.Validate(new Dictionary<string, EncounterObjectGameLogic>()); }
                    catch (Exception e)
                    {
                        entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = HbsValidate, target = layer,
                            message = $"HBS's check of layer {layer.name} stopped with an error ({e.GetType().Name}), so Export would fail on it too. Hover for the error; the object it names needs fixing.",
                            detail = e.ToString() });
                        continue;
                    }
                    var claimed = new HashSet<EncounterObjectValidationEntry>();
                    var kit = new List<MapCheckEntry>();
                    CheckSpawns(scene, layer, masksOk, grid, hbs, claimed, kit);
                    CheckPlayArea(scene, layer, kit);
                    CheckCameraStart(layer, kit);
                    AddHbs(layer, hbs, claimed, hbsSeen, entries);
                    entries.AddRange(kit);
                }
            }
            finally
            {
                parent.SelectEncounterLayerByIndex(selected);
                for (int i = 0; i < layers.Length; i++)
                    if (layers[i].gameObject.activeSelf != active[i]) layers[i].gameObject.SetActive(active[i]);
                foreach (var (m, json) in watched)
                    if (m != null && EditorJsonUtility.ToJson(m) != json) { EditorJsonUtility.FromJsonOverwrite(json, m); LastRestoredCount++; }
            }
            // An object outside the layers (an obstruction, say) is checked by every layer: one entry naming them all.
            foreach (var (entry, names, name) in hbsSeen.Values.Where(v => v.layers.Count > 1))
                entry.message = $"{name} fails HBS's check in layers {string.Join(", ", names)}, so Export skips them. Hover for HBS's message, then fix what it names.";
        }

        // HBS's entries for one layer, one per fault: the three lines HBS writes for an object in the map edge band are one
        // fault, and an entry a kit check already reports with a plain sentence (claimed) goes into that entry's tooltip.
        static void AddHbs(EncounterLayerData layer, List<EncounterObjectValidationEntry> hbs, HashSet<EncounterObjectValidationEntry> claimed,
            Dictionary<(UnityEngine.Object, string), (MapCheckEntry entry, List<string> layers, string name)> seen, List<MapCheckEntry> entries)
        {
            for (int i = 0; i < hbs.Count; i++)
            {
                var e = hbs[i];
                if (claimed.Contains(e)) continue;
                var name = e.encounterObject != null ? e.encounterObject.name : layer.name;
                if (e.validationError != null && e.validationError.EndsWith(HbsOutsideMap, StringComparison.Ordinal))
                {
                    var lines = new List<string> { e.validationError };
                    while (i + 1 < hbs.Count && hbs[i + 1].encounterObject == e.encounterObject && lines.Count < 3 && !claimed.Contains(hbs[i + 1]))
                        lines.Add(hbs[++i].validationError);
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = HbsValidate, target = e.encounterObject,
                        message = $"{name} in layer {layer.name} is in the {SplatMapInfo.mapBoundaryWidth} m map edge band. Move it at least {SplatMapInfo.mapBoundaryWidth} m in from the map edge.",
                        detail = string.Join("\n", lines) });
                    continue;
                }
                var target = e.encounterObject != null ? (UnityEngine.Object)e.encounterObject : layer;
                var key = (target, e.validationError);
                if (seen.TryGetValue(key, out var earlier)) { earlier.layers.Add(layer.name); continue; }
                var entry = new MapCheckEntry { severity = MapCheckSeverity.Error, check = HbsValidate, target = target,
                    message = $"{name} in layer {layer.name} fails HBS's layer check, so Export skips this layer. Hover for HBS's message, then fix what it names.",
                    detail = e.validationError };
                seen[key] = (entry, new List<string> { layer.name }, name);
                entries.Add(entry);
            }
        }

        static void CheckSpawns(MapScene scene, EncounterLayerData layer, bool masksOk, HexGrid grid, List<EncounterObjectValidationEntry> hbs,
            HashSet<EncounterObjectValidationEntry> claimed, List<MapCheckEntry> kit)
        {
            layer.CalculateEncounterBoundary();
            foreach (var point in layer.GetComponentsInChildren<UnitSpawnPointGameLogic>(true))
            {
                var lance = point.GetComponentInParent<LanceSpawnerGameLogic>(true);
                var who = lance != null ? $"{point.name} of {lance.name}" : point.name;
                var pos = point.transform.position;
                if (!layer.IsInEncounterBounds(pos))
                {
                    var theirs = hbs.Where(h => h.encounterObject == point && h.validationError != null && h.validationError.Contains(HbsOutsideEncounter)).ToList();
                    claimed.UnionWith(theirs);
                    kit.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = SpawnOutsidePlayArea, target = point,
                        message = $"{who} (layer {layer.name}) is outside the play area. Move it inside the encounter boundary.",
                        detail = theirs.Count > 0 ? string.Join("\n", theirs.Select(h => h.validationError)) : $"EncounterLayerData.IsInEncounterBounds({pos.x:0.#}, {pos.z:0.#}) is false." });
                }
                if (masksOk && TryCellFlags(scene, pos, out var flags))
                {
                    if (SplatMapInfo.IsImpassable(flags) || SplatMapInfo.IsDeepWater(flags))
                        kit.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = SpawnOnBlockedCell, target = point,
                            message = $"{who} (layer {layer.name}) is on {(SplatMapInfo.IsImpassable(flags) ? "impassable ground" : "deep water")}. Move it onto open ground, or paint the ground there as something else.",
                            detail = $"Exporter cell flags at ({pos.x:0.#}, {pos.z:0.#}): {flags}" });
                    else if (SplatMapInfo.IsWater(flags))
                        kit.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = SpawnOnBlockedCell, target = point,
                            message = $"{who} (layer {layer.name}) is in water. Move it onto land, or paint the ground there as something else, unless units should start in water.",
                            detail = $"Exporter cell flags at ({pos.x:0.#}, {pos.z:0.#}): {flags}" });
                }
            }

            foreach (var lance in layer.GetComponentsInChildren<LanceSpawnerGameLogic>(true))
            {
                var points = lance.unitSpawnPointGameLogicList;
                var hexes = points.Select(p => grid.GetClosestHexPoint3OnGrid(p.transform.position)).Select(h => (h.q, h.r)).Distinct().Count();
                if (points.Length != 4 || hexes != 4)
                    kit.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = LanceHexes, target = lance,
                        message = $"{lance.name} (layer {layer.name}) has {points.Length} spawn points on {hexes} different hexes. A lance needs four points, each on its own hex: move them apart.",
                        detail = string.Join("\n", points.Select(p => { var h = grid.GetClosestHexPoint3OnGrid(p.transform.position); return $"{p.name}: hex ({h.q}, {h.r})"; })) });
            }
        }

        // Retail's CameraStart is a child at local zero under its player lance's first spawn point (TemplateGenerator.AddCameraStart):
        // CameraControl.InitialCameraFacing frames the lance from its own height. A CameraStart under another object, or offset, opens
        // the camera somewhere else (the template once put it at the world origin, which was under the ground on a raised map).
        // Its lance is the PlayerLanceSpawnerGameLogic above it; one that sits outside any lance belongs to the layer's only player
        // lance, and with two player lances (ArenaSkirmish) a loose one is not guessed at.
        static void CheckCameraStart(EncounterLayerData layer, List<MapCheckEntry> kit)
        {
            var lances = layer.GetComponentsInChildren<PlayerLanceSpawnerGameLogic>(true);
            foreach (var cam in layer.GetComponentsInChildren<CameraStart>(true))
            {
                var lance = cam.GetComponentInParent<PlayerLanceSpawnerGameLogic>(true) ?? (lances.Length == 1 ? lances[0] : null);
                var points = lance != null ? lance.unitSpawnPointGameLogicList : null;
                if (points == null || points.Length == 0 || points[0] == null) continue;
                var first = points[0].transform;
                var t = cam.transform;
                if (t.parent == first && t.localPosition.sqrMagnitude < 1e-8f) continue;
                kit.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = CameraStartPlace, target = cam,
                    message = $"CameraStart (layer {layer.name}) is not at local zero under {first.name} of {lance.name}. Retail puts it there, so the start camera frames the lance from its own height. Use Fix.",
                    detail = $"CameraStart parent {(t.parent != null ? PathOf(t.parent) : "(none)")}, local position {t.localPosition}; expected parent {PathOf(first)}, local position (0, 0, 0).",
                    fixTip = $"Move CameraStart under {first.name} of {lance.name} at local zero, rotation and scale reset (one Undo step).",
                    fix = () =>
                    {
                        Undo.SetTransformParent(t, first, "Map Kit: CameraStart under spawn point 1");
                        Undo.RecordObject(t, "Map Kit: CameraStart under spawn point 1");
                        t.localPosition = Vector3.zero; t.localRotation = Quaternion.identity; t.localScale = Vector3.one;
                    } });
            }
        }

        static void CheckPlayArea(MapScene scene, EncounterLayerData layer, List<MapCheckEntry> kit)
        {
            var t = scene.terrain.transform.position;
            var size = scene.terrain.terrainData.size;
            float band = SplatMapInfo.mapBoundaryWidth;
            var inner = Rect.MinMaxRect(t.x + band, t.z + band, t.x + size.x - band, t.z + size.z - band);
            foreach (var rect in layer.GetComponentsInChildren<EncounterBoundaryRectGameLogic>(true))
            {
                var r = rect.GetRect();
                if (r.xMin < inner.xMin || r.yMin < inner.yMin || r.xMax > inner.xMax || r.yMax > inner.yMax)
                    kit.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = PlayAreaInEdgeBand, target = rect,
                        message = $"Play area {rect.name} (layer {layer.name}) reaches into the {band:0} m map edge band, where units cannot go. Make it smaller or move it inward.",
                        detail = $"Play area x {r.xMin:0}..{r.xMax:0}, z {r.yMin:0}..{r.yMax:0}; outside the band: x {inner.xMin:0}..{inner.xMax:0}, z {inner.yMin:0}..{inner.yMax:0}." });
            }
        }

        // The exporter's terrain-type flags for the 4 m cell under pos: the same MapMetaDataExporter.CalculateAverageTerrainValues
        // call GenerateTerrainData makes for that cell.
        static bool TryCellFlags(MapScene scene, Vector3 pos, out TerrainMaskFlags flags)
        {
            flags = TerrainMaskFlags.None;
            var terrain = scene.terrain;
            var local = pos - terrain.transform.position;
            var size = terrain.terrainData.size;
            if (local.x < 0f || local.z < 0f || local.x >= size.x || local.z >= size.z)
                return false;
            int cell = MapMetaDataExporter.cellSize;
            // Cell i covers local i*cell - cell/2 .. i*cell + cell/2 (MapMetaData.cs:162-172 adds half a cell before it divides).
            int cx = Mathf.FloorToInt((local.x + cell / 2f) / cell) * cell, cz = Mathf.FloorToInt((local.z + cell / 2f) / cell) * cell;
            float half = cell / 2f;
            flags = MapMetaDataExporter.CalculateAverageTerrainValues(terrain, cx - half, cz - half, cell, scene.splat).terrainMaskFlags;
            return true;
        }

        static void CheckObstructions(List<MapCheckEntry> entries)
        {
            // MapMetaDataExporter.MarkCellsForRaycasting: an active ObstructionGameLogic with no Renderer below it (roads aside)
            // cannot mark cells, so nothing it covers blocks movement or line of sight.
            foreach (var o in UnityEngine.Object.FindObjectsByType<ObstructionGameLogic>(FindObjectsInactive.Exclude).OrderBy(o => PathOf(o.transform), StringComparer.Ordinal))
            {
                if (o.GetComponentsInChildren<Renderer>().Length > 0 || o.GetComponent<RoadManager>() != null)
                    continue;
                entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = ObstructionNoRenderer, target = o,
                    message = $"{o.name} is marked as an obstruction (ObstructionGameLogic) but has no renderer, so the exporter cannot place it and it blocks nothing. Give it a mesh, or remove its ObstructionGameLogic.",
                    detail = $"ECK DIDN'T THINK THIS COULD HAPPEN - An obstruction without a renderer was found. Obstruction: [{o.name}] Guid: [{o.encounterObjectGuid}]" });
            }
        }

        static void CheckTrees(MapScene scene, List<MapCheckEntry> entries)
        {
            var terrain = scene.terrain;
            var trees = terrain.terrainData.treeInstances;
            if (trees.Length == 0) return;
            var origin = terrain.transform.position;
            var size = terrain.terrainData.size;
            int outside = 0;
            Vector3 first = default;
            foreach (var t in trees)
            {
                var world = origin + Vector3.Scale(t.position, size);
                if (!SplatMapInfo.IsForest(scene.splat.GetTerrainDataAtCoords(world)))
                {
                    if (outside++ == 0) first = world;
                }
            }
            if (outside > 0)
                entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = TreesOutsideForest, target = terrain.gameObject,
                    message = $"{outside} of {trees.Length} trees on {terrain.name} stand outside forest. The game gives cover only where the Forest mask is painted: paint forest under them, or remove them.",
                    detail = $"First at ({first.x:0}, {first.z:0}). Trees carry no gameplay; SplatMapInfo's forest mask does.",
                    fix = () => TerrainTypePaint.FixTreesOutsideForest(terrain, scene.splat),
                    fixTip = $"Run Forest from trees: paint forest within {TerrainTypePaint.DefaultTreeRadius:0} m of every tree on {terrain.name} (one Undo step). Its own settings and preview are in the Paint Terrain Type tool." });
        }

        public static string PathOf(Transform t)
        {
            var parts = new List<string>();
            for (; t != null; t = t.parent) parts.Add(t.name);
            parts.Reverse();
            return string.Join("/", parts);
        }
    }
}
