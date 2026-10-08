#include "FixResult.h"

#include <iostream>

int main()
{
  using ino::FanoutEndpointDisposition;
  using ino::classifyFanoutEndpoints;

  if (classifyFanoutEndpoints(true, 0) != FanoutEndpointDisposition::kSkipNoLoads
      || classifyFanoutEndpoints(false, 0) != FanoutEndpointDisposition::kSkipNoLoads) {
    std::cerr << "a net without loads must be skipped\n";
    return 1;
  }
  if (classifyFanoutEndpoints(false, 1) != FanoutEndpointDisposition::kMissingDriver) {
    std::cerr << "a loaded net without a driver must fail\n";
    return 1;
  }
  if (classifyFanoutEndpoints(true, 1) != FanoutEndpointDisposition::kRepairable) {
    std::cerr << "a driven net with loads must be repairable\n";
    return 1;
  }

  const auto failure = ino::FixResult::failure("missing driver");
  if (failure.ok || failure.message != "missing driver") {
    std::cerr << "failure details were not preserved\n";
    return 1;
  }

  return 0;
}
