// UCU Map Kit: the Scene-view mode overlay (design-v2 § 3 convention 2, § 4.1; map-kit plan U3). Five mode buttons:
// Terrain, Terrain Types, Objects, Encounter, Check. Terrain selects the open map's terrain, so Unity's terrain inspector holds the brushes
// (design-v2 row 1); Check opens the Map Check window by the call the menu item makes (row 13); Terrain Types (TerrainTypesView.cs,
// PaintTerrainType.cs), Objects (ObjectPalette.cs) and Encounter have panels of their own. Each mode has a Shortcut Manager entry (category
// UCU Map Kit, rebindable) and a menu item under UCU Map Kit/Mode. Encounter mode lists the active layer's lances, play area, objectives and regions, each with Select
// and Frame; its Scene-view handles are in EncounterHandles.cs. The mode is Editor state only (SessionState): it changes
// nothing in the map.
using System;
using System.Collections.Generic;
using System.Linq;
using BattleTech;
using BattleTech.Framework;
using UnityEditor;
using UnityEditor.Overlays;
using UnityEditor.SceneManagement;
using UnityEditor.ShortcutManagement;
using UnityEngine;
using UnityEngine.UIElements;

namespace UCU.MapKit
{
    public enum KitMode { None = -1, Terrain = 0, TerrainTypes = 1, Objects = 2, Encounter = 3, Check = 4 }

    public static class KitModes
    {
        const string StateKey = "UCU.MapKit.Mode";
        public const string MenuRoot = "UCU Map Kit/Mode/";

        public struct ModeInfo { public KitMode mode; public string label; public string help; }

        public static readonly ModeInfo[] All =
        {
            new ModeInfo { mode = KitMode.Terrain, label = "Terrain", help = "Select the map's terrain. Unity's terrain inspector then holds the brushes: raise, lower, smooth, set height, stamp, paint texture, trees and details." },
            new ModeInfo { mode = KitMode.TerrainTypes, label = "Terrain Types", help = "Show the terrain types the game reads (water, deep water, forest, rough, road, impassable, custom), the 50 m edge band, the play area and the hex grid near the cursor. Paint them with Paint Terrain Type (the button in this panel, or Alt+Shift+T)." },
            new ModeInfo { mode = KitMode.Objects, label = "Objects", help = "Place rocks, buildings and other props from the Objects palette (UCU Map Kit/Objects…), which this mode opens." },
            new ModeInfo { mode = KitMode.Encounter, label = "Encounter", help = "Move lances, the play area and regions of the active encounter layer. Handles snap to the hex grid and the ground on release." },
            new ModeInfo { mode = KitMode.Check, label = "Check", help = "Open Map Check (the Map Kit window's Check tab): the game's layer validation, what the exporter needs and the kit's checks." },
        };

        public static event Action Changed;

        public static KitMode Current => (KitMode)SessionState.GetInt(StateKey, (int)KitMode.None);

        public static ModeInfo Info(KitMode m) => All.First(i => i.mode == m);

        /// <summary>Switches to <paramref name="m"/>, or out of it when it is already on. Terrain selects the open map's terrain (and stays off,
        /// with one line, when there is none); Check opens Map Check, as UCU Map Kit/Map Check does.</summary>
        public static void Toggle(KitMode m)
        {
            bool entering = Current != m;
            if (entering && m == KitMode.Terrain && !SelectTerrain()) return;
            Set(entering ? m : KitMode.None);
            if (entering && m == KitMode.Check) MapKitWindow.OpenCheck();
        }

        // Dirties nothing; Unity records the selection change as one Undo step, as any selection in the Editor does (measured, map-kit KFIX9 S4).
        static bool SelectTerrain()
        {
            var t = Terrain.activeTerrain;
            if (t == null) { Notify("Terrain mode: the open scene has no terrain. Open a map first (UCU Map Kit > New Map from Template, or a map under Assets/MapKitMaps)."); return false; }
            Selection.activeGameObject = t.gameObject;
            return true;
        }

        public static void Set(KitMode m)
        {
            SessionState.SetInt(StateKey, (int)m);
            foreach (var i in All) Menu.SetChecked(MenuRoot + i.label, i.mode == m);
            if (m != KitMode.None) ShowOverlay();
            Changed?.Invoke();
            SceneView.RepaintAll();
        }

        static void Notify(string text)
        {
            var sv = SceneView.lastActiveSceneView;
            if (sv != null) sv.ShowNotification(new GUIContent(text));
            Debug.Log("UCU Map Kit: " + text);
        }

        /// <summary>Opens the overlay in every Scene view, expanded, so a mode switched on by key or menu is visible.</summary>
        public static void ShowOverlay()
        {
            foreach (SceneView sv in SceneView.sceneViews)
                if (sv.TryGetOverlay(MapKitOverlay.Id, out var o)) { o.displayed = true; o.collapsed = false; }
        }

        // Shortcut Manager entries (Edit > Shortcuts, category "UCU Map Kit"); defaults are Alt+Shift+1..5.
        [Shortcut("UCU Map Kit/Terrain mode", KeyCode.Alpha1, ShortcutModifiers.Alt | ShortcutModifiers.Shift)] static void KeyTerrain() => Toggle(KitMode.Terrain);
        [Shortcut("UCU Map Kit/Terrain Types mode", KeyCode.Alpha2, ShortcutModifiers.Alt | ShortcutModifiers.Shift)] static void KeyTypes() => Toggle(KitMode.TerrainTypes);
        [Shortcut("UCU Map Kit/Objects mode", KeyCode.Alpha3, ShortcutModifiers.Alt | ShortcutModifiers.Shift)] static void KeyObjects() => Toggle(KitMode.Objects);
        [Shortcut("UCU Map Kit/Encounter mode", KeyCode.Alpha4, ShortcutModifiers.Alt | ShortcutModifiers.Shift)] static void KeyEncounter() => Toggle(KitMode.Encounter);
        [Shortcut("UCU Map Kit/Check mode", KeyCode.Alpha5, ShortcutModifiers.Alt | ShortcutModifiers.Shift)] static void KeyCheck() => Toggle(KitMode.Check);

        // Menu items mirror the shortcuts; all five are built.
        [MenuItem(MenuRoot + "Terrain", false, 100)] static void MenuTerrain() => Toggle(KitMode.Terrain);
        [MenuItem(MenuRoot + "Terrain", true)] static bool CanTerrain() { Menu.SetChecked(MenuRoot + "Terrain", Current == KitMode.Terrain); return true; }
        [MenuItem(MenuRoot + "Terrain Types", false, 101)] static void MenuTypes() => Toggle(KitMode.TerrainTypes);
        [MenuItem(MenuRoot + "Terrain Types", true)] static bool CanTypes() { Menu.SetChecked(MenuRoot + "Terrain Types", Current == KitMode.TerrainTypes); return true; }
        [MenuItem(MenuRoot + "Objects", false, 102)] static void MenuObjects() => Toggle(KitMode.Objects);
        [MenuItem(MenuRoot + "Objects", true)] static bool CanObjects() { Menu.SetChecked(MenuRoot + "Objects", Current == KitMode.Objects); return true; }
        [MenuItem(MenuRoot + "Encounter", false, 103)] static void MenuEncounter() => Toggle(KitMode.Encounter);
        [MenuItem(MenuRoot + "Encounter", true)] static bool CanEncounter() { Menu.SetChecked(MenuRoot + "Encounter", Current == KitMode.Encounter); return true; }
        [MenuItem(MenuRoot + "Check", false, 104)] static void MenuCheck() => Toggle(KitMode.Check);
        [MenuItem(MenuRoot + "Check", true)] static bool CanCheck() { Menu.SetChecked(MenuRoot + "Check", Current == KitMode.Check); return true; }
    }

    [Overlay(typeof(SceneView), Id, "UCU Map Kit", true)]
    public class MapKitOverlay : Overlay
    {
        public const string Id = "ucu-map-kit-modes";
        VisualElement root;

        public override void OnCreated()
        {
            KitModes.Changed += Refresh;
            TerrainTypesView.Changed += Refresh;
            Selection.selectionChanged += Refresh;
            Undo.undoRedoPerformed += Refresh;
            EditorSceneManager.sceneOpened += OnSceneOpened;
        }

        public override void OnWillBeDestroyed()
        {
            KitModes.Changed -= Refresh;
            TerrainTypesView.Changed -= Refresh;
            Selection.selectionChanged -= Refresh;
            Undo.undoRedoPerformed -= Refresh;
            EditorSceneManager.sceneOpened -= OnSceneOpened;
        }

        void OnSceneOpened(UnityEngine.SceneManagement.Scene s, OpenSceneMode m) => Refresh();

        public override VisualElement CreatePanelContent()
        {
            root = new VisualElement { name = "ucu-map-kit-overlay", style = { minWidth = 260, maxWidth = 340 } };
            Refresh();
            return root;
        }

        public void Refresh()
        {
            if (root == null) return;
            root.Clear();
            var modes = new VisualElement { name = "modes", style = { flexDirection = FlexDirection.Row, flexWrap = Wrap.Wrap } };
            foreach (var i in KitModes.All)
            {
                var info = i;
                var b = new Button(() => KitModes.Toggle(info.mode)) { text = info.label, name = "mode-" + info.mode };
                bool on = KitModes.Current == info.mode;
                b.tooltip = $"{info.help} ({(on ? "on; press again to leave" : "off")})";
                if (on) { b.style.unityFontStyleAndWeight = FontStyle.Bold; b.style.borderBottomWidth = 2; b.style.borderBottomColor = new Color(0.24f, 0.49f, 0.9f); }
                modes.Add(b);
            }
            root.Add(modes);
            if (KitModes.Current == KitMode.Encounter)
                root.Add(EncounterPanel());
            else if (KitModes.Current == KitMode.TerrainTypes)
                root.Add(TerrainTypesView.Panel());
            else if (KitModes.Current == KitMode.Objects)
                root.Add(new Button(() => ObjectPalette.Open()) { text = "Open the Objects palette", name = "open-objects" });
        }

        static VisualElement EncounterPanel()
        {
            var panel = new VisualElement { name = "encounter", style = { marginTop = 4 } };
            var parent = EncounterEdit.Parent();
            if (parent == null)
            {
                panel.Add(Wrapped(new Label("This scene has no EncounterLayerParent. Open a map scene, or make one with UCU Map Kit > New Map from Template.")));
                return panel;
            }
            var layers = EncounterEdit.Layers(parent);
            var active = EncounterEdit.ActiveLayer(parent);
            var names = layers.Select(l => l.name).ToList();
            if (names.Count == 0)
            {
                panel.Add(Wrapped(new Label("The encounter layer parent has no layers.")));
                return panel;
            }
            int index = active != null ? Array.IndexOf(layers, active) : 0;
            var pick = new PopupField<string>("Layer", names, Mathf.Max(0, index)) { name = "layer",
                tooltip = "The active encounter layer: the one shown in the scene and edited here. Switching it is one Undo step.\nHBS field: selectedEncounterLayerIndex" };
            pick.RegisterValueChangedCallback(e => EncounterEdit.SelectLayer(parent, names.IndexOf(e.newValue)));
            panel.Add(pick);
            if (active == null) return panel;

            var scroll = new ScrollView(ScrollViewMode.Vertical) { name = "items", style = { maxHeight = 360 } };
            Section(scroll, "Lances", active.GetComponentsInChildren<LanceSpawnerGameLogic>(true).Select(l => (Component)l));
            Section(scroll, "Play area", active.GetComponentsInChildren<EncounterBoundaryRectGameLogic>(true).Select(r => (Component)r));
            Section(scroll, "Objectives", active.GetComponentsInChildren<ObjectiveGameLogic>(true).Select(o => (Component)o)
                .Concat(active.GetComponentsInChildren<ContractObjectiveGameLogic>(true)));
            Section(scroll, "Regions", active.GetComponentsInChildren<RegionGameLogic>(true).Select(r => (Component)r));
            panel.Add(scroll);
            panel.Add(Wrapped(new Label("Drag a handle in the Scene view: it snaps to the hex grid and the ground on release. The selected object has number fields beside its handles (Enter applies). Ctrl+Z undoes each move.")
                { name = "hint", style = { fontSize = 10, color = new Color(0.65f, 0.65f, 0.65f), marginTop = 4 } }));
            return panel;
        }

        static Label Wrapped(Label l) { l.style.whiteSpace = WhiteSpace.Normal; return l; }

        static void Section(VisualElement parent, string title, IEnumerable<Component> items)
        {
            var list = items.ToList();
            parent.Add(new Label($"{title} ({list.Count})") { style = { unityFontStyleAndWeight = FontStyle.Bold, marginTop = 4 } });
            if (list.Count == 0) parent.Add(new Label("None in this layer.") { style = { marginLeft = 8 } });
            foreach (var c in list)
            {
                var row = new VisualElement { name = "item-" + c.gameObject.name, style = { flexDirection = FlexDirection.Row, alignItems = Align.Center } };
                bool selected = Selection.activeGameObject == c.gameObject;
                var label = c is ContractObjectiveGameLogic co ? $"{co.title} (contract objective)" : c.gameObject.name;
                var select = new Button(() => { Selection.activeGameObject = c.gameObject; EditorGUIUtility.PingObject(c.gameObject); })
                    { text = label, name = "select", tooltip = $"Select {MapCheck.PathOf(c.transform)}." };
                select.style.flexGrow = 1;
                select.style.unityTextAlign = TextAnchor.MiddleLeft;
                if (selected) select.style.unityFontStyleAndWeight = FontStyle.Bold;
                var frame = new Button(() => MapKitWindow.Select(c)) { text = "Frame", name = "frame", tooltip = $"Select {c.gameObject.name} and frame it in the Scene view." };
                row.Add(select);
                row.Add(frame);
                parent.Add(row);
            }
        }
    }
}
