# Notice: recovered BATTLETECH shaders

The shaders in `Resources/hbs-shaders/` are our approximations of Harebrained Schemes' shader programs for BATTLETECH,
recovered by BattleTech: Unofficial Community Update (UCU) from the compiled shaders in the game and written back out as
ShaderLab source. For all intents and purposes, they belong to Harebrained Schemes and Paradox Interactive and are not covered
by the MIT License. The UCU project publishes them in this repository.

UCU is a non-commercial community project operated under Paradox Interactive's
user-generated-content terms (the [Paradox User Agreement](https://legal.paradoxplaza.com/eula?locale=en)).

The files and their `.meta` GUIDs are UCU's own. The GUIDs are not to be changed: the kit's GraphicsSettings overrides and the
materials `setup/import_closure.py` binds point at them. `setup/shader-set.tsv` lists every file with its size and sha256, and
`setup/install_shaders.py` refreshes the folder from a UCU checkout.
