// UCU Map Kit: Encounter mode's Scene-view handles (design-v2 § 4.2 #3, #4, #8, § 4.4; map-kit plan U3). Drawn only while
// Encounter mode is on, for the active layer:
// - a move handle on each lance (its four spawn points move with it) and on each region;
// - a facing ring on the selected lance;
// - an edge handle on each side of the play area;
// - a radius handle on each region.
// A drag is one Undo step (EncounterEdit.Begin at the first change, End when the handle lets go), and End runs the snap.
// The selected object gets number fields beside its handles (DelayedFloatField: the value applies on Enter, as one Undo
// step, then snaps), so no action needs the mouse. While a kit object is selected, Unity's own move gizmo is hidden so
// that the kit's handle, which snaps, is the one used.
using System;
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEngine;

namespace UCU.MapKit
{
    [InitializeOnLoad]
    public static class EncounterHandles
    {
        static readonly Color PlayerColour = new Color(0.25f, 0.75f, 1f), EnemyColour = new Color(1f, 0.4f, 0.3f);
        static readonly Color AreaColour = new Color(1f, 0.85f, 0.2f), RegionColour = new Color(0.5f, 1f, 0.5f);
        const float FacingRing = 40f;
        static bool hidTools;

        static EncounterHandles()
        {
            SceneView.duringSceneGui += OnSceneGUI;
            KitModes.Changed += () => { if (KitModes.Current != KitMode.Encounter) RestoreTools(); };
        }

        static void OnSceneGUI(SceneView view)
        {
            if (KitModes.Current != KitMode.Encounter) { RestoreTools(); return; }
            var layer = EncounterEdit.ActiveLayer(EncounterEdit.Parent());
            if (layer == null) return;
            var selected = Selection.activeGameObject;

            foreach (var rect in layer.GetComponentsInChildren<EncounterBoundaryRectGameLogic>()) Boundary(rect, selected);
            foreach (var region in layer.GetComponentsInChildren<RegionGameLogic>()) Region(region, selected);
            foreach (var lance in layer.GetComponentsInChildren<LanceSpawnerGameLogic>()) Lance(lance, selected);

            // The handle has let go: snap and close the Undo step.
            if (EncounterEdit.Dragging && GUIUtility.hotControl == 0) EncounterEdit.End();

            if (Event.current.type == EventType.Layout)
            {
                bool kitObject = selected != null && (selected.GetComponent<LanceSpawnerGameLogic>() != null || selected.GetComponent<RegionGameLogic>() != null
                    || selected.GetComponent<EncounterBoundaryRectGameLogic>() != null);
                if (kitObject && !Tools.hidden) { Tools.hidden = true; hidTools = true; }
                else if (!kitObject) RestoreTools();
            }
        }

        static void RestoreTools()
        {
            if (!hidTools) return;
            Tools.hidden = false;
            hidTools = false;
        }

        static void Lance(LanceSpawnerGameLogic lance, GameObject selected)
        {
            var t = lance.transform;
            var pos = t.position;
            bool player = lance is PlayerLanceSpawnerGameLogic;
            Handles.color = player ? PlayerColour : EnemyColour;
            float size = HandleUtility.GetHandleSize(pos) * 0.2f;
            foreach (var p in lance.unitSpawnPointGameLogicList)
            {
                var pp = p.transform.position;
                Handles.DrawWireDisc(pp, Vector3.up, 12f);
                Handles.DrawLine(pp, pp + p.transform.forward * 16f);
                Handles.DrawDottedLine(pos, pp, 3f);
            }
            EditorGUI.BeginChangeCheck();
            var moved = Handles.Slider2D(pos, Vector3.up, Vector3.right, Vector3.forward, size, Handles.RectangleHandleCap, Vector2.zero);
            if (EditorGUI.EndChangeCheck())
            {
                StartDrag(lance.gameObject, "Move " + lance.name, () => EncounterEdit.SnapLance(lance));
                EncounterEdit.MoveLance(lance, moved);
            }
            Handles.Label(pos + Vector3.up * size * 3f, lance.name);
            if (selected != lance.gameObject) return;

            EditorGUI.BeginChangeCheck();
            var turned = Handles.Disc(t.rotation, pos, Vector3.up, FacingRing, false, 0f);
            if (EditorGUI.EndChangeCheck())
            {
                StartDrag(lance.gameObject, "Turn " + lance.name, () => EncounterEdit.ReleaseFacing(lance));
                EncounterEdit.SetFacing(lance, turned.eulerAngles.y);
            }
            Handles.DrawLine(pos, pos + t.forward * FacingRing);
            Fields(pos, "lance", Beside,
                ("X", "World x of the lance's centre (m). Enter moves the lance; its points snap to hexes and the ground.", pos.x, v => EncounterEdit.PlaceLance(lance, new Vector3(v, pos.y, pos.z))),
                ("Z", "World z of the lance's centre (m).", pos.z, v => EncounterEdit.PlaceLance(lance, new Vector3(pos.x, pos.y, v))),
                ("Facing", "The way the lance's units face, in degrees (0 = +z, 90 = +x). HBS: UnitSpawnPointGameLogic.facing", EncounterEdit.Facing(lance), v => EncounterEdit.TurnLance(lance, v)));
        }

        static readonly BoundaryEdge[] Edges = { BoundaryEdge.West, BoundaryEdge.East, BoundaryEdge.South, BoundaryEdge.North };

        static void Boundary(EncounterBoundaryRectGameLogic rect, GameObject selected)
        {
            var c = rect.transform.position;
            float w = EncounterEdit.Edge(rect, BoundaryEdge.West), e = EncounterEdit.Edge(rect, BoundaryEdge.East);
            float s = EncounterEdit.Edge(rect, BoundaryEdge.South), n = EncounterEdit.Edge(rect, BoundaryEdge.North);
            Handles.color = AreaColour;
            Handles.DrawPolyLine(new Vector3(w, c.y, s), new Vector3(e, c.y, s), new Vector3(e, c.y, n), new Vector3(w, c.y, n), new Vector3(w, c.y, s));
            foreach (var edge in Edges)
            {
                var at = EdgePoint(rect, edge);
                var dir = edge == BoundaryEdge.West ? Vector3.left : edge == BoundaryEdge.East ? Vector3.right : edge == BoundaryEdge.South ? Vector3.back : Vector3.forward;
                float size = HandleUtility.GetHandleSize(at) * 0.12f;
                EditorGUI.BeginChangeCheck();
                var moved = Handles.Slider(at, dir, size, Handles.CubeHandleCap, 0f);
                if (EditorGUI.EndChangeCheck())
                {
                    var which = edge;
                    StartDrag(rect.gameObject, "Resize " + rect.name, () => EncounterEdit.SnapBoundary(rect, which));
                    EncounterEdit.SetBoundaryEdge(rect, edge, edge == BoundaryEdge.West || edge == BoundaryEdge.East ? moved.x : moved.z, false);
                }
                if (selected == rect.gameObject)
                {
                    var which = edge;
                    Fields(at, "edge-" + edge, Beside, (edge.ToString(), $"World {(edge == BoundaryEdge.West || edge == BoundaryEdge.East ? "x" : "z")} of the play area's {edge.ToString().ToLowerInvariant()} edge (m). The opposite edge stays; the centre rounds to 4 m as HBS reads it. HBS fields: width, height",
                        EncounterEdit.Edge(rect, edge), v => EncounterEdit.PlaceBoundaryEdge(rect, which, v)));
                }
            }
        }

        static Vector3 EdgePoint(EncounterBoundaryRectGameLogic rect, BoundaryEdge edge)
        {
            var c = rect.transform.position;
            float v = EncounterEdit.Edge(rect, edge);
            return edge == BoundaryEdge.West || edge == BoundaryEdge.East ? new Vector3(v, c.y, c.z) : new Vector3(c.x, c.y, v);
        }

        static void Region(RegionGameLogic region, GameObject selected)
        {
            var c = region.transform.position;
            Handles.color = RegionColour;
            var points = region.regionPointList.Select(p => p.transform.position).ToList();
            if (points.Count > 1) { points.Add(points[0]); Handles.DrawPolyLine(points.ToArray()); }
            float size = HandleUtility.GetHandleSize(c) * 0.2f;
            EditorGUI.BeginChangeCheck();
            var moved = Handles.Slider2D(c, Vector3.up, Vector3.right, Vector3.forward, size, Handles.CircleHandleCap, Vector2.zero);
            if (EditorGUI.EndChangeCheck())
            {
                StartDrag(region.gameObject, "Move " + region.name, () => EncounterEdit.SnapRegion(region));
                EncounterEdit.MoveRegion(region, moved);
            }
            var rim = c + Vector3.right * region.radius;
            EditorGUI.BeginChangeCheck();
            var pulled = Handles.Slider(rim, Vector3.right, HandleUtility.GetHandleSize(rim) * 0.12f, Handles.SphereHandleCap, 0f);
            if (EditorGUI.EndChangeCheck())
            {
                StartDrag(region.gameObject, "Radius of " + region.name, () => EncounterEdit.SnapRegion(region));
                EncounterEdit.SetRegionRadius(region, pulled.x - c.x);
            }
            Handles.Label(c + Vector3.up * size * 3f, region.name);
            if (selected != region.gameObject) return;
            // Below the centre, so the box never covers the radius handle on the same row.
            Fields(c, "region", new Vector2(-84f, 28f),
                ("X", "World x of the region's centre (m). Enter moves it; it and its points snap to hexes and the ground.", c.x, v => EncounterEdit.PlaceRegion(region, new Vector3(v, c.y, c.z))),
                ("Z", "World z of the region's centre (m).", c.z, v => EncounterEdit.PlaceRegion(region, new Vector3(c.x, c.y, v))));
            Fields(rim, "radius", Beside, ("Radius", "Region radius (m), rounded to whole hexes of 24 m on release, so the six points sit on hex centres. HBS field: radius",
                region.radius, v => EncounterEdit.PlaceRegionRadius(region, v)));
        }

        static void StartDrag(GameObject go, string label, Action release)
        {
            if (EncounterEdit.Dragging) return;
            Selection.activeGameObject = go;
            EncounterEdit.Begin(label, release);
        }

        static readonly Vector2 Beside = new Vector2(28f, -10f);

        // Number fields beside a handle (offset in points from the handle); Tab moves between them, Enter applies.
        static void Fields(Vector3 world, string id, Vector2 offset, params (string label, string tip, float value, Action<float> set)[] rows)
        {
            var gp = HandleUtility.WorldToGUIPoint(world);
            var box = new Rect(gp.x + offset.x, gp.y + offset.y, 168f, rows.Length * 20f + 6f);
            Handles.BeginGUI();
            GUI.Box(box, GUIContent.none, EditorStyles.helpBox);
            float labelWidth = EditorGUIUtility.labelWidth;
            EditorGUIUtility.labelWidth = 52f;
            for (int i = 0; i < rows.Length; i++)
            {
                var r = new Rect(box.x + 4f, box.y + 3f + i * 20f, box.width - 8f, 18f);
                GUI.SetNextControlName($"ucu-kit-{id}-{rows[i].label}");
                EditorGUI.BeginChangeCheck();
                float v = EditorGUI.DelayedFloatField(r, new GUIContent(rows[i].label, rows[i].tip), (float)Math.Round(rows[i].value, 2));
                if (EditorGUI.EndChangeCheck()) rows[i].set(v);
            }
            EditorGUIUtility.labelWidth = labelWidth;
            Handles.EndGUI();
        }
    }
}
