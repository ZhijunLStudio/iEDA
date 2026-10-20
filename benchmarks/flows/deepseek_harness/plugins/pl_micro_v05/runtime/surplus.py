"""Explicit, baseline-anchored surplus envelope; no hidden winner selection."""
import math

AXES = ('hpwl_um','rudy_peak','rudy_overflow_sum','setup_wns_ns','setup_tns_ns','hold_wns_ns','hold_tns_ns')
HIGHER = set(AXES[3:])
POLICY = {
    'schema':'ieda.surplus-policy.v1', 'spend_fraction':0.9,
    'epsilon':{k:(0.001 if k in HIGHER else 0.000001) for k in AXES},
    'anchor':'frozen original iEDA legal endpoint, never an evolving parent',
    'weak_axis_rule':'no further deterioration beyond declared numerical/engineering epsilon',
    'met_timing_rule':'do not introduce negative setup/hold WNS or TNS if the original baseline met it',
    'selection':'Among qualified legal endpoints minimize worst positive normalized Inn gap, then sum; controller chooses.',
    'scope_limit':'Reported timing paths are a partial observation. Unreported cells have unknown slack, not proven surplus.',
    'timing_epsilon_note':'1ps for WNS, 0.001ns aggregate for TNS; cost metrics epsilon=1e-6 in reported units. Raw deltas retained.',
}


def assess(candidate, baseline, target):
    if candidate.get('valid') is False:
        return {'qualified':False,'reason':'invalid endpoint','violations':['invalid_endpoint']}
    if any(not isinstance(p.get(k),(int,float)) or isinstance(p.get(k),bool) or not math.isfinite(p[k])
           for p in (candidate,baseline,target) for k in AXES):
        return {'qualified':False,'reason':'complete finite measurements required','violations':['missing_metrics']}
    ledger={}; violations=[]
    for key in AXES:
        sign=-1 if key in HIGHER else 1
        base,ref,cur=(sign*p[key] for p in (baseline,target,candidate))
        surplus=max(0.,ref-base)
        budget=POLICY['spend_fraction']*surplus
        limit=base+budget
        met_timing=key in HIGHER and baseline[key]>=0
        if met_timing:limit=min(limit,0.)
        eps=POLICY['epsilon'][key]
        excess=max(0.,cur-limit)
        # Met setup/hold is a sign constraint, not waived by the 1ps comparison tolerance.
        fails=excess>eps or (met_timing and candidate[key]<0)
        if fails:violations.append(key)
        ledger[key]={'baseline':baseline[key],'target':target[key],'candidate':candidate[key],
            'baseline_advantage':surplus,'consumable_advantage':budget,'spent':max(0.,cur-base),
            'remaining':limit-cur,'limit':sign*limit,'higher_is_better':key in HIGHER,
            'epsilon':eps,'already_met_timing_protected':met_timing,'violation':fails,
            'delta_from_baseline':candidate[key]-baseline[key]}
    return {'qualified':not violations,'violations':violations,'ledger':ledger,
            'note':'Qualification permits bounded tradeoffs; it does not imply Pareto dominance or actual-route improvement.'}


def regressions(candidate, baseline, epsilon=1e-9):
    return [k for k in AXES if ((baseline[k]-candidate[k]) if k in HIGHER else (candidate[k]-baseline[k]))>epsilon]
