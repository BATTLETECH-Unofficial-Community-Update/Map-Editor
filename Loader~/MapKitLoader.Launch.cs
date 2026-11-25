// UCU Map Kit loader: start a kit map by itself (in the loader, not a UCU patch).
//   BattleTech.exe -ucuMap <map id> [-ucuContract <layer id, name or guid>]     (also -ucuMap=<id>)
// Without -ucuMap nothing here is installed and a launch is unchanged. With it the loader skips the intro, presses the
// shipped Skirmish single-player button, selects the map in the lobby's own map list, waits for the lobby curtain to be down and
// both lances valid, presses the shipped Play, and presses the mission-load screen's BEGIN MISSION once it is enabled.
// Lances and mood stay the lobby's own (a random lance each side, the mood the lobby picks). Every wait is bounded; a bad map id,
// a wait that runs out or a throw logs one line to MapKitLoader.log and leaves the game where it is.
// Mono.Options (UnityGameInstance.HandleCommandLineArgs) leaves these arguments alone: -ucuMap has no registered first
// character, so OptionSet.ParseBundledValue returns false and Unprocessed files it and its value as extras.
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using BattleTech;
using BattleTech.Data;
using BattleTech.UI;
using HarmonyLib;
using HBS;
using UnityEngine;

namespace MapKitLoader
{
    static class Launch
    {
        internal const float MenuSeconds = 180f, LobbySeconds = 120f, BriefingSeconds = 900f;
        internal static string Map, Contract;
        static bool started;

        internal static void Install(Harmony harmony)
        {
            ReadArgs(Environment.GetCommandLineArgs(), out Map, out Contract);
            if (Map == null) return;
            Entry.Log("LAUNCH -ucuMap " + Map + (Contract != null ? " -ucuContract " + Contract : "") +
                ": the loader skips the intro and starts Skirmish on this map by itself");
            harmony.Patch(AccessTools.Method(typeof(IntroCinematicLauncher), "Init"), prefix: new HarmonyMethod(typeof(Launch), nameof(SkipIntro)));
            harmony.Patch(AccessTools.Method(typeof(MainMenu), "OnAddedToHierarchy"), postfix: new HarmonyMethod(typeof(Launch), nameof(MenuAdded)));
        }

        internal static void ReadArgs(string[] args, out string map, out string contract)
        {
            map = Value(args, "-ucuMap");
            contract = Value(args, "-ucuContract");
            if (map == null && args.Any(a => a.Equals("-ucuMap", StringComparison.OrdinalIgnoreCase) || a.StartsWith("-ucuMap=", StringComparison.OrdinalIgnoreCase)))
                Entry.Log("LAUNCH -ucuMap has no value; ignored");
        }

        // "-name value" or "-name=value"; a value that starts with "-" is the next argument, not a value.
        static string Value(string[] args, string name)
        {
            for (int i = 0; i < args.Length; i++)
            {
                var a = args[i];
                if (a.StartsWith(name + "=", StringComparison.OrdinalIgnoreCase) && a.Length > name.Length + 1) return a.Substring(name.Length + 1);
                if (a.Equals(name, StringComparison.OrdinalIgnoreCase) && i + 1 < args.Length && !args[i + 1].StartsWith("-")) return args[i + 1];
            }
            return null;
        }

        // The intro plays when DebugBridge.DisableIntroMovie is false (IntroCinematicLauncher.Init); a settings file can set it after
        // startup, so it is forced here, at the check itself.
        static void SkipIntro() => DebugBridge.DisableIntroMovie = true;

        static void MenuAdded()
        {
            if (started) return;
            started = true;
            try
            {
                var go = new GameObject("MapKitLaunch");
                UnityEngine.Object.DontDestroyOnLoad(go);
                go.AddComponent<LaunchDriver>();
            }
            catch (Exception e) { Entry.Log("LAUNCH_STOP could not start the launch driver: " + e.Message); }
        }
    }

    sealed class LaunchDriver : MonoBehaviour
    {
        bool failed, videoStopped;

        void Start() => StartCoroutine(Guard(Run()));

        IEnumerator Guard(IEnumerator inner)
        {
            while (true)
            {
                bool more;
                try { more = inner.MoveNext(); }
                catch (Exception e) { Fail("threw " + e.GetType().Name + ": " + e.Message); break; }
                if (!more) break;
                yield return inner.Current;
            }
            Destroy(gameObject);
        }

        void Fail(string why)
        {
            failed = true;
            Entry.Log("LAUNCH_STOP " + why + "; the loader leaves the game where it is");
        }

        IEnumerator Until(string what, float seconds, Func<bool> ready)
        {
            float end = Time.realtimeSinceStartup + seconds;
            while (true)
            {
                // Unity runs this nested iterator itself, outside Guard, so a throw is caught here.
                bool ok;
                try { ok = ready(); }
                catch (Exception e) { Fail("threw " + e.GetType().Name + " waiting for " + what + ": " + e.Message); yield break; }
                if (ok) yield break;
                if (Time.realtimeSinceStartup > end) { Fail("gave up after " + seconds + " s waiting for " + what); yield break; }
                yield return null;
            }
        }

        static T Module<T>() where T : UIModule => LazySingletonBehavior<UIManager>.HasInstance ? LazySingletonBehavior<UIManager>.Instance.GetFirstModule<T>() : null;

        static object Field(object o, string name) => (AccessTools.Field(o is Type t ? t : o.GetType(), name) ?? throw new MissingFieldException(name)).GetValue(o is Type ? null : o);

        static MapAndEncounters FindMap(string id, out int listed)
        {
            var maps = MetadataDatabase.Instance.GetReleasedMapsAndEncounters(false, true, true);
            listed = maps.Count;
            return maps.FirstOrDefault(m => string.Equals(m.Map.MapName, id, StringComparison.OrdinalIgnoreCase));
        }

        // True once the intro no longer holds the menu. If the patch on IntroCinematicLauncher.Init did not apply, the video is
        // stopped the way its own Escape handler does (SGVideoPlayer.StopVideo).
        bool IntroOver()
        {
            if (!IntroCinematicLauncher.HoldForIntroVideo) return true;
            var player = Module<SGVideoPlayer>();
            if (player != null && !videoStopped) { videoStopped = true; player.StopVideo(); Entry.Log("LAUNCH intro video stopped (SGVideoPlayer.StopVideo)"); }
            return false;
        }

        bool LobbyReady(out SkirmishSettings_Beta lobby, out MapModule maps)
        {
            lobby = Field(typeof(SkirmishSettings_Beta), "instance") as SkirmishSettings_Beta;
            maps = lobby == null ? null : Field(lobby, "mapModule") as MapModule;
            var player = lobby == null ? null : Field(lobby, "playerLancePreview") as LancePreviewPanel;
            var opponent = lobby == null ? null : Field(lobby, "opponentLancePreview") as LancePreviewPanel;
            if (maps == null || player == null || opponent == null || maps.SelectedMap == null || LoadingCurtain.IsVisible) return false;
            try { return player.LanceValid && opponent.LanceValid; }
            catch (NullReferenceException) { return false; }   // the previews are not filled yet
        }

        IEnumerator Run()
        {
            MainMenu menu = null;
            yield return Until("the main menu", Launch.MenuSeconds, () =>
            {
                menu = Module<MainMenu>();
                if (menu == null || !menu.Visible || LoadingCurtain.IsVisible || !IntroOver()) return false;
                // the nav panel is hidden while the save structure refreshes (MainMenu.ShowRefreshingSaves)
                return !(Field(menu, "mainNavPanel") is GameObject nav) || nav.activeInHierarchy;
            });
            if (failed) yield break;
            yield return new WaitForSecondsRealtime(1f);

            int listed;
            var want = FindMap(Launch.Map, out listed);
            if (want == null) { Fail("-ucuMap " + Launch.Map + " is not in Skirmish's map list (" + listed + " listed)"); yield break; }
            menu.ReceiveButtonPress("Skirmish_Singleplayer");
            Entry.Log("LAUNCH pressed Skirmish_Singleplayer; " + listed + " maps listed, " + want.Map.MapName + " among them");

            SkirmishSettings_Beta lobby = null; MapModule maps = null;
            yield return Until("the Skirmish lobby with both lances valid", Launch.LobbySeconds, () => LobbyReady(out lobby, out maps));
            if (failed) yield break;
            maps.SelectedMap = want;
            yield return null;
            var got = maps.SelectedMap;
            if (got == null || !string.Equals(got.Map.MapName, want.Map.MapName, StringComparison.Ordinal))
            {
                Fail("selecting " + want.Map.MapName + " in the lobby read back " + (got == null ? "nothing" : got.Map.MapName));
                yield break;
            }
            if (!PickLayer(got)) yield break;
            yield return Until("the lobby curtain down and both lances valid after the selection", Launch.LobbySeconds, () => LobbyReady(out lobby, out maps));
            if (failed) yield break;
            Entry.Log("LAUNCH selected map=" + got.Map.MapName + " mood=" + (maps.SelectedMood == null ? "?" : maps.SelectedMood.Name) + "; pressing Play");
            lobby.ReceiveButtonPress("Play");

            Briefing briefing = null;
            yield return Until("the mission-load screen's BEGIN MISSION button", Launch.BriefingSeconds, () =>
            {
                briefing = Module<Briefing>();
                var button = briefing == null ? null : Field(briefing, "startButton");
                return button != null && "" + button.GetType().GetProperty("State").GetValue(button, null) == "Enabled";
            });
            if (failed) yield break;
            (AccessTools.Method(typeof(Briefing), "GenerateCloseEvent") ?? throw new MissingMethodException("Briefing.GenerateCloseEvent")).Invoke(briefing, null);
            Entry.Log("LAUNCH pressed BEGIN MISSION (Briefing.GenerateCloseEvent)");
        }

        // LaunchMap takes the first skirmish layer of the selected map (SkirmishSettings_Beta.LaunchMap). -ucuContract moves the
        // matching skirmish layer to the front of that map's own layer list; no match leaves the list as retail has it.
        bool PickLayer(MapAndEncounters map)
        {
            var layers = (List<EncounterLayer_MDD>)Field(map, "_encounters");
            var skirmish = layers.Where(l => l.ContractTypeValue.IsSkirmish).ToList();
            if (skirmish.Count == 0) { Fail("map " + map.Map.MapName + " has no skirmish layer, so Play would find none"); return false; }
            var chosen = skirmish[0];
            if (Launch.Contract != null)
            {
                bool Eq(string s) => string.Equals(s, Launch.Contract, StringComparison.OrdinalIgnoreCase);
                var hit = skirmish.FirstOrDefault(l => Eq(l.EncounterLayerID) || Eq(l.Name) || Eq(l.EncounterLayerGUID));
                if (hit == null)
                    Entry.Log("LAUNCH -ucuContract " + Launch.Contract + " matches no skirmish layer on " + map.Map.MapName + " (" + string.Join(", ", skirmish.Select(l => l.Name + "/" + l.EncounterLayerGUID).ToArray()) + "); using the first, as retail does");
                else if (hit != chosen)
                {
                    int at = layers.IndexOf(chosen);
                    layers.Remove(hit);
                    layers.Insert(at, hit);
                    chosen = hit;
                }
            }
            Entry.Log("LAUNCH layer=" + chosen.Name + " guid=" + chosen.EncounterLayerGUID + " contractType=" + chosen.ContractTypeValue.Name);
            return true;
        }
    }
}
