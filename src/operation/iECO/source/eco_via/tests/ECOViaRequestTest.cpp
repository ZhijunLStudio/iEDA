#include "ieco_via.h"

#include <fstream>
#include <iostream>
#include <iterator>
#include <optional>
#include <stdexcept>
#include <string>

namespace {

void require(bool condition, const char* message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

std::string readFile(const std::string& path)
{
  std::ifstream input(path);
  return {std::istreambuf_iterator<char>(input), std::istreambuf_iterator<char>()};
}

}  // namespace

int main()
{
  try {
    const auto shape = ieco::parseECOViaRequest("shape");
    require(shape.status == ieco::ECOViaStatus::kSuccess, "shape request was rejected");
    require(shape.type == ieco::ECOViaType::kECOViaByShape, "shape request selected the wrong algorithm");

    const auto pattern = ieco::parseECOViaRequest("pattern");
    require(pattern.status == ieco::ECOViaStatus::kUnsupported, "unimplemented pattern request did not fail explicitly");
    require(pattern.type == ieco::ECOViaType::kECOViaByPattern, "pattern request lost its provenance");

    const auto unknown = ieco::parseECOViaRequest("typo");
    require(unknown.status == ieco::ECOViaStatus::kInvalidType, "unknown request silently selected an algorithm");
    require(unknown.type == ieco::ECOViaType::kECONone, "unknown request fell back to shape repair");

    require(ieco::ECOViaResult{ieco::ECOViaStatus::kSuccess, 0}.ok(), "zero repairs must remain a successful shape result");
    require(!ieco::ECOViaResult{ieco::ECOViaStatus::kUnsupported, 0}.ok(), "unsupported repair reported success");
    const auto legacy_shape = ieco::evaluateLegacyViaRequest("shape");
    require(legacy_shape.status == ieco::ECOViaStatus::kRejected, "legacy shape entry must fail closed without oracle");
    require(!legacy_shape.ok(), "legacy shape entry must not report success");
    require(legacy_shape.reason.find("structured") != std::string::npos, "legacy shape rejection reason missing");

    ieco::ECOViaConfig config;
    config.eco_layers.insert("M2");
    ieco::ECOViaShapeRequest request{"M2", {0, 0, 10, 10}, "N1", "shape_1"};
    const auto accepted = ieco::evaluateShapeRequest(request, config, {2, 1, true, true}, "baseline_hash");
    require(accepted.state == ieco::ECORequestState::kAccepted, "accepted request should remain accepted");
    require(accepted.ok(), "accepted shape request should pass");
    require(accepted.changed_shape_count == 1, "accepted request should report one changed shape");
    require(accepted.via_count == 1, "accepted request should report one via");
    require(accepted.oracle.drcImprovement() == 1, "oracle should report explicit DRC improvement");
    require(accepted.oracle.improved(), "oracle should show improvement");
    const std::string accepted_json = ieco::ecoViaReportJson(accepted);
    require(accepted_json.find("\"schema_version\": \"ieda.eco.via_report.v1\"") != std::string::npos,
            "report schema version missing");
    require(accepted_json.find("\"request_state\": \"accepted\"") != std::string::npos, "report schema missing accepted state");
    require(accepted_json.find("\"changed_shape_count\": 1") != std::string::npos, "report missing changed shape count");
    require(accepted_json.find("\"drc_improvement\": 1") != std::string::npos, "report missing DRC improvement");
    require(accepted_json.find("\"delegated_to_platform_or_irt\": true") != std::string::npos, "routeECO delegation proof missing");
    require(accepted_json.find("\"affected_nets\"") != std::string::npos, "report missing affected nets");
    require(ieco::writeEcoViaReportJson(accepted, "/tmp/eco_via_report.json"), "eco_via_report.json write failed");
    require(readFile("/tmp/eco_via_report.json").find("\"schema_version\": \"ieda.eco.via_report.v1\"") != std::string::npos,
            "eco_via_report.json schema missing");

    const auto drc_rolled_back = ieco::evaluateShapeRequest(request, config, {2, 4, true, true}, "baseline_hash");
    require(drc_rolled_back.state == ieco::ECORequestState::kRolledBack, "worse DRC should rollback");
    require(drc_rolled_back.rolledBack(), "rollback flag missing");
    require(drc_rolled_back.rollback_hash == drc_rolled_back.baseline_hash, "rollback hash must match baseline");
    require(drc_rolled_back.committed_hash.empty(), "rolled back commit hash must be empty");
    const std::string rolled_back_json = ieco::ecoViaReportJson(drc_rolled_back);
    require(rolled_back_json.find("\"request_state\": \"rolled_back\"") != std::string::npos, "report schema missing rollback state");
    require(rolled_back_json.find("\"rollback_matches_baseline\": true") != std::string::npos, "rollback proof missing");

    const auto connectivity_rolled_back = ieco::evaluateShapeRequest(request, config, {2, 1, false, true}, "baseline_hash");
    require(connectivity_rolled_back.state == ieco::ECORequestState::kRolledBack, "bad connectivity should rollback");

    const auto route_rolled_back = ieco::evaluateShapeRequest(request, config, {2, 1, true, false}, "baseline_hash");
    require(route_rolled_back.state == ieco::ECORequestState::kRolledBack, "illegal route should rollback");

    ieco::ECOViaConfig full_config = config;
    full_config.request_index = 10;
    full_config.full_oracle_period = 5;
    require(ieco::requiresFullOracle(full_config), "periodic full oracle should be required at request index");
    const auto missing_full_oracle = ieco::evaluateShapeRequest(request, full_config, {2, 1, true, true}, "baseline_hash");
    require(missing_full_oracle.state == ieco::ECORequestState::kRolledBack, "missing required full oracle should rollback");
    const std::string missing_full_json = ieco::ecoViaReportJson(missing_full_oracle);
    require(missing_full_json.find("\"required\": true") != std::string::npos, "full oracle requirement missing");

    full_config.full_oracle = ieco::ECOFullOracleResult{true, true, true, false, "iSTA full oracle failed"};
    const auto failed_full_oracle = ieco::evaluateShapeRequest(request, full_config, {2, 1, true, true}, "baseline_hash");
    require(failed_full_oracle.state == ieco::ECORequestState::kRolledBack, "failed full oracle should rollback");
    require(failed_full_oracle.reason.find("iSTA") != std::string::npos, "full oracle failure reason missing");

    full_config.full_oracle = ieco::ECOFullOracleResult{true, true, true, true, ""};
    const auto full_oracle_accepted = ieco::evaluateShapeRequest(request, full_config, {2, 1, true, true}, "baseline_hash");
    require(full_oracle_accepted.state == ieco::ECORequestState::kAccepted, "passed full oracle should accept");

    ieco::ECOViaConfig runner_config = config;
    runner_config.request_index = 6;
    runner_config.full_oracle_period = 3;
    bool ran_irt = false;
    bool ran_idrc = false;
    bool ran_ista = false;
    ieco::ECOFullOracleProbes probes;
    probes.run_irt = [&ran_irt] {
      ran_irt = true;
      return ieco::ECOFullOracleResult::Probe{true, true, "iRT", ""};
    };
    probes.run_idrc = [&ran_idrc] {
      ran_idrc = true;
      return ieco::ECOFullOracleResult::Probe{true, true, "iDRC", ""};
    };
    probes.run_ista = [&ran_ista] {
      ran_ista = true;
      return ieco::ECOFullOracleResult::Probe{true, true, "iSTA", ""};
    };
    const auto runner_accepted
        = ieco::evaluateShapeRequestWithFullOracle(request, runner_config, {2, 1, true, true}, "baseline_hash", probes);
    require(runner_accepted.state == ieco::ECORequestState::kAccepted, "passed full oracle probes should accept");
    require(ran_irt && ran_idrc && ran_ista, "periodic full oracle should run iRT/iDRC/iSTA probes");
    const std::string runner_json = ieco::ecoViaReportJson(runner_accepted);
    require(runner_json.find("\"source\": \"iRT\"") != std::string::npos, "iRT probe source missing");
    require(runner_json.find("\"source\": \"iDRC\"") != std::string::npos, "iDRC probe source missing");
    require(runner_json.find("\"source\": \"iSTA\"") != std::string::npos, "iSTA probe source missing");

    ieco::ECOFullOracleProbes missing_probe;
    missing_probe.run_irt = probes.run_irt;
    missing_probe.run_idrc = probes.run_idrc;
    const auto missing_probe_result
        = ieco::evaluateShapeRequestWithFullOracle(request, runner_config, {2, 1, true, true}, "baseline_hash", missing_probe);
    require(missing_probe_result.state == ieco::ECORequestState::kRolledBack, "missing iSTA probe should rollback");
    require(missing_probe_result.reason.find("iSTA") != std::string::npos, "missing iSTA probe reason missing");

    ieco::ECOViaConfig direct_write_config = config;
    direct_write_config.route_edit_owner = ieco::ECORouteEditOwner::kIECO;
    direct_write_config.direct_db_route_write_requested = true;
    const auto direct_write = ieco::evaluateShapeRequest(request, direct_write_config, {2, 1, true, true}, "baseline_hash");
    require(direct_write.state == ieco::ECORequestState::kRejected, "iECO direct route DB write should reject");
    require(direct_write.reason.find("route") != std::string::npos, "routeECO ownership reason missing");

    const auto rejected = ieco::evaluateShapeRequest(std::nullopt, config, {1, 0, true, true}, "baseline_hash");
    require(rejected.state == ieco::ECORequestState::kRejected, "missing request should reject");
    require(rejected.status == ieco::ECOViaStatus::kRejected, "missing request should map to rejected status");

    ieco::ECOViaConfig frozen_config;
    frozen_config.freeze_layers.insert("M2");
    const auto frozen = ieco::evaluateShapeRequest(request, frozen_config, {2, 1, true, true}, "baseline_hash");
    require(frozen.state == ieco::ECORequestState::kRejected, "frozen layer request should reject");
    require(frozen.reason.find("frozen") != std::string::npos, "frozen layer rejection reason missing");

    std::cout << "iECO via request tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << error.what() << '\n';
    return 1;
  }
}
