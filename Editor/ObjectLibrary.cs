// UCU Map Kit: Build Object Library (plan .hermes/plans/2026-11-19-map-kit.md -> KS steps 2-4). An extracted retail map's
// static-batched renderers draw a range of a combined mesh ("Combined Mesh (root: scene) n") whose vertices retail baked to
// world space: the renderer's m_StaticBatchInfo names its sub-meshes and its MeshFilter names the combined mesh, so the object
// can't be moved or reused. This step cuts each renderer's vertex and index range out of the combined mesh, moves the vertices
// back by the renderer's inverse transform, dedupes the blocks by content, writes them as meshes plus one prefab per distinct
// object (with its own HBS components, colliders and layer) into Assets/MapKitLibrary, and points the scene's renderers at the
// split meshes with m_StaticBatchInfo cleared. The scene change is one Undo step; the library files stay on disk.
// Decoding reference: setup/batch_ranges.py (KS1). Run it on a map opened from an extraction, before any edit.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using BattleTech;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    public static class ObjectLibrary
    {
        public const string LibraryRoot = "Assets/MapKitLibrary";
        public const string UndoName = "Build Object Library";
        /// <summary>The size gate (map-kit plan KS step 3): the split scene's meshes plus the library, over the extraction's own mesh bytes.</summary>
        public const double SizeGate = 2.0;

        [MenuItem("UCU Map Kit/Setup/Build Object Library…")]
        static void Menu()
        {
            var plan = Plan(SceneManager.GetActiveScene());
            if (plan.error != null) { EditorUtility.DisplayDialog(UndoName, plan.error, "OK"); return; }
            if (!EditorUtility.DisplayDialog(UndoName, plan.Summary() + "\n\nWrite the library and point the scene's renderers at it?", "Build", "Cancel")) return;
            Debug.Log(Build(plan));
        }

        /// <summary>Plan and build without the dialog (the agent and batch route). Returns the summary, or the reason nothing was written.</summary>
        public static string Run(Scene scene)
        {
            var plan = Plan(scene);
            return plan.error != null ? "NOT BUILT: " + plan.error : Build(plan);
        }

        // ------------------------------------------------------------------ the read: cut, transform, dedupe, size
        public class Block
        {
            public MeshRenderer renderer;
            public MeshFilter filter;
            public Mesh combined;
            public VertexAttributeDescriptor[] attrs;
            public byte[][] streams;        // per stream: vertexCount * stride, in the object's local space
            public int vertexCount;
            public int[][] indices;         // per sub-mesh, relative to the block's first vertex
            public MeshTopology[] topology;
            public double[] localPos;       // for the tolerance compare
            public double tol;
            public bool mirrored;
            public string contentKey;       // everything the inverse transform does not touch
            public Block rep;               // the block whose mesh this renderer uses
            public string hash;             // rep only: the library mesh's file-name hash
            public string meshPath;
        }

        public class ObjectEntry
        {
            public Transform root;
            public string key, prefabPath;
            public ObjectEntry rep;
            public int components;
        }

        public class LibraryPlan
        {
            public Scene scene;
            public string error;
            public List<Block> blocks = new List<Block>();
            public List<Block> reps = new List<Block>();
            public List<ObjectEntry> objects = new List<ObjectEntry>();
            public List<ObjectEntry> prefabReps = new List<ObjectEntry>();
            public int renderers, mirrored, multiSub, combinedMeshes;
            public long extractionMeshBytes, combinedBytes, libraryMeshEstimate, prefabEstimate;
            public double Ratio => extractionMeshBytes == 0 ? 0 : (double)(extractionMeshBytes - combinedBytes + libraryMeshEstimate + prefabEstimate) / extractionMeshBytes;

            public string Summary() =>
                $"{scene.name}: {renderers} renderers, {blocks.Count} static-batched in {combinedMeshes} combined meshes " +
                $"({mirrored} mirrored, {multiSub} with more than one sub-mesh). Unique meshes {reps.Count}, objects {objects.Count}, prefabs {prefabReps.Count}. " +
                $"Size estimate: library {Mb(libraryMeshEstimate + prefabEstimate)} (meshes {Mb(libraryMeshEstimate)}, prefabs {Mb(prefabEstimate)}); " +
                $"scene meshes after the split {Mb(extractionMeshBytes - combinedBytes + libraryMeshEstimate + prefabEstimate)} vs the extraction's {Mb(extractionMeshBytes)} " +
                $"(combined {Mb(combinedBytes)}): {Ratio:0.00}x, gate {SizeGate:0.0}x.";
        }

        static string Mb(long b) => $"{b / 1e6:0.0} MB";

        public static LibraryPlan Plan(Scene scene)
        {
            var plan = new LibraryPlan { scene = scene };
            if (!scene.IsValid() || string.IsNullOrEmpty(scene.path)) { plan.error = "Open a saved map scene first."; return plan; }
            var all = scene.GetRootGameObjects().SelectMany(g => g.GetComponentsInChildren<MeshRenderer>(true)).ToList();
            plan.renderers = all.Count;
            var batched = new List<(MeshRenderer r, MeshFilter f, int first, int count)>();
            foreach (var r in all)
            {
                var so = new SerializedObject(r);
                int count = so.FindProperty("m_StaticBatchInfo.subMeshCount").intValue;
                if (count == 0) continue;
                var f = r.GetComponent<MeshFilter>();
                if (f == null || f.sharedMesh == null) { plan.error = $"{MapCheck.PathOf(r.transform)} is static-batched but has no mesh."; return plan; }
                batched.Add((r, f, so.FindProperty("m_StaticBatchInfo.firstSubMesh").intValue, count));
            }
            if (batched.Count == 0) { plan.error = $"{scene.name} has no static-batched renderers: nothing to split."; return plan; }

            var meshes = batched.Select(b => b.f.sharedMesh).Distinct().ToList();
            plan.combinedMeshes = meshes.Count;
            var src = new Dictionary<Mesh, Source>();
            using (var data = Mesh.AcquireReadOnlyMeshData(meshes))
                for (int i = 0; i < meshes.Count; i++) src[meshes[i]] = new Source(meshes[i], data[i]);

            foreach (var (r, f, first, count) in batched)
            {
                var s = src[f.sharedMesh];
                if (first + count > s.subs.Length) { plan.error = $"{MapCheck.PathOf(r.transform)}: sub-meshes {first}..{first + count - 1} are past the {s.subs.Length} of {f.sharedMesh.name}."; return plan; }
                var b = Cut(r, f, s, first, count, out var err);
                if (b == null) { plan.error = $"{MapCheck.PathOf(r.transform)}: {err}"; return plan; }
                plan.blocks.Add(b);
                if (b.mirrored) plan.mirrored++;
                if (count > 1) plan.multiSub++;
            }

            // dedupe: same content key, positions within the larger of the two float32-world errors
            var groups = new Dictionary<string, List<Block>>();
            foreach (var b in plan.blocks)
            {
                if (!groups.TryGetValue(b.contentKey, out var reps)) groups[b.contentKey] = reps = new List<Block>();
                b.rep = reps.FirstOrDefault(p => MaxDiff(p.localPos, b.localPos) <= Math.Max(p.tol, b.tol));
                if (b.rep == null) { reps.Add(b); b.rep = b; plan.reps.Add(b); }
            }
            foreach (var b in plan.reps)
            {
                b.hash = Hash(b.streams.Concat(new[] { IndexBytes(b) }));
                b.meshPath = $"{LibraryRoot}/Meshes/{Clean(b.renderer.name)}_{b.hash}.asset";
                plan.libraryMeshEstimate += 2L * (b.streams.Sum(x => x.LongLength) + IndexBytes(b).LongLength) + 2048;  // text YAML: hex doubles the bytes
            }

            // objects and their prefabs: one prefab per distinct object
            var byRoot = new Dictionary<Transform, ObjectEntry>();
            var blockOf = plan.blocks.ToDictionary(b => b.renderer);
            foreach (var b in plan.blocks)
            {
                var root = ObjectRoot(b.renderer.transform);
                if (!byRoot.ContainsKey(root)) byRoot[root] = new ObjectEntry { root = root };
            }
            var keys = new Dictionary<string, ObjectEntry>();
            foreach (var o in byRoot.Values)
            {
                o.key = ObjectKey(o.root, blockOf, out o.components);
                plan.objects.Add(o);
                if (keys.TryGetValue(o.key, out var rep)) { o.rep = rep; continue; }
                o.rep = o; keys[o.key] = o; plan.prefabReps.Add(o);
                o.prefabPath = $"{LibraryRoot}/Prefabs/{Clean(o.root.name)}_{Hash(new[] { Encoding.UTF8.GetBytes(o.key) })}.prefab";
                plan.prefabEstimate += 1024L * o.components;
            }

            // the extraction's own mesh bytes: the Mesh assets the scene depends on
            foreach (var p in AssetDatabase.GetDependencies(scene.path, true))
                if (AssetDatabase.GetMainAssetTypeAtPath(p) == typeof(Mesh) && File.Exists(p)) plan.extractionMeshBytes += new FileInfo(p).Length;
            foreach (var m in meshes)
            {
                var p = AssetDatabase.GetAssetPath(m);
                if (File.Exists(p)) plan.combinedBytes += new FileInfo(p).Length;
            }
            if (plan.Ratio > SizeGate) plan.error = "Size gate: " + plan.Summary();
            return plan;
        }

        class Source
        {
            public SubMeshDescriptor[] subs;
            public int[] index;
            public byte[][] streams;
            public int[] stride;
            public VertexAttributeDescriptor[] attrs;
            public int[] offset;  // per attrs entry

            public Source(Mesh m, Mesh.MeshData d)
            {
                attrs = m.GetVertexAttributes();
                offset = attrs.Select(a => m.GetVertexAttributeOffset(a.attribute)).ToArray();
                stride = Enumerable.Range(0, d.vertexBufferCount).Select(m.GetVertexBufferStride).ToArray();
                streams = Enumerable.Range(0, d.vertexBufferCount).Select(s => d.GetVertexData<byte>(s).ToArray()).ToArray();
                index = d.indexFormat == IndexFormat.UInt16 ? d.GetIndexData<ushort>().Select(x => (int)x).ToArray() : d.GetIndexData<uint>().Select(x => (int)x).ToArray();
                subs = Enumerable.Range(0, d.subMeshCount).Select(i => d.GetSubMesh(i)).ToArray();
            }
        }

        static Block Cut(MeshRenderer r, MeshFilter f, Source s, int first, int count, out string err)
        {
            err = null;
            var subs = s.subs.Skip(first).Take(count).ToArray();
            int v0 = subs.Min(x => x.firstVertex), v1 = subs.Max(x => x.firstVertex + x.vertexCount), vc = v1 - v0;
            var b = new Block { renderer = r, filter = f, combined = f.sharedMesh, attrs = s.attrs, vertexCount = vc, topology = subs.Select(x => x.topology).ToArray() };
            b.streams = s.streams.Select((x, i) => { var o = new byte[vc * s.stride[i]]; Buffer.BlockCopy(x, v0 * s.stride[i], o, 0, o.Length); return o; }).ToArray();
            b.indices = new int[count][];
            for (int k = 0; k < count; k++)
            {
                var d = subs[k]; var ix = new int[d.indexCount];
                for (int i = 0; i < ix.Length; i++)
                {
                    ix[i] = s.index[d.indexStart + i] + d.baseVertex - v0;
                    if (ix[i] < 0 || ix[i] >= vc) { err = $"index {ix[i] + v0} of sub-mesh {first + k} is outside its vertex range {v0}..{v1 - 1}"; return null; }
                }
                b.indices[k] = ix;
            }

            // world -> the renderer's local space. Positions by the inverse matrix; normals by its inverse-transpose (n_local ~ M^T n_world);
            // tangents by the inverse linear part, w kept (retail's bake kept it, and unity_WorldTransformParams.w restores the mirror sign).
            Matrix4x4 W = r.transform.localToWorldMatrix;
            var M = new double[3, 3];
            for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) M[i, j] = W[i, j];
            double det = M[0, 0] * (M[1, 1] * M[2, 2] - M[1, 2] * M[2, 1]) - M[0, 1] * (M[1, 0] * M[2, 2] - M[1, 2] * M[2, 0]) + M[0, 2] * (M[1, 0] * M[2, 1] - M[1, 1] * M[2, 0]);
            if (Math.Abs(det) < 1e-12) { err = "its transform is singular (a zero scale)"; return null; }
            var Mi = new double[3, 3];
            for (int i = 0; i < 3; i++)
                for (int j = 0; j < 3; j++)
                {
                    int a0 = (j + 1) % 3, a1 = (j + 2) % 3, b0 = (i + 1) % 3, b1 = (i + 2) % 3;
                    Mi[i, j] = (M[a0, b0] * M[a1, b1] - M[a0, b1] * M[a1, b0]) / det;
                }
            double[] T = { W.m03, W.m13, W.m23 };
            b.mirrored = det < 0;
            // float32 world positions (under about 1e3 m) carry about 1e-4 m of error; the inverse scale carries it into local units (KS1)
            b.tol = 2 * 2e-4 * Enumerable.Range(0, 3).Max(i => Math.Abs(Mi[i, 0]) + Math.Abs(Mi[i, 1]) + Math.Abs(Mi[i, 2]));
            b.localPos = new double[vc * 3];
            var MT = Transpose(M);

            var keyBytes = b.streams.Select(x => (byte[])x.Clone()).ToArray();
            for (int a = 0; a < s.attrs.Length; a++)
            {
                var at = s.attrs[a];
                if (at.attribute != VertexAttribute.Position && at.attribute != VertexAttribute.Normal && at.attribute != VertexAttribute.Tangent) continue;
                if (at.dimension < 3) { err = $"{at.attribute} has {at.dimension} components"; return null; }
                int st = s.stride[at.stream], off = s.offset[a], cs = CompSize(at.format);
                if (cs == 0) { err = $"{at.attribute} format {at.format} is not supported"; return null; }
                var buf = b.streams[at.stream];
                for (int v = 0; v < vc; v++)
                {
                    int o = v * st + off;
                    double x = Read(buf, o, at.format), y = Read(buf, o + cs, at.format), z = Read(buf, o + 2 * cs, at.format);
                    double lx, ly, lz;
                    if (at.attribute == VertexAttribute.Position)
                    {
                        x -= T[0]; y -= T[1]; z -= T[2];
                        lx = Mi[0, 0] * x + Mi[0, 1] * y + Mi[0, 2] * z; ly = Mi[1, 0] * x + Mi[1, 1] * y + Mi[1, 2] * z; lz = Mi[2, 0] * x + Mi[2, 1] * y + Mi[2, 2] * z;
                        b.localPos[v * 3] = lx; b.localPos[v * 3 + 1] = ly; b.localPos[v * 3 + 2] = lz;
                    }
                    else
                    {
                        var m = at.attribute == VertexAttribute.Normal ? MT : Mi;
                        lx = m[0, 0] * x + m[0, 1] * y + m[0, 2] * z; ly = m[1, 0] * x + m[1, 1] * y + m[1, 2] * z; lz = m[2, 0] * x + m[2, 1] * y + m[2, 2] * z;
                        double n = Math.Sqrt(lx * lx + ly * ly + lz * lz);
                        if (n > 1e-12) { lx /= n; ly /= n; lz /= n; }
                    }
                    Write(buf, o, at.format, lx); Write(buf, o + cs, at.format, ly); Write(buf, o + 2 * cs, at.format, lz);
                    for (int c = 0; c < 3 * cs; c++) keyBytes[at.stream][o + c] = 0;
                }
            }
            // a mirrored bake had its winding reversed so it faced out at identity; under the mirrored transform again it goes back
            if (b.mirrored)
                for (int k = 0; k < count; k++)
                {
                    var ix = b.indices[k];
                    if (b.topology[k] == MeshTopology.Triangles) for (int i = 0; i + 2 < ix.Length; i += 3) (ix[i + 1], ix[i + 2]) = (ix[i + 2], ix[i + 1]);
                    else if (b.topology[k] == MeshTopology.Quads) for (int i = 0; i + 3 < ix.Length; i += 4) (ix[i + 1], ix[i + 3]) = (ix[i + 3], ix[i + 1]);
                }
            var layout = string.Join(";", s.attrs.Select(x => $"{x.attribute}{x.format}{x.dimension}{x.stream}"));
            b.contentKey = $"{vc}|{layout}|{string.Join(",", b.topology)}|" + Hash(keyBytes.Concat(new[] { IndexBytes(b) }));
            return b;
        }

        static double[,] Transpose(double[,] m)
        {
            var t = new double[3, 3];
            for (int i = 0; i < 3; i++) for (int j = 0; j < 3; j++) t[i, j] = m[j, i];
            return t;
        }

        static int CompSize(VertexAttributeFormat f)
        {
            switch (f)
            {
                case VertexAttributeFormat.Float32: return 4;
                case VertexAttributeFormat.Float16: case VertexAttributeFormat.UNorm16: case VertexAttributeFormat.SNorm16: return 2;
                case VertexAttributeFormat.UNorm8: case VertexAttributeFormat.SNorm8: return 1;
                default: return 0;
            }
        }

        static double Read(byte[] b, int o, VertexAttributeFormat f)
        {
            switch (f)
            {
                case VertexAttributeFormat.Float32: return BitConverter.ToSingle(b, o);
                case VertexAttributeFormat.Float16: return Mathf.HalfToFloat(BitConverter.ToUInt16(b, o));
                case VertexAttributeFormat.UNorm16: return BitConverter.ToUInt16(b, o) / 65535.0;
                case VertexAttributeFormat.SNorm16: return Math.Max(BitConverter.ToInt16(b, o) / 32767.0, -1);
                case VertexAttributeFormat.UNorm8: return b[o] / 255.0;
                default: return Math.Max((sbyte)b[o] / 127.0, -1);
            }
        }

        static void Write(byte[] b, int o, VertexAttributeFormat f, double v)
        {
            switch (f)
            {
                case VertexAttributeFormat.Float32: Buffer.BlockCopy(BitConverter.GetBytes((float)v), 0, b, o, 4); return;
                case VertexAttributeFormat.Float16: Buffer.BlockCopy(BitConverter.GetBytes(Mathf.FloatToHalf((float)v)), 0, b, o, 2); return;
                case VertexAttributeFormat.UNorm16: Buffer.BlockCopy(BitConverter.GetBytes((ushort)Math.Round(Math.Min(Math.Max(v, 0), 1) * 65535)), 0, b, o, 2); return;
                case VertexAttributeFormat.SNorm16: Buffer.BlockCopy(BitConverter.GetBytes((short)Math.Round(Math.Min(Math.Max(v, -1), 1) * 32767)), 0, b, o, 2); return;
                case VertexAttributeFormat.UNorm8: b[o] = (byte)Math.Round(Math.Min(Math.Max(v, 0), 1) * 255); return;
                default: b[o] = (byte)(sbyte)Math.Round(Math.Min(Math.Max(v, -1), 1) * 127); return;
            }
        }

        static byte[] IndexBytes(Block b)
        {
            var all = b.indices.SelectMany(x => x).ToArray();
            var o = new byte[all.Length * 4];
            Buffer.BlockCopy(all, 0, o, 0, o.Length);
            return o;
        }

        static double MaxDiff(double[] a, double[] b)
        {
            double m = 0;
            for (int i = 0; i < a.Length; i++) m = Math.Max(m, Math.Abs(a[i] - b[i]));
            return m;
        }

        static string Hash(IEnumerable<byte[]> parts)
        {
            using (var sha = SHA1.Create())
            {
                foreach (var p in parts) sha.TransformBlock(p, 0, p.Length, null, 0);
                sha.TransformFinalBlock(new byte[0], 0, 0);
                return BitConverter.ToString(sha.Hash, 0, 5).Replace("-", "").ToLowerInvariant();
            }
        }

        static string Clean(string name)
        {
            name = Regex.Replace(name, @"\s*\(\d+\)$", "");
            foreach (var c in Path.GetInvalidFileNameChars()) name = name.Replace(c, '_');
            return name.Trim();
        }

        /// <summary>The object a batched renderer belongs to: its nearest HBS game-logic owner (ObstructionGameLogic, BuildingRepresentation);
        /// else its LODGroup, raised through parents that hold nothing else.</summary>
        public static Transform ObjectRoot(Transform t)
        {
            for (var p = t; p != null; p = p.parent)
                if (p.GetComponent<ObstructionGameLogic>() != null || p.GetComponent<BuildingRepresentation>() != null) return p;
            var lod = t.GetComponentInParent<LODGroup>(true);
            var r = lod != null ? lod.transform : t;
            while (r.parent != null && r.parent.childCount == 1) r = r.parent;
            return r;
        }

        static readonly Regex InstanceRef = new Regex(@"\{""instanceID"":-?\d+\}");
        static readonly Regex GuidField = new Regex(@"""[A-Za-z]*[Gg]uid[A-Za-z]*"":""[^""]*""");

        /// <summary>What makes two objects the same prefab: the hierarchy below the root (names, local poses, layers), each component's
        /// type, the meshes (the library mesh for a batched renderer), materials and collider meshes, and the components' serialized values
        /// without per-instance GUIDs and object references. The root's own pose and name are the instance's.</summary>
        static string ObjectKey(Transform root, Dictionary<MeshRenderer, Block> blockOf, out int components)
        {
            var sb = new StringBuilder(); components = 0;
            foreach (var t in root.GetComponentsInChildren<Transform>(true))
            {
                sb.Append('[').Append(t == root ? "" : RelPath(root, t)).Append('|').Append(t.gameObject.layer).Append('|').Append(t.gameObject.activeSelf);
                if (t != root) sb.Append('|').Append(F(t.localPosition)).Append(F(t.localRotation.eulerAngles)).Append(F(t.localScale));
                foreach (var c in t.GetComponents<Component>())
                {
                    components++;
                    if (c == null) { sb.Append("|missing"); continue; }
                    sb.Append('|').Append(c.GetType().FullName);
                    switch (c)
                    {
                        case Transform _: break;
                        case MeshFilter mf:
                            var r = mf.GetComponent<MeshRenderer>();
                            sb.Append(':').Append(r != null && blockOf.TryGetValue(r, out var b) ? b.rep.hash : AssetId(mf.sharedMesh)); break;
                        case Renderer rr: sb.Append(':').Append(string.Join(",", rr.sharedMaterials.Select(AssetId))).Append(rr.enabled).Append(rr.shadowCastingMode); break;
                        case MeshCollider mc: sb.Append(':').Append(AssetId(mc.sharedMesh)).Append(mc.convex).Append(mc.isTrigger).Append(mc.enabled); break;
                        default: sb.Append(':').Append(GuidField.Replace(InstanceRef.Replace(EditorJsonUtility.ToJson(c), "{}"), "")); break;
                    }
                }
                sb.Append(']');
            }
            return sb.ToString();
        }

        static string RelPath(Transform root, Transform t)
        {
            var parts = new List<string>();
            for (var p = t; p != root; p = p.parent) parts.Add(p.name);
            parts.Reverse();
            return string.Join("/", parts);
        }

        static string F(Vector3 v) => $"({v.x:0.####},{v.y:0.####},{v.z:0.####})";

        static string AssetId(UnityEngine.Object o) =>
            o == null ? "null" : AssetDatabase.TryGetGUIDAndLocalFileIdentifier(o, out string g, out long id) ? $"{g}:{id}" : "scene:" + o.name;

        // ------------------------------------------------------------------ the write
        public static string Build(LibraryPlan plan)
        {
            var sw = System.Diagnostics.Stopwatch.StartNew();
            Folder(LibraryRoot + "/Meshes"); Folder(LibraryRoot + "/Prefabs");
            int newMeshes = 0, newPrefabs = 0;
            var lib = new Dictionary<Block, Mesh>();
            foreach (var b in plan.reps)
            {
                var m = AssetDatabase.LoadAssetAtPath<Mesh>(b.meshPath);
                if (m == null) { m = MakeMesh(b); AssetDatabase.CreateAsset(m, b.meshPath); newMeshes++; }
                lib[b] = m;
            }

            // prefabs: a copy of the object under an inactive holder (no OnEnable runs), its batched renderers on the library meshes
            var holder = new GameObject("MapKitLibrary-staging") { hideFlags = HideFlags.HideAndDontSave };
            holder.SetActive(false);
            var blockOf = plan.blocks.ToDictionary(b => b.renderer);
            try
            {
                foreach (var o in plan.prefabReps)
                {
                    if (File.Exists(o.prefabPath)) continue;
                    var copy = UnityEngine.Object.Instantiate(o.root.gameObject, holder.transform);
                    copy.name = Clean(o.root.name);
                    copy.transform.localPosition = Vector3.zero; copy.transform.localRotation = Quaternion.identity; copy.transform.localScale = Vector3.one;
                    var src = o.root.GetComponentsInChildren<Transform>(true); var dst = copy.GetComponentsInChildren<Transform>(true);
                    for (int i = 0; i < src.Length; i++)
                    {
                        var r = src[i].GetComponent<MeshRenderer>();
                        if (r == null || !blockOf.TryGetValue(r, out var b)) continue;
                        dst[i].GetComponent<MeshFilter>().sharedMesh = lib[b.rep];
                        ClearBatch(dst[i].GetComponent<MeshRenderer>());
                    }
                    PrefabUtility.SaveAsPrefabAsset(copy, o.prefabPath, out bool ok);
                    if (!ok) return $"NOT FINISHED: the prefab {o.prefabPath} did not save; {newMeshes} meshes and {newPrefabs} prefabs were written, the scene is unchanged.";
                    newPrefabs++;
                }
            }
            finally { UnityEngine.Object.DestroyImmediate(holder); }

            // the scene: one Undo step
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName(UndoName);
            int group = Undo.GetCurrentGroup();
            // Undo restores the MeshFilters but not m_StaticBatchInfo (measured on 6000.6.9f1, with SerializedObject's record and with
            // RecordObjects alike), so the batch info goes to a record beside the library and AfterUndoRedo puts it back.
            var ids = new GlobalObjectId[plan.blocks.Count];
            GlobalObjectId.GetGlobalObjectIdsSlow(plan.blocks.Select(b => (UnityEngine.Object)b.renderer).ToArray(), ids);
            var rec = RecordPath(plan.scene);
            Folder(Path.GetDirectoryName(rec).Replace('\\', '/'));
            File.WriteAllLines(rec, plan.blocks.Select((b, i) =>
            {
                var so = new SerializedObject(b.renderer);
                return $"{ids[i]}\t{so.FindProperty("m_StaticBatchInfo.firstSubMesh").intValue}\t{so.FindProperty("m_StaticBatchInfo.subMeshCount").intValue}";
            }));
            AssetDatabase.ImportAsset(rec);
            batchCache.Remove(CacheKey(plan.scene));
            Undo.RecordObjects(plan.blocks.SelectMany(b => new UnityEngine.Object[] { b.filter, b.renderer }).ToArray(), UndoName);
            foreach (var b in plan.blocks)
            {
                b.filter.sharedMesh = lib[b.rep];
                ClearBatch(b.renderer);
            }
            Undo.CollapseUndoOperations(group);
            Undo.IncrementCurrentGroup();  // the next edit is its own step, never part of this one
            EditorSceneManager.MarkSceneDirty(plan.scene);
            return plan.Summary() + $" Written: {newMeshes} new meshes, {newPrefabs} new prefabs ({plan.reps.Count - newMeshes} and {plan.prefabReps.Count - newPrefabs} already there). " +
                   $"{plan.blocks.Count} renderers now draw their own mesh; save the scene to keep it ({sw.Elapsed.TotalSeconds:0.0} s).";
        }

        /// <summary>The scene's static-batch record: each split renderer's GlobalObjectId and its m_StaticBatchInfo before the split.</summary>
        public static string RecordPath(Scene scene) => $"{LibraryRoot}/Records/{scene.name}.batchinfo.tsv";

        static string CacheKey(Scene s) => s.path + "#" + s.handle;  // the renderer objects are per opening of the scene
        static readonly Dictionary<string, Dictionary<MeshRenderer, (int first, int count)>> batchCache = new Dictionary<string, Dictionary<MeshRenderer, (int, int)>>();

        [InitializeOnLoadMethod]
        static void HookUndo() => Undo.undoRedoPerformed += AfterUndoRedo;

        /// <summary>After an Undo or Redo: a recorded renderer on its combined mesh gets its batch info back; one on a library mesh gets it cleared.</summary>
        static void AfterUndoRedo()
        {
            for (int s = 0; s < SceneManager.sceneCount; s++)
            {
                var scene = SceneManager.GetSceneAt(s);
                if (!scene.isLoaded || string.IsNullOrEmpty(scene.path) || !File.Exists(RecordPath(scene))) continue;
                if (!batchCache.TryGetValue(CacheKey(scene), out var map)) batchCache[CacheKey(scene)] = map = ReadRecord(scene);
                foreach (var r in scene.GetRootGameObjects().SelectMany(g => g.GetComponentsInChildren<MeshRenderer>(true)))
                {
                    if (!map.TryGetValue(r, out var info)) continue;
                    var f = r.GetComponent<MeshFilter>();
                    bool onLibrary = f != null && AssetDatabase.GetAssetPath(f.sharedMesh).StartsWith(LibraryRoot + "/");
                    var so = new SerializedObject(r);
                    var first = so.FindProperty("m_StaticBatchInfo.firstSubMesh"); var count = so.FindProperty("m_StaticBatchInfo.subMeshCount");
                    int wantFirst = onLibrary ? 0 : info.first, wantCount = onLibrary ? 0 : info.count;
                    if (first.intValue == wantFirst && count.intValue == wantCount) continue;
                    first.intValue = wantFirst; count.intValue = wantCount;
                    so.ApplyModifiedPropertiesWithoutUndo();
                }
            }
        }

        static Dictionary<MeshRenderer, (int, int)> ReadRecord(Scene scene)
        {
            var map = new Dictionary<MeshRenderer, (int, int)>();
            var rows = File.ReadAllLines(RecordPath(scene)).Select(l => l.Split('\t')).Where(f => f.Length == 3).ToList();
            var ids = rows.Select(f => GlobalObjectId.TryParse(f[0], out var g) ? g : default).ToArray();
            var objs = new UnityEngine.Object[ids.Length];
            GlobalObjectId.GlobalObjectIdentifiersToObjectsSlow(ids, objs);
            for (int i = 0; i < rows.Count; i++)
                if (objs[i] is MeshRenderer r) map[r] = (int.Parse(rows[i][1]), int.Parse(rows[i][2]));
            return map;
        }

        static void ClearBatch(MeshRenderer r)
        {
            var so = new SerializedObject(r);
            so.FindProperty("m_StaticBatchInfo.firstSubMesh").intValue = 0;
            so.FindProperty("m_StaticBatchInfo.subMeshCount").intValue = 0;
            so.ApplyModifiedPropertiesWithoutUndo();
        }

        static Mesh MakeMesh(Block b)
        {
            var m = new Mesh { name = Path.GetFileNameWithoutExtension(b.meshPath) };
            m.SetVertexBufferParams(b.vertexCount, b.attrs);
            for (int s = 0; s < b.streams.Length; s++) m.SetVertexBufferData(b.streams[s], 0, 0, b.streams[s].Length, s);
            int total = b.indices.Sum(x => x.Length);
            var fmt = b.vertexCount > 65535 ? IndexFormat.UInt32 : IndexFormat.UInt16;
            m.SetIndexBufferParams(total, fmt);
            var all = b.indices.SelectMany(x => x).ToArray();
            if (fmt == IndexFormat.UInt16) m.SetIndexBufferData(all.Select(x => (ushort)x).ToArray(), 0, 0, total);
            else m.SetIndexBufferData(all.Select(x => (uint)x).ToArray(), 0, 0, total);
            m.subMeshCount = b.indices.Length;
            for (int k = 0, start = 0; k < b.indices.Length; start += b.indices[k].Length, k++)
                m.SetSubMesh(k, new SubMeshDescriptor(start, b.indices[k].Length, b.topology[k]));
            m.RecalculateBounds();
            return m;
        }

        static void Folder(string path)
        {
            if (AssetDatabase.IsValidFolder(path)) return;
            var parent = Path.GetDirectoryName(path).Replace('\\', '/');
            Folder(parent);
            AssetDatabase.CreateFolder(parent, Path.GetFileName(path));
        }
    }
}
