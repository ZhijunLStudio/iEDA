#ifndef IPL_INSTANCE_SWAP_RESULT_H
#define IPL_INSTANCE_SWAP_RESULT_H

#include <cstdint>
#include <string>

namespace ipl {

enum class InstanceSwapOutcome
{
  kNotRun,
  kCompleted,
  kNoOp,
  kInvalidInput,
  kIllegalOutput,
  kRollbackFailed
};

struct InstanceSwapResult
{
  InstanceSwapOutcome outcome = InstanceSwapOutcome::kNotRun;
  bool completed = false;
  bool legal = false;
  bool rolled_back = false;
  int64_t candidate_count = 0;
  int64_t accepted_count = 0;
  int64_t changed_count = 0;
  int64_t hpwl_before = 0;
  int64_t hpwl_after = 0;
  std::string reason = "instance swap has not run";

  bool isSuccessful() const
  {
    return completed && legal
           && (outcome == InstanceSwapOutcome::kCompleted || outcome == InstanceSwapOutcome::kNoOp);
  }
};

}  // namespace ipl

#endif
