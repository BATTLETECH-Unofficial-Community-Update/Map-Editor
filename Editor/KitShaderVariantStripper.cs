// UCU Map Kit: keeps only the keyword sets retail shipped for the kit's recovered HBS shaders when Build Mod builds a map bundle.
// The recovered shaders declare every retail keyword with multi_compile, so a bundle compiles the whole keyword product without it:
// BattleTech Standard's deferred pass is 331,776 variants (110,592 after Unity's own stripping) per program and graphics API, and a
// map with library buildings did not finish in 3.5 hours (map-kit U8). Retail's urbanwarfare bundle embeds the same shader with 8,640
// deferred sub-programs. This is UCU's Project/Assets/Editor/RetailShaderVariantStripper.cs (the same rule, comparison and refusal
// to empty a pass) pointed at the kit's shader folder and at Shaders/retail-shader-variants.tsv, the rows of UCU's
// tools/shader-recovery/retail-shader-variants.tsv for the kit's shaders (written by setup/install_shaders.py).
using System;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEditor.Build;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

namespace UCU.MapKit
{
    public sealed class KitShaderVariantStripper : IPreprocessShaders
    {
        const string PackageRoot = "Packages/com.ucu.mapkit";
        const string RecoveredRoot = PackageRoot + "/Shaders/Resources/hbs-shaders/";
        const string LogTag = "[KitVariants]";

        static Dictionary<string, List<string[]>> table;

        public int callbackOrder => 0;

        public void OnProcessShader(Shader shader, ShaderSnippetData snippet, IList<ShaderCompilerData> data)
        {
            if (data.Count == 0 || !AssetDatabase.GetAssetPath(shader).StartsWith(RecoveredRoot, StringComparison.Ordinal))
                return;
            string passKey = PassKey(shader.name, (int)snippet.pass.SubshaderIndex, (int)snippet.pass.PassIndex);
            if (!LoadTable().TryGetValue(passKey, out var retailSets))
                return;

            var variants = new string[data.Count][];
            var declared = new HashSet<string>(StringComparer.Ordinal);
            for (int i = 0; i < variants.Length; i++)
            {
                var keywords = data[i].shaderKeywordSet.GetShaderKeywords();
                var names = new string[keywords.Length];
                for (int k = 0; k < names.Length; k++) names[k] = keywords[k].name;
                variants[i] = names;
                declared.UnionWith(names);
            }
            // only keywords both sides know: a keyword the recovered shader added multiplies the kept sets instead of removing them
            var retailKeywords = new HashSet<string>(StringComparer.Ordinal);
            foreach (var set in retailSets) retailKeywords.UnionWith(set);
            declared.IntersectWith(retailKeywords);
            var allowed = new HashSet<string>(StringComparer.Ordinal);
            foreach (var set in retailSets) allowed.Add(SetKey(set, declared));

            int total = data.Count, kept = 0;
            for (int i = 0; i < total; i++)
            {
                if (!allowed.Contains(SetKey(variants[i], declared))) continue;
                if (kept != i) data[kept] = data[i];
                kept++;
            }
            if (kept == 0)
            {
                // a table that fits nothing must not empty a pass
                Debug.LogError($"{LogTag} {passKey} {snippet.shaderType}: no variant matches retail; keeping all {total}");
                return;
            }
            for (int i = total - 1; i >= kept; i--) data.RemoveAt(i);
            Debug.Log($"{LogTag} {passKey} {snippet.shaderType}: kept {kept} of {total}, retail {retailSets.Count}");
        }

        static Dictionary<string, List<string[]>> LoadTable()
        {
            if (table != null) return table;
            table = new Dictionary<string, List<string[]>>(StringComparer.Ordinal);
            var info = UnityEditor.PackageManager.PackageInfo.FindForAssetPath(PackageRoot);
            var path = info == null ? null : Path.Combine(info.resolvedPath, "Shaders", "retail-shader-variants.tsv");
            if (path == null || !File.Exists(path))
            {
                Debug.LogError($"{LogTag} no table at {path ?? PackageRoot + "/Shaders/retail-shader-variants.tsv"}: the kit's shaders build unstripped");
                return table;
            }
            foreach (var line in File.ReadLines(path))
            {
                var c = line.Split('\t');
                var key = PassKey(c[0], int.Parse(c[1]), int.Parse(c[2]));
                if (!table.TryGetValue(key, out var sets)) table[key] = sets = new List<string[]>();
                sets.Add(c[3].Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries));
            }
            return table;
        }

        static string PassKey(string shaderName, int subshader, int pass) => $"{shaderName}|{subshader}|{pass}";

        static string SetKey(string[] keywords, HashSet<string> shared)
        {
            var names = new List<string>(keywords.Length);
            foreach (var k in keywords) if (shared.Contains(k)) names.Add(k);
            names.Sort(StringComparer.Ordinal);
            return string.Join(" ", names);
        }
    }
}
