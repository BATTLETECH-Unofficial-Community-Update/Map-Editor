// UCU Map Kit: the template's EncounterLayerParent and its SimpleBattle layer (encGeneral_Battle; the ArenaSkirmish layer is in TemplateGenerator.Arena.cs), built from the
// K1 inventory of a retail SimpleBattle layer: player lance chunk, one enemy lance with its destroy objective, the
// contract objective, the encounter boundary and the default dialogues. Every encounter object takes the GUID retail's
// SimpleBattle layers share, because retail SimpleBattle contracts address the objects by these GUIDs; only the layer's
// own GUID is new (HBS's GenerateNewGuid). Spec correction 2026-11-20 (K1 leg 3).
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
        // Fixed HBS team ids (EncounterLayerData.GetSelectableTeamGuidsAndNames; retail SimpleBattle spawners).
        const string Player1TeamGuid = "bf40fd39-ccf9-47c4-94a6-061809681140";
        const string TargetTeamGuid = "be77cadd-e245-4240-a93e-b99cc98902a5";
        /// <summary>The encounter tag on every retail player lance spawner; ambushes and occupy objectives require it on the unit.</summary>
        public const string PlayerUnitTag = "player_unit";
        // Shared SimpleBattle encounter-object GUIDs, as on every retail encGeneral_Battle layer (K1 inventory of taiga;
        // the same GUIDs are in the 33 retail SimpleBattle contracts). The player spawner's is HBS's own constant.
        const string ContractObjectiveGuid = "73275787-720a-4c33-9f20-953b1bbf48bd";
        const string PlayerChunkGuid = "8fe4a1b2-232a-48da-9dab-4acb81926998";
        static readonly string[] PlayerPointGuids = { "ec9d2280-ca9a-4d90-8a20-963d8a4c0a39", "ebc06b6a-c5a8-4165-95ce-480bcf335570", "d50f1e9d-0a0b-4dc8-9a06-a33233aaa8a1", "461141c2-f956-49a5-b2c6-6f951b957a94" };
        const string DestroyChunkGuid = "f8089add-7718-4f16-a9aa-6e4a5872bcb0";
        const string EnemySpawnerGuid = "d9a28c08-abdb-42bb-a140-ad3927d1f8cf";
        static readonly string[] EnemyPointGuids = { "9e2d0fed-3d92-42ee-92d0-2cc595709f2a", "e3e34fc2-c664-42ab-920b-6002c058ac55", "ab9e2bfb-f6c4-4b4b-b540-957dcfc48a27", "f46b3021-803a-41ed-87e0-1b8cb86663b8" };
        const string DestroyObjectiveGuid = "d111d351-a666-4852-8e4b-a300d0cccc2d";
        const string BoundaryChunkGuid = "71fb29ec-52e1-496e-a0b6-148af51b961e";
        const string BoundaryRectGuid = "179ac86a-6cce-495b-aba0-9b1554eb30ce";
        const string DialogueChunkGuid = "8955310a-09b3-4661-812b-a52cf268b8ba";
        // Spawn point offsets around a lance spawner, as on the retail layer (about one hex apart).
        static readonly Vector3[] LanceOffsets = { new Vector3(-24f, 0f, 0f), new Vector3(0f, 0f, -20f), new Vector3(24f, 0f, 0f), new Vector3(0f, 0f, 20f) };

        static void BuildEncounterLayerParent(TemplateSettings s, GameObject dropPodLanded, Terrain terrain)
        {
            var root = new GameObject("EncounterLayerParent");
            root.SetActive(false);
            var parent = root.AddComponent<EncounterLayerParent>();
            parent.dropPodLandedPrefab = dropPodLanded;
            var exporter = root.AddComponent<MapMetaDataExporter>();
            exporter.mapName = string.IsNullOrWhiteSpace(s.displayName) ? ReadableName(s.mapName) : s.displayName;
            exporter.weight = 1;
            exporter.generateInclineMap = true;
            // Skirmish-map defaults (MapSettings.SkirmishTags): the biome's tag and typeArena, as retail's
            // mapArena_splitRiver_iTnd row (biomeIcyTundra, featureRiver, typeArena) without the feature tag the template lacks.
            exporter.mapTags = new TagSet("tags/MapTags");
            exporter.mapTags.AddRange(MapSettings.SkirmishTags(s.biome));
            var incline = root.AddComponent<InclineMeshBuilder>();
            incline.downsampleFactor = 6;
            incline.overshootMultiplier = 1.5f;

            var grid = new HexGrid(null);
            var layerGo = Child(root, "encGeneral_Battle", Vector3.zero);
            var layer = layerGo.AddComponent<EncounterLayerData>();
            layer.GenerateNewGuid();
            layer.encounterName = "Battle";
            layer.includeInBuild = IncludeInBuild.Include;
            layer.encounterPlayStyle = EncounterPlayStyle.SinglePlayer;
            layer.EDITOR_SetSupportedContractTypeID("SimpleBattle");
            var contractObjective = layerGo.AddComponent<ContractObjectiveGameLogic>();
            contractObjective.encounterObjectGuid = ContractObjectiveGuid;
            contractObjective.title = "Destroy Enemy Units";
            contractObjective.forPlayer = TeamController.Player1;
            contractObjective.primary = true;
            contractObjective.displayToUser = true;

            float half = s.terrainSize / 2f, lanceZ = Mathf.Min(300f, half - 200f);

            var playerChunkGo = Child(layerGo, "Chunk_PlayerLance", new Vector3(0f, 0f, -lanceZ));
            var playerChunk = playerChunkGo.AddComponent<PlayerLanceChunkGameLogic>();
            playerChunk.encounterObjectGuid = PlayerChunkGuid;
            playerChunk.startingStatus = EncounterObjectStatus.Active;
            var playerSpawner = Lance<PlayerLanceSpawnerGameLogic>(playerChunkGo, "Spawner_PlayerLance", "PlayerLanceSpawnPoint",
                PlayerLanceSpawnerGameLogic.Player1LanceSpawnerGuid, PlayerPointGuids, Player1TeamGuid,
                SpawnUnitMethodType.ViaLeopardDropship, new Vector3(0f, 0f, -lanceZ), terrain, grid, out var firstPlayerPoint);
            // Every retail player lance spawner carries player_unit (180 of 180 in 44 extracted maps, KFIX6); HBS copies the spawner's
            // tags onto its units (LanceSpawnerGameLogic.ContractInitialize), and an ambush springs only for a unit with them.
            playerSpawner.encounterTags = new TagSet("Tags/EncounterTags");
            playerSpawner.encounterTags.Add(PlayerUnitTag);
            AddCameraStart(firstPlayerPoint);
            playerChunk.playerSpawnPointGroup = Ref(new LanceSpawnerRef(), playerSpawner);

            var destroyChunkGo = Child(layerGo, "Chunk_DestroyWholeLance", Vector3.zero);
            var destroyChunk = destroyChunkGo.AddComponent<DestroyWholeLanceChunk>();
            destroyChunk.encounterObjectGuid = DestroyChunkGuid;
            destroyChunk.startingStatus = EncounterObjectStatus.Active;
            var enemySpawner = Lance<LanceSpawnerGameLogic>(destroyChunkGo, "Lance_Enemy_OpposingForce", "UnitSpawnPoint",
                EnemySpawnerGuid, EnemyPointGuids, TargetTeamGuid,
                SpawnUnitMethodType.InstantlyAtSpawnPoint, new Vector3(0f, 0f, lanceZ), terrain, grid, out _);
            var objective = Child(destroyChunkGo, "Objective_DestroyLance", Vector3.zero).AddComponent<DestroyLanceObjective>();
            objective.encounterObjectGuid = DestroyObjectiveGuid;
            objective.title = "Destroy Enemy Units";
            objective.description = "The primary objective to destroy the enemy lance.";
            objective.showProgress = true;
            objective.progressFormat = "[percentageComplete]";
            objective.priority = 1;
            objective.markUnitsWith = ObjectiveMark.AttackTarget;
            objective.lanceToDestroy = Ref(new LanceSpawnerRef(), enemySpawner);
            destroyChunk.lanceSpawner = Ref(new LanceSpawnerRef(), enemySpawner);
            destroyChunk.destroyObjective = Ref(new DestroyLanceObjectiveRef(), objective);
            contractObjective.objectiveRefList = new List<ObjectiveRef> { Ref(new ObjectiveRef(), objective) };

            var boundaryChunkGo = Child(layerGo, "Chunk_EncounterBoundary", OnTerrain(Vector3.zero, terrain, 0f));
            var boundaryChunk = boundaryChunkGo.AddComponent<EncounterBoundaryChunkGameLogic>();
            boundaryChunk.encounterObjectGuid = BoundaryChunkGuid;
            boundaryChunk.startingStatus = EncounterObjectStatus.Active;
            var rect = Child(boundaryChunkGo, "EncounterBoundaryRect", boundaryChunkGo.transform.position).AddComponent<EncounterBoundaryRectGameLogic>();
            rect.encounterObjectGuid = BoundaryRectGuid;
            rect.width = (int)Mathf.Min(1200f, s.terrainSize - 2f * SplatMapInfo.mapBoundaryWidth - 24f);
            rect.height = (int)Mathf.Min(1000f, s.terrainSize - 2f * SplatMapInfo.mapBoundaryWidth - 24f);


            var dialogueChunkGo = Child(layerGo, "Chunk_DefaultDialogue", Vector3.zero);
            var dialogueChunk = dialogueChunkGo.AddComponent<DialogueChunkGameLogic>();
            dialogueChunk.encounterObjectGuid = DialogueChunkGuid;
            dialogueChunk.startingStatus = EncounterObjectStatus.Active;
            Child(dialogueChunkGo, "Dialogue_MissionStart", Vector3.zero).AddComponent<DialogueGameLogic>().encounterObjectGuid = DialogueGameLogic.missionStartDialogueGuid;
            Child(dialogueChunkGo, "Dialogue_MissionSuccess", Vector3.zero).AddComponent<DialogueGameLogic>().encounterObjectGuid = DialogueGameLogic.missionSuccessDialogueGuid;
            Child(dialogueChunkGo, "Dialogue_MissionFailure", Vector3.zero).AddComponent<DialogueGameLogic>().encounterObjectGuid = DialogueGameLogic.missionFailedDialogueGuid;

            // Second layer: ArenaSkirmish, so Skirmish lists the map (TemplateGenerator.Arena.cs). SimpleBattle stays index 0.
            BuildArenaLayer(root, s, terrain, grid);

            root.SetActive(true);
            parent.SelectEncounterLayerByIndex(0);
        }

        static GameObject Child(GameObject parent, string name, Vector3 position)
        {
            var go = new GameObject(name);
            go.transform.SetParent(parent.transform, false);
            go.transform.position = position;
            return go;
        }

        // A lance spawner with four unit spawn points on HBS's hex grid, at terrain height (SnapToTerrain offsets as retail).
        static T Lance<T>(GameObject parent, string name, string pointName, string guid, string[] pointGuids, string teamGuid, SpawnUnitMethodType method, Vector3 centre,
            Terrain terrain, HexGrid grid, out GameObject firstPoint) where T : LanceSpawnerGameLogic
        {
            var go = Child(parent, name, OnTerrain(centre, terrain, 0f));
            var spawner = go.AddComponent<T>();
            spawner.encounterObjectGuid = guid;
            spawner.teamDefinitionGuid = teamGuid;
            spawner.spawnMethod = method;
            // Retail lances are VersionOne; VersionZero with any spawn method but InstantlyAtSpawnPoint fails
            // LanceSpawnerGameLogic.Validate ("needs to be upgraded before selecting different spawn methods").
            spawner.lanceVersion = LanceVersion.VersionOne;
            go.AddComponent<SnapToTerrain>().verticalOffset = 0f;
            firstPoint = null;
            for (int i = 0; i < LanceOffsets.Length; i++)
            {
                var hex = OnTerrain(grid.GetClosestPointOnGrid(centre + LanceOffsets[i]), terrain, 0f);
                var pointGo = Child(go, pointName + (i + 1), hex + Vector3.up * 2f);
                var point = pointGo.AddComponent<UnitSpawnPointGameLogic>();
                point.encounterObjectGuid = pointGuids[i];
                point.hexPosition = hex;
                pointGo.AddComponent<SnapToTerrain>().verticalOffset = 2f;
                if (i == 0) firstPoint = pointGo;
            }
            return spawner;
        }

        // Retail's CameraStart is a child at local zero under the lance's first spawn point (all 8 CameraStarts read from the
        // splitRiver and taiga scenes: localPosition 0,0,0), so CameraControl.InitialCameraFacing frames the lance from its own
        // height. Child() would put it at the WORLD origin: that was 1.6 m from the ground until KT raised the ground to 190 m.
        static void AddCameraStart(GameObject firstPoint)
        {
            var go = new GameObject("CameraStart");
            go.transform.SetParent(firstPoint.transform, false);
            go.AddComponent<CameraStart>();
        }

        // The name the map list shows when the modder types none: the map id with its underscores and camel-case humps split
        // into capitalised words ("mapKit_myFirstMap" is "Map Kit My First Map"). The raw id was shown before.
        public static string ReadableName(string id)
        {
            var sb = new System.Text.StringBuilder();
            for (int i = 0; i < id.Length; i++)
            {
                char c = id[i];
                bool atWord = sb.Length == 0 || sb[sb.Length - 1] == ' ';
                if (c == '_' || c == '-') { if (!atWord) sb.Append(' '); continue; }
                if (!atWord && char.IsUpper(c) && char.IsLower(id[i - 1])) { sb.Append(' '); atWord = true; }
                sb.Append(atWord ? char.ToUpperInvariant(c) : c);
            }
            return sb.ToString().Trim();
        }

        static Vector3 OnTerrain(Vector3 p, Terrain terrain, float offset)
        {
            p.y = terrain.SampleHeight(p) + terrain.transform.position.y + offset;
            return p;
        }

        // Sets both the scene reference and the serialized GUID of an HBS encounter-object reference.
        static LanceSpawnerRef Ref(LanceSpawnerRef r, LanceSpawnerGameLogic target) { r.UpdateEncounterObjectGameObject(target); return r; }
        static DestroyLanceObjectiveRef Ref(DestroyLanceObjectiveRef r, DestroyLanceObjective target) { r.UpdateEncounterObjectGameObject(target); return r; }
        static ObjectiveRef Ref(ObjectiveRef r, ObjectiveGameLogic target) { r.UpdateEncounterObjectGameObject(target); return r; }
    }
}
