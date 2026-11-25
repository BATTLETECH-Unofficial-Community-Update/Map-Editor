# Map-kit VP8: converts the H.264 .m4v VideoClips of a kit project to VP8/Vorbis .webm, as UCU holds them (tools/extraction/
# to-webm.sh): Proton plays H.264 as colour bars and the Linux Editor cannot read it. The same ffmpeg arguments:
# two-pass VP8 at each clip's own video bitrate, Vorbis 128k when the clip has audio. Each clip's .m4v.meta is renamed to
# .webm.meta, so its GUID (and every scene reference to it) stays; nothing else is rewritten. The .m4v is deleted once the .webm
# is written and its SSIM against the source is measured. Needs ffmpeg and ffprobe with libvpx and libvorbis on PATH.
#   to_webm.py <folder holding the .m4v clips, searched recursively> [--report <tsv>] [--idle]
# For a project extracted before this existed: to_webm.py <project>/Assets/VideoClip. Run with the Editor closed; Unity imports
# the .webm when it opens. A second run finds no .m4v and changes nothing. --idle runs ffmpeg at Idle priority (Windows).
# Exit 0 done, 1 a clip failed, 2 ffmpeg missing or without the codecs (refused before any file is touched).
import os, re, shutil, subprocess, sys, tempfile

IDLE = 0x00000040  # IDLE_PRIORITY_CLASS


class ToolsMissing(Exception):
    pass


def require_tools():
    """Raises ToolsMissing naming what to install, unless ffmpeg and ffprobe run and ffmpeg has libvpx and libvorbis."""
    for t in ('ffmpeg', 'ffprobe'):
        if not shutil.which(t):
            raise ToolsMissing(f"{t} is not on PATH. Install ffmpeg with libvpx and libvorbis (a full build, e.g. gyan.dev or "
                               "`winget install Gyan.FFmpeg`) and open a new shell; the VideoClips are converted to VP8 .webm with it.")
    enc = subprocess.run(['ffmpeg', '-hide_banner', '-encoders'], capture_output=True, text=True).stdout
    for codec in ('libvpx', 'libvorbis'):
        if not re.search(r'\b' + codec + r'\s', enc):
            raise ToolsMissing(f"this ffmpeg has no {codec} encoder ({shutil.which('ffmpeg')}); install a full build.")


def run(args, cwd, idle):
    return subprocess.run(args, cwd=cwd, capture_output=True, text=True, creationflags=IDLE if idle and os.name == 'nt' else 0)


def probe(args, cwd):
    return subprocess.run(['ffprobe', '-v', 'error'] + args, cwd=cwd, capture_output=True, text=True).stdout.strip()


def video_bitrate(name, cwd):
    """The source's own video bitrate in bit/s: the stream's, else the container's less 128k of audio, else size over duration."""
    for entry, sel in (('stream=bit_rate', ['-select_streams', 'v:0']), ('format=bit_rate', [])):
        v = probe(sel + ['-show_entries', entry, '-of', 'default=nw=1:nk=1', name], cwd)
        if v.isdigit() and int(v) > 0: return int(v)
    dur = probe(['-show_entries', 'format=duration', '-of', 'default=nw=1:nk=1', name], cwd)
    return int(os.path.getsize(os.path.join(cwd, name)) * 8 / float(dur)) if dur not in ('', 'N/A') else 0


def convert_one(src, idle):
    """src: path of a .m4v. Returns (webm path, ssim string) or raises RuntimeError. Runs ffmpeg in the clip's folder with relative
    names, so a long project path and a name with & or ' never reach a command line as a path."""
    cwd, f = os.path.split(os.path.abspath(src))
    base = os.path.splitext(f)[0]
    out, part = base + '.webm', base + '.part.webm'
    vbr = video_bitrate(f, cwd)
    if vbr <= 0: raise RuntimeError('no video bitrate to match')
    vb, mx = f'{max(vbr // 1000 - 4, 1)}k', f'{vbr * 2 // 1000}k'
    audio = 'audio' in probe(['-select_streams', 'a', '-show_entries', 'stream=codec_type', '-of', 'csv=p=0', f], cwd)
    a = ['-c:a', 'libvorbis', '-b:a', '128k'] if audio else ['-an']
    v = ['-c:v', 'libvpx', '-b:v', vb, '-minrate', '0', '-maxrate', mx, '-bufsize', mx, '-qmin', '0', '-qmax', '50', '-deadline', 'good',
         '-cpu-used', '0', '-auto-alt-ref', '1', '-lag-in-frames', '25', '-arnr-maxframes', '7', '-arnr-strength', '3', '-g', '50',
         '-threads', '0', '-pix_fmt', 'yuv420p']
    log = os.path.join(tempfile.mkdtemp(prefix='vp8pass-'), 'pass')
    c = ['ffmpeg', '-nostdin', '-hide_banner', '-loglevel', 'error', '-y', '-i', f, '-map', '0:v:0']
    try:
        r = run(c + v + ['-pass', '1', '-passlogfile', log, '-an', '-f', 'webm', os.devnull], cwd, idle)
        if r.returncode: raise RuntimeError('pass 1: ' + r.stderr.strip()[-300:])
        r = run(c[:-2] + ['-map', '0:v:0', '-map', '0:a?'] + v + ['-pass', '2', '-passlogfile', log] + a + [part], cwd, idle)
        if r.returncode: raise RuntimeError('pass 2: ' + r.stderr.strip()[-300:])
        s = run(['ffmpeg', '-nostdin', '-hide_banner', '-i', part, '-i', f, '-lavfi', '[0:v][1:v]ssim', '-f', 'null', '-'], cwd, idle)
        m = re.search(r'All:([0-9.]+)', s.stderr)
        if not m or os.path.getsize(os.path.join(cwd, part)) == 0: raise RuntimeError('the .webm has no SSIM or is empty')
        os.replace(os.path.join(cwd, part), os.path.join(cwd, out))
        return os.path.join(cwd, out), m.group(1)
    finally:
        shutil.rmtree(os.path.dirname(log), ignore_errors=True)
        if os.path.exists(os.path.join(cwd, part)): os.remove(os.path.join(cwd, part))


def convert_files(clips, idle=False, say=print):
    """clips: paths of .m4v files. Converts each, moves its meta, deletes the .m4v. Returns rows (name, before, after, ssim, result)."""
    rows = []
    for src in sorted(clips):
        name, meta = os.path.basename(src), src + '.meta'
        base = os.path.splitext(src)[0]
        webm = base + '.webm'
        if os.path.exists(webm + '.meta') and os.path.exists(meta):
            rows.append((name, str(os.path.getsize(src)), '', '', 'FAILED ' + os.path.basename(webm) + '.meta is there already beside ' + os.path.basename(meta)))
            say('   ' + name + ': ' + rows[-1][-1]); continue
        before = os.path.getsize(src)
        try:
            webm, ssim = convert_one(src, idle)
            if os.path.exists(meta): os.replace(meta, webm + '.meta')  # the GUID stays
            os.remove(src)
            rows.append((name, str(before), str(os.path.getsize(webm)), ssim, 'converted' + ('' if os.path.exists(webm + '.meta') else ' (no .meta: Unity gives it a new GUID)')))
        except RuntimeError as e:
            rows.append((name, str(before), '', '', 'FAILED ' + str(e)))
        say(f'   {name}: {before} -> {rows[-1][2] or "-"} SSIM {rows[-1][3] or "-"} {rows[-1][4]}')
    return rows


def main(argv):
    idle = '--idle' in argv
    report = argv[argv.index('--report') + 1] if '--report' in argv else None
    args = [a for i, a in enumerate(argv) if a != '--idle' and a != '--report' and (i == 0 or argv[i - 1] != '--report')]
    if len(args) != 1 or not os.path.isdir(args[0]):
        print('usage:to_webm.py <folder holding the .m4v clips> [--report <tsv>] [--idle]'); return 1
    clips = [os.path.join(d, f) for d, _, fs in os.walk(args[0]) for f in fs if f.lower().endswith('.m4v')]
    if not clips:
        print(f'no .m4v clips under {args[0]}: nothing to convert'); return 0
    try: require_tools()
    except ToolsMissing as e:
        print('to_webm: refused: ' + str(e)); return 2
    rows = convert_files(clips, idle)
    if report:
        with open(report, 'w', encoding='utf-8', newline='\n') as w:
            w.write('clip\tbytes_before\tbytes_after\tssim\tresult\n')
            for r in rows: w.write('\t'.join(r) + '\n')
    ok = [r for r in rows if r[4].startswith('converted')]
    print(f'videoclips converted={len(ok)} failed={len(rows) - len(ok)}; {sum(int(r[1]) for r in ok)} -> {sum(int(r[2]) for r in ok)} bytes')
    return 0 if len(ok) == len(rows) else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
