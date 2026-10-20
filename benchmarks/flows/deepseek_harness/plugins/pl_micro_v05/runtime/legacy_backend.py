#!/usr/bin/env python3
"""Bounded domain-only actor: immutable GP snapshots, RUDY observation and legal delivery."""
import argparse
import json
import math
import os
from pathlib import Path
import shutil
import socket
import sys
import time
import traceback
from common import ROOT, SUITE, desc, load, measure, save, sha, tq, init_commands, run_native, reference_gaps
from surplus import assess, POLICY
from physical_observation import observe_timing, cached_timing, compact, protected_scope, movement
from native_session import NativeSession
from rudy_adapter import direct_transaction,verify_native_grid
from legal_refinement import net_geometry, physical_evidence, refinement


def scalar_metrics(value):
    if not value or not value.get('ok'):
        return {'valid': False, 'reason': value.get('error') if value else 'not measured'}
    m = value.get('metrics', value)
    return {'valid': m.get('ok', False), 'hpwl_um': m.get('hpwl_um'),
            'rudy_peak': m.get('rudy', {}).get('rudy_utilization_max'),
            'rudy_overflow_sum': m.get('rudy', {}).get('rudy_overflow_util_sum'),
            **{k: m.get('timing', {}).get(k) for k in ('setup_wns_ns','setup_tns_ns','hold_wns_ns','hold_tns_ns')}}


class PlacementSession:
    def __init__(self, root):
        self.root = Path(root)
        self.plan = load(self.root / 'episode.json')
        self.suite = load(SUITE)
        self.design = self.suite['designs'][self.plan['design']]
        original=load(self.design['pl_config'])['PL']
        self.baseline_recipe={'start':{'steps':500,'target_density':original['GP']['Density']['target_density'],
            'target_overflow':original['GP']['Nesterov']['target_overflow'],'congestion_effort':0,'timing':bool(original['is_timing_effort'])},
            'advance':{'steps':500,'scope':'global','congestion_effort':0},'max_gp_iterations':original['GP']['Nesterov']['max_iter'],
            'legalize':{'run_dp':True},'seed':42,'instruction':'Continue paused GP snapshots until native termination or max_gp_iterations, then LG+DP. Tool defaults are not automatically the original per-case recipe.'}
        self.deadline = time.monotonic() + max(0, self.plan['deadline_unix'] - time.time())
        self.started = time.monotonic()
        self.native = None
        self.native_branch = None
        self.branches = {}
        self.nodes = {}
        self.legals = {}
        self.current = None
        self.finished = None
        self.refinements = 0
        self.decision_memory = load(ROOT/'experience.json')
        memory=self.decision_memory[self.plan['design']]
        if memory['input_sha256']!=sha(self.design['input_def']) or memory['solver_sha256']!=self.suite['solver']['sha256']:
            raise RuntimeError('experience provenance does not match the frozen input/kernel')
        for recipe in memory['recipes']:
            if sha(recipe['source_result']['path'])!=recipe['source_result']['sha256']:
                raise RuntimeError('experience evidence changed')
        self.stop_rejections = []
        self.observe_count = 0
        self.calls = 0
        self.starts = 0
        self.requested_steps = 0
        self.actual_steps = 0
        self.errors = []
        self.timing_observations = {}
        self.timing_attempts = 0
        self.cached_path_candidates = 0
        self.budget = self.plan['budget']
        self.terminal = False
        sys.path.insert(0,str(ROOT/'helpers'))
        import def_hpwl_eval
        self.hpwl_helper = def_hpwl_eval
        self.hpwl_macros, _ = def_hpwl_eval.parse_lef(Path(self.design['macro_lef']))
        self._persist()

    def _persist(self):
        save(self.root / 'backend-state.json', {'design': self.plan['design'], 'current': self.current,
             'finished': self.finished, 'starts': self.starts, 'calls': self.calls, 'requested_steps': self.requested_steps,
             'actual_steps': self.actual_steps, 'refinements':self.refinements,'stop_rejections':self.stop_rejections, 'nodes': self.nodes, 'legal_candidates': self.legals,
             'errors': self.errors, 'native_branch': self.native_branch,
             'timing_path_observation_attempts':self.timing_attempts,'path_candidates_captured_with_evaluation':self.cached_path_candidates,
             'timing_observations':{k:compact(v)for k,v in self.timing_observations.items()}})

    def _remaining(self):
        return max(0, self.deadline - time.monotonic())

    def close_native(self):
        if self.native:
            try:
                self.native.close()
            finally:
                self.native = None
                self.native_branch = None

    def _ensure_branch(self, branch):
        if self.native and self.native_branch == branch:
            return
        self.close_native()
        info = self.branches[branch]
        native_root = self.root / 'native' / f'{branch}-{time.time_ns()}'
        self.native = NativeSession(self.suite['solver']['path'], self.design, native_root,
                                    info['config'], self.deadline)
        self.native_branch = branch

    def _regions(self, directory, summary):
        rows = [[float(x) for x in line.split(',') if x.strip()] for line in (directory / 'rudy_util.csv').read_text().splitlines() if line.strip()]
        width = max(map(len, rows))
        height = len(rows)
        llx,lly,urx,ury = summary['region']
        # calRUDY writes CSV from highest physical Y down to zero. Convert
        # display rows back to physical bin coordinates before defining scopes.
        ranked = sorted(((v, x, height - 1 - csv_y) for csv_y,row in enumerate(rows) for x,v in enumerate(row)), reverse=True)
        selected = []
        for value,x,y in ranked:
            if any(abs(x-r['bin_x'])+abs(y-r['bin_y']) < 4 for r in selected):
                continue
            selected.append({'index':len(selected), 'utilization':value, 'bin_x':x,'bin_y':y,
                             'center_dbu':[round(llx+(x+.5)*(urx-llx)/width),round(lly+(y+.5)*(ury-lly)/height)]})
            if len(selected) == 8:
                break
        return selected, [width,height]

    def _snapshot(self, branch, parent, requested):
        work = self.native.work
        records = [json.loads(line) for line in (work / 'pl/gp_experiments.jsonl').read_text().splitlines() if line.strip()]
        record = records[-1]
        node_id = f'n{len(self.nodes):03d}'
        directory = self.root / 'snapshots' / node_id
        directory.mkdir(parents=True)
        cp = directory / 'checkpoint.json'
        shutil.copy2(work / 'pl/gp_session_checkpoint.json', cp)
        flags = load(cp)
        if flags.get('checkpoint_semantics') != 'live_instance_materialization_v2':
            raise RuntimeError('checkpoint semantics do not match the validated binary')
        if flags['current_iter'] != record['end_iteration']:
            raise RuntimeError('GP ledger/checkpoint iteration mismatch')
        # Accept only publishes; legalization occurs in an independent process.
        self.native.call(['placer_run_gp -mode accept', f'def_save -path {tq(directory / "raw.def")}',
                          f'run_congestion_eval -model rudy -bin_cnt_x 64 -bin_cnt_y 64 -eval_output_path {tq(directory)}'], 'publish-and-rudy')
        rudy = load(directory / 'congestion_result.json')
        assert rudy['model'] == 'rudy' and rudy['bin_cnt_x'] == rudy['bin_cnt_y'] == 64
        regions, grid = self._regions(directory, rudy)
        raw_hpwl, raw_nets, missing, units = self.hpwl_helper.parse_def(directory/'raw.def',self.hpwl_macros)
        if missing or units<=0:
            raise RuntimeError('raw DEF HPWL measurement has missing endpoints or invalid units')
        node = {'id':node_id, 'branch':branch, 'parent':parent, 'checkpoint':str(cp),
                'raw_def':str(directory / 'raw.def'), 'raw_def_sha256':sha(directory / 'raw.def'),
                'record':record, 'iteration':record['end_iteration'], 'executed_iterations':record['executed_iterations'],
                'overflow':record['overflow'], 'gp_hpwl_dbu':record['hpwl'], 'stop_reason':record.get('stop_reason'),
                'rudy_peak':rudy['rudy_utilization_max'], 'rudy_overflow_sum':rudy['rudy_overflow_util_sum'],
                'rudy_region':rudy['region'], 'rudy_grid':grid, 'hotspots':regions,
                'raw_def_hpwl_um':raw_hpwl/units,'raw_def_hpwl_nets':raw_nets,
                'solver_stopped':flags['stop_placement'],'solver_diverged':flags['is_diverged'],
                'overflow_target':load(self.branches[branch]['config'])['PL']['GP']['Nesterov']['target_overflow'],
                'requested_density':self.branches[branch]['density'],
                'effective_density':flags['config_state']['target_density'],
                'timing_enabled':self.branches[branch]['timing'],
                'congestion_effort':self.branches[branch].get('last_effort', self.branches[branch]['effort'])}
        node['scope'] = record.get('scope','global')
        node['scope_effect'] = record.get('scope_effect')
        self.actual_steps += record['executed_iterations']
        node['converged_by_overflow'] = node['overflow'] <= node['overflow_target'] and not node['solver_diverged']
        self.nodes[node_id] = node
        self.current = node_id
        save(directory / 'snapshot.json', node)
        return {'snapshot':self._node_view(node), 'hotspots':regions, 'budget':self._budget_view()}

    def _node_view(self, n):
        view = {k:n.get(k) for k in ('id','branch','parent','iteration','overflow','gp_hpwl_dbu','rudy_peak','rudy_overflow_sum','overflow_target','executed_iterations','congestion_effort','scope','scope_effect')}
        # Native stop_reason and stop_placement do not reliably signal overflow
        # convergence. Retain raw values in artifacts and expose one status.
        status = ('diverged' if n['solver_diverged'] else 'converged' if n['converged_by_overflow']
                  else 'stopped' if n['solver_stopped'] else 'paused')
        view['status'] = status
        view['can_advance'] = status == 'paused'
        view['valid_snapshot_actions'] = ['restore','legalize'] + (['advance'] if status == 'paused' else [])
        view.update({k:n.get(k)for k in ['requested_density','effective_density','timing_enabled']})
        view.update({k:n.get(k)for k in ['raw_def_hpwl_um','raw_def_sha256']})
        view['native_GP_HPWL_note'] = 'gp_hpwl_dbu is an optimizer diagnostic that may retain a previous value. raw_def_hpwl_um measures the actual current exported DEF, on the SAME geometry used for raw RUDY. Legalization can still change both.'
        view['density_adjusted_by_native'] = abs(n['requested_density']-n['effective_density'])>1e-6
        if view['density_adjusted_by_native']:
            view['density_note'] = ('Native legacy density0.8 aliases to0.6 unless utilization requires higher density; this is not a monotonic density knob.' if abs(n['requested_density']-.8)<1e-6 and n['effective_density']<.8-1e-6 else 'Native raised requested density to the utilization floor; lower requests can produce the SAME effective placement. Inspect effective settings before restarting.')
        return view

    def _budget_view(self):
        legal_costs = [v.get('native',{}).get('wall_s',0)+v.get('metrics',{}).get('terminal',{}).get('wall_s',0)for v in self.legals.values()if v.get('ok')]
        return {'remaining_wall_s':round(self._remaining(),2), 'finalization_reserve_s':self.budget['finalization_reserve_s'],
                'measured_legalization_plus_evaluation_wall_s':legal_costs,
                'calls_used':self.calls,'calls_cap':self.budget['tool_calls'],
                'starts_used':self.starts,'starts_cap':self.budget['starts'],
                'requested_gp_steps_used':self.requested_steps,'requested_gp_steps_cap':self.budget['requested_gp_steps'],
                'actual_gp_steps':self.actual_steps,'legalizations_used':len(self.legals),
                'timing_path_observation_attempts':self.timing_attempts,'timing_path_observation_cap':self.budget.get('timing_observations',8),'cached_legal_path_candidates':getattr(self,'cached_path_candidates',0),'legal_refinements_used':self.refinements,
                'legalizations_cap':self.budget['legalizations']}

    @staticmethod
    def _compact_assessment(value):
        return {k:v for k,v in value.items() if k!='ledger'} | {'remaining_by_axis':{k:v['remaining'] for k,v in value.get('ledger',{}).items()}}

    @staticmethod
    def _matches(metrics,target,engineering):
        from surplus import AXES,HIGHER
        if not metrics.get('valid'):return False
        for key in AXES:
            epsilon=POLICY['epsilon'][key]if engineering else 0.
            if key in HIGHER:
                if metrics[key]+epsilon<target[key]:return False
            elif metrics[key]>target[key]+epsilon:return False
        return True

    def state(self,include_memory=False):
        refs = {}
        for role in ('inn','ieda'):
            p = ROOT / 'references' / self.plan['design'] / role / 'attempt-1/result.json'
            refs[role] = scalar_metrics(load(p)) if p.exists() else {'valid':False,'reason':'reference not ready'}
        current = self.nodes.get(self.current)
        candidates = []
        for k,v in self.legals.items():
            metrics = scalar_metrics(v.get('metrics',{}))
            if not v['ok']:metrics['valid']=False
            candidates.append({'id':k,'from_snapshot':v['snapshot'],'stages':v['stages'],'run_dp':v['run_dp'],**metrics,
                               'surplus':self._compact_assessment(assess(metrics,refs['ieda'],refs['inn'])) if metrics.get('valid') else None,
                               'inn_positive_gaps':reference_gaps(metrics,refs['inn'],self.design['clock_period_ns']) if metrics.get('valid') and refs['inn'].get('valid') else None,
                               'timing_evidence_ready':k in self.timing_observations,
                               'Inn_targets_matched_exactly':self._matches(metrics,refs['inn'],False)if metrics.get('valid')else False,
                               'Inn_targets_matched_within_engineering_epsilon':self._matches(metrics,refs['inn'],True)if metrics.get('valid')else False})
        return {'design':self.plan['design'], 'cells':self.design['initial_identity']['components'],
                'pdk':self.design['pdk'], 'clock_period_ns':self.design['clock_period_ns'],
                'current':self._node_view(current) if current else None, 'hotspots':current['hotspots'] if current else [],
                'history':[{k:v for k,v in self._node_view(n).items()if k not in ('native_GP_HPWL_note','density_note','valid_snapshot_actions')}for n in list(self.nodes.values())[-4:]],
                'all_snapshot_ids':list(self.nodes),
                'legal_candidates':candidates,
                'references_numeric_only':refs, 'finished':self.finished, 'budget':self._budget_view(),
                'surplus_policy':POLICY,'baseline_reproduction_recipe':self.baseline_recipe, 'experiment_memory':self.decision_memory[self.plan['design']]if include_memory else {'available':True,'query':"pl_observe(view='memory')",'recipes':len(self.decision_memory[self.plan['design']]['recipes'])},
                'finish_contract':{'minimum_distinct_effective_GP_configs':3,'minimum_legal_refinements':2,'waivers':['all_Inn_gaps_within_engineering_tolerance','remaining_wall_below_reserve','no_eligible_scope_with_typed_evidence','all_evaluations_exhausted']},
                'timing_observations':{k:{field:v[field]for field in ('reported_setup_paths','reported_hold_paths','protected_cell_count','unknown_cell_count')}for k,v in self.timing_observations.items()},
                'notes':['Every GP step returns an immutable solver checkpoint and measured raw-DEF RUDY64.',
                         'GP HPWL is an optimizer diagnostic; compare delivery using legal-candidate HPWL and timing.',
                         'RUDY-region selects actual RUDY bins; density_hotspot is the old density-based scope.',
                         'Timing is geometric HPWL-RC pre-route estimation, not signoff; no EGR is run.',
                         'Legal evaluation captures paths in the same STA call. timing_evidence_ready permits immediate legal continuation; explicit path inspection is optional and uses the cached same-DEF evidence.']}

    def _legal_view(self, identifier):
        return next(c for c in self.state()['legal_candidates'] if c['id']==identifier)

    def _cache_legal_paths(self,identifier):
        legal=self.legals[identifier]
        if identifier in self.timing_observations:return True
        if not legal.get('ok')or not legal.get('metrics',{}).get('path_evidence'):return False
        try:
            node=self._geometry_node(identifier)
            obs=cached_timing(self.design,node,legal['metrics'],self.root/'timing-observations'/identifier)
            self.timing_observations[identifier]=obs;self.cached_path_candidates+=1
            legal['timing_evidence_captured_with_evaluation']=True
            return True
        except Exception as exc:
            legal['timing_evidence_error']=type(exc).__name__+': '+str(exc)
            return False

    def _geometry_node(self, identifier):
        if identifier in self.nodes:
            return self.nodes[identifier]
        legal=self.legals[identifier]
        if not legal['ok']:raise ValueError('legal candidate did not pass full measurement')
        directory=Path(legal['metrics']['terminal']['log']['path']).parent
        rudy=legal['metrics']['rudy'];hotspots,grid=self._regions(directory,rudy)
        return {'id':identifier,'raw_def':legal['def']['path'],'raw_def_sha256':legal['def']['sha256'],
                'hotspots':hotspots,'rudy_grid':grid,'rudy_region':rudy['region'],
                'rudy_peak':rudy['rudy_utilization_max']}

    def observe(self,args):
        if 'timing_paths'in args and not isinstance(args['timing_paths'],bool):
            raise ValueError('timing_paths must be boolean')
        if args.get('candidate_id') and args.get('snapshot_id'):raise ValueError('choose candidate_id OR snapshot_id')
        if args.get('view','summary')not in ('summary','memory'):raise ValueError('view must be summary/memory')
        self.observe_count+=1
        identifier=args.get('candidate_id') or args.get('snapshot_id') or self.current
        extra={}
        if identifier and (args.get('candidate_id')or args.get('snapshot_id')or args.get('timing_paths')):
            node=self._geometry_node(identifier)
            extra['observed_snapshot' if identifier in self.nodes else 'observed_candidate']=self._node_view(node)if identifier in self.nodes else self._legal_view(identifier)
            if args.get('timing_paths',False) and identifier not in self.timing_observations:
                if identifier in self.legals:self._cache_legal_paths(identifier)
            if args.get('timing_paths',False) and identifier not in self.timing_observations:
                if self.timing_attempts>=self.budget.get('timing_observations',8):
                    raise ValueError('fresh timing observation quota exhausted; existing observations remain readable')
                self.timing_attempts+=1
                obs=observe_timing(self.design,self.suite['solver']['path'],node,
                    self.root/'timing-observations'/identifier,max(.01,self._remaining()-1))
                self.timing_observations[identifier]=obs
            nets=net_geometry(node['raw_def'],self.hpwl_macros,self.hpwl_helper)
            extra['observed_geometry']={'id':identifier,**physical_evidence(node,nets,self.timing_observations.get(identifier))}
            if identifier in self.timing_observations:
                extra['observed_timing']={k:v for k,v in compact(self.timing_observations[identifier]).items()if k!='decision_paths'}
        return {**self.state(include_memory=self.observe_count==1 or args.get('view')=='memory'),**extra}

    def _steps(self, args):
        steps = args.get('steps',200)
        if isinstance(steps,bool) or not isinstance(steps,int) or not 1 <= steps <= 500:
            raise ValueError('steps must be an integer from 1 to 500; full accepted iterations')
        if self.requested_steps + steps > self.budget['requested_gp_steps']:
            raise ValueError('requested GP-step budget exhausted; failed requests do not execute')
        return steps

    def start(self, args):
        steps = self._steps(args)
        if self.starts >= self.budget['starts']:
            raise ValueError('start budget exhausted; resume an existing snapshot or finish')
        density = args.get('target_density',.6)
        overflow_target = args.get('target_overflow',.1)
        effort = args.get('congestion_effort',0)
        timing = args.get('timing',True)
        if isinstance(density,bool) or not isinstance(density,(int,float)) or not math.isfinite(density) or not .4 <= density <= .8:
            raise ValueError('target_density must be a finite number in [0.4,0.8]')
        if effort not in (0,3,4) or isinstance(effort,bool):
            raise ValueError('congestion_effort must be 0,3,4; both3/4 are RUDY-only, no EGR actions are exposed')
        if not isinstance(timing,bool):
            raise ValueError('timing must be boolean')
        if isinstance(overflow_target,bool) or not isinstance(overflow_target,(int,float)) or not .03 <= overflow_target <= .2:
            raise ValueError('target_overflow must be in [0.03,0.2]')
        branch = f'b{self.starts:02d}'
        self.starts += 1
        self.requested_steps += steps
        directory = self.root / 'branches' / branch
        config = load(self.design['pl_config'])
        config['PL']['num_threads'] = 1
        config['PL']['is_timing_effort'] = int(timing)
        config['PL']['is_congestion_effort'] = int(effort > 0)
        config['PL']['GP']['Density']['target_density'] = density
        config['PL']['GP']['Nesterov']['max_iter'] = 2000
        config['PL']['GP']['Nesterov']['target_overflow'] = overflow_target
        save(directory / 'pl_config.json',config)
        self.branches[branch] = {'config':str(directory/'pl_config.json'),'density':density,'effort':effort,'timing':timing}
        self._ensure_branch(branch)
        self.native.call([f'placer_run_gp -mode start -iterations {steps} -seed 42 -random_init 1 -congestion_effort {effort} -report_route_util 0 -report_top_n 64'], 'gp-start')
        return self._snapshot(branch,None,steps)

    def advance(self,args):
        steps = self._steps(args)
        node = self.nodes[args.get('snapshot_id',self.current)]
        if node['solver_stopped'] or node['solver_diverged'] or node['converged_by_overflow']:
            raise ValueError('selected GP snapshot cannot advance: '+self._node_view(node)['status']+'; legalize, restore another paused snapshot, or start a new branch')
        scope = args.get('scope','global')
        if scope not in ('global','rudy_region','density_hotspot','rudy_guarded'):
            raise ValueError('scope must be global, rudy_region, density_hotspot, or rudy_guarded')
        if 'congestion_effort' not in args:raise ValueError('congestion_effort is required explicitly: scope selects cells, not feedback objective')
        effort = args['congestion_effort']
        if effort not in (0,3,4) or isinstance(effort,bool):
            raise ValueError('congestion_effort must be 0,3,4')
        tail = '-scope global'
        selected_names=None;scope_details=None;observation=None
        if scope in ('rudy_region','rudy_guarded'):
            index = args.get('hotspot_index',0)
            radius = args.get('radius_bins',2)
            if not isinstance(index,int) or isinstance(index,bool) or not 0 <= index < len(node['hotspots']):
                raise ValueError('hotspot_index must refer to this snapshot hotspot list')
            if not isinstance(radius,int) or isinstance(radius,bool) or not 1 <= radius <= 6:
                raise ValueError('radius_bins must be an integer in [1,6]')
            hot = node['hotspots'][index]
            llx,lly,urx,ury = node['rudy_region'];nx,ny = node['rudy_grid']
            bounds = [round(llx+max(0,hot['bin_x']-radius)*(urx-llx)/nx),round(lly+max(0,hot['bin_y']-radius)*(ury-lly)/ny),
                      round(llx+min(nx,hot['bin_x']+radius+1)*(urx-llx)/nx),round(lly+min(ny,hot['bin_y']+radius+1)*(ury-lly)/ny)]
            tail = '-scope region -scope_region ' + tq(' '.join(map(str,bounds))) + ' -scope_halo_hops 1 -scope_halo_coeff 0.5'
            if scope=='rudy_guarded':
                observation=self.timing_observations.get(node['id'])
                if not observation:raise ValueError('rudy_guarded requires pl_observe(timing_paths=true,snapshot_id=...) on exactly this snapshot')
                selected_names,scope_details=protected_scope(node,observation,index,radius)
                tail='-scope instances -scope_instances '+tq(','.join(selected_names))+' -scope_halo_hops 0 -scope_halo_coeff 0 -scope_preserve_global_charge 1'
        elif scope == 'density_hotspot':
            tail = '-scope hotspot -scope_active_ratio 0.2 -scope_halo_hops 1 -scope_halo_coeff 0.5'
        self.requested_steps += steps
        self._ensure_branch(node['branch'])
        self.branches[node['branch']]['last_effort'] = effort
        self.native.call([f'placer_run_gp -mode resume -checkpoint {tq(node["checkpoint"])} -iterations {steps} -congestion_effort {effort} -report_route_util 0 -report_top_n 64 {tail}'], 'gp-resume-'+scope)
        result=self._snapshot(node['branch'],node['id'],steps)
        if selected_names is not None:
            child=self.nodes[self.current]
            proof=movement(node,child,selected_names,observation)
            detail={**scope_details,'targets':selected_names,'raw_movement_proof':proof,
                    'parent':node['id'],'child':child['id']}
            save(self.root/'snapshots'/child['id']/'guarded-scope.json',detail)
            result['guarded_scope']={k:v for k,v in detail.items()if k!='targets'}
            if not proof['ok']:raise RuntimeError('guarded scope write invariant failed; do not promote child; restore measured parent')
        return result

    def restore(self,args):
        node = self.nodes[args['snapshot_id']]
        self._ensure_branch(node['branch'])
        target = self.root / 'restores' / f'{self.calls:03d}.def'
        target.parent.mkdir(parents=True,exist_ok=True)
        self.native.call([f'placer_run_gp -mode restore -checkpoint {tq(node["checkpoint"])}',
                          'placer_run_gp -mode accept',f'def_save -path {tq(target)}'],'zero-step-restore')
        equal = sha(target) == node['raw_def_sha256']
        if not equal:
            raise RuntimeError('zero-step restore DEF differs from immutable snapshot; no optimization performed')
        self.current = node['id']
        return {'restored':node['id'],'zero_new_gp_steps':True,'raw_def_bytes_equal':equal,'state':self.state()}

    def legalize(self,args):
        run_dp = args.get('run_dp',True)
        if not isinstance(run_dp,bool):
            raise ValueError('run_dp must be boolean; false produces an independently checked LG-only candidate')
        if len(self.legals) >= self.budget['legalizations']:
            raise ValueError('legalization/evaluation budget exhausted; finish an existing legal candidate')
        node = self.nodes[args.get('snapshot_id',self.current)]
        identifier = f'l{len(self.legals):02d}'
        directory = self.root / 'legal-candidates' / identifier
        directory.mkdir(parents=True)
        legal = {'id':identifier,'snapshot':node['id'],'ok':False,'run_dp':run_dp,'stages':'LG+DP'if run_dp else'LG-only'}
        self.legals[identifier] = legal  # failed attempts count too
        try:
            config = Path(self.branches[node['branch']]['config'])
            commands = init_commands(self.design,directory/'placement',config,node['raw_def'])
            commands += ['placer_run_lg']
            if run_dp:commands += ['placer_run_dp']
            commands += [f'def_save -path {tq(directory/"placement.def")}']
            legal['native'] = run_native(self.suite['solver']['path'],directory/'placement',commands,timeout=max(.01,self._remaining()-1))
            if not legal['native']['ok']:
                raise RuntimeError('LG/DP did not complete')
            legal['metrics'] = measure(self.design,directory/'placement.def',directory/'evaluation',timeout=max(.01,self._remaining()-1),timing_paths=True)
            legal['ok'] = legal['metrics']['ok']
            legal['def'] = desc(directory/'placement.def')
            self._cache_legal_paths(identifier)
        except Exception as exc:
            legal['error'] = str(exc)
        save(directory/'result.json',legal)
        return {'candidate_id':identifier,'snapshot_id':node['id'],'ok':legal['ok'],
                'stages':legal['stages'],'run_dp':run_dp,
                'metrics':scalar_metrics(legal.get('metrics',{})),'error':legal.get('error'),
                'assessment':self._legal_view(identifier),'budget':self._budget_view()}

    def refine(self,args):
        if len(self.legals)>=self.budget['legalizations']:raise ValueError('evaluation quota exhausted')
        parent=self.legals[args['candidate_id']]
        if not parent['ok'] or sha(parent['def']['path'])!=parent['def']['sha256']:raise ValueError('legal parent invalid or changed')
        if args.get('objective') not in ('hpwl','rudy','timing','balanced'):raise ValueError('objective must be explicit: hpwl/rudy/timing/balanced')
        if args.get('scope','hotspot') not in ('hotspot','critical','global'):raise ValueError('scope must be hotspot/critical/global')
        if args.get('operator','local_reorder') not in ('row_opt','instance_swap','local_reorder','bin_opt','all','rudy_swap'):raise ValueError('unknown DP operator')
        for key,lo,hi in [('hotspot_index',0,7),('radius_bins',1,6),('strength',1,8)]:
            value=args.get(key,{'hotspot_index':0,'radius_bins':4,'strength':4}[key])
            if isinstance(value,bool) or not isinstance(value,int) or not lo<=value<=hi:raise ValueError(key+' outside allowed integer range')
        if not isinstance(args.get('protect_reported_timing',True),bool):raise ValueError('protect_reported_timing must be boolean')
        if parent['id'] not in self.timing_observations:self._cache_legal_paths(parent['id'])
        if parent['id'] not in self.timing_observations:raise ValueError('no same-DEF timing evidence; query candidate_id with timing_paths=true before refinement')
        if args.get('operator')=='rudy_swap':
            if args['objective']!='rudy' or args.get('scope','global')!='global':raise ValueError('rudy_swap requires objective=rudy and scope=global (or omit scope)')
            if args.get('wire_guard','both')not in ('none','cap','elmore','both'):raise ValueError('invalid wire_guard')
            if args.get('path_guard','critical')not in ('critical','critical_and_hold','all_reported'):raise ValueError('invalid path_guard')
            if not args.get('protect_reported_timing',True)and 'path_guard'in args:raise ValueError('path_guard conflicts with protect_reported_timing=false')
            for key,default,lo,hi in [('max_moves',8,1,32),('neighbor_trials',4096,256,32768)]:
                value=args.get(key,default)
                if isinstance(value,bool)or not isinstance(value,int)or not lo<=value<=hi:raise ValueError(key+' outside integer bounds')
        elif set(args)&{'max_moves','neighbor_trials','wire_guard','path_guard'}:raise ValueError('direct-search arguments require rudy_swap')
        identifier=f'l{len(self.legals):02d}';directory=self.root/'legal-candidates'/identifier
        directory.mkdir(parents=True)
        legal={'id':identifier,'snapshot':parent['snapshot'],'parent_candidate':parent['id'],'ok':False,
               'run_dp':True,'stages':'legal-ECO:'+args.get('operator','local_reorder'),'refinement_args':args}
        self.legals[identifier]=legal;self.refinements+=1
        try:
            node=self._geometry_node(parent['id']);obs=self.timing_observations[parent['id']]
            nets=net_geometry(parent['def']['path'],self.hpwl_macros,self.hpwl_helper)
            if args.get('operator')=='rudy_swap':
                path,proof=direct_transaction(self.design,parent,node,obs,self.state()['references_numeric_only'],args,directory/'transaction',self._remaining())
            else:
                if set(args)&{'max_moves','neighbor_trials','wire_guard','path_guard'}:raise ValueError('direct-search parameters require operator=rudy_swap')
                path,proof=refinement(self.design,self.suite['solver']['path'],parent['def']['path'],node,obs,nets,args,
                                      directory/'transaction',max(.01,self._remaining()-1))
            legal['native']=proof.get('native',{});legal['proof']={k:v for k,v in proof.items() if k not in ('selected_cells','native_stage','native')}
            legal['metrics']=measure(self.design,path,directory/'evaluation',timeout=max(.01,self._remaining()-1),timing_paths=True)
            legal['ok']=legal['metrics']['ok'];legal['def']=desc(path)
            if args.get('operator')=='rudy_swap' and legal['metrics']['terminal']['ok']:
                check=verify_native_grid(directory/'transaction',directory/'evaluation');legal['proof']['fresh_native_RUDY_check']=check
                legal['ok']=legal['ok']and check['ok']
            self._cache_legal_paths(identifier)
        except Exception as exc:legal['error']=type(exc).__name__+': '+str(exc)
        save(directory/'result.json',legal)
        child=scalar_metrics(legal.get('metrics',{}));before=scalar_metrics(parent['metrics'])
        return {'candidate_id':identifier,'parent_candidate':parent['id'],'ok':legal['ok'],'metrics':child,
                'delta_from_parent':{k:child[k]-before[k] for k in before if k!='valid'} if child.get('valid') else None,
                'proof':legal.get('proof'),'error':legal.get('error'),'assessment':self._legal_view(identifier),'budget':self._budget_view()}

    def finish(self,args):
        chosen = self.legals[args['candidate_id']]
        reason=args.get('stop_reason')
        if reason not in ('targets_matched','evidence_stagnation','quota_exhausted','time_reserve','no_eligible_scope'):
            raise ValueError('explicit stop_reason required: targets_matched/evidence_stagnation/quota_exhausted/time_reserve/no_eligible_scope')
        view=self.state();candidate=self._legal_view(args['candidate_id'])
        gaps=candidate.get('inn_positive_gaps') or {}
        near=candidate.get('Inn_targets_matched_within_engineering_epsilon',False)
        configs={(round(n['effective_density'],6),n['timing_enabled'],n['congestion_effort']) for n in self.nodes.values()}
        budget_done=len(self.legals)>=self.budget['legalizations']
        time_done=self._remaining()<=self.budget['finalization_reserve_s']
        no_scope=reason=='no_eligible_scope' and any('no eligible' in str(v.get('error','')) for v in self.legals.values())
        if not (near or budget_done or time_done or no_scope) and (len(configs)<3 or self.refinements<2):
            self.stop_rejections.append({'reason':reason,'distinct_configs':len(configs),'refinements':self.refinements})
            raise ValueError('finish premature under predeclared horizon: compare 3 effective GP configurations and try 2 legal refinements, unless targets matched, time reserve/quota reached, or typed no-eligible evidence')
        if not chosen['ok'] or not chosen.get('metrics',{}).get('ok'):
            raise ValueError('chosen candidate has not passed independent measurement/identity/placement legality')
        if sha(chosen['def']['path']) != chosen['def']['sha256']:
            raise RuntimeError('immutable measured candidate changed')
        view=self.state()
        qualified=next(c['surplus']for c in view['legal_candidates']if c['id']==args['candidate_id'])
        if not qualified or not qualified['qualified']:
            raise ValueError('candidate violates the frozen surplus envelope: '+str(qualified.get('violations')if qualified else 'missing metrics')+'; generate a qualified endpoint or reproduce the original default flow')
        shutil.copy2(chosen['def']['path'],self.root/'final.def')
        self.finished = {'candidate_id':args['candidate_id'],'snapshot_id':chosen['snapshot'],'def':desc(self.root/'final.def'),
                         'stages':chosen['stages'],'run_dp':chosen['run_dp'],
                         'metrics':scalar_metrics(chosen['metrics'])}
        self.finished['surplus']=qualified
        self.finished['stop_reason']=reason
        self.finished['stop_evidence']={'distinct_effective_configs':len(configs),'legal_refinements':self.refinements,'targets_matched':bool(near),'quota_exhausted':budget_done,'time_reserve':time_done}
        save(self.root/'delivery.json',self.finished)
        self.close_native()
        return {'finished':True,**self.finished,'budget':self._budget_view()}

    def handle(self,request):
        started = time.monotonic()
        self.calls += 1
        op = request.get('op')
        args = request.get('args') or {}
        try:
            if self._remaining() <= 0:
                raise TimeoutError('episode wall budget exhausted')
            if self.calls > self.budget['tool_calls']:
                raise ValueError('domain tool-call budget exhausted')
            if self.finished and op != 'observe':
                raise ValueError('delivery already finalized')
            methods = {'observe':self.observe,'start':self.start,'advance':self.advance,
                       'restore':self.restore,'legalize':self.legalize,'refine':self.refine,'finish':self.finish}
            if op not in methods:
                raise ValueError('unknown domain operation')
            allowed_args = {'observe':{'snapshot_id','candidate_id','timing_paths','view'},'start':{'steps','target_density','target_overflow','congestion_effort','timing'},
                            'advance':{'snapshot_id','steps','scope','congestion_effort','hotspot_index','radius_bins'},
                            'restore':{'snapshot_id'},'legalize':{'snapshot_id','run_dp'},'refine':{'candidate_id','operator','objective','scope','hotspot_index','radius_bins','strength','protect_reported_timing','max_moves','neighbor_trials','wire_guard','path_guard'},'finish':{'candidate_id','stop_reason'}}
            if not isinstance(args,dict) or set(args)-allowed_args[op]:
                raise ValueError('unknown arguments for '+str(op))
            value = {'ok':True,**methods[op](args)}
        except Exception as exc:
            error = {'op':op,'error_class':type(exc).__name__,'message':str(exc)[:700]}
            self.errors.append(error)
            value = {'ok':False,**error,'budget':self._budget_view(),'recoverable':'Inspect state, correct arguments, or select a saved snapshot; no hidden restart/fallback.'}
            with (self.root/'backend-errors.log').open('a') as f:
                traceback.print_exc(file=f)
        value['tool_wall_s'] = time.monotonic()-started
        self._persist()
        with (self.root/'tool-ledger.jsonl').open('a') as f:
            f.write(json.dumps({'request':request,'response':value})+'\n')
        return value


def serve(path):
    root = Path(path).resolve()
    actor = PlacementSession(root)
    server = socket.socket(socket.AF_UNIX,socket.SOCK_STREAM)
    sock = root/'backend.sock'
    if sock.exists():
        raise RuntimeError('backend socket already exists')
    server.bind(str(sock));server.listen(8);server.settimeout(.25)
    save(root/'backend-ready.json',{'pid':os.getpid(),'socket':str(sock)})
    try:
        while actor._remaining()>0 and not actor.terminal:
            try:conn,_=server.accept()
            except socket.timeout:continue
            with conn:
                conn.settimeout(max(.1,actor._remaining()))
                stream=conn.makefile('rb');line=stream.readline(65537)
                if len(line)>65536:response={'ok':False,'message':'request too large'}
                else:
                    try:
                        request=json.loads(line)
                        if request.get('op')=='__close':
                            actor.terminal=True
                            actor.close_native()
                            response={'ok':True,'closed':True}
                        else:response=actor.handle(request)
                    except Exception as exc:response={'ok':False,'message':str(exc)}
                try:conn.sendall((json.dumps(response)+'\n').encode())
                except (BrokenPipeError,ConnectionResetError):pass
    finally:
        actor.close_native();actor._persist();server.close();sock.unlink(missing_ok=True)


def client(path,request):
    root=Path(path).resolve()
    plan=load(root/'episode.json')
    with socket.socket(socket.AF_UNIX,socket.SOCK_STREAM) as conn:
        conn.settimeout(max(.1,plan['deadline_unix']-time.time()))
        conn.connect(str(root/'backend.sock'))
        conn.sendall((json.dumps(request)+'\n').encode())
        data=b''
        while not data.endswith(b'\n'):
            chunk=conn.recv(65536)
            if not chunk:break
            data+=chunk
    return json.loads(data)


if __name__=='__main__':
    parser=argparse.ArgumentParser()
    parser.add_argument('mode',choices=['serve','call'])
    parser.add_argument('--episode',required=True)
    args=parser.parse_args()
    if args.mode=='serve':serve(args.episode)
    else:
        try:response=client(args.episode,json.loads(sys.stdin.read()))
        except Exception as exc:response={'ok':False,'error_class':type(exc).__name__,'message':str(exc)}
        print(json.dumps(response,ensure_ascii=False))
