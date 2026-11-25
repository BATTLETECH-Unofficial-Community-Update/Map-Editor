// UCU Map Kit: UCU Map Kit/Setup/Extract Retail Maps… The modder's list of the maps in their own retail install, each with a
// preview, name, biome, size and the disk and time it costs; they tick the ones they want, and the window runs the chain
// (RetailExtraction.cs) for those, one map at a time. Maps already in the project show as such, and more can be added later:
// each map is a separate export and the GUIDs agree (setup/assetripper-patches), so a later map fits beside an earlier one.
// Previews: retail's own icon where the game has one (15 of 85 maps), else the overhead picture the kit ships in previews
// (68 maps), else a placeholder; each row says which. The window sends nothing anywhere.
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace UCU.MapKit
{
    public class ExtractRetailMapsWindow : EditorWindow
    {
        List<RetailMap> maps = new List<RetailMap>();
        readonly HashSet<string> picked = new HashSet<string>();
        readonly Dictionary<string, Texture2D> thumbs = new Dictionary<string, Texture2D>();
        Vector2 scroll;
        string filter = "", scanText = "";
        bool hideExtracted;
        Job scan;

        [MenuItem("UCU Map Kit/Setup/Extract Retail Maps…")]
        static void Open()
        {
            var w = GetWindow<ExtractRetailMapsWindow>("Extract Retail Maps");
            w.minSize = new Vector2(640f, 420f);
            w.Reload();
        }

        void OnEnable()
        {
            EditorApplication.update += Poll;
            RetailExtraction.Changed += Repaint;
            Reload();
        }

        void OnDisable()
        {
            EditorApplication.update -= Poll;
            RetailExtraction.Changed -= Repaint;
        }

        void Reload() { maps = RetailMaps.LoadCatalog(); thumbs.Clear(); }

        /// <summary>Ticks a map as its row's checkbox does: not one the project already holds. A harness drives these two calls.</summary>
        public bool Pick(string id)
        {
            var m = maps.FirstOrDefault(x => x.id == id);
            if (m == null || RetailMaps.Status(m) != "") return false;
            picked.Add(id);
            return true;
        }

        /// <summary>What the Extract button does: starts the chain on the ticked maps and clears the ticks; null when none is ticked.</summary>
        public ExtractionRun ExtractPicked()
        {
            var sel = maps.Where(m => picked.Contains(m.id)).ToList();
            if (sel.Count == 0) return null;
            var run = RetailExtraction.Start(sel);
            picked.Clear();
            return run;
        }

        void Poll()
        {
            if (scan != null && scan.Poll())
            {
                scanText = scan.Failed ? $"Scan failed: {scan.Error ?? scan.Tail()}" : "";
                scan = null;
                Reload();
                Repaint();
            }
            else if (scan != null) { scanText = "Scanning the retail install: " + scan.Tail(1); Repaint(); }
        }

        void StartScan()
        {
            var bad = RetailMaps.InstallProblem(RetailMaps.RetailInstall);
            if (bad != null) { scanText = bad; return; }
            var py = RetailMaps.FindPython();
            if (py == null) { scanText = "Python 3 with UnityPy and Pillow does not run here (py -3 -c \"import UnityPy, PIL\")."; return; }
            Directory.CreateDirectory(RetailMaps.CatalogDir);
            var log = Path.Combine(RetailMaps.CatalogDir, "scan.log");
            if (File.Exists(log)) File.Delete(log);
            scan = Job.Run(py.Value.exe, $"{py.Value.prefix}\"{RetailMaps.Setup("list_retail_maps.py")}\" \"{RetailMaps.RetailInstall}\" \"{RetailMaps.CatalogDir}\"", log);
        }

        string Folder(string label, string value, string title, bool file, out bool changed)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(label, GUILayout.Width(150));
            var v = EditorGUILayout.TextField(value);
            if (GUILayout.Button("Browse…", GUILayout.Width(70)))
            {
                var p = file ? EditorUtility.OpenFilePanel(title, string.IsNullOrEmpty(value) ? "" : Path.GetDirectoryName(value), "dll") : EditorUtility.OpenFolderPanel(title, value, "");
                if (!string.IsNullOrEmpty(p)) v = p.Replace('/', Path.DirectorySeparatorChar);
            }
            EditorGUILayout.EndHorizontal();
            changed = v != value;
            return v;
        }

        Texture2D Thumb(RetailMap m, out string source)
        {
            var path = RetailMaps.PreviewFile(m, out source);
            if (path == null) return null;
            if (!thumbs.TryGetValue(m.id, out var t) || t == null)
            {
                t = new Texture2D(2, 2) { hideFlags = HideFlags.HideAndDontSave };
                t.LoadImage(File.ReadAllBytes(path));
                thumbs[m.id] = t;
            }
            return t;
        }

        void OnGUI()
        {
            var run = RetailExtraction.Current;
            bool busy = run != null && run.running;
            using (new EditorGUI.DisabledScope(busy))
            {
                var install = Folder("Retail BATTLETECH folder", RetailMaps.RetailInstall, "Choose your retail BATTLETECH folder", false, out var c1);
                if (c1) RetailMaps.RetailInstall = install;
                var tool = Folder("Mapkit Asset Manager", RetailMaps.AssetManager, "Choose AssetRipper.CLI.dll of your Mapkit Asset Manager build", true, out var c2);
                if (c2) RetailMaps.AssetManager = tool;
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("Find my install")) { var f = RetailMaps.FindInstall(); if (f != null) RetailMaps.RetailInstall = f; else scanText = "No retail BATTLETECH install found in the usual Steam and GOG folders. Browse to it."; }
                if (GUILayout.Button(maps.Count == 0 ? "List the retail maps" : "Scan again", GUILayout.Width(140)) && scan == null) StartScan();
                GUILayout.FlexibleSpace();
                EditorGUILayout.EndHorizontal();
                var problem = RetailMaps.InstallProblem(RetailMaps.RetailInstall);
                if (problem != null) EditorGUILayout.HelpBox(problem, MessageType.Warning);
                if (!string.IsNullOrEmpty(tool) && !File.Exists(tool)) EditorGUILayout.HelpBox($"Mapkit Asset Manager is not at {tool}. Build it with setup/assetripper-patches/build.ps1 (see the README) and choose its AssetRipper.CLI.dll.", MessageType.Warning);
            }
            if (!string.IsNullOrEmpty(scanText)) EditorGUILayout.HelpBox(scanText, scan != null ? MessageType.Info : MessageType.Warning);

            if (maps.Count == 0)
            {
                EditorGUILayout.HelpBox("No map list yet. Choose your retail install and press \"List the retail maps\": the kit reads the game's own data (this takes about a minute) and nothing is extracted.", MessageType.Info);
                DrawRun(run);
                return;
            }

            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("Show", GUILayout.Width(40));
            filter = EditorGUILayout.TextField(filter);
            hideExtracted = EditorGUILayout.ToggleLeft("hide maps already in the project", hideExtracted, GUILayout.Width(220));
            EditorGUILayout.EndHorizontal();

            var shown = maps.Where(m => (filter.Length == 0 || m.name.IndexOf(filter, System.StringComparison.OrdinalIgnoreCase) >= 0 || m.id.IndexOf(filter, System.StringComparison.OrdinalIgnoreCase) >= 0
                || m.biome.IndexOf(filter, System.StringComparison.OrdinalIgnoreCase) >= 0) && !(hideExtracted && RetailMaps.Status(m) != "")).ToList();
            scroll = EditorGUILayout.BeginScrollView(scroll);
            using (new EditorGUI.DisabledScope(busy))
                foreach (var m in shown) Row(m);
            EditorGUILayout.EndScrollView();

            var sel = maps.Where(m => picked.Contains(m.id)).ToList();
            int withPreview = maps.Count(m => { RetailMaps.PreviewFile(m, out var s); return s != "none"; });
            int icons = maps.Count(m => { RetailMaps.PreviewFile(m, out var s); return s == "icon"; });
            EditorGUILayout.LabelField($"{maps.Count} maps in this install. Previews: {icons} with retail's own icon, {withPreview - icons} with the kit's overhead picture, {maps.Count - withPreview} not yet (a grey box).", EditorStyles.miniLabel);
            if (sel.Count > 0)
            {
                var peak = sel.Max(m => m.PeakDiskBytes);
                EditorGUILayout.LabelField($"{sel.Count} picked. One at a time: up to {RetailMaps.Gb(peak)} of disk at the peak (deleted after each map), the export takes {RetailMaps.Minutes(sel.Sum(m => m.ExportMinutes))} in all, and the project grows by about 1 to 3 GB a map. Free on this drive: {RetailMaps.Gb(RetailMaps.FreeBytes(RetailMaps.ProjectRoot))}.", EditorStyles.wordWrappedLabel);
            }
            using (new EditorGUI.DisabledScope(busy || sel.Count == 0))
                if (GUILayout.Button(sel.Count == 0 ? "Extract the picked maps" : $"Extract {sel.Count} map{(sel.Count == 1 ? "" : "s")}", GUILayout.Height(26)))
                    ExtractPicked();
            DrawRun(run);
        }

        void Row(RetailMap m)
        {
            EditorGUILayout.BeginHorizontal(GUI.skin.box);
            var status = RetailMaps.Status(m);
            using (new EditorGUI.DisabledScope(status != ""))
            {
                bool on = EditorGUILayout.Toggle(picked.Contains(m.id), GUILayout.Width(18));
                if (on) picked.Add(m.id); else picked.Remove(m.id);
            }
            var tex = Thumb(m, out var source);
            var box = GUILayoutUtility.GetRect(96, 54, GUILayout.Width(96), GUILayout.Height(54));
            if (tex != null) GUI.DrawTexture(box, tex, ScaleMode.ScaleToFit);
            else { EditorGUI.DrawRect(box, new Color(0.13f, 0.13f, 0.13f)); GUI.Label(box, "no preview yet", new GUIStyle(EditorStyles.centeredGreyMiniLabel) { wordWrap = true, normal = { textColor = new Color(0.7f, 0.7f, 0.7f) } }); }
            EditorGUILayout.BeginVertical(GUILayout.ExpandWidth(true));
            EditorGUILayout.LabelField(m.name, EditorStyles.boldLabel);
            EditorGUILayout.LabelField($"{m.id}   {m.biome}{(m.pack.Length > 0 ? "   " + m.pack + " DLC" : "")}", EditorStyles.miniLabel);
            EditorGUILayout.LabelField($"level file {RetailMaps.Size(m.levelBytes)}, {RetailMaps.Gb(m.inputBytes)} with the files it shares   preview: {(source == "icon" ? "retail icon" : source == "shipped" ? "kit picture" : "none yet")}", EditorStyles.miniLabel);
            if (status == "" && picked.Contains(m.id))
                EditorGUILayout.LabelField($"needs {RetailMaps.Gb(m.PeakDiskBytes)} at the peak, export {RetailMaps.Minutes(m.ExportMinutes)}", EditorStyles.miniLabel);
            EditorGUILayout.EndVertical();
            if (status != "") GUILayout.Label(status == "Extracted" ? "Extracted" : "In the project", EditorStyles.boldLabel, GUILayout.Width(100));
            EditorGUILayout.EndHorizontal();
        }

        static void DrawRun(ExtractionRun run)
        {
            if (run == null) return;
            if (run.failedStep != null)
                EditorGUILayout.HelpBox($"Stopped at {run.failedStep}: {run.error}", MessageType.Error);
            else if (run.running)
                EditorGUILayout.HelpBox($"Running ({run.mapIndex + 1} of {run.maps.Count}): {run.step}. Keep Unity open; it imports what was copied when the last map ends.", MessageType.Info);
            else if (run.Succeeded)
                EditorGUILayout.HelpBox(run.maps.Count == 1
                    ? $"Done: {run.maps[0].name} is in the project (Assets/Level Design/Maps)."
                    : $"Done: {run.maps.Count} maps are in the project (Assets/Level Design/Maps): {string.Join(", ", run.maps.Select(m => m.name))}.", MessageType.Info);
            foreach (var l in run.lines.Skip(System.Math.Max(0, run.lines.Count - 6))) EditorGUILayout.LabelField(l, EditorStyles.miniLabel);
        }
    }
}
