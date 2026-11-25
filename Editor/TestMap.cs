// UCU Map Kit: "Test map in UCU". One chain, each step named; the first failure stops it and says which step and why:
// install folder → Map Check → Export → Bake lighting if stale → Build Mod → copy the mod into <UCU>/Mods/<map> (delete,
// then copy) → install the shared MapKitLoader if it is missing → start UCU. The bake is asynchronous, so the chain
// resumes when it ends. The UCU install folder is per machine (EditorPrefs), never in the project.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;
using Debug = UnityEngine.Debug;

namespace UCU.MapKit
{
    public class TestMapRun
    {
        public string map;
        public string install;
        public List<string> steps = new List<string>();
        public string failedStep;
        public string error;
        public bool running;
        public bool Succeeded => !running && failedStep == null && steps.Count == TestMap.StepCount;
    }

    public static class TestMap
    {
        public const string InstallPref = "UCU.MapKit.InstallFolder";
        public const int StepCount = 8;
        public const string Exe = "BattleTech.exe";

        public static string InstallFolder
        {
            get => EditorPrefs.GetString(InstallPref, "");
            set => EditorPrefs.SetString(InstallPref, value ?? "");
        }

        /// <summary>Starts UCU: (exe, arguments, working folder) → what was started. Replaceable so a check can record the
        /// command instead of starting the game.</summary>
        /// <summary>Environment variable Test map sets on the UCU process it starts; MapKitLoader then skips the game's
        /// first-run notices (the Paradox welcome and the GDPR notice) for that session only. Nothing is written to the
        /// install's settings, and analytics are never touched.</summary>
        public const string TestMapVariable = "UCU_MAPKIT_TESTMAP";

        public static Func<string, string, string, string> Starter = (exe, args, dir) =>
        {
            var info = new ProcessStartInfo(exe, args) { WorkingDirectory = dir, UseShellExecute = false };
            info.EnvironmentVariables[TestMapVariable] = "1";
            var p = Process.Start(info);
            return $"started {exe} (pid {p.Id}) in {dir} with {TestMapVariable}=1";
        };

        public static TestMapRun Current { get; private set; }
        public static event Action<TestMapRun> Ended;

        [MenuItem("UCU Map Kit/Test Map in UCU")]
        static void Menu()
        {
            var w = MapKitWindow.OpenTab(MapKitWindow.Tab.Build);
            if (string.IsNullOrEmpty(InstallFolder)) { Debug.LogWarning("UCU Map Kit: set the UCU install folder in the Map Kit window's Build tab first."); return; }
            Run();
            w.Repaint();
        }

        /// <summary>Runs the chain on the open map. It returns while the bake (if one is needed) runs; Current and Ended report the end.</summary>
        public static TestMapRun Run(string install = null)
        {
            if (Current != null && Current.running) throw new InvalidOperationException("Test map is already running.");
            var r = Current = new TestMapRun { install = install ?? InstallFolder, running = true, map = SceneManager.GetActiveScene().name };
            if (!Step(r, "1/8 Install folder", () => CheckInstall(r.install))) return r;
            if (!Step(r, "2/8 Map Check", () =>
            {
                var errors = MapCheck.Run().Where(e => e.severity == MapCheckSeverity.Error).ToList();
                if (errors.Count > 0) throw new InvalidOperationException($"{errors.Count} error(s); open the Check tab to fix them. {string.Join(" ", errors.Select(e => e.ToString()))}");
                return "0 errors";
            })) return r;
            if (!Step(r, "3/8 Export", () =>
            {
                if (SceneManager.GetActiveScene().isDirty) throw new InvalidOperationException("The scene has unsaved changes. Save it first.");
                var x = MapExport.Export(validate: true);
                if (x.validation.Count > 0) throw new InvalidOperationException($"{x.validation.Count} validation error(s): {string.Join("; ", x.validation)}");
                return $"{x.files.Count} files";
            })) return r;
            const string bake = "4/8 Bake lighting";
            if (MapBake.IsStale(SceneManager.GetActiveScene(), out var why))
            {
                if (!Step(r, bake + " (started)", () => $"{why}; {MapBake.Start()}", record: false)) return r;
                MapBake.Finished += Resume;
                return r;
            }
            r.steps.Add($"{bake}: not needed ({why})");
            return Continue(r);
        }

        static void Resume(BakeState s)
        {
            MapBake.Finished -= Resume;
            var r = Current;
            if (r == null || !r.running) return;
            if (!Step(r, "4/8 Bake lighting", () => s == BakeState.Done ? MapBake.Message : throw new InvalidOperationException(MapBake.Message))) return;
            Continue(r);
        }

        static TestMapRun Continue(TestMapRun r)
        {
            BuildModResult built = null;
            if (!Step(r, "5/8 Build Mod", () =>
            {
                built = BuildMod.Build();
                if (built.failedStep != null) throw new InvalidOperationException($"Build Mod stopped at its step {built.failedStep}: {built.error}");
                return $"{built.files.Count} files in {built.outputDir}";
            })) return r;
            if (!Step(r, "6/8 Install the map", () => CopyFolder(built.outputDir, Path.Combine(r.install, "Mods", built.map)))) return r;
            if (!Step(r, "7/8 MapKitLoader", () => InstallLoader(r.install))) return r;
            if (!Step(r, "8/8 Start UCU", () => Starter(Path.Combine(r.install, Exe), "-ucuMap " + built.map, r.install))) return r;
            r.running = false;
            Debug.Log($"UCU Map Kit: Test map: {r.map} is installed in {r.install}\\Mods and UCU was started with -ucuMap {built.map}: the map starts by itself (MapKitLoader presses Skirmish, selects the map, then Play and BEGIN MISSION). The same argument works by hand: BattleTech.exe -ucuMap {built.map}.");
            Ended?.Invoke(r);
            return r;
        }

        static bool Step(TestMapRun r, string name, Func<string> body, bool record = true)
        {
            try
            {
                var detail = body();
                if (record) r.steps.Add($"{name}: {detail}");
                Debug.Log($"UCU Map Kit: Test map step {name}: {detail}");
                return true;
            }
            catch (Exception e)
            {
                r.failedStep = name.Replace(" (started)", "");
                r.error = e.Message;
                r.running = false;
                Debug.LogError($"UCU Map Kit: Test map stopped at step {r.failedStep}: {e.Message}");
                Ended?.Invoke(r);
                return false;
            }
        }

        static string CheckInstall(string dir)
        {
            if (string.IsNullOrEmpty(dir)) throw new InvalidOperationException("No UCU install folder is set. Choose it in the Build tab.");
            if (!Directory.Exists(dir)) throw new InvalidOperationException($"The UCU install folder {dir} does not exist.");
            if (!File.Exists(Path.Combine(dir, Exe))) throw new InvalidOperationException($"{dir} has no {Exe}: choose the folder UCU is installed in.");
            if (!Directory.Exists(Path.Combine(dir, "Mods", "ModTek"))) throw new InvalidOperationException($"{dir} has no Mods\\ModTek: kit maps load through ModTek. Install ModTek v4 into {dir}\\Mods\\ModTek (the kit README, Prerequisites, says where to get it); UCU's installer does not install it.");
            return dir;
        }

        // Delete, then copy, file by file: nothing is written through an old file or a link left in the target.
        static string CopyFolder(string from, string to)
        {
            if (Directory.Exists(to)) Directory.Delete(to, true);
            int n = 0; long bytes = 0;
            foreach (var f in Directory.GetFiles(from, "*", SearchOption.AllDirectories))
            {
                var dst = Path.Combine(to, f.Substring(from.Length + 1));
                Directory.CreateDirectory(Path.GetDirectoryName(dst));
                File.Copy(f, dst);
                n++; bytes += new FileInfo(dst).Length;
            }
            return $"{n} files, {bytes:N0} B in {to}";
        }

        static string LoaderVersion(string modJson)
        {
            if (!File.Exists(modJson)) return null;
            var m = System.Text.RegularExpressions.Regex.Match(File.ReadAllText(modJson), "\"Version\"\\s*:\\s*\"([^\"]+)\"");
            return m.Success ? m.Groups[1].Value : null;
        }

        // One MapKitLoader serves every kit map. When it is missing it is built from the kit's Loader~ source against
        // this install's game code and ModTek's Harmony (the README's dotnet command), outside the package, then copied in.
        static string InstallLoader(string install)
        {
            var target = Path.Combine(install, "Mods", BuildMod.LoaderMod);
            // An older loader has no -ucuMap, so the same version in source and install is the test, not the DLL alone.
            var installedVersion = LoaderVersion(Path.Combine(target, "mod.json"));
            // The kit's scripts compile into the project's Editor assembly (the package has no asmdef), so the package is
            // found from this script's own path.
            var script = AssetDatabase.FindAssets("TestMap t:MonoScript").Select(AssetDatabase.GUIDToAssetPath).FirstOrDefault(p => p.EndsWith("/Editor/TestMap.cs"))
                ?? throw new InvalidOperationException("The kit's TestMap.cs was not found, so its Loader~ source cannot be located.");
            var pkg = UnityEditor.PackageManager.PackageInfo.FindForAssetPath(script);
            var root = pkg != null ? pkg.resolvedPath : Path.GetFullPath(Path.GetDirectoryName(Path.GetDirectoryName(script)));
            var src = Path.Combine(root, "Loader~");
            if (!File.Exists(Path.Combine(src, BuildMod.LoaderMod + ".csproj")))
                throw new InvalidOperationException($"The kit's loader source is not at {src}.");
            if (File.Exists(Path.Combine(target, BuildMod.LoaderMod + ".dll")) && installedVersion != null && installedVersion == LoaderVersion(Path.Combine(src, "mod.json")))
                return $"already installed in {target}";
            var work = Path.Combine(Path.GetDirectoryName(Application.dataPath), "MapKitOutput", "_loader");
            if (Directory.Exists(work)) Directory.Delete(work, true);
            var srcCopy = Path.Combine(work, "src");
            CopyFolder(src, srcCopy);
            var outDir = Path.Combine(work, BuildMod.LoaderMod);
            var managed = Path.Combine(install, "BattleTech_Data", "Managed");
            var harmony = Path.Combine(install, "Mods", "ModTek", "lib", "0Harmony.dll");
            var args = $"build \"{Path.Combine(srcCopy, BuildMod.LoaderMod + ".csproj")}\" -c Release -nologo \"-p:ManagedDir={managed}\" \"-p:HarmonyDll={harmony}\" -o \"{outDir}\"";
            string output;
            int code;
            try
            {
                var p = Process.Start(new ProcessStartInfo("dotnet", args) { UseShellExecute = false, RedirectStandardOutput = true, RedirectStandardError = true, CreateNoWindow = true, WorkingDirectory = srcCopy });
                output = p.StandardOutput.ReadToEnd() + p.StandardError.ReadToEnd();
                p.WaitForExit();
                code = p.ExitCode;
            }
            catch (System.ComponentModel.Win32Exception)
            {
                throw new InvalidOperationException($"{BuildMod.LoaderMod} is not installed and the .NET SDK (dotnet) is not on this machine to build it. Install the .NET SDK, or build the loader as the kit README says and put it in {target}.");
            }
            File.WriteAllText(Path.Combine(work, "build.log"), output);
            if (code != 0 || !File.Exists(Path.Combine(outDir, BuildMod.LoaderMod + ".dll")))
                throw new InvalidOperationException($"Building {BuildMod.LoaderMod} failed (dotnet exit {code}); the log is {Path.Combine(work, "build.log")}.");
            foreach (var f in Directory.GetFiles(outDir).Where(f => !f.EndsWith(".dll") && !f.EndsWith("mod.json")))
                File.Delete(f);
            return "built and installed: " + CopyFolder(outDir, target);
        }
    }
}
