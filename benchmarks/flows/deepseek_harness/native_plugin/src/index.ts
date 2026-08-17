/**
 * First-party native DeepSeek Harness tool plugin for the iEDA GP agent.
 *
 * This is the native-plugin form: it registers seven model-facing tools
 * directly on `ctx.tools` through `defineTool` and executes the same iEDA
 * Python CLIs that the manual GP experiments use. No MCP subprocess bridge is
 * involved.
 *
 * @module @deepseek-ai/dsh-tool-ieda-gp
 */

import type { Context } from '@deepseek-ai/cordis'
import z from '@deepseek-ai/schemastery'
import { defineTool } from '@deepseek-ai/dsh-tools'
import type { JsonValue } from '@deepseek-ai/dsh-tools'
import { execFile } from 'node:child_process'
import { readFileSync } from 'node:fs'
import { join, resolve } from 'node:path'
import { promisify } from 'node:util'

const execFileAsync = promisify(execFile)

export const name = 'tool-ieda-gp'
export const inject = ['tools'] as const

export interface Config {
  /** Absolute path of the iEDA checkout. */
  iedaRoot: string
  /** Python executable used to run the checked-in GP CLIs. */
  python: string
  /** Per-GP-subprocess timeout in milliseconds. */
  timeoutMs: number
}

export const Config: z<Config> = z.object({
  iedaRoot: z.string().required(),
  python: z.string().default('python3'),
  timeoutMs: z.number().step(1).min(1000).default(7_200_000),
})

function readDesigns(iedaRoot: string): Record<string, Record<string, unknown>> {
  const path = join(iedaRoot, 'benchmarks/flows/deepseek_harness/designs.json')
  return JSON.parse(readFileSync(path, 'utf8')) as Record<string, Record<string, unknown>>
}

function knownDesigns(iedaRoot: string): string[] {
  return Object.keys(readDesigns(iedaRoot))
}

function tail(value: string, max = 12000): string {
  return value.length > max ? value.slice(-max) : value
}

async function runCli(
  iedaRoot: string,
  python: string,
  timeoutMs: number,
  script: string,
  args: string[],
): Promise<Record<string, unknown>> {
  try {
    const { stdout, stderr } = await execFileAsync(python, [script, ...args], {
      cwd: iedaRoot,
      timeout: timeoutMs,
      maxBuffer: 32 * 1024 * 1024,
    })
    const text = tail(stdout)
    try {
      return JSON.parse(stdout) as Record<string, unknown>
    } catch {
      return { ok: false, rc: 0, stdout: text, stderr_tail: tail(stderr) }
    }
  } catch (error: unknown) {
    const err = error as NodeJS.ErrnoException & { stdout?: string; stderr?: string }
    return {
      ok: false,
      rc: typeof err.code === 'number' ? err.code : 1,
      error: err.message,
      stdout: tail(err.stdout ?? ''),
      stderr_tail: tail(err.stderr ?? ''),
    }
  }
}

function jsonContent(value: Record<string, unknown>): [{ type: 'text'; text: string }] {
  return [{ type: 'text', text: JSON.stringify(value, null, 2) }]
}

function commonResultSchema() {
  return { type: 'json' } as const
}

function asJson(value: unknown): JsonValue {
  return value as JsonValue
}

/** One shared execution context for every registered tool. */
class IedaGpRuntime {
  constructor(
    private readonly iedaRoot: string,
    private readonly python: string,
    private readonly timeoutMs: number,
  ) {}

  script(name: string): string {
    return join(this.iedaRoot, 'benchmarks/flows', name)
  }

  async agent(design: string, workdir: string, args: string[]): Promise<Record<string, unknown>> {
    const designs = readDesigns(this.iedaRoot)
    const record = designs[design] as Record<string, unknown> | undefined
    if (!record) throw new Error(`unknown design ${JSON.stringify(design)}; known designs: ${knownDesigns(this.iedaRoot).join(', ')}`)
    return runCli(this.iedaRoot, this.python, this.timeoutMs, this.script('gp_agent.py'), [
      '--workdir', resolve(workdir),
      '--case-root', String(record.case_root),
      '--input-def', String(record.input_def),
      '--config', String(record.pl_config),
      ...args,
    ])
  }

  async toolbox(args: string[]): Promise<Record<string, unknown>> {
    return runCli(this.iedaRoot, this.python, this.timeoutMs, this.script('gp_toolbox.py'), args)
  }

  async fullCompare(design: string, resultRoot: string, timing: boolean): Promise<Record<string, unknown>> {
    const designs = readDesigns(this.iedaRoot)
    if (!designs[design]) throw new Error(`unknown design ${JSON.stringify(design)}; known designs: ${knownDesigns(this.iedaRoot).join(', ')}`)
    return runCli(this.iedaRoot, this.python, this.timeoutMs, this.script('run_ipl_full_compare.py'), [
      '--designs', design,
      '--result-root', resolve(resultRoot),
      ...(timing ? ['--timing'] : []),
    ])
  }
}

export function apply(ctx: Context, config: Config): void {
  const runtime = new IedaGpRuntime(resolve(config.iedaRoot), config.python, config.timeoutMs)
  const p = (extra: Record<string, unknown> = {}) => ({ kind: { type: 'string', required: true }, ...extra })
  const out = () => ({ schema: commonResultSchema(), render: (_args: unknown, value: unknown) => jsonContent(value as Record<string, unknown>) })
  const toolbox = async (args: string[]) => asJson(await runtime.toolbox(args))
  const agent = async (args: any) => asJson(await runtime.agent(args.design, args.workdir, args as string[]))
  const restore = async (args: any) => asJson(await runCli(config.iedaRoot, config.python, config.timeoutMs,
    join(config.iedaRoot, 'benchmarks/flows/gp_agent.py'),
    ['--workdir', resolve(args.workdir), 'restore', ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]))
  const scopeArgs = (args: any) => ['--scope', args.scope ?? 'region', '--scope-active-ratio', String(args.scope_active_ratio ?? 0.2),
    '--scope-active-count', String(args.scope_active_count ?? 100), '--scope-instances', args.scope_instances ?? '',
    '--scope-region', args.scope_region ?? '', '--halo-coeff', String(args.halo_coeff ?? 0.5),
    '--halo-hops', String(args.halo_hops ?? 1), '--scope-density-target', String(args.scope_density_target ?? 1),
    '--scope-density-ratio', String(args.scope_density_ratio ?? 0), '--overflow-penalty', String(args.overflow_penalty ?? 0)]
  const freezeRun = async (args: any) => {
    const fz: any = await runtime.toolbox(['freeze_instances', '--workdir', resolve(args.workdir), '--region', args.region,
      ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
    if (!fz.ok) return asJson(fz)
    return asJson(await runtime.agent(args.design, args.workdir, ['local_run', '--iterations', String(args.iterations ?? 10),
      '--scope', 'instances', '--scope-instances', String(fz.scope_instances), '--halo-hops', String(args.halo_hops ?? 0),
      '--halo-coeff', String(args.halo_coeff ?? 0.5), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]))
  }

  ctx.tools.register(defineTool({
    name: 'ieda_gp_inspect',
    description: 'Inspect GP state. kind: status (current metrics with availability/staleness), checkpoints (all checkpoints), grid (top density bins). workdir is required; checkpoint is optional and defaults to the latest checkpoint.',
    parameters: p({ workdir: { type: 'string', required: true }, checkpoint: { type: 'string' }, top_n: { type: 'integer' }, def_path: { type: 'string' } }),
    output: out(),
    execute: async (args: any) => {
      if (args.kind === 'status') return toolbox(['status', '--workdir', resolve(args.workdir), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
      if (args.kind === 'checkpoints') return toolbox(['checkpoints', '--workdir', resolve(args.workdir)])
      if (args.kind === 'grid') return toolbox(['grid', '--workdir', resolve(args.workdir), '--top-n', String(args.top_n ?? 8), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
      throw new Error('ieda_gp_inspect: kind must be status|checkpoints|grid')
    },
  }))

  ctx.tools.register(defineTool({
    name: 'ieda_gp_diagnose',
    description: 'Diagnose GP problems. kind: hotspots (density hotspots), longnets (highest-HPWL nets), unstable (most-moved cells between checkpoint_a and checkpoint_b).',
    parameters: p({ workdir: { type: 'string', required: true }, checkpoint: { type: 'string' }, checkpoint_a: { type: 'string' }, checkpoint_b: { type: 'string' }, top_n: { type: 'integer' }, def_path: { type: 'string' }, region: { type: 'string' } }),
    output: out(),
    execute: async (args: any) => {
      if (args.kind === 'hotspots') return toolbox(['hotspots', '--workdir', resolve(args.workdir), '--top-n', String(args.top_n ?? 5), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
      if (args.kind === 'longnets') return toolbox(['longnets', '--workdir', resolve(args.workdir), '--top-n', String(args.top_n ?? 5), ...(args.def_path ? ['--def-path', args.def_path] : []), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
      if (args.kind === 'unstable') return toolbox(['unstable', '--workdir', resolve(args.workdir), '--checkpoint-a', args.checkpoint_a, '--checkpoint-b', args.checkpoint_b, '--top-n', String(args.top_n ?? 5)])
      throw new Error('ieda_gp_diagnose: kind must be hotspots|longnets|unstable')
    },
  }))

  ctx.tools.register(defineTool({
    name: 'ieda_gp_propose',
    description: 'Propose GP actions without changing state. kind: regions, region_density, freeze. prediction_status is unavailable until a predictor exists.',
    parameters: p({ workdir: { type: 'string', required: true }, checkpoint: { type: 'string' }, priority: { type: 'string' }, top_n: { type: 'integer' }, min_cell_count: { type: 'integer' }, max_cell_count: { type: 'integer' }, def_path: { type: 'string' }, region: { type: 'string' } }),
    output: out(),
    execute: async (args: any) => {
      if (args.kind === 'regions') return toolbox(['propose_regions', '--workdir', resolve(args.workdir), '--priority', args.priority ?? 'density', '--top-n', String(args.top_n ?? 5), '--min-cell-count', String(args.min_cell_count ?? 20), '--max-cell-count', String(args.max_cell_count ?? 200), ...(args.def_path ? ['--def-path', args.def_path] : []), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
      if (args.kind === 'region_density') return toolbox(['propose_region_density', '--workdir', resolve(args.workdir), '--region', args.region, ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
      if (args.kind === 'freeze') return toolbox(['propose_freeze', '--workdir', resolve(args.workdir), '--region', args.region, ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])])
      throw new Error('ieda_gp_propose: kind must be regions|region_density|freeze')
    },
  }))

  ctx.tools.register(defineTool({
    name: 'ieda_gp_run',
    description: 'Execute GP actions. kind: start, advance, candidate, local_run, apply_freeze, apply_region_density. design and workdir are required; all apply kinds return the new checkpoint path.',
    parameters: p({ design: { type: 'string', required: true }, workdir: { type: 'string', required: true }, checkpoint: { type: 'string' }, iterations: { type: 'integer' }, seed: { type: 'integer' }, random_init: { type: 'integer' }, target_density: { type: 'number' }, congestion_effort: { type: 'integer' }, seed_anchor_strength: { type: 'number' }, report_route_util: { type: 'integer' }, scope: { type: 'string' }, scope_active_ratio: { type: 'number' }, scope_active_count: { type: 'integer' }, scope_instances: { type: 'string' }, scope_region: { type: 'string' }, halo_coeff: { type: 'number' }, halo_hops: { type: 'integer' }, overflow_penalty: { type: 'number' }, scope_density_target: { type: 'number' }, scope_density_ratio: { type: 'number' }, region: { type: 'string' } }),
    output: out(),
    execute: async (args: any) => {
      const k = args.kind
      if (k === 'start') return agent([...['start', '--iterations', String(args.iterations ?? 20), '--seed', String(args.seed ?? 1000), '--random-init', String(args.random_init ?? 1), '--seed-anchor-strength', String(args.seed_anchor_strength ?? 0), '--target-density', String(args.target_density ?? -1), '--congestion-effort', String(args.congestion_effort ?? -1), '--report-route-util', String(args.report_route_util ?? 1)]])
      if (k === 'advance') return agent([...['advance', '--iterations', String(args.iterations ?? 100), '--report-route-util', String(args.report_route_util ?? 1), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]])
      if (k === 'candidate') return agent([...['candidate', '--iterations', String(args.iterations ?? 20), ...scopeArgs(args), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]])
      if (k === 'local_run') return agent([...['local_run', '--iterations', String(args.iterations ?? 10), ...scopeArgs(args), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]])
      if (k === 'apply_freeze') return freezeRun(args)
      if (k === 'apply_region_density') return agent([...['local_run', '--iterations', String(args.iterations ?? 10), '--scope', 'region', '--scope-region', args.region, '--scope-density-target', String(args.scope_density_target ?? 1), '--scope-density-ratio', '1', '--halo-hops', String(args.halo_hops ?? 1), '--halo-coeff', String(args.halo_coeff ?? 0.5), ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]])
      throw new Error('ieda_gp_run: kind must be start|advance|candidate|local_run|apply_freeze|apply_region_density')
    },
  }))

  ctx.tools.register(defineTool({
    name: 'ieda_gp_verify',
    description: 'Verify GP results. kind: delta (metric delta between checkpoint_a and checkpoint_b), lg (read-only LG oracle: post-LG HPWL and max/avg displacement).',
    parameters: p({ design: { type: 'string' }, workdir: { type: 'string', required: true }, checkpoint: { type: 'string' }, checkpoint_a: { type: 'string' }, checkpoint_b: { type: 'string' } }),
    output: out(),
    execute: async (args: any) => {
      if (args.kind === 'delta') return toolbox(['verify_delta', '--workdir', resolve(args.workdir), '--checkpoint-a', args.checkpoint_a, '--checkpoint-b', args.checkpoint_b])
      if (args.kind === 'lg') return asJson(await runtime.agent(args.design ?? 's1238', args.workdir, ['verify_lg', ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]))
      throw new Error('ieda_gp_verify: kind must be delta|lg')
    },
  }))

  ctx.tools.register(defineTool({
    name: 'ieda_gp_session',
    description: 'Manage the GP session state. kind: restore, accept, unfreeze, clear_density.',
    parameters: p({ design: { type: 'string' }, workdir: { type: 'string', required: true }, checkpoint: { type: 'string' } }),
    output: out(),
    execute: async (args: any) => {
      if (args.kind === 'restore') return restore(args)
      if (args.kind === 'accept') return asJson(await runtime.agent(args.design ?? 's1238', args.workdir, ['accept', ...(args.checkpoint ? ['--checkpoint', args.checkpoint] : [])]))
      if (args.kind === 'unfreeze' || args.kind === 'clear_density') return asJson({ ok: true, note: 'batch-scoped state is already cleared', workdir: resolve(args.workdir), checkpoint: args.checkpoint ?? null })
      throw new Error('ieda_gp_session: kind must be restore|accept|unfreeze|clear_density')
    },
  }))
}
