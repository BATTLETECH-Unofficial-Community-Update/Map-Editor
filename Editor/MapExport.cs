// UCU Map Kit: "Export Map Data". Runs HBS's MapMetaDataExporter.GenerateMapMetaData on the open map, then writes the
// files SaveMapMetaDataV2 writes (MapMetaDataExporter.cs:564-644), with the same serializer calls, under
// <project>/MapKitOutput/<map>/. Only the output folder differs: HBS's GetTerrainDataPath needs a DataManager the Editor
// does not have (MapMetaDataExporter.cs:194-196). No HBS file is edited. Then the contract writer (ContractWriter.cs) writes
// <map>_<contract>.json beside them for each layer that carries an ambush or kit dialogue.
using System;
using System.Collections.Generic;
using System.IO;
using BattleTech;
using BattleTech.Serialization;
using HBS.Collections;
using HBS.Util;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    public class MapExportResult
    {
        public string outputDir;
        public List<string> files = new List<string>();
        public List<string> validation = new List<string>();
    }

    public static class MapExport
    {
        [MenuItem("UCU Map Kit/Export Map Data")]
        static void ExportMenu()
        {
            var r = Export();
            Debug.Log($"UCU Map Kit: wrote {r.files.Count} files to {r.outputDir}; {r.validation.Count} validation entries");
        }

        public static MapExportResult Export(bool validate = true)
        {
            var scene = MapPreconditions.Require();
            var terrain = scene.terrain;
            var exporter = scene.exporter;
            var parent = scene.parent;

            var map = MapMetaDataExporter.GetMapName();
            var result = new MapExportResult { outputDir = Path.Combine(Path.GetDirectoryName(Application.dataPath), "MapKitOutput", map) };
            Directory.CreateDirectory(result.outputDir);

            // GenerateAndSaveDataV2 (MapMetaDataExporter.cs:232-241) up to the save.
            MapMetaDataExporter.SetSceneFlags();
            MapMetaDataExporter.EnsureRoadsAreObstructions();
            // The exporter raycasts colliders. With autoSyncTransforms off (the kit project's default), an object moved since the
            // last physics step is still at its old place, so a just-placed building exported 0 cells (X2: 28 after a sync).
            Physics.SyncTransforms();
            exporter.GenerateMapMetaData(terrain);

            // SaveMapMetaDataV2 (MapMetaDataExporter.cs:564-644), written to the kit's output folder.
            MapMetaDataExporter.SetSceneFlags();
            exporter.mapMetaData.mapName = exporter.mapName;
            // The map tags go into mapMetaData before it is serialized. HBS assigns them after the write (:643), so its first save
            // in a session carried the tags of the last one (none, on a scene just opened); that was the kit's first Export.
            exporter.mapMetaData.mapTags = new TagSet(exporter.mapTags);
            var bytes = new byte[exporter.mapMetaData.Size()];
            using (var stream = new SerializationStream(bytes))
                exporter.mapMetaData.Save(stream);
            Write(result, $"{map}_TerrainData.bin", bytes);
            int selected = parent.SelectedEncounterLayerIndex;
            parent.UpdateEncounterLayerList(); // HBS's cached list, stale after an Undo that removed a layer
            for (int i = 0; i < parent.EncounterLayerList.Length; i++)
            {
                var layer = parent.SelectEncounterLayerByIndex(i);
                layer.path = MapMetaDataExporter.GetEncounterLayerDataPath(layer.name);
                EncounterObjectGameLogic.MakeItDirty2(layer);
                if (validate)
                {
                    // MapMetaDataExporter.IsLayerValid (:674-687) is private; it is this call plus logging.
                    var entries = layer.Validate(new Dictionary<string, EncounterObjectGameLogic>());
                    foreach (var e in entries)
                        result.validation.Add($"{layer.name}: {e.validationError}");
                    if (entries.Count > 0)
                        continue;
                }
                var name = Path.GetFileName(layer.path);
                Write(result, name, Serializer.Serialize(layer, SerializationTarget.Exported));
                var raycast = new byte[layer.RaycastInfoSize()];
                using (var stream = new SerializationStream(raycast))
                    layer.SaveRaycastInfo(stream);
                Write(result, name.Replace(".bin", "_RaycastInfo.bin"), raycast);
                if (exporter.inclineMeshData != null)
                {
                    var incline = name.Replace(".bin", "_InclineMesh.IMS");
                    exporter.inclineMeshData.SaveToPath(Path.Combine(result.outputDir, incline));
                    result.files.Add(incline);
                }
            }
            parent.SelectEncounterLayerByIndex(selected);
            foreach (var plan in ContractWriter.WriteAll(parent, map, result.outputDir, result.validation))
                result.files.Add(plan.FileName);
            return result;
        }

        static void Write(MapExportResult result, string name, byte[] bytes)
        {
            File.WriteAllBytes(Path.Combine(result.outputDir, name), bytes);
            result.files.Add(name);
        }
    }
}
