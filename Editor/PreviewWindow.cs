// UCU Map Kit: the preview's window. Mood dropdown from the map's supported moods; pose fields that take a pasted
// LoadProbe "CAMPTS ... pose ..." line; Open, Close, and a PNG capture of the preview camera.
using System;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace UCU.MapKit
{
    public class PreviewWindow : EditorWindow
    {
        string[] moods = new string[0];
        int moodIndex;
        PreviewPose pose;
        string pasted = "";
        string status = "";

        void OnEnable()
        {
            minSize = new Vector2(420, 260);
            Refresh();
            pose = PreviewRig.DefaultPose();
        }

        void Refresh()
        {
            try { moods = PreviewRig.SupportedMoods(); status = moods.Length == 0 ? "No supported moods: the terrain needs a TerrainGenerator with a biome." : ""; }
            catch (Exception e) { moods = new string[0]; status = e.Message; }
            moodIndex = Mathf.Clamp(moodIndex, 0, Math.Max(0, moods.Length - 1));
        }

        void OnGUI()
        {
            EditorGUIUtility.labelWidth = 120;
            using (new EditorGUILayout.HorizontalScope())
            {
                var next = EditorGUILayout.Popup("Mood", moodIndex, moods);
                if (GUILayout.Button("Reload", GUILayout.Width(60))) Refresh();
                if (next != moodIndex && moods.Length > 0)
                {
                    moodIndex = next;
                    Try(() => PreviewRig.SetMood(moods[moodIndex]));
                }
            }

            EditorGUILayout.Space();
            EditorGUI.BeginChangeCheck();
            pose.position = EditorGUILayout.Vector3Field("Position", pose.position);
            pose.euler = EditorGUILayout.Vector3Field("Euler", pose.euler);
            pose.fov = EditorGUILayout.FloatField("FOV", pose.fov);
            if (EditorGUI.EndChangeCheck()) PreviewRig.SetPose(pose);
            using (new EditorGUILayout.HorizontalScope())
            {
                pasted = EditorGUILayout.TextField("CAMPTS pose", pasted);
                if (GUILayout.Button("Apply", GUILayout.Width(60)))
                {
                    if (PreviewPose.TryParse(pasted, out var p)) { pose = p; PreviewRig.SetPose(pose); status = ""; }
                    else status = "Not a CAMPTS pose line: it needs pos=(x,y,z) euler=(p,y,r) fov=f.";
                }
            }

            EditorGUILayout.Space();
            using (new EditorGUILayout.HorizontalScope())
            {
                GUI.enabled = moods.Length > 0;
                if (GUILayout.Button(PreviewRig.IsOpen ? "Reopen" : "Open")) Try(() => PreviewRig.Open(moods[moodIndex], pose));
                GUI.enabled = PreviewRig.IsOpen;
                if (GUILayout.Button("Close")) PreviewRig.Close();
                if (GUILayout.Button("Save PNG…"))
                {
                    var path = EditorUtility.SaveFilePanel("Save preview", "", "preview.png", "png");
                    if (!string.IsNullOrEmpty(path)) Try(() => Capture(path, 1920, 1080));
                }
                GUI.enabled = true;
            }
            if (PreviewRig.IsOpen) EditorGUILayout.LabelField("Lighting path", PreviewRig.LightingPath);
            if (!string.IsNullOrEmpty(status)) EditorGUILayout.HelpBox(status, MessageType.Warning);
            EditorGUILayout.HelpBox("The preview camera renders to the Game view. Not shown: HBS vegetation, TerrainTextures, " +
                "weather effects, UI, TAA.", MessageType.Info);
        }

        void Try(Action a)
        {
            try { a(); status = ""; }
            catch (Exception e) { status = e.Message; Debug.LogException(e); }
        }

        /// <summary>Renders the preview camera into a width x height sRGB target and writes it as a PNG (a check copy; the Game view is the preview).</summary>
        public static void Capture(string path, int width, int height)
        {
            var cam = PreviewRig.Camera ?? throw new InvalidOperationException("The preview is not open.");
            var rt = RenderTexture.GetTemporary(width, height, 24, RenderTextureFormat.ARGB32, RenderTextureReadWrite.sRGB);
            var before = cam.targetTexture;
            var active = RenderTexture.active;
            try
            {
                cam.targetTexture = rt;
                // The Game view renders this camera at its own size between captures, and the camera's previous-frame
                // matrices advance once per Editor frame, not per Render: DefaultPostProcessing's motion blur (shutter 30)
                // then reads the size change as motion and smears a radial blur (map-kit-preview-20261120: four renders
                // in one call stayed blurred). Re-enabling the camera clears that history, as a still frame should be.
                cam.enabled = false;
                cam.enabled = true;
                cam.Render();
                RenderTexture.active = rt;
                var tex = new Texture2D(width, height, TextureFormat.RGB24, false);
                tex.ReadPixels(new Rect(0, 0, width, height), 0, 0);
                tex.Apply();
                File.WriteAllBytes(path, tex.EncodeToPNG());
                DestroyImmediate(tex);
            }
            finally
            {
                cam.targetTexture = before;
                RenderTexture.active = active;
                RenderTexture.ReleaseTemporary(rt);
            }
        }
    }
}
