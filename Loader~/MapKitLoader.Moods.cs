// UCU Map Kit: new moods (plan .hermes/plans/2026-11-19-map-kit.md -> X3; probe .hermes/reports/map-kit-x3-probe-20261123/final.md).
// A kit map's mod folder may carry mapkit-moods.json (written by Build Mod) and a mood AssetBundle. Two hooks:
// - the MetadataDatabase.Init postfix writes each mood's Mood, TagSet and Tag rows through HBS's own GetOrCreateMood, from the
//   registry's name, friendly name and tags (a stand-in MoodSettings, so no bundle loads at database init);
// - a MoodController.SetMoodByName prefix: the game loads a mood only with Resources.Load("Moods/<name>") (MoodController.cs:853),
//   which never sees a mod bundle and silently keeps the previous mood. For a registered name the prefix loads the MoodSettings
//   from the mod's bundle and applies it as SetMoodByName does; every other name passes through to the game untouched.
using System;
using System.Collections.Generic;
using System.IO;
using BattleTech.Data;
using BattleTech.Rendering.Mood;
using HarmonyLib;
using HBS.Collections;
using Newtonsoft.Json;
using UnityEngine;

namespace MapKitLoader
{
    /// <summary>mapkit-moods.json, as Build Mod writes it.</summary>
    public sealed class MapKitMoodFile
    {
        public MapKitMood[] moods;
    }

    public sealed class MapKitMood
    {
        public string name;
        public string friendlyName;
        public string[] tags;
        public string bundle;     // the bundle's id in mod.json and its AssetBundle name
        public string bundlePath; // relative to the mod folder
        [JsonIgnore] public string modDir;
    }

    public static class Moods
    {
        public const string FileName = "mapkit-moods.json";
        static readonly Dictionary<string, MapKitMood> registry = new Dictionary<string, MapKitMood>(StringComparer.Ordinal);
        static readonly Dictionary<string, MoodSettings> loaded = new Dictionary<string, MoodSettings>(StringComparer.Ordinal);

        internal static void Log(string line)
        {
            Entry.Log("[MapKitLoader] " + line);
            UnityEngine.Debug.Log("[MapKitLoader] " + line);
        }

        internal static void InstallAll(MetadataDatabase mdd)
        {
            registry.Clear();
            string[] dirs;
            try { dirs = Directory.GetDirectories(Entry.modsDir); }
            catch (Exception e) { Log("MOOD_SCAN_ERROR " + Entry.modsDir + " " + e.Message); return; }
            Array.Sort(dirs, StringComparer.OrdinalIgnoreCase);
            int files = 0, rows = 0;
            foreach (var dir in dirs)
            {
                var file = Path.Combine(dir, FileName);
                if (!File.Exists(file))
                    continue;
                files++;
                if (!Entry.ModEnabled(dir)) { Log("MOOD_SKIP " + file + ": the map's mod is disabled"); continue; }
                MapKitMoodFile data;
                try { data = JsonConvert.DeserializeObject<MapKitMoodFile>(File.ReadAllText(file)); }
                catch (Exception e) { Log("MOOD_SKIP " + file + ": " + e.Message); continue; }
                foreach (var mood in data?.moods ?? new MapKitMood[0])
                {
                    // A bad mood is logged and skipped; it never stops the others.
                    try { Install(mdd, mood, dir); rows++; }
                    catch (Exception e) { Log("MOOD_SKIP " + (mood?.name ?? "(no name)") + " in " + file + ": " + e.Message); }
                }
            }
            Log("MOOD_DONE files=" + files + " moods=" + rows);
        }

        static void Install(MetadataDatabase mdd, MapKitMood mood, string dir)
        {
            if (mood == null || string.IsNullOrEmpty(mood.name) || string.IsNullOrEmpty(mood.bundle) || string.IsNullOrEmpty(mood.bundlePath))
                throw new InvalidDataException("no mood name, bundle or bundle path");
            if (Resources.Load("Moods/" + mood.name, typeof(MoodSettings)) != null)
                throw new InvalidDataException("the game already has a mood named " + mood.name);
            if (registry.ContainsKey(mood.name))
                throw new InvalidDataException("another kit map already registered " + mood.name + " (" + registry[mood.name].modDir + ")");
            // GetOrCreateMood reads only name, GetFriendlyName() and moodTags; the stand-in carries those three.
            var standIn = ScriptableObject.CreateInstance<MoodSettings>();
            try
            {
                standIn.name = mood.name;
                standIn.uniqueFriendlyName = mood.friendlyName ?? "";
                standIn.moodTags = new TagSet(mood.tags ?? new string[0]);
                mdd.GetOrCreateMood(standIn);
            }
            finally { UnityEngine.Object.Destroy(standIn); }
            mood.modDir = dir;
            registry[mood.name] = mood;
            var row = mdd.GetMood(mood.name);
            Log("MOOD_ROW name=" + mood.name + " friendly=\"" + mood.friendlyName + "\" tags=" + string.Join(",", mood.tags ?? new string[0]) +
                " bundle=" + mood.bundle + " path=" + mood.bundlePath + " readback=" + (row == null ? "null" : row.MoodID + "/\"" + row.FriendlyName + "\"/" + row.TagSetID));
        }

        /// <summary>The registered mood's MoodSettings from its bundle (loaded once, reused while the bundle stays loaded), or null.</summary>
        static MoodSettings Load(MapKitMood mood)
        {
            if (loaded.TryGetValue(mood.name, out var cached) && cached != null)
                return cached;
            AssetBundle bundle = null;
            foreach (var b in AssetBundle.GetAllLoadedAssetBundles())
                if (string.Equals(b.name, mood.bundle, StringComparison.OrdinalIgnoreCase)) { bundle = b; break; }
            var path = Path.Combine(mood.modDir, mood.bundlePath);
            if (bundle != null)
                Log("MOOD_BUNDLE " + mood.bundle + " already loaded");
            else
            {
                // LoadFromFile on a missing file logs two Unity ERRORs (KFIX6 F6); a mod shipped without its moods bundle is a plain line.
                if (!File.Exists(path))
                {
                    Log("MOOD_BUNDLE " + mood.bundle + " missing: " + path + " (mood " + mood.name + " not loaded; the game's own lookup runs)");
                    return null;
                }
                bundle = AssetBundle.LoadFromFile(path);
                Log("MOOD_BUNDLE " + mood.bundle + " LoadFromFile " + path + " -> " + (bundle == null ? "null" : "ok"));
                if (bundle == null)
                    return null;
            }
            var settings = bundle.LoadAsset<MoodSettings>(mood.name);
            Log("MOOD_ASSET " + mood.name + " from " + mood.bundle + " -> " + (settings == null ? "null" : "ok"));
            if (settings != null)
                loaded[mood.name] = settings;
            return settings;
        }

        internal static bool SetMoodByName(MoodController controller, string moodName, bool applyMood)
        {
            if (string.IsNullOrEmpty(moodName) || !registry.TryGetValue(moodName, out var mood))
                return true;
            MoodSettings settings;
            try { settings = Load(mood); }
            catch (Exception e) { Log("MOOD_LOAD_ERROR " + moodName + ": " + e); return true; }
            if (settings == null)
            {
                Log("MOOD_SET " + moodName + " not loaded; the game's own lookup runs");
                return true;
            }
            // The same three steps as MoodController.SetMoodByName after its Resources.Load.
            controller.currentMood = settings;
            settings.CheckVersion();
            if (applyMood)
                controller.ApplyMood(refreshSky: true, refreshMusic: false);
            Log("MOOD_SET " + moodName + " applied=" + applyMood);
            return false;
        }
    }

    [HarmonyPatch(typeof(MetadataDatabase), "Init")]
    static class MetadataDatabaseInitMoodsPatch
    {
        static void Postfix(MetadataDatabase __instance) => Moods.InstallAll(__instance);
    }

    [HarmonyPatch(typeof(MoodController), nameof(MoodController.SetMoodByName))]
    static class MoodControllerSetMoodByNamePatch
    {
        static bool Prefix(MoodController __instance, string moodName, bool applyMood) => Moods.SetMoodByName(__instance, moodName, applyMood);
    }
}
