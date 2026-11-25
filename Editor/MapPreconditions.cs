// UCU Map Kit: what Export Map Data needs before it can run (formerly the first lines of MapExport.Export). Map Check lists
// every unmet one; Export throws the first, with the same message as before.
using System;
using System.Collections.Generic;
using System.Linq;
using BattleTech;
using UnityEngine;

namespace UCU.MapKit
{
    /// <summary>The scene objects the exporter works on, as found by the precondition check.</summary>
    public class MapScene
    {
        public Terrain terrain;
        public TerrainGenerator generator;
        public SplatMapInfo splat;
        public MapMetaDataExporter exporter;
        public EncounterLayerParent parent;
    }

    public class MapProblem
    {
        public string message;
        public UnityEngine.Object target;
        public MapProblem(string message, UnityEngine.Object target) { this.message = message; this.target = target; }
    }

    public static class MapPreconditions
    {
        public const string NoTerrain = "The open scene has no active terrain.";
        public const string NoGenerator = "The terrain needs a TerrainGenerator with a biome.";
        // HBS's own wording (MapMetaDataExporter.GenerateTerrainData logs it).
        public const string NoSplat = "Without the SplatMapInfo component on the terrain, we can't have any terrain data from design.";
        public const string NoExporter = "The map needs one object with EncounterLayerParent, MapMetaDataExporter and InclineMeshBuilder.";
        public const string DuplicateLayer = "Two encounter layers are named ";

        /// <summary>Export names a layer's files after the layer, with spaces as underscores (MapMetaDataExporter.GetEncounterLayerDataPath),
        /// on a file system that ignores case: two layers with one of these keys overwrite each other's data without a word.</summary>
        public static string LayerFileKey(string layerName) => layerName.Replace(' ', '_').ToLowerInvariant();

        /// <summary>Every unmet precondition, in the order Export tests them. A check that needs the terrain is skipped without one.</summary>
        public static List<MapProblem> Check(out MapScene scene)
        {
            var problems = new List<MapProblem>();
            scene = new MapScene { terrain = Terrain.activeTerrain };
            if (scene.terrain == null)
                problems.Add(new MapProblem(NoTerrain, null));
            else
            {
                scene.generator = scene.terrain.GetComponent<TerrainGenerator>();
                if (scene.generator == null || scene.generator.biome == null)
                    problems.Add(new MapProblem(NoGenerator, scene.terrain.gameObject));
                scene.splat = scene.terrain.GetComponent<SplatMapInfo>();
                if (scene.splat == null)
                    problems.Add(new MapProblem(NoSplat, scene.terrain.gameObject));
            }
            scene.exporter = UnityEngine.Object.FindAnyObjectByType<MapMetaDataExporter>();
            scene.parent = scene.exporter != null ? scene.exporter.GetComponent<EncounterLayerParent>() : null;
            if (scene.parent == null || scene.exporter.GetComponent<InclineMeshBuilder>() == null)
                problems.Add(new MapProblem(NoExporter, scene.exporter != null ? scene.exporter.gameObject : null));
            if (scene.parent != null)
                foreach (var same in EncounterEdit.Layers(scene.parent).GroupBy(l => LayerFileKey(l.name)).Where(g => g.Count() > 1))
                    problems.Add(new MapProblem($"{DuplicateLayer}{same.First().name}. Export names each layer's files after the layer, so one would overwrite the other's data. Rename or delete one of them in the Hierarchy.", same.Last().gameObject));
            return problems;
        }

        /// <summary>Export's guard: throws InvalidOperationException with the first unmet precondition's message. The encounter tools
        /// (Add Contract Layer, Add Ambush) pass <paramref name="forExport"/> false: they read the terrain and the layers, never the
        /// terrain-type masks or the layers' files, and an extracted retail map has no SplatMapInfo until Rebuild Terrain-Type Masks (map-kit KFIX7: the
        /// README's "Edit a retail map" step 2 runs before step 4 and refused).</summary>
        public static MapScene Require(bool forExport = true)
        {
            var problems = Check(out var scene);
            if (!forExport) problems.RemoveAll(p => p.message == NoSplat || p.message.StartsWith(DuplicateLayer));
            if (problems.Count > 0)
                throw new InvalidOperationException(problems[0].message);
            return scene;
        }
    }
}
