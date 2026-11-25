// UCU Map Kit: Encounter mode's writes (design-v2 § 4.2 #3, #4, #8; map-kit plan U3). The Scene-view handles, the number
// fields beside them and the inspectors' Snap buttons all call these. Every write goes through Undo, and one drag or one
// typed value is one Undo step (Begin ... End). On release everything snaps the way the template places it:
// - positions to HBS's hex grid (HexGrid.GetClosestPointOnGrid, the default 24 m grid the template uses);
// - heights to the ground through HBS's own SnapToTerrain.UpdatePosition where the object has one (unit spawn points keep
//   its 2 m offset), else to the terrain under it (SnapToTerrain.GetTerrainSnapPosition);
// - each point's hexPosition through HBS's WorldPointGameLogic.UpdateHexPosition, so it stays in step with the point.
// HBS code is called, never copied. GUIDs and every other field are left alone.
using System;
using System.Linq;
using BattleTech;
using UnityEditor;
using UnityEngine;

namespace UCU.MapKit
{
    public enum BoundaryEdge { West, East, South, North }

    public static class EncounterEdit
    {
        /// <summary>HBS's hex width when no combat is loaded (HexGrid(null)); a region's radius snaps to whole hexes.</summary>
        public const float HexWidth = 24f;
        /// <summary>HBS rounds the play area's centre down to 4 m (EncounterBoundaryRectGameLogic.UpdateRectCenter).</summary>
        public const int BoundaryCentreStep = 4;

        static readonly HexGrid Grid = new HexGrid(null);
        static int group = -1;
        static Action onRelease;

        // ---- One Undo step per drag or typed value ----

        public static bool Dragging => group >= 0;

        /// <summary>Starts one Undo step; <paramref name="release"/> runs at End (the snap).</summary>
        public static void Begin(string label, Action release)
        {
            if (group >= 0) End();
            Undo.IncrementCurrentGroup();
            Undo.SetCurrentGroupName(label);
            group = Undo.GetCurrentGroup();
            onRelease = release;
        }

        /// <summary>Runs the release snap and closes the Undo step Begin opened.</summary>
        public static void End()
        {
            if (group < 0) return;
            int g = group;
            var release = onRelease;
            group = -1;
            onRelease = null;
            try { release?.Invoke(); }
            finally { Undo.CollapseUndoOperations(g); }
        }

        // ---- Layers ----

        public static EncounterLayerParent Parent() => UnityEngine.Object.FindAnyObjectByType<EncounterLayerParent>(FindObjectsInactive.Include);

        public static EncounterLayerData[] Layers(EncounterLayerParent parent) => parent.GetComponentsInChildren<EncounterLayerData>(true);

        /// <summary>The layer the encounter layer parent has active (the one the scene shows).</summary>
        public static EncounterLayerData ActiveLayer(EncounterLayerParent parent) => parent == null ? null : Layers(parent).FirstOrDefault(l => l.gameObject.activeSelf);

        /// <summary>Makes layer <paramref name="index"/> the active one through HBS's SelectEncounterLayerByIndex, with Undo.</summary>
        public static void SelectLayer(EncounterLayerParent parent, int index)
        {
            Undo.RecordObject(parent, "Select encounter layer");
            foreach (var l in Layers(parent)) Undo.RecordObject(l.gameObject, "Select encounter layer");
            parent.SelectEncounterLayerByIndex(index);
        }

        // ---- Lances ----

        /// <summary>Moves the lance across the ground (x, z); its spawn points are its children and move with it.</summary>
        public static void MoveLance(LanceSpawnerGameLogic lance, Vector3 centre)
        {
            var t = lance.transform;
            Undo.RecordObject(t, "Move lance");
            centre.y = t.position.y;
            t.position = centre;
        }

        /// <summary>The release snap: the lance and each of its unit spawn points onto a hex centre and the ground.</summary>
        public static void SnapLance(LanceSpawnerGameLogic lance)
        {
            var t = lance.transform;
            Undo.RecordObject(t, "Snap lance");
            t.position = OnHex(t.position);
            Ground(t);
            foreach (var p in lance.unitSpawnPointGameLogicList) SnapPoint(p);
        }

        public static float Facing(LanceSpawnerGameLogic lance) => lance.transform.eulerAngles.y;

        /// <summary>Turns the lance and its points to <paramref name="yaw"/> degrees; the points keep their places, as the
        /// template turns a lance. A unit faces the way its spawn point does (UnitSpawnPointGameLogic.facing).</summary>
        public static void SetFacing(LanceSpawnerGameLogic lance, float yaw)
        {
            var t = lance.transform;
            var points = lance.unitSpawnPointGameLogicList.Select(p => p.transform).ToArray();
            Undo.RecordObject(t, "Turn lance");
            foreach (var p in points) Undo.RecordObject(p, "Turn lance");
            var keep = points.Select(p => p.position).ToArray();
            t.rotation = Quaternion.Euler(0f, Mathf.Repeat(yaw, 360f), 0f);
            for (int i = 0; i < points.Length; i++)
            {
                points[i].position = keep[i];
                points[i].rotation = t.rotation;
            }
        }

        /// <summary>A typed position: one Undo step, snapped.</summary>
        public static void PlaceLance(LanceSpawnerGameLogic lance, Vector3 centre)
        {
            Begin("Move " + lance.name, () => SnapLance(lance));
            MoveLance(lance, centre);
            End();
        }

        /// <summary>A typed facing: one Undo step, rounded to a whole degree, then the points re-snapped.</summary>
        public static void TurnLance(LanceSpawnerGameLogic lance, float yaw)
        {
            Begin("Turn " + lance.name, () => ReleaseFacing(lance));
            SetFacing(lance, yaw);
            End();
        }

        public static void ReleaseFacing(LanceSpawnerGameLogic lance)
        {
            SetFacing(lance, Mathf.Round(Facing(lance)));
            SnapLance(lance);
        }

        // ---- Play area (EncounterBoundaryRectGameLogic) ----

        /// <summary>The edge as the handle shows it: the object's position plus half the size (unrounded while dragging).</summary>
        public static float Edge(EncounterBoundaryRectGameLogic rect, BoundaryEdge edge)
        {
            var p = rect.transform.position;
            switch (edge)
            {
                case BoundaryEdge.West: return p.x - rect.width / 2f;
                case BoundaryEdge.East: return p.x + rect.width / 2f;
                case BoundaryEdge.South: return p.z - rect.height / 2f;
                default: return p.z + rect.height / 2f;
            }
        }

        static BoundaryEdge Opposite(BoundaryEdge e) => e == BoundaryEdge.West ? BoundaryEdge.East : e == BoundaryEdge.East ? BoundaryEdge.West : e == BoundaryEdge.South ? BoundaryEdge.North : BoundaryEdge.South;
        static bool AlongX(BoundaryEdge e) => e == BoundaryEdge.West || e == BoundaryEdge.East;

        /// <summary>Moves one edge to <paramref name="coord"/> (world x for West/East, z for South/North); the opposite edge
        /// stays. With <paramref name="snap"/>, the centre lands on HBS's 4 m step, so HBS's GetRect keeps the opposite edge
        /// exactly where it was, and the size is the even number of metres that gives.</summary>
        public static void SetBoundaryEdge(EncounterBoundaryRectGameLogic rect, BoundaryEdge edge, float coord, bool snap)
        {
            var t = rect.transform;
            Undo.RecordObject(t, "Resize play area");
            Undo.RecordObject(rect, "Resize play area");
            float o = Edge(rect, Opposite(edge));
            float centre = (o + coord) / 2f;
            if (snap)
            {
                o = Mathf.Round(o);
                centre = Mathf.Round(centre / BoundaryCentreStep) * BoundaryCentreStep;
                if (Mathf.Abs(centre - o) < BoundaryCentreStep) centre = o + Mathf.Sign(coord - o == 0f ? 1f : coord - o) * BoundaryCentreStep;
            }
            int size = Mathf.Max(2, Mathf.RoundToInt(2f * Mathf.Abs(centre - o)));
            var p = t.position;
            if (AlongX(edge)) { p.x = centre; rect.width = size; }
            else { p.z = centre; rect.height = size; }
            t.position = p;
            if (snap) Ground(t);
        }

        /// <summary>The release snap for a dragged edge.</summary>
        public static void SnapBoundary(EncounterBoundaryRectGameLogic rect, BoundaryEdge edge) => SetBoundaryEdge(rect, edge, Edge(rect, edge), true);

        /// <summary>A typed edge: one Undo step, snapped.</summary>
        public static void PlaceBoundaryEdge(EncounterBoundaryRectGameLogic rect, BoundaryEdge edge, float coord)
        {
            Begin("Resize " + rect.name, () => SnapBoundary(rect, edge));
            SetBoundaryEdge(rect, edge, coord, false);
            End();
        }

        // ---- Regions ----

        public static void MoveRegion(RegionGameLogic region, Vector3 centre)
        {
            var t = region.transform;
            Undo.RecordObject(t, "Move region");
            centre.y = t.position.y;
            t.position = centre;
        }

        /// <summary>Sets the radius and lays the region points out as a regular hexagon around the region (HBS: "Player visible
        /// regions are required to be regular hexagons"). The release snap rounds it to whole hexes.</summary>
        public static void SetRegionRadius(RegionGameLogic region, float radius)
        {
            Undo.RecordObject(region, "Region radius");
            region.radius = Mathf.Max(1f, radius);
            LayOutPoints(region);
        }

        /// <summary>The release snap: the region onto a hex centre and the ground, the radius to whole hexes, and the points
        /// onto the hexagon's corners, which are then hex centres too, each with its hexPosition.</summary>
        public static void SnapRegion(RegionGameLogic region)
        {
            var t = region.transform;
            Undo.RecordObject(t, "Snap region");
            Undo.RecordObject(region, "Snap region");
            t.position = OnHex(t.position);
            Ground(t);
            region.radius = Mathf.Max(HexWidth, Mathf.Round(region.radius / HexWidth) * HexWidth);
            LayOutPoints(region);
            foreach (var p in region.regionPointList) SnapPoint(p);
        }

        public static void PlaceRegion(RegionGameLogic region, Vector3 centre)
        {
            Begin("Move " + region.name, () => SnapRegion(region));
            MoveRegion(region, centre);
            End();
        }

        public static void PlaceRegionRadius(RegionGameLogic region, float radius)
        {
            Begin("Radius of " + region.name, () => SnapRegion(region));
            SetRegionRadius(region, radius);
            End();
        }

        // Corner i at i * 360/n degrees from +x: with six points and a radius of whole hexes these are hex centres.
        static void LayOutPoints(RegionGameLogic region)
        {
            var points = region.regionPointList;
            var c = region.transform.position;
            for (int i = 0; i < points.Length; i++)
            {
                float a = i * 2f * Mathf.PI / points.Length;
                var t = points[i].transform;
                Undo.RecordObject(t, "Region radius");
                t.position = new Vector3(c.x + Mathf.Cos(a) * region.radius, t.position.y, c.z + Mathf.Sin(a) * region.radius);
            }
        }

        // ---- Shared snaps ----

        /// <summary>One point onto its hex centre and the ground; then HBS's UpdateHexPosition sets hexPosition from it.</summary>
        public static void SnapPoint(WorldPointGameLogic point)
        {
            var t = point.transform;
            Undo.RecordObject(t, "Snap point");
            Undo.RecordObject(point, "Snap point");
            t.position = OnHex(t.position);
            Ground(t);
            point.UpdateHexPosition();
        }

        /// <summary>An object onto its hex centre and the ground, with Undo (ContractLayers' snap of a copied layer).</summary>
        public static void SnapToHexAndGround(Transform t)
        {
            Undo.RecordObject(t, "Snap");
            t.position = OnHex(t.position);
            Ground(t);
        }

        /// <summary>An object onto the ground where it stands, with Undo.</summary>
        public static void SnapToGround(Transform t)
        {
            Undo.RecordObject(t, "Snap");
            Ground(t);
        }

        static Vector3 OnHex(Vector3 p) => Grid.GetClosestPointOnGrid(p);

        static void Ground(Transform t)
        {
            var snap = t.GetComponent<SnapToTerrain>();
            if (snap != null)
            {
                snap.UpdatePosition();
                return;
            }
            var p = t.position;
            p.y = SnapToTerrain.GetTerrainSnapPosition(p).y;
            t.position = p;
        }
    }
}
