"""UCU Map Kit setup: point the project's built-in deferred shaders at the kit's recovered HBS ones, as UCU's project does.

GraphicsSettings m_Deferred, m_DeferredReflections and m_ScreenSpaceShadows get m_Mode 2 (custom shader) and the GUID of the
kit's copy of each shader. The values are UCU's own Project/ProjectSettings/GraphicsSettings.asset (lines 7-15); the kit
shaders keep UCU's GUIDs (setup/install_shaders.py), and this script refuses to write unless each GUID is the one in the
kit's .meta. From map-kit D2-b's run-folder deferred-override.py (.hermes/reports/map-kit-d2b-20261120/scripts/, sha256
02aa1bb0...), with those checks added.

usage (Unity closed, after the kit is in Packages/com.ucu.mapkit): py -3 deferred-overrides.py <project>
"""
import os, re, sys

OVERRIDES = (  # (GraphicsSettings key, shader GUID, the kit's shader file under Shaders/Resources/hbs-shaders)
    ('m_Deferred', 'a12a9dfb3b0bd3f4f845024becccd9dd', 'bt-deferredshading.shader'),
    ('m_DeferredReflections', '0210349363a9a6248a22ac45aa3d515e', 'bt-deferredreflections.shader'),
    ('m_ScreenSpaceShadows', '2a33046a2a1efcd49be92730d2589de3', 'lighting/bt-screenspaceshadows.shader'),
)

if len(sys.argv) != 2:
    sys.exit(__doc__.strip().splitlines()[-1])
project = sys.argv[1]
path = os.path.join(project, 'ProjectSettings', 'GraphicsSettings.asset')
shaders = os.path.join(project, 'Packages', 'com.ucu.mapkit', 'Shaders', 'Resources', 'hbs-shaders')
for key, guid, rel in OVERRIDES:
    meta = os.path.join(shaders, rel + '.meta')
    if not os.path.isfile(os.path.join(shaders, rel)) or 'guid: ' + guid not in open(meta, encoding='utf-8').read():
        sys.exit(f'{key}: the kit shader {rel} with GUID {guid} is not in {shaders}')
text = open(path, encoding='utf-8', newline='').read()
for key, guid, rel in OVERRIDES:
    text, n = re.subn(r'(\n  ' + key + r':\r?\n    m_Mode: )\d(\r?\n    m_Shader: )\{[^}\n]*\}',
                      r'\g<1>2\g<2>{fileID: 4800000, guid: %s, type: 3}' % guid, text)
    if n != 1:
        sys.exit(f'{key}: expected one entry in {path}, found {n}; nothing written')
open(path, 'w', encoding='utf-8', newline='').write(text)
for key, guid, rel in OVERRIDES:
    print(f'MAPKIT_DEFERRED {key} m_Mode=2 guid={guid} ({rel})')
