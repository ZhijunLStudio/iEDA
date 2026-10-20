#!/usr/bin/env python3
"""Read-only closeout of actual deliveries, costs and protocol completeness.

Run against an immutable materialized study. This never invokes a physical
tool, contacts a model, edits a result, or changes a controller decision.
"""
import argparse
import csv
import hashlib
import json
import math
import os
from pathlib import Path
import sys

AXES = ('hpwl_um', 'rudy_peak', 'rudy_overflow_sum', 'setup_wns_ns',
        'setup_tns_ns', 'hold_wns_ns', 'hold_tns_ns')
TOOLS = {'pl_observe', 'pl_start', 'pl_advance', 'pl_restore', 'pl_legalize',
         'pl_refine', 'pl_evaluate', 'pl_finish'}


def read(path, default=None):
    return json.loads(Path(path).read_text()) if Path(path).exists() else default


def digest(path):
    h = hashlib.sha256()
    with Path(path).open('rb') as stream:
        for block in iter(lambda: stream.read(1024 * 1024), b''):
            h.update(block)
    return h.hexdigest()


def lines(path):
    if not path.exists():
        return []
    # Only completed request records are written to this journal. During a
    # partial audit, the final in-flight append may not be readable yet.
    raw = path.read_text()
    return [json.loads(s) for s in raw.splitlines() if s.strip()] if raw.endswith('\n') else [json.loads(s) for s in raw.splitlines()[:-1] if s.strip()]


def request_cost(rows):
    tokens = {}
    for row in rows:
        # Anthropic-compatible start/delta usage is cumulative per request;
        # adding both messages would count input tokens twice.
        values = row.get('usage_events', [])
        for key in ('input_tokens', 'output_tokens', 'cache_creation_input_tokens', 'cache_read_input_tokens'):
            samples = [u[key] for u in values if isinstance(u.get(key), (int, float))]
            if samples:
                tokens[key] = tokens.get(key, 0) + max(samples)
    return {'API_attempts': len(rows),
            'gateway_forwarded_attempts': sum(r.get('forwarded_to_gateway') is True for r in rows),
            'API_failed_or_interrupted_attempts': sum(r.get('http_status') != 200 or bool(r.get('transport_error_class')) for r in rows),
            'API_wall_s': sum(r.get('wall_s', 0) for r in rows), **tokens}


def catalog_matches(root, request):
    expected = request.get('tool_schema_sha256')
    if not expected or len(expected) != 64 or any(c not in '0123456789abcdef' for c in expected):
        return False
    catalog = read(root / 'traces/tool-catalogs' / (expected + '.json'), {})
    tools = catalog.get('tools', [])
    actual = hashlib.sha256(json.dumps(tools, sort_keys=True, separators=(',', ':')).encode()).hexdigest()
    return actual == expected == catalog.get('sha256') and {t.get('name') for t in tools} == TOOLS


def extra_delivery_valid(study, entry, scalar_metrics, assess):
    """Check actual extra-controller output using its independent raw audit."""
    root = study / 'episodes' / entry['id']
    result = read(root / 'result.json', {})
    audit = read(study / 'audits' / entry['id'] / 'result.json', {})
    delivery = result.get('delivery')
    if not result.get('ok') or not audit.get('ok') or not delivery or not (root / 'final.def').is_file():
        return False
    fresh = audit.get('fresh', {}); metrics = scalar_metrics(fresh)
    identity = fresh.get('identity', {})
    final_sha = digest(root / 'final.def')
    inputs = read(study / 'suite.json')['designs'][entry['design']]
    if not (fresh.get('ok') and metrics.get('valid') and fresh.get('legality', {}).get('legalized')
            and identity.get('same_netlist') and identity.get('same_floorplan')
            and identity.get('left', {}).get('def_sha256') == digest(inputs['input_def'])
            and identity.get('right', {}).get('def_sha256') == final_sha
            and fresh.get('def', {}).get('sha256') == final_sha == delivery['def']['sha256']):
        return False
    if not all(isinstance(metrics.get(k), (int, float)) and math.isfinite(metrics[k]) and math.isclose(metrics[k], delivery['metrics'][k], rel_tol=1e-10, abs_tol=1e-6) for k in AXES):
        return False
    refs = [scalar_metrics(read(study / 'references' / entry['design'] / role / 'attempt-1/result.json')) for role in ('ieda', 'inn')]
    return assess(metrics, *refs)['qualified']


def inspect(study, workflow, output):
    study, workflow, output = (Path(p).resolve() for p in (study, workflow, output))
    # Import the frozen evaluator policy, rather than a newer working copy.
    os.environ['IEDA_STUDY_ROOT'] = str(study)
    sys.path.insert(0, str(study))
    from study_contract import verify_study
    from pl_backend import scalar_metrics
    from surplus import assess
    verify_study(study)
    plan, suite = read(study / 'paired-plan.json'), read(study / 'suite.json')
    entries = plan['rule'] + plan['agent']
    checks = {
        'plan_has_12_designs_and_72_unique_episodes': len(suite['designs']) == 12 and len(entries) == 72 and len({e['id'] for e in entries}) == 72,
        'three_agents_and_three_rules_per_design': all(sum(e['design'] == d for e in plan['agent']) == 3 and {e['controller'] for e in plan['rule'] if e['design'] == d} == {'coarse', 'fine', 'adaptive'} for d in suite['designs']),
        'fixed_Flash_max_native_DSH': plan.get('model') == 'deepseek-flash' and plan.get('effort') == 'max' and plan.get('tools_mode') == 'native' and plan.get('dsh_version') == '0.2.1-rc.2',
    }
    costs, audits, pending = [], [], []
    for entry in entries:
        identifier = entry['id']; root = study / 'episodes' / identifier
        receipt = read(study / 'attempt-receipts' / (identifier + '.json'), {})
        value = read(root / 'result.json', {})
        if not receipt:
            pending.append(identifier)
            continue
        work = value.get('work', {}); delivery = value.get('delivery')
        audit_path = study / 'audits' / identifier / 'result.json'
        independent = read(audit_path, {})
        budget = plan['arms'][entry['arm']]['budget']
        actual_checks = {}
        if delivery:
            candidate = read(root / 'legal-candidates' / delivery['candidate_id'] / 'result.json', {})
            fresh = independent.get('fresh', {})
            measured = scalar_metrics(fresh) if fresh else {}
            actual_checks['DEF_matches_selected_and_fresh_evidence'] = bool((root / 'final.def').is_file() and digest(root / 'final.def') == delivery['def']['sha256'] == candidate.get('def', {}).get('sha256') == fresh.get('def', {}).get('sha256'))
            actual_checks['fresh_measurement_valid'] = bool(fresh.get('ok') and measured.get('valid') and fresh.get('legality', {}).get('legalized'))
            identity = fresh.get('identity', {})
            actual_checks['exact_input_identity_and_floorplan'] = bool(identity.get('same_netlist') and identity.get('same_floorplan') and identity.get('left', {}).get('def_sha256') == digest(suite['designs'][entry['design']]['input_def']) and identity.get('right', {}).get('def_sha256') == delivery['def']['sha256'])
            actual_checks['all_seven_axes_reproduce'] = all(isinstance(measured.get(k), (int, float)) and isinstance(delivery['metrics'].get(k), (int, float)) and math.isfinite(measured[k]) and math.isclose(measured[k], delivery['metrics'][k], rel_tol=1e-10, abs_tol=1e-6) for k in AXES)
            refs = [scalar_metrics(read(study / 'references' / entry['design'] / role / 'attempt-1/result.json')) for role in ('ieda', 'inn')]
            actual_checks['frozen_delivery_envelope'] = bool(measured.get('valid') and assess(measured, *refs)['qualified'])
        requests = lines(root / 'traces/requests.jsonl')
        is_agent = entry in plan['agent']
        if is_agent and value:
            actual_checks['actual_model_effort_and_tools'] = bool(requests) and all(r.get('model') == 'deepseek-flash' and r.get('output_config') == {'effort': 'max'} and r.get('thinking') == {'type': 'enabled'} and set(r.get('tool_names', [])) == TOOLS and r.get('wire_tool_schemas_valid') is True for r in requests)
            actual_checks['actual_tool_catalog_hashes_reproduce'] = bool(requests) and all(catalog_matches(root, r) for r in requests)
            actual_checks['API_request_count_includes_failures'] = len(requests) == value.get('model_request_count') <= budget['model_requests']
        if value:
            actual_checks['physical_CPU_within_cap'] = 0 <= work.get('physical_cpu_s', math.inf) <= budget['physical_cpu_seconds']
            actual_checks['actual_GP_including_unpublished_upper_bound_within_cap'] = work.get('actual_gp_steps', 0) + work.get('unobserved_GP_reserved_steps', 0) <= budget['actual_gp_steps']
            actual_checks['trials_and_fresh_evaluations_within_caps'] = work.get('neighbor_trials_used', math.inf) <= budget['neighbor_trials'] and work.get('fresh_sta_used', math.inf) <= budget['fresh_sta']
            actual_checks['wall_within_cap'] = value.get('wall_s', math.inf) <= budget['wall_seconds']
            actual_checks['owned_processes_cleaned'] = not value.get('owned_survivors') and not value.get('ownership_errors') and not value.get('parse_errors')
        normal = bool(receipt.get('ok') and value.get('ok') and independent.get('ok') and delivery and all(actual_checks.values()))
        audit_cpu = independent.get('fresh', {}).get('terminal', {}).get('cpu_s')
        model_cost = request_cost(requests)
        if not is_agent:
            model_cost.update({k: 0 for k in ('input_tokens', 'output_tokens', 'cache_creation_input_tokens', 'cache_read_input_tokens')})
        costs.append({'episode': identifier, 'design': entry['design'], 'controller': entry.get('controller', 'agent'),
                      'normal': normal, 'actual_delivery': bool(delivery),
                      'physical_CPU_s': work.get('physical_cpu_s'), 'total_wall_s': value.get('wall_s'),
                      'preparation_wall_s': value.get('preparation_wall_s'), 'queue_wall_s': receipt.get('wall_s'),
                      'controller_tree_reaped_CPU_s': value.get('tree_reaped_cpu_s'),
                      'fresh_STA_attempts': work.get('fresh_sta_used'), 'actual_GP_steps': work.get('actual_gp_steps'),
                      'unpublished_GP_upper_bound': work.get('unobserved_GP_reserved_steps'),
                      'actual_neighbor_trials': work.get('neighbor_trials_used'), 'cache_hits': work.get('evaluation_cache_hits'),
                      'audit_native_CPU_s': audit_cpu, 'audit_wall_s': independent.get('audit_wall_s'), **model_cost})
        audits.append({'episode': identifier, 'normal': normal, 'has_delivery': bool(delivery), 'checks': actual_checks,
                       'result': str(root / 'result.json'), 'result_sha256': digest(root / 'result.json') if value else None,
                       'independent_audit': str(audit_path) if independent else None,
                       'independent_audit_sha256': digest(audit_path) if independent else None})
    checks.update(all_72_attempts_terminal=not pending,
                  every_actual_delivery_passes_fresh_identity_legality_and_sevenaxis=all(all(a['checks'].get(k) is True for k in ('DEF_matches_selected_and_fresh_evidence', 'fresh_measurement_valid', 'exact_input_identity_and_floorplan', 'all_seven_axes_reproduce', 'frozen_delivery_envelope')) for a in audits if a['has_delivery']),
                  all_36_rule_deliveries_normal=sum(c['normal'] for c in costs if c['controller'] != 'agent') == 36,
                  at_least_35_of_36_agent_deliveries_normal=sum(c['normal'] for c in costs if c['controller'] == 'agent') >= 35)
    reports = ('analysis-v1/all-deliveries.csv', 'analysis-v1/actual-cost-quality-curves.csv',
               'analysis-v1/quality-vs-physical-CPU.png', 'analysis-v1/quality-vs-physical-CPU.pdf',
               'analysis-v1/delivered-quality-vs-total-wall.png',
               'attribution-v1/failure-accounting.json', 'attribution-v1/REPORT.txt')
    checks['required_tables_curves_and_attribution_present'] = all((study / name).is_file() for name in reports)
    coverage_amendment = read(study.parent / 'protocol/post-main-required-checks.json', {})
    if coverage_amendment:
        supplementary = read(study.parent / 'audit/gp4-equivalence-summary.json', {})
        evidence = supplementary.get('cases', [])
        passed = supplementary.get('ok') is True and supplementary.get('kernel_sha256') == coverage_amendment['fixed_kernel_SHA']
        passed = passed and {e.get('design') for e in evidence} == {'gcd_nangate45_a', 'salsa20_sky130_a'} and len(evidence) == 2
        for item in evidence:
            proof = item.get('result', {})
            if not proof.get('path') or not Path(proof['path']).is_file():
                passed = False
                continue
            value = read(proof['path'], {})
            required = ('feedback_4_same_actual_iterations', 'feedback_4_same_raw_DEF', 'zero_GP_restore_exact_parent')
            passed = passed and digest(proof['path']) == proof.get('sha256') and value.get('ok') is True and value.get('design') == item.get('design') and all(value.get('checks', {}).get(k) is True for k in required)
        checks['supplementary_supported_feedback4_cadence_and_restore'] = passed
    recovery_plan = read(study.parent / 'protocol/lg-recovery-control-provenance.json', {})
    if recovery_plan:
        recovery = read(study.parent / 'audit/lg-recovery-control-summary.json', {})
        groups = recovery.get('results', [])
        complete = recovery.get('ok') is True and recovery.get('completed') == recovery.get('total') == 4
        complete = complete and len(groups) == 2 and {g.get('design') for g in groups} == {'aes', 'salsa20_sky130_a'}
        shadow_reproduced = complete
        for group in groups:
            records = {r['role']: r for r in group.get('cases', [])}
            complete = complete and set(records) == {'formal_original', 'original_shadow', 'recover'} and all(r.get('normal') is True for r in records.values())
            original, shadow = records.get('formal_original', {}), records.get('original_shadow', {})
            same_metrics = bool(original.get('metrics') and shadow.get('metrics')) and all(math.isclose(original['metrics'][k], shadow['metrics'][k], rel_tol=1e-10, abs_tol=1e-6) for k in AXES)
            shadow_reproduced = shadow_reproduced and same_metrics and bool(original.get('delivery_sha256')) and original.get('delivery_sha256') == shadow.get('delivery_sha256')
        checks['training_LG_recovery_controls_complete_and_audited'] = complete
        checks['original_fine_shadows_reproduce_DEF_and_seven_axes'] = shadow_reproduced
    main_decision = read(study / 'analysis-v1/decision.json', {})
    # The user requires individual-win catchup even if aggregate main quality
    # fails. The original driver covers the positive case; a rule-only
    # followup covers the negative case without adding model experiments.
    winners = main_decision.get('catchup_required', [])
    catchup_complete = bool(main_decision) and not winners
    if winners:
        extra = study.parent / 'catchup-v1'
        extra_plan = read(extra / 'paired-plan.json', {})
        extra_cohort = read(extra / 'cohort-result.json', {})
        catchup_complete = extra_cohort.get('ok') is True and extra_cohort.get('completed') == extra_cohort.get('total') == len(winners)
        catchup_complete = catchup_complete and extra_plan.get('agent') == [] and len(extra_plan.get('rule', [])) == len(winners)
        catchup_complete = catchup_complete and {e['design'] for e in extra_plan.get('rule', [])} == {w['design'] for w in winners}
        if catchup_complete:
            verify_study(extra)
            catchup_complete = all(extra_delivery_valid(extra, e, scalar_metrics, assess) for e in extra_plan['rule'])
    checks['all_individual_win_and_practical_gain_rule_catchups_completed'] = catchup_complete
    catchup = read(workflow / 'catchup-decision.json', {})
    negative_catchup = read(study.parent / 'unconditional-catchup-workflow-v1/catchup-decision.json', {})
    conclusion = 'validation_incomplete'
    if all(checks.values()) and main_decision:
        if not main_decision['main_quality_gate_passed']:
            conclusion = 'do_not_expand_current_agent_QoR_claim'
        elif not catchup:
            conclusion = 'pending_compute_catchup'
        elif not catchup['ok']:
            catchup_runs = read(study.parent / 'catchup-v1/cohort-result.json', {})
            if not catchup_runs.get('ok'):
                conclusion = 'validation_incomplete'
            else:
                conclusion = 'attribution_incomplete' if any(not r['CPU_caught_up'] for r in catchup['results']) else 'do_not_expand_current_agent_QoR_claim_after_catchup'
        else:
            ablations = read(study.parent / 'ablations-v1/cohort-result.json', {})
            conclusion = 'continue_with_larger_repeats_and_final_physical_validation' if ablations.get('completed') == ablations.get('total') == 12 else 'pending_twelve_conditional_ablations'
    output.mkdir(parents=True, exist_ok=False)
    keys = list(dict.fromkeys(k for row in costs for k in row))
    with (output / 'actual-costs.csv').open('x', newline='') as stream:
        writer = csv.DictWriter(stream, fieldnames=keys); writer.writeheader(); writer.writerows(costs)
    sums = {}
    for key in ('physical_CPU_s', 'controller_tree_reaped_CPU_s', 'total_wall_s', 'preparation_wall_s',
                'audit_native_CPU_s', 'audit_wall_s', 'API_attempts', 'gateway_forwarded_attempts',
                'API_failed_or_interrupted_attempts', 'API_wall_s', 'input_tokens', 'output_tokens'):
        samples = [c[key] for c in costs if isinstance(c.get(key), (int, float))]
        sums[key] = {'sum_known': sum(samples), 'measured_episodes': len(samples), 'unknown_episodes': len(costs) - len(samples)}
    summary = {'schema': 'ieda.pl-evidence-closeout.v1', 'checks': checks, 'completed_attempts': len(costs), 'pending': pending,
               'conclusion': conclusion, 'main_quality_gate': main_decision.get('main_quality_gate_passed'),
               'episodes': audits, 'cost_totals': sums,
               'scope': 'Main actual deliveries only; development and failed technical attempts remain in their original archives and are not main samples. RUDY64/HPWL-RC placement proxies. Technical/data failures establish incomplete validation, not failure of the research direction.',
               'cost_semantics': 'Physical CPU and controller-tree CPU overlap; do not add them. API time overlaps episode wall time. Audit native CPU/wall are additional and never fed back. Missing costs are unknown, not zero. Token usage takes per-request cumulative maxima, never sums start and delta twice.',
               'coverage_timing': coverage_amendment.get('timing_disclosure'),
               'recovery_control_scope': 'Four additional non-LLM training-only controls defined before any holdout controller started, comparing original shadows to GP continuation after early LG failure. Original72 and QoR thresholds remain unchanged. Shadow reproduction uses identical DEF and the same1e-6 absolute/1e-10 relative seven-axis tolerance as independent remeasurement.',
               'individual_win_compute_attribution': catchup or negative_catchup,
               'catchup_scope': 'Every median win/practical challenge gain is checked even when the aggregate main gate fails. Extra caps alone do not establish actual compute matching; unmatched work cannot earn an independent-strategy claim. Conditional model ablations still require the positive main gate.',
               'sources': {'plan_sha256': digest(study / 'paired-plan.json'), 'study_lock_sha256': digest(study / 'study-lock.json'), 'postprocessor_sha256': digest(__file__)}}
    (output / 'evidence-audit.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({'output': str(output), 'completed': len(costs), 'pending': len(pending), 'conclusion': conclusion}), flush=True)
    return summary


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--study', required=True); p.add_argument('--workflow', required=True); p.add_argument('--output', required=True)
    a = p.parse_args(); inspect(a.study, a.workflow, a.output)
