/*
 * @FilePath: congestion_summary.h
 * @Description: C-CONG v0 — EGR overflow map aggregation contract
 */

#pragma once

#include <cstdint>
#include <optional>
#include <string>

namespace ieval {

struct OverflowMapStats
{
  std::string map_path;
  int64_t bin_count{0};
  int64_t total{0};
  int32_t max{0};
  double mean{0.0};
  double top_1_pct_mean{0.0};
  double top_5_pct_mean{0.0};
  double nonzero_bin_pct{0.0};
  double weighted_average{0.0};
  std::string weighted_average_source;
  bool valid{false};
};

struct CongestionSummaryDocument
{
  std::string stage;
  bool valid{false};
  OverflowMapStats horizontal;
  OverflowMapStats vertical;
  OverflowMapStats union_map;
};

bool writeCongestionSummaryJson(const std::string& stage, const std::string& rt_dir_path, const std::string& output_path);

std::optional<CongestionSummaryDocument> readCongestionSummaryJson(const std::string& input_path);

std::optional<OverflowMapStats> aggregateOverflowMapFile(const std::string& map_path);

std::optional<CongestionSummaryDocument> buildCongestionSummary(const std::string& stage, const std::string& rt_dir_path);

}  // namespace ieval
