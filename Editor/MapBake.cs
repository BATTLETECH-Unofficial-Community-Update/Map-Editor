// UCU Map Kit: Bake lighting, with the K3 recipe (.hermes/reports/map-kit-k3-20261122/final.md): Enlighten realtime GI only
// at a realtime resolution of 0.0625, a temporary light-probe group in retail taiga's layout (columns every 64 m, probes at
// ground +1, +20 and +60 m: 33 x 33 x 3 = 3,267 on 2048 m), and Unity's GI cache raised for the bake and put back after it.
// Afterwards the probe group and the reflection-probe .exr are removed and the scene is saved once, so the scene file points
// at its LightingData (a kit scene is the kit's own Unity 6 scene; the no-save rule is for retail scenes, work-item decision
// 2026-11-22). Size is judged before and after against retail, on the uncompressed Enlighten files (.sse set), as the
// project's rule asks: generated data more than about 2x retail's means different inputs, so the bake does not start, and
// a result past it is reported and stops Test map.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    public enum BakeState { Idle, Running, Done, Failed, TooLarge, NotPrepared }

    public class BakeEstimate
    {
        public float terrainSize;
        public long texels;
        public long estimateBytes;
        public long retailBytes;
        /// <summary>Set for an extracted retail map (or a copy of one) that Prepare Lighting from Retail has not set up: the estimate
        /// then covers only the terrain, and the bake does not start.</summary>
        public string unprepared;
        public double Ratio => retailBytes == 0 ? 0 : (double)estimateBytes / retailBytes;
        public override string ToString() => $"{texels:N0} texels, about {estimateBytes:N0} B against retail's {retailBytes:N0} B ({Ratio:F2}x)";
    }

    public class BakeMeasure
    {
        public string lightingData;
        public int systems;
        public long terrainBytes;   // per-system files: caw, ecm, iws.sse, rgb, rsc.sse, vis
        public long probeBytes;     // shared probe files: rpc.sse, pos
        public long retailBytes;
        public double Ratio => retailBytes == 0 ? 0 : (double)terrainBytes / retailBytes;
        public override string ToString() => $"{systems} systems, {terrainBytes:N0} B of terrain GI ({Ratio:F3}x retail's {retailBytes:N0} B), {probeBytes:N0} B of probe data";
    }

    public static class MapBake
    {
        public const float RealtimeResolution = 0.0625f;
        public const int CacheGB = 50;
        public const double Limit = 2.0;
        // Retail taigaRiver (level66), a 2048 m map: its 4 terrain systems hold 4,515,412 B of uncompressed Enlighten data.
        public const long RetailTerrainBytes2048 = 4515412;
        // K3's test bake of the template measured 806,197 B for 4,096 texels at these settings (196.8 B a texel).
        public const double BytesPerTexel = 806197.0 / 4096.0;
        const string ProbeGroupName = "UCU Map Kit bake probes (removed after the bake)";
        static readonly string[] SystemExts = { "caw", "ecm", "iws.sse", "rgb", "rsc.sse", "vis" };
        static readonly string[] ProbeExts = { "rpc.sse", "pos" };

        public static BakeState State { get; private set; }
        public static string Message { get; private set; } = "";
        public static BakeMeasure LastMeasure { get; private set; }
        public static event Action<BakeState> Finished;

        static string scenePath;
        static int cacheBefore = -1;
        static bool completed;
        static int idleTicks;

        public static BakeEstimate Estimate(Terrain terrain)
        {
            float size = terrain.terrainData.size.x;
            long across = (long)Mathf.Round(RealtimeResolution * size);
            var e = new BakeEstimate { terrainSize = size, texels = across * across };
            e.estimateBytes = (long)(e.texels * BytesPerTexel);
            e.retailBytes = (long)(RetailTerrainBytes2048 * (size / 2048.0) * (size / 2048.0));
            // An extracted retail map prepared by RetailLighting is judged against all of its own retail systems, props included.
            var scene = terrain.gameObject.scene;
            var rf = RetailLighting.Reference(scene.path);
            if (rf != null) { e.texels = rf.texels; e.estimateBytes = (long)(rf.texels * BytesPerTexel); e.retailBytes = rf.bytes; }
            // An unprepared one keeps the renderers' own lighting flags from the extraction, which are not retail's bake set, so its
            // props bake as hundreds of systems the terrain-only figure above does not count (map-kit A1 D18: 0.71x estimated,
            // 75.7x baked, 253 systems against retail's 12).
            else if (RetailMaps.SourceMap(scene.path) is string source)
                e.unprepared = $"{scene.name} is {(source == scene.name ? "an extracted retail map" : "a copy of the retail map " + source)} whose lighting has not been " +
                    "prepared, so the size check cannot size its bake. Run UCU Map Kit > Setup > Prepare Lighting from Retail, save the scene, then bake.";
            return e;
        }

        static string LightingFolder(Scene scene) => $"{Path.GetDirectoryName(scene.path).Replace('\\', '/')}/{scene.name}";

        /// <summary>Stale = no lighting data for the scene, or the terrain saved after it. Shortcut: other GI contributors
        /// (props) are not tracked; upgrade when maps carry baked props (U8).</summary>
        public static bool IsStale(Scene scene, out string why)
        {
            var ld = $"{LightingFolder(scene)}/LightingData.asset";
            if (!File.Exists(ld) || Lightmapping.lightingDataAsset == null || AssetDatabase.GetAssetPath(Lightmapping.lightingDataAsset) != ld)
            {
                why = "the map has no lighting data of its own";
                return true;
            }
            var terrain = Terrain.activeTerrain;
            var td = terrain == null ? null : AssetDatabase.GetAssetPath(terrain.terrainData);
            if (!string.IsNullOrEmpty(td) && File.GetLastWriteTimeUtc(td) > File.GetLastWriteTimeUtc(ld))
            {
                why = "the terrain was saved after the last bake";
                return true;
            }
            why = "the lighting data is newer than the terrain";
            return false;
        }

        /// <summary>Starts the bake (asynchronous). Throws, naming the reason, when it cannot start.</summary>
        public static BakeEstimate Start()
        {
            if (State == BakeState.Running || Lightmapping.isRunning) throw new InvalidOperationException("A bake is already running.");
            var scene = SceneManager.GetActiveScene();
            if (string.IsNullOrEmpty(scene.path)) throw new InvalidOperationException("Save the map scene first.");
            if (scene.isDirty) throw new InvalidOperationException("The scene has unsaved changes. Save it first: the bake saves the scene once when it ends.");
            if (SceneManager.sceneCount != 1) throw new InvalidOperationException("Close the other open scenes first.");
            var terrain = Terrain.activeTerrain ?? throw new InvalidOperationException(MapPreconditions.NoTerrain);
            var est = Estimate(terrain);
            if (est.unprepared != null)
            {
                Set(BakeState.NotPrepared, "Not started: " + est.unprepared);
                throw new InvalidOperationException(Message);
            }
            if (est.Ratio > Limit)
            {
                Set(BakeState.TooLarge, $"Not started: the estimate is {est}, more than {Limit}x retail. The map's lighting inputs differ from retail's; check the terrain's size and its Scale In Lightmap.");
                throw new InvalidOperationException(Message);
            }

            scenePath = scene.path;
            cacheBefore = EditorPrefs.GetInt("GICacheMaximumSizeGB", 10);
            EditorPrefs.SetInt("GICacheMaximumSizeGB", Math.Max(cacheBefore, CacheGB));
            var ls = new LightingSettings { name = scene.name + "_lighting", realtimeGI = true, bakedGI = false };
            var lso = new SerializedObject(ls);
            lso.FindProperty("m_RealtimeResolution").floatValue = RealtimeResolution;
            lso.ApplyModifiedPropertiesWithoutUndo();
            Lightmapping.lightingSettings = ls;
            AddProbes(terrain);

            completed = false;
            idleTicks = 0;
            Lightmapping.bakeCompleted -= OnCompleted;
            Lightmapping.bakeCompleted += OnCompleted;
            if (!Lightmapping.BakeAsync())
            {
                Cleanup();
                Set(BakeState.Failed, "Unity did not start the bake (Lightmapping.BakeAsync returned false).");
                throw new InvalidOperationException(Message);
            }
            Set(BakeState.Running, $"Baking {scene.name}: {est}.");
            EditorApplication.update -= Poll;
            EditorApplication.update += Poll;
            return est;
        }

        static void AddProbes(Terrain terrain)
        {
            var o = terrain.transform.position; var size = terrain.terrainData.size;
            int columns = Mathf.RoundToInt(size.x / 64f);
            var positions = new List<Vector3>();
            for (int ix = 0; ix <= columns; ix++)
                for (int iz = 0; iz <= columns; iz++)
                {
                    float x = o.x + 64f * ix, z = o.z + 64f * iz;
                    float ground = terrain.SampleHeight(new Vector3(x, 0f, z)) + o.y;
                    foreach (var dy in new[] { 1f, 20f, 60f }) positions.Add(new Vector3(x, ground + dy, z));
                }
            new GameObject(ProbeGroupName).AddComponent<LightProbeGroup>().probePositions = positions.ToArray();
        }

        static void OnCompleted() => completed = true;

        static void Poll()
        {
            if (Lightmapping.isRunning) { idleTicks = 0; return; }
            // bakeCompleted can arrive a tick after isRunning drops; wait a few idle ticks before calling it stopped.
            if (!completed && ++idleTicks < 5) return;
            EditorApplication.update -= Poll;
            Lightmapping.bakeCompleted -= OnCompleted;
            try { Finish(completed); }
            catch (Exception e) { Cleanup(); Set(BakeState.Failed, "After the bake: " + e.Message); Debug.LogException(e); }
            Finished?.Invoke(State);
        }

        static void Finish(bool ok)
        {
            var scene = SceneManager.GetActiveScene();
            if (scene.path != scenePath)
            {
                Cleanup();
                Set(BakeState.Failed, $"The open scene changed during the bake ({scene.path}); {scenePath} was not saved.");
                return;
            }
            if (!ok)
            {
                Cleanup();
                Set(BakeState.Failed, "The bake stopped without finishing (cancelled, or Unity reported an error in the Console). The scene was not saved.");
                return;
            }
            Cleanup();
            var exr = $"{LightingFolder(scene)}/ReflectionProbe-0.exr";
            if (File.Exists(exr)) AssetDatabase.DeleteAsset(exr);
            if (!EditorSceneManager.SaveScene(scene))
            {
                Set(BakeState.Failed, "The bake finished but saving the scene failed.");
                return;
            }
            var ld = Lightmapping.lightingDataAsset == null ? null : AssetDatabase.GetAssetPath(Lightmapping.lightingDataAsset);
            if (string.IsNullOrEmpty(ld)) { Set(BakeState.Failed, "The bake finished with no LightingData asset."); return; }
            LastMeasure = Measure(ld, Terrain.activeTerrain.terrainData.size.x, RetailLighting.Reference(scene.path)?.bytes ?? 0);
            if (LastMeasure.Ratio > Limit)
                Set(BakeState.TooLarge, $"Baked and saved, but the lighting is {LastMeasure}: more than {Limit}x retail. Stop here and find what differs from retail before using this map.");
            else
                Set(BakeState.Done, $"Baked and saved: {LastMeasure}.");
        }

        // The probe group is removed and the GI cache size put back on every exit path.
        static void Cleanup()
        {
            foreach (var pg in UnityEngine.Object.FindObjectsByType<LightProbeGroup>(FindObjectsInactive.Include).Where(p => p.name == ProbeGroupName))
                UnityEngine.Object.DestroyImmediate(pg.gameObject);
            if (cacheBefore >= 0) EditorPrefs.SetInt("GICacheMaximumSizeGB", cacheBefore);
            cacheBefore = -1;
        }

        static void Set(BakeState s, string message)
        {
            State = s;
            Message = message;
            if (s == BakeState.Failed || s == BakeState.TooLarge) Debug.LogError("UCU Map Kit: Bake lighting: " + message);
            else if (s == BakeState.NotPrepared) Debug.LogWarning("UCU Map Kit: Bake lighting: " + message);
            else Debug.Log("UCU Map Kit: Bake lighting: " + message);
        }

        /// <summary>Uncompressed Enlighten bytes of a LightingData asset, from the UnityFS bundle it embeds (m_EnlightenData):
        /// the node directory gives each file's size, so no data is decompressed. tools/gi-weld/measure-ld.py reads the same set.</summary>
        public static BakeMeasure Measure(string lightingDataPath, float terrainSize, long retailBytes = 0)
        {
            var bytes = File.ReadAllBytes(lightingDataPath);
            var sig = Encoding.ASCII.GetBytes("UnityFS\0");
            int o = IndexOf(bytes, sig);
            if (o < 4) throw new InvalidDataException($"{lightingDataPath} carries no Enlighten bundle.");
            var m = new BakeMeasure { lightingData = lightingDataPath, retailBytes = retailBytes > 0 ? retailBytes : (long)(RetailTerrainBytes2048 * (terrainSize / 2048.0) * (terrainSize / 2048.0)) };
            List<(string, long)> nodes;
            // An extracted retail map's LightingData embeds a bare bundle header with no directory: retail keeps its GI in
            // GI/level<N>, outside the level file (KE2).
            try { nodes = BundleNodes(bytes, o); }
            catch (Exception e) when (e is IndexOutOfRangeException || e is ArgumentException)
            { throw new InvalidDataException($"{lightingDataPath} carries an empty Enlighten bundle (no baked GI; an extracted map needs Prepare Lighting from Retail and a bake)."); }
            foreach (var (name, size) in nodes)
            {
                var file = name.Split('/').Last();
                int dot = file.IndexOf('.');
                var ext = dot < 0 ? "" : file.Substring(dot + 1);
                if (SystemExts.Contains(ext)) m.terrainBytes += size;
                if (ProbeExts.Contains(ext)) m.probeBytes += size;
                if (ext == "rsc.sse") m.systems++;
            }
            return m;
        }

        static int IndexOf(byte[] a, byte[] p)
        {
            for (int i = 0; i + p.Length <= a.Length; i++)
            {
                int k = 0;
                while (k < p.Length && a[i + k] == p[k]) k++;
                if (k == p.Length) return i;
            }
            return -1;
        }

        // UnityFS header and block-info directory (big-endian); block info is stored raw or LZ4-compressed.
        static List<(string, long)> BundleNodes(byte[] b, int start)
        {
            int p = start;
            string CStr() { int s = p; while (b[p] != 0) p++; var t = Encoding.UTF8.GetString(b, s, p - s); p++; return t; }
            uint U32() { uint v = (uint)(b[p] << 24 | b[p + 1] << 16 | b[p + 2] << 8 | b[p + 3]); p += 4; return v; }
            long I64() { long v = 0; for (int i = 0; i < 8; i++) v = v << 8 | b[p + i]; p += 8; return v; }
            CStr(); uint version = U32(); CStr(); CStr();
            long total = I64();
            int cSize = (int)U32(), uSize = (int)U32(); uint flags = U32();
            if (version >= 7 && (p - start) % 16 != 0) p += 16 - (p - start) % 16;
            // Flag 0x80: the block info sits at the end of the bundle instead of after the header.
            if ((flags & 0x80) != 0) p = start + (int)total - cSize;
            var raw = new byte[cSize];
            Array.Copy(b, p, raw, 0, cSize);
            uint comp = flags & 0x3f;
            var info = comp == 0 ? raw : comp == 2 || comp == 3 ? Lz4(raw, uSize) : throw new InvalidDataException($"block info compression {comp} is not read by the kit");
            var nodes = new List<(string, long)>();
            b = info; p = 16;
            int blocks = (int)U32();
            p += blocks * 10;
            int count = (int)U32();
            for (int i = 0; i < count; i++)
            {
                I64(); long size = I64(); U32();
                nodes.Add((CStr(), size));
            }
            return nodes;
        }

        static byte[] Lz4(byte[] src, int outSize)
        {
            var dst = new byte[outSize];
            int s = 0, d = 0;
            while (s < src.Length)
            {
                int token = src[s++];
                int lit = token >> 4;
                if (lit == 15) { int x; do { x = src[s++]; lit += x; } while (x == 255); }
                Array.Copy(src, s, dst, d, lit); s += lit; d += lit;
                if (s >= src.Length) break;
                int off = src[s] | src[s + 1] << 8; s += 2;
                int len = token & 15;
                if (len == 15) { int x; do { x = src[s++]; len += x; } while (x == 255); }
                len += 4;
                for (int i = 0; i < len; i++) { dst[d] = dst[d - off]; d++; }
            }
            if (d != outSize) throw new InvalidDataException($"LZ4 block info decoded to {d} bytes, expected {outSize}");
            return dst;
        }
    }
}
