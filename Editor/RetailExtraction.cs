// UCU Map Kit: "Extract Retail Maps…", the chain. For each picked map, in order, each step named; the first failure stops the
// whole run and names its step and why (the log of that step is in MapKitOutput/retail-maps/<map>/). Checks first (retail
// install and the game's Wwise runtime copied from it, tools, free disk), then per map:
//   1/6 Stage input        setup/closure-list.py + setup/stage-ar-input.ps1: the map's level file, its external files and the
//                          game's managed code, copied from the retail install (read-only on the install); setup/retail-null-meshes.py
//                          lists the renderers retail itself ships with no mesh (retail-null-meshes.tsv, for the open counts)
//   2/6 Export             setup/export-map.ps1: Mapkit Asset Manager (AssetRipper with stable GUIDs) under the 5 s size watch
//   3/6 Embed scene logic  setup/embed_scene_logic.py: the encounter logic goes back into the scene file, as retail has it; then
//                          setup/strip_null_scripts.py removes the components retail shipped with no script (UCU's retail fix E11) and
//                          setup/drop_tree_prototypes.py the tree prototypes retail shipped with no prefab (UCU's retail fix E09)
//   4/6 Cut the closure    setup/closure.py (every asset the scene reaches, by GUID; 0 unresolved) and the size gate
//                          (setup/retail-closure-size.py: the closure against the map's retail data, 2x stops it); then
//                          setup/retail_moods.py: the moods the game draws for the map's biome (the biome's required mood tags) and
//                          their closure, with its own size gate against retail's objects (nothing is copied yet)
//   5/6 Import             setup/import_closure.py copy (the closure into Assets; an asset whose GUID the project has is not copied
//                          again; then the moods into Assets/MapKitRetailMoods, never a Resources folder) and bind (the export's script GUIDs onto the game code in the project); then
//                          setup/to_webm.py turns the VideoClips it copied (the urban maps' billboards, H.264 .m4v) into VP8 .webm
//                          under the same GUIDs, as UCU holds them (needs ffmpeg with libvpx and libvorbis)
//   6/6 Delete the export  the staged input and the export (12 to 24 GB), then the next map
// Unity's auto refresh and script reload are held for the whole run, and Unity imports what was copied when the run ends.
// The tools are external programs; Mapkit Asset Manager is GPL-3.0 and is run, never linked. No network is used.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;

namespace UCU.MapKit
{
    /// <summary>One external command or in-process action, with its output in a log file.</summary>
    public class Job
    {
        public bool Done, Failed;
        public int Exit;
        public string Log, Error;
        Process process;
        Task task;
        StreamWriter log, outFile;
        readonly object gate = new object();

        public static Job Run(string exe, string args, string logPath, string outPath = null)
        {
            var j = new Job { Log = logPath };
            Directory.CreateDirectory(Path.GetDirectoryName(logPath));
            j.log = new StreamWriter(logPath, true) { AutoFlush = true };
            j.log.WriteLine($"> {exe} {args}");
            if (outPath != null) j.outFile = new StreamWriter(outPath, false) { AutoFlush = true };
            try
            {
                var p = j.process = new Process { StartInfo = new ProcessStartInfo(exe, args) { UseShellExecute = false, RedirectStandardOutput = true, RedirectStandardError = true, CreateNoWindow = true } };
                p.OutputDataReceived += (s, e) => { if (e.Data != null) { lock (j.gate) { (j.outFile ?? j.log).WriteLine(e.Data); } } };
                p.ErrorDataReceived += (s, e) => { if (e.Data != null) { lock (j.gate) { j.log.WriteLine(e.Data); } } };
                p.Start();
                p.BeginOutputReadLine();
                p.BeginErrorReadLine();
            }
            catch (Exception e) { j.Finish(1, $"{exe} could not be started: {e.Message}"); }
            return j;
        }

        public static Job Do(string name, Action action, string logPath)
        {
            var j = new Job { Log = logPath };
            Directory.CreateDirectory(Path.GetDirectoryName(logPath));
            j.log = new StreamWriter(logPath, true) { AutoFlush = true };
            j.log.WriteLine($"> {name}");
            j.task = Task.Run(() =>
            {
                try { action(); j.log.WriteLine("done"); j.Finish(0, null); }
                catch (Exception e) { j.log.WriteLine(e.ToString()); j.Finish(1, e.Message); }
            });
            return j;
        }

        void Finish(int exit, string error)
        {
            lock (gate) { Exit = exit; Error = error; Failed = exit != 0; log?.Dispose(); outFile?.Dispose(); log = outFile = null; Done = true; }
        }

        public bool Poll()
        {
            if (Done) return true;
            if (process != null && process.HasExited) { process.WaitForExit(); Finish(process.ExitCode, null); }
            return Done;
        }

        /// <summary>The last non-empty lines of the log, readable while the job still writes it.</summary>
        public string Tail(int lines = 3)
        {
            if (!File.Exists(Log)) return "";
            using (var f = new FileStream(Log, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
            using (var r = new StreamReader(f))
                return string.Join(" | ", r.ReadToEnd().Split((char)10).Select(l => l.Trim()).Where(l => l.Length > 0).Reverse().Take(lines).Reverse());
        }
    }

    public class ExtractionRun
    {
        public List<RetailMap> maps;
        public int mapIndex;
        public string step = "", failedStep, error, failedMap;
        public bool running;
        public readonly List<string> lines = new List<string>();
        public readonly Dictionary<string, double> seconds = new Dictionary<string, double>();
        public DateTime started = DateTime.Now;
        public RetailMap Map => mapIndex < maps.Count ? maps[mapIndex] : null;
        public bool Succeeded => !running && failedStep == null && mapIndex >= maps.Count;
    }

    [Serializable] class DoneRecord { public string map, finished; public int closureFiles; public long closureBytes; public string[] steps; }

    public static class RetailExtraction
    {
        public const double GateRatio = 2.0;
        public const long ProjectGrowthBytes = 3L * 1000 * 1000 * 1000; // per map; KR1g added 1.0 GB (taiga) and 1.9 GB (terracePlaza)

        public static ExtractionRun Current { get; private set; }
        public static event Action<ExtractionRun> Ended;
        public static event Action Changed;

        class Step { public string name; public List<Func<Job>> jobs = new List<Func<Job>>(); public Func<int, Job, string> verify = (i, j) => null; public Action after; }

        static List<Step> steps = new List<Step>();
        static int stepIndex, jobIndex;
        static Job job;
        static DateTime stepStarted;
        static bool touchedProject, locked;
        static (string exe, string prefix) py;
        static string tool, install;
        static int closureFiles;
        static long closureBytes;

        static void Say(string text)
        {
            var line = $"{DateTime.Now:HH:mm:ss} {text}";
            Current.lines.Add(line);
            try { Directory.CreateDirectory(RetailMaps.OutputRoot); File.AppendAllText(Path.Combine(RetailMaps.OutputRoot, "run.log"), line + "\n"); } catch (IOException) { }
            UnityEngine.Debug.Log("UCU Map Kit: Extract Retail Maps: " + text);
            Changed?.Invoke();
        }

        static bool Fail(string step, string why)
        {
            var r = Current;
            r.failedStep = step; r.error = why; r.failedMap = r.Map?.id; r.running = false;
            UnityEngine.Debug.LogError($"UCU Map Kit: Extract Retail Maps stopped at step {step}: {why}");
            Say($"STOPPED at {step}: {why}");
            if (r.Map != null)
            {
                // A stopped map gives its disk back (12 to 24 GB); its logs stay in the work folder for the reason.
                var w = RetailMaps.WorkDir(r.Map.id);
                foreach (var d in new[] { Path.Combine(w, "ar-input"), Path.Combine(w, "export") })
                    try { if (Directory.Exists(d)) { Directory.Delete(d, true); Say($"Removed {d}"); } }
                    catch (Exception e) { Say($"Could not remove {d} ({e.Message}); delete it by hand to free the space."); }
            }
            Finish();
            return false;
        }

        static void Finish()
        {
            EditorApplication.update -= Tick;
            if (locked) { AssetDatabase.AllowAutoRefresh(); EditorApplication.UnlockReloadAssemblies(); locked = false; }
            if (touchedProject) AssetDatabase.Refresh();
            Current.running = false;
            Changed?.Invoke();
            Ended?.Invoke(Current);
        }

        /// <summary>Checks, then starts the chain on the picked maps. It returns at once (or with the failed check); Current, Changed and Ended report the rest.</summary>
        public static ExtractionRun Start(IEnumerable<RetailMap> picked)
        {
            if (Current != null && Current.running) throw new InvalidOperationException("An extraction is already running.");
            var r = Current = new ExtractionRun { maps = picked.ToList(), running = true };
            touchedProject = false;
            Say($"{r.maps.Count} map(s): {string.Join(", ", r.maps.Select(m => m.name))}");
            install = RetailMaps.RetailInstall; tool = RetailMaps.AssetManager;
            try
            {
                var bad = RetailMaps.InstallProblem(install);
                if (bad != null) { Fail("Check 1/3 Retail install", bad); return r; }
                bad = InstallWwise(install, out var wwise);
                if (bad != null) { Fail("Check 1/3 Retail install", bad); return r; }
                Say($"Check 1/3 Retail install: {install}; {wwise}");
                var found = RetailMaps.FindPython();
                if (string.IsNullOrEmpty(tool) || !File.Exists(tool))
                { Fail("Check 2/3 Tools", $"Mapkit Asset Manager is not at \"{tool}\". Build it with setup/assetripper-patches/build.ps1 and choose its AssetRipper.CLI.dll."); return r; }
                if (!RetailMaps.Quick("dotnet", "--version", out var dotnet)) { Fail("Check 2/3 Tools", "The .NET SDK (dotnet) does not run on this machine; Mapkit Asset Manager needs it."); return r; }
                if (found == null) { Fail("Check 2/3 Tools", "Python 3 with UnityPy and Pillow does not run here (py -3 -c \"import UnityPy, PIL\"); the setup scripts need it."); return r; }
                py = found.Value;
                foreach (var s in new[] { "closure-list.py", "stage-ar-input.ps1", "export-map.ps1", "embed_scene_logic.py", "strip_null_scripts.py", "drop_tree_prototypes.py", "retail-null-meshes.py", "closure.py", "retail-closure-size.py", "import_closure.py", "to_webm.py", "retail_moods.py" })
                    if (!File.Exists(RetailMaps.Setup(s))) { Fail("Check 2/3 Tools", $"The kit's setup script {s} is missing from {Path.Combine(RetailMaps.PackageRoot(), "setup")}."); return r; }
                Say($"Check 2/3 Tools: Mapkit Asset Manager {tool}, dotnet {dotnet.Trim()}, {py.exe} {py.prefix}".TrimEnd());
                if (!RetailMaps.Quick("ffmpeg", "-version", out _))
                    Say("Warning: ffmpeg is not on PATH. A map with video clips (the urban maps) stops at step 5 until it is installed; then run setup/to_webm.py on Assets/VideoClip.");
                var need = r.maps.Max(m => m.PeakDiskBytes) + r.maps.Count * ProjectGrowthBytes + RetailMaps.ReserveBytes;
                var free = RetailMaps.FreeBytes(RetailMaps.ProjectRoot);
                if (free < need)
                { Fail("Check 3/3 Free disk space", $"The largest picked map needs about {RetailMaps.Gb(r.maps.Max(m => m.PeakDiskBytes))} at its peak, the project grows by up to {RetailMaps.Gb(r.maps.Count * ProjectGrowthBytes)}, and {RetailMaps.Gb(RetailMaps.ReserveBytes)} must stay free: {RetailMaps.Gb(need)} in all, but {RetailMaps.Gb(free)} is free."); return r; }
                Say($"Check 3/3 Free disk space: {RetailMaps.Gb(free)} free, {RetailMaps.Gb(need)} needed");
            }
            catch (Exception e) { Fail("Check", e.Message); return r; }
            Directory.CreateDirectory(RetailMaps.OutputRoot);
            EditorApplication.LockReloadAssemblies();
            AssetDatabase.DisallowAutoRefresh();
            locked = true;
            EditorApplication.update += Tick;
            BeginMap();
            return r;
        }

        /// <summary>The game's Wwise 2016.2.2 runtime (AkSoundEngine.dll and its four effect plugins), copied from the retail install into
        /// Assets/Plugins/x86_64 with the metas UCU tracks for them (Wwise~), as UCU's own project stages them (stage_data.py PLUGIN_DLLS).
        /// HBS's AkGameObj is [ExecuteInEditMode] and registers itself with AkSoundEngine in Awake, so without the DLL a retail map logs
        /// DllNotFoundException once per Wwise object when it opens. The DLLs are the modder's own; the kit never carries them. A file the
        /// project already has is left alone. Returns why it could not, or null; `done` says what it did.</summary>
        static string InstallWwise(string install, out string done)
        {
            done = null;
            var dst = Path.Combine(Application.dataPath, "Plugins", "x86_64");
            var copied = new List<string>();
            foreach (var f in WwiseDlls)
            {
                var t = Path.Combine(dst, f);
                if (File.Exists(t)) continue;
                var s = Path.Combine(install, "BattleTech_Data", "Plugins", f);
                var meta = Path.Combine(RetailMaps.PackageRoot(), "Wwise~", f + ".meta");
                if (!File.Exists(s)) return $"{install} has no BattleTech_Data\\Plugins\\{f}, the game's Wwise sound engine, which the retail maps' sound objects call in the Editor.";
                if (!File.Exists(meta)) return $"The kit's {f}.meta is missing from {Path.GetDirectoryName(meta)}.";
                Directory.CreateDirectory(dst);
                File.Copy(meta, t + ".meta", true);
                File.Copy(s, t);
                copied.Add(f);
            }
            if (copied.Count > 0) touchedProject = true;
            done = copied.Count > 0 ? $"Wwise runtime copied into Assets/Plugins/x86_64: {string.Join(", ", copied)}" : "Wwise runtime already in Assets/Plugins/x86_64";
            return null;
        }

        static readonly string[] WwiseDlls = { "AkFlanger.dll", "AkGuitarDistortion.dll", "AkSoundEngine.dll", "AkStereoDelay.dll", "AkTremolo.dll" };

        // ----- the per-map steps -----

        static string Q(string path) => "\"" + path + "\"";
        static Job Py(string log, string script, string args, string outFile = null) => Job.Run(py.exe, $"{py.prefix}{Q(RetailMaps.Setup(script))} {args}", log, outFile);
        static Job Ps(string log, string script, string args) => Job.Run("powershell", $"-NoProfile -ExecutionPolicy Bypass -File {Q(RetailMaps.Setup(script))} {args}", log);

        static void BeginMap()
        {
            var r = Current;
            if (r.Map == null) { Say("All picked maps are extracted."); Finish(); return; }
            var m = r.Map;
            var w = RetailMaps.WorkDir(m.id);
            string input = Path.Combine(w, "ar-input"), export = Path.Combine(w, "export");
            string project = Path.Combine(export, "ExportedProject"), assets = Path.Combine(project, "Assets");
            string list = Path.Combine(w, "closure-files.txt"), closure = Path.Combine(w, "closure.tsv"), moodsClosure = Path.Combine(w, "moods-closure.tsv");
            string L(string n) => Path.Combine(w, n + ".log");
            var data = Path.Combine(install, "BattleTech_Data");
            steps = new List<Step>();

            var s1 = new Step { name = "1/6 Stage input" };
            s1.jobs.Add(() => Job.Do("clear this map's work folder", () => { if (Directory.Exists(w)) Directory.Delete(w, true); Directory.CreateDirectory(w); }, Path.Combine(RetailMaps.OutputRoot, m.id + ".clear.log")));
            s1.jobs.Add(() => Py(L("stage"), "closure-list.py", $"{Q(data)} {m.level}", list));
            s1.jobs.Add(() => Ps(L("stage"), "stage-ar-input.ps1", $"-Install {Q(install)} -Out {Q(input)} -List {Q(list)}"));
            s1.jobs.Add(() => Py(L("stage"), "retail-null-meshes.py", $"{Q(data)} {m.level} {Q(Path.Combine(w, "retail-null-meshes.tsv"))}"));
            s1.verify = (i, j) => i == 1 && !File.ReadLines(list).Any(l => l.Trim() == m.level) ? $"the file closure of {m.level} is empty ({j.Tail()})" : null;
            steps.Add(s1);

            var s2 = new Step { name = "2/6 Export (Mapkit Asset Manager)" };
            s2.jobs.Add(() => Ps(L("export"), "export-map.ps1", $"-In {Q(input)} -Out {Q(export)} -Ar {Q(tool)} -ArLog {Q(Path.Combine(w, "ar.log"))} -WatchLog {Q(Path.Combine(w, "watch.log"))} -LimitBytes {m.ExportBytesCap} -DriveFreeMinGB {RetailMaps.DriveFreeMinGB}"));
            s2.verify = (i, j) =>
            {
                if (!j.Failed) return null;
                var watch = Path.Combine(w, "watch.log");
                var trip = File.Exists(watch) ? File.ReadLines(watch).LastOrDefault(l => l.Contains("TRIPPED")) : null;
                return trip != null ? trip.Substring(trip.IndexOf("TRIPPED")) : $"exit {j.Exit}: {j.Tail()}";
            };
            steps.Add(s2);

            var s3 = new Step { name = "3/6 Embed scene logic" };
            s3.jobs.Add(() => Directory.Exists(Path.Combine(assets, "MonoBehaviour"))
                ? Py(L("embed"), "embed_scene_logic.py", $"--project {Q(project)} --apply")
                : Job.Do("this export has no logic assets: nothing to embed", () => { }, L("embed")));
            s3.jobs.Add(() => Py(L("embed"), "strip_null_scripts.py", $"--project {Q(project)} --scene {Q(m.SceneRelative)} --apply --manifest {Q(Path.Combine(w, "null-scripts.tsv"))}"));
            s3.jobs.Add(() => Py(L("embed"), "drop_tree_prototypes.py", $"--project {Q(project)} --apply --manifest {Q(Path.Combine(w, "tree-prototypes.tsv"))}"));
            steps.Add(s3);

            var s4 = new Step { name = "4/6 Cut the closure" };
            s4.jobs.Add(() => Py(L("closure"), "closure.py", $"{Q(assets)} {Q($"Level Design/Maps/{m.id}/{m.id}.unity")} {Q(closure)}"));
            s4.jobs.Add(() => Py(L("gate"), "retail-closure-size.py", $"{Q(data)} {Q(Path.Combine(export, "AuxiliaryFiles", "path_id_map.json"))} {Q(closure)} {Q(assets)} {m.level} {GateRatio:F1}"));
            // The map's retail moods (the game's rule: the biome's required tags): their closure and its size gate, before anything is copied.
            s4.jobs.Add(() => Py(L("moods"), "retail_moods.py", $"{Q(assets)} {Q(install)} {m.id} {Q(moodsClosure)} {Q(list)}"));
            s4.verify = (i, j) =>
            {
                if (i == 2)
                {
                    var text = File.Exists(L("moods")) ? File.ReadAllText(L("moods")) : "";
                    var stop = System.Text.RegularExpressions.Regex.Match(text, @"GATE STOP: [^\r\n]*");
                    if (stop.Success) return "retail moods: " + stop.Value;
                    var found = System.Text.RegularExpressions.Regex.Match(text, @"MOODS [^\r\n]*moods by the game's rule");
                    var total = System.Text.RegularExpressions.Regex.Match(text, @"GATE total [^\r\n]*");
                    if (!j.Failed) Say($"{m.name}: retail moods: {(found.Success ? found.Value.Substring(found.Value.IndexOf(':') + 2) : "none")}{(total.Success ? "; " + total.Value : "")}");
                    return null;
                }
                if (i == 0)
                {
                    if (j.Failed) return null;
                    var text = File.ReadAllText(L("closure"));
                    var m1 = System.Text.RegularExpressions.Regex.Match(text, @"closure files=(\d+) bytes=(\d+)");
                    if (m1.Success) { closureFiles = int.Parse(m1.Groups[1].Value); closureBytes = long.Parse(m1.Groups[2].Value); }
                    var m2 = System.Text.RegularExpressions.Regex.Match(text, @"unresolved non-builtin guids: (\d+) distinct");
                    return m2.Success && m2.Groups[1].Value == "0" ? null : $"the closure has unresolved GUIDs ({(m2.Success ? m2.Value : j.Tail())})";
                }
                var g = File.Exists(L("gate")) ? File.ReadLines(L("gate")).LastOrDefault(l => l.StartsWith("GATE")) : null;
                if (j.Exit == 3) return "size gate: " + (g ?? j.Tail());
                if (g != null) Say($"{m.name}: size {g.Substring(5)}");   // every map's ratio and categories over the limit, on record
                return null;
            };
            steps.Add(s4);

            var s5 = new Step { name = "5/6 Import" };
            s5.jobs.Add(() => { touchedProject = true; return Py(L("import"), "import_closure.py", $"copy {Q(assets)} {Q(closure)} {Q(Application.dataPath)}"); });
            // The retail moods, into Assets/MapKitRetailMoods (never a Resources folder): an asset whose GUID the project has is not copied again.
            s5.jobs.Add(() => Py(L("import"), "import_closure.py", $"copy {Q(assets)} {Q(moodsClosure)} {Q(Application.dataPath)}"));
            s5.jobs.Add(() => Py(L("import"), "import_closure.py", $"bind {Q(assets)} {Q(Application.dataPath)} {Q(Path.Combine(w, "bind.tsv"))}"));
            s5.jobs.Add(() => Directory.Exists(Path.Combine(Application.dataPath, "VideoClip"))
                ? Py(L("import"), "to_webm.py", Q(Path.Combine(Application.dataPath, "VideoClip")))
                : Job.Do("this project has no VideoClip folder: nothing to convert", () => { }, L("import")));
            steps.Add(s5);

            var s6 = new Step { name = "6/6 Delete the export" };
            s6.jobs.Add(() => Job.Do("keep retail's LightingData (Prepare Lighting from Retail reads it)", () =>
            {
                var src = Path.Combine(assets, "Level Design", "Maps", m.id, m.id, "LightingData.asset");
                if (File.Exists(src)) File.Copy(src, RetailLighting.RetailLightingDataFile(m.id), true);
            }, L("delete")));
            s6.jobs.Add(() => Job.Do("delete the staged input and the export", () => { foreach (var d in new[] { input, export }) if (Directory.Exists(d)) Directory.Delete(d, true); }, L("delete")));
            s6.after = () =>
            {
                var rec = new DoneRecord { map = m.id, finished = DateTime.Now.ToString("o"), closureFiles = closureFiles, closureBytes = closureBytes,
                    steps = Current.seconds.Where(kv => kv.Key.StartsWith(m.id + " ")).Select(kv => $"{kv.Key}: {kv.Value:F0} s").ToArray() };
                File.WriteAllText(RetailMaps.DoneFile(m.id), JsonUtility.ToJson(rec, true));
            };
            steps.Add(s6);

            stepIndex = jobIndex = 0; job = null;
            Say($"{m.name} ({m.id}, {m.level}): input {RetailMaps.Gb(m.inputBytes)}, estimate {RetailMaps.Minutes(m.ExportMinutes)}, peak disk {RetailMaps.Gb(m.PeakDiskBytes)}");
        }

        static void Tick()
        {
            var r = Current;
            if (r == null || !r.running) { EditorApplication.update -= Tick; return; }
            try
            {
                if (job == null)
                {
                    if (stepIndex >= steps.Count) { r.mapIndex++; BeginMap(); return; }
                    if (jobIndex == 0) { stepStarted = DateTime.Now; r.step = $"{r.Map.name}: {steps[stepIndex].name}"; Say($"{r.step} (started)"); }
                    job = steps[stepIndex].jobs[jobIndex]();
                    return;
                }
                if (!job.Poll()) return;
                var s = steps[stepIndex];
                var why = s.verify(jobIndex, job);
                if (why == null && job.Failed) why = job.Error ?? $"exit {job.Exit}: {job.Tail()}";
                if (why != null) { Fail($"{r.Map.name}: {s.name}", why); return; }
                job = null;
                if (++jobIndex >= s.jobs.Count)
                {
                    var took = (DateTime.Now - stepStarted).TotalSeconds;
                    r.seconds[$"{r.Map.id} {s.name}"] = took;
                    Say($"{r.Map.name}: {s.name}: ok, {took:F0} s");
                    s.after?.Invoke();
                    stepIndex++; jobIndex = 0;
                }
            }
            catch (Exception e) { Fail($"{r.Map?.id}: {(stepIndex < steps.Count ? steps[stepIndex].name : "finish")}", e.Message); }
        }
    }
}
