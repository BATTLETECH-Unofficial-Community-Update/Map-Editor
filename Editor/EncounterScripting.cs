// UCU Map Kit: encounter scripting (map-kit X6; spec .hermes/reports/map-kit-x6-probe-20261123/final.md). Two supported types:
// - Add Ambush: copies a wired retail ambush (AmbushChunkGameLogic with its trigger region and points and its lance with spawn
//   points; only the 15 DestroyBase layers carry one) from an extracted map into the active encounter layer. U9's Add Contract
//   Layer steps are reused (ContractLayers): links into the source map are cleared and listed in Map Check, and every *Ref is
//   pointed at the copies with HBS's UpdateEncounterObjectGameObject. Unlike a layer copy, every encounter object of the
//   ambush takes a new GUID (HBS's GenerateNewGuid): a modder's ambush is not a retail contract's, and the kit writes its own
//   contract entries for it (ContractWriter). The region lands where the modder asks; the lance and its points keep their
//   retail offsets from it where the play area holds them, else are drawn in toward it (FitLanceInPlayArea); all snap to hex
//   and ground. One Undo step.
// - Add Dialogue: a DialogueGameLogic with lines (speaker, text) played at mission start, success or failure (HBS's fixed
//   GUIDs; an existing one is filled), or by an objective's success or failure (a new GUID, set on the objective). One Undo
//   step. Its lines go into the exported contract (ContractWriter); region-triggered chains are deferred (spec § 3).
// Map Check adds: an ambush with an empty or foreign ref, a dialogue line whose camera focus names nothing in its layer, and a
// ControlledByContract chunk the contract Export writes has no entry for.
using System;
using System.Collections.Generic;
using System.Linq;
using BattleTech;
using BattleTech.Designed;
using BattleTech.Framework;
using HBS.Collections;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    public enum DialoguePlay { MissionStart, MissionSuccess, MissionFailure, ObjectiveSuccess, ObjectiveFailure, None }

    public struct DialogueLine
    {
        public string speaker, words;
        public DialogueLine(string speaker, string words) { this.speaker = speaker; this.words = words; }
    }

    public class AmbushAddResult
    {
        public AmbushChunkGameLogic chunk;
        public RegionGameLogic region;
        public LanceSpawnerGameLogic lance;
        public string sourceMap, sourceChunkGuid;
        public Dictionary<string, string> newGuids = new Dictionary<string, string>();
        public int strayGuidStrings, snapped;
        public float regionRadiusSource, regionRadius;
        /// <summary>1 when the lance kept the source's offsets from the region; less when it was drawn in to fit the play area.</summary>
        public float lanceScale = 1f;
        public ContractLayerAddResult copy = new ContractLayerAddResult();
    }

    public static class EncounterScripting
    {
        public const string AmbushRefs = "ambush-refs";
        public const string ChunkNoEntry = "chunk-no-contract-entry";
        public const string CameraFocus = "dialogue-camera-focus";
        public const string AmbushTriggerTags = "ambush-trigger-tags";
        public const string AmbushCoversSpawn = "ambush-covers-spawn";
        public const string DefaultSpeaker = "castDef_DariusDefault";
        const string AmbushSourceType = "DestroyBase";

        // ---- Menu ----

        [MenuItem("UCU Map Kit/Add Ambush")]
        static void AddAmbushMenu() => AddAmbush(MenuPoint());

        [MenuItem("UCU Map Kit/Add Dialogue/Mission Start")] static void DlgStart() => AddDialogueMenu(DialoguePlay.MissionStart);
        [MenuItem("UCU Map Kit/Add Dialogue/Mission Success")] static void DlgSuccess() => AddDialogueMenu(DialoguePlay.MissionSuccess);
        [MenuItem("UCU Map Kit/Add Dialogue/Mission Failure")] static void DlgFailure() => AddDialogueMenu(DialoguePlay.MissionFailure);
        [MenuItem("UCU Map Kit/Add Dialogue/Selected Objective Succeeds")] static void DlgObjOk() => AddDialogueMenu(DialoguePlay.ObjectiveSuccess);
        [MenuItem("UCU Map Kit/Add Dialogue/Selected Objective Fails")] static void DlgObjBad() => AddDialogueMenu(DialoguePlay.ObjectiveFailure);

        static void AddDialogueMenu(DialoguePlay play)
        {
            var objective = Selection.activeGameObject != null ? Selection.activeGameObject.GetComponent<ObjectiveGameLogic>() : null;
            AddDialogue(play, new[] { new DialogueLine(DefaultSpeaker, "") }, objective);
        }

        // The Scene view's pivot, else the active layer's play area centre.
        static Vector3 MenuPoint()
        {
            var view = SceneView.lastActiveSceneView;
            if (view != null) return view.pivot;
            var rect = EncounterEdit.ActiveLayer(EncounterEdit.Parent())?.GetComponentInChildren<EncounterBoundaryRectGameLogic>(true);
            return rect != null ? rect.transform.position : Vector3.zero;
        }

        static EncounterLayerData RequireLayer(out Scene target)
        {
            target = SceneManager.GetActiveScene();
            if (string.IsNullOrEmpty(target.path))
                throw new InvalidOperationException("Save the open map first: the kit records what it adds in files beside the scene.");
            var scene = MapPreconditions.Require(forExport: false);
            return EncounterEdit.ActiveLayer(scene.parent) ?? throw new InvalidOperationException("No encounter layer is active. Select one on the encounter layer parent.");
        }

        // ---- Add Ambush ----

        /// <summary>Copies a wired retail ambush into the active layer with new GUIDs, its region centred on <paramref name="regionAt"/>.</summary>
        public static AmbushAddResult AddAmbush(Vector3 regionAt)
        {
            var layer = RequireLayer(out var target);
            var sources = ContractLayers.Index().Where(s => s.typeName == AmbushSourceType && s.scenePath != target.path).OrderBy(s => s.map, StringComparer.Ordinal).ToList();
            if (sources.Count == 0)
                throw new InvalidOperationException("No extracted retail map has a DestroyBase layer, the only retail layers with a working ambush. Extract one first (UCU Map Kit > Extract Retail Maps).");
            var res = new AmbushAddResult();
            res.copy.layer = layer;
            const string label = "Map Kit: add ambush";
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName(label);
            int group = Undo.GetCurrentGroup();

            GameObject copy = null;
            Scene source = default;
            try
            {
                foreach (var src in sources)
                {
                    source = ContractLayers.OpenSource(src.scenePath);
                    var srcLayer = source.GetRootGameObjects().SelectMany(g => g.GetComponentsInChildren<EncounterLayerData>(true)).FirstOrDefault(l => l.encounterObjectGuid == src.layerGuid);
                    var original = srcLayer == null ? null : srcLayer.GetComponentsInChildren<AmbushChunkGameLogic>(true).FirstOrDefault(a =>
                        a.ambushTriggerRegion.encounterObject != null && a.ambushTriggerRegion.encounterObject.transform.IsChildOf(a.transform) &&
                        a.ambushingSpawnGroup.encounterObject != null && a.ambushingSpawnGroup.encounterObject.transform.IsChildOf(a.transform));
                    if (original == null)
                    {
                        ContractLayers.CloseSource(source);
                        source = default;
                        continue;
                    }
                    res.sourceMap = src.map;
                    res.sourceChunkGuid = original.encounterObjectGuid;
                    SceneManager.SetActiveScene(target);
                    copy = UnityEngine.Object.Instantiate(original.gameObject);
                    copy.name = original.name;
                    var inChunk = new HashSet<string>(original.GetComponentsInChildren<EncounterObjectGameLogic>(true).Select(o => o.encounterObjectGuid).Where(g => !string.IsNullOrEmpty(g)));
                    var outside = new HashSet<string>(source.GetRootGameObjects().SelectMany(g => g.GetComponentsInChildren<EncounterObjectGameLogic>(true))
                        .Select(o => o.encounterObjectGuid).Where(g => !string.IsNullOrEmpty(g)));
                    outside.ExceptWith(inChunk);
                    ContractLayers.ClearSourceLinks(copy, layer, src, source, outside, res.copy);
                    // New GUIDs; the copies' references still carry the old ones, so Repoint gets the copies by old GUID.
                    var byOld = new Dictionary<string, EncounterObjectGameLogic>();
                    foreach (var o in copy.GetComponentsInChildren<EncounterObjectGameLogic>(true))
                    {
                        var old = o.encounterObjectGuid;
                        o.GenerateNewGuid();
                        if (string.IsNullOrEmpty(old) || byOld.ContainsKey(old)) continue;
                        byOld[old] = o;
                        res.newGuids[old] = o.encounterObjectGuid;
                    }
                    ContractLayers.Repoint(copy, res.copy, byOld);
                    res.strayGuidStrings = RenameGuidStrings(copy, res.newGuids);
                    break;
                }
                if (copy == null)
                    throw new InvalidOperationException($"None of the {sources.Count} extracted DestroyBase layers has an ambush with its region and lance under it.");
            }
            catch
            {
                if (copy != null) UnityEngine.Object.DestroyImmediate(copy);
                throw;
            }
            finally
            {
                ContractLayers.CloseSource(source);
                SceneManager.SetActiveScene(target);
            }

            Undo.RegisterCreatedObjectUndo(copy, label);
            try
            {
                Undo.SetTransformParent(copy.transform, layer.transform, label);
                res.chunk = copy.GetComponent<AmbushChunkGameLogic>();
                res.region = res.chunk.ambushTriggerRegion.encounterObject;
                res.lance = res.chunk.ambushingSpawnGroup.encounterObject;
                var shift = regionAt - res.region.transform.position;
                shift.y = 0f;
                Undo.RecordObject(copy.transform, label);
                copy.transform.position += shift;
                res.lanceScale = FitLanceInPlayArea(layer, res.region.transform.position, res.lance, label);
                res.snapped = ContractLayers.Snap(copy.transform);
                RequireSeparateHexes(res.lance);
                res.regionRadiusSource = res.region.radius;
                KeepPlayerSpawnsOutside(layer, res.region, label);
                res.regionRadius = res.region.radius;
            }
            catch
            {
                Undo.RevertAllDownToGroup(group);
                throw;
            }
            Undo.CollapseUndoOperations(group);
            EditorSceneManager.MarkSceneDirty(target);
            if (res.copy.cleared.Count > 0)
            {
                foreach (var link in res.copy.cleared)
                {
                    link.layerGuid = layer.encounterObjectGuid;
                    // The copy's objects took new GUIDs after ClearSourceLinks recorded the old ones. A removed object (a building team
                    // assignment) or one with no GUID is listed on the chunk.
                    link.objectGuid = res.newGuids.TryGetValue(link.objectGuid, out var fresh) ? fresh : res.chunk.encounterObjectGuid;
                }
                ContractLayers.WriteLinks(target, layer, res.copy.cleared, keepLayer: true);
            }
            Selection.activeGameObject = copy;
            Debug.Log($"UCU Map Kit: added ambush {copy.name} to layer {layer.name} from {res.sourceMap}: {res.newGuids.Count} new GUIDs, {res.copy.refsRepointed} references on the copies, " +
                $"{res.copy.cleared.Count} source-map links cleared (Map Check lists them), {res.snapped} objects snapped, trigger region radius {res.regionRadius:0.#} m" +
                (res.regionRadius < res.regionRadiusSource ? $" (the source's {res.regionRadiusSource:0.#} m would cover the player lance's spawn)" : "") +
                (res.lanceScale < 1f ? $", lance drawn in to {res.lanceScale:P0} of the source's distance from the region to fit the play area" : "") + ". Its lance and units go into the contract Export writes.");
            return res;
        }

        // ---- Trigger region and player spawns ----

        /// <summary>The player lance spawners' spawn points and the spawners themselves: where the player's units appear.</summary>
        static List<Vector3> PlayerSpawnPositions(EncounterLayerData layer)
        {
            var list = new List<Vector3>();
            foreach (var s in layer.GetComponentsInChildren<PlayerLanceSpawnerGameLogic>(true))
            {
                list.Add(s.transform.position);
                list.AddRange(s.GetComponentsInChildren<UnitSpawnPointGameLogic>(true).Select(p => p.transform.position));
            }
            return list;
        }

        /// <summary>Whether the region holds this ground position. The exporter assigns a cell to a region by casting rays down at
        /// its collider (MapMetaDataExporter), so the collider decides; a region without one falls back to its points, then its
        /// radius.</summary>
        public static bool RegionCovers(RegionGameLogic region, Vector3 p)
        {
            var col = region.GetComponent<Collider>();
            if (col != null && col.enabled)
                return col.Raycast(new Ray(new Vector3(p.x, 10000f, p.z), Vector3.down), out _, 20000f);
            var pts = region.regionPointList.Select(r => r.transform.position).ToArray();
            if (pts.Length < 3)
                return Flat(p - region.transform.position).magnitude <= region.radius * Mathf.Abs(region.transform.lossyScale.x);
            bool inside = false;
            for (int i = 0, j = pts.Length - 1; i < pts.Length; j = i++)
                if ((pts[i].z > p.z) != (pts[j].z > p.z) && p.x < (pts[j].x - pts[i].x) * (p.z - pts[i].z) / (pts[j].z - pts[i].z) + pts[i].x)
                    inside = !inside;
            return inside;
        }

        static Vector3 Flat(Vector3 v) { v.y = 0f; return v; }

        // The encounter tags each unit of this spawner gets: the spawner's own plus its spawn point's.
        static IEnumerable<TagSet> UnitTags(LanceSpawnerGameLogic s)
        {
            var own = s.encounterTags ?? new TagSet();
            var points = s.GetComponentsInChildren<UnitSpawnPointGameLogic>(true);
            if (points.Length == 0) { yield return own; yield break; }
            foreach (var p in points)
            {
                var t = new TagSet(own);
                if (p.encounterTags != null) t.AddRange(p.encounterTags);
                yield return t;
            }
        }

        // A retail ambush keeps its source region, which can be wider than the distance from the modder's point to the player
        // lance; it then fires at the drop (KFIX6 F7b: 231.66 m from Interchange, 150 m from the player spawn). The region (its
        // collider and points with it) is scaled about its centre so every player spawn lies a hex outside it.
        static void KeepPlayerSpawnsOutside(EncounterLayerData layer, RegionGameLogic region, string label)
        {
            var spawns = PlayerSpawnPositions(layer);
            if (spawns.Count == 0) return;
            var c = region.transform.position;
            float extent = region.regionPointList.Select(p => Flat(p.transform.position - c).magnitude).DefaultIfEmpty(0f).Max();
            var mesh = region.GetComponent<MeshCollider>()?.sharedMesh;
            if (mesh != null) extent = Mathf.Max(extent, mesh.vertices.Select(v => Flat(region.transform.TransformPoint(v) - c).magnitude).DefaultIfEmpty(0f).Max());
            if (extent <= 0f) extent = region.radius;
            float nearest = spawns.Min(s => Flat(s - c).magnitude), room = nearest - EncounterEdit.HexWidth;
            if (extent <= room) return;
            if (room < EncounterEdit.HexWidth)
                throw new InvalidOperationException($"The ambush's trigger region would hold the player lance's spawn: the point is {nearest:0} m from it. " +
                    $"Point the Scene view at least {2f * EncounterEdit.HexWidth:0} m from the player lance and add it again.");
            float k = room / extent;
            var t = region.transform;
            Undo.RecordObject(t, label);
            Undo.RecordObject(region, label);
            t.localScale = new Vector3(t.localScale.x * k, t.localScale.y, t.localScale.z * k);
            region.radius *= k;
            foreach (var p in region.regionPointList) EncounterEdit.SnapPoint(p);
            Physics.SyncTransforms();
        }

        // A retail ambush keeps its lance far from its trigger region, inside retail's own play area: taiga's lance object is 661 m
        // from the region and its four points 380-520 m (map-kit KFIX7 P1). The copy moves with the region and keeps those offsets
        // where the open map's play area holds them. Where it does not (A1 D13: two points outside, Map Check errors, Build Mod
        // refused), the lance and its points are drawn in toward the region centre, all by one factor, the largest that puts each of
        // them a hex inside the layer's play area (HBS's EncounterLayerData.IsInEncounterBounds, which Map Check reads).
        static float FitLanceInPlayArea(EncounterLayerData layer, Vector3 centre, LanceSpawnerGameLogic lance, string label)
        {
            layer.CalculateEncounterBoundary();
            var h = EncounterEdit.HexWidth;
            bool Inside(Vector3 p) => new[] { Vector3.zero, new Vector3(h, 0f, 0f), new Vector3(-h, 0f, 0f), new Vector3(0f, 0f, h), new Vector3(0f, 0f, -h) }
                .All(d => layer.IsInEncounterBounds(p + d));
            var moved = new[] { lance.transform }.Concat(lance.GetComponentsInChildren<UnitSpawnPointGameLogic>(true).Select(p => p.transform)).ToArray();
            var offsets = moved.Select(t => Flat(t.position - centre)).ToArray();
            bool Fits(float k) => offsets.All(o => Inside(centre + o * k));
            if (Fits(1f)) return 1f;
            if (!Inside(centre))
                throw new InvalidOperationException($"The point is outside the play area of layer {layer.name}, so the ambush lance can't be placed inside it. Point the Scene view inside the play area and add it again.");
            float lo = 0f, hi = 1f;
            for (int i = 0; i < 24; i++) { float mid = (lo + hi) / 2f; if (Fits(mid)) lo = mid; else hi = mid; }
            var to = offsets.Select(o => centre + o * lo).ToArray();
            foreach (var t in moved) Undo.RecordObject(t, label);
            for (int i = 0; i < moved.Length; i++) moved[i].position = new Vector3(to[i].x, moved[i].position.y, to[i].z);
            return lo;
        }

        // Drawn in, the points can come too close to stand on hexes of their own (Map Check's lance-hexes error).
        static void RequireSeparateHexes(LanceSpawnerGameLogic lance)
        {
            var grid = new HexGrid(null);
            var points = lance.GetComponentsInChildren<UnitSpawnPointGameLogic>(true);
            int hexes = points.Select(p => grid.GetClosestHexPoint3OnGrid(p.transform.position)).Select(x => (x.q, x.r)).Distinct().Count();
            if (hexes < points.Length)
                throw new InvalidOperationException($"Drawn in to fit the play area, the ambush lance's {points.Length} spawn points would share hexes ({hexes} hexes). " +
                    "Point the Scene view nearer the middle of the play area and add it again.");
        }

        // Any other GUID string of the copy (not a *Ref, which Repoint set) that still names an old GUID takes the new one.
        static int RenameGuidStrings(GameObject copy, Dictionary<string, string> newGuids)
        {
            int n = 0;
            foreach (var c in copy.GetComponentsInChildren<MonoBehaviour>(true))
            {
                if (c == null) continue;
                var so = new SerializedObject(c);
                var p = so.GetIterator();
                bool changed = false;
                while (p.Next(true))
                    if (p.propertyType == SerializedPropertyType.String && p.propertyPath != "encounterObjectGuid" && newGuids.TryGetValue(p.stringValue, out var g))
                    {
                        p.stringValue = g;
                        changed = true;
                        n++;
                    }
                if (changed) so.ApplyModifiedPropertiesWithoutUndo();
            }
            return n;
        }

        // ---- Add Dialogue ----

        /// <summary>Adds (or, for a mission start/success/failure dialogue the layer has, fills) a dialogue with these lines in
        /// the active layer, and links it to the objective for an objective's success or failure. One Undo step.</summary>
        public static DialogueGameLogic AddDialogue(DialoguePlay play, IList<DialogueLine> lines, ObjectiveGameLogic objective = null, string name = null)
        {
            var layer = RequireLayer(out var target);
            bool byObjective = play == DialoguePlay.ObjectiveSuccess || play == DialoguePlay.ObjectiveFailure;
            if (byObjective && (objective == null || objective.GetComponentInParent<EncounterLayerData>(true) != layer))
                throw new InvalidOperationException("Select an objective of the active layer first: the dialogue plays when it succeeds or fails.");
            if (lines == null || lines.Count == 0) throw new InvalidOperationException("A dialogue needs at least one line.");
            string fixedGuid = play == DialoguePlay.MissionStart ? DialogueGameLogic.missionStartDialogueGuid
                : play == DialoguePlay.MissionSuccess ? DialogueGameLogic.missionSuccessDialogueGuid
                : play == DialoguePlay.MissionFailure ? DialogueGameLogic.missionFailedDialogueGuid : null;
            string label = $"Map Kit: add dialogue ({play})";
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName(label);
            int group = Undo.GetCurrentGroup();

            // A new object is built whole, then registered: Redo re-creates an object as it was registered, so one registered
            // before its components were added came back empty (measured, X6 discovery pass).
            var created = new List<GameObject>();
            var dlg = fixedGuid == null ? null : layer.GetComponentsInChildren<DialogueGameLogic>(true).FirstOrDefault(d => d.encounterObjectGuid == fixedGuid);
            if (dlg != null) Undo.RecordObject(dlg, label);
            else
            {
                var chunk = layer.GetComponentsInChildren<DialogueChunkGameLogic>(true).FirstOrDefault();
                if (chunk == null)
                {
                    var cgo = new GameObject("Chunk_Dialogue");
                    cgo.transform.SetParent(layer.transform, false);
                    chunk = cgo.AddComponent<DialogueChunkGameLogic>();
                    chunk.GenerateNewGuid();
                    chunk.startingStatus = EncounterObjectStatus.Active;
                    created.Add(cgo);
                }
                var go = new GameObject(name ?? (fixedGuid != null ? "Dialogue_" + play : $"Dialogue_{objective.name}_{(play == DialoguePlay.ObjectiveSuccess ? "Success" : play == DialoguePlay.ObjectiveFailure ? "Failure" : "New")}"));
                go.transform.SetParent(chunk.transform, false);
                dlg = go.AddComponent<DialogueGameLogic>();
                if (fixedGuid != null) dlg.encounterObjectGuid = fixedGuid;
                else dlg.GenerateNewGuid();
                if (created.Count == 0) created.Add(go);
            }
            dlg.dialogueSource = DialogueSourceType.FromEditor;
            if (dlg.conversationContent == null) dlg.conversationContent = new ConversationContent();
            dlg.conversationContent.contents = lines.Select(l => new DialogueContent { words = l.words ?? "", selectedCastDefId = l.speaker ?? "" }).ToArray();
            foreach (var made in created) Undo.RegisterCreatedObjectUndo(made, label);
            if (byObjective)
            {
                Undo.RecordObject(objective, label);
                var r = new DialogueRef();
                r.UpdateEncounterObjectGameObject(dlg);
                if (play == DialoguePlay.ObjectiveSuccess) objective.onSuccessDialogue = r;
                else objective.onFailureDialogue = r;
            }
            Undo.CollapseUndoOperations(group);
            EditorSceneManager.MarkSceneDirty(target);
            ContractWriter.RecordDialogue(target, dlg.encounterObjectGuid);
            Selection.activeGameObject = dlg.gameObject;
            return dlg;
        }

        // ---- Map Check ----

        public static void AddCheckEntries(EncounterLayerParent parent, List<MapCheckEntry> entries)
        {
            var map = SceneManager.GetActiveScene().name;
            foreach (var layer in EncounterEdit.Layers(parent))
            {
                var inLayer = new HashSet<string>(layer.GetComponentsInChildren<EncounterObjectGameLogic>(true).Select(o => o.encounterObjectGuid).Where(g => !string.IsNullOrEmpty(g)));
                foreach (var a in layer.GetComponentsInChildren<AmbushChunkGameLogic>(true))
                {
                    var bad = new List<string>();
                    string region = ContractWriter.RefGuid(a.ambushTriggerRegion), lance = ContractWriter.RefGuid(a.ambushingSpawnGroup);
                    if (region == "") bad.Add("no trigger region"); else if (!inLayer.Contains(region)) bad.Add($"a trigger region {region} that is not in the layer");
                    if (lance == "") bad.Add("no lance"); else if (!inLayer.Contains(lance)) bad.Add($"a lance {lance} that is not in the layer");
                    if (bad.Count > 0)
                    {
                        entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = AmbushRefs, target = a,
                            message = $"Ambush {a.name} (layer {layer.name}) has {string.Join(" and ", bad)}, so it spawns nothing even when a contract enables it. Pick both in its inspector, or remove it. (60 retail ambushes are empty like this.)",
                            detail = $"AmbushChunkGameLogic.ambushTriggerRegion = {region}; ambushingSpawnGroup = {lance}" });
                        continue;
                    }
                    // HBS springs it only for a unit whose encounter tags hold all of these (AmbushChunkGameLogic.OnAmbushRegionEntered);
                    // a unit gets its spawner's and its spawn point's tags (LanceSpawnerGameLogic.ContractInitialize).
                    var need = a.requiredTagsOnTriggeringUnit;
                    var spawners = layer.GetComponentsInChildren<PlayerLanceSpawnerGameLogic>(true);
                    if (need != null && need.Count > 0 && !spawners.Any(s => UnitTags(s).Any(t => t.ContainsAll(need))))
                        entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = AmbushTriggerTags, target = a,
                            message = $"Ambush {a.name} (layer {layer.name}) springs only for a unit tagged {string.Join(", ", need.ToArray())}, and no player lance spawner of the layer gives its units that tag, so it never spawns. " +
                                $"Add {string.Join(", ", need.ToArray())} to the Encounter tags of {(spawners.Length == 0 ? "the layer's player lance spawner" : spawners[0].name)} (every retail player lance spawner carries {TemplateGenerator.PlayerUnitTag}).",
                            detail = $"requiredTagsOnTriggeringUnit = [{string.Join(", ", need.ToArray())}]; player spawners: " +
                                string.Join("; ", spawners.Select(s => $"{s.name} [{string.Join(", ", (s.encounterTags?.ToArray() ?? new string[0]))}]")) });
                    var regionObj = a.ambushTriggerRegion.encounterObject;
                    if (regionObj != null)
                    {
                        Physics.SyncTransforms();  // the kit project keeps autoSyncTransforms off; the region's collider decides
                        var covered = PlayerSpawnPositions(layer).Where(p => RegionCovers(regionObj, p)).ToList();
                        if (covered.Count > 0)
                            entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = AmbushCoversSpawn, target = regionObj,
                                message = $"The trigger region {regionObj.name} of ambush {a.name} (layer {layer.name}) holds {covered.Count} of the player lance's spawn positions, so the ambush springs at the drop. Move the region away from the player lance.",
                                detail = $"covered: {string.Join("; ", covered.Select(p => $"({p.x:0.#}, {p.z:0.#})"))}; region centre ({regionObj.transform.position.x:0.#}, {regionObj.transform.position.z:0.#}) radius {regionObj.radius:0.#}" });
                    }
                }
                foreach (var d in layer.GetComponentsInChildren<DialogueGameLogic>(true))
                {
                    var lines = d.conversationContent?.contents ?? new DialogueContent[0];
                    for (int i = 0; i < lines.Length; i++)
                    {
                        var focus = lines[i] == null ? "" : ContractWriter.RefGuid(lines[i].cameraFocus);
                        if (focus != "" && !inLayer.Contains(focus))
                            entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = CameraFocus, target = d,
                                message = $"Line {i + 1} of dialogue {d.name} (layer {layer.name}) turns the camera to {focus}, which names nothing in the layer. Pick the object in the line's Camera on field, or clear it.",
                                detail = $"DialogueContent.cameraFocus = {focus} (contract field cameraFocusGuid)" });
                    }
                }
                ContractPlan plan;
                try { plan = ContractWriter.Plan(layer, map); }
                catch (Exception e)
                {
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Error, check = ChunkNoEntry, target = layer,
                        message = $"Layer {layer.name}'s contract cannot be written: {e.Message}", detail = e.ToString() });
                    continue;
                }
                if (plan == null) continue;
                var listed = new HashSet<string>(plan.contract.chunkList.Select(c => c.GUID));
                foreach (var c in layer.GetComponentsInChildren<EncounterChunkGameLogic>(true).Where(c => c.startingStatus == EncounterObjectStatus.ControlledByContract && !listed.Contains(c.encounterObjectGuid)))
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = ChunkNoEntry, target = c,
                        message = $"{c.name} (layer {layer.name}) starts Controlled By Contract, but the contract Export writes ({plan.FileName}) has no entry for it, so it finishes at encounter start. Set its region and lance (an ambush), set it Active, or remove it.",
                        detail = $"EncounterChunkGameLogic.startingStatus = ControlledByContract; {plan.FileName} chunkList: {string.Join(", ", listed)}; base {plan.baseFile}" });
            }
        }
    }
}
