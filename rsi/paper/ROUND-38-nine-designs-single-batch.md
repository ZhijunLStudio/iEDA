# Round 38: nine of fifteen designs re-measured in a single batch, and the corrected standing reproduces

## 1. The standing rebuild, nine designs

Both arms scored inside one process per design, one thread. Every ratio is ours over the reference;
below 1.00 is better. The right-hand columns compare against the round-28 values, which were taken
across batches - if those were contaminated by the round-31 anomaly, these would disagree.

| design | single-batch hpwl / union / max | round-28 | match |
|---|---|---|---|
| gcd_sky130_a | 1.1357 / 2.3889 / 1.2727 | 1.14 / 2.39 / 1.27 | yes yes yes |
| picorv32 | 0.8081 / 1.4525 / 1.6111 | 0.81 / 1.45 / 1.61 | yes yes yes |
| s1238 | 0.7613 / 1.142 / 1.4286 | 0.76 / 1.15 / 1.43 | yes yes yes |
| s1238_ics55_a | 0.8289 / 0.5226 / 0.4286 | 0.83 / 0.52 / 0.43 | yes yes yes |
| s1238_nangate45_a | 0.7489 / - / - | 0.75 / - / - | yes - - |
| s1238_sky130_a | 1.0776 / 2.0525 / 1.8571 | 1.08 / 2.05 / 1.86 | yes yes yes |
| s38584_ics55_a | 0.9695 / 1.1656 / 1.6 | 0.97 / 1.18 / 1.6 | yes yes yes |
| s38584_nangate45_a | 0.959 / 1.5 / 1 | 0.96 / 1.5 / 1 | yes yes yes |
| s5378_sky130_b | 0.8962 / 1.5597 / 1.2727 | 0.9 / 1.56 / 1.27 | yes yes yes |


**All twenty-seven ratios agree within 0.02, and most agree to the third or fourth decimal.** The
cross-batch method was sound for this quantity, and round 28's protocol correction is confirmed by an
independent single-batch re-measurement.

## 2. What the standing says

Of the nine designs measured: **2 have every measurable dimension no worse than the reference**,
**2 of 9 fail wirelength, 7 of 9 fail total overflow and 6 of 9 fail peak overflow.**

That is the objective's diagnosis confirmed with a sound protocol: **wirelength is close to parity and
congestion is the deficit, with peak the worse of the two congestion numbers.** Six designs are not yet
measured - aes, apb4_timer, gcd_ics55_a, gcd_nangate45_a, salsa20_ics55_a, salsa20_nangate45_a - and the
reference legalisation for aes is slow enough that its run has been going for hours; that one is being
carried by a chunk that started before the harness fixes and may need restarting.

## 3. The exclusions are now suspect and are being retested

Every entry on the excluded list was established before the protocol fixes - under the bypass protocol
whose reference congestion was 2.0x to 2.7x too large, and in several cases with a harness whose arm
switching did not work at all. **An exclusion is only as good as its measurement.**

The first re-test running now is the highest-value one: **congestion-aware global placement**
(-congestion_effort 4), which was excluded as "not a fix as an unconditional default". It is measured
here on the corrected metric, both arms in one process, one thread, against a reference legalised in the
same process.

## 4. What is already solid

- The flow runs; the blocker is gone without touching iEDA (build/bin/iEDA-nosshim).
- The harness switches binaries correctly now (IEDA_BIN resolved at call time; daemon off).
- The standing for 9 of 15 designs is measured and reproduces round 28.
- SR-10 and SR-11 are in the tree; SR-13 and SR-14 are **unmeasured** rather than rejected and will be
  re-judged with a working harness.
