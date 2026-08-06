/*
 * @FilePath: congestion_summary.cpp
 * @Description: C-CONG v0 — aggregate EGR overflow CSV maps into JSON
 */

#include "congestion_summary.h"

#include <algorithm>
#include <chrono>
#include <climits>
#include <cmath>
#include <ctime>
#include <filesystem>
#include <fstream>
#include <functional>
#include <iomanip>
#include <numeric>
#include <sstream>
#include <vector>

#include "congestion_eval.h"
#include "general_ops.h"
#include "idm.h"
#include "json/json.hpp"
#include "log/Log.hh"

namespace ieval {

namespace {

std::string overflowFileName(const std::string& stage, const std::string& overflow_type)
{
  return stage + "_egr_" + overflow_type + "_overflow.csv";
}

std::optional<std::filesystem::path> resolveOverflowMapPath(const std::string& rt_dir_path, const std::string& file_name)
{
  std::vector<std::filesystem::path> candidates;
  const std::filesystem::path requested_dir(rt_dir_path);
  candidates.push_back(requested_dir / file_name);
  candidates.push_back(requested_dir / "egr_congestion_map" / file_name);
  if (requested_dir.has_parent_path() && requested_dir.parent_path().has_parent_path()) {
    candidates.push_back(requested_dir.parent_path().parent_path() / "egr_congestion_map" / file_name);
  }
  candidates.push_back(std::filesystem::path(getDefaultOutputPath()) / "egr_congestion_map" / file_name);
  const std::string& feature_path = dmInst->get_config().get_feature_path();
  if (!feature_path.empty()) {
    candidates.push_back(std::filesystem::path(feature_path) / "egr_congestion_map" / file_name);
  }
  const std::string& output_path = dmInst->get_config().get_output_path();
  if (!output_path.empty() && output_path != getDefaultOutputPath()) {
    candidates.push_back(std::filesystem::path(output_path) / "egr_congestion_map" / file_name);
  }

  for (const auto& candidate : candidates) {
    std::error_code error;
    if (std::filesystem::is_regular_file(candidate, error) && !error) {
      return candidate;
    }
  }
  return std::nullopt;
}

std::optional<std::vector<int32_t>> readOverflowValues(const std::filesystem::path& file_path)
{
  std::ifstream file(file_path);
  if (!file.is_open()) {
    return std::nullopt;
  }

  std::vector<int32_t> values;
  std::string line;
  size_t row = 0;
  try {
    while (std::getline(file, line)) {
      ++row;
      std::istringstream stream(line);
      std::string token;
      size_t column = 0;
      while (std::getline(stream, token, ',')) {
        ++column;
        const size_t first = token.find_first_not_of(" \t\r\n");
        const size_t last = token.find_last_not_of(" \t\r\n");
        if (first == std::string::npos) {
          LOG_ERROR << "empty EGR overflow value in " << file_path.string() << " at " << row << ':' << column;
          return std::nullopt;
        }
        const std::string normalized = token.substr(first, last - first + 1);
        size_t parsed_length = 0;
        const double parsed = std::stod(normalized, &parsed_length);
        if (parsed_length != normalized.size() || !std::isfinite(parsed) || parsed < 0.0 || parsed > INT32_MAX
            || std::floor(parsed) != parsed) {
          LOG_ERROR << "invalid EGR overflow value '" << normalized << "' in " << file_path.string() << " at " << row << ':' << column;
          return std::nullopt;
        }
        values.push_back(static_cast<int32_t>(parsed));
      }
    }
  } catch (const std::exception& error) {
    LOG_ERROR << "failed to parse EGR overflow map " << file_path.string() << ": " << error.what();
    return std::nullopt;
  }
  if (values.empty()) {
    LOG_ERROR << "EGR overflow map is empty: " << file_path.string();
    return std::nullopt;
  }
  return values;
}

double topMean(const std::vector<int32_t>& ordered_desc, double fraction)
{
  const size_t count = std::max<size_t>(1, static_cast<size_t>(std::ceil(ordered_desc.size() * fraction)));
  const int64_t top_sum = std::accumulate(ordered_desc.begin(), ordered_desc.begin() + static_cast<std::ptrdiff_t>(count), int64_t{0});
  return static_cast<double>(top_sum) / static_cast<double>(count);
}

OverflowMapStats buildStatsFromValues(const std::string& map_path, const std::vector<int32_t>& values, std::optional<float> weighted_average)
{
  OverflowMapStats stats;
  stats.map_path = map_path;
  stats.bin_count = static_cast<int64_t>(values.size());
  stats.total = std::accumulate(values.begin(), values.end(), int64_t{0});
  stats.max = *std::max_element(values.begin(), values.end());
  stats.mean = static_cast<double>(stats.total) / static_cast<double>(values.size());

  std::vector<int32_t> ordered = values;
  std::sort(ordered.begin(), ordered.end(), std::greater<int32_t>());
  stats.top_1_pct_mean = topMean(ordered, 0.01);
  stats.top_5_pct_mean = topMean(ordered, 0.05);
  stats.nonzero_bin_pct = 100.0 * static_cast<double>(std::count_if(values.begin(), values.end(), [](int32_t v) { return v > 0; }))
                          / static_cast<double>(values.size());
  if (weighted_average && *weighted_average >= 0.0F) {
    stats.weighted_average = static_cast<double>(*weighted_average);
    stats.weighted_average_source = "legacy_weighted_average";
  } else {
    stats.weighted_average = stats.mean;
    stats.weighted_average_source = "csv_mean_fallback";
  }
  stats.valid = true;
  return stats;
}

nlohmann::json directionToJson(const OverflowMapStats& stats)
{
  return nlohmann::json{{"path", stats.map_path},
                        {"bin_count", stats.bin_count},
                        {"total", stats.total},
                        {"max", stats.max},
                        {"mean", stats.mean},
                        {"top_1_pct_mean", stats.top_1_pct_mean},
                        {"top_5_pct_mean", stats.top_5_pct_mean},
                        {"nonzero_bin_pct", stats.nonzero_bin_pct},
                        {"weighted_average", stats.weighted_average},
                        {"weighted_average_source", stats.weighted_average_source},
                        {"valid", stats.valid}};
}

std::string iso8601Now()
{
  const auto now = std::chrono::system_clock::now();
  const std::time_t time = std::chrono::system_clock::to_time_t(now);
  std::tm tm_buf{};
  gmtime_r(&time, &tm_buf);
  std::ostringstream stream;
  stream << std::put_time(&tm_buf, "%Y-%m-%dT%H:%M:%SZ");
  return stream.str();
}

}  // namespace

std::optional<OverflowMapStats> aggregateOverflowMapFile(const std::string& map_path)
{
  const std::filesystem::path path(map_path);
  const auto values = readOverflowValues(path);
  if (!values) {
    return std::nullopt;
  }
  return buildStatsFromValues(path.string(), *values, std::nullopt);
}

std::optional<CongestionSummaryDocument> buildCongestionSummary(const std::string& stage, const std::string& rt_dir_path)
{
  CongestionSummaryDocument document;
  document.stage = stage;

  CongestionEval* eval = CongestionEval::getInst();
  struct DirectionSpec
  {
    std::string type;
    OverflowMapStats CongestionSummaryDocument::* field;
    float (CongestionEval::* weighted_avg)(std::string, std::string);
  };

  const std::vector<DirectionSpec> directions = {
      {"horizontal", &CongestionSummaryDocument::horizontal, &CongestionEval::evalHoriAvgOverflow},
      {"vertical", &CongestionSummaryDocument::vertical, &CongestionEval::evalVertiAvgOverflow},
      {"union", &CongestionSummaryDocument::union_map, &CongestionEval::evalUnionAvgOverflow},
  };

  bool all_valid = true;
  for (const auto& direction : directions) {
    const std::string file_name = overflowFileName(stage, direction.type);
    const auto map_path = resolveOverflowMapPath(rt_dir_path, file_name);
    if (!map_path) {
      all_valid = false;
      continue;
    }
    const auto values = readOverflowValues(*map_path);
    if (!values) {
      all_valid = false;
      continue;
    }
    const float weighted_average = (eval->*direction.weighted_avg)(stage, rt_dir_path);
    document.*(direction.field) = buildStatsFromValues(map_path->string(), *values, weighted_average);
  }

  document.valid = all_valid;
  return document;
}

bool writeCongestionSummaryJson(const std::string& stage, const std::string& rt_dir_path, const std::string& output_path)
{
  const auto document = buildCongestionSummary(stage, rt_dir_path);
  if (!document) {
    return false;
  }

  nlohmann::json payload;
  payload["schema"] = "C-CONG";
  payload["schema_version"] = 1;
  payload["stage"] = document->stage;
  payload["source"] = "egr_csv";
  payload["valid"] = document->valid;
  payload["generated_at"] = iso8601Now();
  payload["maps"] = nlohmann::json{{"horizontal", directionToJson(document->horizontal)},
                                   {"vertical", directionToJson(document->vertical)},
                                   {"union", directionToJson(document->union_map)}};
  payload["summary"] = nlohmann::json{{"average_edge_congestion", document->union_map.weighted_average},
                                      {"total_overflow", document->union_map.total},
                                      {"max_overflow", document->union_map.max},
                                      {"mean", document->union_map.mean},
                                      {"top_1_pct_mean", document->union_map.top_1_pct_mean},
                                      {"top_5_pct_mean", document->union_map.top_5_pct_mean},
                                      {"nonzero_bin_pct", document->union_map.nonzero_bin_pct}};

  try {
    const std::filesystem::path out_path(output_path);
    if (out_path.empty()) {
      LOG_ERROR << "empty congestion summary output path";
      return false;
    }
    if (out_path.has_parent_path()) {
      std::filesystem::create_directories(out_path.parent_path());
    }
    std::ofstream out_file(out_path);
    if (!out_file.is_open()) {
      LOG_ERROR << "failed to open congestion summary output: " << output_path;
      return false;
    }
    out_file << payload.dump(2) << '\n';
  } catch (const std::exception& error) {
    LOG_ERROR << "failed to write congestion summary JSON: " << error.what();
    return false;
  }
  return document->valid;
}

std::optional<CongestionSummaryDocument> readCongestionSummaryJson(const std::string& input_path)
{
  std::ifstream in_file(input_path);
  if (!in_file.is_open()) {
    return std::nullopt;
  }

  nlohmann::json payload;
  try {
    in_file >> payload;
  } catch (const std::exception& error) {
    LOG_ERROR << "failed to parse congestion summary JSON " << input_path << ": " << error.what();
    return std::nullopt;
  }

  CongestionSummaryDocument document;
  document.stage = payload.value("stage", "place");
  document.valid = payload.value("valid", false);

  auto load_direction = [&](const char* key, OverflowMapStats& stats) {
    if (!payload.contains("maps") || !payload["maps"].contains(key)) {
      return;
    }
    const auto& node = payload["maps"][key];
    stats.map_path = node.value("path", "");
    stats.bin_count = node.value("bin_count", 0);
    stats.total = node.value("total", 0);
    stats.max = node.value("max", 0);
    stats.mean = node.value("mean", 0.0);
    stats.top_1_pct_mean = node.value("top_1_pct_mean", 0.0);
    stats.top_5_pct_mean = node.value("top_5_pct_mean", 0.0);
    stats.nonzero_bin_pct = node.value("nonzero_bin_pct", 0.0);
    stats.weighted_average = node.value("weighted_average", 0.0);
    stats.weighted_average_source = node.value("weighted_average_source", "");
    stats.valid = node.value("valid", false);
  };

  load_direction("horizontal", document.horizontal);
  load_direction("vertical", document.vertical);
  load_direction("union", document.union_map);
  return document;
}

}  // namespace ieval
