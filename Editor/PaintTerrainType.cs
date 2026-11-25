// UCU Map Kit: Paint Terrain Type (design-v2 § 3 rows 2, 2b and 7, § 5 U5; map-kit plan U5). A terrain paint tool in the
// terrain inspector's paint dropdown that paints the gameplay types into SplatMapInfo's mask textures with Unity's own
// brushes, size and strength, plus two helpers that derive types from the map (Forest from trees, Water below height).
// - A painted pixel is written 255 and a cleared one 0, never a value in between: the exporter marks a pixel whose
//   grayscale is above SplatMapInfo.ValueThreshold (0), so any grey would mark it too. The brush's falloff therefore sets
//   the painted shape, not a shade: a pixel is painted where brush value > 0 and brush value >= 1 - strength. At full
//   strength that is the whole brush disc Unity previews; a lower strength paints a smaller core of it.
// - Painting a type adds it to its own mask and leaves the others; where types overlap, the game keeps one (the legend's
//   order, MapMetaData.GetPriorityTerrainMaskFlags). Clear removes every type.
// - Each stroke and each helper is one Undo step: Undo.RegisterCompleteObjectUndo on each mask texture it changes, before
//   the first change. The step is collapsed only after the last change: collapsing between the record and the change made
//   Redo restore the state from before the change (measured: U5).
// - The masks are imported PNGs, so the change lives in the loaded textures until the scene is saved: then each changed
//   mask is written back to its PNG (delete, then write) and reimported, with its import settings untouched.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEditor.ShortcutManagement;
using UnityEditor.TerrainTools;
using UnityEngine;
using UnityEngine.TerrainTools;

namespace UCU.MapKit
{
    public enum PaintType { Water, DeepWater, Forest, Rough, Road, Impassable, Custom, Clear }

    /// <summary>The mask writes shared by the paint tool, its helpers and Map Check's Fix: strokes, helpers, undo and save.</summary>
    public static class TerrainTypePaint
    {
        public const string UndoPrefix = "Paint Terrain Type";
        public const string ForestFromTreesName = "Forest from trees";
        public const string WaterBelowHeightName = "Water below height";
        const string PendingKey = "UCU.MapKit.PendingMasks";

        public static readonly PaintType[] Types = (PaintType[])Enum.GetValues(typeof(PaintType));

        public static string Label(PaintType t) => t == PaintType.DeepWater ? "Deep water" : t.ToString();

        public static string UndoName(string what) => $"{UndoPrefix} ({what})";

        public static Texture2D Mask(SplatMapInfo s, PaintType t)
        {
            switch (t)
            {
                case PaintType.Water: return s.waterMask;
                case PaintType.DeepWater: return s.deepWaterMask;
                case PaintType.Forest: return s.forestMask;
                case PaintType.Rough: return s.roughMask;
                case PaintType.Road: return s.roadMask;
                case PaintType.Impassable: return s.impassableMask;
                case PaintType.Custom: return s.customMask;
                default: return null;
            }
        }

        /// <summary>The masks a type writes: its own, or all seven for Clear.</summary>
        public static Texture2D[] Targets(SplatMapInfo s, PaintType t) =>
            t == PaintType.Clear ? Types.Where(x => x != PaintType.Clear).Select(x => Mask(s, x)).ToArray() : new[] { Mask(s, t) };

        /// <summary>Why the open map cannot be painted, or null when it can.</summary>
        public static string Problem(Terrain terrain, out SplatMapInfo splat)
        {
            splat = terrain != null ? terrain.GetComponent<SplatMapInfo>() : null;
            if (terrain == null) return "Select a map terrain to paint its terrain types.";
            if (splat == null) return $"{terrain.name} has no SplatMapInfo, so it has no terrain-type masks. Run Map Check.";
            var masks = Targets(splat, PaintType.Clear);
            if (masks.Any(m => m == null || !m.isReadable)) return "A terrain-type mask is missing or not readable: run Map Check (UCU Map Kit/Map Check) for which one.";
            if (masks.Any(m => m.width != masks[0].width || m.height != masks[0].height)) return "The seven masks differ in size: run Map Check.";
            return null;
        }

        // ---- Strokes -------------------------------------------------------------------------------------------------

        static SplatMapInfo strokeSplat;
        static PaintType strokeType;
        static int strokeGroup = -1;
        static readonly HashSet<Texture2D> strokeRegistered = new HashSet<Texture2D>();

        public static bool InStroke => strokeGroup >= 0;
        public static int LastStrokePixels { get; private set; }

        /// <summary>Starts one Undo step. Every dab until EndStroke belongs to it.</summary>
        public static void BeginStroke(SplatMapInfo splat, PaintType type)
        {
            EndStroke();
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName(UndoName(Label(type)));
            strokeGroup = Undo.GetCurrentGroup();
            strokeSplat = splat;
            strokeType = type;
            strokeRegistered.Clear();
            LastStrokePixels = 0;
        }

        /// <summary>One brush stamp at terrain UV <paramref name="uv"/>, as the terrain inspector passes it to OnPaint.
        /// Returns the number of mask pixels it changed.</summary>
        public static int Dab(Terrain terrain, Vector2 uv, Texture brush, float size, float strength)
        {
            if (!InStroke || strokeSplat == null || brush == null) return 0;
            ReadBrush(brush);
            var targets = Targets(strokeSplat, strokeType);
            int w = targets[0].width, h = targets[0].height;
            // The brush transform's target space is the terrain's local space in metres (measured: U5 probe, bounds 604..644
            // for a 40 m brush at uv 0.3047 on a 2048 m terrain), not terrain UV.
            var xf = TerrainPaintUtility.CalculateBrushTransform(terrain, uv, size, 0f);
            var b = xf.GetBrushXYBounds();
            var tsize = terrain.terrainData.size;
            float mx = tsize.x / w, mz = tsize.z / h; // metres per mask pixel
            int x0 = Mathf.Clamp(Mathf.FloorToInt(b.xMin / mx), 0, w - 1), x1 = Mathf.Clamp(Mathf.CeilToInt(b.xMax / mx), 0, w - 1);
            int z0 = Mathf.Clamp(Mathf.FloorToInt(b.yMin / mz), 0, h - 1), z1 = Mathf.Clamp(Mathf.CeilToInt(b.yMax / mz), 0, h - 1);
            int rw = x1 - x0 + 1, rh = z1 - z0 + 1;
            var on = new bool[rw * rh];
            int any = 0;
            for (int z = 0; z < rh; z++)
                for (int x = 0; x < rw; x++)
                {
                    // The mask pixel's centre (SplatMapInfo: pixel p covers p..p+1 mask pixels of the terrain's local space).
                    var buv = xf.ToBrushUV(new Vector2((x0 + x + 0.5f) * mx, (z0 + z + 0.5f) * mz));
                    if (buv.x < 0f || buv.y < 0f || buv.x > 1f || buv.y > 1f) continue;
                    float v = SampleBrush(buv);
                    if (v > 0f && v >= 1f - strength) { on[z * rw + x] = true; any++; }
                }
            if (any == 0) return 0;
            float value = strokeType == PaintType.Clear ? 0f : 1f; // 0 or 255 in the RGB24 mask, never in between
            var write = new Color(value, value, value, 1f);
            int changed = 0;
            foreach (var tex in targets)
            {
                var px = tex.GetPixels(x0, z0, rw, rh); // the exporter reads grayscale; RGB24 has no alpha to keep
                var before = changed;
                for (int i = 0; i < px.Length; i++)
                {
                    if (!on[i]) continue;
                    var c = px[i];
                    if (c.r == value && c.g == value && c.b == value) continue;
                    // Recorded before the first change, so Undo restores the mask as it was when the stroke began.
                    if (strokeRegistered.Add(tex)) Undo.RegisterCompleteObjectUndo(tex, UndoName(Label(strokeType)));
                    px[i] = write;
                    changed++;
                }
                if (changed == before) continue;
                tex.SetPixels(x0, z0, rw, rh, px);
                tex.Apply(false);
            }
            LastStrokePixels += changed;
            return changed;
        }

        /// <summary>Closes the Undo step and, when it changed a mask, marks the masks for saving and the overlay stale.</summary>
        public static void EndStroke()
        {
            if (!InStroke) return;
            Undo.CollapseUndoOperations(strokeGroup);
            strokeGroup = -1;
            if (strokeRegistered.Count > 0) MarkChanged(strokeRegistered);
            strokeRegistered.Clear();
            strokeSplat = null;
        }

        // Unity's brush (Brush.texture, an R16 mask with the falloff in it) read once per brush version.
        static float[] brushPx;
        static int brushW, brushH;
        static Texture brushTex;
        static uint brushCount;

        static void ReadBrush(Texture brush)
        {
            if (brush == brushTex && brush.updateCount == brushCount && brushPx != null) return;
            brushW = brush.width;
            brushH = brush.height;
            var rt = RenderTexture.GetTemporary(brushW, brushH, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
            var prev = RenderTexture.active;
            Graphics.Blit(brush, rt);
            RenderTexture.active = rt;
            var t = new Texture2D(brushW, brushH, TextureFormat.RGBAFloat, false, true);
            t.ReadPixels(new Rect(0, 0, brushW, brushH), 0, 0);
            t.Apply(false);
            RenderTexture.active = prev;
            RenderTexture.ReleaseTemporary(rt);
            brushPx = t.GetPixels().Select(c => c.r).ToArray();
            UnityEngine.Object.DestroyImmediate(t);
            brushTex = brush;
            brushCount = brush.updateCount;
        }

        static float SampleBrush(Vector2 uv)
        {
            float fx = uv.x * brushW - 0.5f, fy = uv.y * brushH - 0.5f;
            int ax = Mathf.Clamp(Mathf.FloorToInt(fx), 0, brushW - 1), ay = Mathf.Clamp(Mathf.FloorToInt(fy), 0, brushH - 1);
            int bx = Mathf.Min(ax + 1, brushW - 1), by = Mathf.Min(ay + 1, brushH - 1);
            float tx = Mathf.Clamp01(fx - ax), ty = Mathf.Clamp01(fy - ay);
            float top = Mathf.Lerp(brushPx[ay * brushW + ax], brushPx[ay * brushW + bx], tx);
            float bottom = Mathf.Lerp(brushPx[by * brushW + ax], brushPx[by * brushW + bx], tx);
            return Mathf.Lerp(top, bottom, ty);
        }

        // ---- Helpers (2b): pixels to paint, previewed first, then applied as one Undo step ----------------------------

        /// <summary>Mask pixels with at least <paramref name="minTrees"/> trees within <paramref name="radius"/> m of their centre.</summary>
        public static bool[] ForestFromTrees(Terrain terrain, SplatMapInfo splat, float radius, int minTrees, out int trees)
        {
            var data = terrain.terrainData;
            var size = data.size;
            int w = splat.forestMask.width, h = splat.forestMask.height;
            float sx = size.x / w, sz = size.z / h;
            var count = new int[w * h];
            var all = data.treeInstances;
            trees = all.Length;
            foreach (var t in all)
            {
                float lx = t.position.x * size.x, lz = t.position.z * size.z;
                int x0 = Mathf.Max(0, Mathf.FloorToInt((lx - radius) / sx)), x1 = Mathf.Min(w - 1, Mathf.FloorToInt((lx + radius) / sx));
                int z0 = Mathf.Max(0, Mathf.FloorToInt((lz - radius) / sz)), z1 = Mathf.Min(h - 1, Mathf.FloorToInt((lz + radius) / sz));
                for (int z = z0; z <= z1; z++)
                    for (int x = x0; x <= x1; x++)
                    {
                        float dx = (x + 0.5f) * sx - lx, dz = (z + 0.5f) * sz - lz;
                        if (dx * dx + dz * dz <= radius * radius) count[z * w + x]++;
                    }
            }
            var on = new bool[w * h];
            for (int i = 0; i < on.Length; i++) on[i] = count[i] >= Mathf.Max(1, minTrees);
            return on;
        }

        /// <summary>Mask pixels whose ground (world Y, at the pixel centre) is below <paramref name="height"/>.</summary>
        public static bool[] WaterBelowHeight(Terrain terrain, SplatMapInfo splat, float height)
        {
            var data = terrain.terrainData;
            int res = data.heightmapResolution, w = splat.waterMask.width, h = splat.waterMask.height;
            var hm = data.GetHeights(0, 0, res, res);
            float oy = terrain.transform.position.y, sy = data.size.y;
            var on = new bool[w * h];
            for (int z = 0; z < h; z++)
            {
                float fz = (z + 0.5f) / h * (res - 1);
                int az = Mathf.Min((int)fz, res - 2);
                float tz = fz - az;
                for (int x = 0; x < w; x++)
                {
                    float fx = (x + 0.5f) / w * (res - 1);
                    int ax = Mathf.Min((int)fx, res - 2);
                    float tx = fx - ax;
                    float v = Mathf.Lerp(Mathf.Lerp(hm[az, ax], hm[az, ax + 1], tx), Mathf.Lerp(hm[az + 1, ax], hm[az + 1, ax + 1], tx), tz);
                    on[z * w + x] = oy + v * sy < height;
                }
            }
            return on;
        }

        /// <summary>How many of <paramref name="on"/>'s pixels are not yet marked in <paramref name="type"/>'s mask.</summary>
        public static int NewPixels(SplatMapInfo splat, PaintType type, bool[] on)
        {
            var px = Mask(splat, type).GetPixels32();
            int n = 0;
            for (int i = 0; i < on.Length; i++) if (on[i] && !(px[i].r == 255 && px[i].g == 255 && px[i].b == 255)) n++;
            return n;
        }

        /// <summary>Writes 255 into <paramref name="type"/>'s mask where <paramref name="on"/> is set, as one Undo step named
        /// after <paramref name="what"/>. Returns the pixels changed.</summary>
        public static int Apply(SplatMapInfo splat, PaintType type, bool[] on, string what)
        {
            var tex = Mask(splat, type);
            var px = tex.GetPixels32();
            var white = new Color32(255, 255, 255, 255);
            int changed = 0;
            for (int i = 0; i < on.Length; i++) if (on[i] && !(px[i].r == 255 && px[i].g == 255 && px[i].b == 255)) changed++;
            if (changed == 0) return 0;
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName(UndoName(what));
            Undo.RegisterCompleteObjectUndo(tex, UndoName(what));
            for (int i = 0; i < on.Length; i++) if (on[i]) px[i] = white;
            tex.SetPixels32(px);
            tex.Apply(false);
            Undo.CollapseUndoOperations(Undo.GetCurrentGroup());
            MarkChanged(new[] { tex });
            return changed;
        }

        /// <summary>Forest from trees with the defaults Map Check's Fix uses: forest within 6 m of every tree (one Undo step).</summary>
        public static int FixTreesOutsideForest(Terrain terrain, SplatMapInfo splat) =>
            Apply(splat, PaintType.Forest, ForestFromTrees(terrain, splat, DefaultTreeRadius, 1, out _), ForestFromTreesName);

        public const float DefaultTreeRadius = 6f;

        // ---- Undo, save ----------------------------------------------------------------------------------------------

        [InitializeOnLoadMethod]
        static void Hook()
        {
            Undo.undoRedoEvent += OnUndoRedo;
            EditorSceneManager.sceneSaving += (scene, path) => WritePending();
            EditorSceneManager.sceneSaved += scene => ImportWritten();
        }

        // An Undo or Redo of one of these steps changes the masks it names back: they need writing again.
        static void OnUndoRedo(in UndoRedoInfo info)
        {
            if (info.undoName == null || !info.undoName.StartsWith(UndoPrefix + " (", StringComparison.Ordinal)) return;
            var splat = Terrain.activeTerrain != null ? Terrain.activeTerrain.GetComponent<SplatMapInfo>() : null;
            if (splat == null) return;
            var what = info.undoName.Substring(UndoPrefix.Length + 2).TrimEnd(')');
            var types = what == ForestFromTreesName ? new[] { PaintType.Forest } : what == WaterBelowHeightName ? new[] { PaintType.Water } : Types.Where(x => Label(x) == what).ToArray();
            if (types.Length > 0) MarkChanged(Targets(splat, types[0]).Where(m => m != null));
        }

        /// <summary>The asset paths of masks changed since they were last written to their PNGs.</summary>
        public static string[] Pending => SessionState.GetString(PendingKey, "").Split(new[] { '\n' }, StringSplitOptions.RemoveEmptyEntries);

        static readonly List<string> written = new List<string>();

        /// <summary>Marks masks changed outside a paint stroke (Roads.cs bake) for writing at the next save.</summary>
        public static void MarkChanged(IEnumerable<Texture2D> masks)
        {
            var paths = new HashSet<string>(Pending);
            foreach (var m in masks) { var p = AssetDatabase.GetAssetPath(m); if (!string.IsNullOrEmpty(p)) paths.Add(p); }
            SessionState.SetString(PendingKey, string.Join("\n", paths.OrderBy(p => p, StringComparer.Ordinal)));
            var t = Terrain.activeTerrain;
            if (t != null) EditorSceneManager.MarkSceneDirty(t.gameObject.scene); // so the scene asks to be saved, and saving writes the masks
            TerrainTypesView.MarkDirty();
        }

        /// <summary>Writes each changed mask back to its PNG (delete, then write). Runs before a scene is saved.</summary>
        public static void WritePending()
        {
            foreach (var path in Pending)
            {
                var tex = AssetDatabase.LoadAssetAtPath<Texture2D>(path);
                if (tex == null || !tex.isReadable) { Debug.LogWarning($"UCU Map Kit: terrain-type mask {path} is missing or not readable; its painting was not written."); continue; }
                var png = tex.EncodeToPNG();
                File.Delete(path);
                File.WriteAllBytes(path, png);
                written.Add(path);
            }
            SessionState.EraseString(PendingKey);
        }

        /// <summary>Reimports the PNGs WritePending wrote, so the asset database matches them. Runs after the scene is saved.</summary>
        public static void ImportWritten()
        {
            var paths = written.ToArray();
            written.Clear();
            foreach (var p in paths) AssetDatabase.ImportAsset(p, ImportAssetOptions.ForceUpdate | ImportAssetOptions.ForceSynchronousImport);
        }

        class SaveProject : AssetModificationProcessor
        {
            // File > Save Project saves no scene; write the masks here and reimport them once the save is done.
            static string[] OnWillSaveAssets(string[] paths)
            {
                if (Pending.Length > 0 && !paths.Any(p => p.EndsWith(".unity", StringComparison.OrdinalIgnoreCase)))
                {
                    WritePending();
                    EditorApplication.delayCall += ImportWritten;
                }
                return paths;
            }
        }
    }

    /// <summary>The Shortcut Manager context of the type shortcuts: active while Paint Terrain Type is the terrain inspector's tool.</summary>
    public class PaintTerrainTypeContext : IShortcutContext
    {
        public bool active => PaintTerrainTypeTool.Shown();
    }

    /// <summary>The tool in the terrain inspector's paint dropdown ("Paint Terrain Type").</summary>
    public class PaintTerrainTypeTool : TerrainPaintTool<PaintTerrainTypeTool>
    {
        public const string ToolName = "Paint Terrain Type";
        const string TypeKey = "UCU.MapKit.PaintType", RadiusKey = "UCU.MapKit.TreeRadius", MinTreesKey = "UCU.MapKit.MinTrees", HeightKey = "UCU.MapKit.WaterHeight";

        public static PaintType Type { get => (PaintType)SessionState.GetInt(TypeKey, (int)PaintType.Forest); set => SessionState.SetInt(TypeKey, (int)value); }
        public static float TreeRadius { get => SessionState.GetFloat(RadiusKey, TerrainTypePaint.DefaultTreeRadius); set => SessionState.SetFloat(RadiusKey, Mathf.Max(0.5f, value)); }
        public static int MinTrees { get => SessionState.GetInt(MinTreesKey, 1); set => SessionState.SetInt(MinTreesKey, Mathf.Max(1, value)); }
        public static float WaterHeight { get => SessionState.GetFloat(HeightKey, float.NaN); set => SessionState.SetFloat(HeightKey, value); }

        /// <summary>The helper whose preview is shown, or null.</summary>
        public static string PreviewOf { get; private set; }

        public override string GetName() => ToolName;

        public override string GetDescription() =>
            "Paint the terrain types the game reads (water, deep water, forest, rough, road, impassable, custom) with Unity's brushes. " +
            "A pixel is painted where the brush reaches, scaled by Opacity; Clear removes every type. Ctrl+Z undoes a stroke. Saving the scene writes the masks.";

        public override void OnEnterToolMode()
        {
            if (KitModes.Current != KitMode.TerrainTypes) KitModes.Set(KitMode.TerrainTypes);
        }

        public override void OnExitToolMode()
        {
            TerrainTypePaint.EndStroke();
            ClearPreview();
        }

        public override void OnRenderBrushPreview(Terrain terrain, IOnSceneGUI editContext)
        {
            if (editContext.hitValidTerrain && editContext.brushTexture != null)
                TerrainPaintUtilityEditor.ShowDefaultPreviewBrush(terrain, editContext.brushTexture, editContext.brushSize);
        }

        public override void OnSceneGUI(Terrain terrain, IOnSceneGUI editContext)
        {
            var e = Event.current;
            if (e.rawType == EventType.MouseUp || e.type == EventType.MouseLeaveWindow) TerrainTypePaint.EndStroke();
        }

        public override bool OnPaint(Terrain terrain, IOnPaint editContext)
        {
            if (TerrainTypePaint.Problem(terrain, out var splat) != null) return false;
            if (Event.current != null && Event.current.type == EventType.MouseDown || !TerrainTypePaint.InStroke)
                TerrainTypePaint.BeginStroke(splat, Type);
            TerrainTypePaint.Dab(terrain, editContext.uv, editContext.brushTexture, editContext.brushSize, editContext.brushStrength);
            return true;
        }

        public override void OnInspectorGUI(Terrain terrain, IOnInspectorGUI editContext)
        {
            var problem = TerrainTypePaint.Problem(terrain, out var splat);
            if (problem != null) { EditorGUILayout.HelpBox(problem, MessageType.Warning); return; }

            EditorGUILayout.LabelField("Terrain type", EditorStyles.boldLabel);
            var labels = TerrainTypePaint.Types.Select(t => new GUIContent(TerrainTypePaint.Label(t), ButtonTip(t))).ToArray();
            var picked = (PaintType)GUILayout.SelectionGrid((int)Type, labels, 4);
            if (picked != Type) Choose(picked);
            EditorGUILayout.HelpBox(Type == PaintType.Clear
                ? "Clear: removes every type where you paint."
                : $"{TerrainTypePaint.Label(Type)}: {TypeTip(Type)} Painting adds it; where types overlap the game keeps one (the order in the Terrain Types legend).", MessageType.None);
            // No brush-asset inspector: on a built-in brush Unity shows "The brush is read-only.", which reads as "you can't paint".
            editContext.ShowBrushesGUI(5, BrushGUIEditFlags.Select | BrushGUIEditFlags.Size | BrushGUIEditFlags.Opacity, splat.Width);

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Derive from the map", EditorStyles.boldLabel);
            EditorGUILayout.LabelField("Each helper shows what it would paint first; Apply paints it (one Undo step).", EditorStyles.wordWrappedMiniLabel);

            EditorGUILayout.LabelField(TerrainTypePaint.ForestFromTreesName, EditorStyles.miniBoldLabel);
            TreeRadius = EditorGUILayout.FloatField(new GUIContent("Within (m)", "Paint forest where enough trees stand within this distance."), TreeRadius);
            MinTrees = EditorGUILayout.IntField(new GUIContent("At least (trees)", "How many trees must stand within that distance."), MinTrees);
            HelperButtons(TerrainTypePaint.ForestFromTreesName, () => PreviewForest(terrain, splat), () => ApplyForest(terrain, splat));

            var (lo, hi) = HeightRange(terrain);
            if (float.IsNaN(WaterHeight)) WaterHeight = lo + 2f;
            EditorGUILayout.LabelField(TerrainTypePaint.WaterBelowHeightName, EditorStyles.miniBoldLabel);
            WaterHeight = EditorGUILayout.FloatField(new GUIContent("Below height (m)", $"Paint water where the ground is lower than this world height. This map's ground runs from {lo:0.#} to {hi:0.#} m."), WaterHeight);
            HelperButtons(TerrainTypePaint.WaterBelowHeightName, () => PreviewWater(terrain, splat), () => ApplyWater(terrain, splat));

            var pending = TerrainTypePaint.Pending.Length;
            if (pending > 0) EditorGUILayout.HelpBox($"{pending} mask(s) painted since the last save. Save the scene (Ctrl+S) to write them.", MessageType.Info);
        }

        static void HelperButtons(string name, Action preview, Action apply)
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                if (GUILayout.Button(new GUIContent("Preview", $"Show in the Scene view where {name} would paint. Nothing is changed."))) preview();
                using (new EditorGUI.DisabledScope(PreviewOf != name))
                    if (GUILayout.Button(new GUIContent("Apply", $"Paint it (one Undo step). Preview first."))) apply();
                using (new EditorGUI.DisabledScope(PreviewOf != name))
                    if (GUILayout.Button(new GUIContent("Cancel", "Hide the preview."))) ClearPreview();
            }
        }

        static string TypeTip(PaintType t) =>
            t == PaintType.Clear ? "Removes every type." : TerrainTypesView.Styles.First(s => s.flag == Flag(t)).help;

        // ---- The eight type shortcuts (Shortcut Manager, under UCU Map Kit) --------------------------------------------
        // Shift+1..8 in the order of the buttons. A plain digit clashes: Unity 6 binds 2 to Scene View/Toggle 2D Mode (and 2 in
        // the Animation window); Alt+1..6 are its Scene view render modes and Alt+Shift+1..5 the kit's mode keys. The only
        // Shift+digit Unity 6 binds is Shift+2 in the Animation window (checked live: U5K). The shortcuts act only while this
        // tool is the terrain inspector's active tool (PaintTerrainTypeContext), so they take no key from another tool.

        const string IdPrefix = "UCU Map Kit/Paint type: ";

        public static string ShortcutId(PaintType t) => IdPrefix + TerrainTypePaint.Label(t);

        /// <summary>The type's binding as the Shortcut Manager has it now (a rebinding shows), or "none".</summary>
        public static string ShortcutText(PaintType t)
        {
            var b = ShortcutManager.instance.GetShortcutBinding(ShortcutId(t));
            return b.keyCombinationSequence.Any() ? b.ToString() : "none";
        }

        /// <summary>A type button's tooltip: what the type is, then its shortcut.</summary>
        public static string ButtonTip(PaintType t) => $"{TypeTip(t)}\nShortcut: {ShortcutText(t)}";

        /// <summary>Picks the type to paint, as clicking its button does, and redraws the terrain inspector to show it.</summary>
        public static void Choose(PaintType t)
        {
            Type = t;
            foreach (var i in Inspectors()) (i as Editor)?.Repaint();
        }

        [InitializeOnLoadMethod]
        static void RegisterContext() => ShortcutManager.RegisterContext(new PaintTerrainTypeContext());

        [Shortcut(IdPrefix + "Water", typeof(PaintTerrainTypeContext), KeyCode.Alpha1, ShortcutModifiers.Shift)] static void KeyWater() => Choose(PaintType.Water);
        [Shortcut(IdPrefix + "Deep water", typeof(PaintTerrainTypeContext), KeyCode.Alpha2, ShortcutModifiers.Shift)] static void KeyDeepWater() => Choose(PaintType.DeepWater);
        [Shortcut(IdPrefix + "Forest", typeof(PaintTerrainTypeContext), KeyCode.Alpha3, ShortcutModifiers.Shift)] static void KeyForest() => Choose(PaintType.Forest);
        [Shortcut(IdPrefix + "Rough", typeof(PaintTerrainTypeContext), KeyCode.Alpha4, ShortcutModifiers.Shift)] static void KeyRough() => Choose(PaintType.Rough);
        [Shortcut(IdPrefix + "Road", typeof(PaintTerrainTypeContext), KeyCode.Alpha5, ShortcutModifiers.Shift)] static void KeyRoad() => Choose(PaintType.Road);
        [Shortcut(IdPrefix + "Impassable", typeof(PaintTerrainTypeContext), KeyCode.Alpha6, ShortcutModifiers.Shift)] static void KeyImpassable() => Choose(PaintType.Impassable);
        [Shortcut(IdPrefix + "Custom", typeof(PaintTerrainTypeContext), KeyCode.Alpha7, ShortcutModifiers.Shift)] static void KeyCustom() => Choose(PaintType.Custom);
        [Shortcut(IdPrefix + "Clear", typeof(PaintTerrainTypeContext), KeyCode.Alpha8, ShortcutModifiers.Shift)] static void KeyClear() => Choose(PaintType.Clear);

        public static TerrainMaskFlags Flag(PaintType t) => t switch
        {
            PaintType.Water => TerrainMaskFlags.Water, PaintType.DeepWater => TerrainMaskFlags.DeepWater, PaintType.Forest => TerrainMaskFlags.Forest,
            PaintType.Rough => TerrainMaskFlags.Rough, PaintType.Road => TerrainMaskFlags.Road, PaintType.Impassable => TerrainMaskFlags.Impassable,
            PaintType.Custom => TerrainMaskFlags.Custom, _ => TerrainMaskFlags.None,
        };

        static (float lo, float hi) HeightRange(Terrain t)
        {
            var b = t.terrainData.bounds;
            float y = t.transform.position.y;
            return (y + b.min.y, y + b.max.y);
        }

        public static int PreviewForest(Terrain terrain, SplatMapInfo splat)
        {
            var on = TerrainTypePaint.ForestFromTrees(terrain, splat, TreeRadius, MinTrees, out int trees);
            int n = TerrainTypePaint.NewPixels(splat, PaintType.Forest, on);
            ShowPreview(TerrainTypePaint.ForestFromTreesName, on, splat, PaintType.Forest,
                $"Preview: {TerrainTypePaint.ForestFromTreesName} ({trees} trees, at least {MinTrees} within {TreeRadius:0.#} m): {n} m² of new forest. Apply in the Paint Terrain Type tool.");
            return n;
        }

        public static int PreviewWater(Terrain terrain, SplatMapInfo splat)
        {
            var on = TerrainTypePaint.WaterBelowHeight(terrain, splat, WaterHeight);
            int n = TerrainTypePaint.NewPixels(splat, PaintType.Water, on);
            ShowPreview(TerrainTypePaint.WaterBelowHeightName, on, splat, PaintType.Water,
                $"Preview: {TerrainTypePaint.WaterBelowHeightName} {WaterHeight:0.#} m: {n} m² of new water. Apply in the Paint Terrain Type tool.");
            return n;
        }

        public static int ApplyForest(Terrain terrain, SplatMapInfo splat)
        {
            ClearPreview();
            return TerrainTypePaint.Apply(splat, PaintType.Forest, TerrainTypePaint.ForestFromTrees(terrain, splat, TreeRadius, MinTrees, out _), TerrainTypePaint.ForestFromTreesName);
        }

        public static int ApplyWater(Terrain terrain, SplatMapInfo splat)
        {
            ClearPreview();
            return TerrainTypePaint.Apply(splat, PaintType.Water, TerrainTypePaint.WaterBelowHeight(terrain, splat, WaterHeight), TerrainTypePaint.WaterBelowHeightName);
        }

        static void ShowPreview(string name, bool[] on, SplatMapInfo splat, PaintType type, string text)
        {
            if (KitModes.Current != KitMode.TerrainTypes) KitModes.Set(KitMode.TerrainTypes);
            var mask = TerrainTypePaint.Mask(splat, type);
            TerrainTypesView.SetPreview(on, mask.width, mask.height, TerrainTypesView.Styles.First(s => s.flag == Flag(type)).colour, text);
            PreviewOf = name;
        }

        public static void ClearPreview()
        {
            PreviewOf = null;
            TerrainTypesView.ClearPreview();
        }

        // ---- Opening it: the Terrain Types panel's button, the menu and the Shortcut Manager --------------------------

        [MenuItem("UCU Map Kit/Paint Terrain Type", false, 60)]
        static void MenuOpen() => Open();

        [Shortcut("UCU Map Kit/Paint Terrain Type", KeyCode.T, ShortcutModifiers.Alt | ShortcutModifiers.Shift)]
        static void KeyOpen() => Open();

        /// <summary>Selects the map's terrain, switches to Terrain Types mode and picks this tool in the terrain inspector.
        /// Returns why it cannot (no map terrain), or null; the tool is picked once the Inspector has built the terrain inspector.</summary>
        public static string Open()
        {
            var terrain = Terrain.activeTerrain;
            var problem = TerrainTypePaint.Problem(terrain, out _);
            if (problem != null) { Notify(problem); return problem; }
            bool newSelection = Selection.activeGameObject != terrain.gameObject;
            Selection.activeGameObject = terrain.gameObject;
            if (KitModes.Current != KitMode.TerrainTypes) KitModes.Set(KitMode.TerrainTypes);
            problem = SelectInInspector();
            // A new selection is processed a few updates later: the Inspector builds the terrain inspector then, and the
            // Editor switches tools, so the terrain inspector shows the terrain's last built-in tool or none (measured: U5
            // probe). Watch those first updates and pick this tool, once, if it is not shown.
            if (newSelection || problem != null)
            {
                watchTerrain = terrain;
                if (watchUpdates <= 0) EditorApplication.update += WatchSwitch;
                watchUpdates = WatchWindow;
                LastWatch = "watching";
            }
            return null;
        }

        const int WatchWindow = 30;
        const string NoInspector = "Open the Inspector, then pick Paint Terrain Type in the terrain's paint dropdown.";
        static Terrain watchTerrain;
        static int watchUpdates;

        /// <summary>What the watch after Open did (evidence): "kept", "picked after N updates", or "not shown".</summary>
        public static string LastWatch { get; private set; }

        static void WatchSwitch()
        {
            int seen = WatchWindow - --watchUpdates;
            bool stop = watchUpdates <= 0 || watchTerrain == null || Selection.activeGameObject != watchTerrain.gameObject;
            if (!stop && Inspectors().Length > 0 && !Shown())
            {
                SelectInInspector();
                LastWatch = $"picked after {seen} updates";
                stop = true;
            }
            else if (stop)
            {
                LastWatch = Shown() ? "kept" : "not shown";
                if (!Shown() && watchTerrain != null && Selection.activeGameObject == watchTerrain.gameObject) Notify(NoInspector);
            }
            if (!stop) return;
            EditorApplication.update -= WatchSwitch;
            watchUpdates = 0;
            watchTerrain = null;
        }

        /// <summary>Whether every terrain inspector shows this tool in its Paint category.</summary>
        public static bool Shown()
        {
            var t = InspectorType;
            var active = t?.GetMethod("GetActiveTerrainTool", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public)?.Invoke(null, null);
            var category = t?.GetField("m_SelectedCategory", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
            var inspectors = Inspectors();
            return active is PaintTerrainTypeTool && category != null && inspectors.Length > 0 && inspectors.All(i => category.GetValue(i).ToString() == "Paint");
        }

        static Type InspectorType => typeof(TerrainPaintUtilityEditor).Assembly.GetType("UnityEditor.TerrainInspector");

        static UnityEngine.Object[] Inspectors() => InspectorType == null ? new UnityEngine.Object[0] : Resources.FindObjectsOfTypeAll(InspectorType);

        static string SelectInInspector()
        {
            // The terrain inspector has no public call to pick a paint tool; TerrainInspector.SelectPaintTool(Type) is what
            // its own dropdown calls. Rebuild the inspectors so the selection's TerrainInspector exists now.
            ActiveEditorTracker.sharedTracker.ForceRebuild();
            var inspectorType = InspectorType;
            var select = inspectorType?.GetMethod("SelectPaintTool", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
            var inspectors = Inspectors();
            var category = inspectorType?.GetMethod("SelectCategory", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic | System.Reflection.BindingFlags.Public);
            if (select == null || category == null || inspectors.Length == 0)
                return NoInspector;
            // A freshly built inspector can show no tool category ("No tool selected"); pick the Paint Terrain category first.
            var paint = Enum.Parse(category.GetParameters()[0].ParameterType, "Paint");
            foreach (var i in inspectors)
            {
                category.Invoke(i, new object[] { paint, false });
                select.Invoke(i, new object[] { typeof(PaintTerrainTypeTool) });
            }
            return null;
        }

        static void Notify(string text)
        {
            var sv = SceneView.lastActiveSceneView;
            if (sv != null) sv.ShowNotification(new GUIContent(text));
            Debug.Log("UCU Map Kit: " + text);
        }
    }
}
