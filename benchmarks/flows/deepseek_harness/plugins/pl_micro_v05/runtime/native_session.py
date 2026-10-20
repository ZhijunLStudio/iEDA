"""One owned persistent iEDA Tcl interpreter, with explicit checked RPC replies."""
from pathlib import Path
import os
import re
import select
import signal
import subprocess
import time
import uuid
from common import desc, init_commands, native_env, pid_identity, save, canonical_commands, native_command, native_cpu


class NativeSession:
    def __init__(self, binary, design, work, config, deadline):
        self.work = Path(work)
        self.work.mkdir(parents=True, exist_ok=True)
        self.deadline = deadline
        self.started = time.monotonic()
        self.buffer = b''
        self.log = (self.work / 'native.log').open('wb')
        command=native_command(binary)
        self.proc = subprocess.Popen(command, cwd=self.work, env=native_env(), stdin=subprocess.PIPE,
                                     stdout=subprocess.PIPE, stderr=subprocess.STDOUT, start_new_session=True, bufsize=0)
        self.identity = pid_identity(self.proc.pid)
        self.log_identity = {'identity': self.identity, 'binary': str(binary), 'command':command,'native_cpu':native_cpu(), 'persistent': True}
        save(self.work / 'native-started.json', self.log_identity)
        helper = 'proc __agent_rpc {rid scripthex} {set script [binary decode hex $scripthex]; set rc [catch {uplevel #0 $script} msg opts]; puts "__AGENT_RPC__${rid}:${rc}:[binary encode hex $msg]"; flush stdout}\n'
        self.proc.stdin.write(helper.encode())
        self.proc.stdin.flush()
        try:
            self.call(init_commands(design, self.work, config), 'initialize')
        except BaseException:
            self.close(force=True)
            raise

    def cpu(self):
        try:
            stat = Path('/proc', str(self.proc.pid), 'stat').read_text()
            f = stat[stat.rfind(')') + 2:].split()
            return (int(f[11]) + int(f[12])) / os.sysconf('SC_CLK_TCK')
        except (OSError, ValueError, IndexError):
            return None

    def call(self, commands, label='command', timeout=None):
        import work_budget
        if work_budget.ACTIVE:
            work_budget.ACTIVE.check()
        commands = canonical_commands(commands, self.work)
        started = time.monotonic()
        cpu0 = self.cpu()
        rid = uuid.uuid4().hex
        command = '\n'.join(commands)
        encoded = command.encode().hex()
        self.proc.stdin.write(f'__agent_rpc {rid} {encoded}\n'.encode())
        self.proc.stdin.flush()
        until = min(self.deadline, started + timeout) if timeout is not None else self.deadline
        pattern = re.compile(b'__AGENT_RPC__' + rid.encode() + rb':(\d+):([0-9a-f]*)\r?\n')
        reply = None
        try:
            while time.monotonic() < until:
                if work_budget.ACTIVE:
                    work_budget.ACTIVE.check()
                match = pattern.search(self.buffer)
                if match:
                    reply = {'rc': int(match.group(1)), 'message': bytes.fromhex(match.group(2).decode()).decode(errors='replace')}
                    self.buffer = self.buffer[match.end():]
                    break
                ready, _, _ = select.select([self.proc.stdout], [], [], min(0.2, max(0, until - time.monotonic())))
                if not ready:
                    if self.proc.poll() is not None:
                        raise RuntimeError('native process exited before checked RPC result')
                    continue
                chunk = os.read(self.proc.stdout.fileno(), 65536)
                if not chunk:
                    raise RuntimeError('native output EOF before checked RPC result')
                self.log.write(chunk)
                self.log.flush()
                self.buffer += chunk
            if reply is None:
                raise TimeoutError('native RPC exceeded episode/action deadline: ' + label)
        except BaseException as exc:
            cpu1 = self.cpu()
            row = {'label': label, 'commands': commands, 'completed': False,
                   'error_class': type(exc).__name__, 'message': str(exc),
                   'wall_s': time.monotonic() - started,
                   'native_cpu_s': cpu1 - cpu0 if cpu1 is not None and cpu0 is not None else None}
            with (self.work / 'rpc-ledger.jsonl').open('a') as stream:
                import json
                stream.write(json.dumps(row) + '\n')
            # A timed-out GP must not continue spending CPU while the model
            # considers its next action. Kill this owned interpreter now.
            self.close(force=True)
            raise
        cpu1 = self.cpu()
        row = {'label': label, 'commands': commands, **reply, 'wall_s': time.monotonic() - started,
               'native_cpu_s': cpu1 - cpu0 if cpu1 is not None and cpu0 is not None else None}
        with (self.work / 'rpc-ledger.jsonl').open('a') as f:
            import json
            f.write(json.dumps(row) + '\n')
        if reply['rc']:
            raise RuntimeError('native Tcl error: ' + reply['message'])
        return row

    def close(self, force=False):
        cpu = self.cpu()
        signaled = False
        if self.proc.poll() is None:
            if force:
                signaled = True
                os.killpg(self.proc.pid, signal.SIGTERM)
            try:
                if not force:
                    self.proc.stdin.write(b'flow_exit\n')
                    self.proc.stdin.flush()
                self.proc.wait(timeout=1 if force else 3)
            except (OSError, subprocess.TimeoutExpired):
                signaled = True
                if self.proc.poll() is None:
                    os.killpg(self.proc.pid, signal.SIGTERM)
                try:
                    self.proc.wait(timeout=2)
                except subprocess.TimeoutExpired:
                    os.killpg(self.proc.pid, signal.SIGKILL)
                    self.proc.wait(timeout=2)
        self.log.close()
        row = {**self.log_identity, 'returncode': self.proc.returncode, 'cleanup_signal_used': signaled,
               'wall_s': time.monotonic() - self.started, 'native_cpu_s_sampled': cpu,
               'matching_process_live': pid_identity(self.proc.pid) == self.identity,
               'log': desc(self.work / 'native.log')}
        save(self.work / 'native-terminal.json', row)
        return row
