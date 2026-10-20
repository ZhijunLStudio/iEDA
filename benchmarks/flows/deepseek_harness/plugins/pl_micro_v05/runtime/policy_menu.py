"""Common menu for all four controllers, frozen before holdout optimization."""
DP_ACTIONS=[{'objective':a,'operator':b,'scope':c,'protect_reported_timing':d,'strength':4}for a,b,c,d in [('rudy','local_reorder','hotspot',True),('timing','instance_swap','critical',False),('balanced','row_opt','global',False),('rudy','instance_swap','hotspot',True),('balanced','all','global',False),('hpwl','bin_opt','global',True)]]
DIRECT_ACTIONS=[{'objective':'rudy','operator':'rudy_swap','scope':'global','protect_reported_timing':True,'path_guard':'critical','wire_guard':g,'neighbor_trials':4096}for g in ('both','cap','elmore','none')]
LATE_FEEDBACK=[{'steps':s,'congestion_effort':f,'scope':'global'}for f in (3,4)for s in (8,24,64,200)]

def shared_menu(memory,baseline):
    starts=[{'density':baseline['start']['target_density'],'feedback':0,'timing':baseline['start']['timing'],'overflow_target':baseline['start']['target_overflow'],'checkpoint_iteration':baseline['max_gp_iterations'],'run_dp':True,'baseline':True}]
    starts+=memory['recipes']
    starts+=[{'density':d,'feedback':f,'timing':True,'overflow_target':.1,'checkpoint_iteration':500,'run_dp':False}for d,f in ((.5,3),(.4,4),(.6,4),(.5,4),(.7,4),(.7,3),(.7,0))]
    unique=[];seen=set()
    for rec in starts:
        key=tuple(rec.get(k)for k in ('density','feedback','timing','overflow_target','checkpoint_iteration','run_dp'))
        if key not in seen:unique.append({k:v for k,v in rec.items()if k not in ('source_result','metrics','rank','qualified','violations')});seen.add(key)
    return {'GP_portfolio':unique,'late_feedback':LATE_FEEDBACK,'DP_actions':DP_ACTIONS,'direct_actions':DIRECT_ACTIONS,'batch_choices':[1,2,4,8],'DP_caps':[64,256,None],'rule_parent_rank':'qualified first, then worst positive normalized Inn gap, sum, immutable ID','repair':'at most two timing critical-scope repairs for a measured unqualified child; then retain parent','prior_scope':'Union of frozen historical rule and stage-rule recipes, same menu supplied to agent; no holdout optimization outcomes.'}
