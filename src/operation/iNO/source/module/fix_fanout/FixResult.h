#pragma once

#include <cstddef>
#include <string>
#include <utility>

namespace ino {

enum class FanoutEndpointDisposition
{
  kRepairable,
  kSkipNoLoads,
  kMissingDriver,
};

constexpr FanoutEndpointDisposition classifyFanoutEndpoints(bool has_driver, std::size_t load_count)
{
  if (load_count == 0) {
    return FanoutEndpointDisposition::kSkipNoLoads;
  }
  return has_driver ? FanoutEndpointDisposition::kRepairable : FanoutEndpointDisposition::kMissingDriver;
}

struct FixResult
{
  bool ok = false;
  std::size_t inserted = 0;
  std::string message;

  static FixResult success(std::size_t inserted_count = 0) { return {true, inserted_count, {}}; }
  static FixResult failure(std::string failure_message) { return {false, 0, std::move(failure_message)}; }
};

}  // namespace ino
