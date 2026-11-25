// UCU Map Kit: "Roads…" (plan .hermes/plans/2026-11-19-map-kit.md -> X4; probe .hermes/reports/map-kit-x4-probe-20261123/final.md).
// A road is drawn as a Unity spline (SplineContainer, com.unity.splines) under GAME/RoadManager. Bake writes what the game reads of
// a retail road: a mesh strip on the ground (layer 11 Obstruction, with a MeshCollider) and the road band in SplatMapInfo.roadMask,
// which Export turns into Road cells (MapMetaDataExporter.CalculateAverageTerrainValues: 10 of a cell's 25 samples), and paints the
// biome's dirt-road splat layer under the mesh, which is what shows a road on screen (PaintRoadLayer). It writes no
// RoadSpline and no Curvy object: nothing reads them while the game plays (probe section 2).
// - The spline object is tagged EditorOnly, so Unity leaves it out of the map's bundle (the player has no Splines code). The mesh is
//   its sibling "<road> Mesh", not its child, so it stays in the bundle; the name is the link between the two.
// - The width is kept on the spline itself (embedded float data, key WidthKey). The mesh is stored in the scene, not as an asset,
//   so one Undo step covers the whole bake: the old mesh object, the new one, the mask and the splat. A re-bake does not give the
//   old band its old splat back (Undo does).
// - The band is the mesh's own footprint: a re-bake clears the old mesh's texels, then sets every road's.
using System;
using System.Collections.Generic;
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Splines;

namespace UCU.MapKit
{
    public class RoadBakeResult
    {
        public string road;
        public int knots, samples, vertices, triangles, texelsCleared, texelsSet, roadTexels, splatTexels;
        public float length, width, lift;
        public string material;
    }

    public static class Roads
    {
        public const float DefaultWidth = 8f;
        // Below 4 m the band covers fewer than 10 of a 4 m cell's 25 samples along much of its length, and those cells lose the flag.
        public const float MinWidth = 4f;
        public const string WidthKey = "ucu-road-width";
        public const string UndoBake = "Bake Road";
        public const string CheckWidth = "road-width";
        public const string CheckOffMap = "road-off-map";
        const string ManagerName = "RoadManager", GameRoot = "GAME", MeshSuffix = " Mesh";
        const float Step = 1f;         // metres between cross-sections along the road
        const float AcrossStep = 2f;   // at most this far between vertices across it, so the strip follows the ground
        // UVs as retail's road mesh lays out the road texture (deathValley RoadSpline1, Assets/Mesh/Mesh_1.asset, measured): U runs along
        // the road, one unit per 46.6 m on a 7.156 m surface (6.51 widths), and V runs across it from 0.009 to 0.68.
        const float UPerWidth = 46.596f / 7.156f, VEdge0 = 0.009f, VEdge1 = 0.68f;

        /// <summary>Height of the mesh above the ground. Retail's road sits on terrain carved 0.3 m below its spline
        /// (RoadSpline.roadHeightOffset -0.3); the kit does not carve, so the strip lies on the ground with this offset.</summary>
        public static float Lift = 0.1f;

        [MenuItem("UCU Map Kit/Roads…")]
        public static void Open() => EditorWindow.GetWindow<RoadsWindow>(false, "Roads", true);

        [InitializeOnLoadMethod]
        static void Hook() => Undo.undoRedoEvent += OnUndoRedo;

        // An Undo or Redo of a bake changes the road mask back: it needs writing at the next save, like a paint stroke.
        static void OnUndoRedo(in UndoRedoInfo info)
        {
            if (info.undoName == null || !info.undoName.StartsWith(UndoBake, StringComparison.Ordinal)) return;
            var splat = Terrain.activeTerrain != null ? Terrain.activeTerrain.GetComponent<SplatMapInfo>() : null;
            if (splat != null && splat.roadMask != null) TerrainTypePaint.MarkChanged(new[] { splat.roadMask });
            if (Terrain.activeTerrain != null) SaveTerrain(Terrain.activeTerrain.terrainData);
        }

        // The splat is a sub-asset of the map's TerrainData, which a scene save does not write; a bake (and its Undo or Redo) writes
        // it at once, as TemplateGenerator does, so Build Mod packs the painted road. This also writes an unsaved sculpt of the map.
        static void SaveTerrain(TerrainData td)
        {
            if (td == null) return;
            EditorUtility.SetDirty(td);
            AssetDatabase.SaveAssetIfDirty(td);
        }

        /// <summary>The biome's dirt-road splat layer (Biome.SplatTextures.dirtRoadLayer), or -1 when the terrain has no biome.</summary>
        public static int RoadLayer()
        {
            var t = Terrain.activeTerrain;
            var biome = t != null && t.GetComponent<TerrainGenerator>() != null ? t.GetComponent<TerrainGenerator>().biome : null;
            return biome != null ? biome.splatTextures.dirtRoadLayer : -1;
        }

        public static RoadManager Manager() => UnityEngine.Object.FindAnyObjectByType<RoadManager>(FindObjectsInactive.Include);

        /// <summary>The map's RoadManager, made under GAME (version 1, with HBS's road obstruction) when it has none.</summary>
        static RoadManager EnsureManager()
        {
            var rm = Manager();
            if (rm != null) return rm;
            var scene = EditorSceneManager.GetActiveScene();
            var game = scene.GetRootGameObjects().FirstOrDefault(g => g.name == GameRoot);
            if (game == null)
            {
                game = new GameObject(GameRoot);
                Undo.RegisterCreatedObjectUndo(game, "Add Road");
            }
            var go = new GameObject(ManagerName);
            go.transform.SetParent(game.transform, false);
            rm = go.AddComponent<RoadManager>();
            rm.version = RoadManager.RoadsWithCollisionVersion;
            rm.EnsureRoadObstruction(); // HBS: ObstructionGameLogic with buildingdef_Road, as Export does
            go.GetComponent<ObstructionGameLogic>().EnsureGuid();
            Undo.RegisterCreatedObjectUndo(go, "Add Road");
            return rm;
        }

        public static SplineContainer[] All()
        {
            var rm = Manager();
            return rm == null ? new SplineContainer[0] : rm.GetComponentsInChildren<SplineContainer>(true);
        }

        public static float GetWidth(SplineContainer road) =>
            road.Spline.TryGetFloatData(WidthKey, out var d) ? d.DefaultValue : DefaultWidth;

        public static void SetWidth(SplineContainer road, float width)
        {
            Undo.RecordObject(road, "Road width");
            road.Spline.GetOrCreateFloatData(WidthKey).DefaultValue = width;
            EditorUtility.SetDirty(road);
        }

        /// <summary>The biome's one-lane road material (Biome.GetRoadMaterial, as RoadSpline.GetRoadMaterial asks for it), else two-lane.</summary>
        public static Material BiomeMaterial()
        {
            var t = Terrain.activeTerrain;
            var biome = t != null && t.GetComponent<TerrainGenerator>() != null ? t.GetComponent<TerrainGenerator>().biome : null;
            if (biome == null) return null;
            return biome.GetRoadMaterial(RoadModel.OneLaneRoad) ?? biome.GetRoadMaterial(RoadModel.TwoLaneRoad);
        }

        public static GameObject MeshObject(SplineContainer road)
        {
            var parent = road.transform.parent;
            if (parent == null) return null;
            var t = parent.Find(road.name + MeshSuffix);
            return t != null ? t.gameObject : null;
        }

        /// <summary>A new straight road of 40 m through <paramref name="centre"/>, on the ground, with the default width. One Undo step.</summary>
        public static SplineContainer AddRoad(Vector3 centre, float width = DefaultWidth)
        {
            var terrain = Terrain.activeTerrain ?? throw new InvalidOperationException(MapPreconditions.NoTerrain);
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName("Add Road");
            var rm = EnsureManager();
            var names = new HashSet<string>(rm.GetComponentsInChildren<Transform>(true).Select(t => t.name));
            int n = 1;
            while (names.Contains("Road" + n)) n++;
            var go = new GameObject("Road" + n) { tag = "EditorOnly" };
            go.transform.SetParent(rm.transform, false);
            var road = go.AddComponent<SplineContainer>();
            foreach (var dx in new[] { -20f, 20f })
            {
                var p = centre + new Vector3(dx, 0f, 0f);
                p.y = Ground(terrain, p);
                road.Spline.Add(new BezierKnot(go.transform.InverseTransformPoint(p)), TangentMode.AutoSmooth);
            }
            road.Spline.GetOrCreateFloatData(WidthKey).DefaultValue = width;
            Undo.RegisterCreatedObjectUndo(go, "Add Road");
            Undo.CollapseUndoOperations(Undo.GetCurrentGroup());
            Selection.activeGameObject = go;
            return road;
        }

        static float Ground(Terrain t, Vector3 p) => t.SampleHeight(p) + t.transform.position.y;

        /// <summary>Bakes <paramref name="road"/>: replaces its mesh and its band in the road mask, as one Undo step.
        /// <paramref name="material"/> null keeps the old mesh's material, else takes the biome's.</summary>
        public static RoadBakeResult Bake(SplineContainer road, Material material = null)
        {
            var terrain = Terrain.activeTerrain ?? throw new InvalidOperationException(MapPreconditions.NoTerrain);
            var problem = TerrainTypePaint.Problem(terrain, out var splat);
            if (problem != null) throw new InvalidOperationException(problem);
            if (road.Spline.Count < 2) throw new InvalidOperationException($"{road.name} has fewer than two knots: draw the road first.");
            var mask = splat.roadMask;
            var r = new RoadBakeResult { road = road.name, knots = road.Spline.Count, width = GetWidth(road), lift = Lift, length = road.CalculateLength() };

            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName($"{UndoBake} ({road.name})");
            var px = mask.GetPixels32();
            var old = MeshObject(road);
            if (old != null)
            {
                if (material == null && old.GetComponent<MeshRenderer>() != null) material = old.GetComponent<MeshRenderer>().sharedMaterial;
                r.texelsCleared = Footprint(terrain, mask, old, px, false);
                Undo.DestroyObjectImmediate(old);
            }
            if (material == null) material = BiomeMaterial();

            var go = new GameObject(road.name + MeshSuffix) { layer = LayerMask.NameToLayer("Obstruction") };
            go.transform.SetParent(road.transform.parent, false);
            var mesh = Strip(terrain, road, go.transform, r);
            go.AddComponent<MeshFilter>().sharedMesh = mesh;
            go.AddComponent<MeshRenderer>().sharedMaterial = material;
            go.AddComponent<MeshCollider>().sharedMesh = mesh;
            Undo.RegisterCreatedObjectUndo(go, UndoBake);
            r.material = material != null ? material.name : "(none)";

            // Every road's footprint, so a road the old band overlapped keeps its texels.
            foreach (var other in All())
            {
                var m = other == road ? go : MeshObject(other);
                if (m == null) continue;
                int set = Footprint(terrain, mask, m, px, true);
                if (other == road) r.texelsSet = set;
            }
            // The mask is recorded here, after the objects are made: a GameObject created between a texture's record and its change
            // leaves Redo restoring the old pixels (measured, X4 hera/probe-redo*.out).
            Undo.RegisterCompleteObjectUndo(mask, UndoBake);
            mask.SetPixels32(px);
            mask.Apply(false);
            var td = terrain.terrainData;
            Undo.RegisterCompleteObjectUndo(new UnityEngine.Object[] { td }.Concat(td.alphamapTextures).ToArray(), UndoBake);
            r.splatTexels = PaintRoadLayer(terrain, go, RoadLayer());
            SaveTerrain(td);
            Undo.CollapseUndoOperations(Undo.GetCurrentGroup());
            TerrainTypePaint.MarkChanged(new[] { mask });
            r.roadTexels = px.Count(c => c.r == 255);
            return r;
        }

        // The strip: cross-sections every Step metres, each from edge to edge at AcrossStep or less, every vertex on the ground plus Lift.
        static Mesh Strip(Terrain terrain, SplineContainer road, Transform meshTransform, RoadBakeResult r)
        {
            int along = Mathf.Max(2, Mathf.CeilToInt(r.length / Step));
            int across = Mathf.Max(1, Mathf.CeilToInt(r.width / AcrossStep));
            var verts = new List<Vector3>();
            var uvs = new List<Vector2>();
            Vector3 prev = default, side = Vector3.right;
            float dist = 0f;
            for (int i = 0; i <= along; i++)
            {
                float t = (float)i / along;
                Vector3 c = road.EvaluatePosition(t);
                Vector3 tan = road.EvaluateTangent(t);
                tan.y = 0f;
                if (tan.sqrMagnitude > 1e-8f) side = new Vector3(tan.z, 0f, -tan.x).normalized; // a vertical tangent keeps the last side
                if (i > 0) dist += Vector3.Distance(new Vector3(c.x, 0f, c.z), new Vector3(prev.x, 0f, prev.z));
                prev = c;
                for (int k = 0; k <= across; k++)
                {
                    var p = c + side * (r.width * ((float)k / across - 0.5f));
                    p.y = Ground(terrain, p) + Lift;
                    verts.Add(meshTransform.InverseTransformPoint(p));
                    uvs.Add(new Vector2(dist / (UPerWidth * r.width), VEdge0 + (VEdge1 - VEdge0) * k / across));
                }
            }
            var tris = new List<int>();
            int row = across + 1;
            for (int i = 0; i < along; i++)
                for (int k = 0; k < across; k++)
                {
                    int a = i * row + k, b = a + 1, c = a + row, d = c + 1;
                    tris.AddRange(new[] { a, c, b, b, c, d }); // clockwise seen from above with side = tangent rotated right
                }
            var mesh = new Mesh { name = road.name + MeshSuffix };
            if (verts.Count > 65535) mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;
            mesh.SetVertices(verts);
            mesh.SetUVs(0, uvs);
            mesh.SetTriangles(tris, 0);
            mesh.RecalculateNormals();
            mesh.RecalculateTangents();
            mesh.RecalculateBounds();
            r.samples = along + 1; r.vertices = verts.Count; r.triangles = tris.Count / 3;
            return mesh;
        }

        // Sets (or clears) the mask texels whose centre lies inside the mesh's triangles seen from above. Texel s covers
        // s..s+1 texel widths of the terrain's local space (SplatMapInfo.GetTerrainDataAtCoords floors). Returns the texels changed.
        static int Footprint(Terrain terrain, Texture2D mask, GameObject meshObject, Color32[] px, bool on)
        {
            int w = mask.width;
            var value = on ? new Color32(255, 255, 255, 255) : new Color32(0, 0, 0, 255);
            int changed = 0;
            ForTexels(terrain, meshObject, w, mask.height, (x, z) =>
            {
                int idx = z * w + x;
                if (px[idx].r == value.r && px[idx].g == value.g && px[idx].b == value.b) return;
                px[idx] = value;
                changed++;
            });
            return changed;
        }

        // Calls visit(x, z) for every texel of a w x h grid over the terrain whose centre lies inside the mesh's triangles seen from above
        // (a texel can be visited more than once, by two triangles).
        static void ForTexels(Terrain terrain, GameObject meshObject, int w, int h, Action<int, int> visit)
        {
            var mf = meshObject.GetComponent<MeshFilter>();
            if (mf == null || mf.sharedMesh == null) return;
            var mesh = mf.sharedMesh;
            var origin = terrain.transform.position;
            var size = terrain.terrainData.size;
            float sx = size.x / w, sz = size.z / h;
            var v = mesh.vertices.Select(p => { var q = meshObject.transform.TransformPoint(p) - origin; return new Vector2(q.x / sx, q.z / sz); }).ToArray();
            var tris = mesh.triangles;
            for (int i = 0; i < tris.Length; i += 3)
            {
                Vector2 a = v[tris[i]], b = v[tris[i + 1]], c = v[tris[i + 2]];
                int x0 = Mathf.Max(0, Mathf.FloorToInt(Mathf.Min(a.x, b.x, c.x))), x1 = Mathf.Min(w - 1, Mathf.CeilToInt(Mathf.Max(a.x, b.x, c.x)));
                int z0 = Mathf.Max(0, Mathf.FloorToInt(Mathf.Min(a.y, b.y, c.y))), z1 = Mathf.Min(h - 1, Mathf.CeilToInt(Mathf.Max(a.y, b.y, c.y)));
                for (int z = z0; z <= z1; z++)
                    for (int x = x0; x <= x1; x++)
                        if (Inside(new Vector2(x + 0.5f, z + 0.5f), a, b, c)) visit(x, z);
            }
        }

        // What shows a retail road is the terrain's own splat: the biome's dirt-road layer is painted under it (deathValley: weight
        // 0.90 on the road, 0.09 12 m beside it). The road material's _TERRAIN_BLEND program takes the terrain's albedo until the
        // mesh is 1.5 m above the ground (bt-standardroad.shader, deferred pass), and retail's mesh sits 0.18-0.33 m above it, so the
        // mesh adds little colour of its own (KFIX6, hera/l4-roadheight.out, l5-roadsplat.out). Paints that layer at full weight under
        // the mesh. Returns the texels painted.
        static int PaintRoadLayer(Terrain terrain, GameObject meshObject, int layer)
        {
            var td = terrain.terrainData;
            int res = td.alphamapResolution, layers = td.alphamapLayers;
            if (layer < 0 || layer >= layers) return 0;
            var alpha = td.GetAlphamaps(0, 0, res, res);
            var seen = new HashSet<int>();
            ForTexels(terrain, meshObject, res, res, (x, z) =>
            {
                if (!seen.Add(z * res + x)) return;
                for (int l = 0; l < layers; l++) alpha[z, x, l] = l == layer ? 1f : 0f;
            });
            if (seen.Count > 0) td.SetAlphamaps(0, 0, alpha);
            return seen.Count;
        }

        static bool Inside(Vector2 p, Vector2 a, Vector2 b, Vector2 c)
        {
            float d1 = Cross(p, a, b), d2 = Cross(p, b, c), d3 = Cross(p, c, a);
            bool neg = d1 < 0f || d2 < 0f || d3 < 0f, pos = d1 > 0f || d2 > 0f || d3 > 0f;
            return !(neg && pos);
        }

        static float Cross(Vector2 p, Vector2 a, Vector2 b) => (b.x - a.x) * (p.y - a.y) - (b.y - a.y) * (p.x - a.x);

        /// <summary>Map Check's road entries: a road narrower than MinWidth, and a road whose band leaves the terrain.</summary>
        public static void AddCheckEntries(Terrain terrain, List<MapCheckEntry> entries)
        {
            var origin = terrain.transform.position;
            var size = terrain.terrainData.size;
            var map = Rect.MinMaxRect(origin.x, origin.z, origin.x + size.x, origin.z + size.z);
            foreach (var road in All())
            {
                float width = GetWidth(road);
                if (width < MinWidth)
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = CheckWidth, target = road,
                        message = $"{road.name} is {width:0.#} m wide. Below {MinWidth:0} m many of its 4 m cells don't get the Road terrain type, so units don't move faster there. Set its width to {MinWidth:0} m or more in Roads… and bake it again.",
                        detail = $"Spline embedded float data [{WidthKey}] = {width}; MapMetaDataExporter gives a cell a terrain type with 10 of its 25 samples." });
                if (road.Spline.Count < 2) continue;
                float length = road.CalculateLength();
                int n = Mathf.Max(2, Mathf.CeilToInt(length / Step));
                for (int i = 0; i <= n; i++)
                {
                    float t = (float)i / n;
                    Vector3 c = road.EvaluatePosition(t), tan = road.EvaluateTangent(t);
                    tan.y = 0f;
                    var side = tan.sqrMagnitude > 1e-8f ? new Vector3(tan.z, 0f, -tan.x).normalized * (width / 2f) : Vector3.zero;
                    var outside = new[] { c, c + side, c - side }.Where(p => !map.Contains(new Vector2(p.x, p.z))).Select(p => (Vector3?)p).FirstOrDefault();
                    if (outside == null) continue;
                    var off = outside.Value;
                    entries.Add(new MapCheckEntry { severity = MapCheckSeverity.Warning, check = CheckOffMap, target = road,
                        message = $"{road.name} leaves the map near ({off.x:0}, {off.z:0}). Past the terrain edge it has no ground and no terrain type. Move its knots inside the map and bake it again.",
                        detail = $"First point outside the terrain x {map.xMin:0}..{map.xMax:0}, z {map.yMin:0}..{map.yMax:0}, at {t * length:0} m of {length:0} m along the road (band edge included)." });
                    break;
                }
            }
        }
    }

    public class RoadsWindow : EditorWindow
    {
        float width = Roads.DefaultWidth;
        Material material;
        Vector2 scroll;

        void OnEnable() => minSize = new Vector2(360f, 220f);
        void OnHierarchyChange() => Repaint();

        void OnGUI()
        {
            if (Terrain.activeTerrain == null)
            {
                EditorGUILayout.HelpBox("Open a map scene to draw roads in it.", MessageType.Info);
                return;
            }
            EditorGUILayout.HelpBox("Add a road, then shape it with Unity's spline tools (select the road, then the spline tool in the Scene view toolbar). " +
                "Bake lays the road mesh on the ground and paints the Road terrain type under it. Bake again after each change.", MessageType.None);
            width = Mathf.Max(0.5f, EditorGUILayout.FloatField(new GUIContent("Width of a new road (m)", $"At least {Roads.MinWidth:0} m, so the cells along it get the Road terrain type."), width));
            material = (Material)EditorGUILayout.ObjectField(new GUIContent("Material", "Empty: the road keeps its material, or a new road takes the biome's road material."), material, typeof(Material), false);
            if (GUILayout.Button("Add road"))
            {
                var sv = SceneView.lastActiveSceneView;
                Roads.AddRoad(sv != null ? sv.pivot : Vector3.zero, width);
            }
            EditorGUILayout.Space();
            var roads = Roads.All();
            if (roads.Length == 0) EditorGUILayout.LabelField("This map has no roads yet.");
            scroll = EditorGUILayout.BeginScrollView(scroll);
            foreach (var road in roads)
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button(road.name, EditorStyles.miniButtonLeft, GUILayout.MinWidth(90f))) { Selection.activeGameObject = road.gameObject; SceneView.FrameLastActiveSceneView(); }
                EditorGUI.BeginChangeCheck();
                float w = EditorGUILayout.FloatField(Roads.GetWidth(road), GUILayout.Width(50f));
                if (EditorGUI.EndChangeCheck()) Roads.SetWidth(road, Mathf.Max(0.5f, w));
                GUILayout.Label("m", GUILayout.Width(16f));
                GUILayout.Label(Roads.MeshObject(road) != null ? "baked" : "not baked", GUILayout.Width(64f));
                if (GUILayout.Button("Bake", EditorStyles.miniButtonRight, GUILayout.Width(50f)))
                {
                    try { var r = Roads.Bake(road, material); Debug.Log($"UCU Map Kit: baked {r.road}: {r.length:0} m, {r.vertices} vertices, {r.texelsSet} road texels set, {r.texelsCleared} cleared."); }
                    catch (Exception e) { EditorUtility.DisplayDialog("UCU Map Kit", e.Message, "OK"); }
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndScrollView();
        }
    }
}
