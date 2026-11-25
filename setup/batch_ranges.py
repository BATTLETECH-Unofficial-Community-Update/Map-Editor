#!/usr/bin/env python
"""KS1 probe: do static-batched renderers in an extracted scene still resolve to their sub-mesh range?

Read-only; text YAML only; no Unity.  Usage:
  py -3 batch_ranges.py <scene.unity> <mesh-dir> [--orig-dir <dir>] [--out <dir>] [--sample N]
  <mesh-dir>  folder holding the combined meshes ("Combined Mesh*.asset" + .meta)
  <orig-dir>  optional folder (Mesh/ of the extraction) with the original meshes, for the byte comparison
  --out       folder for the per-renderer table and the summary (default: current directory)

For every MeshRenderer with m_StaticBatchInfo.subMeshCount > 0:
  1. the renderer's MeshFilter names the combined mesh; firstSubMesh/subMeshCount index its sub-mesh table;
  2. the vertex range (firstVertex, vertexCount) is decoded from _typelessdata using the channel layout;
  3. the index range is read from m_IndexBuffer and must stay inside the vertex range;
  4. the decoded world-space AABB is compared with the sub-mesh's localAABB (a MeshRenderer carries no
     m_LocalAABB of its own: the sub-mesh descriptor is the recorded bound);
  5. the vertices are moved back by the inverse of the GameObject's local-to-world matrix and compared with an
     original mesh of the same vertex/index count where the extraction still has one;
  6. identical blocks after the inverse transform are grouped (dedup potential).
"""
import argparse, collections, hashlib, os, re, sys
import numpy as np

FMT = {0: ('<f4', 4), 1: ('<f2', 2), 2: ('u1', 1), 3: ('i1', 1), 4: ('<u2', 2), 5: ('<i2', 2),
       6: ('u1', 1), 7: ('i1', 1), 8: ('<u2', 2), 9: ('<i2', 2), 10: ('<u4', 4), 11: ('<i4', 4)}
NORM = {2: 255.0, 3: 127.0, 4: 65535.0, 5: 32767.0}
GUID_RE = re.compile(r'guid: ([0-9a-f]{32})')


def sha16(b):
    return hashlib.sha256(b).hexdigest()[:16]


# ---------------------------------------------------------------- scene
def parse_scene(path):
    data = open(path, 'rb').read()
    docs = data.split(b'\n--- !u!')
    gos, trs, mrs, mfs = {}, {}, {}, {}
    for d in docs[1:]:
        nl = d.index(b'\n')
        head = d[:nl].decode()
        cls, rest = head.split(' &', 1)
        cls = int(cls)
        if cls not in (1, 4, 23, 33) or 'stripped' in rest:
            continue
        fid = int(rest.split()[0])
        t = d[nl:].decode('utf-8', 'replace')
        if cls == 1:
            gos[fid] = dict(name=re.search(r'm_Name: (.*)', t).group(1).strip(),
                            layer=int(re.search(r'm_Layer: (\d+)', t).group(1)))
        elif cls == 4:
            v = lambda k, n: [float(x) for x in re.search(r'%s: \{%s\}' % (k, ', '.join(n + ': ([^,}]+)' for n in 'xyzw'[:len(n)])), t).groups()]
            trs[fid] = dict(go=int(re.search(r'm_GameObject: \{fileID: (-?\d+)', t).group(1)),
                            q=v('m_LocalRotation', 'xyzw'), p=v('m_LocalPosition', 'xyz'), s=v('m_LocalScale', 'xyz'),
                            father=int(re.search(r'm_Father: \{fileID: (-?\d+)', t).group(1)))
        elif cls == 23:
            m = re.search(r'm_StaticBatchInfo:\s+firstSubMesh: (\d+)\s+subMeshCount: (\d+)', t)
            mrs[fid] = dict(go=int(re.search(r'm_GameObject: \{fileID: (-?\d+)', t).group(1)),
                            first=int(m.group(1)), count=int(m.group(2)),
                            mats=GUID_RE.findall(t.split('m_StaticBatchInfo')[0]),
                            root=int(re.search(r'm_StaticBatchRoot: \{fileID: (-?\d+)', t).group(1)),
                            enabled=int(re.search(r'm_Enabled: (\d)', t).group(1)))
        else:
            mfs[fid] = dict(go=int(re.search(r'm_GameObject: \{fileID: (-?\d+)', t).group(1)),
                            guid=(GUID_RE.search(t) or [None, None])[1])
    return gos, trs, mrs, mfs


def trs_matrix(q, p, s):
    x, y, z, w = q
    n = x * x + y * y + z * z + w * w
    if n > 0:
        x, y, z, w = (c / n ** 0.5 for c in (x, y, z, w))
    R = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                  [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                  [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])
    M = np.eye(4)
    M[:3, :3] = R * np.array(s)[None, :]
    M[:3, 3] = p
    return M


def world_matrices(trs):
    local = {i: trs_matrix(t['q'], t['p'], t['s']) for i, t in trs.items()}
    cache = {}

    def get(i):
        chain = []
        while i not in cache:
            chain.append(i)
            f = trs[i]['father']
            if f == 0 or f not in trs:
                cache[i] = None
                break
            i = f
        for j in reversed(chain):
            par = cache[trs[j]['father']] if trs[j]['father'] in cache else None
            cache[j] = local[j] if par is None else par @ local[j]
        return cache[chain[0]] if chain else cache[i]
    return {i: get(i) for i in trs}


# ---------------------------------------------------------------- mesh
class Mesh:
    def __init__(self, path):
        self.path = path
        txt = open(path, 'r', encoding='utf-8', errors='replace').read()
        self.name = re.search(r'm_Name: (.*)', txt).group(1).strip("' ")
        sub = txt.split('  m_SubMeshes:\n', 1)[1].split('\n  m_Shapes:', 1)[0]
        self.subs = []
        for m in re.finditer(r'firstByte: (\d+)\s+indexCount: (\d+)\s+topology: (\d+)\s+baseVertex: (-?\d+)\s+firstVertex: (\d+)\s+'
                             r'vertexCount: (\d+)\s+localAABB:\s+m_Center: \{x: ([^,]+), y: ([^,]+), z: ([^}]+)\}\s+'
                             r'm_Extent: \{x: ([^,]+), y: ([^,]+), z: ([^}]+)\}', sub):
            g = m.groups()
            self.subs.append(dict(fb=int(g[0]), ic=int(g[1]), topo=int(g[2]), bv=int(g[3]), fv=int(g[4]), vc=int(g[5]),
                                  c=np.array([float(x) for x in g[6:9]]), e=np.array([float(x) for x in g[9:12]])))
        self.index_format = int(re.search(r'm_IndexFormat: (\d+)', txt).group(1))
        self.compressed = int(re.search(r'm_MeshCompression: (\d+)', txt).group(1))
        vd = txt.split('  m_VertexData:\n', 1)[1].split('\n  m_CompressedMesh:', 1)[0]
        self.vcount = int(re.search(r'm_VertexCount: (\d+)', vd).group(1))
        ch = re.findall(r'- stream: (\d+)\s+offset: (\d+)\s+format: (\d+)\s+dimension: (\d+)', vd.split('m_Channels:', 1)[1].split('m_DataSize')[0])
        self.channels = [tuple(int(v) for v in c) for c in ch]
        m = re.search(r'_typelessdata: ([0-9a-f]*)', vd)
        self.raw = bytes.fromhex(m.group(1)) if m else b''
        ib = re.search(r'm_IndexBuffer: ([0-9a-f]*)', txt)
        self.ibuf = bytes.fromhex(ib.group(1)) if ib else b''
        self.bounds = None
        m = re.search(r'm_LocalAABB:\s+m_Center: \{x: ([^,]+), y: ([^,]+), z: ([^}]+)\}\s+m_Extent: \{x: ([^,]+), y: ([^,]+), z: ([^}]+)\}', txt)
        if m:
            g = [float(x) for x in m.groups()]
            self.bounds = (np.array(g[:3]), np.array(g[3:]))
        # stream layout: streams in order, each vcount * stride, start aligned to 16
        nstream = 1 + max((c[0] for c in self.channels if c[3] & 0xF), default=0)
        self.stride = [0] * nstream
        for s, off, f, d in self.channels:
            d &= 0xF
            if d:
                self.stride[s] = max(self.stride[s], off + d * FMT[f][1])
        self.stream_off, pos = [], 0
        for s in range(nstream):
            self.stream_off.append(pos)
            pos += self.vcount * self.stride[s]
            pos = (pos + 15) & ~15
        self._cache = {}

    def channel(self, idx):
        """-> float32 array (vcount, dim) or None; unorm/snorm normalised."""
        if idx in self._cache:
            return self._cache[idx]
        s, off, f, d = self.channels[idx]
        d &= 0xF
        if not d or not self.raw:
            self._cache[idx] = None
            return None
        dt, sz = FMT[f]
        buf = np.frombuffer(self.raw, dtype=np.uint8, count=self.vcount * self.stride[s], offset=self.stream_off[s])
        buf = buf.reshape(self.vcount, self.stride[s])[:, off:off + d * sz]
        a = np.ascontiguousarray(buf).view(dt).reshape(self.vcount, d).astype(np.float32)
        if f in NORM:
            a = a / NORM[f]
            if f in (3, 5):
                a = np.maximum(a, -1.0)
        self._cache[idx] = a
        return a

    def raw_rows(self, a, b):
        """raw bytes of vertices [a,b) over all streams, as one (n, total) uint8 array"""
        parts = []
        for s, st in enumerate(self.stride):
            buf = np.frombuffer(self.raw, dtype=np.uint8, count=self.vcount * st, offset=self.stream_off[s]).reshape(self.vcount, st)
            parts.append(buf[a:b])
        return np.concatenate(parts, axis=1)

    def indices(self, sub):
        dt = np.uint32 if self.index_format else np.uint16
        sz = 4 if self.index_format else 2
        return np.frombuffer(self.ibuf, dtype=dt, count=sub['ic'], offset=sub['fb']).astype(np.int64) + sub['bv']


def aabb(v):
    lo, hi = v.min(0), v.max(0)
    return (lo + hi) / 2, (hi - lo) / 2


def transform_dirs(m3, d):
    return d @ m3.T


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('scene')
    ap.add_argument('mesh_dir')
    ap.add_argument('--orig-dir')
    ap.add_argument('--out', default='.')
    ap.add_argument('--sample', type=int, default=20)
    ap.add_argument('--shift', type=int, default=0, help='positive control: read the range this many sub-meshes late (must fail)')
    ap.add_argument('--tol', type=float, default=1e-3, help='AABB tolerance in world units')
    a = ap.parse_args()
    os.makedirs(a.out, exist_ok=True)

    gos, trs, mrs, mfs = parse_scene(a.scene)
    go2tr = {t['go']: i for i, t in trs.items()}
    go2mf = {m['go']: i for i, m in mfs.items()}
    W = world_matrices(trs)

    # combined meshes by guid
    comb = {}
    for f in sorted(os.listdir(a.mesh_dir)):
        if f.startswith('Combined') and f.endswith('.asset'):
            g = GUID_RE.search(open(os.path.join(a.mesh_dir, f + '.meta')).read()).group(1)
            comb[g] = Mesh(os.path.join(a.mesh_dir, f))
            comb[g].file = f
    orig_files = {}
    if a.orig_dir:
        for f in sorted(os.listdir(a.orig_dir)):
            if f.endswith('.asset') and not f.startswith('Combined'):
                orig_files[f] = os.path.join(a.orig_dir, f)

    batched = {i: m for i, m in mrs.items() if m['count'] > 0}
    print(f'MeshRenderers {len(mrs)}  batched {len(batched)}  MeshFilters {len(mfs)}  combined meshes {len(comb)}', file=sys.stderr)

    # index originals by (vertexCount, total indexCount)
    oidx = collections.defaultdict(list)
    if orig_files:
        for f, p in orig_files.items():
            with open(p, 'r', encoding='utf-8', errors='replace') as fh:
                t = fh.read()
            if '_typelessdata: ' not in t:
                continue
            m = re.search(r'm_VertexCount: (\d+)', t)
            ics = [int(x) for x in re.findall(r'indexCount: (\d+)', t.split('  m_Shapes:', 1)[0])]
            if m:
                oidx[(int(m.group(1)), sum(ics))].append(f)
        print(f'original meshes indexed: {sum(len(v) for v in oidx.values())} in {len(oidx)} (vc,ic) keys', file=sys.stderr)
    ocache = {}

    def get_orig(f):
        if f not in ocache:
            ocache[f] = Mesh(os.path.join(a.orig_dir, f))
        return ocache[f]

    rows = []
    per_mesh = collections.defaultdict(lambda: dict(renderers=0, subs=0, verts=0, idx=0, bytes=0))
    per_root = collections.Counter()
    blocks = []  # for dedup
    first_fail = None
    for rid in sorted(batched):
        r = batched[rid]
        go = gos.get(r['go'], {})
        mf = mfs.get(go2mf.get(r['go']))
        st = []
        cm = comb.get(mf['guid']) if mf else None
        row = dict(go=r['go'], name=go.get('name', '?'), rid=rid, first=r['first'], count=r['count'])
        if cm is None:
            row.update(mesh='-', status='NO-COMBINED-MESH(mf=%s)' % (mf and mf['guid']))
            rows.append(row)
            first_fail = first_fail or row
            continue
        row['mesh'] = cm.file
        per_root[r['root']] += 1
        if r['first'] + a.shift + r['count'] > len(cm.subs):
            row['status'] = 'RANGE-OUT-OF-TABLE'
            rows.append(row)
            first_fail = first_fail or row
            continue
        subs = cm.subs[r['first'] + a.shift:r['first'] + a.shift + r['count']]
        # vertex ranges (union) and index sanity
        verts_idx = np.concatenate([np.arange(s['fv'], s['fv'] + s['vc']) for s in subs])
        ic = sum(s['ic'] for s in subs)
        okidx = True
        for s in subs:
            ix = cm.indices(s)
            if len(ix) and (ix.min() < s['fv'] or ix.max() >= s['fv'] + s['vc']):
                okidx = False
        pos = cm.channel(0)[verts_idx].astype(np.float64)
        ctr, ext = aabb(pos)
        # sub-mesh recorded bound: union of the sub-mesh AABBs
        lo = np.min([s['c'] - s['e'] for s in subs], axis=0)
        hi = np.max([s['c'] + s['e'] for s in subs], axis=0)
        rc, re_ = (lo + hi) / 2, (hi - lo) / 2
        d_aabb = float(max(np.abs(ctr - rc).max(), np.abs(ext - re_).max()))
        row.update(vc=len(verts_idx), ic=ic, nsub=len(subs), idx_in_range=int(okidx), d_aabb_world=d_aabb)
        # inverse transform
        Wm = W.get(go2tr.get(r['go']))
        if Wm is None:
            row['status'] = 'NO-TRANSFORM'
            rows.append(row)
            first_fail = first_fail or row
            continue
        det = np.linalg.det(Wm[:3, :3])
        row['det'] = det
        try:
            Wi = np.linalg.inv(Wm)
        except np.linalg.LinAlgError:
            row['status'] = 'SINGULAR'
            rows.append(row)
            first_fail = first_fail or row
            continue
        lp = pos @ Wi[:3, :3].T + Wi[:3, 3]
        lctr, lext = aabb(lp)
        row['local_ext'] = float(lext.max())
        # float32 world positions (<~1e3 m) carry ~1e-4 m error; the inverse scale maps it to local units
        row['tol_local'] = float(2e-4 * np.abs(Wi[:3, :3]).sum(1).max())
        status = 'OK' if (okidx and d_aabb <= a.tol) else ('IDX-OUT' if not okidx else 'AABB-MISMATCH')
        row['status'] = status
        if status != 'OK':
            first_fail = first_fail or row
        # bytes
        per_mesh[cm.file]['renderers'] += 1
        per_mesh[cm.file]['subs'] += len(subs)
        per_mesh[cm.file]['verts'] += len(verts_idx)
        per_mesh[cm.file]['idx'] += ic
        stride_total = sum(cm.stride)
        per_mesh[cm.file]['bytes'] += len(verts_idx) * stride_total + ic * (4 if cm.index_format else 2)
        blocks.append((rid, cm, subs, verts_idx, lp, Wi, tuple(r['mats']), row))
        # original lookup
        cands = oidx.get((len(verts_idx), ic), []) if len(subs) == 1 else []
        row['orig_cands'] = len(cands)
        best = None
        for f in cands:
            om = get_orig(f)
            if om.compressed or om.vcount != len(verts_idx) or om.channel(0) is None:
                continue
            op = om.channel(0).astype(np.float64)
            dd = float(np.abs(op - lp).max())
            if best is None or dd < best[0]:
                best = (dd, f, om)
        if best:
            dd, f, om = best
            row['orig'] = f
            row['orig_max_pos_diff'] = dd
            row['orig_match'] = int(dd <= row['tol_local'])
            # index equality (relative to firstVertex)
            ixc = cm.indices(subs[0]) - subs[0]['fv']
            ixo = np.concatenate([om.indices(s) for s in om.subs]) if om.subs else np.array([])
            row['orig_idx_equal'] = int(len(ixc) == len(ixo) and bool((ixc == ixo).all()))
            # uv0 (channel 4) exact, normals after transform
            uc, uo = cm.channel(4)[verts_idx] if cm.channel(4) is not None else None, om.channel(4)
            if uc is not None and uo is not None and uc.shape == uo.shape:
                row['orig_uv0_max_diff'] = float(np.abs(uc - uo).max())
                row['orig_uv0_half_equal'] = int(np.array_equal(uo.astype(np.float16).astype(np.float32), uc))  # original float32 rounded to half
                row['orig_uv0_bytes_equal'] = int(cm.channels[4][2] == om.channels[4][2] and
                                                 cm.raw_rows(subs[0]['fv'], subs[0]['fv'] + subs[0]['vc'])[:, cm.channels[4][1]:cm.channels[4][1] + FMT[cm.channels[4][2]][1] * 2].tobytes() ==
                                                 np.ascontiguousarray(om.raw_rows(0, om.vcount)[:, om.channels[4][1]:om.channels[4][1] + FMT[om.channels[4][2]][1] * 2]).tobytes())
            nc, no = cm.channel(1), om.channel(1)
            if nc is not None and no is not None:
                n_loc = nc[verts_idx].astype(np.float64) @ Wm[:3, :3]  # n_local ~ M^T n_world (inverse-transpose)
                n_loc /= np.maximum(np.linalg.norm(n_loc, axis=1, keepdims=True), 1e-12)
                no_n = no.astype(np.float64) / np.maximum(np.linalg.norm(no, axis=1, keepdims=True), 1e-12)
                row['orig_normal_max_diff'] = float(np.abs(n_loc - no_n).max())

    # ------------------------------------------------ dedup (after the inverse transform)
    groups = collections.defaultdict(list)
    for rid, cm, subs, vi, lp, Wi, mats, row in blocks:
        ix = np.concatenate([cm.indices(s) - s['fv'] for s in subs]) if len(subs) == 1 else None
        uv = (sha16(np.ascontiguousarray(cm.raw_rows(subs[0]['fv'], subs[0]['fv'] + subs[0]['vc'])[:, cm.channels[4][1]:cm.channels[4][1] + 4]).tobytes())
              if len(subs) == 1 and cm.channels[4][3] else 'x')
        topo = (len(vi), len(subs), sha16(ix.astype(np.int32).tobytes()) if ix is not None else 'multi', uv)
        wp = cm.channel(0)[vi].astype(np.float64)
        groups[topo].append((rid, lp, wp, mats, sum(s['ic'] for s in subs), cm, row['tol_local']))
    n_blocks = len(blocks)
    total_bytes = sum(v['bytes'] for v in per_mesh.values())

    def dedup(use_world):
        """unique (positions, materials) blocks and their bytes; positions equal within two float32-world errors"""
        n_pos = n_mat = nbytes = 0
        for mem in groups.values():
            reps, seen = [], []
            for rid, lp, wp, mats, ic, cm, tl in mem:
                p, tol = (wp, 4e-4) if use_world else (lp, 2 * tl)
                if not any(np.abs(rp - p).max() <= tol for rp in reps):
                    reps.append(p)
                if not any(m == mats and np.abs(rp - p).max() <= tol for rp, m in seen):
                    seen.append((p, mats))
                    nbytes += len(p) * sum(cm.stride) + ic * (4 if cm.index_format else 2)
            n_pos += len(reps)
            n_mat += len(seen)
        return n_pos, n_mat, nbytes
    uniq_pos, uniq_pos_mat, dedup_bytes_pos = dedup(False)
    ctl_pos, ctl_mat, ctl_bytes = dedup(True)

    # ------------------------------------------------ outputs
    cols = ['go', 'name', 'rid', 'mesh', 'first', 'count', 'nsub', 'vc', 'ic', 'idx_in_range', 'd_aabb_world', 'det', 'local_ext', 'tol_local',
            'orig_cands', 'orig', 'orig_max_pos_diff', 'orig_match', 'orig_idx_equal', 'orig_uv0_max_diff', 'orig_uv0_bytes_equal', 'orig_uv0_half_equal',
            'orig_normal_max_diff', 'status']
    # `rows` holds only the early failures; the blocks' rows are the same dict objects, so gather them all
    allrows = {r['rid']: r for r in rows}
    for b in blocks:
        allrows[b[0]] = b[7]
    with open(os.path.join(a.out, 'ranges.tsv'), 'w', encoding='utf-8', newline='') as fh:
        fh.write('\t'.join(cols) + '\n')
        for rid in sorted(allrows):
            r = allrows[rid]
            fh.write('\t'.join(('%.6g' % r[c]) if isinstance(r.get(c), float) else str(r.get(c, '')) for c in cols) + '\n')

    stat = collections.Counter(r['status'] for r in allrows.values())
    S = []
    S.append(f'scene renderers {len(mrs)}; batched (subMeshCount>0) {len(batched)}; status {dict(stat)}')
    S.append(f'batched renderers per static-batch root (m_StaticBatchRoot fileID): {dict(per_root)}')
    S.append('per combined mesh: file, renderers, sub-meshes, vertices, indices, bytes (vertex+index of the renderers\' ranges), whole-mesh vertexCount/subMeshes/data bytes')
    for f in sorted(per_mesh):
        cm = next(c for c in comb.values() if c.file == f)
        v = per_mesh[f]
        S.append(f'  {f}\trend {v["renderers"]}\tsubs {v["subs"]}/{len(cm.subs)}\tverts {v["verts"]}/{cm.vcount}\tidx {v["idx"]}\tbytes {v["bytes"]}\tmesh data {len(cm.raw)}+{len(cm.ibuf)}')
    S.append(f'combined meshes referenced by no batched renderer: {[c.file for c in comb.values() if c.file not in per_mesh]}')
    S.append(f'total range bytes {total_bytes}; total combined-mesh bytes {sum(len(c.raw) + len(c.ibuf) for c in comb.values())}')
    bad = [r for r in allrows.values() if r['status'] != 'OK']
    S.append(f'non-OK renderers: {len(bad)}; first: {first_fail}')
    dm = [r['d_aabb_world'] for r in allrows.values() if 'd_aabb_world' in r]
    S.append(f'world AABB diff (decoded vertices vs sub-mesh localAABB): max {max(dm):.3g}, p99 {np.percentile(dm, 99):.3g}, median {np.median(dm):.3g}, tol {a.tol}')
    om = [r for r in allrows.values() if 'orig' in r]
    S.append(f'renderers with an original mesh of equal (vertex, index) count found: {sum(1 for r in allrows.values() if r.get("orig_cands"))}; compared {len(om)}; '
             f'position match {sum(r["orig_match"] for r in om)}; index-equal {sum(r["orig_idx_equal"] for r in om)}; '
             f'uv0 equal after float32->half {sum(r.get("orig_uv0_half_equal", 0) for r in om)}; uv0 raw bytes equal {sum(r.get("orig_uv0_bytes_equal", 0) for r in om)}')
    if om:
        S.append(f'orig pos diff (local units): max {max(r["orig_max_pos_diff"] for r in om):.3g}, median {np.median([r["orig_max_pos_diff"] for r in om]):.3g}')
    S.append(f'dedup: blocks {n_blocks}; unique by (topology+uv0 bytes, positions within 2x the float32-world error) {uniq_pos}; also by material list {uniq_pos_mat}; '
             f'deduplicated range bytes {dedup_bytes_pos} ({dedup_bytes_pos / max(total_bytes, 1):.3f} of {total_bytes})')
    S.append(f'dedup: topology groups {len(groups)} (same vertex count, index bytes, uv0 bytes); positions agree in every group when unique == groups ({uniq_pos} vs {len(groups)})')
    S.append(f'dedup control (world positions, no inverse transform): unique {ctl_pos}, by material {ctl_mat}, bytes {ctl_bytes} (must be larger than the inverse-transform figure)')
    open(os.path.join(a.out, 'summary.txt'), 'w', encoding='utf-8').write('\n'.join(S) + '\n')
    print('\n'.join(S))

    # 20 sample (evenly spaced among renderers with an original)
    if om:
        om.sort(key=lambda r: r['rid'])
        step = max(len(om) // a.sample, 1)
        sample = om[::step][:a.sample]
        with open(os.path.join(a.out, 'sample20.tsv'), 'w', encoding='utf-8', newline='') as fh:
            c2 = ['rid', 'name', 'orig', 'vc', 'ic', 'orig_max_pos_diff', 'local_ext', 'orig_idx_equal', 'orig_uv0_max_diff', 'orig_uv0_bytes_equal', 'orig_uv0_half_equal', 'orig_normal_max_diff']
            fh.write('\t'.join(c2) + '\n')
            for r in sample:
                fh.write('\t'.join(('%.6g' % r[c]) if isinstance(r.get(c), float) else str(r.get(c, '')) for c in c2) + '\n')


if __name__ == '__main__':
    main()
