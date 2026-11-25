// UCU Map Kit: the base of the kit's readable inspectors (design-v2 § 4.4). Each inspector shows the HBS fields a modder
// touches under plain labels; every tooltip ends with the HBS field name and keeps HBS's own [Tooltip] text. An "HBS fields"
// foldout below draws Unity's default inspector, so nothing is hidden. Every write goes through the SerializedObject
// (PropertyField bindings, or ApplyModifiedProperties), so Undo and prefab overrides behave as in the default inspector.
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using BattleTech;
using UnityEditor;
using UnityEditor.UIElements;
using UnityEngine;
using UnityEngine.UIElements;

namespace UCU.MapKit
{
    public abstract class KitInspector : Editor
    {
        public const string RootPrefix = "ucu-kit-";
        public const string FoldoutName = "hbs-fields";

        protected abstract string Title { get; }
        protected abstract string Summary { get; }
        protected abstract void Build(VisualElement root);

        public override VisualElement CreateInspectorGUI()
        {
            var root = new VisualElement { name = RootPrefix + target.GetType().Name };
            root.Add(new Label(Title) { style = { unityFontStyleAndWeight = FontStyle.Bold, marginTop = 2 } });
            root.Add(new Label(Summary) { style = { whiteSpace = WhiteSpace.Normal, marginBottom = 4, color = new Color(0.65f, 0.65f, 0.65f) } });
            Build(root);
            var fold = new Foldout { text = "HBS fields", value = false, name = FoldoutName, viewDataKey = "ucu-kit-hbs-fields-" + target.GetType().Name };
            fold.tooltip = "Every serialized field under the name HBS gave it (Unity's default inspector).";
            fold.style.marginTop = 6;
            InspectorElement.FillDefaultInspector(fold, serializedObject, this);
            root.Add(fold);
            return root;
        }

        // A serialized field under a plain label. HBS's [ReadOnly] fields stay read-only, as HBS marked them.
        protected PropertyField Field(VisualElement parent, string path, string label, string help = null)
        {
            var p = serializedObject.FindProperty(path);
            if (p == null)
            {
                parent.Add(new Label($"{label}: HBS field {path} is not serialized on this object.") { style = { whiteSpace = WhiteSpace.Normal } });
                return null;
            }
            var f = new PropertyField(p, label) { name = "kit-" + path };
            Tip(f, path, help);
            if (HasAttribute(path, "ReadOnlyAttribute")) f.SetEnabled(false);
            parent.Add(f);
            return f;
        }

        // A read-only line the kit computes from the object (a count, the active layer); never written.
        protected Label Info(VisualElement parent, string name, string text, string tooltip)
        {
            var l = new Label(text) { name = "kit-" + name, tooltip = tooltip, style = { whiteSpace = WhiteSpace.Normal, marginLeft = 3, marginTop = 2 } };
            parent.Add(l);
            return l;
        }

        // One HBS encounter-object reference (an EncounterObjectRef<T> field). The object and its two GUID copies are
        // written together, as HBS's UpdateEncounterObjectGameObject sets them (EncounterObjectRef.cs:118-132), in one
        // ApplyModifiedProperties: one Undo step, and the serialized GUID never goes stale.
        protected ObjectField RefField<T>(VisualElement parent, string path, string label, string help = null) where T : EncounterObjectGameLogic
        {
            var obj = serializedObject.FindProperty(path + ".encounterObject");
            if (obj == null)
            {
                parent.Add(new Label($"{label}: HBS field {path} is not serialized on this object."));
                return null;
            }
            var f = new ObjectField(label) { objectType = typeof(T), allowSceneObjects = true, name = "kit-" + path };
            f.AddToClassList(BaseField<UnityEngine.Object>.alignedFieldUssClassName);
            Tip(f, path, help);
            f.showMixedValue = obj.hasMultipleDifferentValues;
            f.SetValueWithoutNotify(obj.objectReferenceValue);
            f.RegisterValueChangedCallback(e => SetRef(path, e.newValue as T));
            f.TrackPropertyValue(obj, p => { f.showMixedValue = p.hasMultipleDifferentValues; f.SetValueWithoutNotify(p.objectReferenceValue); });
            parent.Add(f);
            return f;
        }

        protected void SetRef(string path, EncounterObjectGameLogic value)
        {
            serializedObject.Update();
            serializedObject.FindProperty(path + ".encounterObject").objectReferenceValue = value;
            var guid = value != null ? value.encounterObjectGuid : string.Empty;
            serializedObject.FindProperty(path + ".internalEncounterObjectGuid").stringValue = guid;
            serializedObject.FindProperty(path + ".loadingGuid").stringValue = guid;
            serializedObject.ApplyModifiedProperties();
        }

        // A list of HBS encounter-object references (List<ObjectiveRef> and the like): one RefField per entry, Add and
        // Remove last. Each write is one ApplyModifiedProperties.
        protected VisualElement RefList<T>(VisualElement parent, string path, string label, string help = null) where T : EncounterObjectGameLogic
        {
            var list = serializedObject.FindProperty(path);
            var box = new VisualElement { name = "kit-" + path, style = { marginTop = 2 } };
            var tip = TipText(path, help);
            box.Add(new Label(label) { tooltip = tip, style = { marginLeft = 3 } });
            parent.Add(box);
            if (list == null || !list.isArray)
            {
                box.Add(new Label($"HBS field {path} is not serialized on this object."));
                return box;
            }
            if (serializedObject.isEditingMultipleObjects)
            {
                box.Add(new Label("Different on each selected object: select one to edit, or use HBS fields.") { style = { whiteSpace = WhiteSpace.Normal, marginLeft = 12 } });
                return box;
            }
            var rows = new VisualElement { style = { marginLeft = 12 } };
            box.Add(rows);
            void Fill()
            {
                rows.Clear();
                serializedObject.Update();
                for (int i = 0; i < list.arraySize; i++)
                    RefField<T>(rows, $"{path}.Array.data[{i}]", $"{i + 1}", help);
                if (list.arraySize == 0) rows.Add(new Label("None.") { tooltip = tip });
            }
            var buttons = new VisualElement { style = { flexDirection = FlexDirection.Row, marginLeft = 12 } };
            buttons.Add(new Button(() =>
            {
                serializedObject.Update();
                list.arraySize++;
                var path0 = $"{path}.Array.data[{list.arraySize - 1}]";
                serializedObject.FindProperty(path0 + ".encounterObject").objectReferenceValue = null;
                serializedObject.FindProperty(path0 + ".internalEncounterObjectGuid").stringValue = string.Empty;
                serializedObject.FindProperty(path0 + ".loadingGuid").stringValue = string.Empty;
                serializedObject.ApplyModifiedProperties();
            }) { text = "Add", name = "kit-" + path + "-add", tooltip = "Add an empty entry; then pick its object." });
            buttons.Add(new Button(() =>
            {
                serializedObject.Update();
                if (list.arraySize > 0) list.arraySize--;
                serializedObject.ApplyModifiedProperties();
            }) { text = "Remove last", name = "kit-" + path + "-remove", tooltip = "Remove the last entry." });
            box.Add(buttons);
            var size = serializedObject.FindProperty(path + ".Array.size");
            box.TrackPropertyValue(size, _ => Fill());
            Fill();
            return box;
        }

        // "<kit help>\nHBS: <HBS's [Tooltip]>\nHBS field: <path>", on the element and on every child that carries a
        // tooltip of its own (PropertyField puts HBS's text on its label, which would otherwise win on hover).
        protected void Tip(VisualElement e, string path, string help)
        {
            var tip = TipText(path, help);
            e.tooltip = tip;
            e.RegisterCallback<GeometryChangedEvent>(_ => e.Query<VisualElement>().ForEach(c => { if (!string.IsNullOrEmpty(c.tooltip)) c.tooltip = tip; }));
        }

        protected string TipText(string path, string help)
        {
            var lines = new List<string>();
            if (!string.IsNullOrEmpty(help)) lines.Add(help);
            var hbs = HbsTooltip(path);
            if (!string.IsNullOrEmpty(hbs)) lines.Add("HBS: " + hbs);
            lines.Add("HBS field: " + path);
            return string.Join("\n", lines);
        }

        string HbsTooltip(string path) => FieldOf(path)?.GetCustomAttribute<TooltipAttribute>(true)?.tooltip;

        bool HasAttribute(string path, string attributeName) =>
            FieldOf(path)?.GetCustomAttributes(true).Any(a => a.GetType().Name == attributeName) ?? false;

        FieldInfo FieldOf(string path)
        {
            var name = path.Split('.')[0];
            for (var t = target.GetType(); t != null && t != typeof(MonoBehaviour); t = t.BaseType)
            {
                var f = t.GetField(name, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly);
                if (f != null) return f;
            }
            return null;
        }
    }
}
