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

    ieco::ECOViaConfig config;
    config.eco_layers.insert("M2");
    ieco::ECOViaShapeRequest request{"M2", {0, 0, 10, 10}, "N1", "shape_1"};
    const auto accepted = ieco::evaluateShapeRequest(request, config, {2, 1, true, true}, "baseline_hash");
    require(accepted.state == ieco::ECORequestState::kAccepted, "accepted request should remain accepted");
    require(accepted.ok(), "accepted shape request should pass");
    require(accepted.changed_shape_count == 1, "accepted request should report one changed shape");
    require(accepted.via_count == 1, "accepted request should report one via");
    require(accepted.oracle.improved(), "oracle should show improvement");
    const std::string accepted_json = ieco::ecoViaReportJson(accepted);
    require(accepted_json.find("\"schema_version\": \"ieda.eco.via_report.v1\"") != std::string::npos,
            "report schema version missing");
    require(accepted_json.find("\"request_state\": \"accepted\"") != std::string::npos, "report schema missing accepted state");
    require(accepted_json.find("\"changed_shape_count\": 1") != std::string::npos, "report missing changed shape count");
    require(accepted_json.find("\"affected_nets\"") != std::string::npos, "report missing affected nets");
    require(ieco::writeEcoViaReportJson(accepted, "/tmp/eco_via_report.json"), "eco_via_report.json write failed");
    require(readFile("/tmp/eco_via_report.json").find("\"schema_version\": \"ieda.eco.via_report.v1\"") != std::string::npos,
            "eco_via_report.json schema missing");

    const auto rolled_back = ieco::evaluateShapeRequest(request, config, {2, 4, false, true}, "baseline_hash");
    require(rolled_back.state == ieco::ECORequestState::kRolledBack, "failed oracle should rollback");
    require(rolled_back.rolledBack(), "rollback flag missing");
    require(rolled_back.rollback_hash == rolled_back.baseline_hash, "rollback hash must match baseline");
    require(rolled_back.committed_hash.empty(), "rolled back commit hash must be empty");
    const std::string rolled_back_json = ieco::ecoViaReportJson(rolled_back);
    require(rolled_back_json.find("\"request_state\": \"rolled_back\"") != std::string::npos, "report schema missing rollback state");
    require(rolled_back_json.find("\"rollback_matches_baseline\": true") != std::string::npos, "rollback proof missing");

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
