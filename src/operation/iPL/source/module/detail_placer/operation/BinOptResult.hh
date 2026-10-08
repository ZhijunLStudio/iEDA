#ifndef IPL_BIN_OPT_RESULT_H
#define IPL_BIN_OPT_RESULT_H

#include <cstdint>
#include <string>

namespace ipl {

enum class BinOptOutcome
{
  kNotRun,
  kCompleted,
  kNoOp,
  kInvalidInput,
  kIllegalOutput
};

struct BinOptResult
{
  BinOptOutcome outcome = BinOptOutcome::kNotRun;
  bool completed = false;
  bool legal = false;
  bool rolled_back = false;
  int64_t candidate_count = 0;
  int64_t changed_count = 0;
  int64_t hpwl_before = 0;
  int64_t hpwl_after = 0;
  std::string reason = "bin optimization has not run";

  bool isSuccessful() const
  {
    return completed && legal && (outcome == BinOptOutcome::kCompleted || outcome == BinOptOutcome::kNoOp);
  }
};

}  // namespace ipl

#endif
