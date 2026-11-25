// UCU Map Kit: the Objects palette (map-kit plan U8; design-v2 row "6 Objects"; D-U1 = a: template and extracted maps alike;
// D-U3 = a: the props are the Build Object Library's prefabs under Assets/MapKitLibrary). Menu UCU Map Kit/Objects…, and the
// Objects mode of the Scene-view overlay opens it.
// - Lists the library's prefabs by kind (Rocks, Structures, Water, Decals, Lights), taken from the GAME/Parent_* container the
//   object stood in on its retail map, with AssetPreview thumbnails (they load asynchronously), a search box and pages.
// - Drag a tile into the Scene view (it lands on the surface under the cursor), or select a tile and click in the Scene view to
//   place it again and again (Esc or the tile again stops).
// - Each placement is one Undo step: a prefab instance under GAME/<its kind's container> of the open map (made when missing),
//   with new encounter GUIDs (each placed building is its own Building in the game), and optional random rotation and scale.
// Kinds: the library records each object's renderers but not its container (ObjectLibrary.cs writes no container), so the palette
// reads them from a split map once (Read kinds from this map) and keeps them in Records/kinds.tsv.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UIElements;

namespace UCU.MapKit
{
    public enum ObjectKind { All, Rocks, Structures, Water, Decals, Lights }

    public class PaletteEntry
    {
        public string path, name, container;
        public ObjectKind kind;   // All = no kind recorded
        public GameObject Prefab => AssetDatabase.LoadAssetAtPath<GameObject>(path);
    }

    [InitializeOnLoad]
    public class ObjectPalette : EditorWindow
    {
        public const string PrefabRoot = ObjectLibrary.LibraryRoot + "/Prefabs";
        public const string MeshRoot = ObjectLibrary.LibraryRoot + "/Meshes";
        public const string KindsRecord = ObjectLibrary.LibraryRoot + "/Records/kinds.tsv";
        public const string GameRoot = "GAME";
        public const int PageSize = 24;
        public const float ScaleMin = 0.8f, ScaleMax = 1.2f;
        const string DragKey = "UCU.MapKit.PalettePrefab";
        const string RotKey = "UCU.MapKit.Objects.RandomRotation", ScaleKey = "UCU.MapKit.Objects.RandomScale";

        // retail container -> kind; the first container of a kind is where the palette places it (K1 inventory, 13 containers).
        // Urban maps keep their buildings, ramps and seam covers outside GAME, under the root OBJECTS/<district> (capitolHill:
        // 582 of 583 buildings), and their plot buildings under PlotParent; both count as Structures, and a placed one goes to
        // GAME/Parent_Structures, outside any plot variant.
        static readonly (string container, ObjectKind kind)[] Containers =
        {
            ("Parent_Placed_Rock_Geo", ObjectKind.Rocks), ("Parent_Stamp_Rocks", ObjectKind.Rocks),
            ("Parent_Structures", ObjectKind.Structures), ("PlotParent", ObjectKind.Structures), ("OBJECTS", ObjectKind.Structures),
            ("Parent_Water", ObjectKind.Water), ("Parent_Decals", ObjectKind.Decals), ("Parent_Lights", ObjectKind.Lights),
        };

        public static bool RandomRotation { get => EditorPrefs.GetBool(RotKey, false); set => EditorPrefs.SetBool(RotKey, value); }
        public static bool RandomScale { get => EditorPrefs.GetBool(ScaleKey, false); set => EditorPrefs.SetBool(ScaleKey, value); }
        /// <summary>The prefab the Scene view places on a click, or null.</summary>
        public static string Armed { get; private set; }

        static ObjectPalette()
        {
            SceneView.duringSceneGui += OnSceneGUI;
            KitModes.Changed += () => { if (KitModes.Current == KitMode.Objects) Open(); };
        }

        [MenuItem("UCU Map Kit/Objects…")]
        public static ObjectPalette Open()
        {
            var w = GetWindow<ObjectPalette>("Objects");
            w.minSize = new Vector2(420f, 320f);
            w.Reload();
            return w;
        }

        // ------------------------------------------------------------------ the library and its kinds
        public static ObjectKind KindOf(string container) => Containers.FirstOrDefault(c => c.container == container).kind;

        public static string ContainerFor(PaletteEntry e) =>
            e.kind != ObjectKind.All ? Containers.First(c => c.kind == e.kind).container : e.container;

        public static Dictionary<string, string> ReadKinds()
        {
            var d = new Dictionary<string, string>();
            if (File.Exists(KindsRecord))
                foreach (var f in File.ReadAllLines(KindsRecord).Select(l => l.Split('\t')).Where(f => f.Length >= 2))
                    d[f[0]] = f[1];
            return d;
        }

        public static List<PaletteEntry> LoadEntries()
        {
            var kinds = ReadKinds();
            if (!AssetDatabase.IsValidFolder(PrefabRoot)) return new List<PaletteEntry>();
            return AssetDatabase.FindAssets("t:Prefab", new[] { PrefabRoot }).Select(AssetDatabase.GUIDToAssetPath).Select(p =>
            {
                kinds.TryGetValue(p, out var c);
                return new PaletteEntry { path = p, name = Path.GetFileNameWithoutExtension(p), container = c, kind = c == null ? ObjectKind.All : KindOf(c) };
            }).OrderBy(e => e.name, StringComparer.OrdinalIgnoreCase).ToList();
        }

        /// <summary>The entries a kind and a search show, in list order.</summary>
        public static List<PaletteEntry> Filter(List<PaletteEntry> all, ObjectKind kind, string search) =>
            all.Where(e => (kind == ObjectKind.All || e.kind == kind) &&
                           (string.IsNullOrEmpty(search) || e.name.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0)).ToList();

        // An object's library meshes, sorted: the same on a split map's object and on the prefab made from it (ObjectLibrary.Build
        // points both at the same mesh assets).
        static string Signature(GameObject root) =>
            string.Join(",", root.GetComponentsInChildren<MeshFilter>(true).Select(f => AssetDatabase.GetAssetPath(f.sharedMesh))
                .Where(p => p.StartsWith(MeshRoot + "/")).Select(AssetDatabase.AssetPathToGUID).OrderBy(g => g));

        // the nearest GAME/Parent_* or PlotParent above the object, else its scene root (an urban map's OBJECTS)
        static string SourceContainer(Transform t)
        {
            for (var p = t.parent; p != null; p = p.parent)
                if (p.name.StartsWith("Parent_") || p.name == "PlotParent") return p.name;
            return t.root == t ? null : t.root.name;
        }

        /// <summary>Reads the container of every library object on a split map (one Build Object Library has run on it) into
        /// Records/kinds.tsv. Rows from other maps are kept; a prefab seen in two containers takes the one most of its objects use.</summary>
        public static string ReadKindsFrom(Scene scene)
        {
            if (!scene.IsValid() || !File.Exists(ObjectLibrary.RecordPath(scene)))
                return $"{scene.name} has no Build Object Library record: run UCU Map Kit/Setup/Build Object Library… on it first.";
            var bySig = new Dictionary<string, Dictionary<string, int>>();
            var roots = new HashSet<Transform>();
            foreach (var f in scene.GetRootGameObjects().SelectMany(g => g.GetComponentsInChildren<MeshFilter>(true)))
                if (AssetDatabase.GetAssetPath(f.sharedMesh).StartsWith(MeshRoot + "/")) roots.Add(ObjectLibrary.ObjectRoot(f.transform));
            foreach (var r in roots)
            {
                var c = SourceContainer(r) ?? "(none)";
                var sig = Signature(r.gameObject);
                if (!bySig.TryGetValue(sig, out var n)) bySig[sig] = n = new Dictionary<string, int>();
                n.TryGetValue(c, out var k); n[c] = k + 1;
            }
            var kinds = ReadKinds();
            int matched = 0, unmatched = 0;
            foreach (var p in AssetDatabase.FindAssets("t:Prefab", new[] { PrefabRoot }).Select(AssetDatabase.GUIDToAssetPath))
            {
                var prefab = AssetDatabase.LoadAssetAtPath<GameObject>(p);
                if (prefab == null || !bySig.TryGetValue(Signature(prefab), out var n)) { unmatched++; continue; }
                kinds[p] = n.OrderByDescending(x => x.Value).First().Key;
                matched++;
            }
            Directory.CreateDirectory(Path.GetDirectoryName(KindsRecord));
            File.WriteAllLines(KindsRecord, kinds.OrderBy(k => k.Key).Select(k => $"{k.Key}\t{k.Value}"));
            AssetDatabase.ImportAsset(KindsRecord);
            var counts = kinds.Values.GroupBy(KindOf).OrderBy(g => g.Key).Select(g => $"{(g.Key == ObjectKind.All ? "no kind" : g.Key.ToString())} {g.Count()}");
            return $"{scene.name}: {roots.Count} library objects; {matched} prefabs got their container from this map, {unmatched} come from other maps. Record: {string.Join(", ", counts)}.";
        }

        // ------------------------------------------------------------------ placement (the window, the Scene view and the agent route)
        /// <summary>GAME/<container> in the scene, made (with Undo) when missing.</summary>
        static Transform Container(Scene scene, string container)
        {
            var game = scene.GetRootGameObjects().FirstOrDefault(g => g.name == GameRoot);
            if (game == null)
            {
                game = new GameObject(GameRoot);
                SceneManager.MoveGameObjectToScene(game, scene);
                Undo.RegisterCreatedObjectUndo(game, "Create " + GameRoot);
            }
            if (string.IsNullOrEmpty(container)) return game.transform;
            var c = game.transform.Find(container);
            if (c != null) return c;
            var go = new GameObject(container);
            go.transform.SetParent(game.transform, false);
            Undo.RegisterCreatedObjectUndo(go, "Create " + container);
            return go.transform;
        }

        /// <summary>One Undo step: an instance of the entry's prefab at a world position, under its kind's container, with new
        /// encounter GUIDs, upright, turned by yaw degrees and scaled uniformly.</summary>
        public static GameObject Place(PaletteEntry e, Vector3 position, float yaw, float scale)
        {
            var prefab = e.Prefab;
            var scene = SceneManager.GetActiveScene();
            if (prefab == null || !scene.IsValid()) return null;
            Undo.IncrementCurrentGroup();
            int group = Undo.GetCurrentGroup();
            Undo.SetCurrentGroupName("Place " + e.name);
            var parent = Container(scene, ContainerFor(e));
            var go = (GameObject)PrefabUtility.InstantiatePrefab(prefab, parent);
            go.transform.SetPositionAndRotation(position, Quaternion.Euler(0f, yaw, 0f));
            go.transform.localScale = prefab.transform.localScale * scale;
            PrefabUtility.RecordPrefabInstancePropertyModifications(go.transform);
            // The prefab carries the GUIDs of the object it was cut from; two placed copies with one GUID would be one Building.
            foreach (var l in go.GetComponentsInChildren<EncounterObjectGameLogic>(true))
            {
                l.GenerateNewGuid();
                PrefabUtility.RecordPrefabInstancePropertyModifications(l);
            }
            Undo.RegisterCreatedObjectUndo(go, "Place " + e.name);
            Undo.CollapseUndoOperations(group);
            Undo.IncrementCurrentGroup();
            return go;
        }

        public static GameObject PlaceWithToggles(PaletteEntry e, Vector3 position) =>
            Place(e, position, RandomRotation ? UnityEngine.Random.Range(0f, 360f) : 0f, RandomScale ? UnityEngine.Random.Range(ScaleMin, ScaleMax) : 1f);

        /// <summary>The surface below a point: the highest collider hit straight down, else the active terrain's height.</summary>
        public static bool Ground(Vector3 at, out Vector3 hit)
        {
            hit = at;
            var hits = Physics.RaycastAll(new Vector3(at.x, 5000f, at.z), Vector3.down, 10000f);
            if (hits.Length > 0) { hit = hits.OrderByDescending(h => h.point.y).First().point; return true; }
            var t = Terrain.activeTerrain;
            if (t == null) return false;
            hit.y = t.SampleHeight(at) + t.transform.position.y;
            return true;
        }

        /// <summary>The agent route of a drag or a click: the entry placed on the surface below a world x, z.</summary>
        public static GameObject PlaceAt(string prefabPath, Vector3 at)
        {
            var e = LoadEntries().FirstOrDefault(x => x.path == prefabPath);
            return e != null && Ground(at, out var p) ? PlaceWithToggles(e, p) : null;
        }

        static PaletteEntry EntryAt(string path) => LoadEntries().FirstOrDefault(x => x.path == path);

        public static void Arm(string path) { Armed = path; SceneView.RepaintAll(); foreach (var w in Resources.FindObjectsOfTypeAll<ObjectPalette>()) w.Refresh(); }

        static void OnSceneGUI(SceneView view)
        {
            var e = Event.current;
            var dragged = DragAndDrop.GetGenericData(DragKey) as string;
            if (dragged != null && (e.type == EventType.DragUpdated || e.type == EventType.DragPerform))
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                if (e.type == EventType.DragPerform)
                {
                    DragAndDrop.AcceptDrag();
                    var entry = EntryAt(dragged);
                    if (entry != null && HandleUtility.PlaceObject(e.mousePosition, out var pos, out _)) PlaceWithToggles(entry, pos);
                    DragAndDrop.SetGenericData(DragKey, null);
                }
                e.Use();
                return;
            }
            if (Armed == null) return;
            if (e.type == EventType.Layout) HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
            if (e.type == EventType.KeyDown && e.keyCode == KeyCode.Escape) { Arm(null); e.Use(); return; }
            if (e.type == EventType.MouseDown && e.button == 0 && !e.alt)
            {
                var entry = EntryAt(Armed);
                if (entry != null && HandleUtility.PlaceObject(e.mousePosition, out var pos, out _)) PlaceWithToggles(entry, pos);
                e.Use();
            }
        }

        // ------------------------------------------------------------------ the window
        List<PaletteEntry> all = new List<PaletteEntry>();
        [SerializeField] ObjectKind kind = ObjectKind.All;
        [SerializeField] string search = "";
        [SerializeField] int page;
        VisualElement grid, kinds;
        Label status, pageLabel;
        readonly Dictionary<string, Image> thumbs = new Dictionary<string, Image>();

        public ObjectKind Kind => kind;
        public string Search => search;
        public int Page => page;
        public int PageCount => Math.Max(1, (Shown().Count + PageSize - 1) / PageSize);
        public List<PaletteEntry> Shown() => Filter(all, kind, search);
        public List<PaletteEntry> PageEntries() => Shown().Skip(page * PageSize).Take(PageSize).ToList();
        /// <summary>The tiles drawn now, by prefab path, with whether the thumbnail has arrived.</summary>
        public Dictionary<string, bool> Tiles() => thumbs.ToDictionary(t => t.Key, t => t.Value.image != null);

        public void Reload() { all = LoadEntries(); page = Mathf.Clamp(page, 0, PageCount - 1); Refresh(); }
        public void SetKind(ObjectKind k) { kind = k; page = 0; Refresh(); }
        public void SetSearch(string s) { search = s ?? ""; page = 0; var f = rootVisualElement.Q<ToolbarSearchField>("search"); f?.SetValueWithoutNotify(search); Refresh(); }
        public void SetPage(int p) { page = Mathf.Clamp(p, 0, PageCount - 1); Refresh(); }

        void CreateGUI()
        {
            var root = rootVisualElement;
            var bar = new Toolbar();
            var field = new ToolbarSearchField { name = "search", tooltip = "Show the objects whose name contains this text." };
            field.SetValueWithoutNotify(search);
            field.RegisterValueChangedCallback(ev => { search = ev.newValue; page = 0; Refresh(); });
            field.style.flexGrow = 1;
            bar.Add(field);
            var rot = new ToolbarToggle { text = "Random rotation", name = "random-rotation", value = RandomRotation, tooltip = "Turn each placed object to a random facing." };
            rot.RegisterValueChangedCallback(ev => RandomRotation = ev.newValue);
            var scl = new ToolbarToggle { text = "Random scale", name = "random-scale", value = RandomScale, tooltip = $"Scale each placed object by a random factor from {ScaleMin} to {ScaleMax}." };
            scl.RegisterValueChangedCallback(ev => RandomScale = ev.newValue);
            bar.Add(rot); bar.Add(scl);
            root.Add(bar);
            kinds = new VisualElement { name = "kinds", style = { flexDirection = FlexDirection.Row, flexWrap = Wrap.Wrap } };
            root.Add(kinds);
            grid = new VisualElement { name = "grid", style = { flexDirection = FlexDirection.Row, flexWrap = Wrap.Wrap } };
            var scroll = new ScrollView(ScrollViewMode.Vertical) { style = { flexGrow = 1 } };
            scroll.Add(grid);
            root.Add(scroll);
            var pager = new VisualElement { style = { flexDirection = FlexDirection.Row, alignItems = Align.Center } };
            pager.Add(new Button(() => SetPage(page - 1)) { text = "◀ Previous", name = "prev" });
            pageLabel = new Label { name = "page", style = { flexGrow = 1, unityTextAlign = TextAnchor.MiddleCenter } };
            pager.Add(pageLabel);
            pager.Add(new Button(() => SetPage(page + 1)) { text = "Next ▶", name = "next" });
            root.Add(pager);
            var read = new Button(() => { Debug.Log("UCU Map Kit: " + ReadKindsFrom(SceneManager.GetActiveScene())); Reload(); })
                { text = "Read kinds from this map", name = "read-kinds", tooltip = "Record which GAME/Parent_* container each library object stands in on the open map (a map Build Object Library has split)." };
            root.Add(read);
            status = new Label { name = "status", style = { whiteSpace = WhiteSpace.Normal, fontSize = 10, color = new Color(0.65f, 0.65f, 0.65f) } };
            root.Add(status);
            root.schedule.Execute(UpdateThumbs).Every(250);
            Reload();
        }

        void OnDestroy() { if (Armed != null) Arm(null); }

        public void Refresh()
        {
            if (grid == null) return;
            kinds.Clear();
            foreach (ObjectKind k in Enum.GetValues(typeof(ObjectKind)))
            {
                var kk = k;
                int n = k == ObjectKind.All ? all.Count : all.Count(e => e.kind == k);
                var b = new Button(() => SetKind(kk)) { text = $"{k} ({n})", name = "kind-" + k };
                if (k == kind) b.style.unityFontStyleAndWeight = FontStyle.Bold;
                kinds.Add(b);
            }
            grid.Clear(); thumbs.Clear();
            foreach (var e in PageEntries()) grid.Add(Tile(e));
            var shown = Shown().Count;
            pageLabel.text = $"Page {page + 1} of {PageCount} ({shown} objects)";
            int unread = all.Count(e => e.container == null), other = all.Count(e => e.container != null && e.kind == ObjectKind.All);
            status.text = all.Count == 0
                ? $"No objects in {PrefabRoot}. Open an extracted retail map and run UCU Map Kit/Setup/Build Object Library… first."
                : (Armed != null ? $"Placing {Path.GetFileNameWithoutExtension(Armed)}: click in the Scene view; Esc or the tile again stops. " : "Drag a tile into the Scene view, or select it and click in the Scene view. ")
                  + (unread > 0 ? $"{unread} objects have no kind yet: open the map they came from and press Read kinds. " : "")
                  + (other > 0 ? $"{other} come from other containers (stamps, ground plates, skirts, trees) and are listed under All only." : "");
            UpdateThumbs();
        }

        VisualElement Tile(PaletteEntry e)
        {
            bool on = Armed == e.path;
            var tile = new Button(() => Arm(on ? null : e.path))
            {
                name = "tile", tooltip = $"{e.name}\n{(e.kind == ObjectKind.All ? "no kind" : e.kind.ToString())}, from {e.container ?? "an unread map"}; placed under {GameRoot}/{ContainerFor(e) ?? ""}",
                style = { width = 96, height = 116, flexDirection = FlexDirection.Column, alignItems = Align.Center, paddingLeft = 2, paddingRight = 2 }
            };
            if (on) { tile.style.borderBottomWidth = 3; tile.style.borderBottomColor = new Color(0.24f, 0.49f, 0.9f); }
            var img = new Image { scaleMode = ScaleMode.ScaleToFit, style = { width = 88, height = 88 } };
            thumbs[e.path] = img;
            tile.Add(img);
            tile.Add(new Label(e.name) { style = { fontSize = 9, whiteSpace = WhiteSpace.NoWrap, overflow = Overflow.Hidden, textOverflow = TextOverflow.Ellipsis, maxWidth = 92 } });   // the whole name is in the tooltip
            tile.RegisterCallback<PointerMoveEvent>(ev =>
            {
                if ((ev.pressedButtons & 1) == 0 || DragAndDrop.GetGenericData(DragKey) != null) return;
                DragAndDrop.PrepareStartDrag();
                DragAndDrop.objectReferences = new UnityEngine.Object[0];   // only the palette's own handler places it
                DragAndDrop.SetGenericData(DragKey, e.path);
                DragAndDrop.StartDrag(e.name);
            });
            return tile;
        }

        void UpdateThumbs()
        {
            foreach (var kv in thumbs)
                if (kv.Value.image == null)
                {
                    var p = AssetDatabase.LoadAssetAtPath<GameObject>(kv.Key);
                    var t = p == null ? null : AssetPreview.GetAssetPreview(p);
                    if (t != null) kv.Value.image = t;
                }
        }
    }
}
