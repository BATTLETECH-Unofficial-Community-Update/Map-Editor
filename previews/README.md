# Map preview pictures

One 542x305 PNG for each retail map that ships no `<MapID>_icon` of its own: 68 of those 70 maps (see Missing). The 15 maps that
have a retail icon are not here, because retail's own `<MapID>_icon` is what shows for them.

Files are named `<MapID>.png`. Each is RGB with the top row first (an ordinary PNG). Retail's `.dds` icons are stored bottom
row first, so they look upside down in an ordinary viewer; a loader that takes both must not flip these.

These pictures show BATTLETECH maps. [NOTICE](../NOTICE.md) lists them with the other game content in this kit.

## How they were made

Each picture is a screenshot taken in UCU, in a contract played on that map, at the first player turn. The game's own
screenshot path took it with the HUD and in-world UI off, units hidden, ambient fog at 0.3 times its value and fog of war
off. Players were UCU builds without a store, with ModTek and no map mod.

| item | value |
|---|---|
| area | the play-area boundary of the map's encounter layer (not the terrain) |
| camera | pitch 25 degrees down, vertical field of view 45, looking along +z |
| distance | the smallest that keeps a 5x5 grid of boundary points inside a 10 % border |
| capture | 1084x610, averaged down to 542x305, after 8 seconds at the pose |
| mood | by biome: Arid `AridDayClear`, Arctic `ArcticDayFrozen`, Verdant `VerdantDayWindy`, Jungle `JungleDayMisty`, Mars `MartianAfternoonDusty`, Urban `UrbanAfternoon`, Lunar `LunarSunset` (no day mood exists) |

Story and restoration maps have no procedural contract, so their pictures were taken from the map's own layer with the first
loaded contract definition of that type.

## Known limits

- The framing is fitted to the play area, not retail's hand-framed crop. Against three retail icons (canyon, redCity, bigLoch)
  two show the same landmarks and one (bigLoch) shows the same region from another side. No camera angle reproduced retail's.
- Colours differ from retail's desaturated icons, and no crosshair grid is drawn.
- Rendering one map twice gives the same camera but not the same pixels: animated foliage and temporal effects differ.
- Some highland maps are dark under `VerdantDayWindy` (rockyCliffs, rawCliffsides, bluffs, hiddenLagoon).

## Missing

`mapStory_StoryEncounter1a_vHigh` and `mapStory_StoryEncounter6b_iGlc` have no picture here.
