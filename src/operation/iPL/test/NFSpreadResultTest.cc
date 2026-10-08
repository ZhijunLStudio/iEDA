#include "operation/NFSpreadResult.hh"

#include <cstdlib>
#include <iostream>

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << message << '\n';
  }
  return condition;
}

}  // namespace

int main()
{
  bool ok = true;

  const ipl::NFSpreadResult no_overflow{
      .execution_success = true,
      .feasible = true,
      .no_progress = false,
      .moved_count = 0,
      .overflow_before = 0,
      .overflow_after = 0,
      .iterations = 0,
      .reason = "network flow spread had no overflow to reduce"};
  ok &= require(no_overflow.isSuccessful(), "an already feasible layout must be a successful no-op");

  const ipl::NFSpreadResult no_path{
      .execution_success = false,
      .feasible = false,
      .no_progress = true,
      .moved_count = 0,
      .overflow_before = 100,
      .overflow_after = 100,
      .iterations = 1,
      .reason = "network flow spread found no feasible path for overflow"};
  ok &= require(!no_path.isSuccessful() && no_path.no_progress && no_path.overflow_after >= no_path.overflow_before,
                "an infeasible no-progress result must fail");

  const ipl::NFSpreadResult improved{
      .execution_success = true,
      .feasible = true,
      .no_progress = false,
      .moved_count = 2,
      .overflow_before = 100,
      .overflow_after = 20,
      .iterations = 3,
      .reason = "network flow spread reduced overflow"};
  ok &= require(improved.isSuccessful() && improved.moved_count > 0 && improved.overflow_after < improved.overflow_before,
                "a feasible movement result must report progress");

  const ipl::NFSpreadResult moved_without_improvement{
      .execution_success = false,
      .feasible = false,
      .no_progress = true,
      .moved_count = 1,
      .overflow_before = 100,
      .overflow_after = 100,
      .iterations = 1,
      .reason = "network flow spread made no measurable overflow progress"};
  ok &= require(!moved_without_improvement.isSuccessful() && moved_without_improvement.moved_count > 0,
                "movement without overflow improvement must not report success");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
