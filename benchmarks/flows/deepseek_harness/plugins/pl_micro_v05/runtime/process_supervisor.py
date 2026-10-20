"""Owned subprocess identities and orphan adoption for isolated PL episodes.

The three definitions below are preserved from the validated utility runner;
placement policies and experiment-directory dependencies are intentionally absent.
"""
import json
import os
from pathlib import Path

def process_identity(pid, procfs=Path('/proc')):
    try:
        stat = (procfs / str(pid) / 'stat').read_text()
        fields = stat[stat.rfind(')') + 2:].split()
        return {'pid': int(pid), 'state': fields[0], 'ppid': int(fields[1]),
                'pgid': int(fields[2]), 'sid': int(fields[3]), 'start_ticks': int(fields[19])}
    except (FileNotFoundError, ProcessLookupError, PermissionError, ValueError, IndexError):
        return None


def enable_subreaper():
    # A wrapper can die between native Popen and publishing started.json.
    # Adoption makes its orphaned descendants visible as our own children;
    # ownership never relies on an executable-name or global-process match.
    import ctypes
    libc = ctypes.CDLL(None, use_errno=True)
    if libc.prctl(36, 1, 0, 0, 0) != 0:  # PR_SET_CHILD_SUBREAPER
        raise OSError(ctypes.get_errno(), 'cannot enable owned-descendant adoption')


class OwnedProcesses:
    def __init__(self, root, wrapper_pid, owner_pid=None, procfs=Path('/proc')):
        self.root = Path(root)
        self.wrapper_pid = wrapper_pid
        self.owner_pid = os.getpid() if owner_pid is None else owner_pid
        self.procfs = Path(procfs)
        self.known = {}  # (pid, start_ticks), never a PID alone
        self.sessions = {}  # session leader -> its recorded start identity
        self.parse_errors = []
        self.ownership_errors = []
        self.signals = []
        self._seen_errors = set()
        initial = process_identity(wrapper_pid, self.procfs)
        if initial:
            self.remember(initial, 'owned Popen wrapper')

    def error(self, path, error, ownership=False):
        record = {'path': str(path), 'error': str(error)}
        key = (record['path'], record['error'], ownership)
        if key not in self._seen_errors:
            self._seen_errors.add(key)
            (self.ownership_errors if ownership else self.parse_errors).append(record)

    def remember(self, identity, reason):
        key = (identity['pid'], identity['start_ticks'])
        if key not in self.known:
            self.known[key] = {**identity, 'ownership_reason': reason}
        if identity['pid'] == identity['sid']:
            self.sessions[identity['sid']] = identity['start_ticks']

    def snapshot(self):
        return {int(p.name): identity for p in self.procfs.iterdir() if p.name.isdigit()
                if (identity := process_identity(int(p.name), self.procfs)) is not None}

    def refresh(self):
        snapshot = self.snapshot()
        # Preserve any currently matching known members, even after their
        # original parent or session leader exits.
        owned = {pid for pid, ticks in self.known
                 if pid in snapshot and snapshot[pid]['start_ticks'] == ticks}
        # This process runs no unrelated children during an arm. Subreaper
        # adoption plus ancestry therefore establishes positive ownership.
        parents = owned | {self.owner_pid}
        while True:
            additions = {pid for pid, value in snapshot.items()
                         if pid != self.owner_pid and value['ppid'] in parents and pid not in owned}
            if not additions:
                break
            for pid in additions:
                self.remember(snapshot[pid], 'wrapper descendant or adopted owned child')
            owned |= additions
            parents |= additions
        for stage in ('placement', 'measurement'):
            path = self.root / stage / 'started.json'
            if not path.exists():
                continue
            try:
                started = json.loads(path.read_text())
                pid = int(started['pid'])
                records = started['initial_group']
                leader = next(x for x in records if int(x['pid']) == pid)
                ticks = int(leader['start_ticks'])
                if pid <= 1 or ticks <= 0:
                    raise ValueError('invalid published native process identity')
                live_leader = snapshot.get(pid)
                if live_leader and live_leader['start_ticks'] != ticks:
                    self.error(path, 'published leader PID was reused; do not trust its current session', True)
                    continue
                # Frozen helper uses start_new_session=True. A surviving Linux
                # session retains its leader identity even after leader exit.
                self.sessions[pid] = ticks
                for published in records:
                    candidate = snapshot.get(int(published['pid']))
                    if candidate and candidate['start_ticks'] == int(published['start_ticks']):
                        self.remember(candidate, 'matching published native PID/start')
            except (OSError, ValueError, KeyError, TypeError, StopIteration) as error:
                self.error(path, error)
        for pid, value in snapshot.items():
            sid = value['sid']
            if sid not in self.sessions:
                continue
            leader = snapshot.get(sid)
            if leader and leader['start_ticks'] != self.sessions[sid]:
                continue
            self.remember(value, 'member of positively identified owned session')
        return self.live(snapshot)

    def live(self, snapshot=None):
        snapshot = self.snapshot() if snapshot is None else snapshot
        return [{**value, 'ownership_reason': self.known[(pid, value['start_ticks'])]['ownership_reason']}
                for pid, value in snapshot.items()
                if (pid, value['start_ticks']) in self.known and value['state'] != 'Z']

    def signal_live(self, sig):
        self.refresh()
        # Signal individually after a fresh identity check. Avoid killpg with a
        # possibly exited/reused leader or an unverified member.
        for target in sorted(self.live(), key=lambda x: x['pid'] == self.wrapper_pid):
            current = process_identity(target['pid'], self.procfs)
            matches = bool(current and current['start_ticks'] == target['start_ticks'] and current['state'] != 'Z')
            record = {'pid': target['pid'], 'start_ticks': target['start_ticks'],
                      'signal': int(sig), 'identity_rechecked': matches, 'sent': False}
            if matches:
                try:
                    os.kill(target['pid'], sig)
                    record['sent'] = True
                except ProcessLookupError:
                    pass
                except OSError as error:
                    self.error('signal:' + str(target['pid']), error, True)
            self.signals.append(record)

    def reap_adopted(self):
        for pid, ticks in tuple(self.known):
            if pid == self.wrapper_pid:
                continue  # Popen owns its wait status.
            value = process_identity(pid, self.procfs)
            if value and value['start_ticks'] == ticks and value['state'] == 'Z' and value['ppid'] == self.owner_pid:
                try:
                    os.waitpid(pid, os.WNOHANG)
                except (ChildProcessError, ProcessLookupError):
                    pass
