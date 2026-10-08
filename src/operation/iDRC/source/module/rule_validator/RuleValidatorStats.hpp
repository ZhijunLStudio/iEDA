// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <cstdint>
#include <map>
#include <string>

#include "json/json.hpp"

namespace idrc {

struct RuleRuntimeStats
{
  double runtime_seconds = 0.0;
  int64_t cluster_count = 0;
  int64_t violation_count = 0;
};

struct RuleValidatorRunStats
{
  double runtime_seconds = 0.0;
  int32_t thread_count = 1;
  int64_t cluster_count = 0;
  int64_t verified_cluster_count = 0;
  int64_t stale_cluster_cache_count = 0;
  double peak_rss_mb = 0.0;
  std::map<std::string, RuleRuntimeStats> per_rule;
};

auto buildRuleValidatorStatsJson(const RuleValidatorRunStats& stats) -> nlohmann::ordered_json;

}  // namespace idrc
