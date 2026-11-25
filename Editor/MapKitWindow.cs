// UCU Map Kit: the Map Kit window, three tabs.
// - Map: the map's settings (MapSettings.cs: display name, biome, weight, tags, preview picture, the biome's moods).
// - Check: runs MapCheck on the open map and lists each entry with a severity icon and word, a plain sentence, the object,
//   a Select button and, where the kit can repair it, a Fix button (one Undo step, then the check runs again); HBS's own
//   message is the tooltip. The summary says when the scene has unsaved changes (a Fix makes some), which Build Mod refuses.
// - Build: the UCU install folder (per machine), Bake lighting (MapBake.cs) and Test map in UCU (TestMap.cs).
// The window holds no map state: it reads and writes the open scene. Buttons take keyboard focus (Tab) and activate with
// Enter or Space; the window and each action have a menu item, which the Shortcut Manager lists for a key binding.
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UIElements;

namespace UCU.MapKit
{
    public class MapKitWindow : EditorWindow
    {
        public enum Tab { Map, Check, Build }

        List<MapCheckEntry> entries;
        static bool fixedSinceSave;
        string checkedScene;
        ScrollView list;
        Label summary;
        [SerializeField] Tab tab = Tab.Check;
        readonly Dictionary<Tab, VisualElement> pages = new Dictionary<Tab, VisualElement>();
        readonly Dictionary<Tab, Button> buttons = new Dictionary<Tab, Button>();
        readonly MapTab mapTab = new MapTab();

        public IReadOnlyList<MapCheckEntry> Entries => entries;
        public Tab CurrentTab => tab;

        [MenuItem("UCU Map Kit/Map Check")]
        static void OpenCheckMenu() => OpenCheck();

        [MenuItem("UCU Map Kit/Map Settings")]
        static void OpenMapMenu() => OpenTab(Tab.Map);

        [MenuItem("UCU Map Kit/Bake Lighting and Test Map")]
        static void OpenBuildMenu() => OpenTab(Tab.Build);

        public static MapKitWindow OpenCheck()
        {
            var w = OpenTab(Tab.Check);
            w.RunCheck();
            return w;
        }

        public static MapKitWindow OpenTab(Tab t)
        {
            var w = GetWindow<MapKitWindow>("Map Kit");
            w.minSize = new Vector2(520f, 240f);
            w.ShowTab(t);
            return w;
        }

        public void ShowTab(Tab t)
        {
            tab = t;
            foreach (var kv in pages) kv.Value.style.display = kv.Key == t ? DisplayStyle.Flex : DisplayStyle.None;
            foreach (var kv in buttons)
            {
                kv.Value.style.unityFontStyleAndWeight = kv.Key == t ? FontStyle.Bold : FontStyle.Normal;
                kv.Value.style.borderBottomWidth = kv.Key == t ? 2 : 0;
            }
            Repaint();
        }

        public void RunCheck()
        {
            entries = MapCheck.Run();
            var scene = SceneManager.GetActiveScene();
            checkedScene = string.IsNullOrEmpty(scene.path) ? "the unsaved scene" : scene.path;
            Rebuild();
        }

        void OnEnable() => EditorApplication.update += RepaintWhileBusy;
        void OnDisable() => EditorApplication.update -= RepaintWhileBusy;

        // The bake and Test map run in the background; the Build tab shows their state as it changes.
        void RepaintWhileBusy()
        {
            if (tab == Tab.Build && (MapBake.State == BakeState.Running || (TestMap.Current != null && TestMap.Current.running)))
                Repaint();
        }

        void CreateGUI()
        {
            var root = rootVisualElement;
            root.style.paddingLeft = root.style.paddingRight = 6;
            root.style.paddingTop = 4;

            var tabs = new VisualElement { style = { flexDirection = FlexDirection.Row, marginBottom = 4 } };
            foreach (var (t, tip) in new[] { (Tab.Map, "The map's settings: name, biome, how often it is picked, tags, preview picture."),
                (Tab.Check, "Map Check: problems that stop the map from exporting or playing."),
                (Tab.Build, "Bake the lighting and test the map in UCU.") })
            {
                var b = new Button(() => ShowTab(t)) { text = t.ToString(), tooltip = tip, name = "tab-" + t.ToString().ToLowerInvariant() };
                b.style.borderBottomColor = new Color(0.24f, 0.49f, 0.9f);
                tabs.Add(b);
                buttons[t] = b;
            }
            root.Add(tabs);

            pages[Tab.Map] = new IMGUIContainer(mapTab.OnGUI) { name = "page-map", style = { flexGrow = 1 } };
            pages[Tab.Build] = new IMGUIContainer(BuildGUI) { name = "page-build", style = { flexGrow = 1 } };
            var check = new VisualElement { name = "page-check", style = { flexGrow = 1 } };
            var header = new VisualElement { style = { flexDirection = FlexDirection.Row, alignItems = Align.Center } };
            var run = new Button(RunCheck) { text = "Check map", tooltip = "Run Map Check on the open scene. It changes nothing in the map." };
            run.name = "check-map";
            header.Add(run);
            summary = new Label { style = { flexGrow = 1, whiteSpace = WhiteSpace.Normal, marginLeft = 6 } };
            summary.name = "summary";
            header.Add(summary);
            check.Add(header);
            list = new ScrollView(ScrollViewMode.Vertical) { style = { flexGrow = 1, marginTop = 4 } };
            list.name = "entries";
            check.Add(list);
            pages[Tab.Check] = check;
            foreach (var t in new[] { Tab.Map, Tab.Check, Tab.Build }) root.Add(pages[t]);
            ShowTab(tab);
            Rebuild();
        }

        Vector2 buildScroll;

        void BuildGUI()
        {
            var scene = SceneManager.GetActiveScene();
            buildScroll = EditorGUILayout.BeginScrollView(buildScroll);
            EditorGUIUtility.labelWidth = 150f;

            EditorGUILayout.LabelField("UCU install", EditorStyles.boldLabel);
            EditorGUILayout.BeginHorizontal();
            var folder = EditorGUILayout.DelayedTextField(new GUIContent("UCU install folder", "The folder with UCU's BattleTech.exe. Kept on this computer only (Unity's EditorPrefs), not in the project."), TestMap.InstallFolder);
            if (folder != TestMap.InstallFolder) TestMap.InstallFolder = folder;
            if (GUILayout.Button("Browse…", GUILayout.Width(80)))
            {
                var picked = EditorUtility.OpenFolderPanel("UCU install folder", TestMap.InstallFolder, "");
                if (!string.IsNullOrEmpty(picked)) TestMap.InstallFolder = picked.Replace('/', Path.DirectorySeparatorChar);
            }
            EditorGUILayout.EndHorizontal();
            var exeFound = !string.IsNullOrEmpty(TestMap.InstallFolder) && File.Exists(Path.Combine(TestMap.InstallFolder, TestMap.Exe));
            EditorGUILayout.LabelField(" ", string.IsNullOrEmpty(TestMap.InstallFolder) ? "Not set." : exeFound ? $"{TestMap.Exe} found." : $"No {TestMap.Exe} in this folder.", EditorStyles.miniLabel);

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Lighting", EditorStyles.boldLabel);
            var terrain = Terrain.activeTerrain;
            if (terrain == null)
                EditorGUILayout.HelpBox(MapPreconditions.NoTerrain, MessageType.Info);
            else
            {
                var est = MapBake.Estimate(terrain);
                EditorGUILayout.LabelField(new GUIContent("Estimate", "Texels from the terrain size at the kit's realtime resolution (0.0625), bytes from the kit's measured bake. Retail: taigaRiver's terrain lighting, scaled by area."),
                    new GUIContent($"{est.texels:N0} texels, about {est.estimateBytes / 1e6:F2} MB; retail {est.retailBytes / 1e6:F2} MB ({est.Ratio:F2}x)"));
                if (est.unprepared != null) EditorGUILayout.HelpBox(est.unprepared, MessageType.Warning);
                string why = "";
                bool stale = !string.IsNullOrEmpty(scene.path) && MapBake.IsStale(scene, out why);
                EditorGUILayout.LabelField("Lighting data", string.IsNullOrEmpty(scene.path) ? "Save the scene first." : (stale ? "Needs a bake: " : "Up to date: ") + why, EditorStyles.wordWrappedLabel);
                using (new EditorGUI.DisabledScope(MapBake.State == BakeState.Running || string.IsNullOrEmpty(scene.path)))
                    if (GUILayout.Button(new GUIContent("Bake lighting", "Bakes the map's realtime lighting with retail-sized settings, then saves the scene once. Refuses to start past 2x retail's size.")))
                        TryRun(() => MapBake.Start());
                if (MapBake.State != BakeState.Idle)
                    EditorGUILayout.HelpBox($"{MapBake.State}: {MapBake.Message}", MapBake.State == BakeState.Failed || MapBake.State == BakeState.TooLarge ? MessageType.Error : MapBake.State == BakeState.NotPrepared ? MessageType.Warning : MessageType.Info);
            }

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Test map", EditorStyles.boldLabel);
            EditorGUILayout.LabelField("Checks, exports, bakes if needed, builds the mod, installs it and the MapKitLoader mod into the UCU install, and starts UCU.", EditorStyles.wordWrappedMiniLabel);
            var r = TestMap.Current;
            using (new EditorGUI.DisabledScope((r != null && r.running) || MapBake.State == BakeState.Running))
                if (GUILayout.Button("Test map in UCU"))
                    TryRun(() => TestMap.Run());
            if (r != null)
            {
                foreach (var s in r.steps) EditorGUILayout.LabelField("Done: " + s, EditorStyles.wordWrappedMiniLabel);
                if (r.running) EditorGUILayout.LabelField("… running", EditorStyles.miniLabel);
                if (r.failedStep != null) EditorGUILayout.HelpBox($"Stopped at step {r.failedStep}: {r.error}", MessageType.Error);
                else if (r.Succeeded) EditorGUILayout.HelpBox($"{r.map} is installed in {Path.Combine(r.install, "Mods", r.map)} and UCU was started with -ucuMap {r.map}: the map starts by itself (Skirmish, the map, Play, BEGIN MISSION). By hand: BattleTech.exe -ucuMap {r.map}.", MessageType.Info);
            }
            EditorGUILayout.EndScrollView();
        }

        void TryRun(System.Action a)
        {
            try { a(); }
            catch (System.Exception e) { Debug.LogWarning("UCU Map Kit: " + e.Message); }
        }

        void Rebuild()
        {
            if (list == null) return;
            list.Clear();
            if (entries == null)
            {
                summary.text = "Not checked yet: press Check map.";
                return;
            }
            int errors = entries.Count(e => e.severity == MapCheckSeverity.Error), warnings = entries.Count - errors;
            summary.text = entries.Count == 0
                ? $"{checkedScene}: no problems found (0 entries)."
                : $"{checkedScene}: {Count(errors, "error")}, {Count(warnings, "warning")}.";
            // Map Check itself changes nothing in the scene (map-kit KFIX7 D12); a Fix does, and Build Mod refuses an unsaved scene.
            if (!SceneManager.GetActiveScene().isDirty) fixedSinceSave = false;
            else summary.text += " The scene has unsaved changes" + (fixedSinceSave ? " (a Fix changed it)" : "") + ": save it (File > Save) before Build Mod.";
            foreach (var e in entries)
                list.Add(Row(e, RunCheck));
        }

        static string Count(int n, string word) => $"{n} {word}{(n == 1 ? "" : "s")}";

        static VisualElement Row(MapCheckEntry e, System.Action recheck)
        {
            var row = new VisualElement { style = { flexDirection = FlexDirection.Row, alignItems = Align.FlexStart, paddingTop = 3, paddingBottom = 3 } };
            row.style.borderBottomWidth = 1;
            row.style.borderBottomColor = new Color(0.5f, 0.5f, 0.5f, 0.3f);
            row.tooltip = string.IsNullOrEmpty(e.detail) ? e.message : e.detail;

            var icon = new Image { image = EditorGUIUtility.IconContent(e.severity == MapCheckSeverity.Error ? "console.erroricon.sml" : "console.warnicon.sml").image };
            icon.style.width = icon.style.height = 16;
            icon.style.flexShrink = 0;
            row.Add(icon);
            var word = new Label(e.severity == MapCheckSeverity.Error ? "Error" : "Warning") { style = { width = 58, flexShrink = 0, unityFontStyleAndWeight = FontStyle.Bold } };
            row.Add(word);

            var text = new VisualElement { style = { flexGrow = 1, flexShrink = 1 } };
            text.Add(new Label(e.message) { style = { whiteSpace = WhiteSpace.Normal } });
            var obj = new Label(e.TargetName) { style = { whiteSpace = WhiteSpace.Normal, fontSize = 10, color = new Color(0.6f, 0.6f, 0.6f) } };
            text.Add(obj);
            row.Add(text);

            var select = new Button(() => Select(e.target)) { text = "Select", tooltip = e.target == null ? "This entry has no object to select." : $"Select and frame {e.TargetName}." };
            select.style.flexShrink = 0;
            select.SetEnabled(e.target != null);
            row.Add(select);
            if (e.fix != null)
            {
                var fix = new Button(() => { e.fix(); fixedSinceSave = true; recheck(); }) { text = "Fix", name = "fix", tooltip = e.fixTip + " Save the scene afterwards: Build Mod needs it saved." };
                fix.style.flexShrink = 0;
                row.Add(fix);
            }
            return row;
        }

        public static void Select(Object target)
        {
            if (target == null) return;
            var go = target is Component c ? c.gameObject : target as GameObject;
            Selection.activeObject = go != null ? go : target;
            EditorGUIUtility.PingObject(Selection.activeObject);
            if (go != null && SceneView.lastActiveSceneView != null)
                SceneView.lastActiveSceneView.FrameSelected();
        }
    }
}
