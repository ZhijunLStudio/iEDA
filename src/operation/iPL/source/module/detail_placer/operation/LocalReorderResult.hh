#ifndef IPL_LOCAL_REORDER_RESULT_H
#define IPL_LOCAL_REORDER_RESULT_H

#include <cstdint>
#include <string>

namespace ipl {

enum class LocalReorderOutcome
{
  kNotRun,
  kCompleted,
  kNoOp,
  kInvalidInput,
  kIllegalOutput
};

struct LocalReorderResult
{
  LocalReorderOutcome outcome = LocalReorderOutcome::kNotRun;
  bool completed = false;
  bool legal = false;
  bool rolled_back = false;
  int64_t candidate_count = 0;
  int64_t accepted_count = 0;
  int64_t changed_count = 0;
  int64_t window_count = 0;
  int64_t search_count = 0;
  int64_t search_budget = -1;
  int32_t max_window = 2;
  bool budget_exhausted = false;
  int64_t hpwl_before = 0;
  int64_t hpwl_after = 0;
  std::string reason = "local reorder has not run";

  bool isSuccessful() const
  {
    return completed && legal
           && (outcome == LocalReorderOutcome::kCompleted || outcome == LocalReorderOutcome::kNoOp);
  }
};

}  // namespace ipl

#endif
