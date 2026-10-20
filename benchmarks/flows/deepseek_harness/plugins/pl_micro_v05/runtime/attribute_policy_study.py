"""Evidence-based failure accounting; hypotheses are not causal conclusions."""
import argparse
from collections import Counter
import json
from pathlib import Path
from common import ROOT, load, save, reference_gaps


def attribute(output):
    output=Path(output);output.mkdir(exist_ok=False,parents=True)
    plan=load(ROOT/'paired-plan.json');suite=load(ROOT/'suite.json');rows=[]
    for entry in plan['rule']+plan['agent']:
        root=ROOT/'episodes'/entry['id'];result=load(root/'result.json')if(root/'result.json').exists()else{}
        ledger=root/'tool-ledger.jsonl';events=[json.loads(s)for s in ledger.read_text().splitlines()if s.strip()]if ledger.exists()else[]
        proof_rows=[e['response'].get('proof',{})for e in events if e['request']['op']=='refine']
        errors=Counter(e['response'].get('error_class','InvalidPhysicalResult')for e in events if not e['response']['ok'])
        actions=Counter(e['request']['op']for e in events)
        def qualified(response):return bool(((response.get('assessment')or{}).get('surplus')or{}).get('qualified'))
        valid=[e['response']for e in events if e['response'].get('metrics',{}).get('valid')and qualified(e['response'])]
        from pl_backend import scalar_metrics
        target=scalar_metrics(load(ROOT/'references'/entry['design']/'inn/attempt-1/result.json'))
        period=suite['designs'][entry['design']]['clock_period_ns']
        def score(m):
            g=reference_gaps(m,target,period);return(g['worst'],g['sum'])
        best=min((score(e['metrics'])for e in valid),default=None)
        delivered=result.get('delivery');actual=score(delivered['metrics'])if delivered else None
        requests=root/'traces/requests.jsonl';rr=[json.loads(s)for s in requests.read_text().splitlines()if s.strip()]if requests.exists()else[]
        timing_updates=sum(p.read_text(errors='replace').count('Update netweight for timing improvement.')for p in(root/'native').glob('*/native.log'))
        rows.append({'episode':entry['id'],'design':entry['design'],'controller':entry.get('controller','agent'),
                     'normal_delivery':result.get('ok',False),'result_checks_failed':[k for k,v in result.get('checks',{}).items()if not v],
                     'tool_operations':dict(actions),'backend_errors':dict(errors),
                     'no_change_refinements':sum(e['response'].get('no_change')is True for e in events),
                     'cache_hits':result.get('work',{}).get('evaluation_cache_hits',0),
                     'refinement_accepted_swaps':sum(p.get('accepted_swaps',0)for p in proof_rows),
                     'refinement_cells_moved':sum(p.get('changed_count',0)for p in proof_rows),
                     'unqualified_measurements':sum(bool(e['response'].get('metrics',{}).get('valid'))and not qualified(e['response'])for e in events),
                     'best_measured_rank_diagnostic':best,'actual_delivered_rank':actual,
                     'delivered_worse_than_known_qualified_candidate':bool(best and actual and actual>best),
                     'API_wall_s':sum(r.get('wall_s',0)for r in rr),'total_wall_s':result.get('wall_s'),
                     'actual_work':result.get('work'),
                     'GP_internal_timing_weight_update_events':timing_updates,
                     'STA_budget_unit':'Explicit fresh evaluation attempts requested by the actor, not all internal timing propagation passes. GP/DP internal timing and initialization remain charged in physical CPU; GP updates are additionally counted from native logs.',
                     'interpretation':'Counts describe observed bottlenecks. Model choice, stopping, physical action limits and proxy limitations require separate counterfactual evidence.'})
    save(output/'failure-accounting.json',{'episodes':rows,'scope':'No seed pooling, no retrospective policy changes, no physical-floor or DAC claim.'})
    text=['Validation attribution ledger','',f'Episodes with a normal independently audited result flag: {sum(r["normal_delivery"]for r in rows)}/{len(rows)}.',
          f'Deliveries worse than a known qualified candidate under the frozen rank: {sum(r["delivered_worse_than_known_qualified_candidate"]for r in rows)}.',
          'Per-episode errors, no-ops, fresh measurements, work and API/wall costs are in failure-accounting.json.',
          'Incomplete audits or resource failures are technical failures, not evidence that the direction succeeds or fails.',
          'RUDY64 and HPWL-RC improvements do not establish routed congestion or signoff timing.',
          'If the agent loses after the frozen compute catchup, do not expand the current agent QoR claim. Physical-tool usefulness can still be reported separately.']
    (output/'REPORT.txt').write_text('\n'.join(text)+'\n')


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--output',required=True);attribute(parser.parse_args().output)
