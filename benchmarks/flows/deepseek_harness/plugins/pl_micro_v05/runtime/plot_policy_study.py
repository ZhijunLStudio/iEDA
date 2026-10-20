"""Export scientific figures; actual delivered points and diagnostic curves."""
import argparse
import csv
from collections import defaultdict
from pathlib import Path


def plot(directory):
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
    directory=Path(directory)
    with(directory/'all-deliveries.csv').open()as stream:deliveries=list(csv.DictReader(stream))
    with(directory/'actual-cost-quality-curves.csv').open()as stream:curves=list(csv.DictReader(stream))
    designs=list(dict.fromkeys(row['design']for row in deliveries))
    colors={'coarse':'#3377bb','fine':'#dd9933','adaptive':'#339977','agent':'#aa4488'}
    fig,axes=plt.subplots((len(designs)+2)//3,3,figsize=(14,3.2*((len(designs)+2)//3)),squeeze=False)
    groups=defaultdict(list)
    for row in curves:groups[(row['design'],row['episode'],row['controller'])].append(row)
    for ax,design in zip(axes.flat,designs):
        for (name,identifier,controller),rows in groups.items():
            if name!=design:continue
            rows=[r for r in rows if r.get('physical_cpu_s')and r.get('best_measured_worst_gap_diagnostic')]
            ax.step([float(r['physical_cpu_s'])for r in rows],[float(r['best_measured_worst_gap_diagnostic'])for r in rows],where='post',ls=':',alpha=.5,color=colors.get(controller,'grey'))
        for row in deliveries:
            if row['design']==design and row['status']=='valid'and row.get('physical_cpu_s')and row.get('worst_Inn_gap'):
                ax.scatter(float(row['physical_cpu_s']),float(row['worst_Inn_gap']),marker='o'if row['role']=='agent'else's',color=colors.get(row['role'],'grey'),s=34)
        ax.set_title(design);ax.set_xlabel('Actual physical CPU (s)');ax.set_ylabel('Worst normalized Inn gap');ax.grid(alpha=.2)
    for ax in list(axes.flat)[len(designs):]:ax.set_visible(False)
    from matplotlib.lines import Line2D
    fig.legend(handles=[Line2D([],[],marker='o'if k=='agent'else's',color=v,label=k,ls='')for k,v in colors.items()],loc='lower center',ncol=4)
    fig.suptitle('Markers: actual delivered layouts. Dotted lines: best-measured diagnostic only.\nPlacement proxies: RUDY64 / HPWL-RC, not routed/signoff QoR.',fontsize=11)
    fig.tight_layout(rect=(0,.035,1,.95));fig.savefig(directory/'quality-vs-physical-CPU.png',dpi=180);fig.savefig(directory/'quality-vs-physical-CPU.pdf');plt.close(fig)
    fig,ax=plt.subplots(figsize=(8,5))
    for row in deliveries:
        if row['status']=='valid'and row.get('wall_s')and row.get('worst_Inn_gap'):
            ax.scatter(float(row['wall_s']),float(row['worst_Inn_gap']),color=colors.get(row['role'],'grey'),marker='o'if row['role']=='agent'else's',alpha=.75)
    ax.set_xlabel('Total wall time including API (s)');ax.set_ylabel('Delivered worst normalized Inn gap');ax.grid(alpha=.2)
    ax.set_title('Actual deliveries; designs are reported separately in the CSV')
    fig.tight_layout();fig.savefig(directory/'delivered-quality-vs-total-wall.png',dpi=180);plt.close(fig)


if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--analysis',required=True)
    plot(parser.parse_args().analysis)
