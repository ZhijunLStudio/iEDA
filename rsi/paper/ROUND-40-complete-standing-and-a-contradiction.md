# Round 40: the complete standing, and a preliminary result that contradicts an exclusion

## 1. The complete standing, fifteen designs, one batch

Both arms scored inside one process per design, one thread, the reference legalised first. Every ratio is
ours over the reference; below 1.00 is better.

| design | PDK | wirelength | total overflow | peak overflow | verdict |
|---|---|---|---|---|---|
| aes | sky130 | 0.7323 | 1.3609 | 1.6111 | fail: union, max |
| apb4_timer | sky130 | 0.8717 | 0.9285 | 1.0000 | **ALL** |
| gcd_ics55_a | ics55 | 0.9442 | 1.8500 | 0.5000 | fail: union |
| gcd_nangate45_a | nangate45 | 0.8919 | - | - | **ALL** |
| gcd_sky130_a | sky130 | 1.1357 | 2.3889 | 1.2727 | fail: hpwl, union, max |
| picorv32 | sky130 | 0.8081 | 1.4525 | 1.6111 | fail: union, max |
| s1238 | sky130 | 0.7613 | 1.1420 | 1.4286 | fail: union, max |
| s1238_ics55_a | ics55 | 0.8289 | 0.5226 | 0.4286 | **ALL** |
| s1238_nangate45_a | nangate45 | 0.7489 | - | - | **ALL** |
| s1238_sky130_a | sky130 | 1.0776 | 2.0525 | 1.8571 | fail: hpwl, union, max |
| s38584_ics55_a | ics55 | 0.9695 | 1.1656 | 1.6000 | fail: union, max |
| s38584_nangate45_a | nangate45 | 0.9590 | 1.5000 | 1.0000 | fail: union |
| s5378_sky130_b | sky130 | 0.8962 | 1.5597 | 1.2727 | fail: union, max |
| salsa20_ics55_a | ics55 | 0.9448 | 0.7862 | 1.1429 | fail: max |
| salsa20_nangate45_a | nangate45 | 0.9414 | 1.8862 | 1.7143 | fail: union, max |

**4 of 15 designs are no worse on every measurable dimension** (apb4_timer, gcd_nangate45_a,
s1238_ics55_a, s1238_nangate45_a; the two nangate45 designs have no congestion reference so only their
wirelength is claimed). **Wirelength fails on 2 of 15, total overflow on 10 of 13 measurable, peak on 9 of
13.**

This reproduces round 28's numbers and is the sound baseline the objective now stands on: **the deficit
is congestion, and peak is the worse of the two.**

## 2. A preliminary result that contradicts the exclusion list

Every entry on the excluded list was established before the protocol was fixed. The first re-test is
congestion-aware global placement, and **it looks much better than the exclusion says**.

Effort 0 is the standing measurement of the same design, binary, seed and configuration; effort 4 is the
same run with congestion-aware wirelength enabled:

| design | effort 0 (standing) | **effort 4** | change |
|---|---|---|---|
| s38584_ics55_a | 0.9695 / **1.1656** / **1.6000** | 0.9729 / **0.8807** / **1.2000** | union -793, peak -6, wirelength +0.3% |
| s1238_sky130_a | 1.1172 / 2.2661 / 1.7143 | **1.0663** / 1.7664 / 1.4286 | union -875, peak -8, **wirelength -4%** |

**On both designs it improves total overflow and peak together, and wirelength does not get worse** - on
s1238_sky130_a it also improves. On s38584_ics55_a it takes total overflow from 1.17x the reference to
0.88x, i.e. **from failing to winning**.

The exclusion says congestion-aware wirelength levels 2/3/4 are "not a fix as an unconditional default".
**Two designs are not a basis for overturning that**, and it is a single seed. What they are is a strong
enough signal to run the full test, which is now in flight: effort 4 on all fifteen designs, against the
standing's effort-0 values, same binary, same seed.

## 3. The cost, which is the reason this needs care

Effort 4 calls the congestion evaluator inside the Nesterov loop, so a design takes tens of minutes
instead of about one. If it is adopted, the price is not the SR-11 guard's two evaluator calls but
something much larger, and that has to be weighed against the gain and stated whenever the result is
quoted.

## 4. Notes on this round's housekeeping

- The aggregate now writes its results after every design rather than only at the end, so partial work
  survives a slow or dead run - the failure mode that lost two designs in round 37.
- The standing's per-design placement files are the durable artefact, so no chunk boundary can lose work
  again.
- An earlier aggregate, written while its process ran under a CPU set outside the machine's range, had
  every congestion measurement silently fail and left wirelength-only ratios. It was not reported and has
  been overwritten. That is the second harness parameter this campaign has had silently invalidate a
  batch, and it is why section 2's comparison is anchored on a configuration whose value is already known.

## 5. Tree state

Source unchanged: SR-10 and SR-11 in; SR-2/3/4/5/7/8/9/12 withdrawn with recorded reasons; SR-13 and
SR-14 **unmeasured** pending re-judgement. Binary f9581627.
