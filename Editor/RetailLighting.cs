// UCU Map Kit: "Prepare Lighting from Retail" (map-kit KE2). An extracted retail map carries none of retail's realtime GI: the
// import keeps a LightingData whose Enlighten scene mapping is empty and whose Enlighten bundle is a bare header (retail ships the
// system data in BattleTech_Data/GI/<level>, outside the level file), and its renderers' ContributeGI flags are not retail's bake
// set. So the map has to be baked again, and a plain bake is far too large: the split meshes keep half-precision realtime UVs,
// which the precompute rejects (one minimum chart per triangle, about 609x retail on taiga; gbrain
// lessons/enlighten-half-precision-uv2-per-triangle-charts).
//
// This step sets the open scene up so Bake lighting reproduces retail's layout, from retail's own numbers. It ports the inputs of
// UCU's gi-weld route (tools/gi-weld: retail_systems.py, sysrect.py's sources, the system tag per retail system), not its proxies:
// gi-weld welds proxies because UCU's props are static-batched; a kit map's props are split into their own renderers, so they are
// baked as themselves and bind through the LightingData with no binder.
//   - retail's renderer rows (renderer, system) come from the retail LightingData the extraction keeps beside the map's logs
//     (MapKitOutput/retail-maps/<map>/retail-LightingData.asset, AssetRipper's YAML), and each system's size (w x h texels) from
//     the retail install's GI/<level> files (the .rsc.sse header, as tools/gi-weld/gisys.py reads it);
//   - ContributeGI goes on exactly for retail's rows and the terrain, and off for every other renderer (they take light probes);
//   - the realtime UV channel (uv3) of those renderers' meshes is rewritten at full precision (same values);
//   - each retail system gets a LightmapParameters with systemTag = system + 1 and a resolution chosen so the system's world area
//     comes to its retail texel count at MapBake.RealtimeResolution, less Unity's measured chart overhead (ChartOverhead); the
//     terrain's Scale In Lightmap gives retail's chunk density;
//   - the retail reference (texels and bytes of all the map's retail systems) is written for MapBake's 2x gate.
// shortcut: ChartOverhead was measured on one map (taiga, KE2 bake 1: area-calibrated prop systems came to 2.32x their retail
// texels); a map whose props chart differently lands elsewhere, and the post-bake gate measures it. Upgrade to a per-map figure if
// another extracted map misses the gate. (Matching each renderer's own retail footprint instead split taiga into 84 systems.)
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;

namespace UCU.MapKit
{
    [Serializable]
    public class RetailGIReference
    {
        public string map, level;
        public int systems, terrainSystems, rows, rowsFound, contributors, meshesRewritten;
        public long texels, bytes;
        public string note;
        public override string ToString() => $"{map} ({level}): {systems} retail systems ({terrainSystems} terrain), {texels:N0} texels, {bytes:N0} B; " +
            $"{rowsFound}/{rows} retail renderer rows found, {contributors} contributors, {meshesRewritten} meshes given full-precision uv3";
    }

    public static class RetailLighting
    {
        public static string RetailLightingDataFile(string map) => Path.Combine(RetailMaps.WorkDir(map), "retail-LightingData.asset");
        static string Folder(string scenePath) => Path.Combine(Path.GetDirectoryName(scenePath), Path.GetFileNameWithoutExtension(scenePath) + "_RetailGI").Replace('\\', '/');
        static string ReferenceFile(string scenePath) => Folder(scenePath) + "/retail-gi.json";

        /// <summary>The retail reference written by Prepare for this scene, or null (MapBake then uses its terrain-only reference).</summary>
        public static RetailGIReference Reference(string scenePath)
        {
            var f = string.IsNullOrEmpty(scenePath) ? null : ReferenceFile(scenePath);
            return f != null && File.Exists(f) ? JsonUtility.FromJson<RetailGIReference>(File.ReadAllText(f)) : null;
        }

        [MenuItem("UCU Map Kit/Setup/Prepare Lighting from Retail")]
        static void PrepareMenu()
        {
            var scene = EditorSceneManager.GetActiveScene();
            try
            {
                var r = Prepare();
                EditorUtility.DisplayDialog("UCU Map Kit", r + ".\n\nSave the scene, then Bake Lighting.", "OK");
            }
            catch (Exception e) { EditorUtility.DisplayDialog("UCU Map Kit", e.Message, "OK"); }
        }

        class Row { public long fid; public int sys; }
        public const double ChartOverhead = 65824.0 / 28392.0;

        /// <summary>Sets up the open scene from the retail map <paramref name="map"/> (default: the retail map the scene comes from,
        /// RetailMaps.SourceMap: its own name, or the map a Save As copy was saved from). Leaves the scene dirty; mesh and
        /// LightmapParameters assets are written.</summary>
        public static RetailGIReference Prepare(string map = null)
        {
            var scene = EditorSceneManager.GetActiveScene();
            if (string.IsNullOrEmpty(scene.path)) throw new InvalidOperationException("Save the map scene first.");
            map = string.IsNullOrEmpty(map) ? RetailMaps.SourceMap(scene.path) ?? throw new InvalidOperationException(RetailMaps.NoSource(scene.name)) : map;
            var entry = RetailMaps.LoadCatalog().FirstOrDefault(m => m.id == map) ?? throw new InvalidOperationException($"{map} is not in the retail map catalog; this step needs a map extracted from retail.");
            var ldFile = RetailLightingDataFile(map);
            if (!File.Exists(ldFile)) throw new FileNotFoundException($"No retail LightingData for {map}: extract the map again (the extraction keeps it).", ldFile);
            var install = RetailMaps.RetailInstall;
            var bad = RetailMaps.InstallProblem(install);
            if (bad != null) throw new InvalidOperationException(bad);
            var giDir = Path.Combine(install, "BattleTech_Data", "GI", entry.level);
            if (!Directory.Exists(giDir)) throw new DirectoryNotFoundException($"The retail install has no GI/{entry.level}.");
            var terrain = Terrain.activeTerrain ?? throw new InvalidOperationException(MapPreconditions.NoTerrain);

            // Retail LightingData (YAML): renderer rows, systems (radiosity hash names the GI files), terrain chunks.
            var text = File.ReadAllText(ldFile);
            string Section(string a, string b) { int i = text.IndexOf(a, StringComparison.Ordinal), j = text.IndexOf(b, i < 0 ? 0 : i, StringComparison.Ordinal); if (i < 0 || j < 0) throw new InvalidDataException($"{ldFile} has no {a} section."); return text.Substring(i, j - i); }
            var rows = Regex.Matches(Section("m_Renderers:", "m_Systems:"), @"renderer: \{fileID: (-?\d+)[^}]*\}\s+dynamicLightmapSTInSystem: \{[^}]*\}\s+systemId: (\d+)")
                .Cast<Match>().Select(m => new Row { fid = long.Parse(m.Groups[1].Value), sys = int.Parse(m.Groups[2].Value) }).ToList();
            var sysHashes = Regex.Matches(Section("m_Systems:", "m_Probesets:"), @"radiositySystemHash:\s+serializedVersion: 2\s+Hash: (\w+)").Cast<Match>().Select(m => m.Groups[1].Value).ToList();
            var tc = Regex.Match(Section("m_TerrainChunks:", "m_EnlightenSceneMappingRendererIDs:"), @"firstSystemId: (\d+)\s+numChunksInX: (\d+)\s+numChunksInY: (\d+)");
            if (rows.Count == 0 || sysHashes.Count == 0) throw new InvalidDataException($"{ldFile} lists no renderers or no systems.");
            int firstTerrain = tc.Success ? int.Parse(tc.Groups[1].Value) : int.MaxValue, chunksX = tc.Success ? int.Parse(tc.Groups[2].Value) : 0;
            int terrainSystems = tc.Success ? chunksX * int.Parse(tc.Groups[3].Value) : 0;

            var r = new RetailGIReference { map = map, level = entry.level, systems = sysHashes.Count, terrainSystems = terrainSystems };
            var size = new (int w, int h)[sysHashes.Count];
            for (int s = 0; s < sysHashes.Count; s++)
            {
                var name = WordSwap(sysHashes[s]);
                var dir = Path.Combine(giDir, name.Substring(0, 2));
                var rsc = File.ReadAllBytes(Path.Combine(dir, name + ".rsc.sse"));
                if (rsc.Length < 0x20 || rsc[0] != 0x74 || rsc[1] != 0x51 || rsc[2] != 0x10 || rsc[3] != 0xad) throw new InvalidDataException($"{name}.rsc.sse is not an Enlighten file.");
                size[s] = (BitConverter.ToInt32(rsc, 0x18), BitConverter.ToInt32(rsc, 0x1c));
                r.texels += size[s].w * size[s].h;
                foreach (var ext in new[] { "caw", "ecm", "iws.sse", "rgb", "rsc.sse", "vis" })
                {
                    var f = Path.Combine(dir, name + "." + ext);
                    if (File.Exists(f)) r.bytes += new FileInfo(f).Length;
                }
            }

            // The scene's renderers by file ID (an extracted scene keeps retail's IDs).
            var byId = new Dictionary<ulong, MeshRenderer>();
            foreach (var mr in UnityEngine.Object.FindObjectsByType<MeshRenderer>(FindObjectsInactive.Include))
                byId[GlobalObjectId.GetGlobalObjectIdSlow(mr).targetObjectId] = mr;
            var sysOf = new Dictionary<MeshRenderer, int>();
            foreach (var row in rows.Where(x => x.sys < firstTerrain))
            {
                r.rows++;
                if (byId.TryGetValue((ulong)row.fid, out var mr)) { sysOf[mr] = row.sys; r.rowsFound++; }
            }
            // Straight from the extraction, a retail map's props still draw ranges of retail's static-batched combined meshes
            // ("Combined Mesh (root: scene) n", m_StaticBatchInfo set). Those meshes are not readable, so every system's area reads 0 and
            // none gets its LightmapParameters; Unity's bake also drops some of them ("Invalid format for channel(s)") and lays the rest
            // out as hundreds of systems (map-kit KFIX7: 200 against retail's 12, stopped by the 2x watch; KE2's 15 systems were on a
            // copy whose props Build Object Library had split). So the step refuses until the props are split.
            int batched = sysOf.Keys.Count(m => new SerializedObject(m).FindProperty("m_StaticBatchInfo.subMeshCount").intValue > 0);
            if (batched > 0)
                throw new InvalidOperationException($"{batched} of the {sysOf.Count} objects retail lit on this map still draw from retail's combined (static-batched) meshes, which the bake can't size. " +
                    "Run UCU Map Kit > Setup > Build Object Library… on this map first, save it, then run Prepare Lighting from Retail again.");

            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName("Prepare Lighting from Retail");
            var folder = Folder(scene.path);
            Directory.CreateDirectory(folder);
            var area = new double[sysHashes.Count];
            foreach (var kv in sysOf) area[kv.Value] += WorldArea(kv.Key);
            var param = new LightmapParameters[sysHashes.Count];
            var basis = AssetDatabase.GetBuiltinExtraResource<LightmapParameters>("LightmapParameters/Default-Medium.giparams");
            for (int s = 0; s < firstTerrain && s < sysHashes.Count; s++)
            {
                if (area[s] <= 0) continue;
                var path = $"{folder}/system{s}.giparams";
                var p = AssetDatabase.LoadAssetAtPath<LightmapParameters>(path);
                if (p == null) { p = new LightmapParameters(); EditorUtility.CopySerialized(basis, p); AssetDatabase.CreateAsset(p, path); }
                p.systemTag = s + 1;
                p.resolution = (float)(Math.Sqrt(size[s].w * size[s].h / (area[s] * ChartOverhead)) / MapBake.RealtimeResolution);
                EditorUtility.SetDirty(p);
                AssetDatabase.SaveAssetIfDirty(p);
                param[s] = p;
            }

            var rewritten = new HashSet<Mesh>();
            foreach (var mr in UnityEngine.Object.FindObjectsByType<MeshRenderer>(FindObjectsInactive.Include))
            {
                var flags = GameObjectUtility.GetStaticEditorFlags(mr.gameObject);
                bool contributes = sysOf.TryGetValue(mr, out int sys);
                var want = contributes ? flags | StaticEditorFlags.ContributeGI : flags & ~StaticEditorFlags.ContributeGI;
                var so = new SerializedObject(mr);
                Undo.RecordObject(mr.gameObject, "Prepare Lighting from Retail");
                Undo.RecordObject(mr, "Prepare Lighting from Retail");
                if (want != flags) GameObjectUtility.SetStaticEditorFlags(mr.gameObject, want);
                so.Update();
                so.FindProperty("m_LightmapParameters").objectReferenceValue = contributes ? param[sys] : null;
                so.FindProperty("m_ScaleInLightmap").floatValue = 1f;
                so.ApplyModifiedProperties();
                if (contributes) { mr.receiveGI = ReceiveGI.Lightmaps; r.contributors++; }
                if (!contributes) continue;
                var mesh = mr.GetComponent<MeshFilter>() ? mr.GetComponent<MeshFilter>().sharedMesh : null;
                if (mesh == null || rewritten.Contains(mesh) || !mesh.HasVertexAttribute(VertexAttribute.TexCoord2) || mesh.GetVertexAttributeFormat(VertexAttribute.TexCoord2) == VertexAttributeFormat.Float32) continue;
                var uv = new List<Vector2>();
                mesh.GetUVs(2, uv);
                mesh.SetUVs(2, uv);   // full precision, same values: the precompute rejects Float16 realtime UVs
                EditorUtility.SetDirty(mesh);
                if (!string.IsNullOrEmpty(AssetDatabase.GetAssetPath(mesh))) AssetDatabase.SaveAssetIfDirty(mesh);
                rewritten.Add(mesh);
            }
            r.meshesRewritten = rewritten.Count;

            // Terrain: in retail's bake, at retail's chunk density (texels per metre of one chunk system).
            if (terrainSystems > 0 && firstTerrain < size.Length)
            {
                Undo.RecordObject(terrain.gameObject, "Prepare Lighting from Retail");
                Undo.RecordObject(terrain, "Prepare Lighting from Retail");
                GameObjectUtility.SetStaticEditorFlags(terrain.gameObject, GameObjectUtility.GetStaticEditorFlags(terrain.gameObject) | StaticEditorFlags.ContributeGI);
                var density = size[firstTerrain].w / (terrain.terrainData.size.x / chunksX);
                var tso = new SerializedObject(terrain);
                tso.FindProperty("m_ScaleInLightmap").floatValue = density / MapBake.RealtimeResolution;
                tso.ApplyModifiedProperties();
            }
            r.note = "per-system resolution from world area and retail texels, less the chart overhead measured on taiga (ChartOverhead)";
            File.WriteAllText(ReferenceFile(scene.path), JsonUtility.ToJson(r, true));
            AssetDatabase.ImportAsset(ReferenceFile(scene.path));
            EditorSceneManager.MarkSceneDirty(scene);
            Debug.Log("UCU Map Kit: Prepare Lighting from Retail: " + r);
            return r;
        }

        // Retail names a system's GI files by its radiosity hash with each 32-bit word's bytes reversed (tools/gi-weld/gisys.py wswap).
        static string WordSwap(string h)
        {
            var o = new System.Text.StringBuilder(32);
            for (int i = 0; i < 32; i += 8) o.Append(h, i + 6, 2).Append(h, i + 4, 2).Append(h, i + 2, 2).Append(h, i, 2);
            return o.ToString();
        }

        static double WorldArea(MeshRenderer mr)
        {
            var mf = mr.GetComponent<MeshFilter>();
            var m = mf ? mf.sharedMesh : null;
            if (m == null || !m.isReadable) return 0;
            var v = m.vertices; var t = m.triangles; var M = mr.localToWorldMatrix; double a = 0;
            for (int i = 0; i < t.Length; i += 3)
            {
                Vector3 p = M.MultiplyPoint3x4(v[t[i]]);
                a += 0.5 * Vector3.Cross(M.MultiplyPoint3x4(v[t[i + 1]]) - p, M.MultiplyPoint3x4(v[t[i + 2]]) - p).magnitude;
            }
            return a;
        }
    }
}
