# Notice

The MIT License in [LICENSE](LICENSE) covers the code and documents written for BattleTech: Unofficial Community Update
(UCU) in this repository, and nothing else. In particular it does not cover the content listed below.

## BATTLETECH game content

BATTLETECH, its game code, art, shaders, data and trademarks belong to Harebrained Schemes and Paradox Interactive.
UCU is a non-commercial community project operated under Paradox Interactive's user-generated-content terms (the
[Paradox User Agreement](https://legal.paradoxplaza.com/eula?locale=en)). The kit needs a UCU install and a retail copy
of BATTLETECH.

- **Game code, meshes, textures and maps are not in this repository.** The kit's setup step reads the game's code and art
  from your own UCU and retail installs, and your Unity project stays on your machine. A map you build carries the game art
  it uses in its bundles: its terrain textures, for example, and the weather effects and textures of a weather mood you
  copied. Its bundles can also carry compiled forms of the recovered shaders below. That content is still BATTLETECH's.
  The pictures of retail maps and the screenshots listed below are in this repository.
- **Recovered shaders are in this repository.** `Shaders/Resources/hbs-shaders/` holds 77 shaders as ShaderLab source
  (about 75.8 MB with their `.meta` files). They are our approximations of Harebrained Schemes' shader programs for
  BATTLETECH, recovered by UCU from the compiled shaders in the game and written back out as ShaderLab source. For all
  intents and purposes, they belong to Harebrained Schemes and Paradox Interactive and are not covered by the MIT License.
  The UCU project publishes them in this repository. The folder carries its own [notice](Shaders/NOTICE.md). Not in it:
  retail's compiled shader files (the kit leaves those on your disk), UCU's transplant patches and the decompiled game code.
- **Screenshots of the game's art** in this repository are BATTLETECH content, shown here to document the kit, and are
  not covered by the MIT License:
  - `Documentation~/images/r1-preview-high.jpg`
  - `Documentation~/images/r1-preview-low.jpg`
  - `Documentation~/images/r2-extract-retail-maps.png` (the Extract Retail Maps window; its list shows retail's own map
    icons and the kit's preview pictures)
- **Map preview pictures.** `previews/` holds 68 PNG pictures of retail maps, one per file named for the map, rendered in
  UCU. They show BATTLETECH maps.

Any file added later that is derived from BATTLETECH content is listed here and kept in a folder with its own notice.

## Third-party tools

The kit's setup runs these tools. They are not included in this repository: you install them, and each one keeps its
own licence.

| Tool | Licence | Used for |
|---|---|---|
| [ilspycmd](https://github.com/icsharpcode/ILSpy) | MIT | Turning the game code in your UCU install into source the Unity Editor compiles |
| [Mapkit Asset Manager](https://github.com/BATTLETECH-Unofficial-Community-Update/Mapkit-Asset-Manager) | GPL-3.0 | Copying the game's art out of your retail install |
| [UnityPy](https://github.com/K0lb3/UnityPy) | MIT | Setup's art fix-up scripts |

`assetripper-patches/` is offered under GPL-3.0, not under the MIT License.

The kit's setup also copies third-party libraries the game ships with (Harmony, DOTween, Steamworks.NET, protobuf-net,
Mono.Data.Sqlite and others) from your UCU install into your Unity project. They are not in this repository and keep
their own licences.

## Trademarks

BattleTech is a registered trademark of Microsoft Gaming and the Topps Company (licensed to Catalyst Game Labs).
