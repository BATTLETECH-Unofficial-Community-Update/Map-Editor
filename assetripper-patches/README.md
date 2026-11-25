# AssetRipper patches for the map kit

The map kit extracts retail maps with a fork of AssetRipper, Mapkit Asset Manager
(<https://github.com/BATTLETECH-Unofficial-Community-Update/Mapkit-Asset-Manager>). This folder is the same changes as a patch set against upstream, so the kit can build the tool without the fork's
repository: `build.ps1` fetches upstream at the pin, applies the patches in order and publishes the CLI.

- Pin: upstream `https://github.com/AssetRipper/AssetRipper` commit `189ccb660ddaf6e1abdd1422113ea60fde8470b4`
  (AssetRipper 1.3.14), the version of the `AssetRipper-CLI_v2` build UCU's exports used.
- The patches are `git format-patch` output of the fork's first five commits, one change each:
  - `0001-cli-front-end.patch`: the `AssetRipper.CLI` command line (`<input> <output>`); upstream has no CLI project at this
    commit. Every setting is its default.
  - `0002-class-name-script-lookup.patch`: a MonoScript whose script ID does not resolve is looked up by class name in its
    assembly (nested types included): a type matching `ClassName_R`, `ClassName`, or `ClassName_R` ignoring case, the first
    in enumeration order.
  - `0003-script-content-level1.patch`: `ScriptContentLevel` defaults to `Level1` (methods stubbed). Upstream's `Level2`
    overflows the stack in ICSharpCode.Decompiler (`AddCheckedBlocks.GetResult`) on BattleTech's Assembly-CSharp.
  - `0004-shader-export-yaml.patch`: `ShaderExportMode` defaults to `Yaml` (ShaderAssets with the compiled programs).
  - `0005-deterministic-guids.patch`: GUID = MD5 of `file/<file name>/<path ID>` for an asset read from a game file;
    `processed/<collection>/<class ID>/<directory>/<name>` for an asset AssetRipper generates; `scene/<level file>` for a
    scene; a generated prefab takes its root GameObject's identity. Writes `AuxiliaryFiles/guid_map.tsv` (path, GUID,
    kind, key) through the CLI. Code GUIDs (scripts, assemblies) were already deterministic and are unchanged.
- Why the GUIDs: stock AssetRipper gives every exported asset a random GUID (`UnityGuid.NewGuid()` in
  `AssetExportCollection`), so two exports of different maps disagree on the assets they share, and a map extracted later
  cannot be added to a project that holds an earlier one.
- Build: `powershell -NoProfile -ExecutionPolicy Bypass -File "<kit folder>\assetripper-patches\build.ps1" -Src "<source folder>" -Out "<tool folder>"` (git and
  a .NET SDK that targets net10.0; built with SDK 11.0.100, no package pins needed). Run it like the stock tool:
  `setup/launch-ar.ps1 -In "<staged game>" -Out "<export>" -Log "<log>" -Ar "<tool folder>\AssetRipper.CLI.dll"`.

AssetRipper is GPL-3.0. The kit runs the built tool as a separate program and never links it; the patches are offered
under AssetRipper's own licence.
