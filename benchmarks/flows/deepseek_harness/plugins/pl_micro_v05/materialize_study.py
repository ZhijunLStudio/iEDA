#!/usr/bin/env python3
"""Create a new, runnable external study root from this plugin's source.

Inputs and frozen references remain outside Git. This does not start native
work or contact a model gateway, and never overwrites an existing study.
"""
import argparse,hashlib,json,shutil,sys
from pathlib import Path


def materialize(output,suite,plan,experience,helpers,references):
    package=Path(__file__).resolve().parent
    values={name:json.loads(Path(path).read_text())for name,path in [('suite',suite),('paired-plan',plan),('experience',experience)]}
    output=Path(output).resolve()
    if output.exists():raise FileExistsError(output)
    if not values['suite'].get('designs') or not values['paired-plan'].get('arms'):
        raise ValueError('suite designs and budget arms are required')
    if values['paired-plan'].get('agent') or values['paired-plan'].get('repeats'):
        gateway=values['paired-plan'].get('gateway_base_url')
        if not isinstance(gateway,str) or not gateway:
            raise ValueError('freeze gateway_base_url in the plan before materializing model episodes')
    declared_helpers={Path(item['path']).name:item['sha256'] for item in values['suite']['helpers']}
    for name in ('def_hpwl_eval.py','def_identity.py','placement_legality.py'):
        if not(Path(helpers)/name).is_file():raise ValueError('missing frozen measurement helper: '+name)
        if hashlib.sha256((Path(helpers)/name).read_bytes()).hexdigest()!=declared_helpers.get(name):
            raise ValueError('selected measurement helper differs from the frozen suite: '+name)
    for design in values['suite']['designs']:
        if design not in values['experience']:raise ValueError('missing same-prior memory entry: '+design)
        for role in ('ieda','inn'):
            if not(Path(references)/design/role/'attempt-1/result.json').is_file():raise ValueError('missing reference: '+design+'/'+role)
    verified={}
    def check(value):
        if isinstance(value,dict):
            if 'path'in value and 'sha256'in value:
                path=Path(value['path'])
                if path not in verified:
                    digest=hashlib.sha256()
                    with path.open('rb')as stream:
                        for block in iter(lambda:stream.read(1024*1024),b''):digest.update(block)
                    verified[path]=digest.hexdigest()
                if verified[path]!=value['sha256']:raise ValueError('frozen asset changed: '+str(path))
            else:
                for child in value.values():check(child)
        elif isinstance(value,list):
            for child in value:check(child)
    for key in ('solver','original_solver','helpers','frozen_inputs'):check(values['suite'][key])
    output.mkdir(parents=True,exist_ok=False)
    for source in (package/'runtime').glob('*.py'):shutil.copy2(source,output/source.name)
    shutil.copytree(package/'validation',output/'validation',ignore=shutil.ignore_patterns('__pycache__'))
    plugin=output/'plugin';plugin.mkdir()
    shutil.copytree(package/'lib',plugin/'lib')
    for name in ('package.json','cordis.patch.yml'):shutil.copy2(package/name,plugin/name)
    for name,value in values.items():(output/(name+'.json')).write_text(json.dumps(value,indent=2,ensure_ascii=False)+'\n')
    plan_value=values['paired-plan']
    (output/'all-plan.json').write_text(json.dumps({**plan_value,'agent':plan_value.get('agent',[])+plan_value.get('repeats',[])},indent=2)+'\n')
    (output/'repeat-plan.json').write_text(json.dumps({**plan_value,'agent':plan_value.get('repeats',[]),'rule':[],'stage_rule':[]},indent=2)+'\n')
    (output/'helpers').symlink_to(Path(helpers).resolve(),target_is_directory=True)
    (output/'references').symlink_to(Path(references).resolve(),target_is_directory=True)
    sys.path.insert(0, str(package / 'runtime'))
    from study_contract import freeze_manifest
    freeze_manifest(output)
    return output


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('output','suite','plan','experience','references'):p.add_argument('--'+name,required=True,type=Path)
    p.add_argument('--helpers',type=Path,default=Path(__file__).resolve().parent/'helpers')
    a=p.parse_args();print(materialize(a.output,a.suite,a.plan,a.experience,a.helpers,a.references))
