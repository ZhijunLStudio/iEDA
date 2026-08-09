#pragma once

#include <cstdint>
#include <string>

namespace ipl {

struct NFSpreadResult
{
  bool execution_success = false;
  bool feasible = false;
  bool no_progress = false;
  int64_t moved_count = 0;
  int64_t overflow_before = 0;
  int64_t overflow_after = 0;
  int32_t iterations = 0;
  std::string reason = "network flow spread has not run";

  bool isSuccessful() const
  {
    return execution_success && feasible && !no_progress;
  }
};

}  // namespace ipl
