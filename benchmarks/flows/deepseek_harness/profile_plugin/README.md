# Installable bundle for a running dsh profile

This package is the standalone form of the iEDA GP native plugin for an
installed `@deepseek-ai/dsh` CLI (rc.6). It declares `dsh.bundle.patch`, so:

```sh
export PATH=/home/lizhijun/.npm-global/bin:/tmp/corepack-bin:$PATH
dsh plugin --profile web add /home/lizhijun/work/iEDA.ai/benchmarks/flows/deepseek_harness/profile_plugin
```

`dsh plugin` runs pnpm inside `$DSH_HOME/profiles/web`, installs this package,
sees its `dsh.bundle.patch`, and adds `@ieda-ai/dsh-tool-ieda-gp` to the
profile's `dsh.profile.bundles`. Restart `dsh web --port 3080` to load it.

The model tools are `ieda_gp_baselines`, `ieda_gp_start`, `ieda_gp_candidate`,
`ieda_gp_advance`, `ieda_gp_report`, `ieda_gp_eval_def`, and
`ieda_gp_full_compare`.
