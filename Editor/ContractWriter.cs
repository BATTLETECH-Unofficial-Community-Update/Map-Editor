// UCU Map Kit: the contract-JSON writer (map-kit X6; spec .hermes/reports/map-kit-x6-probe-20261123/final.md). HBS's own
// contract export is stripped (ContractOverride.ExportContractFromEditor has an empty body), so the kit builds HBS's object
// model (ContractOverride and its ChunkOverride, LanceOverride, DialogueOverride, ObjectiveOverride lists) and serializes it
// with HBS's own ContractOverride.ToJSON. The schema is retail's.
// - Base: the retail contract of the layer's contract type whose encounter GUIDs the layer lacks least, read from the retail
//   install's data/contracts/<type>/ with HBS's FromJSONFull; with no install, a minimal contract of that type built from the
//   layer (contract objectives, objectives, the player lance).
// - Added on top: a chunkList entry with enableChunkFromContract for each wired ambush (ControlledByContract, region and lance
//   set) the base does not list, and a lanceOverrideList entry for its lance with one unit override per spawn point, read
//   from the lance and point fields the modder sets; a dialogueList entry with the scene's lines for each dialogue the kit's
//   Add Dialogue made or filled (listed in <scene>_contract-dialogues.json beside the scene); and the objectiveList dialogue
//   GUIDs of every objective that plays one of those dialogues.
// - Bound to its map (KFIX5): a requirementList entry with Scope Map that requires the map's own tag (MapTag). HBS checks every
//   requirement of a contract against each candidate map, and a Map-scoped one against that map's MDD tag set
//   (SimGameState.DoesContractMeetRequirements and SetTagsAndStats, SimGameState.cs:3229-3262; called per map by
//   FillMapEncounterContractData -> CreatePotentialContract, :3121, :3189). Build Mod adds the tag to the map's row
//   (mapkit-map.json, which MapKitLoader writes with HBS's UpdateMap), and no retail map has it, so the contract is never
//   offered on a retail map of the same contract type, where its kit GUIDs do not exist.
// Retail scenes carry placeholder dialogue text ("(TODO - Finailize default success)") that retail contracts replace, so a
// dialogue is written only when the kit made or filled it, never because the scene has text. A layer with none of these
// gets no contract, and the game keeps using the retail ones.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using BattleTech.Designed;
using BattleTech.Framework;
using HBS.Collections;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    public class ContractPlan
    {
        public EncounterLayerData layer;
        public ContractOverride contract;
        public string id, baseId, baseFile;
        public int baseMissing;
        public List<string> added = new List<string>();
        public string FileName => id + ".json";
    }

    [Serializable]
    class ContractDialogueFile
    {
        public List<string> dialogues = new List<string>();
    }

    public static class ContractWriter
    {
        /// <summary>The ModTek manifest type for a contract file: HBS's BattleTechResourceType.ContractOverride, as retail-shaped
        /// mods list it (BTA's "BT Advanced Contracts" mod.json: {"Type": "ContractOverride", "Path": "contract"}).</summary>
        public const string ManifestType = "ContractOverride";

        /// <summary>The tag that binds a kit contract to its map: the map's id. Build Mod puts it in the map's tags, and each contract
        /// the map writes requires it with a Map-scoped requirement (see the file header).</summary>
        public static string MapTag(string map) => map;

        // ---- The record of the dialogues the kit made or filled ----

        public static string DialoguesFile(Scene scene) => string.IsNullOrEmpty(scene.path) ? null : $"{Path.GetDirectoryName(scene.path).Replace('\\', '/')}/{scene.name}_contract-dialogues.json";

        static string Full(string assetPath) => Path.Combine(Path.GetDirectoryName(Application.dataPath), assetPath);

        public static HashSet<string> RecordedDialogues(Scene scene)
        {
            var path = DialoguesFile(scene);
            if (path == null || !File.Exists(Full(path))) return new HashSet<string>();
            return new HashSet<string>((JsonUtility.FromJson<ContractDialogueFile>(File.ReadAllText(Full(path))) ?? new ContractDialogueFile()).dialogues);
        }

        /// <summary>Adds a dialogue GUID to the record. An entry whose dialogue is gone or has no lines (an undone Add) writes nothing.</summary>
        public static void RecordDialogue(Scene scene, string guid)
        {
            var path = DialoguesFile(scene) ?? throw new InvalidOperationException("Save the open map first: the kit records its dialogues in a file beside the scene.");
            var set = RecordedDialogues(scene);
            if (!set.Add(guid)) return;
            File.WriteAllText(Full(path), JsonUtility.ToJson(new ContractDialogueFile { dialogues = set.OrderBy(g => g, StringComparer.Ordinal).ToList() }, true));
            AssetDatabase.ImportAsset(path);
        }

        // ---- What the layer adds to a contract ----

        /// <summary>The GUID an HBS *Ref names: its object's, else its stored GUID. Read through the fields, because HBS's
        /// EncounterObjectGuid getter searches the scene and writes the reference (Map Check must not write).</summary>
        public static string RefGuid(object reference)
        {
            var t = reference?.GetType();
            while (t != null && !(t.IsGenericType && t.GetGenericTypeDefinition() == typeof(EncounterObjectRef<>))) t = t.BaseType;
            if (t == null) return "";
            var o = t.GetField("encounterObject").GetValue(reference) as EncounterObjectGameLogic;
            if (o != null) return o.encounterObjectGuid ?? "";
            return t.GetField("internalEncounterObjectGuid", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic).GetValue(reference) as string ?? "";
        }

        public static IEnumerable<AmbushChunkGameLogic> WiredAmbushes(EncounterLayerData layer) => layer.GetComponentsInChildren<AmbushChunkGameLogic>(true)
            .Where(a => a.startingStatus == EncounterObjectStatus.ControlledByContract && RefGuid(a.ambushTriggerRegion) != "" && RefGuid(a.ambushingSpawnGroup) != "");

        public static IEnumerable<DialogueGameLogic> KitDialogues(EncounterLayerData layer, HashSet<string> recorded) => layer.GetComponentsInChildren<DialogueGameLogic>(true)
            .Where(d => recorded.Contains(d.encounterObjectGuid) && d.conversationContent?.contents != null && d.conversationContent.contents.Any(c => c != null && !string.IsNullOrWhiteSpace(c.words)));

        /// <summary>The contract Export would write for the layer, or null when the layer adds nothing to one.</summary>
        public static ContractPlan Plan(EncounterLayerData layer, string map)
        {
            var recorded = RecordedDialogues(layer.gameObject.scene);
            var ambushes = WiredAmbushes(layer).ToList();
            var dialogues = KitDialogues(layer, recorded).ToList();
            if (ambushes.Count == 0 && dialogues.Count == 0) return null;
            var plan = Base(layer);
            var co = plan.contract;
            var have = new HashSet<string>(co.chunkList.Select(c => c.GUID));
            foreach (var a in ambushes.Where(a => !have.Contains(a.encounterObjectGuid)))
            {
                co.chunkList.Add(new ChunkOverride(a) { enableChunkFromContract = true });
                plan.added.Add($"chunkList {a.name} {a.encounterObjectGuid} enableChunkFromContract=true");
                var lance = a.ambushingSpawnGroup.encounterObject;
                if (lance != null && !Teams(co).Any(t => t.lanceOverrideList.Any(l => l.GUID == lance.encounterObjectGuid)))
                {
                    var team = Teams(co).FirstOrDefault(t => t.teamGuid == lance.teamDefinitionGuid)
                        ?? throw new InvalidOperationException($"{lance.name}: its team {lance.teamDefinitionGuid} is none of the contract's teams. Pick its team in the lance's inspector.");
                    team.lanceOverrideList.Add(Lance(lance));
                    plan.added.Add($"{team.teamName}.lanceOverrideList {lance.name} {lance.encounterObjectGuid} lanceDefId={lance.lanceDefId} units={lance.unitSpawnPointGameLogicList.Length}");
                }
            }
            var kit = new HashSet<string>(dialogues.Select(d => d.encounterObjectGuid));
            foreach (var d in dialogues)
            {
                var entry = co.dialogueList.FirstOrDefault(e => e.GUID == d.encounterObjectGuid);
                if (entry == null) co.dialogueList.Add(entry = new DialogueOverride(d) { name = d.name });
                entry.overrideDialogueBucketId = null;
                entry.dialogueContent = d.conversationContent.contents.Where(c => c != null).Select(c => new DialogueContentOverride(c)).ToList();
                plan.added.Add($"dialogueList {entry.name} {d.encounterObjectGuid} lines={entry.dialogueContent.Count}");
            }
            foreach (var o in layer.GetComponentsInChildren<ObjectiveGameLogic>(true))
            {
                string ok = RefGuid(o.onSuccessDialogue), bad = RefGuid(o.onFailureDialogue);
                if (!kit.Contains(ok) && !kit.Contains(bad)) continue;
                var entry = co.objectiveList.FirstOrDefault(e => e.GUID == o.encounterObjectGuid);
                if (entry == null) co.objectiveList.Add(entry = new ObjectiveOverride(o) { title = o.title, description = o.description, isPrimary = o.IsRequiredForContractObjective });
                // HBS's ObjectiveGameLogic.ApplyContractOverride sets both GUIDs from the entry, so both are written.
                entry.OnSuccessDialogueGUID = ok;
                entry.OnFailureDialogueGUID = bad;
                plan.added.Add($"objectiveList {o.name} {o.encounterObjectGuid} OnSuccessDialogueGUID={ok} OnFailureDialogueGUID={bad}");
            }
            co.requirementList.Add(new RequirementDef { Scope = EventScope.Map, RequirementTags = new TagSet(new[] { MapTag(map) }) });
            plan.added.Add($"requirementList Scope=Map RequirementTags=[{MapTag(map)}]");
            plan.id = $"{map}_{plan.baseId}";
            co.AssignID(plan.id);
            return plan;
        }

        /// <summary>Export: writes <map>_<contract>.json for each layer that adds something; problems go to the validation list.</summary>
        public static List<ContractPlan> WriteAll(EncounterLayerParent parent, string map, string outputDir, List<string> problems)
        {
            var written = new List<ContractPlan>();
            foreach (var layer in EncounterEdit.Layers(parent))
            {
                ContractPlan plan;
                try { plan = Plan(layer, map); }
                catch (Exception e) { problems.Add($"{layer.name}: contract: {e.Message}"); continue; }
                if (plan == null) continue;
                File.WriteAllText(Path.Combine(outputDir, plan.FileName), plan.contract.ToJSON());
                written.Add(plan);
            }
            return written;
        }

        /// <summary>A written contract read back with HBS's own deserializer (the full read the game makes on rehydrate).</summary>
        public static ContractOverride Read(string path)
        {
            var co = new ContractOverride();
            co.FromJSONFull(File.ReadAllText(path));
            return co;
        }

        public static IEnumerable<TeamOverride> Teams(ContractOverride co) => new[] { co.player1Team, co.player2Team, co.employerTeam, co.employersAllyTeam,
            co.targetTeam, co.targetsAllyTeam, co.neutralToAllTeam, co.hostileToAllTeam }.Where(t => t != null);

        // The lance and its units as the modder set them on the spawner and its points (LanceSpawnerGameLogic.ApplyContractOverride
        // and UnitSpawnPointGameLogic.ApplyContractOverride read these fields back).
        static LanceOverride Lance(LanceSpawnerGameLogic lance)
        {
            var o = new LanceOverride(lance) { name = lance.name, lanceDefId = lance.lanceDefId, lanceDifficultyAdjustment = lance.difficultyAdjustment };
            if (lance.lanceTagSet != null) o.lanceTagSet.AddRange(lance.lanceTagSet.ToArray());
            if (lance.excludedLanceTagSet != null) o.lanceExcludedTagSet.AddRange(lance.excludedLanceTagSet.ToArray());
            if (lance.spawnEffectTags != null) o.spawnEffectTags.AddRange(lance.spawnEffectTags.ToArray());
            foreach (var p in lance.unitSpawnPointGameLogicList)
            {
                var u = new UnitSpawnPointOverride(p) { customUnitName = p.customUnitName, customHeraldryDefId = p.customHeraldryDefId, unitType = p.unitType, unitDefId = p.UnitDefId, pilotDefId = p.pilotDefId };
                if (p.unitTagSet != null) u.unitTagSet.AddRange(p.unitTagSet.ToArray());
                if (p.unitExcludedTagSet != null) u.unitExcludedTagSet.AddRange(p.unitExcludedTagSet.ToArray());
                if (p.spawnEffectTags != null) u.spawnEffectTags.AddRange(p.spawnEffectTags.ToArray());
                if (p.pilotTagSet != null) u.pilotTagSet.AddRange(p.pilotTagSet.ToArray());
                if (p.pilotExcludedTagSet != null) u.pilotExcludedTagSet.AddRange(p.pilotExcludedTagSet.ToArray());
                o.unitSpawnPointOverrideList.Add(u);
            }
            return o;
        }

        // ---- The base contract ----

        /// <summary>data/contracts of the retail install the kit was pointed at (Extract Retail Maps), else of the one it finds.</summary>
        public static string RetailContractsDir()
        {
            var install = string.IsNullOrEmpty(RetailMaps.RetailInstall) ? RetailMaps.FindInstall() : RetailMaps.RetailInstall;
            var dir = install == null ? null : Path.Combine(install, "BattleTech_Data", "StreamingAssets", "data", "contracts");
            return dir != null && Directory.Exists(dir) ? dir : null;
        }

        static ContractPlan Base(EncounterLayerData layer)
        {
            var type = layer.SupportedContractTypeValue;
            if (type == null || type.IsInvalidUnsetRow) throw new InvalidOperationException($"Encounter layer {layer.name} has no contract type.");
            var guids = new HashSet<string>(layer.GetComponentsInChildren<EncounterObjectGameLogic>(true).Select(o => o.encounterObjectGuid));
            var dir = RetailContractsDir();
            var folder = dir == null ? null : Path.Combine(dir, type.Name.ToLowerInvariant());
            ContractPlan best = null;
            if (folder != null && Directory.Exists(folder))
                foreach (var f in Directory.GetFiles(folder, "*.json").OrderBy(f => f, StringComparer.Ordinal))
                {
                    var co = Read(f);
                    if (co.ContractTypeValue == null || co.ContractTypeValue.Name != type.Name) continue;
                    int missing = Guids(co).Count(g => !guids.Contains(g));
                    if (best == null || missing < best.baseMissing)
                        best = new ContractPlan { layer = layer, contract = co, baseId = Path.GetFileNameWithoutExtension(f), baseFile = f, baseMissing = missing };
                }
            return best ?? Template(layer, guids);
        }

        static IEnumerable<string> Guids(ContractOverride co) =>
            co.contractObjectiveList.Select(o => o.GUID).Concat(co.objectiveList.Select(o => o.GUID)).Concat(co.chunkList.Select(c => c.GUID))
                .Concat(Teams(co).SelectMany(t => t.lanceOverrideList).SelectMany(l => new[] { l.GUID }.Concat(l.unitSpawnPointOverrideList.Select(u => u.GUID))))
                .Where(g => !string.IsNullOrEmpty(g));

        // No retail install: a minimal contract of the layer's type, from the layer's own contract objectives, objectives and
        // player lance (HBS's ToJSON needs player 1's first lance).
        static ContractPlan Template(EncounterLayerData layer, HashSet<string> guids)
        {
            var co = new ContractOverride(layer) { contractName = layer.encounterName };
            foreach (var c in layer.GetComponentsInChildren<ContractObjectiveGameLogic>(true))
                co.contractObjectiveList.Add(new ContractObjectiveOverride(c) { title = c.title, description = c.description });
            foreach (var o in layer.GetComponentsInChildren<ObjectiveGameLogic>(true))
                co.objectiveList.Add(new ObjectiveOverride(o) { title = o.title, description = o.description, isPrimary = o.IsRequiredForContractObjective });
            var player = layer.GetComponentsInChildren<PlayerLanceSpawnerGameLogic>(true).FirstOrDefault(p => p.teamDefinitionGuid == co.player1Team.teamGuid)
                ?? throw new InvalidOperationException($"No retail install was found for a base contract, and layer {layer.name} has no player 1 lance to build one from.");
            co.player1Team.lanceOverrideList.Add(Lance(player));
            return new ContractPlan { layer = layer, contract = co, baseId = layer.SupportedContractTypeValue.Name, baseFile = "(template: no retail install found)" };
        }
    }
}
