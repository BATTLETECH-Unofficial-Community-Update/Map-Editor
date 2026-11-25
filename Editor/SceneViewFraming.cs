// UCU Map Kit: a Scene view that shows the map when a kit map opens (map-kit KFIX9 S2).
// The fault: a map is open but the Scene view is black. Measured in the Editor on Direct3D12, two causes, one change each:
// - The view keeps its old position when a map opens. The default pivot (0,0,0) is the middle of the terrain's footprint, but the
//   ground there is 190 m up on the template map, so the camera sits inside the hill and sees nothing.
// - HBS's MoodController puts a 4,500 m sphere (Unlit/BT-ReflectionFog, layer "Reflector") around every map for the reflection probe.
//   The game's camera does not draw that layer; the Scene view does, and from outside the sphere (a view zoomed out past about 700 m) it
//   covers the map as a black disc. With the layer hidden in the Scene view the same views draw the terrain (template and extracted map).
// So when a kit map opens (or is created, which opens it), this hides the Reflector layer in the Scene view, and, when the view is not on
// the map (pivot outside the terrain's footprint, below its surface, or the camera under it), frames the active layer's player lance, or
// the terrain's centre when the layer has none. A view already on the map is left alone. Nothing is selected, dirtied or put on the Undo
// stack; batch mode and scenes without an EncounterLayerParent are not touched. Tools.visibleLayers is the Layers menu of the Scene
// view: the modder can turn Reflector back on there.
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace UCU.MapKit
{
    [InitializeOnLoad]
    static class SceneViewFraming
    {
        const string StartKey = "UCU.MapKit.FramedAtStart";
        const int MaxWaitTicks = 600;
        static int ticks;
        static bool waiting;

        static SceneViewFraming()
        {
            if (Application.isBatchMode || AssetDatabase.IsAssetImportWorkerProcess()) return;
            EditorSceneManager.sceneOpened += (s, mode) => { if (mode == OpenSceneMode.Single) Queue(); };
            // The scene the Editor starts with, once per Editor session (a recompile must not pull a view the modder moved back to the map).
            if (!SessionState.GetBool(StartKey, false)) { SessionState.SetBool(StartKey, true); Queue(); }
        }

        static void Queue()
        {
            ticks = 0;
            if (waiting) return;
            waiting = true;
            EditorApplication.update += Tick;
        }

        // The Scene view and the opened scene's objects are there a few Editor updates after the event.
        static void Tick()
        {
            if (EditorApplication.isPlayingOrWillChangePlaymode || EditorApplication.isCompiling || EditorApplication.isUpdating) { if (++ticks > MaxWaitTicks) Done(); return; }
            var sv = SceneView.lastActiveSceneView;
            if (sv == null || EncounterEdit.Parent() == null) { if (++ticks > 60) Done(); return; }
            Done();
            HideReflector();
            FrameIfOffMap(sv);
        }

        static void Done() { waiting = false; EditorApplication.update -= Tick; }

        static void HideReflector()
        {
            int layer = LayerMask.NameToLayer("Reflector");
            if (layer >= 0 && (Tools.visibleLayers & (1 << layer)) != 0) Tools.visibleLayers &= ~(1 << layer);
        }

        static bool Inside(Terrain t, Vector3 p)
        {
            var o = t.transform.position; var s = t.terrainData.size;
            return p.x >= o.x && p.x <= o.x + s.x && p.z >= o.z && p.z <= o.z + s.z;
        }

        static float Ground(Terrain t, Vector3 p) => t.SampleHeight(p) + t.transform.position.y;

        static bool OnMap(SceneView sv, Terrain t)
        {
            var camera = sv.pivot - sv.rotation * Vector3.forward * sv.cameraDistance;
            return Inside(t, sv.pivot) && sv.pivot.y >= Ground(t, sv.pivot) - 1f && (!Inside(t, camera) || camera.y >= Ground(t, camera) - 1f);
        }

        static void FrameIfOffMap(SceneView sv)
        {
            var t = Terrain.activeTerrain;
            if (t == null || OnMap(sv, t)) return;
            var layer = EncounterEdit.ActiveLayer(EncounterEdit.Parent());
            var spawners = layer == null ? new PlayerLanceSpawnerGameLogic[0] : layer.GetComponentsInChildren<PlayerLanceSpawnerGameLogic>(true);
            var lance = spawners.FirstOrDefault(p => p.encounterObjectGuid == PlayerLanceSpawnerGameLogic.Player1LanceSpawnerGuid) ?? spawners.FirstOrDefault();
            Bounds b;
            if (lance != null)
            {
                b = new Bounds(lance.transform.position, Vector3.zero);
                foreach (var c in lance.GetComponentsInChildren<Transform>()) b.Encapsulate(c.position);
                b.Expand(new Vector3(80f, 20f, 80f));
            }
            else
            {
                var o = t.transform.position; var s = t.terrainData.size;
                var centre = new Vector3(o.x + s.x * 0.5f, 0f, o.z + s.z * 0.5f);
                centre.y = Ground(t, centre);
                b = new Bounds(centre, new Vector3(200f, 40f, 200f));
            }
            sv.Frame(b, true);
        }
    }
}
