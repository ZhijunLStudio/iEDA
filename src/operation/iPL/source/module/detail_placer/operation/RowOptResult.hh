#ifndef IPL_ROWOPT_RESULT_H
#define IPL_ROWOPT_RESULT_H

#include <cstdint>
#include <string>

namespace ipl {

enum class RowOptOutcome
{
  kNotRun,
  kCompleted,
  kNoOp,
  kInvalidInput,
  kIllegalOutput
};

struct RowOptResult
{
  RowOptOutcome outcome = RowOptOutcome::kNotRun;
  bool completed = false;
  bool legal = false;
  bool rolled_back = false;
  int64_t changed_count = 0;
  int64_t hpwl_before = 0;
  int64_t hpwl_after = 0;
  std::string reason = "row optimization has not run";

  bool isSuccessful() const
  {
    return completed && legal && (outcome == RowOptOutcome::kCompleted || outcome == RowOptOutcome::kNoOp);
  }
};

}  // namespace ipl

#endif
