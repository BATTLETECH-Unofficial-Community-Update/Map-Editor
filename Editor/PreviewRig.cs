// UCU Map Kit: Game-view preview. Runs HBS's own edit-mode render setup on the open map:
// the player's camera (Resources/Internal/GameCamera) with HBS's camera components, the map's own MoodController and
// TerrainMaterialSetup. Call list: .hermes/reports/map-kit-p1-20261120/setup-calls.md §4.2 (steps 1, 3, 4, 5, 6/6b, 7, 8,
// 10-12, 15); steps 13 (HBS vegetation) and 14 (TerrainTextures) are not safe in edit mode and are not run.
// Nothing the rig adds is saved: every object it creates is HideFlags.DontSave and is destroyed on Close, on a scene
// change and before a domain reload. HBS's mood code also writes the open scene in memory without dirtying it (sun,
// probe and weather objects under the MoodController, its current mood, terrain distances, RenderSettings), so the
// preview opens only on a saved scene with no unsaved edits, and Close reopens that scene from disk. EditorJsonUtility
// is not a safe snapshot: on 6000.6 it writes every object reference as instanceID 0, so a write-back nulls them.
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using BattleTech.Data;
using BattleTech.Rendering;
using BattleTech.Rendering.Mood;
using HBS.Collections;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace UCU.MapKit
{
    [Serializable]
    public struct PreviewPose
    {
        public Vector3 position;
        public Vector3 euler;
        public float fov;

        // Reads a LoadProbe "CAMPTS <tag> pose pos=(x,y,z) euler=(p,y,r) ... fov=f" line (tools/build-probe/LoadProbe/CamPoints.cs).
        public static bool TryParse(string line, out PreviewPose pose)
        {
            pose = default;
            var pos = Regex.Match(line ?? "", @"pos=\(([^)]*)\)");
            var eul = Regex.Match(line ?? "", @"euler=\(([^)]*)\)");
            var fov = Regex.Match(line ?? "", @"fov=([-\d.]+)");
            if (!pos.Success || !eul.Success || !fov.Success) return false;
            pose = new PreviewPose { position = V3(pos.Groups[1].Value), euler = V3(eul.Groups[1].Value), fov = float.Parse(fov.Groups[1].Value, CultureInfo.InvariantCulture) };
            return true;
        }

        static Vector3 V3(string s)
        {
            var p = s.Split(',').Select(x => float.Parse(x.Trim(), CultureInfo.InvariantCulture)).ToArray();
            return new Vector3(p[0], p[1], p[2]);
        }
    }

    [InitializeOnLoad]
    public static class PreviewRig
    {
        const string CameraPrefab = "Internal/GameCamera";
        const string RigName = "UCU Map Kit Preview (not saved)";
        // Camera-prefab components that are input, audio, screenshots or HBS vegetation (§4.2 step 13): off in the preview.
        static readonly HashSet<string> Disabled = new HashSet<string> { "CameraControl", "DebugFlyCameraControl", "PhysicsRaycaster", "CameraShake", "AkAudioListener", "BTScreenShot", "RenderTrees" };
        const BindingFlags Priv = BindingFlags.Instance | BindingFlags.NonPublic;

        static GameObject rig;
        static Camera camera;
        static string scenePath;
        static bool reopening;
        const string PendingReopen = "UCU.MapKit.Preview.ReopenScene";

        public static bool IsOpen => rig != null;
        public static Camera Camera => camera;
        /// <summary>"compute" when the player's compute shaders were injected (§4.2 step 6); "legacy" for the 6b fallback.</summary>
        public static string LightingPath { get; private set; }

        static PreviewRig()
        {
            // A domain reload drops the managed references but not DontSave objects: remove any left from before it.
            foreach (var go in Resources.FindObjectsOfTypeAll<GameObject>().Where(g => g.name == RigName && g.hideFlags.HasFlag(HideFlags.DontSave)))
                UnityEngine.Object.DestroyImmediate(go);
            // A domain reload or entering Play cannot reopen a scene there and then: the reopen waits for edit mode.
            AssemblyReloadEvents.beforeAssemblyReload += () => Close(defer: true);
            EditorApplication.playModeStateChanged += s =>
            {
                if (s == PlayModeStateChange.ExitingEditMode) Close(defer: true);
                else if (s == PlayModeStateChange.EnteredEditMode) EditorApplication.delayCall += ReopenPending;
            };
            // The scene is going away: nothing of it is kept, so there is nothing to reopen.
            EditorSceneManager.sceneClosing += (s, removing) => { if (!reopening) Close(reopen: false); };
            EditorSceneManager.activeSceneChangedInEditMode += (a, b) => { if (!reopening) Close(); };
            if (!EditorApplication.isPlayingOrWillChangePlaymode) EditorApplication.delayCall += ReopenPending;
            EditorApplication.update += PrebakeTerrain;
        }

        [MenuItem("UCU Map Kit/Preview/Open Game-View Preview")]
        static void OpenMenu() => EditorWindow.GetWindow<PreviewWindow>(false, "Map Preview");

        [MenuItem("UCU Map Kit/Preview/Close Preview")]
        static void CloseMenu() => Close();

        /// <summary>Supported moods of the open map's biome, from the MetadataDatabase (Mood rows for the biome's required tags).</summary>
        public static string[] SupportedMoods()
        {
            var generator = Terrain.activeTerrain ? Terrain.activeTerrain.GetComponent<TerrainGenerator>() : null;
            if (generator == null || generator.biome == null) return new string[0];
            return MetadataDatabase.Instance.GetSupportedMoodsForBiome(generator.biome.biomeSkin, new TagSet()).Select(m => m.Name).OrderBy(n => n, StringComparer.Ordinal).ToArray();
        }

        public static void Open(string moodName, PreviewPose pose)
        {
            Close();
            var scene = EditorSceneManager.GetActiveScene();
            if (EditorSceneManager.sceneCount != 1 || string.IsNullOrEmpty(scene.path) || scene.isDirty)
                throw new InvalidOperationException("Save the scene, with no other scene open, before opening the preview: Close reopens it from disk.");
            var terrain = Terrain.activeTerrain ?? throw new InvalidOperationException("The open scene has no active terrain.");
            var generator = terrain.GetComponent<TerrainGenerator>();
            // §4.2 step 1: TerrainMaterialSetup.OnEnable dereferences the biome (TerrainMaterialSetup.cs:861). Assigning it would
            // change the scene, so the preview refuses instead.
            if (generator == null || generator.biome == null)
                throw new InvalidOperationException("The terrain needs a TerrainGenerator with a biome.");
            var mood = UnityEngine.Object.FindAnyObjectByType<MoodController>()
                ?? throw new InvalidOperationException("The map has no MoodController (§4.2 step 9 creates one, which would change the scene).");
            var prefab = Resources.Load<GameObject>(CameraPrefab) ?? throw new InvalidOperationException($"Resources/{CameraPrefab} is not in this project.");

            scenePath = scene.path;

            // §4.2 step 3: re-push HBS's terrain material and globals (no GI update).
            terrain.GetComponent<TerrainMaterialSetup>()?.UpdateMaterial(false);

            // §4.2 step 4: the player's camera, built under an inactive holder so nothing enables before it is set up.
            rig = EditorUtility.CreateGameObjectWithHideFlags(RigName, HideFlags.DontSave);
            rig.SetActive(false);
            var cam = UnityEngine.Object.Instantiate(prefab, rig.transform);
            foreach (var t in rig.GetComponentsInChildren<Transform>(true))
            {
                t.gameObject.hideFlags = HideFlags.DontSave;
                foreach (var c in t.GetComponents<Component>().Where(c => c != null)) c.hideFlags = HideFlags.DontSave;
            }
            foreach (var b in cam.GetComponentsInChildren<Behaviour>(true).Where(b => Disabled.Contains(b.GetType().Name)))
                b.enabled = false;
            camera = cam.GetComponentsInChildren<Camera>(true).First(c => c.CompareTag("MainCamera"));

            // §4.2 step 6, with 6b only as the reported fallback.
            var renderer = camera.GetComponent<BTCustomRenderer>();
            var fog = camera.GetComponent<FogScattering>();
            LightingPath = InjectCompute(renderer, fog) ? "compute" : "legacy";
            if (LightingPath == "legacy")
            {
                renderer.useClusteredEditor = false;
                fog.useComputeShader = false;
                Debug.LogWarning("UCU Map Kit preview: the player's compute shaders are not in this project; lights and fog use HBS's legacy/2D path (approximate).");
            }

            SetPose(pose);
            rig.SetActive(true);
            // §4.2 step 7: BTCustomRenderer sets UIMSAA back to 4 in its first OnPreCull; 2 keeps BTPostProcess off the
            // UI render texture, which is null outside Play (BTPostProcess.cs:1212-1217).
            Camera.onPreRender += KeepUiMsaa;
            // §4.2 steps 8 and 10: the map's own MoodController applies the mood to the camera stack.
            SetMood(moodName);
        }

        public static void SetMood(string moodName)
        {
            if (!IsOpen) return;
            var mood = UnityEngine.Object.FindAnyObjectByType<MoodController>();
            mood.SetMoodByName(moodName);
            // In edit mode ApplyMood only arms a countdown (MoodController.cs:465-468); its own Update runs RefreshGI
            // (DynamicGI.UpdateEnvironment, SetSHCoefficients, RefreshReflection) about 11 Editor ticks later
            // (MoodController.cs:963-979), and a background Editor may not tick. Run HBS's RefreshGI now.
            mood.RefreshGI();
            PrebakeTerrain();
            if (mood.currentMood == null || mood.currentMood.name != moodName)
                throw new InvalidOperationException($"Mood [{moodName}] is not in Resources/Moods.");
            SceneView.RepaintAll();
        }

        public static void SetPose(PreviewPose pose)
        {
            if (camera == null) return;
            camera.transform.SetPositionAndRotation(pose.position, Quaternion.Euler(pose.euler));
            if (pose.fov > 0f) camera.fieldOfView = pose.fov;
        }

        /// <summary>A pose looking at the open map's terrain centre from above, for a first look.</summary>
        public static PreviewPose DefaultPose()
        {
            var t = Terrain.activeTerrain;
            var c = t ? t.transform.position + t.terrainData.size / 2f : Vector3.zero;
            return new PreviewPose { position = new Vector3(c.x, (t ? t.SampleHeight(c) : 0f) + 400f, c.z - 400f), euler = new Vector3(45f, 0f, 0f), fov = 35f };
        }

        public static void Close() => Close(reopen: true);

        static void Close(bool reopen = true, bool defer = false)
        {
            Camera.onPreRender -= KeepUiMsaa;
            if (rig != null) UnityEngine.Object.DestroyImmediate(rig);
            rig = null;
            camera = null;
            var path = scenePath;
            scenePath = null;
            if (path == null || !reopen) return;
            if (defer) SessionState.SetString(PendingReopen, path);
            else Reopen(path);
        }

        static void ReopenPending()
        {
            var path = SessionState.GetString(PendingReopen, "");
            SessionState.EraseString(PendingReopen);
            if (path != "") Reopen(path);
        }

        // Discards what HBS wrote to the scene in memory. A scene that was edited meanwhile is left alone, with a warning.
        static void Reopen(string path)
        {
            var scene = EditorSceneManager.GetSceneByPath(path);
            if (!scene.IsValid() || !scene.isLoaded) return;
            if (scene.isDirty)
            {
                Debug.LogWarning($"UCU Map Kit preview: {path} was edited while the preview was open; it was not reopened, so it still holds the preview's mood. Reopen it without saving to discard that.");
                return;
            }
            reopening = true;
            try { EditorSceneManager.OpenScene(path, OpenSceneMode.Single); }
            finally { reopening = false; }
        }

        // The far terrain pass reads _BT_TerrainHeight/Albedo/Normal (and _BT_TerrainAmbient), which
        // EnvironmentOverlays.OnPreRender renders with a nested terrainCamera.Render() when heightDirty/ambientDirty is set
        // (EnvironmentOverlays.cs:331-347). Unity 6 rejects a render nested in another camera's OnPreRender ("Unable to add
        // Renderer to the Scene after Culling") and the textures stay black. HBS's own OnPreRender is run here instead, from
        // EditorApplication.update and right after Open/SetMood, outside any camera render; the in-render call then finds
        // nothing dirty and only sets the globals. Covers the preview camera and the Scene view's copy of the component.
        static bool prebakeTerrain = true; // a control leg turns it off by reflection
        static readonly FieldInfo HeightDirty = typeof(EnvironmentOverlays).GetField("heightDirty", Priv);
        static readonly MethodInfo OverlaysPreRender = typeof(EnvironmentOverlays).GetMethod("OnPreRender", Priv);

        static void PrebakeTerrain()
        {
            if (!prebakeTerrain || camera == null || Terrain.activeTerrain == null) return;
            foreach (var c in SceneView.sceneViews.Cast<SceneView>().Select(v => v.camera).Append(camera))
            {
                var eo = c ? c.GetComponent<EnvironmentOverlays>() : null;
                if (eo != null && eo.isActiveAndEnabled && ((bool)HeightDirty.GetValue(eo) || eo.ambientDirty))
                    OverlaysPreRender.Invoke(eo, null);
            }
        }

        static void KeepUiMsaa(Camera c)
        {
            if (c == camera) BTCustomRenderer.UIMSAA = 2;
        }

        // The player's DataManager supplies these at runtime (BTCustomRenderer.cs:768-794, FogScattering.cs:447-467);
        // the recovered sources are loaded from the project instead.
        static bool InjectCompute(BTCustomRenderer renderer, FogScattering fog)
        {
            var cluster = FindCompute("ClusteredLighting");
            var tile = FindCompute("MaterialIDTile");
            var integration = FindCompute("VolumetricIntegration");
            if (cluster == null || tile == null || integration == null) return false;
            Set(renderer, "_clusterCompute", cluster);
            Set(renderer, "clusterKernel", cluster.FindKernel("LightClusters"));
            Set(renderer, "depthKernel", cluster.FindKernel("DepthDownsample"));
            Set(renderer, "_tileIDCompute", tile);
            Set(renderer, "idKernel", tile.FindKernel("MatIDTile"));
            Set(renderer, "combatIDKernel", tile.FindKernel("MatIDTileCombat"));
            Set(fog, "_integrationShader", integration);
            Set(fog, "_kernel", integration.FindKernel("LightIntegration"));
            return true;
        }

        static ComputeShader FindCompute(string name) => AssetDatabase.FindAssets($"{name} t:ComputeShader")
            .Select(g => AssetDatabase.LoadAssetAtPath<ComputeShader>(AssetDatabase.GUIDToAssetPath(g))).FirstOrDefault(c => c != null && c.name == name);

        static void Set(object target, string field, object value)
        {
            var f = target.GetType().GetField(field, Priv) ?? throw new MissingFieldException(target.GetType().Name, field);
            f.SetValue(target, value);
        }
    }
}
