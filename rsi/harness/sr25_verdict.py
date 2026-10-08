import json, os, sys
from pathlib import Path
W = Path('/home/lizhijun/work/ieda-rsi')
ref = json.loads((W/'runs/four_arm.json').read_text())
designs = sorted(x for x in os.listdir(W/'runs/standingB') if (W/'runs/standingB'/x).is_dir())
seeds = [1000,1001,1002,1003]
def load(d, arm):
    out={}
    for s in seeds:
        for sub in ['seedcells','seedcells_sr25','seedcells_serial']:
            p = W/'runs'/sub/('%s_%s_s%d.json'%(arm,d,s))
            if p.exists():
                try:
                    c=json.loads(p.read_text())
                    if c.get('union') is not None: out[s]=c; break
                except Exception: pass
    return out
cur = {d: load(d,'cur') for d in designs}
sr  = {d: load(d,'sr25') for d in designs}
print('%-22s | %-16s | %-16s | %s' % ('design','current (4 seeds)','SR-25 (4 seeds)','note'))
nc=ns=0; gains=[]; regs=[]; npc=nps=0
for d in designs:
    R=ref['designs'][d]['arms']['ref']
    def fmt(arm_map):
        cells=[]; npass=0
        for s in seeds:
            c=arm_map.get(s)
            if not c: cells.append(' --  '); continue
            ok = c.get('pass_')
            npass += bool(ok)
            cells.append('%s%s' % ('P' if ok else '.', ''))
        return ''.join(cells), npass
    cs, cp = fmt(cur[d]); ss, sp = fmt(sr[d])
    npc += (cp==4); nps += (sp==4)
    for s in seeds:
        a=cur[d].get(s); b=sr[d].get(s)
        if a and b:
            if b.get('pass_') and not a.get('pass_'): gains.append('%s@%d'%(d,s))
            if a.get('pass_') and not b.get('pass_'): regs.append('%s@%d'%(d,s))
    measured_c = len(cur[d]); measured_s = len(sr[d])
    note=[]
    if measured_c < 4 or measured_s < 4:
        note.append('(incomplete: cur %d/4, sr25 %d/4 measured)' % (measured_c, measured_s))
    elif sp > cp: note.append('improved %d->%d' % (cp, sp))
    elif sp < cp: note.append('REGRESSED %d->%d' % (cp, sp))
    if note or cp or sp:
        print('%-22s | %-16s | %-16s | %s' % (d, '%s %d/4'%(cs,cp), '%s %d/4'%(ss,sp), ', '.join(note)))
print()
print('primary (every seed):  cur %d/15   sr25 %d/15' % (npc, nps))
tots_c = sum(len(cur[d]) and sum(1 for s in cur[d] if cur[d][s].get('pass_')) for d in designs)
tots_s = sum(len(sr[d]) and sum(1 for s in sr[d] if sr[d][s].get('pass_')) for d in designs)
ncell_c = sum(len(cur[d]) for d in designs); ncell_s = sum(len(sr[d]) for d in designs)
print('secondary:             cur %d/%d   sr25 %d/%d' % (tots_c, ncell_c, tots_s, ncell_s))
print()
print('gains  (sr25 PASS where cur failed): %d  %s' % (len(gains), ', '.join(gains) or '-'))
print('regress(sr25 fail where cur passed): %d  %s' % (len(regs), ', '.join(regs) or '-'))
