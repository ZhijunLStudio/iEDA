#include <filesystem>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

#include "FlowScheduler.hh"

namespace {

using ieda::platform::FlowContractError;
using ieda::platform::FlowScheduler;
using ieda::platform::Stage;
using ieda::platform::StageStatus;

void expect(bool condition, const std::string& message)
{
  if (!condition) {
    throw std::runtime_error(message);
  }
}

std::filesystem::path testDirectory(const std::string& name)
{
  const auto path = std::filesystem::temp_directory_path() / ("ieda_flow_scheduler_" + name);
  std::filesystem::remove_all(path);
  std::filesystem::create_directories(path);
  return path;
}

void testGraphValidation()
{
  FlowScheduler missing(testDirectory("missing"));
  missing.registerStage({"sta", {"rcx"}, {}, [] { return true; }, {}, {}});
  bool rejected = false;
  try {
    missing.validateAndTopologicalOrder();
  } catch (const FlowContractError&) {
    rejected = true;
  }
  expect(rejected, "missing dependency must be rejected before execution");

  FlowScheduler cycle(testDirectory("cycle"));
  cycle.registerStage({"a", {"b"}, {}, [] { return true; }, {}, {}});
  cycle.registerStage({"b", {"a"}, {}, [] { return true; }, {}, {}});
  rejected = false;
  try {
    cycle.validateAndTopologicalOrder();
  } catch (const FlowContractError&) {
    rejected = true;
  }
  expect(rejected, "dependency cycle must be rejected before execution");
}

void testOutOfOrderPlanDoesNotRun()
{
  FlowScheduler scheduler(testDirectory("order"));
  int run_count = 0;
  scheduler.registerStage({"rcx", {}, {}, [&run_count] { ++run_count; return true; }, {}, {}});
  scheduler.registerStage({"sta", {"rcx"}, {}, [&run_count] { ++run_count; return true; }, {}, {}});
  bool rejected = false;
  try {
    scheduler.run({"sta", "rcx"});
  } catch (const FlowContractError&) {
    rejected = true;
  }
  expect(rejected, "out-of-order plan must be rejected");
  expect(run_count == 0, "invalid plan must not execute callbacks");
}

void testFailureAbortsChain()
{
  FlowScheduler scheduler(testDirectory("abort"));
  int downstream_runs = 0;
  scheduler.registerStage({"place", {}, {}, [] { return false; }, {}, {}});
  scheduler.registerStage({"route", {"place"}, {}, [&downstream_runs] { ++downstream_runs; return true; }, {}, {}});
  const auto result = scheduler.run();
  expect(!result.ok() && result.failed_stage == "place", "false stage return must fail the flow");
  expect(downstream_runs == 0, "downstream stage must not run after failure");
  expect(scheduler.status("route") == StageStatus::kBlocked, "downstream stage must be marked blocked");
}

void testProductsAndSuccessStamp()
{
  const auto work_dir = testDirectory("products");
  FlowScheduler missing_product(work_dir);
  missing_product.registerStage({"route", {}, {"route.def"}, [] { return true; }, {}, {}});
  auto result = missing_product.run();
  expect(!result.ok(), "missing product must turn callback success into flow failure");
  expect(!std::filesystem::exists(work_dir / ".ieda/stamps/SUCCESS_route"), "failed product assertion must not write success stamp");

  FlowScheduler success(work_dir);
  success.registerStage({"route", {}, {"route.def"}, [work_dir] {
                           std::ofstream output(work_dir / "route.def");
                           output << "VERSION 5.8 ;\n";
                           return static_cast<bool>(output);
                         }, {}, {}});
  result = success.run();
  expect(result.ok(), "stage with required product must succeed");
  expect(std::filesystem::is_regular_file(work_dir / ".ieda/stamps/SUCCESS_route"), "successful stage must write success stamp");
  expect(success.profile().at("route").wall_ms >= 0.0, "successful stage must record wall time");
}

void testRestartRestoreRequiresMatchingIdentityAndProducts()
{
  const auto work_dir = testDirectory("restore");
  int run_count = 0;
  FlowScheduler initial(work_dir);
  initial.setRunIdentity("binary-and-input-manifest-a");
  initial.registerStage({"route", {}, {"route.def"}, [&] {
                           ++run_count;
                           std::ofstream output(work_dir / "route.def");
                           output << "VERSION 5.8 ;\n";
                           return static_cast<bool>(output);
                         }, {}, {}});
  expect(initial.run().ok() && run_count == 1, "initial run must execute and publish its product");

  FlowScheduler resumed(work_dir);
  resumed.setRunIdentity("binary-and-input-manifest-a");
  resumed.registerStage({"route", {}, {"route.def"}, [&] {
                           ++run_count;
                           return true;
                         }, {}, {}});
  const auto restored = resumed.restoreRunState();
  expect(restored == std::vector<std::string>{"route"}, "matching restart must restore the completed stage");
  expect(resumed.run().ok() && run_count == 1, "restored stage must not execute again");

  FlowScheduler changed_identity(work_dir);
  changed_identity.setRunIdentity("binary-and-input-manifest-b");
  changed_identity.registerStage({"route", {}, {"route.def"}, [] { return true; }, {}, {}});
  expect(changed_identity.restoreRunState().empty(), "different run identity must invalidate the checkpoint");

  {
    std::ofstream changed(work_dir / "route.def", std::ios::app);
    changed << "# changed\n";
  }
  FlowScheduler changed_product(work_dir);
  changed_product.setRunIdentity("binary-and-input-manifest-a");
  changed_product.registerStage({"route", {}, {"route.def"}, [] { return true; }, {}, {}});
  expect(changed_product.restoreRunState().empty(), "changed product must invalidate the checkpoint");
}

}  // namespace

int main()
{
  try {
    testGraphValidation();
    testOutOfOrderPlanDoesNotRun();
    testFailureAbortsChain();
    testProductsAndSuccessStamp();
    testRestartRestoreRequiresMatchingIdentityAndProducts();
    std::cout << "FlowScheduler tests passed\n";
    return 0;
  } catch (const std::exception& error) {
    std::cerr << "FlowScheduler test failure: " << error.what() << '\n';
    return 1;
  }
}
