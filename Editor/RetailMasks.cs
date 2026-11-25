// UCU Map Kit: "Rebuild Terrain-Type Masks from Retail" (plan .hermes/plans/2026-11-19-map-kit.md -> KE1). HBS stripped the
// design-time SplatMapInfo from the shipped map scenes and shipped only the exporter's result, the TerrainData.bin cells
// (gbrain lessons/retail-map-scenes-lack-splatmapinfo), so an extracted map can't be exported until it has masks again.
// This step reads the map's own shipped TerrainData.bin and writes the seven masks back from its cells.
//
// Why it is lossless at cell resolution: MapMetaDataExporter.CalculateAverageTerrainValues gives cell c (4 m) the flag F when at
// least 10 of its 5x5 samples, 1 m apart at world offsets 4c-2 .. 4c+2 on each axis, read F from the masks. With a 1 m mask texel,
// texels 4c-2 .. 4c+1 on each axis (16 samples) belong to cell c alone: a flag the cell has gets 16 of 25, and a flag only its
// neighbours have gets at most 9 (the shared fifth row and column). Retail's cells hold one flag each (GetPriorityTerrainMaskFlags),
// so the masks carry that flag and the re-export applies the same priority. Cells in the map edge band keep only MapBoundary in
// retail's file; the masks are empty there and the exporter adds MapBoundary by position, as it did for retail.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using HBS.Util;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace UCU.MapKit
{
    public class RetailMasksResult
    {
        public string source;
        public int cellsX, cellsZ, maskWidth, maskHeight;
        public float cellSize, texelSize;
        public Dictionary<string, int> cells = new Dictionary<string, int>();   // retail cells per flag (all 16 bits that occur)
        public Dictionary<string, int> texels = new Dictionary<string, int>();  // mask texels set per mask
        public List<string> masks = new List<string>();
    }

    public static class RetailMasks
    {
        static readonly (string name, TerrainMaskFlags flag)[] Masks =
        {
            ("water", TerrainMaskFlags.Water), ("deepWater", TerrainMaskFlags.DeepWater), ("forest", TerrainMaskFlags.Forest),
            ("rough", TerrainMaskFlags.Rough), ("custom", TerrainMaskFlags.Custom), ("road", TerrainMaskFlags.Road),
            ("impassable", TerrainMaskFlags.Impassable),
        };

        [MenuItem("UCU Map Kit/Setup/Rebuild Terrain-Type Masks from Retail")]
        static void RebuildMenu()
        {
            try
            {
                var r = Rebuild();
                Debug.Log($"UCU Map Kit: wrote {r.masks.Count} masks ({r.maskWidth}x{r.maskHeight}, {r.texelSize} m texel) from {r.source} " +
                          $"({r.cellsX}x{r.cellsZ} cells of {r.cellSize} m). Save the scene to keep the SplatMapInfo.");
            }
            catch (Exception e) { EditorUtility.DisplayDialog("UCU Map Kit", e.Message, "OK"); }
        }

        /// <summary>The retail TerrainData.bin of retail map <paramref name="map"/>: the retail install's data/maps/&lt;map&gt; folder.</summary>
        public static string RetailTerrainData(string map)
        {
            var install = RetailMaps.RetailInstall;
            var bad = RetailMaps.InstallProblem(install);
            if (bad != null) throw new InvalidOperationException(bad);
            var path = Path.Combine(install, "BattleTech_Data", "StreamingAssets", "data", "maps", map.ToLowerInvariant(), map + "_TerrainData.bin");
            if (!File.Exists(path)) throw new FileNotFoundException($"The retail install has no {map}_TerrainData.bin; this step needs a map extracted from retail.", path);
            return path;
        }

        /// <summary>Writes the seven masks from <paramref name="terrainData"/> (default: the retail file of the retail map the open map
        /// comes from, RetailMaps.SourceMap), next to the scene under the scene's own name, and points the terrain's SplatMapInfo at
        /// them (added if missing). One Undo step; the scene is left dirty.</summary>
        public static RetailMasksResult Rebuild(string terrainData = null)
        {
            var terrain = Terrain.activeTerrain ?? throw new InvalidOperationException(MapPreconditions.NoTerrain);
            var scene = terrain.gameObject.scene;
            var map = scene.name;
            var r = new RetailMasksResult { source = terrainData ?? RetailTerrainData(RetailMaps.SourceMap(scene.path) ?? throw new InvalidOperationException(RetailMaps.NoSource(map))), cellSize = MapMetaDataExporter.cellSize };
            var meta = new MapMetaData();
            meta.Load(new SerializationStream(File.ReadAllBytes(r.source)));
            var cells = meta.mapTerrainDataCells;
            r.cellsZ = cells.GetLength(0); r.cellsX = cells.GetLength(1);
            var size = terrain.terrainData.size;
            r.maskWidth = (int)size.x; r.maskHeight = (int)size.z;
            // The exporter makes size/cellSize cells and reads a mask texel per metre only when the mask is as wide as the terrain.
            if (r.maskWidth != size.x || r.maskHeight != size.z || r.cellsX * MapMetaDataExporter.cellSize != r.maskWidth || r.cellsZ * MapMetaDataExporter.cellSize != r.maskHeight)
                throw new InvalidOperationException($"{r.source} has {r.cellsX}x{r.cellsZ} cells of {MapMetaDataExporter.cellSize} m, but the terrain is {size.x}x{size.z} m: they don't belong together.");
            r.texelSize = size.x / r.maskWidth;
            foreach (TerrainMaskFlags f in Enum.GetValues(typeof(TerrainMaskFlags)))
            {
                if (f == TerrainMaskFlags.None) continue;
                int n = 0;
                foreach (var c in cells) if ((c.terrainMask & f) != 0) n++;
                if (n > 0) r.cells[f.ToString()] = n;
            }

            var dir = Path.GetDirectoryName(scene.path).Replace('\\', '/');
            var textures = new List<Texture2D>();
            int w = r.maskWidth, h = r.maskHeight;
            var px = new Color32[w * h];
            var white = new Color32(255, 255, 255, 255);
            foreach (var (name, flag) in Masks)
            {
                int on = 0;
                for (int t = 0; t < h; t++)
                {
                    int cz = Mathf.Min((t + 2) / MapMetaDataExporter.cellSize, r.cellsZ - 1);
                    for (int s = 0; s < w; s++)
                    {
                        int cx = Mathf.Min((s + 2) / MapMetaDataExporter.cellSize, r.cellsX - 1);
                        bool set = (cells[cz, cx].terrainMask & flag) != 0;
                        px[t * w + s] = set ? white : default;
                        if (set) on++;
                    }
                }
                r.texels[name] = on;
                var path = $"{dir}/{map}_mask_{name}.png";
                textures.Add(WriteMask(path, w, h, px));
                r.masks.Add(path);
            }

            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName("Rebuild Terrain-Type Masks from Retail");
            var splat = terrain.GetComponent<SplatMapInfo>() ?? Undo.AddComponent<SplatMapInfo>(terrain.gameObject);
            Undo.RecordObject(splat, "Rebuild Terrain-Type Masks from Retail");
            splat.waterMask = textures[0]; splat.deepWaterMask = textures[1]; splat.forestMask = textures[2]; splat.roughMask = textures[3];
            splat.customMask = textures[4]; splat.roadMask = textures[5]; splat.impassableMask = textures[6];
            splat.ValueThreshold = 0f;
            EditorUtility.SetDirty(splat);
            EditorSceneManager.MarkSceneDirty(scene);
            return r;
        }

        // Same importer settings as the template's masks (TemplateGenerator.CreateMask): RGB24 source, readable, uncompressed, point,
        // no mips, so SplatMapInfo.LoadSplatData reads black as 0 (gbrain lessons/r8-texture-grayscale-not-zero).
        static Texture2D WriteMask(string path, int w, int h, Color32[] px)
        {
            var tex = new Texture2D(w, h, TextureFormat.RGB24, false);
            tex.SetPixels32(px);
            if (File.Exists(path)) File.Delete(path);
            File.WriteAllBytes(path, tex.EncodeToPNG());
            UnityEngine.Object.DestroyImmediate(tex);
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceSynchronousImport);
            var importer = (TextureImporter)AssetImporter.GetAtPath(path);
            importer.textureType = TextureImporterType.Default;
            importer.isReadable = true;
            importer.sRGBTexture = false;
            importer.mipmapEnabled = false;
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.filterMode = FilterMode.Point;
            importer.maxTextureSize = Mathf.Max(32, Mathf.NextPowerOfTwo(Mathf.Max(w, h)));
            importer.textureCompression = TextureImporterCompression.Uncompressed;
            importer.SaveAndReimport();
            return AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        }
    }
}
