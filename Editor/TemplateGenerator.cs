// UCU Map Kit: "New Map from Template". Builds a new contract-map scene from code: terrain, SplatMapInfo design masks,
// mood, the scene-level HBS objects, a SimpleBattle and an ArenaSkirmish encounter layer. No retail scene is copied (decision D6); the
// field values come from the K1 inventory of a retail map. HBS code is called, never copied.
using System;
using System.IO;
using System.Linq;
using BattleTech;
using BattleTech.Rendering;
using BattleTech.Rendering.Mood;
using BattleTech.UI;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace UCU.MapKit
{
    public enum TemplateHeights { Flat, Noise }

    [Serializable]
    public class TemplateSettings
    {
        public string mapName = "mapKit_new";
        public string displayName = "";
        public Biome.BIOMESKIN biome = Biome.BIOMESKIN.tundraFrozen;
        public int terrainSize = 2048;
        public TemplateHeights heights = TemplateHeights.Flat;
        public float noiseAmplitude = 30f;
        public MoodSettings mood;
        public string folder = "Assets/MapKitMaps";
    }

    public static partial class TemplateGenerator
    {
        // Retail map values recorded by the K1 inventory (.hermes/reports/map-kit-k1-20261120/inventory.md).
        const int HeightmapResolution = 1025;
        const int AlphamapResolution = 2048;
        const int BaseMapResolution = 2048;
        const int DetailResolution = 2048;
        // Vertical layout of the terrain, derived from retail (KT, .hermes/reports/map-kit-kt-20261122/final.md). Measured on
        // the 78 shipped terrain maps (`TerrainData.bin` cell heights; the 7 urban maps have all-zero cells, a flat 33x33
        // plane at 0, and are left out) and on 10 maps' TerrainData assets and scenes (7 terrain, 3 urban; the two sources'
        // lowest ground and median agree to 0.1 m):
        //   - the 7 terrain maps read from assets sit at position y 0 with size y 2048 m and 1025 samples, whatever their kind
        //     (taiga, moon, desert, jungle, mars, glacier, split river), so the template does too: HeightRange is retail's
        //     2048 m, not the terrain size;
        //   - ground height above the bottom of that range: the median of the 78 maps' own median ground is 189.7 m
        //     (p10 122 m, p90 305 m); the median of their lowest ground is 87.6 m, so retail itself digs about 105 m below
        //     its own median (p90 217 m, most 312 m). Rule: flat ground at the rounded median of retail's medians, 190 m,
        //     which leaves the digging room retail's typical map uses (about 105 m) with room to spare, and 1,858 m up.
        // The old template used the biome's baseHeight (1.56 m; no HBS code reads it), so erosion reached 0 m in a few strokes.
        const float HeightRange = 2048f;
        const float GroundHeight = 190f;
        const string TerrainShaderName = "Terrain/BT-Terrain";
        const string DefaultMoodName = "DefaultMood";
        const string TerrainObjectName = "terrain_instance_x0_y0";
        const string DropPodLandedName = "DropPodLanded";
        // Every retail map scene (85 of 85) uses DefaultReflectionMode.Custom with this cubemap (taiga: m_CustomReflection
        // blank_reflection). Unity 6's RenderSettings.customReflection getter throws on a scene without one, which aborts
        // HBS's SkyScattering.OnEnable (SkyScattering.cs:664) before its fog, ambient and reflection setup.
        const string ReflectionCubemapName = "blank_reflection";
        static readonly string[] MaskNames = { "water", "deepWater", "forest", "rough", "custom", "road", "impassable" };

        [MenuItem("UCU Map Kit/New Map from Template…")]
        static void OpenWindow() => EditorWindow.GetWindow<TemplateWindow>(true, "New Map from Template");

        /// <summary>Creates the scene and its assets under settings.folder/mapName and leaves it open. Returns the scene path.</summary>
        public static string Generate(TemplateSettings s)
        {
            if (string.IsNullOrEmpty(s.mapName) || s.mapName.IndexOfAny(Path.GetInvalidFileNameChars()) >= 0 || s.mapName.Contains(" "))
                throw new ArgumentException($"Map name [{s.mapName}] must be a file name without spaces: it becomes the scene name and the map id.");
            // HBS marks every manifest entry whose id contains "template" as a template and never loads it
            // (VersionManifestEntry.cs:152, LoadRequest.TryCreateAndAddLoadRequest): the map's bundle and data would not load.
            if (s.mapName.IndexOf("template", StringComparison.OrdinalIgnoreCase) >= 0)
                throw new ArgumentException($"Map name [{s.mapName}] must not contain \"template\": the game skips any file whose id contains it, so the map would not load.");
            if (AssetDatabase.FindAssets("t:Scene").Select(AssetDatabase.GUIDToAssetPath).Any(p => Path.GetFileNameWithoutExtension(p) == s.mapName))
                throw new InvalidOperationException($"A scene named [{s.mapName}] already exists in this project.");
            if (s.terrainSize < 256 || (s.terrainSize & (s.terrainSize - 1)) != 0)
                throw new ArgumentException($"Terrain size [{s.terrainSize}] must be a power of two of at least 256 m.");

            var biome = FindBiome(s.biome);
            var layers = FindTerrainLayers(s.biome);
            var shader = Shader.Find(TerrainShaderName) ?? throw new InvalidOperationException($"Shader [{TerrainShaderName}] is not in this project.");
            var mood = s.mood != null ? s.mood : FindAsset<MoodSettings>(DefaultMoodName, "t:MoodSettings");
            var dropPodLanded = FindAsset<GameObject>(DropPodLandedName, "t:Prefab");
            var reflection = FindAsset<Cubemap>(ReflectionCubemapName, "t:Cubemap");

            var dir = $"{s.folder}/{s.mapName}";
            if (AssetDatabase.IsValidFolder(dir))
                throw new InvalidOperationException($"Folder [{dir}] already exists.");
            CreateFolders(dir);

            // NewScene unloads unused assets: anything loaded above is destroyed and its references read null (biome,
            // mood: K1c probe). The lookups above only refuse early; the assets are loaded again from their paths here.
            var paths = new[] { biome, (UnityEngine.Object)mood, dropPodLanded, reflection }.Concat(layers).Select(AssetDatabase.GetAssetPath).ToArray();
            var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
            biome = AssetDatabase.LoadAssetAtPath<Biome>(paths[0]);
            mood = AssetDatabase.LoadAssetAtPath<MoodSettings>(paths[1]);
            dropPodLanded = AssetDatabase.LoadAssetAtPath<GameObject>(paths[2]);
            reflection = AssetDatabase.LoadAssetAtPath<Cubemap>(paths[3]);
            layers = paths.Skip(4).Select(AssetDatabase.LoadAssetAtPath<TerrainLayer>).ToArray();
            shader = Shader.Find(TerrainShaderName);
            var terrain = BuildTerrain(s, dir, biome, layers, shader);
            BuildMood(mood);
            BuildSceneObjects();
            BuildEncounterLayerParent(s, dropPodLanded, terrain);
            RenderSettings.defaultReflectionMode = UnityEngine.Rendering.DefaultReflectionMode.Custom;
            RenderSettings.customReflectionTexture = reflection;

            var scenePath = $"{dir}/{s.mapName}.unity";
            if (!EditorSceneManager.SaveScene(scene, scenePath))
                throw new InvalidOperationException($"Saving [{scenePath}] failed.");
            // Reopen from disk so Export works on exactly what was saved. (The biome that read null to Export in the creating
            // session, docs-map-kit-shots-1, was an asset unloaded by NewScene; it is now reloaded after NewScene above.)
            EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Single);
            return scenePath;
        }

        internal static Biome FindBiome(Biome.BIOMESKIN skin)
        {
            var biome = AssetDatabase.FindAssets("t:Biome").Select(g => AssetDatabase.LoadAssetAtPath<Biome>(AssetDatabase.GUIDToAssetPath(g)))
                .FirstOrDefault(b => b != null && b.biomeSkin == skin);
            return biome != null ? biome : throw new InvalidOperationException($"No Biome asset for [{skin}] in this project: set up the art of a map with this biome first.");
        }

        // A biome's 8 terrain layers are named envTxrTerr_<biome in snake case>_layer<0-7>_... (retail art naming).
        internal static TerrainLayer[] FindTerrainLayers(Biome.BIOMESKIN skin)
        {
            var key = "envTxrTerr_" + string.Concat(skin.ToString().Select((c, i) => char.IsUpper(c) && i > 0 ? "_" + char.ToLowerInvariant(c) : c.ToString())) + "_layer";
            var all = AssetDatabase.FindAssets("t:TerrainLayer").Select(g => AssetDatabase.LoadAssetAtPath<TerrainLayer>(AssetDatabase.GUIDToAssetPath(g))).ToArray();
            var layers = new TerrainLayer[8];
            for (int i = 0; i < 8; i++)
                layers[i] = all.Where(l => l != null && l.diffuseTexture != null && l.diffuseTexture.name.StartsWith(key + i + "_", StringComparison.Ordinal))
                    .OrderBy(l => l.name, StringComparer.Ordinal).FirstOrDefault();
            if (layers.Any(l => l == null))
                throw new InvalidOperationException($"Biome [{skin}] has {layers.Count(l => l != null)} of its 8 terrain layers ({key}0..7) in this project.");
            return layers;
        }

        static T FindAsset<T>(string name, string filter) where T : UnityEngine.Object
        {
            var asset = AssetDatabase.FindAssets($"{name} {filter}").Select(g => AssetDatabase.LoadAssetAtPath<T>(AssetDatabase.GUIDToAssetPath(g)))
                .FirstOrDefault(a => a != null && a.name == name);
            return asset != null ? asset : throw new InvalidOperationException($"[{name}] ({typeof(T).Name}) is not in this project.");
        }

        internal static Texture2D FindTexture(string name) => AssetDatabase.FindAssets($"{name} t:Texture2D")
            .Select(g => AssetDatabase.LoadAssetAtPath<Texture2D>(AssetDatabase.GUIDToAssetPath(g))).FirstOrDefault(t => t != null && t.name == name);

        static void CreateFolders(string dir)
        {
            var parts = dir.Split('/');
            for (int i = 1; i < parts.Length; i++)
            {
                var parent = string.Join("/", parts.Take(i));
                if (!AssetDatabase.IsValidFolder(parent + "/" + parts[i]))
                    AssetDatabase.CreateFolder(parent, parts[i]);
            }
        }

        static Terrain BuildTerrain(TemplateSettings s, string dir, Biome biome, TerrainLayer[] layers, Shader shader)
        {
            var data = new TerrainData { heightmapResolution = HeightmapResolution };
            data.size = new Vector3(s.terrainSize, HeightRange, s.terrainSize);
            data.alphamapResolution = AlphamapResolution;
            data.baseMapResolution = BaseMapResolution;
            data.SetDetailResolution(DetailResolution, 32);
            // Only a TerrainData that is already an asset saves its alpha-map textures, so create the asset first.
            AssetDatabase.CreateAsset(data, $"{dir}/{s.mapName}_terrain.asset");
            data.terrainLayers = layers;
            var heights = new float[HeightmapResolution, HeightmapResolution];
            var baseHeight = GroundHeight / data.size.y;
            for (int z = 0; z < HeightmapResolution; z++)
                for (int x = 0; x < HeightmapResolution; x++)
                    heights[z, x] = baseHeight + (s.heights == TemplateHeights.Noise
                        ? s.noiseAmplitude / data.size.y * Mathf.PerlinNoise(x * 0.01f, z * 0.01f) : 0f);
            data.SetHeights(0, 0, heights);
            var alpha = new float[AlphamapResolution, AlphamapResolution, layers.Length];
            for (int z = 0; z < AlphamapResolution; z++)
                for (int x = 0; x < AlphamapResolution; x++)
                    alpha[z, x, 0] = 1f;
            data.SetAlphamaps(0, 0, alpha);
            EditorUtility.SetDirty(data);
            AssetDatabase.SaveAssetIfDirty(data);

            // HBS's TerrainMaterialSetup renames the terrain material to "<terrain object> Material"
            // (TerrainMaterialSetup.cs:209), so the asset file carries that name to keep name and file in step.
            const string materialName = TerrainObjectName + " Material";
            var material = new Material(shader) { name = materialName };
            AssetDatabase.CreateAsset(material, $"{dir}/{materialName}.mat");

            var go = Terrain.CreateTerrainGameObject(data);
            go.SetActive(false);
            go.name = TerrainObjectName;
            go.layer = LayerMask.NameToLayer("Terrain");
            go.transform.position = new Vector3(-s.terrainSize / 2f, 0f, -s.terrainSize / 2f);
            GameObjectUtility.SetStaticEditorFlags(go, StaticEditorFlags.ContributeGI);
            var terrain = go.GetComponent<Terrain>();
            terrain.materialTemplate = material;
            terrain.heightmapPixelError = 15f;
            terrain.basemapDistance = 600f;
            terrain.drawInstanced = false;
            // Retail terrain lightmap fields (taiga: scale 0.0512, no LightmapParameters). Unity's defaults for a new
            // terrain (0.0125, Default-VeryLowResolution) lay out 1 system of 256 texels at the retail realtime resolution
            // 0.0625; these give retail's 4 systems / 16,384 texels (K1b bake test).
            var terrainSo = new SerializedObject(terrain);
            terrainSo.FindProperty("m_ScaleInLightmap").floatValue = 0.0512f;
            terrainSo.FindProperty("m_LightmapParameters").objectReferenceValue = null;
            terrainSo.ApplyModifiedPropertiesWithoutUndo();
            go.AddComponent<TerrainGenerator>().biome = biome;
            var setup = go.AddComponent<TerrainMaterialSetup>();
            setup.terrainAlbedo = layers.Select(l => l.diffuseTexture).ToArray();
            setup.terrainNormal = layers.Select(l => l.normalMapTexture).ToArray();
            setup.terrainHeights = layers.Select(l => FindTexture(l.diffuseTexture.name.Replace("_alb", "_hgt"))).ToArray();
            var splat = go.AddComponent<SplatMapInfo>();
            var masks = MaskNames.Select(n => CreateMask(dir, $"{s.mapName}_mask_{n}")).ToArray();
            splat.waterMask = masks[0];
            splat.deepWaterMask = masks[1];
            splat.forestMask = masks[2];
            splat.roughMask = masks[3];
            splat.customMask = masks[4];
            splat.roadMask = masks[5];
            splat.impassableMask = masks[6];
            go.SetActive(true);
            return terrain;
        }

        // One design mask: black (clear) everywhere, readable and uncompressed so SplatMapInfo.LoadSplatData can read it.
        // The map boundary needs no mask: the exporter marks cells within SplatMapInfo.mapBoundaryWidth of the edge.
        static Texture2D CreateMask(string dir, string name)
        {
            var path = $"{dir}/{name}.png";
            var tex = new Texture2D(AlphamapResolution, AlphamapResolution, TextureFormat.RGB24, false);
            tex.SetPixels32(new Color32[AlphamapResolution * AlphamapResolution]);
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
            importer.maxTextureSize = AlphamapResolution;
            importer.textureCompression = TextureImporterCompression.Uncompressed;
            importer.SaveAndReimport();
            return AssetDatabase.LoadAssetAtPath<Texture2D>(path);
        }

        static void BuildMood(MoodSettings mood)
        {
            var root = new GameObject("MoodController") { layer = LayerMask.NameToLayer("Utility") };
            root.SetActive(false);
            var sun = new GameObject("Sunlight") { layer = LayerMask.NameToLayer("Light") };
            sun.transform.SetParent(root.transform, false);
            var light = sun.AddComponent<Light>();
            light.type = LightType.Directional;
            light.shadows = LightShadows.Soft;
            sun.AddComponent<BTSunlight>();
            var probe = new GameObject("Reflection Probe") { layer = LayerMask.NameToLayer("Utility") };
            probe.transform.SetParent(root.transform, false);
            var refProbe = probe.AddComponent<ReflectionProbe>();
            probe.AddComponent<CenterToTerrain>().height = 20f;
            var weather = new GameObject("Weather Controller");
            weather.transform.SetParent(root.transform, false);
            var weatherController = weather.AddComponent<WeatherController>();
            weather.AddComponent<WindZone>();
            var mc = root.AddComponent<MoodController>();
            mc.sunlight = light;
            mc.refProbe = refProbe;
            mc.weatherController = weatherController;
            mc.currentMood = mood;
            root.SetActive(true);
        }

        static void BuildSceneObjects()
        {
            var ux = new GameObject("CombatUXCreator").AddComponent<CombatUXCreator>();
            ux.ObjectiveBeaconName = "uiPrf_objectiveMarker";
            ux.ObjectiveBeaconSecondaryName = "uiPrf_objectiveMarkerSecondary";
            ux.MiniObjectiveBeaconName = "uiPrf_objectiveMarkerMini";
            new GameObject("HBS.DebugConsole.DebugConsole").AddComponent<HBS.DebugConsole.DebugConsole>();
            new GameObject("GAME");
        }
    }

    class TemplateWindow : EditorWindow
    {
        TemplateSettings settings = new TemplateSettings();

        void OnEnable() => minSize = new Vector2(420f, 190f);

        void OnGUI()
        {
            EditorGUIUtility.labelWidth = 190f;
            settings.mapName = EditorGUILayout.TextField("Map name (id)", settings.mapName);
            settings.displayName = EditorGUILayout.TextField("Display name", settings.displayName);
            settings.biome = (Biome.BIOMESKIN)EditorGUILayout.EnumPopup("Biome", settings.biome);
            settings.terrainSize = EditorGUILayout.IntField("Terrain size (m)", settings.terrainSize);
            settings.heights = (TemplateHeights)EditorGUILayout.EnumPopup("Heights", settings.heights);
            if (settings.heights == TemplateHeights.Noise)
                settings.noiseAmplitude = EditorGUILayout.FloatField("Noise amplitude (m)", settings.noiseAmplitude);
            settings.mood = (MoodSettings)EditorGUILayout.ObjectField("Mood (empty: DefaultMood)", settings.mood, typeof(MoodSettings), false);
            if (GUILayout.Button("Create"))
            {
                var path = TemplateGenerator.Generate(settings);
                Debug.Log($"UCU Map Kit: created {path}");
                Close();
            }
        }
    }
}
