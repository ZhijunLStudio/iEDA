"""All conditional ablation deliveries beside the three original main runs."""
import argparse
import csv
import json
from pathlib import Path
from common import load, save, reference_gaps
from pl_backend import scalar_metrics


def summarize(main,ablations,output):
    main,ablations,output=map(Path,(main,ablations,output));output.mkdir(parents=True,exist_ok=False)
    suite=load(main/'suite.json');rows=[];summaries=[]
    for design in('salsa20_sky130_a','aes'):
        target=scalar_metrics(load(main/'references'/design/'inn/attempt-1/result.json'))
        period=suite['designs'][design]['clock_period_ns']
        for variant,root in [('autonomous',main),('fixed_granularity',ablations),('summary_only',ablations)]:
            entries=[e for e in load(root/'paired-plan.json')['agent']if e['design']==design and e.get('variant','autonomous')==variant];scores=[]
            for entry in entries:
                p=root/'episodes'/entry['id']/'result.json';v=load(p)if p.exists()else{}
                audit=root/'audits'/entry['id']/'result.json';ok=v.get('ok')and audit.exists()and load(audit)['ok']
                delivery=v.get('delivery');m=delivery.get('metrics',{})if delivery else{}
                g=reference_gaps(m,target,period)if m.get('valid')else None
                row={'design':design,'variant':variant,'episode':entry['id'],'normal_delivery':bool(ok),**m,**v.get('work',{}),'wall_s':v.get('wall_s'),'model_requests':v.get('model_request_count'),'worst_Inn_gap':g['worst']if g else None,'sum_Inn_gap':g['sum']if g else None}
                rows.append(row);scores.append(((g['worst'],g['sum'])if ok and g else(float('inf'),float('inf')),row))
            scores.sort(key=lambda x:(*x[0],x[1]['episode']))
            middle=scores[1][1]if len(scores)==3 and scores[1][1]['normal_delivery']else None
            summaries.append({'design':design,'variant':variant,'normal':sum(r[1]['normal_delivery']for r in scores),'attempts':len(scores),'median_actual_episode':middle['episode']if middle else None,'median_metrics':middle if middle else None})
    keys=list(dict.fromkeys(k for row in rows for k in row))
    with(output/'all-ablation-deliveries.csv').open('x',newline='')as stream:
        writer=csv.DictWriter(stream,fieldnames=keys);writer.writeheader();writer.writerows(rows)
    save(output/'summary.json',{'conditions':summaries,'scope':'Three actual deliveries per condition; missing/failed runs retained. Small-sample engineering ablations, not a significance or routed-quality claim.'})


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--main',required=True);parser.add_argument('--ablations',required=True);parser.add_argument('--output',required=True)
    args=parser.parse_args();summarize(args.main,args.ablations,args.output)
