"""v0.5 proposal/evaluation split; original physical algorithms remain frozen."""
import argparse,copy,json,shutil,sys,time,traceback
from pathlib import Path
import legacy_backend as legacy
from common import ROOT,load,save,desc,sha,measure,init_commands,run_native,tq
from evaluation_cache import EvaluationCache
from legal_refinement import refinement,net_geometry,physical_evidence
from physical_observation import coordinates
from rudy_adapter import direct_transaction,verify_native_grid
from surplus import AXES
import work_budget
scalar_metrics=legacy.scalar_metrics

class PlacementSession(legacy.PlacementSession):
    def __init__(self,root):
        from study_contract import verify_study
        verify_study()
        episode=load(Path(root)/'episode.json')
        self.variant=episode.get('variant','autonomous')
        self.work=work_budget.WorkBudget(episode['budget'],episode.get('deadline_unix'))
        work_budget.ACTIVE=self.work
        self.cache=EvaluationCache();self.proposals={};self.evaluation_attempts=0;self.action_coverage=[]
        super().__init__(root)
    def _persist(self):
        super()._persist()
        value=load(self.root/'backend-state.json')
        value.update(schema='ieda.pl-session.v05',proposals=self.proposals,work=self.work.view(),evaluation_attempts=self.evaluation_attempts,action_coverage=self.action_coverage)
        save(self.root/'backend-state.json',value)
    def _budget_view(self):
        view=super()._budget_view();view.update(self.work.view())
        view.update(legal_candidates_count=len(self.legals),legalizations_used=self.work.fresh_sta,legalizations_cap=self.work.limits.get('fresh_sta',24))
        journal=self.root/'frontend-calls.jsonl'
        frontend=len(journal.read_text().splitlines())if journal.exists()else 0
        view.update(calls_used=max(self.calls,frontend),backend_calls_received=self.calls,frontend_model_calls_attempted=frontend)
        return view
    def _steps(self,args):
        steps=args.get('steps',200)
        if isinstance(steps,bool) or not isinstance(steps,int) or not 1<=steps<=500:raise ValueError('steps must be integer1..500')
        if self.actual_steps+self.work.unobserved_gp_reserved+steps>self.budget.get('actual_gp_steps',self.budget['requested_gp_steps']):raise work_budget.BudgetExhausted('actual GP budget cannot cover this batch')
        return steps
    def _gp_call(self,method,args):
        before_steps,before_requested=self.actual_steps,self.requested_steps
        try:
            return getattr(super(),method)(args)
        except BaseException:
            if self.native and self.native.proc.poll() is not None:
                self.close_native()
            if self.actual_steps==before_steps and self.requested_steps>before_requested:
                # An interrupted native call may not publish an iteration
                # ledger. Reserve its requested upper bound; never label it
                # as observed work or turn a failed call into free compute.
                self.work.unobserved_gp_reserved+=self.requested_steps-before_requested
            self.work.actual_gp_steps=self.actual_steps
            raise
    def start(self,args):return self._gp_call('start',args)
    def advance(self,args):return self._gp_call('advance',args)
    def _snapshot(self,*args):
        value=super()._snapshot(*args);self.work.actual_gp_steps=self.actual_steps;value['budget']=self._budget_view();return value
    @staticmethod
    def _proposal_view(p):
        return {k:p.get(k) for k in ('id','parent_candidate','snapshot','stages','def','no_change','accepted_prefix','predicted_metrics','measured_candidate','error')}
    def state(self,include_memory=False):
        value=super().state(include_memory)
        value.update(schema='ieda.pl-state.v05',proposal_count=len(self.proposals),recent_proposals=[self._proposal_view(p)for p in list(self.proposals.values())[-16:]])
        value['finish_contract']={'measured_candidate_required':True,'qualified_required':True,'stop_scope':'tested parents/actions only; no inferred global physics floor'}
        from policy_menu import shared_menu
        value['shared_action_menu']=shared_menu(self.decision_memory[self.plan['design']],self.baseline_recipe)if include_memory else {'query':'pl_observe(view=memory)'}
        value['capabilities']={'evaluation':['immediate','defer'],'DP_max_selected_cells':True,'rudy_accepted_prefixes':True,'reported_paths_are_partial':True,'cache':'episode-local complete measurement fingerprint'}
        return value
    def _new_proposal(self,path,**metadata):
        identifier=f'p{len(self.proposals):04d}';self.proposals[identifier]={'id':identifier,'def':desc(path),**metadata}
        save(self.root/'proposals'/identifier/'proposal.json',self.proposals[identifier]);return identifier
    @staticmethod
    def _evaluation_mode(args):
        mode=args.get('evaluation','immediate')
        if mode not in ('immediate','defer'):raise ValueError('evaluation must be immediate/defer')
        return mode
    def legalize(self,args):
        mode=self._evaluation_mode(args);run_dp=args.get('run_dp',True)
        if not isinstance(run_dp,bool):raise ValueError('run_dp must be boolean')
        node=self.nodes[args['snapshot_id']];directory=self.root/'transactions'/f'lg{self.work.attempts:04d}'
        self.work.attempts+=1;config=Path(self.branches[node['branch']]['config'])
        commands=init_commands(self.design,directory/'placement',config,node['raw_def'])
        path=directory/'placement.def';commands+=['placer_run_lg']+(['placer_run_dp']if run_dp else[])+[f'def_save -path {tq(path)}']
        terminal=run_native(self.suite['solver']['path'],directory/'placement',commands,timeout=max(.01,self._remaining()-1))
        if not terminal['ok']:raise RuntimeError('LG/DP did not complete')
        identifier=self._new_proposal(path,snapshot=node['id'],stages='LG+DP'if run_dp else'LG-only',run_dp=run_dp,native=terminal,no_change=False)
        return self.evaluate({'proposal_id':identifier})if mode=='immediate'else{'proposal_id':identifier,'measured':False,'deliverable':False,'budget':self._budget_view()}
    def _validate_refine(self,args):
        common={'candidate_id','evaluation','objective','operator','scope','protect_reported_timing'}
        direct={'max_moves','neighbor_trials','wire_guard','path_guard'};dp={'strength','hotspot_index','radius_bins','max_selected_cells'}
        if args.get('objective')not in ('hpwl','rudy','timing','balanced'):raise ValueError('invalid objective')
        operator=args.get('operator','local_reorder');is_direct=operator=='rudy_swap'
        if operator not in ('rudy_swap','row_opt','instance_swap','local_reorder','bin_opt','all'):raise ValueError('invalid operator')
        if set(args)-common-(direct if is_direct else dp):raise ValueError('arguments mix incompatible DP/direct-search branches')
        if not isinstance(args.get('protect_reported_timing',True),bool):raise ValueError('protect_reported_timing must be boolean')
        if is_direct:
            if args['objective']!='rudy' or args.get('scope','global')!='global':raise ValueError('rudy_swap requires rudy/global')
            if args.get('wire_guard','both')not in ('none','cap','elmore','both'):raise ValueError('invalid wire_guard')
            if args.get('path_guard','critical')not in ('critical','critical_and_hold','all_reported'):raise ValueError('invalid path_guard')
            if not args.get('protect_reported_timing',True) and 'path_guard'in args:raise ValueError('path_guard requires protection=true')
            bounds=[('max_moves',8,1,32),('neighbor_trials',4096,256,32768)]
        else:
            if args.get('scope','hotspot')not in ('hotspot','critical','global'):raise ValueError('invalid DP scope')
            bounds=[('strength',4,1,8),('hotspot_index',0,0,7),('radius_bins',4,1,6)]
            if 'max_selected_cells'in args:bounds.append(('max_selected_cells',64,1,self.design['initial_identity']['components']))
        for key,default,lo,hi in bounds:
            value=args.get(key,default)
            if isinstance(value,bool)or not isinstance(value,int)or not lo<=value<=hi:raise ValueError(key+' outside integer bounds')
    def refine(self,supplied):
        args=dict(supplied)
        if 'action'in args:
            action=args.pop('action')
            if not isinstance(action,dict)or set(action)&set(args):raise ValueError('action must have no duplicate top-level fields')
            args.update(action)
        mode=self._evaluation_mode(args);self._validate_refine(args);parent=self.legals[args['candidate_id']]
        if not parent['ok']or sha(parent['def']['path'])!=parent['def']['sha256']:raise ValueError('measured immutable parent required')
        if parent['id']not in self.timing_observations:self._cache_legal_paths(parent['id'])
        if parent['id']not in self.timing_observations:raise ValueError('same-DEF timing paths unavailable')
        directory=self.root/'transactions'/f't{self.refinements:04d}';self.refinements+=1;self.work.attempts+=1
        node=self._geometry_node(parent['id']);obs=self.timing_observations[parent['id']]
        if args.get('operator')=='rudy_swap':
            if self.budget.get('neighbor_trials',131072)-self.work.neighbor_trials<args.get('neighbor_trials',4096):raise work_budget.BudgetExhausted('requested trial cap exceeds remaining actual quota')
            path,proof=direct_transaction(self.design,parent,node,obs,self.state()['references_numeric_only'],args,directory,self._remaining())
        else:
            nets=net_geometry(parent['def']['path'],self.hpwl_macros,self.hpwl_helper)
            path,proof=refinement(self.design,self.suite['solver']['path'],parent['def']['path'],node,obs,nets,args,directory,max(.01,self._remaining()-1))
        common={'snapshot':parent['snapshot'],'parent_candidate':parent['id'],'run_dp':True,'stages':'legal-ECO:'+args.get('operator','local_reorder'),'refinement_args':args,'native':proof.get('native',{})}
        prefixes=[]
        if args.get('operator')=='rudy_swap':
            for prefix in load(directory/'prefixes.json'):
                partial=copy.deepcopy(proof);partial.update(candidate_sha256=prefix['publication']['candidate_sha256'],changed_count=prefix['publication']['changed_cells'],accepted_swaps=prefix['index'])
                prefixes.append(self._new_proposal(prefix['def_path'],**common,proof=partial,transaction=prefix['transaction'],accepted_prefix=prefix['index'],predicted_metrics=prefix['move']['predicted_metrics'],no_change=False))
        identifier=self._new_proposal(path,**common,proof=proof,transaction=str(directory),no_change=sha(path)==parent['def']['sha256'])
        result={'proposal_id':identifier,'prefix_proposal_ids':prefixes,'proof':{k:v for k,v in proof.items()if k not in ('selected_cells','native_stage','native')},'no_change':self.proposals[identifier]['no_change'],'budget':self._budget_view()}
        result.update(self.evaluate({'proposal_id':identifier})if mode=='immediate'else{'measured':False,'deliverable':False});return result
    def evaluate(self,args):
        proposal=self.proposals[args['proposal_id']]
        if sha(proposal['def']['path'])!=proposal['def']['sha256']:raise RuntimeError('immutable proposal changed')
        self.evaluation_attempts+=1;key,fingerprint=self.cache.fingerprint(self.design,proposal['def']['path']);cached=self.cache.get(key)
        if cached:
            self.work.cache_hits+=1
            for identifier,candidate in self.legals.items():
                if candidate.get('evaluation_fingerprint')==key and candidate['ok']:
                    proposal['measured_candidate']=identifier;return self._evaluation_view(identifier,proposal['id'],True)
        identifier=f'l{len(self.legals):02d}';directory=self.root/'legal-candidates'/identifier;directory.mkdir(parents=True)
        candidate={**copy.deepcopy(proposal),'id':identifier,'ok':False,'evaluation_fingerprint':key,'proposal_id':proposal['id']};self.legals[identifier]=candidate
        save(directory/'measurement-fingerprint.json',fingerprint)
        try:
            metrics=cached or measure(self.design,proposal['def']['path'],directory/'evaluation',timeout=max(.01,self._remaining()-1),timing_paths=True)
            candidate['metrics']=metrics;candidate['ok']=metrics['ok']
            if candidate.get('proof',{}).get('operator')=='rudy_swap'and candidate['ok']:
                check=verify_native_grid(candidate['transaction'],Path(metrics['terminal']['log']['path']).parent);candidate['proof']['fresh_native_RUDY_check']=check;candidate['ok']=candidate['ok']and check['ok']
            if candidate['ok']:
                self._cache_legal_paths(identifier);self.cache.put(key,metrics);proposal['measured_candidate']=identifier
        except BaseException as exc:
            candidate['ok']=False;candidate['error']=type(exc).__name__+': '+str(exc)
            candidate.setdefault('metrics',{'ok':False,'error':candidate['error']})
            save(directory/'result.json',candidate)
            raise
        save(directory/'result.json',candidate);return self._evaluation_view(identifier,proposal['id'],bool(cached))
    def _evaluation_view(self,identifier,proposal_id,cached):
        candidate=self.legals[identifier];metrics=scalar_metrics(candidate.get('metrics',{}));parent_id=self.proposals[proposal_id].get('parent_candidate');parent=self.legals.get(parent_id)
        before=scalar_metrics(parent['metrics'])if parent else None
        response={'ok':candidate['ok'],'candidate_id':identifier,'proposal_id':proposal_id,'snapshot_id':candidate['snapshot'],'parent_candidate':parent_id,'metrics':metrics,'assessment':self._legal_view(identifier),'cache_hit':cached,'fresh_STA':not cached,'measured':True,'delta_from_parent':{k:metrics[k]-before[k]for k in AXES}if before and metrics.get('valid')else None,'budget':self._budget_view()}
        budget_error=candidate.get('metrics',{}).get('terminal',{}).get('budget_error')
        if not candidate['ok'] and budget_error:
            response.update(error_class='BudgetExhausted',error=budget_error)
            response['metrics']={**metrics,'reason':budget_error}
            response['assessment']={**response['assessment'],'reason':budget_error}
        return response
    def observe(self,args):
        view=args.get('view','summary')
        if self.variant=='summary_only':
            if view not in ('summary','memory'):raise ValueError('detailed observations disabled by frozen summary-only ablation')
            self.observe_count+=1
            return self.state(include_memory=self.observe_count==1 or view=='memory')
        if view in ('summary','memory'):return super().observe(args)
        if view not in ('paths','hotspots','cells','compare','proposals','filters'):raise ValueError('invalid observation view')
        offset,limit=args.get('offset',0),args.get('limit',4)
        for value,lo,hi in [(offset,0,1000000),(limit,1,64),(args.get('node_offset',0),0,1000000),(args.get('node_limit',16),1,64)]:
            if isinstance(value,bool)or not isinstance(value,int)or not lo<=value<=hi:raise ValueError('invalid pagination bounds')
        if args.get('candidate_id')and args.get('snapshot_id'):raise ValueError('choose candidate_id OR snapshot_id')
        if view=='filters':
            p=self.proposals[args['proposal_id']]if args.get('proposal_id')else self.legals[args['candidate_id']]
            proof=p.get('proof',{})
            value={'proposal_id':p.get('proposal_id',p['id']),'no_change':p.get('no_change'),
                   'proof':{k:v for k,v in proof.items()if k not in ('selected_cells','native','native_stage')}}
            if p.get('transaction'):
                path=Path(p['transaction'])/'search.json'
                # Prefixes share the producing search's filters/work, but
                # retain their own measured geometry and accepted index.
                if not path.exists():path=path.parent.parent/'search.json'
                if path.exists():
                    search=load(path)
                    value['search']={k:v for k,v in search.items()if k!='accepted_moves'}
            return {**value,'new_STA':False,'budget':self._budget_view()}
        if view=='proposals':rows=[self._proposal_view(p)for p in self.proposals.values()]
        else:
            identifier=args.get('candidate_id')or args.get('snapshot_id')
            if not identifier:raise ValueError('candidate_id or snapshot_id required')
            node=self._geometry_node(identifier)
            if view=='paths':
                if identifier not in self.timing_observations and identifier in self.legals:self._cache_legal_paths(identifier)
                obs=self.timing_observations.get(identifier)
                if not obs or sha(node['raw_def'])!=obs['raw_def_sha256']or sha(obs['paths']['path'])!=obs['paths']['sha256']:raise ValueError('matching cached paths required; query timing_paths=true first')
                analysis=args.get('analysis','both')
                if analysis not in ('both','setup','hold'):raise ValueError('invalid analysis')
                paths=[p for p in obs['decision_paths_all']if analysis=='both'or p['analysis']==analysis]
                if args.get('endpoint'):paths=[p for p in paths if p['endpoint']==args['endpoint']]
                begin,count=args.get('node_offset',0),args.get('node_limit',16)
                rows=[{**p,'node_count':len(p['nodes']),'node_offset':begin,'nodes':p['nodes'][begin:begin+count],'next_node_offset':begin+count if begin+count<len(p['nodes'])else None}for p in paths]
            elif view=='compare':
                left=self._legal_view(identifier);right=self._legal_view(args['other_candidate_id'])
                return {'left':left,'right':right,'delta':{k:left[k]-right[k]for k in AXES},'budget':self._budget_view()}
            else:
                nets=net_geometry(node['raw_def'],self.hpwl_macros,self.hpwl_helper)
                if view=='hotspots':
                    if args.get('net_name'):rows=[n for n in nets if n['name']==args['net_name']]
                    else:
                        rows=[]
                        for hot in node['hotspots']:
                            details=physical_evidence({**node,'hotspots':[hot]},nets,self.timing_observations.get(identifier))
                            rows.extend(details['hotspot_topology'])
                else:
                    coords=coordinates(node['raw_def']);names=[args['cell_name']]if args.get('cell_name')else sorted(coords)
                    rows=[{'name':n,**coords[n],'incident_nets':[net['name']for net in nets if n in net['cells']],'unreported_timing_is_unknown':True}for n in names if n in coords]
        return {'view':view,'offset':offset,'total':len(rows),'items':rows[offset:offset+limit],'next_offset':offset+limit if offset+limit<len(rows)else None,'new_STA':False,'budget':self._budget_view()}
    def finish(self,args):
        reason=args.get('stop_reason')
        if reason not in ('targets_matched','evidence_stagnation','quota_exhausted','time_reserve','no_eligible_scope'):raise ValueError('explicit typed stop_reason required')
        if args.get('candidate_id')not in self.legals:raise ValueError('unmeasured proposals cannot finish; evaluated candidate required')
        chosen=self.legals[args['candidate_id']];qualification=self._legal_view(chosen['id'])['surplus']
        if not chosen['ok']or not qualification or not qualification['qualified']:raise ValueError('only a measured qualified candidate can finish')
        if reason=='targets_matched'and not self._legal_view(chosen['id'])['Inn_targets_matched_within_engineering_epsilon']:raise ValueError('targets_matched requires all seven Inn targets within frozen engineering tolerance')
        if sha(chosen['def']['path'])!=chosen['def']['sha256']:raise RuntimeError('measured geometry changed')
        context,_=self.cache.fingerprint(self.design,chosen['def']['path'])
        if context!=chosen.get('evaluation_fingerprint')or self.cache.get(context)is None:raise RuntimeError('delivery measurement context or cached evidence changed; re-evaluation required')
        shutil.copy2(chosen['def']['path'],self.root/'final.def')
        tested={'measured_states':[{'candidate_id':k,'parent_candidate':v.get('parent_candidate'),
                                   'metrics':scalar_metrics(v.get('metrics',{})),
                                   'qualified':(self._legal_view(k).get('surplus')or{}).get('qualified',False)}
                                  for k,v in self.legals.items()],
                'attempted_actions':self.action_coverage,'remaining_budget':self._budget_view()}
        save(self.root/'stop-evidence.json',tested)
        self.finished={'candidate_id':chosen['id'],'snapshot_id':chosen['snapshot'],'def':desc(self.root/'final.def'),'stages':chosen['stages'],'run_dp':chosen['run_dp'],'metrics':scalar_metrics(chosen['metrics']),'surplus':qualification,'stop_reason':reason,'stop_evidence':{'scope':'tested parents/actions only; not a global physics floor','effective_configs':sorted({(round(n['effective_density'],6),n['timing_enabled'],n['congestion_effort'])for n in self.nodes.values()}),'proposals':len(self.proposals),'measured_candidates':len(self.legals),'physical_refinements':self.refinements,'errors':self.errors[-8:],'work':self.work.view()}}
        self.finished['stop_evidence'].update(tested_states_and_actions=desc(self.root/'stop-evidence.json'),remaining_budget=tested['remaining_budget'],selected_measured_parent=chosen['id'])
        save(self.root/'delivery.json',self.finished);self.close_native();return {'finished':True,**self.finished,'budget':self._budget_view()}
    def handle(self,request):
        started=time.monotonic();self.calls+=1;op=request.get('op');args=request.get('args',{})
        requested_args=copy.deepcopy(args)
        try:
            if not isinstance(args,dict):raise ValueError('arguments must be an object')
            allowed={'observe':{'snapshot_id','candidate_id','proposal_id','timing_paths','view','analysis','endpoint','offset','limit','node_offset','node_limit','net_name','cell_name','other_candidate_id'},'start':{'steps','target_density','target_overflow','congestion_effort','timing'},'advance':{'snapshot_id','steps','scope','congestion_effort','hotspot_index','radius_bins'},'restore':{'snapshot_id'},'legalize':{'snapshot_id','run_dp','evaluation'},'refine':{'candidate_id','action','evaluation','objective','operator','scope','protect_reported_timing','max_moves','neighbor_trials','wire_guard','path_guard','max_selected_cells','strength','hotspot_index','radius_bins'},'evaluate':{'proposal_id'},'finish':{'candidate_id','stop_reason'}}
            if op not in allowed or set(args)-allowed[op]:raise ValueError('unknown operation or fields')
            if self.variant=='fixed_granularity':
                args=copy.deepcopy(args)
                if op in ('start','advance'):args['steps']=100
                if op=='legalize':args['evaluation']='immediate'
                if op=='refine':
                    action=args.get('action',args)
                    if action.get('operator')=='rudy_swap':action['max_moves']=1
                    else:action['max_selected_cells']=64
                    args['evaluation']='immediate'
            if self.calls>self.budget['tool_calls']:raise work_budget.BudgetExhausted('tool-call quota exhausted')
            if self._remaining()<=0:raise work_budget.BudgetExhausted('episode wall deadline reached')
            if self.finished and op!='observe':raise ValueError('delivery already finalized')
            if op not in ('finish','observe'):self.work.check()
            value={'ok':True,**getattr(self,op)(args)}
            if not value['ok']:
                self.errors.append({'op':op,'error_class':'InvalidPhysicalResult','message':'Physical attempt retained but complete valid measurements were not produced','candidate_id':value.get('candidate_id')})
        except Exception as exc:
            error={'op':op,'error_class':type(exc).__name__,'message':str(exc)[:1200]};self.errors.append(error)
            value={'ok':False,**error,'budget':self._budget_view(),'recoverable':'Correct arguments, inspect existing evidence or explicitly finish a qualified measured candidate.'}
            with (self.root/'backend-errors.log').open('a')as out:traceback.print_exc(file=out)
        value['tool_wall_s']=time.monotonic()-started
        if self.variant=='fixed_granularity':value['effective_arguments']=args
        if op in ('start','advance','restore','legalize','refine','evaluate'):
            self.action_coverage.append({'op':op,'args':args,'ok':value['ok'],
                                         'candidate_id':value.get('candidate_id'),'proposal_id':value.get('proposal_id'),
                                         'budget_after':self._budget_view()})
        self._persist()
        with (self.root/'tool-ledger.jsonl').open('a')as out:out.write(json.dumps({'request':{'op':op,'args':requested_args},'effective_args':args,'response':value})+'\n')
        return value

legacy.PlacementSession=PlacementSession
serve,client=legacy.serve,legacy.client
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('mode',choices=['serve','call']);p.add_argument('--episode',required=True);a=p.parse_args()
    if a.mode=='serve':serve(a.episode)
    else:
        try:value=client(a.episode,json.loads(sys.stdin.read()))
        except Exception as exc:value={'ok':False,'error_class':type(exc).__name__,'message':str(exc)}
        print(json.dumps(value,ensure_ascii=False))
