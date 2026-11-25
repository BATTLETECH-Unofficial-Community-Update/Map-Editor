// UCU Map Kit: the shared loader mod. Every kit map's mod folder carries a mapkit-map.json and no DLL; this one ModTek mod
// reads them all in a MetadataDatabase.Init postfix and writes each map's Map and EncounterLayer rows through HBS's own
// MetadataDatabase API (MapsAndEncounters_MDDExtensions). One shared DLL, because a DLL per map with one assembly name
// collides as soon as two kit maps are installed.
using System;
using System.IO;
using BattleTech;
using BattleTech.Data;
using HarmonyLib;
using HBS.Collections;
using Newtonsoft.Json;

namespace MapKitLoader
{
    /// <summary>The map row and its encounter-layer rows, as Build Mod writes them to mapkit-map.json.</summary>
    public sealed class MapKitMap
    {
        public string id;
        public string displayName;
        public string scenePath;
        public string biome;
        public string[] tags;
        public int weight = 1;
        public MapKitLayer[] layers;
    }

    public sealed class MapKitLayer
    {
        public string guid;
        public string name;
        public string friendlyName;
        public int contractTypeId;
        public string contractType;
    }

    public static class Entry
    {
        public const string FileName = "mapkit-map.json";
        static string logPath;
        internal static string modsDir;

        public static void Init(string directory, string settingsJSON)
        {
            var own = Path.GetFullPath(directory).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar);
            logPath = Path.Combine(own, "MapKitLoader.log");
            modsDir = Path.GetDirectoryName(own);
            try { File.WriteAllText(logPath, ""); } catch { }
            try
            {
                var harmony = new Harmony("ucu.mapkit.loader");
                harmony.PatchAll(typeof(Entry).Assembly);
                Log("PATCH installed MetadataDatabase.Init postfix; mods folder " + modsDir);
                // The map kit needs no GDPR notice, and never touches analytics. Only a game the kit's Test map
                // started (it sets this variable on that process) skips MainMenu.ShowFirstRunInfo, the Paradox welcome and the
                // GDPR notice, so nothing is answered and reporting stays as it was. A launch by the player shows them as UCU does.
                if (Environment.GetEnvironmentVariable(TestMapVariable) == "1")
                {
                    var target = AccessTools.Method(typeof(BattleTech.UI.MainMenu), "ShowFirstRunInfo");
                    harmony.Patch(target, prefix: new HarmonyMethod(typeof(Entry), nameof(SkipFirstRunInfo)));
                    Log("TESTMAP first-run notices skipped for this session (" + TestMapVariable + "=1)");
                }
                Launch.Install(harmony);   // MapKitLoader.Launch.cs: -ucuMap; installs nothing without it
            }
            catch (Exception e) { Log("PATCH_ERROR " + e); }
        }

        /// <summary>Set to 1 by the kit's Test map on the UCU process it starts.</summary>
        public const string TestMapVariable = "UCU_MAPKIT_TESTMAP";

        static bool SkipFirstRunInfo() => false;

        internal static void InstallAll(MetadataDatabase mdd)
        {
            string[] dirs;
            try { dirs = Directory.GetDirectories(modsDir); }
            catch (Exception e) { Log("SCAN_ERROR " + modsDir + " " + e.Message); return; }
            Array.Sort(dirs, StringComparer.OrdinalIgnoreCase);
            int found = 0, installed = 0;
            foreach (var dir in dirs)
            {
                var file = Path.Combine(dir, FileName);
                if (!File.Exists(file))
                    continue;
                found++;
                if (!ModEnabled(dir)) { Log("MAPKIT_SKIP " + file + ": the map's mod is disabled"); continue; }
                // A bad file is logged and skipped; it never stops the other maps.
                try { Install(mdd, file); installed++; }
                catch (Exception e) { Log("MAPKIT_SKIP " + file + ": " + e.Message); }
            }
            Log("MAPKIT_DONE files=" + found + " installed=" + installed);
        }

        // A map mod the player turned off must not reach the map list: ModTek keeps the switch in modstate.json beside
        // mod.json; mod.json's own Enabled is the default.
        internal static bool ModEnabled(string dir)
        {
            foreach (var name in new[] { "modstate.json", "mod.json" })
            {
                var path = Path.Combine(dir, name);
                if (!File.Exists(path)) continue;
                try
                {
                    var token = Newtonsoft.Json.Linq.JObject.Parse(File.ReadAllText(path))["Enabled"];
                    if (token != null) return (bool)token;
                }
                catch (Exception e) { Log("MAPKIT_STATE_ERROR " + path + ": " + e.Message); }
            }
            return true;
        }

        static void Install(MetadataDatabase mdd, string file)
        {
            var map = JsonConvert.DeserializeObject<MapKitMap>(File.ReadAllText(file));
            if (map == null || string.IsNullOrEmpty(map.id) || string.IsNullOrEmpty(map.scenePath))
                throw new InvalidDataException("no map id or scene path");
            // GetOrCreateMap takes the MapID from the scene file name; a mismatch would write the rows under another id.
            if (Path.GetFileNameWithoutExtension(map.scenePath) != map.id)
                throw new InvalidDataException("scene path " + map.scenePath + " does not end in " + map.id + ".unity");
            if (map.id.ToLowerInvariant().Contains("template"))
                throw new InvalidDataException("map id " + map.id + " contains \"template\"; the game never loads such an id");
            if (map.layers == null || map.layers.Length == 0)
                throw new InvalidDataException("no encounter layers");
            var biome = (Biome.BIOMESKIN)Enum.Parse(typeof(Biome.BIOMESKIN), map.biome, false);
            var tags = new TagSet(map.tags ?? new string[0]);

            mdd.GetOrCreateMap(map.scenePath);
            mdd.UpdateMap(map.id, map.displayName ?? map.id, 1, biome, tags, map.scenePath, true, map.weight);
            Log("MAPKIT_ROW Map id=" + map.id + " name=\"" + map.displayName + "\" path=" + map.scenePath + " biome=" + biome +
                " tags=" + string.Join(",", tags.ToArray()) + " weight=" + map.weight + " from " + file);
            foreach (var layer in map.layers)
            {
                mdd.GetOrCreateEncounterLayer(map.id, layer.guid);
                mdd.UpdateEncounterLayer(map.id, layer.guid, layer.name, layer.friendlyName, "", 0, layer.contractTypeId, new TagSet(), true);
                Log("MAPKIT_ROW EncounterLayer id=" + map.id + "." + layer.guid + " name=" + layer.name + " friendly=\"" +
                    layer.friendlyName + "\" contractType=" + layer.contractType + "/" + layer.contractTypeId);
            }

            var readback = mdd.GetReleasedMapByName(map.id, false);
            if (readback == null)
            {
                Log("MAPKIT_READBACK map=" + map.id + " null (no released layer of a published contract type)");
                return;
            }
            Log("MAPKIT_READBACK map=" + readback.Map.MapID + " path=" + readback.Map.MapPath + " layers=" + readback.Encounters.Length);
            foreach (var layer in readback.Encounters)
                Log("MAPKIT_READBACK_LAYER map=" + readback.Map.MapID + " name=" + layer.Name + " type=" + layer.ContractTypeID);
        }

        internal static void Log(string line)
        {
            try { File.AppendAllText(logPath, line + Environment.NewLine); } catch { }
        }
    }

    [HarmonyPatch(typeof(MetadataDatabase), "Init")]
    static class MetadataDatabaseInitPatch
    {
        static void Postfix(MetadataDatabase __instance) => Entry.InstallAll(__instance);
    }
}
