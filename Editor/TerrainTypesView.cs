// UCU Map Kit: Terrain Types mode (design-v2 § 4.2 #2, § 4.4, § 5 U4; map-kit plan U4). While the mode is on,
// the Scene view shows what the exporter will write into TerrainData.bin:
// - each 4 m cell's terrain type (water, deep water, forest, rough, road, impassable, custom) in a colour and a hatch
//   pattern of its own, so colour is never the only signal;
// - the 50 m edge band, where the exporter marks every cell MapBoundary;
// - the play area of the active encounter layer;
// - the hex grid near the cursor, with the cursor cell's type named beside it.
// The cell types come from a cached copy of the masks at cell resolution, rebuilt when a mask asset is reimported or the
// map changes or a Paint Terrain Type stroke ends (PaintTerrainType.cs, U5), with a helper's preview drawn over them.
// This view writes nothing to the scene.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using BattleTech;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.UIElements;

namespace UCU.MapKit
{
    [InitializeOnLoad]
    public static class TerrainTypesView
    {
        public struct TypeStyle { public TerrainMaskFlags flag; public string name; public Color colour; public string hatch; public string help; }

        /// <summary>In the order MapMetaData.GetPriorityTerrainMaskFlags picks one type for a cell (the edge band first).</summary>
        public static readonly TypeStyle[] Styles =
        {
            new TypeStyle { flag = TerrainMaskFlags.MapBoundary, name = "Edge band", colour = new Color(0.85f, 0.85f, 0.85f), hatch = "checks", help = $"The outer {SplatMapInfo.mapBoundaryWidth} m of the map. Units cannot enter it, whatever is painted there." },
            new TypeStyle { flag = TerrainMaskFlags.Impassable, name = "Impassable", colour = new Color(0.9f, 0.12f, 0.12f), hatch = "crosses", help = "Units cannot enter." },
            new TypeStyle { flag = TerrainMaskFlags.DeepWater, name = "Deep water", colour = new Color(0.08f, 0.2f, 0.75f), hatch = "grid", help = "Units cannot enter." },
            new TypeStyle { flag = TerrainMaskFlags.Water, name = "Water", colour = new Color(0.3f, 0.65f, 1f), hatch = "rows", help = "Shallow water: costs movement, cools heat." },
            new TypeStyle { flag = TerrainMaskFlags.Road, name = "Road", colour = new Color(1f, 0.55f, 0.1f), hatch = "back diagonals", help = "Faster movement." },
            new TypeStyle { flag = TerrainMaskFlags.Custom, name = "Custom", colour = new Color(0.75f, 0.3f, 0.95f), hatch = "columns", help = "The biome's own type (for example lava or radiation)." },
            new TypeStyle { flag = TerrainMaskFlags.Forest, name = "Forest", colour = new Color(0.1f, 0.7f, 0.2f), hatch = "dots", help = "Gives cover; costs movement." },
            new TypeStyle { flag = TerrainMaskFlags.Rough, name = "Rough", colour = new Color(0.65f, 0.45f, 0.25f), hatch = "diagonals", help = "Costs movement." },
        };

        static readonly Color AreaColour = new Color(1f, 0.85f, 0.2f), GridColour = new Color(1f, 1f, 1f, 0.75f);
        const int TexelsPerCell = 2, HatchPeriod = 8, GridRings = 3;
        const float Lift = 0.5f;

        public static event Action Changed;

        /// <summary>Where the cursor last touched the terrain (world); the hex grid is drawn around it.</summary>
        public static Vector3? CursorPoint;

        // The cache: one TerrainMaskFlags per exporter cell, rows along z, as MapMetaData.mapTerrainDataCells[z, x].
        static TerrainMaskFlags[] cells;
        static int cellsX, cellsZ;
        static Vector3 origin, size;
        static string cacheKey, error;
        static bool dirty = true;
        static Texture2D texture;
        static Mesh mesh;
        static Material material;
        static float bandXMin, bandXMax, bandZMin, bandZMax;
        static readonly Dictionary<TerrainMaskFlags, int> counts = new Dictionary<TerrainMaskFlags, int>();
        static readonly Dictionary<TerrainMaskFlags, Texture2D> swatches = new Dictionary<TerrainMaskFlags, Texture2D>();
        static GUIStyle readout;
        static Texture2D preview;
        static string previewText;

        public static long LastRefreshMs { get; private set; }
        public static int RefreshCount { get; private set; }
        public static string Error => error;

        static TerrainTypesView()
        {
            SceneView.duringSceneGui += OnSceneGUI;
            EditorSceneManager.sceneOpened += (s, m) => MarkDirty();
            Undo.undoRedoPerformed += MarkDirty;
        }

        public static void MarkDirty() { dirty = true; SceneView.RepaintAll(); }

        /// <summary>A reimported texture that is one of the open map's masks makes the cache stale.</summary>
        internal static void OnTexturesImported(IEnumerable<string> paths)
        {
            var splat = Splat();
            if (splat == null) return;
            var masks = new HashSet<string>(Masks(splat).Where(m => m != null).Select(AssetDatabase.GetAssetPath));
            if (paths.Any(masks.Contains)) MarkDirty();
        }

        static SplatMapInfo Splat() => Terrain.activeTerrain != null ? Terrain.activeTerrain.GetComponent<SplatMapInfo>() : null;

        static Texture2D[] Masks(SplatMapInfo s) => new[] { s.waterMask, s.deepWaterMask, s.forestMask, s.roughMask, s.customMask, s.roadMask, s.impassableMask };

        static string Key(Terrain t, SplatMapInfo s) =>
            $"{t.GetEntityId()} {t.transform.position} {t.terrainData.size} {s.ValueThreshold} " + string.Join(",", Masks(s).Select(m => m == null ? "-" : m.GetEntityId() + ":" + m.imageContentsHash));

        /// <summary>Rebuilds the cache now if it is stale; with <paramref name="force"/>, always.</summary>
        public static void Refresh(bool force = false)
        {
            var terrain = Terrain.activeTerrain;
            var splat = Splat();
            if (terrain == null || splat == null) { Clear("The open scene has no terrain with a SplatMapInfo. Open a map scene."); return; }
            var key = Key(terrain, splat);
            if (!force && !dirty && key == cacheKey) return;
            var clock = Stopwatch.StartNew();
            try
            {
                var bad = Masks(splat).FirstOrDefault(m => m == null || !m.isReadable);
                if (bad != null || Masks(splat).Any(m => m == null)) throw new InvalidOperationException("A mask is missing or not readable: run Map Check (UCU Map Kit/Map Check) for which one.");
                Build(terrain, splat);
                error = null;
            }
            catch (Exception e) { Clear(e.Message); }
            cacheKey = key;
            dirty = false;
            LastRefreshMs = clock.ElapsedMilliseconds;
            RefreshCount++;
            Changed?.Invoke();
        }

        static void Clear(string why)
        {
            cells = null;
            error = why;
            cacheKey = null;
            dirty = false;
        }

        // HBS's SplatMapInfo.LoadSplatData reads the masks into one flag per mask pixel (grayscale > ValueThreshold); the
        // per-cell step below is the mask part of MapMetaDataExporter.CalculateAverageTerrainValues (MapMetaDataExporter.cs:
        // 530-560), with the same float steps: 5 x 5 samples per 4 m cell, a type counts when 10 or more samples carry it
        // (CellDesignMaskTracker), the cell keeps the type GetPriorityTerrainMaskFlags picks, and cells within mapBoundaryWidth
        // of the edge get MapBoundary. Calling CalculateAverageTerrainValues itself per cell would also sample heights and
        // steepness for all 262,144 cells, which the overlay does not need.
        static void Build(Terrain terrain, SplatMapInfo splat)
        {
            splat.LoadSplatData();
            var field = typeof(SplatMapInfo).GetField("terrainData", BindingFlags.NonPublic | BindingFlags.Instance);
            var pixels = field?.GetValue(splat) as TerrainMaskFlags[];
            if (pixels == null) throw new InvalidOperationException("SplatMapInfo.LoadSplatData gave no data (the masks may differ in size; see the Console).");
            origin = terrain.transform.position;
            size = terrain.terrainData.size;
            int w = splat.Width, h = splat.Height, cell = MapMetaDataExporter.cellSize;
            cellsX = (int)size.x / cell;
            cellsZ = (int)size.z / cell;
            cells = new TerrainMaskFlags[cellsX * cellsZ];
            float half = cell / 2f;
            int band = SplatMapInfo.mapBoundaryWidth;
            int far = (int)(origin.x * -2f) - band; // HBS's own edge test: it uses position.x for both axes.
            var types = new[] { TerrainMaskFlags.Water, TerrainMaskFlags.Forest, TerrainMaskFlags.Rough, TerrainMaskFlags.Custom, TerrainMaskFlags.Road, TerrainMaskFlags.DeepWater, TerrainMaskFlags.Impassable };
            var tally = new int[types.Length];
            for (int r = 0; r < cellsZ; r++)
                for (int c = 0; c < cellsX; c++)
                {
                    float x = (int)(half + c * cell - half) - half, z = (int)(half + r * cell - half) - half;
                    float nx = x + origin.x, nz = z + origin.z;
                    Array.Clear(tally, 0, tally.Length);
                    for (int i = 0; i <= cell; i++)
                        for (int j = 0; j <= cell; j++)
                        {
                            // SplatMapInfo.GetTerrainDataAtCoords and getIndexFromCoords, unchanged.
                            float vx = j + nx, vz = i + nz;
                            int px = (int)((vx - origin.x) / size.x * w), pz = (int)((vz - origin.z) / size.z * h);
                            px = px < 0 ? 0 : px > w ? w : px;
                            pz = pz < 0 ? 0 : pz > h ? h : pz;
                            int index = pz * w + px;
                            var f = index >= pixels.Length ? TerrainMaskFlags.None : pixels[index];
                            if (f == TerrainMaskFlags.None) continue;
                            for (int k = 0; k < types.Length; k++) if ((f & types[k]) == types[k]) tally[k]++;
                        }
                    var flags = TerrainMaskFlags.None;
                    for (int k = 0; k < types.Length; k++) if (tally[k] >= 10) flags |= types[k];
                    flags = MapMetaData.GetPriorityTerrainMaskFlags(flags);
                    if (x < band || z < band || x > far || z > far) flags |= TerrainMaskFlags.MapBoundary;
                    cells[r * cellsX + c] = flags;
                }

            counts.Clear();
            foreach (var s in Styles) counts[s.flag] = 0;
            counts[TerrainMaskFlags.None] = 0;
            foreach (var f in cells) counts[Shown(f)]++;

            // The band as the cells give it, along the middle row and column.
            int mr = cellsZ / 2, mc = cellsX / 2;
            int c0 = Enumerable.Range(0, cellsX).First(c => !SplatMapInfo.IsMapBoundary(cells[mr * cellsX + c]));
            int c1 = Enumerable.Range(0, cellsX).Last(c => !SplatMapInfo.IsMapBoundary(cells[mr * cellsX + c]));
            int r0 = Enumerable.Range(0, cellsZ).First(r => !SplatMapInfo.IsMapBoundary(cells[r * cellsX + mc]));
            int r1 = Enumerable.Range(0, cellsZ).Last(r => !SplatMapInfo.IsMapBoundary(cells[r * cellsX + mc]));
            bandXMin = CellMin(c0, origin.x); bandXMax = CellMin(c1 + 1, origin.x);
            bandZMin = CellMin(r0, origin.z); bandZMax = CellMin(r1 + 1, origin.z);

            BuildTexture();
            BuildMesh(terrain);
        }

        /// <summary>The world coordinate where cell <paramref name="i"/> starts: the game's lookup (MapMetaData.GetXIndex)
        /// puts cell i at local 4i - 2 to 4i + 2, around the exporter's sample window.</summary>
        static float CellMin(int i, float o) => o + i * MapMetaDataExporter.cellSize - MapMetaDataExporter.cellSize / 2f;

        /// <summary>The type a cell shows: the edge band over anything, else its one priority type, or None (clear).</summary>
        public static TerrainMaskFlags Shown(TerrainMaskFlags f) => SplatMapInfo.IsMapBoundary(f) ? TerrainMaskFlags.MapBoundary : MapMetaData.GetPriorityTerrainMaskFlags(f);

        /// <summary>The cached flags of the cell the game looks up for <paramref name="world"/> (MapMetaData.GetXIndex /
        /// GetZIndex, sized to this terrain), or null outside the cells or with no cache.</summary>
        public static TerrainMaskFlags? CellAt(Vector3 world, out int row, out int col)
        {
            row = col = -1;
            if (cells == null) return null;
            float cell = MapMetaDataExporter.cellSize;
            col = (int)(cellsX * ((world.x - origin.x + cell * 0.5f) / size.x));
            row = (int)(cellsZ * ((world.z - origin.z + cell * 0.5f) / size.z));
            if (world.x - origin.x + cell * 0.5f < 0f || world.z - origin.z + cell * 0.5f < 0f || col >= cellsX || row >= cellsZ) return null;
            return cells[row * cellsX + col];
        }

        public static int Count(TerrainMaskFlags shown) => counts.TryGetValue(shown, out var n) ? n : 0;

        static bool Hatched(string hatch, int u, int v)
        {
            int a = u % HatchPeriod, b = v % HatchPeriod;
            switch (hatch)
            {
                case "rows": return b < 2;
                case "columns": return a < 2;
                case "grid": return a < 2 || b < 2;
                case "dots": return a < 3 && b < 3;
                case "diagonals": return (u + v) % HatchPeriod < 2;
                case "back diagonals": return ((u - v) % HatchPeriod + HatchPeriod) % HatchPeriod < 2;
                case "crosses": return (u + v) % HatchPeriod < 2 || ((u - v) % HatchPeriod + HatchPeriod) % HatchPeriod < 2;
                case "checks": return (u / 4 + v / 4) % 2 == 0;
                default: return false;
            }
        }

        static Color32 Texel(TypeStyle s, int u, int v, bool opaque)
        {
            bool on = Hatched(s.hatch, u, v);
            var c = s.colour;
            float alpha = on ? 0.85f : 0.3f;
            if (opaque) c = Color.Lerp(new Color(0.35f, 0.35f, 0.35f), c, alpha);
            c.a = opaque ? 1f : alpha;
            return c;
        }

        static void BuildTexture()
        {
            int tw = cellsX * TexelsPerCell, th = cellsZ * TexelsPerCell;
            if (texture == null || texture.width != tw || texture.height != th)
            {
                if (texture != null) UnityEngine.Object.DestroyImmediate(texture);
                texture = new Texture2D(tw, th, TextureFormat.RGBA32, false) { name = "UCU Map Kit terrain types", filterMode = FilterMode.Point, wrapMode = TextureWrapMode.Clamp, hideFlags = HideFlags.HideAndDontSave };
            }
            var style = Styles.ToDictionary(s => s.flag);
            var px = new Color32[tw * th];
            for (int v = 0; v < th; v++)
                for (int u = 0; u < tw; u++)
                {
                    var shown = Shown(cells[(v / TexelsPerCell) * cellsX + u / TexelsPerCell]);
                    if (shown != TerrainMaskFlags.None && style.TryGetValue(shown, out var s)) px[v * tw + u] = Texel(s, u, v, false);
                }
            texture.SetPixels32(px);
            texture.Apply(false);
        }

        // A grid that follows the ground, 0.5 m above it, covering the cells as the game looks them up.
        static void BuildMesh(Terrain terrain)
        {
            const int n = 257;
            if (mesh == null) mesh = new Mesh { name = "UCU Map Kit terrain types", hideFlags = HideFlags.HideAndDontSave, indexFormat = UnityEngine.Rendering.IndexFormat.UInt32 };
            float x0 = CellMin(0, origin.x), z0 = CellMin(0, origin.z), sx = cellsX * MapMetaDataExporter.cellSize, sz = cellsZ * MapMetaDataExporter.cellSize;
            var verts = new Vector3[n * n];
            var uv = new Vector2[n * n];
            for (int i = 0; i < n; i++)
                for (int j = 0; j < n; j++)
                {
                    float fu = j / (n - 1f), fv = i / (n - 1f);
                    var p = new Vector3(x0 + fu * sx, 0f, z0 + fv * sz);
                    p.y = terrain.SampleHeight(p) + origin.y + Lift;
                    verts[i * n + j] = p;
                    uv[i * n + j] = new Vector2(fu, fv);
                }
            var tris = new int[(n - 1) * (n - 1) * 6];
            int t = 0;
            for (int i = 0; i < n - 1; i++)
                for (int j = 0; j < n - 1; j++)
                {
                    int a = i * n + j;
                    tris[t++] = a; tris[t++] = a + n; tris[t++] = a + 1;
                    tris[t++] = a + 1; tris[t++] = a + n; tris[t++] = a + n + 1;
                }
            mesh.Clear();
            mesh.vertices = verts;
            mesh.uv = uv;
            mesh.triangles = tris;
            mesh.RecalculateBounds();
        }

        static void OnSceneGUI(SceneView view)
        {
            if (KitModes.Current != KitMode.TerrainTypes) return;
            var e = Event.current;
            var terrain = Terrain.activeTerrain;
            if (terrain == null) return;
            if (e.type == EventType.MouseMove || e.type == EventType.MouseDrag)
            {
                var collider = terrain.GetComponent<TerrainCollider>();
                if (collider != null && collider.Raycast(HandleUtility.GUIPointToWorldRay(e.mousePosition), out var hit, 100000f)) CursorPoint = hit.point;
                view.Repaint();
            }
            if (e.type != EventType.Repaint) return;
            Refresh();
            if (cells == null) return;

            if (material == null)
            {
                var shader = Shader.Find("Hidden/UCU Map Kit/Terrain Types"); // TerrainTypesOverlay.shader, beside this file
                if (shader == null) { error = "The kit's shader Hidden/UCU Map Kit/Terrain Types is missing: reinstall the map kit package."; return; }
                material = new Material(shader) { hideFlags = HideFlags.HideAndDontSave };
            }
            material.mainTexture = texture;
            material.SetPass(0);
            Graphics.DrawMeshNow(mesh, Matrix4x4.identity);
            if (preview != null)
            {
                material.mainTexture = preview;
                material.SetPass(0);
                Graphics.DrawMeshNow(mesh, Matrix4x4.identity);
            }

            var oldZ = Handles.zTest;
            Handles.zTest = UnityEngine.Rendering.CompareFunction.Always;
            Handles.color = Color.white;
            Outline(terrain, bandXMin, bandZMin, bandXMax, bandZMax, 3f);
            Handles.Label(Ground(terrain, new Vector3(bandXMin + 8f, 0f, bandZMax - 8f)), $"Edge band: the outer {SplatMapInfo.mapBoundaryWidth} m", EditorStyles.whiteBoldLabel);

            var layer = EncounterEdit.ActiveLayer(EncounterEdit.Parent());
            if (layer != null)
                foreach (var rect in layer.GetComponentsInChildren<EncounterBoundaryRectGameLogic>())
                {
                    var r = rect.GetRect();
                    Handles.color = AreaColour;
                    Outline(terrain, r.xMin, r.yMin, r.xMax, r.yMax, 4f);
                    Handles.Label(Ground(terrain, new Vector3(r.xMin + 8f, 0f, r.yMax - 8f)), $"Play area ({layer.name})", EditorStyles.whiteBoldLabel);
                }

            if (CursorPoint.HasValue) DrawHexes(terrain, CursorPoint.Value);
            Handles.zTest = oldZ;
            if (preview != null && previewText != null)
            {
                Handles.BeginGUI();
                // Right of the Scene view's tools column, as tall as the wrapped text.
                var content = new GUIContent(previewText);
                float w = Mathf.Max(200f, Mathf.Min(560f, view.position.width - 96f));
                GUI.Label(new Rect(56f, 8f, w, ReadoutStyle().CalcHeight(content, w)), content, ReadoutStyle());
                Handles.EndGUI();
            }
        }

        /// <summary>Shows a Paint Terrain Type helper's result before it is applied: <paramref name="pixels"/> (mask pixels,
        /// <paramref name="w"/> x <paramref name="h"/>) drawn on the drape in <paramref name="colour"/> with white stripes.</summary>
        public static void SetPreview(bool[] pixels, int w, int h, Color colour, string text)
        {
            Refresh();
            if (cells == null) return;
            int tw = cellsX * TexelsPerCell, th = cellsZ * TexelsPerCell;
            if (preview == null || preview.width != tw || preview.height != th)
            {
                if (preview != null) UnityEngine.Object.DestroyImmediate(preview);
                preview = new Texture2D(tw, th, TextureFormat.RGBA32, false) { name = "UCU Map Kit helper preview", filterMode = FilterMode.Point, wrapMode = TextureWrapMode.Clamp, hideFlags = HideFlags.HideAndDontSave };
            }
            // Texel u covers local (u - 1) * m .. u * m, m = cell / TexelsPerCell: the drape starts half a cell before the terrain.
            float m = (float)MapMetaDataExporter.cellSize / TexelsPerCell, kx = w / size.x, kz = h / size.z;
            var px = new Color32[tw * th];
            Color32 fill = new Color(colour.r, colour.g, colour.b, 0.55f), stripe = new Color(1f, 1f, 1f, 0.95f);
            for (int v = 0; v < th; v++)
            {
                int pz0 = Mathf.Max(0, Mathf.FloorToInt((v - 1) * m * kz)), pz1 = Mathf.Min(h - 1, Mathf.CeilToInt(v * m * kz) - 1);
                for (int u = 0; u < tw; u++)
                {
                    int px0 = Mathf.Max(0, Mathf.FloorToInt((u - 1) * m * kx)), px1 = Mathf.Min(w - 1, Mathf.CeilToInt(u * m * kx) - 1);
                    bool any = false;
                    for (int z = pz0; z <= pz1 && !any; z++) for (int x = px0; x <= px1 && !any; x++) any = pixels[z * w + x];
                    if (any) px[v * tw + u] = (u + v) % 6 < 2 ? stripe : fill;
                }
            }
            preview.SetPixels32(px);
            preview.Apply(false);
            previewText = text;
            Changed?.Invoke();
            SceneView.RepaintAll();
        }

        public static void ClearPreview()
        {
            if (preview == null) return;
            UnityEngine.Object.DestroyImmediate(preview);
            preview = null;
            previewText = null;
            Changed?.Invoke();
            SceneView.RepaintAll();
        }

        public static string PreviewText => previewText;

        static Vector3 Ground(Terrain t, Vector3 p) { p.y = t.SampleHeight(p) + t.transform.position.y + Lift; return p; }

        static void Outline(Terrain t, float x0, float z0, float x1, float z1, float width)
        {
            var pts = new List<Vector3>();
            void Edge(Vector3 a, Vector3 b) { int steps = Mathf.Max(1, Mathf.CeilToInt(Vector3.Distance(a, b) / 16f)); for (int i = 0; i < steps; i++) pts.Add(Ground(t, Vector3.Lerp(a, b, i / (float)steps))); }
            Vector3 sw = new Vector3(x0, 0, z0), se = new Vector3(x1, 0, z0), ne = new Vector3(x1, 0, z1), nw = new Vector3(x0, 0, z1);
            Edge(sw, se); Edge(se, ne); Edge(ne, nw); Edge(nw, sw);
            pts.Add(pts[0]);
            Handles.DrawAAPolyLine(width, pts.ToArray());
        }

        // HBS's hexes (HexGrid: 24 m apart, flat sides facing east and west) within three rings of the cursor's hex.
        static void DrawHexes(Terrain t, Vector3 at)
        {
            var grid = new BattleTech.HexGrid(null);
            float radius = grid.HexWidth / Mathf.Sqrt(3f);
            Handles.color = GridColour;
            foreach (var centre in grid.GetGridPointsAroundPointWithinRadius(at, GridRings))
            {
                var corners = new Vector3[7];
                for (int k = 0; k < 6; k++)
                {
                    float a = Mathf.Deg2Rad * (30f + 60f * k);
                    corners[k] = Ground(t, centre + new Vector3(Mathf.Cos(a) * radius, 0f, Mathf.Sin(a) * radius));
                }
                corners[6] = corners[0];
                Handles.DrawAAPolyLine(2f, corners);
            }
            var flags = CellAt(at, out int row, out int col);
            if (flags == null) return;
            var shown = Shown(flags.Value);
            var painted = MapMetaData.GetPriorityTerrainMaskFlags(flags.Value & ~TerrainMaskFlags.MapBoundary);
            var under = SplatMapInfo.IsMapBoundary(flags.Value) && painted != TerrainMaskFlags.None ? $" (painted {Name(painted)})" : "";
            Handles.Label(Ground(t, at) + Vector3.up * 2f, $"{Name(shown)}{under}\ncell x {col}, z {row}", ReadoutStyle());
        }

        static GUIStyle ReadoutStyle()
        {
            if (readout != null && readout.normal.background != null) return readout;
            var bg = new Texture2D(1, 1) { hideFlags = HideFlags.HideAndDontSave };
            bg.SetPixel(0, 0, new Color(0.08f, 0.08f, 0.08f, 0.9f));
            bg.Apply();
            return readout = new GUIStyle(EditorStyles.label) { padding = new RectOffset(6, 6, 4, 4), fontStyle = FontStyle.Bold, wordWrap = true, normal = { background = bg, textColor = Color.white } };
        }

        public static string Name(TerrainMaskFlags shown) => shown == TerrainMaskFlags.None ? "Clear" : Styles.FirstOrDefault(s => s.flag == shown).name ?? shown.ToString();

        static Texture2D Swatch(TypeStyle s)
        {
            if (swatches.TryGetValue(s.flag, out var tex) && tex != null) return tex;
            tex = new Texture2D(48, 24, TextureFormat.RGBA32, false) { filterMode = FilterMode.Point, hideFlags = HideFlags.HideAndDontSave };
            var px = new Color32[48 * 24];
            for (int v = 0; v < 24; v++) for (int u = 0; u < 48; u++) px[v * 48 + u] = Texel(s, u, v, true);
            tex.SetPixels32(px);
            tex.Apply(false);
            return swatches[s.flag] = tex;
        }

        /// <summary>The overlay panel for this mode: the legend (swatch, name, cells on this map, what it does) and the other marks.</summary>
        public static VisualElement Panel()
        {
            Refresh();
            var panel = new VisualElement { name = "terrain-types", style = { marginTop = 4 } };
            if (error != null)
            {
                panel.Add(Wrapped(new Label(error)));
                return panel;
            }
            panel.Add(new Label("Terrain types") { style = { unityFontStyleAndWeight = FontStyle.Bold } });
            panel.Add(new Button(() => PaintTerrainTypeTool.Open()) { text = "Paint Terrain Type", name = "paint-terrain-type",
                tooltip = "Select the terrain and open the Paint Terrain Type tool in the Inspector (Alt+Shift+T, or UCU Map Kit/Paint Terrain Type). Paint water, forest, roads and the other types with Unity's brushes." });
            if (previewText != null) panel.Add(Wrapped(new Label(previewText) { name = "preview", style = { unityFontStyleAndWeight = FontStyle.Bold, marginTop = 2 } }));
            var pending = TerrainTypePaint.Pending.Length;
            if (pending > 0) panel.Add(Wrapped(new Label($"{pending} mask(s) painted since the last save: save the scene (Ctrl+S) to write them.") { name = "pending", style = { marginTop = 2 } }));
            foreach (var s in Styles)
            {
                var row = new VisualElement { name = "legend-" + s.flag, style = { flexDirection = FlexDirection.Row, alignItems = Align.Center, marginTop = 2 },
                    tooltip = $"{s.name}: {s.help}\nPattern: {s.hatch}. HBS flag: TerrainMaskFlags.{s.flag}" };
                row.Add(new Image { image = Swatch(s), style = { width = 48, height = 24, marginRight = 6 } });
                row.Add(new Label($"{s.name} ({s.hatch})") { style = { flexGrow = 1 } });
                row.Add(new Label($"{Count(s.flag)} cells") { name = "count", style = { color = new Color(0.7f, 0.7f, 0.7f) } });
                panel.Add(row);
            }
            panel.Add(new Label($"Clear: no fill ({Count(TerrainMaskFlags.None)} cells)") { name = "legend-None", style = { marginTop = 2 } });
            panel.Add(new Label("Yellow line: the play area of the active encounter layer. White line: the inner edge of the edge band. White hexes: the hex grid around the cursor, with the type of the cell under it.") { name = "marks", style = { whiteSpace = WhiteSpace.Normal, marginTop = 4 } });
            panel.Add(new Label($"Each 4 m cell shows the one type the exporter writes for it. Last read of the masks: {LastRefreshMs} ms.")
                { name = "hint", style = { whiteSpace = WhiteSpace.Normal, fontSize = 10, color = new Color(0.65f, 0.65f, 0.65f), marginTop = 4 } });
            return panel;
        }

        static Label Wrapped(Label l) { l.style.whiteSpace = WhiteSpace.Normal; return l; }
    }

    class TerrainTypesMaskWatcher : AssetPostprocessor
    {
        static void OnPostprocessAllAssets(string[] imported, string[] deleted, string[] moved, string[] movedFrom) =>
            TerrainTypesView.OnTexturesImported(imported.Concat(moved));
    }
}
