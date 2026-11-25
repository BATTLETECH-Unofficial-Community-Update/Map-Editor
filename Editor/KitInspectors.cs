// UCU Map Kit: readable inspectors for the HBS components a modder touches (design-v2 § 4.1, § 4.4; map-kit plan U2).
// Labels are plain words; the HBS field name and HBS's own tooltip are in each tooltip; "HBS fields" below shows the
// default inspector. The kit only reads HBS code here (the team list, the spawn points, the layer list); writes go through
// the SerializedObject (KitInspector), except the Snap buttons, which run Encounter mode's snap (EncounterEdit, with Undo),
// and the plot Variant dropdown, which runs HBS's own variant switch (PlotInspector.SetVariant, with Undo).
using System.Collections.Generic;
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
    [CustomEditor(typeof(LanceSpawnerGameLogic), true), CanEditMultipleObjects]
    public class LanceSpawnerInspector : KitInspector
    {
        protected override string Title => target is PlayerLanceSpawnerGameLogic ? "Player lance spawner" : "Lance spawner";
        protected override string Summary => "A lance and the four unit spawn points under it. The lance arrives at its points.";

        protected override void Build(VisualElement root)
        {
            Team(root);
            Field(root, "spawnMethod", "Arrives by", "How the lance reaches its spawn points.");
            Field(root, "dropshipAnimationStyle", "Dropship flight", "Only used when it arrives by dropship.");
            Field(root, "spawnUnitsOnActivation", "Spawn when activated", "Spawn the units as soon as the spawner becomes active.");
            Field(root, "triggerInterruptPhaseOnSpawn", "Act on spawn");
            Field(root, "behaviorTree", "AI behaviour", "The AI tree the lance's units run.");
            Field(root, "lanceDefId", "Lance definition", "\"Manual\" uses the units set on each spawn point; \"Tagged\" picks a lance by tags; otherwise a LanceDef id.");
            Field(root, "encounterTags", "Encounter tags");
            if (!serializedObject.isEditingMultipleObjects)
            {
                var points = ((LanceSpawnerGameLogic)target).unitSpawnPointGameLogicList;
                Info(root, "unitSpawnPoints", $"Unit spawn points: {points.Length} ({string.Join(", ", points.Select(p => p.name))})",
                    "The UnitSpawnPointGameLogic children of this spawner.\nHBS field: unitSpawnPointGameLogicList");
            }
            // The same snap Encounter mode runs when a lance handle lets go (EncounterEdit.SnapLance), as one Undo step.
            root.Add(new Button(() => { foreach (var t in targets) EncounterEdit.PlaceLance((LanceSpawnerGameLogic)t, ((Component)t).transform.position); })
                { text = "Snap to hex and ground", name = "kit-snap",
                  tooltip = "Puts the lance and each of its unit spawn points on a hex centre and on the ground, and sets each point's hex position (HBS field: hexPosition)." });
        }

        // The team dropdown lists HBS's own selectable teams (EncounterLayerData.GetSelectableTeamGuidsAndNames) and
        // stores the team GUID, as HBS's field expects.
        void Team(VisualElement root)
        {
            var p = serializedObject.FindProperty("teamDefinitionGuid");
            var layer = ((Component)target).GetComponentInParent<EncounterLayerData>(true);
            var teams = layer != null ? layer.GetSelectableTeamGuidsAndNames() : new List<KeyValuePair<string, string>>();
            var choices = teams.Select(t => t.Key).ToList();
            if (!choices.Contains(p.stringValue)) choices.Add(p.stringValue);
            string Name(string guid) => teams.Where(t => t.Key == guid).Select(t => t.Value).DefaultIfEmpty($"unknown team {guid}").First();
            var f = new PopupField<string>("Team", choices, p.stringValue, Name, Name) { bindingPath = "teamDefinitionGuid", name = "kit-teamDefinitionGuid" };
            f.AddToClassList(BaseField<string>.alignedFieldUssClassName);
            f.showMixedValue = p.hasMultipleDifferentValues;
            Tip(f, "teamDefinitionGuid", "Which side the lance fights for.");
            root.Add(f);
        }
    }

    [CustomEditor(typeof(UnitSpawnPointGameLogic), true), CanEditMultipleObjects]
    public class UnitSpawnPointInspector : KitInspector
    {
        protected override string Title => "Unit spawn point";
        protected override string Summary => "One unit of a lance appears here. Its lance spawner sets the team and how it arrives.";

        protected override void Build(VisualElement root)
        {
            Field(root, "unitType", "Unit type");
            Field(root, "mechDefId", "Mech", "A MechDef id, for a Manual lance.");
            Field(root, "vehicleDefId", "Vehicle", "A VehicleDef id, for a Manual lance.");
            Field(root, "turretDefId", "Turret", "A TurretDef id, for a Manual lance.");
            Field(root, "pilotDefId", "Pilot", "A PilotDef id, for a Manual lance.");
            Field(root, "customUnitName", "Custom unit name");
            Field(root, "customHeraldryDefId", "Custom heraldry", "A HeraldryDef id.");
            var hex = Field(root, "hexPosition", "Hex position", "The hex centre the unit stands on. HBS sets it when the point is snapped to the grid; it is not typed in.");
            hex?.SetEnabled(false);
        }
    }

    [CustomEditor(typeof(EncounterBoundaryRectGameLogic), true), CanEditMultipleObjects]
    public class EncounterBoundaryRectInspector : KitInspector
    {
        protected override string Title => "Play area";
        protected override string Summary => "The rectangle units may move in. Its centre is this object's position, rounded to 4 m.";

        protected override void Build(VisualElement root)
        {
            Field(root, "width", "Width (m)", "East-west size of the play area.");
            Field(root, "height", "Depth (m)", "North-south size of the play area.");
        }
    }

    [CustomEditor(typeof(RegionGameLogic), true), CanEditMultipleObjects]
    public class RegionInspector : KitInspector
    {
        protected override string Title => "Region";
        protected override string Summary => "An area on the map that objectives and triggers use. Its region points outline it.";

        protected override void Build(VisualElement root)
        {
            Field(root, "radius", "Radius (m)");
            Field(root, "regionDefId", "Region type", "The RegionDef that sets how the region is shown (regiondef_Hidden: not shown).");
            Field(root, "alwaysShowRegionWhenActive", "Shown while active");
            RefList<ObjectiveGameLogic>(root, "objectiveRefList", "Objectives", "The objectives this region belongs to.");
            if (!serializedObject.isEditingMultipleObjects)
                Info(root, "regionPoints", $"Region points: {((RegionGameLogic)target).regionPointList.Length}",
                    "The RegionPointGameLogic children that outline the region; HBS needs at least 3.\nHBS field: regionPointList");
            // The snap Encounter mode runs when a region handle lets go (EncounterEdit.SnapRegion), as one Undo step.
            root.Add(new Button(() => { foreach (var t in targets) EncounterEdit.PlaceRegion((RegionGameLogic)t, ((Component)t).transform.position); })
                { text = "Snap to hex and ground", name = "kit-snap",
                  tooltip = "Puts the region on a hex centre and the ground, rounds the radius to whole 24 m hexes and lays the region points out as a regular hexagon on hex centres, each with its hex position." });
        }
    }

    [CustomEditor(typeof(ObjectiveGameLogic), true), CanEditMultipleObjects]
    public class ObjectiveInspector : KitInspector
    {
        protected override string Title => ObjectNames.NicifyVariableName(target.GetType().Name);
        protected override string Summary => "One objective. A contract objective lists it; its result counts toward the contract.";

        protected override void Build(VisualElement root)
        {
            Field(root, "title", "Title", "Shown in the objective list.");
            Field(root, "description", "Description");
            Field(root, "primary", "Needed by contract");
            Field(root, "displayToUser", "Show in game");
            Field(root, "showProgress", "Show progress");
            Field(root, "progressFormat", "Progress text", "For example [percentageComplete].");
            Field(root, "priority", "List order");
            Field(root, "markUnitsWith", "Mark units as");
            Field(root, "useBeacon", "Show a beacon");
            Field(root, "invertObjective", "Inverted");
        }
    }

    [CustomEditor(typeof(DestroyLanceObjective), true), CanEditMultipleObjects]
    public class DestroyLanceObjectiveInspector : ObjectiveInspector
    {
        protected override string Title => "Destroy lance objective";
        protected override string Summary => "Succeeds when every unit of the chosen lance is destroyed.";

        protected override void Build(VisualElement root)
        {
            RefField<LanceSpawnerGameLogic>(root, "lanceToDestroy", "Lance to destroy");
            base.Build(root);
        }
    }

    [CustomEditor(typeof(ContractObjectiveGameLogic), true), CanEditMultipleObjects]
    public class ContractObjectiveInspector : KitInspector
    {
        protected override string Title => "Contract objective";
        protected override string Summary => "What the contract asks of one player, made of the objectives it lists.";

        protected override void Build(VisualElement root)
        {
            Field(root, "title", "Title", "Shown in the contract.");
            Field(root, "description", "Description");
            Field(root, "forPlayer", "For player");
            Field(root, "primary", "Primary");
            Field(root, "displayToUser", "Show in the contract");
            Field(root, "forDisplayPurposesOnly", "Display only");
            Field(root, "mustCompleteAll", "Wait for all");
            RefList<ObjectiveGameLogic>(root, "objectiveRefList", "Objectives", "The objectives this contract objective is made of.");
        }
    }

    [CustomEditor(typeof(EncounterLayerData), true), CanEditMultipleObjects]
    public class EncounterLayerDataInspector : KitInspector
    {
        protected override string Title => "Encounter layer";
        protected override string Summary => "One contract type's setup on this map: its spawns, objectives and play area. Export writes one LayerData file per layer.";

        protected override void Build(VisualElement root)
        {
            Field(root, "encounterName", "Name", "The layer's name in the game's lists.");
            Field(root, "supportedContractTypeID", "Contract type", "Set when the layer is made; contracts of this type use the layer.")?.SetEnabled(false);
            Field(root, "encounterPlayStyle", "Play style");
            Field(root, "includeInBuild", "Include in build");
            Field(root, "encounterDescription", "Description");
            Field(root, "estimatedBattleValue", "Battle value", "An estimate of the encounter's strength.");
            Field(root, "startingFogOfWarVisibility", "Fog of war at start");
            Field(root, "notes", "Notes", "For map makers; not shown in the game.");
            if (!serializedObject.isEditingMultipleObjects)
                Info(root, "active", ((Component)target).gameObject.activeSelf ? "Active layer: yes" : "Active layer: no (the encounter layer parent selects the active layer)",
                    "Only the active layer is shown in the scene and checked by the game's tools.");
        }
    }

    [CustomEditor(typeof(EncounterLayerParent), true), CanEditMultipleObjects]
    public class EncounterLayerParentInspector : KitInspector
    {
        protected override string Title => "Encounter layer parent";
        protected override string Summary => "Holds the map's encounter layers, one of them active. MapMetaDataExporter and InclineMeshBuilder sit on the same object.";

        protected override void Build(VisualElement root)
        {
            Field(root, "dropPodLandedPrefab", "Drop pod effect", "The prefab left where a drop pod lands.");
            if (serializedObject.isEditingMultipleObjects) return;
            var parent = (EncounterLayerParent)target;
            var layers = parent.GetComponentsInChildren<EncounterLayerData>(true);
            // The contract type is read from the serialized field: HBS's SupportedContractTypeValue getter writes it back.
            string Type(EncounterLayerData l) { using (var so = new SerializedObject(l)) return so.FindProperty("supportedContractTypeID").stringValue; }
            Info(root, "layers", "Layers: " + string.Join(", ", layers.Select(l => $"{l.name} ({Type(l)}){(l.gameObject.activeSelf ? ", active" : "")}")),
                "The EncounterLayerData children, with their contract types.\nHBS field: selectedEncounterLayerIndex (the active one)");
        }
    }

    // Urban plots (U10). A plot's variants are its PlotVariant children; one is active. HBS switches a variant with
    // Plot.SelectPlotVariantByName, run by PlotParent.OverridePlots (PlotParent.cs:29) for the entry the active layer's
    // PlotOverride holds; a plot without an entry goes back to variant 0 (:25). OverridePlots runs whenever a layer is
    // selected (EncounterLayerParent.cs:176), so by Export and Map Check, and when the game loads the LayerData
    // (EncounterLayerData.cs:2199-2203). A choice kept only on the plot would be undone there, so the choice is the active
    // layer's PlotOverride entry. A layer without a PlotOverride (every layer ContractLayers.Add copies in) keeps whatever
    // variant the layer selected before it left, so Map Check and Export reset it (KFIX5, U10P Finding 1): the switch adds
    // the PlotOverride, holding every plot's current variant, then writes the entry.
    [CustomEditor(typeof(Plot), true)]
    public class PlotInspector : KitInspector
    {
        protected override string Title => "Urban plot";
        protected override string Summary => "A plot holds building variants and the game shows one. Each encounter layer chooses its own (its plot override), so the variant below is the active layer's.";

        protected override void Build(VisualElement root)
        {
            Field(root, "width", "Width (m)");
            Field(root, "height", "Depth (m)");
            var plot = (Plot)target;
            var names = plot.GetPlotVariantNameList();
            if (names.Length == 0)
            {
                Info(root, "variant", "Variants: none (no PlotVariant children).", "HBS lists a plot's PlotVariant children as its variants (Plot.GetPlotVariantNameList).");
                return;
            }
            var layer = EncounterEdit.ActiveLayer(EncounterEdit.Parent());
            var po = layer != null ? layer.GetComponent<PlotOverride>() : null;
            var choices = Enumerable.Range(0, names.Length).ToList();
            if (!choices.Contains(plot.SelectedPlotVariantIndex)) choices.Add(plot.SelectedPlotVariantIndex);
            string Name(int i) => i >= 0 && i < names.Length ? names[i] : "none active";
            // With T = int the (label, choices, defaultIndex, ...) constructor is the one C# picks; pass the index.
            var f = new PopupField<int>("Variant", choices, choices.IndexOf(plot.SelectedPlotVariantIndex), Name, Name) { name = "kit-variant" };
            f.AddToClassList(BaseField<int>.alignedFieldUssClassName);
            Tip(f, "selectedPlotVariantIndex", "The buildings this plot shows. Export writes the active variant's buildings into the layer's data.");
            f.RegisterValueChangedCallback(e => SetVariant(plot, e.newValue));
            f.TrackPropertyValue(serializedObject.FindProperty("selectedPlotVariantIndex"), _ => f.SetValueWithoutNotify(plot.SelectedPlotVariantIndex));
            root.Add(f);
            Info(root, "variant-layer", po != null ? $"Chosen for layer {layer.name} (its plot override)."
                : layer != null ? $"Layer {layer.name} has no plot override yet: choosing a variant adds one, holding every plot's current variant." : "No active encounter layer.",
                "HBS field: PlotOverride.plotOverrideEntryList (plotName, plotVariant) on the active layer");
        }

        /// <summary>Makes variant <paramref name="index"/> the plot's active one for the active layer, as one Undo step.</summary>
        public static void SetVariant(Plot plot, int index)
        {
            var names = plot.GetPlotVariantNameList();
            if (index < 0 || index >= names.Length) return;
            var layer = EncounterEdit.ActiveLayer(EncounterEdit.Parent());
            var po = layer != null ? layer.GetComponent<PlotOverride>() : null;
            // HBS's OverridePlots needs a PlotParent once the layer has a PlotOverride (EncounterLayerData.cs:443-446), and resets
            // only that parent's plots (PlotParent.cs:13-31); a plot outside one keeps its own index.
            var plotParent = plot.GetComponentInParent<PlotParent>(true);
            if (po == null && layer != null && plotParent != null)
            {
                // Created first: Undo.AddComponent closes the records taken before it, so a plot recorded earlier and changed
                // after it is left out of Undo (KFIX5, measured). Recorded before it is filled, so Redo re-creates it with its entries.
                po = Undo.AddComponent<PlotOverride>(layer.gameObject);
                Undo.RecordObject(po, "Plot variant");
                foreach (var p in plotParent.GetPlotList())
                {
                    var shown = p.GetSelectedPlotVariant();
                    if (shown != null) po.plotOverrideEntryList.Add(new PlotOverrideEntry { plotName = p.name, plotVariant = shown.name });
                }
            }
            var undo = new List<Object> { plot };
            undo.AddRange(plot.GetPlotVariantList().Select(v => (Object)v.gameObject));
            if (po != null) undo.Add(po);
            Undo.RecordObjects(undo.ToArray(), "Plot variant");
            if (po == null)
                plot.SelectedPlotVariantIndex = index;
            else
            {
                var entry = po.GetPlotOverrideEntryByName(plot.name);
                if (entry == null) po.plotOverrideEntryList.Add(entry = new PlotOverrideEntry { plotName = plot.name });
                entry.plotVariant = names[index];
                plot.SelectPlotVariantByName(names[index]);
            }
            foreach (var o in undo)
                if (PrefabUtility.IsPartOfPrefabInstance(o)) PrefabUtility.RecordPrefabInstancePropertyModifications(o);
        }
    }
}
