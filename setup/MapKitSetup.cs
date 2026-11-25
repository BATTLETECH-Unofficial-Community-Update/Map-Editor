#if MAPKIT_SETUP
// UCU Map Kit setup: the project settings the game code and a map scene need, set through the Editor API.
// Not compiled inside the package (the #if above): setup-project.ps1 stages a copy with `#define MAPKIT_SETUP` into the new project's
// Assets, runs it once in batch mode (-executeMethod MapKitSetup.ApplySettings) before the game code and the kit are added (the kit's
// Editor scripts only compile once the game code is there), then deletes the copy. The settings stay in ProjectSettings.
using System;
using System.IO;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEngine;
using UnityEngine.Rendering;

public static class MapKitSetup
{
    public static void ApplySettings()
    {
        PlayerSettings.colorSpace = ColorSpace.Linear;
        PlayerSettings.allowUnsafeCode = true; // firstpass SVGImporter.Native uses unsafe (UCU: allowUnsafeCode 1)
        PlayerSettings.SetApiCompatibilityLevel(UnityEditor.Build.NamedBuildTarget.Standalone, ApiCompatibilityLevel.NET_Unity_4_8);
        foreach (GraphicsTier tier in new[] { GraphicsTier.Tier1, GraphicsTier.Tier2, GraphicsTier.Tier3 })
        {
            var s = EditorGraphicsSettings.GetTierSettings(BuildTargetGroup.Standalone, tier);
            s.renderingPath = RenderingPath.DeferredShading;
            EditorGraphicsSettings.SetTierSettings(BuildTargetGroup.Standalone, tier, s);
        }
        // D3D12 first, D3D11 second. The Editor starts on the first API in this list.
        PlayerSettings.SetUseDefaultGraphicsAPIs(BuildTarget.StandaloneWindows64, false);
        PlayerSettings.SetGraphicsAPIs(BuildTarget.StandaloneWindows64, new[] { GraphicsDeviceType.Direct3D12, GraphicsDeviceType.Direct3D11 });
        var args = Environment.GetCommandLineArgs();
        // The project's name (-mapkitName, default: the project folder's name, or its parent's when the folder is called
        // Project) and company (-mapkitCompany). Unity Hub titles a project from ProjectSettings/ProjectName.txt before
        // productName (which it shows only when its "Default project name" preference says product name) and the folder name.
        var dir = new DirectoryInfo(Directory.GetCurrentDirectory());
        var name = Arg(args, "-mapkitName") ?? (dir.Name == "Project" && dir.Parent != null ? dir.Parent.Name : dir.Name);
        PlayerSettings.productName = name;
        PlayerSettings.companyName = Arg(args, "-mapkitCompany") ?? "UCU Map Kit";
        File.WriteAllText(Path.Combine("ProjectSettings", "ProjectName.txt"), name);
        // The retail install, when setup is given one (-mapkitRetail <folder>): the Extract Retail Maps window's folder
        // (RetailMaps.RetailPref, a per-machine EditorPrefs value, never in the project).
        var retail = Arg(args, "-mapkitRetail");
        if (retail != null)
            EditorPrefs.SetString("UCU.MapKit.RetailInstall", retail);
        AssetDatabase.SaveAssets();
        Debug.Log($"MAPKIT_SETUP colorSpace={PlayerSettings.colorSpace} api={PlayerSettings.GetApiCompatibilityLevel(UnityEditor.Build.NamedBuildTarget.Standalone)} " +
                  $"unsafe={PlayerSettings.allowUnsafeCode} tier1={EditorGraphicsSettings.GetTierSettings(BuildTargetGroup.Standalone, GraphicsTier.Tier1).renderingPath} " +
                  $"defaultApis={PlayerSettings.GetUseDefaultGraphicsAPIs(BuildTarget.StandaloneWindows64)} " +
                  $"apis={string.Join(",", PlayerSettings.GetGraphicsAPIs(BuildTarget.StandaloneWindows64))} " +
                  $"retail={EditorPrefs.GetString("UCU.MapKit.RetailInstall", "")} " +
                  $"product={PlayerSettings.productName} company={PlayerSettings.companyName} " +
                  $"hubName={File.ReadAllText(Path.Combine("ProjectSettings", "ProjectName.txt"))}");
    }

    static string Arg(string[] args, string key)
    {
        var i = Array.IndexOf(args, key);
        return i >= 0 && i + 1 < args.Length && args[i + 1].Trim().Length > 0 ? args[i + 1] : null;
    }
}
#endif
