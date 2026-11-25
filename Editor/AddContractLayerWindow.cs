// UCU Map Kit: "Add Contract Layer…" (map-kit plan U9; design-v2 row 12). Pick a contract type, then the extracted retail map
// whose layer of that type to copy; Add layer copies it into the open map (ContractLayers.Add: one Undo step) and runs Map Check.
// A type no extracted map has says which step gives it one. The window holds no map state.
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;

namespace UCU.MapKit
{
    public class AddContractLayerWindow : EditorWindow
    {
        List<ContractLayerSource> index;
        string[] typeNames = new string[0];
        [SerializeField] int typeIndex;
        [SerializeField] int sourceIndex;
        string status = "";
        Vector2 scroll;

        public string Status => status;

        [MenuItem("UCU Map Kit/Add Contract Layer…")]
        static void OpenMenu() => Open();

        public static AddContractLayerWindow Open()
        {
            var w = GetWindow<AddContractLayerWindow>(true, "Add Contract Layer");
            w.minSize = new Vector2(460f, 260f);
            w.Load(false);
            return w;
        }

        public void Load(bool rebuild)
        {
            try
            {
                index = ContractLayers.Index(rebuild, (map, f) => EditorUtility.DisplayProgressBar("Add Contract Layer", $"Reading the encounter layers of {map}", f));
            }
            finally { EditorUtility.ClearProgressBar(); }
            typeNames = ContractLayers.SupportedTypes().Select(t => t.Name).ToArray();
            typeIndex = Mathf.Clamp(typeIndex, 0, Mathf.Max(0, typeNames.Length - 1));
            int maps = index.Select(s => s.map).Distinct().Count();
            status = $"{index.Count(s => s.supported)} layers of {typeNames.Length} contract types in {maps} extracted maps.";
        }

        public List<ContractLayerSource> SourcesOf(string type) => (index ?? new List<ContractLayerSource>()).Where(s => s.supported && s.typeName == type)
            .OrderBy(s => s.map, System.StringComparer.OrdinalIgnoreCase).ThenBy(s => s.layerName, System.StringComparer.Ordinal).ToList();

        public void Select(string type, string map)
        {
            typeIndex = System.Array.IndexOf(typeNames, type);
            sourceIndex = SourcesOf(type).FindIndex(s => s.map == map);
        }

        void OnGUI()
        {
            if (index == null) Load(false);
            scroll = EditorGUILayout.BeginScrollView(scroll);
            EditorGUILayout.LabelField("Copy an encounter layer of another contract type from a retail map extracted on this machine into the open map. " +
                "Its objects keep the GUIDs the game's contracts use; the layer is moved to this map's play area and snapped to the hex grid and the ground. " +
                "Links to the source map's buildings are cleared and listed in Map Check.", EditorStyles.wordWrappedLabel);
            EditorGUILayout.Space();
            var labels = typeNames.Select(t => { int n = SourcesOf(t).Count; return n == 0 ? $"{t} (no extracted map has one)" : $"{t} ({n})"; }).ToArray();
            typeIndex = EditorGUILayout.Popup(new GUIContent("Contract type", "HBS's single-player contract types and Skirmish (ArenaSkirmish); the number is how many extracted maps have a layer of it."), typeIndex, labels.Select(l => new GUIContent(l)).ToArray());
            string type = typeIndex >= 0 && typeIndex < typeNames.Length ? typeNames[typeIndex] : null;
            var sources = type == null ? new List<ContractLayerSource>() : SourcesOf(type);
            if (sources.Count == 0)
            {
                EditorGUILayout.HelpBox(type == null ? "No contract types are known yet." :
                    $"No extracted map has a {type} layer. Extract a map that has one (UCU Map Kit > Setup > Extract Retail Maps…), then press Rebuild index.", MessageType.Info);
            }
            else
            {
                sourceIndex = Mathf.Clamp(sourceIndex, 0, sources.Count - 1);
                sourceIndex = EditorGUILayout.Popup(new GUIContent("Copy from", "The extracted map, and the layer's name in it."), sourceIndex, sources.Select(s => new GUIContent(s.Label)).ToArray());
            }
            EditorGUILayout.Space();
            using (new EditorGUILayout.HorizontalScope())
            {
                using (new EditorGUI.DisabledScope(sources.Count == 0))
                    if (GUILayout.Button(new GUIContent("Add layer", "Copy the layer into the open map (one Undo step), then run Map Check."), GUILayout.Height(24)))
                        AddSelected();
                if (GUILayout.Button(new GUIContent("Rebuild index", "Read every extracted map's encounter layers again."), GUILayout.Height(24)))
                    Load(true);
                if (GUILayout.Button("Close", GUILayout.Height(24)))
                    Close();
            }
            EditorGUILayout.Space();
            EditorGUILayout.LabelField(status, EditorStyles.wordWrappedMiniLabel);
            EditorGUILayout.EndScrollView();
        }

        /// <summary>The Add layer button: copies the selected layer, then opens Map Check on the result.</summary>
        public ContractLayerAddResult AddSelected()
        {
            string type = typeIndex >= 0 && typeIndex < typeNames.Length ? typeNames[typeIndex] : null;
            var sources = type == null ? new List<ContractLayerSource>() : SourcesOf(type);
            if (sources.Count == 0) return null;
            var src = sources[Mathf.Clamp(sourceIndex, 0, sources.Count - 1)];
            try
            {
                EditorUtility.DisplayProgressBar("Add Contract Layer", $"Copying {src.layerName} from {src.map}", 0.5f);
                var r = ContractLayers.Add(src);
                status = $"Added {r.layer.name} ({src.typeName}) from {src.map}: {r.objects} encounter objects, {r.cleared.Count} source-map links cleared (listed in Map Check). Ctrl+Z undoes it.";
                MapKitWindow.OpenCheck();
                return r;
            }
            catch (System.Exception e)
            {
                status = $"Not added: {e.Message}";
                Debug.LogError($"UCU Map Kit: Add Contract Layer: {e}");
                return null;
            }
            finally { EditorUtility.ClearProgressBar(); }
        }
    }
}
