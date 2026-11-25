# Developing the UCU Map Kit

For people who work on the kit itself. A modder needs only [README.md](README.md).

## Where things are

| Path | What it is | Who runs it |
|---|---|---|
| `Editor/` | The kit's Editor scripts (no asmdef: they compile into the project's `Assembly-CSharp-Editor` after setup). | Unity |
| `setup/setup-project.ps1` | The setup step a modder runs: packages, layer table, `csc.rsp`, `MapKitSetup.cs`, `decompile.ps1`, `fix-artefacts.py`, `block-ns.py`, the kit copy, `deferred-overrides.py`, the `MapKitLoader` build, the first compile. | modder |
| `setup/deferred-overrides.py` | GraphicsSettings `m_Deferred`, `m_DeferredReflections`, `m_ScreenSpaceShadows` → mode 2 and the kit shaders' GUIDs, the values of UCU's `Project/ProjectSettings/GraphicsSettings.asset`. Refuses unless the kit's `.meta` carries each GUID. Change it when UCU's overrides change. | setup |
| `setup/MapKitSetup.cs` | Project settings, D3D12 first; the project's name and company (`-Name`, `-Company`; `ProjectSettings/ProjectName.txt` is the title Unity Hub shows). Wrapped in `#if MAPKIT_SETUP` so it never compiles inside the package; setup stages a copy with the define. `setup/kr-open-counts.cs` uses the same guard for a Hera snippet. | setup |
| `setup/ProjectSettings~/TagManager.asset` | A copy of UCU's `Project/ProjectSettings/TagManager.asset`. Refresh it when UCU's layer table changes. The `~` keeps Unity from importing it inside the package. | setup |
| `setup/*.py`, `setup/*.ps1` called by `Editor/RetailExtraction.cs` | The extraction chain (stage, export, embed, cut, import, delete). | Extract Retail Maps |
| `setup/to_webm.py`, `setup/repair_videoclips.py` | Old-project repairs a modder runs by hand with the Editor closed: `.m4v` billboard clips to VP8 `.webm` keeping each GUID; and clips extracted before the media-staging fix (KFIX5), whose media is put back under the clip's GUID, the urban scenes repointed, then converted. Both are idempotent. | modder |
| `setup/install_shaders.py`, `setup/shader-set.tsv` | Copies UCU's recovered shaders from a UCU checkout into `Shaders/` (SHD1). Needs the UCU repo. | kit developer |
| `Shaders/retail-shader-variants.tsv` | The retail variant list shipped beside the recovered shaders; `Editor/KitShaderVariantStripper.cs` reads it. | Unity |
| `Loader~/` | `MapKitLoader` source (references the UCU install's `Assembly-CSharp`, `Newtonsoft.Json` and framework DLLs, and ModTek's `Mods/ModTek/lib/0Harmony.dll`). Setup step 8 builds it with `dotnet` into `<project>/MapKitOutput/_loader/MapKitLoader`; Test Map in UCU builds it the same way when the install has none. No built copy is shipped (P1c: the .NET SDK is already required for `ilspycmd`, so a build step adds no prerequisite and the source stays the only copy). | setup, Test map |
| `setup/publish-kit.ps1` | Publishes the kit: `git archive` of HEAD's `tools/map-kit`, minus the developer-only files below, plus `MANIFEST.tsv` (commit, tree, each file's size and sha256). Refuses a dirty `tools/map-kit`. | kit developer |
| `assetripper-patches/` | Mapkit Asset Manager: AssetRipper 1.3.14 plus the kit's patches (stable GUIDs). Built by the user; the kit makes no network call. | user, once |

## Developer-only files in `setup/` (left out of the published kit)

These need a UCU checkout (`tools/UcuPaths.ps1`, `tools/hera-call.ps1`, `tools/editor-lease.ps1`, git) or serve only its agent
harness, and are not part of a modder's route. `setup/publish-kit.ps1` deletes exactly these from what it publishes (its
`$exclude` list; it refuses when one is missing, so the list and this section stay current):

- `batch-unity.ps1`: one blocking batch run on a kit project (Unity path from `UcuPaths.ps1`).
- `hx.ps1`: a Hera call on a kit Editor through `tools/hera-call.ps1`.
- `kr-chain.ps1`, `kr-open-counts.cs`, `kr-open-counts-req.py`: the KR extraction chain run outside the picker
  (`UcuPaths.ps1`, `hera-call.ps1`), and the per-scene open counts it takes through a Hera exec request (GameObjects,
  missing scripts, null meshes, errors).
- `refresh-kit-package.ps1`: installs `git archive HEAD tools/map-kit` into a kit project through a compile gate, and puts
  the old package back when the gate fails (`editor-lease.ps1`, `batch-unity.ps1`).
- `install_shaders.py`: copies UCU's recovered shaders from a UCU checkout's `Project/Assets` into `Shaders/`.
- `publish-kit.ps1`: needs git and the repository.
- `task-wait.ps1`: waits for a Hera exec operation on a kit Editor to reach a terminal state, with the log guard (agent harness).

Kept although they name UCU paths: `kr-collect.py` (reads only the kit's own extraction logs), `preview_assets.py`
(`import_closure.py` imports its functions; only its command line takes a UCU checkout), `shader-set.tsv` (data: the
shipped shader set with sizes, hashes and GUIDs), and comments that cite `.hermes/` records.

## Driving a kit Editor from an agent

- The Hera connector is a harness step, not part of the kit: `py -3 tools/build-probe/add-hera-connector.py <project>`
  adds it at the main project's pin. Add it only after setup's compile gate: the connector depends on
  `com.unity.nuget.newtonsoft-json`, and that dependency hid the kit's own missing Newtonsoft package until P1b's
  archive control ran without it (2,043 `error CS`).
- Capturing the Inspector through the internal `GUIView.GrabPixels` crashes a D3D12 Editor in
  `GfxDeviceD3D12Base::GrabIntoRenderTexture` (reproduced twice; the kit's own windows captured without a crash). The kit itself
  never calls it: launch the Editor with `-force-d3d11` for an Inspector capture only. A D3D11 capture needs its colours corrected.
- With two Editors open, name the kit one: `tools/hera-call.ps1 -Project <kit project> -Lease <slot> -Run <run>`.
- `RetailExtraction.Current` can read null after the import's domain reload; the end marker of a run is `done.json` in
  `MapKitOutput/retail-maps/`.
- Extraction step 4 failed on MAX_PATH once (a 263-character path with a 36-character project path, `LongPathsEnabled` 0);
  keep kit test projects on short paths.

## Testing a package change

The package is tested from a `publish-kit.ps1` folder alone, outside any checkout, so nothing can lean on the repo (for
uncommitted work, commit it in a scratch clone and publish from there, never on main): a fresh 6000.6.9f1 project
(`Unity.exe -batchmode -quit -createProject <folder>`), `setup/setup-project.ps1` against a UCU install with `Mods\ModTek`
and a retail install, the batch compile (0 `error CS`, exit 0), the read-backs (graphics APIs D3D12 first; `ProjectName.txt`; the three
deferred overrides in `GraphicsSettings.asset`), `MapKitLoader` built and its Init in a player's ModTek log, one extraction
of a `tundraFrozen` map, then **New Map from Template** and Map Check 0. The agents' harness for it is
`tools/build-probe/map-kit-package-leg.ps1` (in the UCU repository, not in the kit).

## Shader coverage (from the SHD0 census)

`BattleTech Mech Standard` (dropships; 58 of the game's 94 scenes reach it) and `BattleTech/VFX/Additive` (4
map scenes) ship in `Shaders/Resources/hbs-shaders/` as build-only imports: UCU's `Project/Assets` holds no copy of either (the
G8 bundle build imports them temporarily), so `setup/install_shaders.py` keeps the kit's own files (the rows of
`setup/shader-set.tsv` with reason `build-only-import`, checked against the list) and reads their keyword rows from
`setup/build-only-variants.tsv`. `BattleTech/VFX/VFX-Deferred` (14
materials in 7 Flashpoint maps; `vfx/bt-vfx-deferred.shader`) and `HBS/Horizon Displacement` (Power Structure;
`hbs_horizon_displacement.shader`) ship in `Shaders/Resources/hbs-shaders/` and `setup/shader-set.tsv` (added in a3e544be0).
The other 33 shaders the kit does not carry belong to the SimGame, space, starmap and portrait scenes. `setup/import_closure.py` points each extracted material at the kit's shaders
through `setup/shader-map.tsv`.
