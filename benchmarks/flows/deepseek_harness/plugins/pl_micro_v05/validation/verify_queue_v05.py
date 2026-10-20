"""Queue aggregation and partial progress; no native or model execution."""
import json
from pathlib import Path
import tempfile
import time
from unittest.mock import patch
import run_policy_study as queue

with tempfile.TemporaryDirectory(prefix='pl-queue-accounting-')as directory:
    root=Path(directory)
    plan={'rule':[{'id':'one'},{'id':'two'}],'agent':[],'execution_order':['one','two']}
    (root/'paired-plan.json').write_text(json.dumps(plan))
    observed=[]
    def worker(entry,agent):
        if entry['id']=='two':
            deadline=time.monotonic()+2
            while time.monotonic()<deadline and not(root/'cohort-progress.json').exists():time.sleep(.01)
            observed.append((root/'cohort-progress.json').exists())
        return {'id':entry['id'],'ok':True,'scope':'queue-only synthetic receipt, never an experimental result'}
    # Silence worker progress; the single emitted JSON is the check result.
    import contextlib,io
    with patch.object(queue,'ROOT',root),patch.object(queue,'worker',worker),patch('sys.argv',['queue','--workers','2']),contextlib.redirect_stdout(io.StringIO()):queue.main()
    result=json.loads((root/'cohort-result.json').read_text())
    checks={'partial_progress_published_before_other_job_finishes':observed==[True],
            'all_results_aggregated_once':result['ok']and result['completed']==result['total']==2 and set(result['results'])=={'one','two'},
            'queue_run_record_preserved':len(list((root/'cohort-runs').glob('*/result.json')))==1}
    value={'ok':all(checks.values()),'checks':checks,'native_runs':0,'API_requests':0}
print(json.dumps(value))
if not value['ok']:raise SystemExit(1)
