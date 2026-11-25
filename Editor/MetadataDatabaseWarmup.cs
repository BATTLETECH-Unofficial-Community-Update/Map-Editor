// UCU Map Kit: run MetadataDatabase's static constructor on the main thread before a scene opens in the Editor. The same
// Editor-only route as UCU's own project (Project/Assets/Editor/MetadataDatabaseEditModeWarmup.cs, console register E18).
//
// Retail map scenes carry ExtraContractData in their encounter logic. Its field initializer
// (player1TeamFaction = FactionEnumeration.GetPlayer1sMercUnitFactionValue().Name) reaches the MetadataDatabase static
// constructor, whose Init reads ModLoader.AreModsEnabled -> PlayerPrefs.GetInt. In the game the database is up before any
// map loads. Opening a map in the Editor runs that initializer first, while Unity deserializes the scene, where Unity
// forbids PlayerPrefs ("GetInt is not allowed to be called from a MonoBehaviour constructor"), and the
// TypeInitializationException leaves MetadataDatabase unusable until the next script reload.
//
// EditorSceneManager.sceneOpening fires on the main thread before the scene file is read, outside any constructor, so the
// static constructor runs there as it does in the game. Once per script reload, before the first scene of any folder (a
// modder's map need not be under Level Design/Maps); not in Play or batch mode. The game code is unchanged.
using System.Runtime.CompilerServices;
using BattleTech.Data;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

namespace UCU.MapKit
{
    [InitializeOnLoad]
    static class MetadataDatabaseWarmup
    {
        static bool done;

        static MetadataDatabaseWarmup()
        {
            if (Application.isBatchMode || AssetDatabase.IsAssetImportWorkerProcess()) return;
            EditorSceneManager.sceneOpening += (path, mode) =>
            {
                if (done || EditorApplication.isPlayingOrWillChangePlaymode) return;
                done = true;
                RuntimeHelpers.RunClassConstructor(typeof(MetadataDatabase).TypeHandle);
                Debug.Log($"UCU Map Kit: MetadataDatabase initialized before opening {path}");
            };
            // After the scene has loaded, not before: a lookup of the DebugConsole made while a scene loads (by whom was not traced) can run before the new
            // one exists, and a lookup that finds none is kept for good (ContractLayers.ResetSceneSingletons). A reset in sceneOpening was measured
            // to be spoilt again that way (map-kit KFIX9 S1, fix1: the first open after each start or reload failed).
            EditorSceneManager.sceneOpened += (scene, mode) =>
            {
                if (!EditorApplication.isPlayingOrWillChangePlaymode) ContractLayers.ResetSceneSingletons();
            };
        }
    }
}
