// UCU Map Kit: "Extract Retail Maps…", the data side. The list of maps comes from the modder's own retail install (setup/
// list_retail_maps.py reads the game's database, scene list and map icons), the estimates come from the measurements of the
// extraction route (KR1g: staging plus export took 39 to 40 s per GB of input and used 2.74 to 2.75 times the input in disk at
// its peak; the export is 1.74 times the input), and the settings are per machine (EditorPrefs), never in the project.
// Nothing here touches the network.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace UCU.MapKit
{
    public class RetailMap
    {
        public string id, level, name, biome, pack, scene, icon;
        public long levelBytes, inputBytes;
        public int inputFiles;

        /// <summary>Disk in use at the export's peak: the staged input plus the export (KR1g: 19.6 GB for 7.15 GB of input).</summary>
        public long PeakDiskBytes => (long)(inputBytes * RetailMaps.PeakDiskFactor);
        public long ExportBytesCap => (long)(inputBytes * RetailMaps.ExportFactor * 2);
        public double ExportMinutes => inputBytes / 1e9 * RetailMaps.SecondsPerInputGB / 60.0;
        public string SceneRelative => $"Assets/Level Design/Maps/{id}/{id}.unity";
    }

    public static class RetailMaps
    {
        public const string RetailPref = "UCU.MapKit.RetailInstall";
        public const string ToolPref = "UCU.MapKit.AssetManager";
        public const double PeakDiskFactor = 2.75, ExportFactor = 1.74, SecondsPerInputGB = 40;
        public const long ReserveBytes = 10L * 1000 * 1000 * 1000; // free space that must remain after the peak

        public static string RetailInstall
        {
            get => EditorPrefs.GetString(RetailPref, "");
            set => EditorPrefs.SetString(RetailPref, value ?? "");
        }

        /// <summary>The Mapkit Asset Manager build to run: its AssetRipper.CLI.dll (setup/assetripper-patches/build.ps1 makes one).</summary>
        public static string AssetManager
        {
            get => EditorPrefs.GetString(ToolPref, "");
            set => EditorPrefs.SetString(ToolPref, value ?? "");
        }

        /// <summary>Free bytes on the drive that holds a folder. Replaceable so a harness can stand in a small drive.</summary>
        public static Func<string, long> FreeBytes = folder => new DriveInfo(Path.GetPathRoot(Path.GetFullPath(folder))).AvailableFreeSpace;

        /// <summary>The export watch stops a run whose output drive falls below this many GB free (default 10).</summary>
        public static int DriveFreeMinGB = 10;

        public static string ProjectRoot => Path.GetDirectoryName(Application.dataPath);
        public static string OutputRoot => Path.Combine(ProjectRoot, "MapKitOutput", "retail-maps");
        public static string CatalogDir => Path.Combine(OutputRoot, "_catalog");
        public static string CatalogFile => Path.Combine(CatalogDir, "retail-maps.tsv");
        public static string WorkDir(string id) => Path.Combine(OutputRoot, id);
        public static string DoneFile(string id) => Path.Combine(WorkDir(id), "done.json");
        public static string SceneFile(string id) => Path.Combine(Application.dataPath, "Level Design", "Maps", id, id + ".unity");

        /// <summary>The kit package's folder, found from this script's own path (the kit has no asmdef).</summary>
        static string packageRoot;

        public static string PackageRoot()
        {
            if (packageRoot != null && Directory.Exists(packageRoot)) return packageRoot;
            var script = AssetDatabase.FindAssets("RetailMaps t:MonoScript").Select(AssetDatabase.GUIDToAssetPath).FirstOrDefault(p => p.EndsWith("/Editor/RetailMaps.cs"))
                ?? throw new InvalidOperationException("The kit's RetailMaps.cs was not found, so its setup folder cannot be located.");
            var pkg = UnityEditor.PackageManager.PackageInfo.FindForAssetPath(script);
            return packageRoot = pkg != null ? pkg.resolvedPath : Path.GetFullPath(Path.GetDirectoryName(Path.GetDirectoryName(script)));
        }

        public static string Setup(string file) => Path.Combine(PackageRoot(), "setup", file);

        /// <summary>The picture for a map: retail's own icon (converted by the scan, on this machine only), else the overhead
        /// picture the kit ships in previews, else null. Source is "icon", "shipped" or "none".</summary>
        public static string PreviewFile(RetailMap m, out string source)
        {
            var icon = Path.Combine(CatalogDir, "previews", m.id + ".png");
            if (File.Exists(icon)) { source = "icon"; return icon; }
            var shipped = Path.Combine(PackageRoot(), "previews", m.id + ".png");
            if (File.Exists(shipped)) { source = "shipped"; return shipped; }
            source = "none";
            return null;
        }

        public static List<RetailMap> LoadCatalog()
        {
            var list = new List<RetailMap>();
            if (!File.Exists(CatalogFile)) return list;
            foreach (var line in File.ReadLines(CatalogFile).Skip(1))
            {
                var c = line.Split('\t');
                if (c.Length < 10) continue;
                list.Add(new RetailMap { id = c[0], level = c[1], name = c[2], biome = c[3], pack = c[4], scene = c[5], icon = c[6],
                    levelBytes = long.Parse(c[7]), inputFiles = int.Parse(c[8]), inputBytes = long.Parse(c[9]) });
            }
            return list.OrderBy(m => m.name, StringComparer.OrdinalIgnoreCase).ToList();
        }

        /// <summary>The retail map a scene comes from: its own name when it is an extracted retail map, else the map it was saved from
        /// with File > Save As (recorded by MapOwnAssets in its layer-links file), else null.</summary>
        public static string SourceMap(string scenePath)
        {
            var name = Path.GetFileNameWithoutExtension(scenePath ?? "");
            if (name.Length > 0 && LoadCatalog().Any(m => m.id == name)) return name;
            return ContractLayers.CopiedFrom(scenePath);
        }

        /// <summary>The line Prepare Lighting from Retail, Rebuild Terrain-Type Masks and the bake's size check give for a scene with no source.</summary>
        public static string NoSource(string map) =>
            $"{map} is not a map extracted from retail, and it records no retail map it was saved from. This step works on an extracted retail map, or on a copy saved from one with File > Save As.";

        /// <summary>"Extracted" when the map's scene is in the project and a run of this window finished it; "In the project" when the
        /// scene is there without that record (another route put it there, or a run ended early); "" otherwise.</summary>
        public static string Status(RetailMap m)
        {
            if (!File.Exists(SceneFile(m.id))) return "";
            return File.Exists(DoneFile(m.id)) ? "Extracted" : "In the project";
        }

        public static string FindInstall()
        {
            var pf = Environment.GetFolderPath(Environment.SpecialFolder.ProgramFilesX86);
            foreach (var c in new[] { Path.Combine(pf, "Steam", "steamapps", "common", "BATTLETECH"), @"C:\GOG Games\BATTLETECH", Path.Combine(pf, "GOG Galaxy", "Games", "BATTLETECH") }) // abs-path-ok: the store's default install folder, probed for the modder
                if (InstallProblem(c) == null) return c;
            return null;
        }

        /// <summary>Why a folder is not a retail BATTLETECH install, or null. The files are the ones the extraction reads.</summary>
        public static string InstallProblem(string dir)
        {
            if (string.IsNullOrEmpty(dir)) return "No retail BATTLETECH install folder is set. Choose the folder that holds BattleTech_Data.";
            if (!Directory.Exists(dir)) return $"The retail install folder {dir} does not exist.";
            var data = Path.Combine(dir, "BattleTech_Data");
            if (!File.Exists(Path.Combine(data, "globalgamemanagers")) || !File.Exists(Path.Combine(data, "level0")))
                return $"{dir} has no BattleTech_Data\\globalgamemanagers and level files: choose your retail BATTLETECH folder (not the UCU one).";
            if (!File.Exists(Path.Combine(data, "StreamingAssets", "MDD", "MetadataDatabase.db")))
                return $"{dir} has no BattleTech_Data\\StreamingAssets\\MDD\\MetadataDatabase.db, the game's map list.";
            return null;
        }

        /// <summary>Python 3 as the kit runs it: the py launcher (py -3), else python. Null when neither runs.</summary>
        public static (string exe, string prefix)? FindPython()
        {
            foreach (var (exe, prefix) in new[] { ("py", "-3 "), ("python", "") })
                if (Quick(exe, prefix + "-c \"import UnityPy, PIL\"", out _)) return (exe, prefix);
            return null;
        }

        public static bool Quick(string exe, string args, out string output)
        {
            output = "";
            try
            {
                var p = Process.Start(new ProcessStartInfo(exe, args) { UseShellExecute = false, RedirectStandardOutput = true, RedirectStandardError = true, CreateNoWindow = true });
                output = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
                p.WaitForExit();
                return p.ExitCode == 0;
            }
            catch (System.ComponentModel.Win32Exception) { return false; }
        }

        public static string Gb(long bytes) => $"{bytes / 1e9:F1} GB";
        public static string Size(long bytes) => bytes >= 1000L * 1000 * 1000 ? Gb(bytes) : $"{bytes / 1e6:F0} MB";
        public static string Minutes(double m) => m < 1 ? "under 1 min" : $"about {Math.Round(m)} min";
    }
}
