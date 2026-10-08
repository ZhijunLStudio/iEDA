#pragma once

#include <atomic>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <fstream>
#include <iostream>
#include <string>

namespace irt {

/**
 * @brief Memory budget protection to prevent OOM crashes.
 *
 * Monitors process memory and triggers graceful abort when over budget,
 * so partial routing results can still be saved.
 */
class MemoryBudgetGuard
{
 public:
  explicit MemoryBudgetGuard(size_t max_memory_mb = 8192) : _max_memory_mb(max_memory_mb), _abort_flag(false)
  {
    const char* env_budget = std::getenv("IEDA_RT_MAX_MEMORY_MB");
    if (env_budget) {
      _max_memory_mb = static_cast<size_t>(std::atoi(env_budget));
    }
    std::cerr << "[MemoryBudgetGuard] initialized: max=" << _max_memory_mb << " MB\n";
  }

  bool checkBudget()
  {
    size_t current_mb = getCurrentMemoryUsageMB();
    if (current_mb > _max_memory_mb) {
      if (!_abort_flag.exchange(true)) {
        std::cerr << "[MemoryBudgetGuard] Memory budget exceeded!\n"
                  << "  Current: " << current_mb << " MB\n"
                  << "  Budget: " << _max_memory_mb << " MB\n"
                  << "Aborting gracefully to save partial results...\n";
      }
      return false;
    }
    return true;
  }

  bool isAborted() const { return _abort_flag.load(); }

  size_t getCurrentMemoryUsageMB() const
  {
#ifdef __linux__
    std::ifstream status("/proc/self/status");
    std::string line;
    while (std::getline(status, line)) {
      if (line.substr(0, 6) == "VmRSS:") {
        size_t kb = 0;
        if (std::sscanf(line.c_str(), "VmRSS: %zu kB", &kb) == 1) {
          return kb / 1024;
        }
      }
    }
#endif
    return 0;
  }

  size_t getMaxMemoryMB() const { return _max_memory_mb; }

 private:
  size_t _max_memory_mb;
  std::atomic<bool> _abort_flag;
};

}  // namespace irt
