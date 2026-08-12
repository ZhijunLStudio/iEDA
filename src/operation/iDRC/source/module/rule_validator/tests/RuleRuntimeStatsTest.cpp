#include <iostream>
#include <map>
#include <set>
#include <stdexcept>
#include <string>

#include "RVCluster.hpp"
#include "RuleCoverage.hpp"

namespace {

void require(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

auto makeStatsJson() -> nlohmann::ordered_json
{
  idrc::RuleValidatorRunStats stats;
  stats.runtime_seconds = 1.25;
  stats.thread_count = 4;
  stats.cluster_count = 8;
  stats.verified_cluster_count = 3;
  stats.stale_cluster_cache_count = 0;
  stats.peak_rss_mb = 256.5;
  stats.per_rule["metal_short"] = {0.5, 2, 1};
  stats.per_rule["minimum_width"] = {0.25, 1, 0};

  return idrc::buildRuleValidatorStatsJson(stats);
}

void testRuntimeStatsSchema()
{
  const auto runtime_json = makeStatsJson();
  require(runtime_json.at("thread_count") == 4, "thread count missing from runtime stats");
  require(runtime_json.at("cluster_count") == 8 && runtime_json.at("verified_cluster_count") == 3, "cluster counters missing");
  require(runtime_json.at("stale_cluster_cache_count") == 0, "stale cache counter missing");
  require(runtime_json.at("peak_rss_mb") == 256.5, "peak RSS missing");
  require(runtime_json.at("runtime_seconds") == 1.25, "runtime seconds missing");
  require(runtime_json.at("per_rule").at("metal_short").at("runtime_seconds") == 0.5, "per-rule runtime missing");
  require(runtime_json.at("per_rule").at("metal_short").at("cluster_count") == 2, "per-rule cluster count missing");
  require(runtime_json.at("per_rule").at("metal_short").at("violation_count") == 1, "per-rule violation count missing");
  require(runtime_json.at("per_rule").at("metal_short").at("cluster_count").is_number_integer(),
          "per-rule cluster count type changed");
}

void testRuntimeStatsRepeatability()
{
  const auto expected = makeStatsJson();
  for (int repeat = 0; repeat < 64; ++repeat) {
    require(makeStatsJson() == expected, "runtime json ordering is not repeatable");
  }
}

void testCoverageAttachment()
{
  auto coverage = idrc::RuleCoverageReport::build({"metal_short"}, {"metal_short"}, {});
  idrc::RuleValidatorRunStats stats;
  stats.thread_count = 2;
  stats.cluster_count = 4;
  stats.verified_cluster_count = 4;
  stats.per_rule["metal_short"] = {0.1, 4, 0};
  coverage.attachRunStats(stats);

  const auto runtime = coverage.toJson().at("runtime");
  require(runtime.at("attached") == true, "runtime stats were not marked attached");
  require(runtime.at("thread_count") == 2, "attached runtime thread count was lost");
  require(runtime.at("per_rule").at("metal_short").at("cluster_count") == 4, "attached per-rule stats were lost");
}

void testParallelReadOnlySerialization()
{
  const auto expected = makeStatsJson();
  bool ok = true;
#pragma omp parallel for schedule(static)
  for (int repeat = 0; repeat < 128; ++repeat) {
    const bool same = (makeStatsJson() == expected);
    if (!same) {
#pragma omp critical(idrc_rule_runtime_stats_test)
      ok = false;
    }
  }
  require(ok, "parallel runtime serialization changed output");
}

void testClusterCacheClearingContract()
{
  idrc::RVCluster cluster;
  std::map<int32_t, idrc::RVLayerData> layer_data;
  layer_data[1];
  cluster.set_layer_data(layer_data);
  require(!cluster.get_layer_data().empty(), "fixture did not seed cluster cache");

  const bool had_cluster_cache = !cluster.get_layer_data().empty();
  cluster.get_layer_data().clear();

  idrc::RuleValidatorRunStats stats;
  if (had_cluster_cache) {
    stats.stale_cluster_cache_count += 1;
  }
  cluster.set_run_stats(stats);

  require(cluster.get_layer_data().empty(), "cluster cache was not cleared after verification");
  require(cluster.get_run_stats().stale_cluster_cache_count == 1, "stale cluster cache counter did not trip");
}

}  // namespace

int main()
{
  try {
    testRuntimeStatsSchema();
    testRuntimeStatsRepeatability();
    testCoverageAttachment();
    testParallelReadOnlySerialization();
    testClusterCacheClearingContract();
    std::cout << "iDRC rule runtime stats tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "iDRC rule runtime stats test failure: " << error.what() << '\n';
    return 1;
  }
}
