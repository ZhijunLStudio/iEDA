#include "config/Config.hh"

#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

auto loadJson(const std::string& path) -> nlohmann::json
{
  std::ifstream stream(path);
  nlohmann::json json;
  stream >> json;
  return json;
}

}  // namespace

int main()
{
  bool ok = true;
  const std::string config_path = IPL_TEST_CONFIG_PATH;
  const auto valid_json = loadJson(config_path);

  auto validation = ipl::Config::validateJson(valid_json);
  ok &= require(validation.valid, "production placement config must satisfy the typed schema");

  auto missing = valid_json;
  missing["PL"]["GP"]["Nesterov"].erase("max_iter");
  validation = ipl::Config::validateJson(missing);
  ok &= require(!validation.valid && validation.path == "$.PL.GP.Nesterov.max_iter",
                "missing required key must report its full path");

  auto unknown = valid_json;
  unknown["PL"]["GP"]["Density"]["target_densitty"] = 0.7;
  validation = ipl::Config::validateJson(unknown);
  ok &= require(!validation.valid && validation.path == "$.PL.GP.Density.target_densitty",
                "unknown key must be rejected without mutating the JSON");

  auto wrong_type = valid_json;
  wrong_type["PL"]["num_threads"] = "8";
  validation = ipl::Config::validateJson(wrong_type);
  ok &= require(!validation.valid && validation.path == "$.PL.num_threads", "wrong scalar type must be rejected");

  auto bad_range = valid_json;
  bad_range["PL"]["GP"]["Density"]["target_density"] = 1.0;
  validation = ipl::Config::validateJson(bad_range);
  ok &= require(!validation.valid && validation.path == "$.PL.GP", "typed Nesterov range validation must reject invalid density");

  auto optional_padding = valid_json;
  optional_padding["PL"]["GP"].erase("global_right_padding");
  validation = ipl::Config::validateJson(optional_padding);
  ok &= require(validation.valid, "legacy config may omit optional GP global padding");

  const std::filesystem::path malformed_path = "/tmp/ipl_config_validation_malformed.json";
  {
    std::ofstream stream(malformed_path);
    stream << "{\"PL\":";
  }
  validation = ipl::Config::validateFile(malformed_path.string());
  ok &= require(!validation.valid && validation.reason.find("malformed JSON") != std::string::npos,
                "malformed JSON file must return a non-fatal validation result");

  ipl::Config first(config_path);
  ipl::Config second(config_path);
  ok &= require(first.effectiveConfigJson() == second.effectiveConfigJson(), "effective config must be deterministic");
  ok &= require(first.effectiveConfigHash() == second.effectiveConfigHash() && first.effectiveConfigHash().size() == 16,
                "effective config hash must be stable and fixed-width");
  ok &= require(ipl::Config::validateJson(first.effectiveConfigJson()).valid,
                "effective config must round-trip through the same schema");
  ok &= require(first.effectiveConfigJson().at("PL").at("GP").contains("global_right_padding"),
                "effective config must materialize optional defaults");

  std::filesystem::remove(malformed_path);
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
