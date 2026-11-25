// UCU Map Kit: readable inspectors for the two encounter-scripting types (map-kit X6, EncounterScripting.cs). Writes go
// through the SerializedObject (KitInspector), so each edit is one Undo step, except "Write these lines into the contract",
// which adds the dialogue to the scene's contract record (ContractWriter).
using System.Linq;
using BattleTech;
using BattleTech.Designed;
using BattleTech.Framework;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;

namespace UCU.MapKit
{
    [CustomEditor(typeof(AmbushChunkGameLogic), true), CanEditMultipleObjects]
    public class AmbushChunkInspector : KitInspector
    {
        protected override string Title => "Ambush";
        protected override string Summary => "A lance that appears when a unit enters the trigger region. Controlled By Contract: the contract Export writes enables it when its region and lance are set.";

        protected override void Build(VisualElement root)
        {
            Field(root, "startingStatus", "Starts", "Controlled By Contract: off unless the contract enables it (Export adds that entry). Active: always armed.");
            Field(root, "onlyTriggerOnce", "Only once", "Spawn the lance on the first entry only.");
            RefField<RegionGameLogic>(root, "ambushTriggerRegion", "Trigger region", "Entering this region springs the ambush.");
            RefField<LanceSpawnerGameLogic>(root, "ambushingSpawnGroup", "Ambush lance", "The lance that appears. Its units go into the contract from its spawn points.");
            Field(root, "requiredTagsOnTriggeringUnit", "Triggered by", "Only units with these tags spring it (retail: player_unit).");
            Field(root, "notes", "Notes", "For map makers; not shown in the game.");
        }
    }

    [CustomEditor(typeof(DialogueGameLogic), true)]
    public class DialogueInspector : KitInspector
    {
        const string Lines = "conversationContent.contents";

        protected override string Title => "Dialogue";
        protected override string Summary => "A conversation of one or more lines. Its lines go into the contract Export writes, which is where the game reads them.";

        protected override void Build(VisualElement root)
        {
            var d = (DialogueGameLogic)target;
            Info(root, "plays", "Plays: " + Plays(d), "Mission start, success and failure use HBS's fixed dialogue GUIDs; an objective plays one by its success or failure dialogue.");
            Field(root, "dialogueSource", "Source", "From Editor: the lines below. From Bucket: a random conversation of a DialogBucketDef.");
            Field(root, "dialoguePriority", "Priority");
            Field(root, "showOnlyOnce", "Only once");
            Field(root, "dialogueSortOrder", "Sort order");
            var list = serializedObject.FindProperty(Lines);
            var box = new VisualElement { name = "kit-lines", style = { marginTop = 4 } };
            box.Add(new Label("Lines") { tooltip = TipText(Lines, "Speaker is a CastDef id (castDef_DariusDefault, castDef_SumireDefault, ...)."), style = { marginLeft = 3, unityFontStyleAndWeight = FontStyle.Bold } });
            root.Add(box);
            if (list == null || !list.isArray)
            {
                box.Add(new Label($"HBS field {Lines} is not serialized on this object."));
                return;
            }
            var rows = new VisualElement { style = { marginLeft = 8 } };
            box.Add(rows);
            void Fill()
            {
                rows.Clear();
                serializedObject.Update();
                for (int i = 0; i < list.arraySize; i++)
                {
                    var p = $"{Lines}.Array.data[{i}]";
                    rows.Add(new Label($"Line {i + 1}") { style = { marginTop = 3 } });
                    Field(rows, p + ".selectedCastDefId", "Speaker", "A CastDef id: who speaks, with their portrait.");
                    Field(rows, p + ".words", "Text");
                    Field(rows, p + ".emote", "Emote");
                    RefField<EncounterObjectGameLogic>(rows, p + ".cameraFocus", "Camera on", "The object the camera turns to while the line plays (contract field cameraFocusGuid).");
                }
                if (list.arraySize == 0) rows.Add(new Label("None."));
                rows.Bind(serializedObject);
            }
            var buttons = new VisualElement { style = { flexDirection = FlexDirection.Row, marginLeft = 8 } };
            buttons.Add(new Button(() =>
            {
                serializedObject.Update();
                list.arraySize++;
                var last = $"{Lines}.Array.data[{list.arraySize - 1}]";
                serializedObject.FindProperty(last + ".words").stringValue = "";
                serializedObject.ApplyModifiedProperties();
            }) { text = "Add line", name = "kit-lines-add", tooltip = "Add a line (it starts with the last line's speaker)." });
            buttons.Add(new Button(() =>
            {
                serializedObject.Update();
                if (list.arraySize > 0) list.arraySize--;
                serializedObject.ApplyModifiedProperties();
            }) { text = "Remove last", name = "kit-lines-remove", tooltip = "Remove the last line." });
            box.Add(buttons);
            box.TrackPropertyValue(serializedObject.FindProperty(Lines + ".Array.size"), _ => Fill());
            Fill();

            bool recorded = ContractWriter.RecordedDialogues(d.gameObject.scene).Contains(d.encounterObjectGuid);
            var state = Info(root, "contract", recorded ? "Contract: these lines are written into the contract Export writes."
                : "Contract: not written. Retail scenes carry placeholder text the retail contracts replace, so only dialogues made with Add Dialogue, or marked below, go into the kit's contract.",
                "ContractWriter: dialogueList entry with dialogueContent from these lines; record " + ContractWriter.DialoguesFile(d.gameObject.scene));
            if (!recorded)
                root.Add(new Button(() => { ContractWriter.RecordDialogue(d.gameObject.scene, d.encounterObjectGuid); state.text = "Contract: these lines are written into the contract Export writes."; })
                    { text = "Write these lines into the contract", name = "kit-contract-record" });
        }

        static string Plays(DialogueGameLogic d)
        {
            if (d.encounterObjectGuid == DialogueGameLogic.missionStartDialogueGuid) return "at mission start";
            if (d.encounterObjectGuid == DialogueGameLogic.missionSuccessDialogueGuid) return "on mission success";
            if (d.encounterObjectGuid == DialogueGameLogic.missionFailedDialogueGuid) return "on mission failure";
            var layer = d.GetComponentInParent<EncounterLayerData>(true);
            var by = layer == null ? new string[0] : layer.GetComponentsInChildren<ObjectiveGameLogic>(true).SelectMany(o => new[]
            {
                ContractWriter.RefGuid(o.onSuccessDialogue) == d.encounterObjectGuid ? $"when {o.name} succeeds" : null,
                ContractWriter.RefGuid(o.onFailureDialogue) == d.encounterObjectGuid ? $"when {o.name} fails" : null,
            }).Where(s => s != null).ToArray();
            return by.Length > 0 ? string.Join(", ", by) : "not linked (a trigger or an objective must play it)";
        }
    }
}
