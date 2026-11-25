"""UCU Map Kit setup, step 1: add the Unity packages a kit project needs.

    py -3 add_packages.py <project folder>

Run it with the Unity Editor closed. It pins each package to the exact version below in
<project>/Packages/manifest.json; Unity resolves them (and writes packages-lock.json) on the next open or batch run.
"""
import json
import sys

# id -> pinned version.
PACKAGES = {
    # The game's code needs these four.
    "com.unity.ugui": "2.6.0",
    "com.unity.addressables": "3.1.0",
    "com.unity.mathematics": "1.4.0",
    # Newtonsoft JSON for the game code (BattleTech.ModSupport, JsonProperty on the defs). Addressables does not bring it: the
    # earlier kit projects got it only as a dependency of the agents' Hera connector, at this resolved version (map-kit P1b).
    "com.unity.nuget.newtonsoft-json": "3.2.2",
    # Terrain Tools: noise, erosion and stamp brushes for "Shape the ground". 5.3.3 declares unity 6000.0 in the registry
    # (packages.unity.com), published 2026-08-19; verified to compile and run on 6000.6.9f1.
    "com.unity.terrain-tools": "5.3.3",
    # Splines: the road tool draws a road as a Unity spline (Roads.cs, map-kit X4). 2.9.2 is the version bundled with the
    # Editor 6000.6.9f1 (Data/Resources/PackageManager/Editor/com.unity.splines-2.9.2.tgz). Unity Companion License.
    "com.unity.splines": "2.9.2",
}


def main(project):
    path = project.rstrip("/\\") + "/Packages/manifest.json"
    with open(path, encoding="utf-8") as f:
        manifest = json.load(f)
    manifest["dependencies"].update(PACKAGES)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write(json.dumps(manifest, indent=2) + "\n")
    for name, version in PACKAGES.items():
        print(f"{name} {version}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    main(sys.argv[1])
