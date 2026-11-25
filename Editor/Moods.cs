// UCU Map Kit: "New Mood…" (plan .hermes/plans/2026-11-19-map-kit.md -> X3; probe .hermes/reports/map-kit-x3-probe-20261123/final.md).
// A new mood is a copy of a MoodSettings (retail's own, which Extract Retail Maps brings for the map's biome; or one made here), kept
// beside the map scene in <map folder>/Moods/<name>.asset. The modder edits its fog,
// light and sky in the asset's own inspector. Its tags put it in one biome's pool: the target biome's required mood tags (the game
// draws a contract's mood from every Mood row holding all of them, Contract.cs:1278-1281) plus the three mood_mapType tags, so it lists
// in every mode. No new biome: the biome is a compile-time enum (probe section 4).
// Build Mod puts the map's moods in their own AssetBundle, <map>_moods: Unity refuses scenes and other assets in one bundle, so they
// cannot go in the scene bundle. It also writes mapkit-moods.json, which the shared MapKitLoader mod reads to write the Mood rows and to
// load the mood from the bundle when the game asks for it (the game itself looks only in Resources).
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using BattleTech;
using BattleTech.Data;
using BattleTech.Rendering.Mood;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace UCU.MapKit
{
    /// <summary>mapkit-moods.json. MapKitLoader reads the same field names.</summary>
    [Serializable]
    public class MapKitMoodFile
    {
        public MapKitMoodRow[] moods;
    }

    [Serializable]
    public class MapKitMoodRow
    {
        public string name;
        public string friendlyName;
        public string[] tags;
        public string bundle;
        public string bundlePath;
    }

    public static class Moods
    {
        public const string Folder = "Moods";
        public const string RegistryFile = "mapkit-moods.json";
        // Retail moods meant for every mode carry all three (JungleDayMisty: mood_mapTypeGeneral, mood_mapTypeCampaign, mood_mapTypeArena).
        public static readonly string[] MapTypeTags = { "mood_mapTypeGeneral", "mood_mapTypeCampaign", "mood_mapTypeArena" };

        [MenuItem("UCU Map Kit/New Mood…")]
        public static void Open() => EditorWindow.GetWindow<NewMoodWindow>(false, "New Mood", true);

        /// <summary>Where the retail moods of an extracted map are kept: Extract Retail Maps copies the moods the game draws for the map's
        /// biome here (setup/retail_moods.py). Never a Resources folder: nothing here ships in a mod unless a mood copy refers to it.</summary>
        public const string RetailFolder = "Assets/MapKitRetailMoods/Moods";

        /// <summary>A mood a new one can start from: its asset, the group the list shows it under and its friendly name.</summary>
        [Serializable]
        public class MoodSource
        {
            public string path, group, friendly;
            public string Label => group + "/" + friendly;
        }

        /// <summary>The moods a new one can start from, grouped by where they come from: retail's moods for this map's biome and for
        /// other biomes (Extract Retail Maps brings the biome's moods with each map), the project's Resources/Moods (the template's
        /// DefaultMood), and any other mood in the project that is not a kit map's own. Every group is listed. An extraction brings the
        /// moods of the map's biome into RetailFolder (map-kit MOODS); before that it brought none, and a list that preferred
        /// Resources/Moods showed only the template's DefaultMood (map-kit A1 D14).</summary>
        public static MoodSource[] SourceMoods(Biome.BIOMESKIN mapBiome, out string note)
        {
            var all = AssetDatabase.FindAssets("t:MoodSettings").Select(AssetDatabase.GUIDToAssetPath).OrderBy(p => p, StringComparer.OrdinalIgnoreCase).ToArray();
            // The game's own rule says which biomes draw a mood: the Mood rows holding the biome's required tags (Contract.GetMood).
            var pools = new Dictionary<string, List<Biome.BIOMESKIN>>(StringComparer.OrdinalIgnoreCase);
            var friendly = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
            try
            {
                foreach (var b in Enum.GetValues(typeof(Biome.BIOMESKIN)).Cast<Biome.BIOMESKIN>().Where(b => b != Biome.BIOMESKIN.UNDEFINED && b != Biome.BIOMESKIN.generic))
                    foreach (var m in MetadataDatabase.Instance.GetSupportedMoodsForBiome(b, new HBS.Collections.TagSet()))
                    {
                        if (!pools.TryGetValue(m.Name, out var list)) pools[m.Name] = list = new List<Biome.BIOMESKIN>();
                        list.Add(b); friendly[m.Name] = m.FriendlyName;
                    }
            }
            catch (Exception e) { Debug.LogWarning("UCU Map Kit: New Mood could not read the game's mood pools, so retail moods are listed without a biome: " + e.Message); }

            // A retail mood is one the game draws for some biome (a pool above), wherever the project keeps it: the extraction's moods are in
            // RetailFolder, and a map whose scene refers to a mood by GUID brings that one into Resources/Moods with the map's own assets.
            bool InRetail(string p) => !IsKitMood(p) && (Path.GetDirectoryName(p).Replace('\\', '/') == RetailFolder || pools.ContainsKey(Path.GetFileNameWithoutExtension(p)));
            bool InResources(string p) => p.IndexOf("/Resources/Moods/", StringComparison.OrdinalIgnoreCase) >= 0;
            var retail = all.Where(InRetail).ToArray();
            var resources = all.Where(p => !InRetail(p) && InResources(p)).ToArray();
            var other = all.Where(p => !InRetail(p) && !InResources(p) && !IsKitMood(p)).ToArray();

            string Friendly(string p) => friendly.TryGetValue(Path.GetFileNameWithoutExtension(p), out var f) ? f
                : AssetDatabase.LoadAssetAtPath<MoodSettings>(p)?.GetFriendlyName() ?? Path.GetFileNameWithoutExtension(p);
            string Group(string p)
            {
                if (!pools.TryGetValue(Path.GetFileNameWithoutExtension(p), out var biomes)) return "Retail, no biome";
                if (biomes.Contains(mapBiome)) return $"Retail, this map's biome ({Pretty(mapBiome)})";
                return $"Retail, other biomes/{Pretty(biomes[0])}{(biomes.Count > 1 ? $" and {biomes.Count - 1} more" : "")}";
            }
            var list2 = retail.Select(p => new MoodSource { path = p, group = Group(p), friendly = Friendly(p) })
                .OrderBy(s => s.group.StartsWith("Retail, this map") ? 0 : 1).ThenBy(s => s.group, StringComparer.OrdinalIgnoreCase).ThenBy(s => s.friendly, StringComparer.OrdinalIgnoreCase).ToList();
            list2.AddRange(resources.Select(p => new MoodSource { path = p, group = "In Resources/Moods", friendly = Friendly(p) }));
            list2.AddRange(other.Select(p => new MoodSource { path = p, group = "Elsewhere in this project", friendly = Friendly(p) }));
            int inBiome = list2.Count(s => s.group.StartsWith("Retail, this map"));
            note = list2.Count == 0
                ? "This project has no mood to copy. Extract a retail map first: it brings the moods the game draws for the map's biome."
                : $"{retail.Length} retail moods ({inBiome} for this map's biome), {resources.Length} in Resources/Moods, {other.Length} elsewhere in the project."
                  + (retail.Length == 0 ? " Extract a retail map to bring the moods of its biome." : "");
            return list2.ToArray();
        }

        /// <summary>tundraFrozen -> Tundra frozen (the game's own biome skin name).</summary>
        public static string Pretty(Biome.BIOMESKIN biome)
        {
            var words = System.Text.RegularExpressions.Regex.Replace(biome.ToString(), "([a-z])([A-Z])", "$1 $2").ToLowerInvariant();
            return char.ToUpperInvariant(words[0]) + words.Substring(1);
        }

        // A kit mood: in a Moods folder beside a map scene.
        static bool IsKitMood(string path)
        {
            var dir = Path.GetDirectoryName(path);
            return Path.GetFileName(dir) == Folder && Directory.GetFiles(Path.GetDirectoryName(dir), "*.unity").Length > 0;
        }

        /// <summary>The map's mood folder: Moods beside the map scene.</summary>
        public static string MoodFolder(string scenePath) => $"{Path.GetDirectoryName(scenePath).Replace('\\', '/')}/{Folder}";

        public static string[] MapMoods(string scenePath)
        {
            var folder = MoodFolder(scenePath);
            if (!AssetDatabase.IsValidFolder(folder)) return new string[0];
            return AssetDatabase.FindAssets("t:MoodSettings", new[] { folder }).Select(AssetDatabase.GUIDToAssetPath)
                .Where(p => Path.GetDirectoryName(p).Replace('\\', '/') == folder).OrderBy(p => p, StringComparer.Ordinal).ToArray();
        }

        public static string BundleName(string map) => map.ToLowerInvariant() + "_moods";

        /// <summary>The biome's required mood tags, from the game's database (BiomeSkin.RequiredMoodTagSetID).</summary>
        public static string[] BiomeTags(Biome.BIOMESKIN biome) =>
            MetadataDatabase.Instance.GetBiome(biome)?.RequiredMoodTagSetEntry?.TagSet?.ToArray() ?? new string[0];

        /// <summary>The tags of a mood copied from <paramref name="source"/> for <paramref name="biome"/>: the source's time, fog and
        /// other tags, without any biome's required tag, plus the target biome's required tags and the three mood_mapType tags.</summary>
        public static string[] TagsFor(IEnumerable<string> source, Biome.BIOMESKIN biome)
        {
            var biomeTags = new HashSet<string>(Enum.GetValues(typeof(Biome.BIOMESKIN)).Cast<Biome.BIOMESKIN>().SelectMany(BiomeTags), StringComparer.OrdinalIgnoreCase);
            var target = BiomeTags(biome);
            if (target.Length == 0)
                throw new InvalidOperationException($"Biome {biome} has no required mood tag in the game's database, so no map would draw the mood.");
            return MapTypeTags.Concat(target).Concat(source.Where(t => !biomeTags.Contains(t)))
                .Distinct(StringComparer.OrdinalIgnoreCase).ToArray();
        }

        /// <summary>Copies the mood at <paramref name="sourcePath"/> to the open map's Moods folder as <paramref name="name"/>, with the
        /// friendly name and the tags for <paramref name="biome"/>, and selects it so its inspector shows. Returns the new asset's path.</summary>
        public static string Create(string sourcePath, string name, string friendlyName, Biome.BIOMESKIN biome)
        {
            var scene = EditorSceneManager.GetActiveScene();
            if (string.IsNullOrEmpty(scene.path))
                throw new InvalidOperationException("Save the map scene first: its moods are kept beside it.");
            name = (name ?? "").Trim();
            friendlyName = (friendlyName ?? "").Trim();
            if (name.Length == 0 || name.Any(c => !(char.IsLetterOrDigit(c) || c == '_')))
                throw new InvalidOperationException($"Mood name [{name}] must be letters, digits or _ only: it is the asset's name and the game's mood id.");
            if (friendlyName.Length == 0)
                throw new InvalidOperationException("Give the mood a friendly name: the Skirmish lobby lists it.");
            var source = AssetDatabase.LoadAssetAtPath<MoodSettings>(sourcePath) ?? throw new InvalidOperationException($"{sourcePath} is not a mood.");
            // The game's Mood table keys both names uniquely (Mood.Name, Mood.FriendlyName UNIQUE).
            var mdd = MetadataDatabase.Instance;
            if (mdd.GetMood(name) != null)
                throw new InvalidOperationException($"The game already has a mood named {name}.");
            if (mdd.Query<Mood_MDD>("SELECT * FROM Mood WHERE FriendlyName=@F", new { F = friendlyName }).Any())
                throw new InvalidOperationException($"The game already has a mood called \"{friendlyName}\".");
            foreach (var other in AssetDatabase.FindAssets("t:MoodSettings").Select(AssetDatabase.GUIDToAssetPath).Select(AssetDatabase.LoadAssetAtPath<MoodSettings>).Where(m => m != null))
            {
                if (string.Equals(other.name, name, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidOperationException($"This project already has a mood named {name} ({AssetDatabase.GetAssetPath(other)}).");
                if (string.Equals(other.uniqueFriendlyName, friendlyName, StringComparison.OrdinalIgnoreCase))
                    throw new InvalidOperationException($"This project already has a mood called \"{friendlyName}\" ({AssetDatabase.GetAssetPath(other)}).");
            }
            var tags = TagsFor(source.moodTags, biome);

            var folder = MoodFolder(scene.path);
            if (!AssetDatabase.IsValidFolder(folder))
                AssetDatabase.CreateFolder(Path.GetDirectoryName(folder).Replace('\\', '/'), Folder);
            var path = $"{folder}/{name}.asset";
            if (!AssetDatabase.CopyAsset(sourcePath, path))
                throw new InvalidOperationException($"Copying {sourcePath} to {path} failed.");
            var mood = AssetDatabase.LoadAssetAtPath<MoodSettings>(path);
            var so = new SerializedObject(mood);
            so.FindProperty("uniqueFriendlyName").stringValue = friendlyName;
            var items = so.FindProperty("moodTags.items");
            items.arraySize = tags.Length;
            for (int i = 0; i < tags.Length; i++) items.GetArrayElementAtIndex(i).stringValue = tags[i];
            so.ApplyModifiedPropertiesWithoutUndo();
            AssetDatabase.SaveAssetIfDirty(mood);
            Selection.activeObject = mood;
            Debug.Log($"UCU Map Kit: New Mood {path} from {sourcePath}: \"{friendlyName}\", biome {biome}, tags {string.Join(",", tags)}. Edit its fog, light and sky in its inspector.");
            return path;
        }

        /// <summary>The map's mood bundle for Build Mod, or null when the map has no mood.</summary>
        public static AssetBundleBuild? Bundle(string scenePath, string map)
        {
            var moods = MapMoods(scenePath);
            if (moods.Length == 0) return null;
            return new AssetBundleBuild { assetBundleName = BundleName(map), assetNames = moods };
        }

        /// <summary>Writes mapkit-moods.json for the map's moods into <paramref name="outputDir"/>; returns its path, or null when the
        /// map has no mood.</summary>
        public static string WriteRegistry(string outputDir, string scenePath, string map)
        {
            var moods = MapMoods(scenePath).Select(AssetDatabase.LoadAssetAtPath<MoodSettings>).ToArray();
            if (moods.Length == 0) return null;
            var bundle = BundleName(map);
            var file = new MapKitMoodFile
            {
                moods = moods.Select(m => new MapKitMoodRow
                {
                    name = m.name,
                    friendlyName = m.GetFriendlyName(),
                    tags = m.moodTags.ToArray(),
                    bundle = bundle,
                    bundlePath = "bundle/" + bundle,
                }).ToArray(),
            };
            var path = Path.Combine(outputDir, RegistryFile);
            Directory.CreateDirectory(outputDir);
            File.WriteAllText(path, JsonUtility.ToJson(file, true));
            return path;
        }
    }

    public class NewMoodWindow : EditorWindow
    {
        // The window's state is public so a harness drives the window's own path (Refresh, Choose, CreateSelected), not Moods.Create alone.
        public Moods.MoodSource[] sources = new Moods.MoodSource[0];
        public string note, result;
        public int source;
        public string moodName = "", friendlyName = "";
        public Biome.BIOMESKIN biome = Biome.BIOMESKIN.UNDEFINED;

        // Wide enough for the longest entry ("Retail, other biomes/Desert parched and 1 more/Arid Afternoon Clear"): at the default width the popup cut the mood's own name off.
        void OnEnable() { minSize = new Vector2(620f, 300f); Refresh(); }

        /// <summary>Reads the open map's biome and the project's moods again.</summary>
        public void Refresh()
        {
            var t = Terrain.activeTerrain;
            var generator = t != null ? t.GetComponent<TerrainGenerator>() : null;
            if (generator != null && generator.biome != null) biome = generator.biome.biomeSkin;
            sources = Moods.SourceMoods(biome, out note);
            source = Mathf.Clamp(source, 0, Mathf.Max(0, sources.Length - 1));
        }

        /// <summary>Picks the source mood by its asset name (what the list shows under its friendly name); false when it is not listed.</summary>
        public bool Choose(string assetName)
        {
            var i = Array.FindIndex(sources, s => Path.GetFileNameWithoutExtension(s.path) == assetName);
            if (i < 0) return false;
            source = i; return true;
        }

        /// <summary>What the Create button does.</summary>
        public string CreateSelected()
        {
            try { return result = "Created " + Moods.Create(sources[source].path, moodName, friendlyName, biome); }
            catch (Exception e) { return result = e.Message; }
        }

        void OnGUI()
        {
            EditorGUILayout.HelpBox(note, sources.Length > 0 ? MessageType.Info : MessageType.Warning);
            if (sources.Length == 0) return;
            source = EditorGUILayout.Popup("Copy of", source, sources.Select(s => s.Label).ToArray());
            moodName = EditorGUILayout.TextField("Name", moodName);
            friendlyName = EditorGUILayout.TextField("Friendly name", friendlyName);
            biome = (Biome.BIOMESKIN)EditorGUILayout.EnumPopup("Biome", biome);
            EditorGUILayout.HelpBox("The mood joins the biome's pool: every map of that biome can draw it. Edit its fog, light and sky in the new asset's inspector.", MessageType.None);
            if (GUILayout.Button("Create")) CreateSelected();
            if (!string.IsNullOrEmpty(result)) EditorGUILayout.HelpBox(result, MessageType.None);
            var scene = EditorSceneManager.GetActiveScene();
            if (string.IsNullOrEmpty(scene.path)) return;
            EditorGUILayout.LabelField("This map's moods", EditorStyles.boldLabel);
            foreach (var p in Moods.MapMoods(scene.path))
                if (GUILayout.Button(Path.GetFileNameWithoutExtension(p), EditorStyles.linkLabel))
                    Selection.activeObject = AssetDatabase.LoadAssetAtPath<MoodSettings>(p);
        }
    }
}
