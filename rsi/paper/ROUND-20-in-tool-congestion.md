# Round 20: the tool can now see its own congestion, measured with the project's evaluator

## 1. The failed attempts this round, stated first

**SR-8** (previous round) computed a demand estimate from detail placement's own data. It varied, but
moved opposite to the evaluator on all four designs tried.

**SR-9** completed it with the two things it was missing - a capacity term and a blur - and it still
did not track. The capacity derivation had a unit bug of my own (a length in database units
multiplied by a track count, five orders of magnitude too large, so every bin looked empty); fixing
it gave sensible magnitudes (peak utilisation 0.3 to 5.1, zero to six bins over capacity) but the
direction stayed inverted on the two designs where the evaluator's own numbers exist:

| design | EGR max, GP+LG to +DP | SR-9 utilisation |
|---|---|---|
| s1238_ics55_a | 10 to **14 (worse)** | 1.233 to 1.147 (down) |
| s1238_sky130_a | 78 to **66 (better)** | 3.654 to 5.056 (up) |

That is the third proxy that failed. The lesson is not that the proxies were badly written but that
**approximating an evaluator is strictly worse than calling it**, and this tree already contains one.

## 2. What the tree already had

iPL already links iEDA's evaluation code - ExternalAPI calls iieval::TimingAPI for slack and includes
congestion_api.h. And PLAPI already contains the call that computes exactly the quantity the
objective is scored on:

    void PLAPI::notifyPLCongestionInfo(int stage)
    {
      this->writeBackSourceDataBase();
      iieval::OverflowSummary overflow_summary = _external_api->evalproCongestion();
      PlacerDBInst.egr_tof[stage] = overflow_summary.total_overflow_union;
      PlacerDBInst.egr_mof[stage] = overflow_summary.max_overflow_union;
      ...
    }

evalproCongestion runs iEDA's own EGR model on the shared in-memory design. So the placer can measure
its own congestion in process, at any point, using the same model the scorecard uses.

## 3. SR-10: the measurement inside detail placement's caller

SR-10 calls notifyPLCongestionInfo(2) immediately before and immediately after
detail_place.runDetailPlace() in PLAPI::runDP(), and logs both. Built in 13 s.

**Validation, against the harness's independent measurement of the same thing:**

| design | in-tool EGR, before DP to after DP | harness, GP+LG to LG+DP |
|---|---|---|
| s38584_nangate45_a | max **1 to 4**, total **3 to 21** | max 1 to 4, total 3 to 21 |
| s1238_ics55_a | max 6 to 16, total 70 to 124 | max 12 to 16 (different seed) |
| salsa20_ics55_a | max 34 to 43, total 42618 to 41966 | max 34 to 43 |

**They agree, exactly on s38584_nangate45_a and in both direction and magnitude elsewhere.** The
in-tool number is the real metric, not a proxy.

## 4. Why this matters more than the failed proxies

Every round since Round 8 has tried to make detail placement stop damaging congestion, and every
attempt failed for one reason: the stage could not measure congestion. The density grid is exhausted
as a source (maximum saturated at 1.0, sum saturated at 0.0, both constant on legal placements), a
demand proxy computed from detail placement's own data does not track the score, and the real demand
model in the tree is bound to global placement's instance type.

**That is now resolved by not building a signal at all**: the evaluator is called. Detail placement's
caller knows its congestion effect to the bin, inside the tool, in the metric the objective is scored
on.

## 5. The guard, and why it is not in this round

The action that follows is the one the evidence has pointed at for twelve rounds: keep the detail
placement result only when it does not raise the measured congestion, otherwise keep the legalised
placement. The mechanism is identified and in place:

- PlacerDB::beginStageTransaction / rollbackStageTransaction already exist and
  DetailPlacer::runDetailPlace already uses them, with several rollback paths already implemented.
- Instance::set_shape(ll_x, ll_y, ur_x, ur_y) provides coordinate restore if a manual snapshot is used
  instead.
- The two measurement calls are already in PLAPI::runDP and validated.

It is not implemented this round because the revert has to be correct in the presence of
notifyPLCongestionInfo's own writeBackSourceDataBase() call, which pushes the placer's state into the
shared database the evaluator reads; getting that ordering wrong would corrupt the placement
silently. That is a one-round piece of work with a specific failure mode, and it is the next thing to
do.

## 6. Standing, unchanged

| dimension | median ratio vs reference | no worse |
|---|---|---|
| HPWL | 0.90 | 13 / 15 |
| EGR union | 0.78 | 8 / 13 |
| **EGR max** | **1.35** | **3 / 13** |
| setup WNS | 0.85 | 7 / 7 |
| setup TNS | 0.62 | 6 / 7 |

SR-10 is instrumentation and changes no placement. The two preceding proxies are reverted; SR-10
stays in the tree because it is validated, and it is the prerequisite the guard needs.

## 7. Cost

Two EGR evaluations per detail placement. The probe run took about 90 s per design against a 7.4 s
global placement and a 2.9 s legalisation, so the guard as designed would roughly triple the
post-placement cost of the flow. That is the price of deciding on the real metric rather than a
proxy, and it is worth stating plainly before it is adopted.
