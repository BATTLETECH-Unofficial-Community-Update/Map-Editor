# Map-kit KFIX5: repairs the VideoClips of maps extracted before stage-ar-input.ps1 staged a .assets file's streamed media
# (<base>.resource, without the .assets). Mapkit Asset Manager writes a VideoClip whose bytes it cannot read as YAML that points
# at the retail file (m_ExternalResources.m_Source: sharedassets84.resource); the project does not have it, and every urban
# Build Mod logged "Failed to pack resource file". With the file staged it writes what UCU's own export has
# (extractedAssets-YAML-v2/.../VideoClip/*.m4v): the clip's bytes, as <name>.<extension of m_OriginalPath>, with a
# VideoClipImporter meta, under the same GUID (deterministic GUIDs, assetripper-patches/0005), referenced as `type: 3`.
# This does the same for a project that already holds the YAML clips: the bytes are cut from the retail install's file at
# m_Offset/m_Size, the meta keeps the GUID, the YAML asset and its meta are deleted, and every YAML reference to the clip is
# rewritten from type 2 to type 3. The clips are then converted to VP8 .webm (to_webm.py, as UCU holds them: the .m4v.meta is
# renamed, the GUID stays), so ffmpeg is needed; without it the run stops before it touches a file. Run with the Editor closed;
# Unity imports the clips when it opens. A second run changes nothing.
#   repair_videoclips.py <project Assets> <retail BattleTech_Data> <report.tsv>
import importlib.util, os, re, sys

# to_webm.py is loaded from this script's folder by path: `py -3 -I` leaves that folder off sys.path, and a plain import
# would also write __pycache__ into the package, which Unity imports (KFIX6 F1, F2).
sys.dont_write_bytecode = True
_spec = importlib.util.spec_from_file_location('to_webm', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'to_webm.py'))
to_webm = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(to_webm)

META = """fileFormatVersion: 2
guid: {guid}
timeCreated: {created}
licenseType: Free
VideoClipImporter:
  serializedVersion: 2
  externalObjects: {{}}
  useLegacyImporter: 0
  quality: 0
  isColorLinear: 0
  frameRange: 0
  startFrame: 0
  endFrame: {frames}
  colorSpace: 0
  deinterlace: 0
  encodeAlpha: 0
  flipVertical: 0
  flipHorizontal: 0
  importAudio: 1
  targetSettings: {{}}
  output:
    sourcePixelAspectRatioNumerator: 0
    sourcePixelAspectRatioDenominator: 0
    sourceFrameRate: 0
    sourceFileSize: 0
    sourceAudioChannelCount:
    sourceHasAlpha: 0
    transcodeSkipped: 0
    sourceAudioSampleRate:
    originalWidth: 0
    originalHeight: 0
    originalFrameCount: 0
    encodedSettings:
      enableTranscoding: 0
      codec: 0
      resizeFormat: 0
      aspectRatio: 0
      customWidth: 0
      customHeight: 0
      bitrateMode: 0
      spatialQuality: 0
  userData:
  assetBundleName:
  assetBundleVariant:
"""  # Mapkit Asset Manager's VideoClipImporter meta for the game's Unity 2018 (VideoClipExportCollection.CreateImporter), as UCU's export has it


def lp(p):  # extended-length path: a plain path past 259 characters fails to open on Windows with LongPathsEnabled = 0 (its default)
    p = os.path.normpath(os.path.abspath(p))
    if os.name != 'nt' or p.startswith('\\\\?\\'): return p
    return '\\\\?\\UNC\\' + p[2:] if p.startswith('\\\\') else '\\\\?\\' + p


def field(text, name):
    m = re.search(r'^\s*' + name + r':[ \t]*(.*)$', text, re.M)
    return m.group(1).strip() if m else ''


def write(path, data):  # a new file swapped in, so a hard-linked original is never written through
    tmp = path + '.kfix5-tmp'
    with open(tmp, 'wb') as h: h.write(data)
    os.replace(tmp, path)


def main(assets, data_dir, report):
    assets, data_dir = lp(assets), lp(data_dir)
    rows, fixed, bad, checked = [], {}, 0, False
    for d, _, fs in os.walk(assets):
        for f in fs:
            if not f.endswith('.asset'): continue
            p = os.path.join(d, f)
            with open(p, 'rb') as h: head = h.read(200)
            if b'--- !u!329 ' not in head: continue  # class 329 = VideoClip
            text = open(p, encoding='utf-8', errors='replace').read()
            src, off, size = field(text, 'm_Source'), field(text, 'm_Offset'), field(text, 'm_Size')
            if not src or not size.isdigit() or int(size) == 0: continue
            meta = open(p + '.meta', encoding='utf-8').read()
            guid, created = field(meta, 'guid'), field(meta, 'timeCreated') or '0'
            ext = os.path.splitext(field(text, 'm_OriginalPath'))[1] or '.bytes'
            out = p[:-len('.asset')] + ext
            rel = os.path.relpath(p, assets).replace(os.sep, '/')
            retail = os.path.join(data_dir, src)
            why = ('no ' + src + ' in the retail data' if not os.path.exists(retail) else
                   src + ' is shorter than offset+size' if os.path.getsize(retail) < int(off or 0) + int(size) else
                   os.path.basename(out) + ' is there already' if os.path.exists(out) or os.path.exists(out + '.meta') else '')
            if why:
                rows.append((rel, guid, src, off, size, '', 'SKIPPED ' + why)); bad += 1; continue
            if not checked:  # before the first write: no clip is left as an .m4v for want of ffmpeg
                try: to_webm.require_tools()
                except to_webm.ToolsMissing as e:
                    print('repair_videoclips: refused, nothing changed: ' + str(e)); return 2
                checked = True
            with open(retail, 'rb') as h:
                h.seek(int(off or 0)); data = h.read(int(size))
            write(out, data)
            write(out + '.meta', META.format(guid=guid, created=created, frames=field(text, 'm_FrameCount') or '0').encode('utf-8'))
            os.remove(p); os.remove(p + '.meta')
            fixed[guid] = os.path.relpath(out, assets).replace(os.sep, '/')
            rows.append((rel, guid, src, off, size, fixed[guid], 'repaired'))
    refs = files = 0
    if fixed:
        pat = re.compile(rb'(\{fileID: 32900000, guid: )(' + b'|'.join(g.encode() for g in fixed) + rb')(, type: )2\}')
        for d, _, fs in os.walk(assets):
            for f in fs:
                if f.endswith('.meta'): continue
                p = os.path.join(d, f)
                with open(p, 'rb') as h:
                    if h.read(5) != b'%YAML': continue
                    data = b'%YAML' + h.read()
                new, n = pat.subn(rb'\g<1>\g<2>\g<3>3}', data)
                if n:
                    write(p, new); refs += n; files += 1
                    rows.append((os.path.relpath(p, assets).replace(os.sep, '/'), '', '', '', '', '', f'references type 2 -> 3: {n}'))
    if fixed:  # the repaired clips become VP8 .webm under the same GUIDs
        conv = {r[0]: r for r in to_webm.convert_files([os.path.join(assets, g.replace('/', os.sep)) for g in fixed.values() if g.lower().endswith('.m4v')])}
        for i, r in enumerate(rows):
            if r[6] == 'repaired' and os.path.basename(r[5]) in conv:
                c = conv[os.path.basename(r[5])]
                rows[i] = r[:5] + (os.path.splitext(r[5])[0] + '.webm' if c[4].startswith('converted') else r[5], 'repaired; ' + c[4])
                bad += not c[4].startswith('converted')
    with open(report, 'w', encoding='utf-8', newline='\n') as w:
        w.write('asset\tguid\tsource\toffset\tsize\tnow\tresult\n')
        for r in rows: w.write('\t'.join(r) + '\n')
    print(f"videoclips repaired={len(fixed)} skipped/failed={bad}; references rewritten={refs} in {files} files; report {report}")
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main(*sys.argv[1:4]))
