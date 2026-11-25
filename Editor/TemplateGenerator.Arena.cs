// UCU Map Kit: the template's ArenaSkirmish layer (encArena_Skirmish), the layer Skirmish lists a map by (contract type 4,
// the only multiplayer type). Modelled on retail's encArena_Skirmish (mapArena_splitRiver_iTnd; K1d inventory): one
// chunk with two player lance spawners and one destroy-lance objective per player, two contract objectives, and the
// encounter boundary. Every encounter object takes retail's GUID, because ArenaSkirmish_Default/_Template address them;
// only the layer's own GUID is new (HBS's GenerateNewGuid), as for the SimpleBattle layer (K1 decision 56).
using System.Collections.Generic;
using BattleTech;
using BattleTech.Designed;
using BattleTech.Framework;
using HBS.Collections;
using UnityEngine;

namespace UCU.MapKit
{
    public static partial class TemplateGenerator
    {
        const string Player2TeamGuid = "757173dd-b4e1-4bb5-9bee-d78e623cc867";
        // Retail encArena_Skirmish GUIDs. The contract objectives, objectives, spawners and spawn points are the ones the
        // two retail ArenaSkirmish contracts reference; the chunk and boundary GUIDs are retail's too.
        const string ArenaP1ContractObjectiveGuid = "73275787-720a-4c33-9f20-953b1bbf48bd";
        const string ArenaP2ContractObjectiveGuid = "1a9cf63e-ee5b-48a4-957a-80d72267a04c";
        const string ArenaChunkGuid = "818146c7-767c-44ea-905e-80d8006a62eb";
        static readonly string[] ArenaP1PointGuids = { "ec9d2280-ca9a-4d90-8a20-963d8a4c0a39", "ebc06b6a-c5a8-4165-95ce-480bcf335570", "d50f1e9d-0a0b-4dc8-9a06-a33233aaa8a1", "461141c2-f956-49a5-b2c6-6f951b957a94" };
        static readonly string[] ArenaP2PointGuids = { "bfdd72f9-395c-4cde-9f2b-dd28505242a1", "226faa53-e63d-4d02-acd7-ff2fd68598f4", "358c5692-25ee-433b-b9ce-bab9ae35528e", "a863316c-9380-462e-92b1-96e060e44cea" };
        const string ArenaP1DestroyP2Guid = "e32bff57-dd51-4ff4-9d36-ea987844a55d";
        const string ArenaP2DestroyP1Guid = "35ef0c91-b7c2-4380-8ca8-ccdda6d865bc";
        const string ArenaBoundaryChunkGuid = "ea7c6c82-7b3f-4757-aa1e-b1266283a667";
        const string ArenaBoundaryRectGuid = "179ac86a-6cce-495b-aba0-9b1554eb30ce";
        const string ArenaObjectiveTitle = "Destroy Enemy Lance";

        static void BuildArenaLayer(GameObject root, TemplateSettings s, Terrain terrain, HexGrid grid)
        {
            var layerGo = Child(root, "encArena_Skirmish", Vector3.zero);
            var layer = layerGo.AddComponent<EncounterLayerData>();
            layer.GenerateNewGuid();
            layer.encounterName = "Multiplayer Battle 1";
            layer.includeInBuild = IncludeInBuild.Include;
            layer.encounterPlayStyle = EncounterPlayStyle.MultiPlayerVersus;
            layer.EDITOR_SetSupportedContractTypeID("ArenaSkirmish");
            var p1Contract = ContractObjective(layerGo, ArenaP1ContractObjectiveGuid, TeamController.Player1);
            var p2Contract = ContractObjective(layerGo, ArenaP2ContractObjectiveGuid, TeamController.Player2);
            // Retail's layer also has an empty PlotOverride. Left out: the template has no PlotParent, and
            // EncounterLayerData.OverridePlots dereferences one whenever the layer is selected (EncounterLayerData.cs:446).

            var chunkGo = Child(layerGo, "MultiPlayerSkirmishChunk", Vector3.zero);
            var chunk = chunkGo.AddComponent<EmptyCustomChunkGameLogic>();
            chunk.encounterObjectGuid = ArenaChunkGuid;
            chunk.startingStatus = EncounterObjectStatus.Active;
            chunk.notes = "A simple skirmish between two players. It contains 2 lance spawners, and 1 objective for each player: Kill the opposing lance.";

            // Retail: the boundary is 1500 m square and the two lances about 1,240 m apart, facing each other.
            int side = (int)Mathf.Min(1500f, s.terrainSize - 2f * SplatMapInfo.mapBoundaryWidth - 24f);
            float lanceZ = Mathf.Min(600f, side / 2f - 150f);
            var p1 = PlayerLance(chunkGo, "Player1LanceSpawner", PlayerLanceSpawnerGameLogic.Player1LanceSpawnerGuid, ArenaP1PointGuids,
                Player1TeamGuid, new Vector3(0f, 0f, lanceZ), 180f, new[] { "player_unit" }, terrain, grid);
            var p2 = PlayerLance(chunkGo, "Player2LanceSpawner", PlayerLanceSpawnerGameLogic.Player2LanceSpawnerGuid, ArenaP2PointGuids,
                Player2TeamGuid, new Vector3(0f, 0f, -lanceZ), 0f, new[] { "player_player2", "player_unit" }, terrain, grid);
            var p1Objective = DestroyLance(chunkGo, "Player1DestroyPlayer2", ArenaP1DestroyP2Guid, p2);
            var p2Objective = DestroyLance(chunkGo, "Player2DestroyPlayer1", ArenaP2DestroyP1Guid, p1);
            p1Contract.objectiveRefList = new List<ObjectiveRef> { Ref(new ObjectiveRef(), p1Objective) };
            p2Contract.objectiveRefList = new List<ObjectiveRef> { Ref(new ObjectiveRef(), p2Objective) };

            var boundaryChunkGo = Child(layerGo, "Chunk_EncounterBoundary", OnTerrain(Vector3.zero, terrain, 0f));
            var boundaryChunk = boundaryChunkGo.AddComponent<EncounterBoundaryChunkGameLogic>();
            boundaryChunk.encounterObjectGuid = ArenaBoundaryChunkGuid;
            boundaryChunk.startingStatus = EncounterObjectStatus.Active;
            boundaryChunkGo.AddComponent<SnapToTerrain>().snapToTerrainOnly = true;
            var rectGo = Child(boundaryChunkGo, "EncounterBoundaryRect", boundaryChunkGo.transform.position);
            var rect = rectGo.AddComponent<EncounterBoundaryRectGameLogic>();
            rect.encounterObjectGuid = ArenaBoundaryRectGuid;
            rect.width = side;
            rect.height = side;
            rectGo.AddComponent<SnapToTerrain>().snapToTerrainOnly = true;
        }

        static ContractObjectiveGameLogic ContractObjective(GameObject layerGo, string guid, TeamController player)
        {
            var c = layerGo.AddComponent<ContractObjectiveGameLogic>();
            c.encounterObjectGuid = guid;
            c.title = ArenaObjectiveTitle;
            c.forPlayer = player;
            c.primary = true;
            c.displayToUser = true;
            return c;
        }

        // A player lance as retail places it: spawned at its points (InstantlyAtSpawnPoint), VersionOne, facing `yaw`, a
        // CameraStart on its first point. The points keep their world positions (and hexPosition) when the spawner turns.
        static PlayerLanceSpawnerGameLogic PlayerLance(GameObject chunkGo, string name, string guid, string[] pointGuids, string teamGuid,
            Vector3 centre, float yaw, string[] tags, Terrain terrain, HexGrid grid)
        {
            var spawner = Lance<PlayerLanceSpawnerGameLogic>(chunkGo, name, "PlayerLanceSpawnPoint", guid, pointGuids, teamGuid,
                SpawnUnitMethodType.InstantlyAtSpawnPoint, centre, terrain, grid, out var firstPoint);
            spawner.encounterTags = new TagSet("Tags/EncounterTags");
            spawner.encounterTags.AddRange(tags);
            spawner.lanceDefId = LanceSpawnerGameLogic.LanceDef_Manual;
            var t = spawner.transform;
            var points = new List<(Transform, Vector3)>();
            foreach (Transform p in t) points.Add((p, p.position));
            t.rotation = Quaternion.Euler(0f, yaw, 0f);
            foreach (var (p, pos) in points) { p.position = pos; p.rotation = t.rotation; }
            AddCameraStart(firstPoint);
            return spawner;
        }

        static DestroyLanceObjective DestroyLance(GameObject chunkGo, string name, string guid, LanceSpawnerGameLogic target)
        {
            var o = Child(chunkGo, name, Vector3.zero).AddComponent<DestroyLanceObjective>();
            o.encounterObjectGuid = guid;
            o.title = ArenaObjectiveTitle;
            o.showProgress = true;
            o.progressFormat = "[percentageComplete]";
            o.markUnitsWith = ObjectiveMark.AttackTarget;
            o.lanceToDestroy = Ref(new LanceSpawnerRef(), target);
            return o;
        }
    }
}
