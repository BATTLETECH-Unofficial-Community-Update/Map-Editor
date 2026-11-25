// UCU Map Kit: the Map Kit window's Map tab. The map's settings live where HBS keeps them, so the scene stays the only
// record and nothing is hidden: display name, weight and map tags on the MapMetaDataExporter (HBS exports them and Build
// Mod writes them into mapkit-map.json), the biome on the terrain's TerrainGenerator. The one setting HBS has no field
// for, the preview picture, is a visible PNG beside the scene (<map>_preview.png); Build Mod uses it as the Skirmish icon.
// Every write goes through Undo (SerializedObject or Undo.RecordObjects), so Ctrl+Z and Ctrl+Y cover the tab.
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using BattleTech.Data;
using BattleTech.Rendering;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace UCU.MapKit
{
    public static class MapSettings
    {
        public const string ArenaTag = "typeArena";

        /// <summary>The tags a kit Skirmish map gets by default: the biome's tag (its required mood tags in the game's
        /// database, the same tag retail maps of that biome carry) and typeArena, as retail's arena maps
        /// (mapArena_splitRiver_iTnd: biomeIcyTundra, featureRiver, typeArena; feature tags describe content and are left to the modder).</summary>
        public static string[] SkirmishTags(Biome.BIOMESKIN skin)
        {
            var biomeTags = MetadataDatabase.Instance.GetBiome(skin)?.RequiredMoodTagSetEntry?.TagSet;
            return (biomeTags == null ? new string[0] : biomeTags.ToArray()).Concat(new[] { ArenaTag }).Distinct().ToArray();
        }

        public static string PreviewPath(Scene scene) => string.IsNullOrEmpty(scene.path) ? null : $"{Path.GetDirectoryName(scene.path).Replace('\\', '/')}/{scene.name}_preview.png";

        /// <summary>Biomes whose art (Biome asset and its 8 terrain layers) is in this project.</summary>
        public static Biome.BIOMESKIN[] AvailableBiomes() => AssetDatabase.FindAssets("t:Biome")
            .Select(g => AssetDatabase.LoadAssetAtPath<Biome>(AssetDatabase.GUIDToAssetPath(g))).Where(b => b != null).Select(b => b.biomeSkin).Distinct()
            .Where(s => { try { TemplateGenerator.FindTerrainLayers(s); return true; } catch (InvalidOperationException) { return false; } }).OrderBy(s => s.ToString()).ToArray();

        /// <summary>Sets the terrain's biome and swaps its 8 ground layers for the new biome's (layer i for layer i, so the
        /// painted ground look keeps its layout), as New Map from Template sets them. One Undo step.</summary>
        public static void SetBiome(Terrain terrain, Biome.BIOMESKIN skin)
        {
            var generator = terrain.GetComponent<TerrainGenerator>();
            var setup = terrain.GetComponent<TerrainMaterialSetup>();
            var biome = TemplateGenerator.FindBiome(skin);
            var layers = TemplateGenerator.FindTerrainLayers(skin);
            Undo.RecordObjects(new UnityEngine.Object[] { generator, terrain.terrainData, setup }.Where(o => o != null).ToArray(), "Map Kit: biome " + skin);
            generator.biome = biome;
            terrain.terrainData.terrainLayers = layers;
            if (setup != null)
            {
                setup.terrainAlbedo = layers.Select(l => l.diffuseTexture).ToArray();
                setup.terrainNormal = layers.Select(l => l.normalMapTexture).ToArray();
                setup.terrainHeights = layers.Select(l => TemplateGenerator.FindTexture(l.diffuseTexture.name.Replace("_alb", "_hgt"))).ToArray();
            }
            EditorUtility.SetDirty(generator);
            if (setup != null) EditorUtility.SetDirty(setup);
            UnityEditor.SceneManagement.EditorSceneManager.MarkSceneDirty(terrain.gameObject.scene);
        }

        /// <summary>Writes the map tags through the exporter's serialized TagSet (keeps its source file), one Undo step.</summary>
        public static void SetTags(MapMetaDataExporter exporter, IEnumerable<string> tags)
        {
            var so = new SerializedObject(exporter);
            var items = so.FindProperty("mapTags.items");
            var list = tags.Select(t => t.Trim()).Where(t => t.Length > 0).Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
            items.arraySize = list.Length;
            for (int i = 0; i < list.Length; i++) items.GetArrayElementAtIndex(i).stringValue = list[i];
            so.ApplyModifiedProperties();
        }

        /// <summary>Copies a picture to <map>_preview.png beside the scene (delete, then copy) and imports it.</summary>
        public static string SetPreviewFromFile(Scene scene, string file)
        {
            var dst = PreviewPath(scene) ?? throw new InvalidOperationException("Save the map scene first: the preview picture is kept beside it.");
            var full = Path.GetFullPath(dst);
            if (File.Exists(full)) File.Delete(full);
            File.Copy(file, full);
            ImportPicture(dst);
            return dst;
        }

        // Imported at its own size (no power-of-two scaling, no mipmaps), so the tab shows the picture's real size. Build Mod
        // reads the PNG file, not the imported texture.
        static void ImportPicture(string path)
        {
            AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceSynchronousImport);
            var importer = (TextureImporter)AssetImporter.GetAtPath(path);
            importer.npotScale = TextureImporterNPOTScale.None;
            importer.mipmapEnabled = false;
            importer.SaveAndReimport();
        }

        /// <summary>Renders the open preview camera at the Skirmish icon size into <map>_preview.png.</summary>
        public static string CapturePreview(Scene scene)
        {
            var dst = PreviewPath(scene) ?? throw new InvalidOperationException("Save the map scene first: the preview picture is kept beside it.");
            if (!PreviewRig.IsOpen) throw new InvalidOperationException("Open the preview first (UCU Map Kit/Preview/Open Game-View Preview) and frame the shot.");
            var full = Path.GetFullPath(dst);
            if (File.Exists(full)) File.Delete(full);
            PreviewWindow.Capture(full, BuildMod.IconWidth, BuildMod.IconHeight);
            ImportPicture(dst);
            return dst;
        }
    }

    /// <summary>The Map tab's IMGUI body (MapKitWindow hosts it).</summary>
    class MapTab
    {
        string tagText;
        UnityEngine.Object tagsOf;
        string status = "";
        Vector2 scroll;

        public void OnGUI()
        {
            MapPreconditions.Check(out var map);
            var scene = SceneManager.GetActiveScene();
            if (map.exporter == null || map.generator == null)
            {
                EditorGUILayout.HelpBox("The open scene is not a kit map: it needs a terrain with a TerrainGenerator and the EncounterLayerParent object. Open a map, or make one with UCU Map Kit/New Map from Template.", MessageType.Info);
                return;
            }
            scroll = EditorGUILayout.BeginScrollView(scroll);
            EditorGUIUtility.labelWidth = 170f;
            EditorGUILayout.LabelField(new GUIContent("Map id", "The scene's name. Rename the scene file to change it."), new GUIContent(scene.name));

            var so = new SerializedObject(map.exporter);
            so.Update();
            EditorGUILayout.PropertyField(so.FindProperty("mapName"), new GUIContent("Display name", "The name players see in the map list. HBS field MapMetaDataExporter.mapName."));
            EditorGUILayout.PropertyField(so.FindProperty("weight"), new GUIContent("How often it is picked", "The map's weight when the game picks a map at random: retail maps use 1 (city maps 5). HBS field MapMetaDataExporter.weight."));
            so.ApplyModifiedProperties();

            var skins = MapSettings.AvailableBiomes();
            var current = map.generator.biome != null ? map.generator.biome.biomeSkin : Biome.BIOMESKIN.UNDEFINED;
            if (!skins.Contains(current)) skins = skins.Concat(new[] { current }).ToArray();
            int at = Array.IndexOf(skins, current);
            int pick = EditorGUILayout.Popup(new GUIContent("Biome", "The biomes whose art is in this project. Changing it swaps the ground's 8 layers for the new biome's. HBS field TerrainGenerator.biome."), at, skins.Select(s => s.ToString()).ToArray());
            if (pick != at && pick >= 0)
                Try(() => MapSettings.SetBiome(map.terrain, skins[pick]));

            if (tagsOf != map.exporter || tagText == null || GUIUtility.keyboardControl == 0)
            {
                tagText = string.Join(", ", map.exporter.mapTags == null ? new string[0] : map.exporter.mapTags.ToArray());
                tagsOf = map.exporter;
            }
            EditorGUILayout.BeginHorizontal();
            GUI.SetNextControlName("map-tags");
            var edited = EditorGUILayout.DelayedTextField(new GUIContent("Map tags", "Comma-separated. The game and mods select maps by tag (retail: a biome tag, feature tags such as featureLake, and typeArena or typeMission). HBS field MapMetaDataExporter.mapTags."), tagText);
            if (edited != tagText)
            {
                tagText = edited;
                MapSettings.SetTags(map.exporter, edited.Split(','));
            }
            if (GUILayout.Button(new GUIContent("Skirmish defaults", "The biome's tag and typeArena, as retail's arena maps carry."), GUILayout.Width(120)))
                Try(() => { MapSettings.SetTags(map.exporter, MapSettings.SkirmishTags(current)); tagText = null; });
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Preview picture", EditorStyles.boldLabel);
            var previewPath = MapSettings.PreviewPath(scene);
            var picture = previewPath == null ? null : AssetDatabase.LoadAssetAtPath<Texture2D>(previewPath);
            EditorGUILayout.LabelField(picture == null
                ? "None: Build Mod renders the map from above for the Skirmish list."
                : $"{previewPath} ({picture.width}x{picture.height}); Build Mod uses it as the Skirmish picture ({BuildMod.IconWidth}x{BuildMod.IconHeight}; another size is stretched to it).", EditorStyles.wordWrappedLabel);
            if (picture != null)
            {
                var r = GUILayoutUtility.GetRect(BuildMod.IconWidth / 2f, BuildMod.IconHeight / 2f, GUILayout.ExpandWidth(false));
                EditorGUI.DrawPreviewTexture(r, picture, null, ScaleMode.ScaleToFit);
            }
            EditorGUILayout.BeginHorizontal();
            using (new EditorGUI.DisabledScope(!PreviewRig.IsOpen))
                if (GUILayout.Button(new GUIContent("Capture from preview", PreviewRig.IsOpen ? "Render the open preview camera into the picture." : "Open UCU Map Kit/Preview/Open Game-View Preview first.")))
                    Try(() => status = "Saved " + MapSettings.CapturePreview(scene));
            if (GUILayout.Button("Choose a file…"))
            {
                var file = EditorUtility.OpenFilePanel("Preview picture", "", "png");
                if (!string.IsNullOrEmpty(file)) Try(() => status = "Saved " + MapSettings.SetPreviewFromFile(scene, file));
            }
            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Moods the game uses on this biome", EditorStyles.boldLabel);
            string[] moods;
            try { moods = PreviewRig.SupportedMoods(); }
            catch (Exception e) { moods = new[] { "(could not read the game's mood list: " + e.Message + ")" }; }
            EditorGUILayout.LabelField(moods.Length == 0 ? "(none listed)" : string.Join(", ", moods), EditorStyles.wordWrappedLabel);
            EditorGUILayout.LabelField("A contract on this map picks one of these. Look at each with UCU Map Kit/Preview.", EditorStyles.miniLabel);

            if (status != "") EditorGUILayout.HelpBox(status, MessageType.None);
            EditorGUILayout.EndScrollView();
        }

        void Try(Action a)
        {
            try { a(); status = ""; }
            catch (Exception e) { status = e.Message; Debug.LogException(e); }
        }
    }
}
