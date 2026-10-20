"""Episode-local physical CPU, real GP, neighbor-trial and STA accounting."""
import os
from pathlib import Path
import resource
import time

ACTIVE = None


class BudgetExhausted(RuntimeError):
    pass


class WorkBudget:
    def __init__(self, limits, deadline_unix=None):
        self.limits = limits
        self.cpu0 = time.process_time()
        child = resource.getrusage(resource.RUSAGE_CHILDREN)
        self.child0 = child.ru_utime + child.ru_stime
        self.fresh_sta = 0
        self.neighbor_trials = 0
        self.actual_gp_steps = 0
        self.unobserved_gp_reserved = 0
        self.cache_hits = 0
        self.attempts = 0
        self.cleanup_cpu_reserve_s=limits.get('physical_cleanup_cpu_seconds',10)
        self.physical_deadline_unix = (deadline_unix - limits.get('finalization_reserve_s', 180)) if deadline_unix else None

    def cpu(self):
        child = resource.getrusage(resource.RUSAGE_CHILDREN)
        total = time.process_time() - self.cpu0 + child.ru_utime + child.ru_stime - self.child0
        # A live native child has not yet entered RUSAGE_CHILDREN. Include it
        # once, then let wait()/rusage replace it after it is reaped.
        try:
            children = Path(f'/proc/{os.getpid()}/task/{os.getpid()}/children').read_text().split()
        except OSError:
            children = []
        for pid in children:
            try:
                text = Path('/proc', pid, 'stat').read_text()
                fields = text[text.rfind(')') + 2:].split()
                total += sum(int(fields[i]) for i in (11, 12, 13, 14)) / os.sysconf('SC_CLK_TCK')
            except (OSError, ValueError, IndexError):
                pass
        return total

    def check(self):
        if self.physical_deadline_unix is not None and time.time() >= self.physical_deadline_unix:
            raise BudgetExhausted('physical execution stopped at finalization reserve; explicitly deliver a measured candidate')
        if self.cpu() >= max(0.0, self.limits.get('physical_cpu_seconds', 3600) - self.cleanup_cpu_reserve_s):
            raise BudgetExhausted('physical CPU budget reached; reserve retained for cleanup/delivery')

    def reserve_sta(self):
        self.check()
        if self.fresh_sta >= self.limits.get('fresh_sta', self.limits.get('legalizations', 24)):
            raise BudgetExhausted('fresh STA budget exhausted')
        self.fresh_sta += 1  # failed attempts remain charged

    def trial(self):
        if self.neighbor_trials >= self.limits.get('neighbor_trials', 131072):
            raise BudgetExhausted('actual neighbor-trial budget exhausted')
        self.neighbor_trials += 1
        if self.neighbor_trials % 64 == 0:
            self.check()

    def view(self):
        return {'physical_cpu_s': self.cpu(), 'physical_cpu_cap_s': self.limits.get('physical_cpu_seconds', 3600),
                'physical_CPU_cleanup_reserve_s':self.cleanup_cpu_reserve_s,
                'physical_CPU_dispatch_stop_s':max(0,self.limits.get('physical_cpu_seconds',3600)-self.cleanup_cpu_reserve_s),
                'fresh_sta_used': self.fresh_sta, 'fresh_sta_cap': self.limits.get('fresh_sta', self.limits.get('legalizations', 24)),
                'neighbor_trials_used': self.neighbor_trials, 'neighbor_trials_cap': self.limits.get('neighbor_trials', 131072),
                'actual_gp_steps': self.actual_gp_steps, 'unobserved_GP_reserved_steps': self.unobserved_gp_reserved,
                'evaluation_cache_hits': self.cache_hits,
                'physical_attempts': self.attempts}
