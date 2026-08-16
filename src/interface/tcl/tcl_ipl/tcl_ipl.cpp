// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan PSL v2.
// You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
// EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
// MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************
#include "tcl_ipl.h"

#include <glog/logging.h>

#include <sstream>

#include "IdbInstance.h"
#include "PLAPI.hh"
#include "PlacementResult.hh"
#include "idm.h"
#include "ipl_io.h"
#include "log/Log.hh"
#include "tool_manager.h"
namespace tcl {
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerAutoRun::CmdPlacerAutoRun(const char* cmd_name) : TclCmd(cmd_name)
{
  auto* file_name_option = new TclStringOption(TCL_CONFIG, 1, nullptr);
  addOption(file_name_option);

  auto *json_output_option = new TclSwitchOption("-json");
  addOption(json_output_option);
}

unsigned CmdPlacerAutoRun::check()
{
  TclOption* file_name_option = getOptionOrArg(TCL_CONFIG);
  LOG_FATAL_IF(!file_name_option);
  return 1;
}

unsigned CmdPlacerAutoRun::exec()
{
  if (!check()) {
    return 0;
  }

  TclOption* option = getOptionOrArg(TCL_CONFIG);
  auto data_config = option->getStringVal();

  bool enable_json_output = false;
  TclOption* json_output_option = getOptionOrArg("-json");
  if (json_output_option->is_set_val()) {
    enable_json_output = true;
  }

  const bool placement_succeeded = iplf::tmInst->autoRunPlacer(data_config, enable_json_output);
  if (!placement_succeeded) {
    std::cerr << "iPL run failed; see place_summary.json." << std::endl;
    return ipl::placementTclResult(false);
  }

  std::cout << "iPL run successfully." << std::endl;
  return ipl::placementTclResult(true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerFiller::CmdPlacerFiller(const char* cmd_name) : TclCmd(cmd_name)
{
  auto* file_name_option = new TclStringOption(TCL_CONFIG, 1, nullptr);
  addOption(file_name_option);
}

unsigned CmdPlacerFiller::check()
{
  TclOption* file_name_option = getOptionOrArg(TCL_CONFIG);
  LOG_FATAL_IF(!file_name_option);
  return 1;
}

unsigned CmdPlacerFiller::exec()
{
  if (!check()) {
    return 0;
  }

  TclOption* option = getOptionOrArg(TCL_CONFIG);
  auto data_config = option->getStringVal();

  const bool filler_succeeded = iplf::tmInst->runPlacerFiller(data_config);
  if (!filler_succeeded) {
    std::cerr << "iPL filler run failed." << std::endl;
    return ipl::placementTclResult(false);
  }

  std::cout << "iPL filler run successfully." << std::endl;
  return ipl::placementTclResult(true);
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerIncrementalFlow::CmdPlacerIncrementalFlow(const char* cmd_name) : TclCmd(cmd_name)
{
  auto* file_name_option = new TclStringOption(TCL_CONFIG, 1, nullptr);
  addOption(file_name_option);
}

unsigned CmdPlacerIncrementalFlow::check()
{
  TclOption* file_name_option = getOptionOrArg(TCL_CONFIG);
  LOG_FATAL_IF(!file_name_option);
  return 1;
}

unsigned CmdPlacerIncrementalFlow::exec()
{
  if (!check()) {
    return 0;
  }

  TclOption* option = getOptionOrArg(TCL_CONFIG);
  auto data_config = option->getStringVal();

  const bool incremental_succeeded = iplf::tmInst->runPlacerIncrementalFlow(data_config);
  if (!incremental_succeeded) {
    std::cerr << "iPL incremental flow run failed." << std::endl;
    return ipl::placementTclResult(false);
  }

  std::cout << "iPL incremental flow run successfully." << std::endl;
  return ipl::placementTclResult(true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerIncrementalLG::CmdPlacerIncrementalLG(const char* cmd_name) : TclCmd(cmd_name)
{
}

unsigned CmdPlacerIncrementalLG::check()
{
  return 1;
}

unsigned CmdPlacerIncrementalLG::exec()
{
  if (not check()) {
    return 0;
  }
  auto* inst = iplf::PlacerIO::getInstance();
  inst->runIncrementalLegalization();
  return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerCheckLegality::CmdPlacerCheckLegality(const char* cmd_name) : TclCmd(cmd_name)
{
}

unsigned CmdPlacerCheckLegality::check()
{
  return 1;
}

unsigned CmdPlacerCheckLegality::exec()
{
  auto* inst = iplf::PlacerIO::getInstance();
  bool flag = inst->checkLegality();

  if (flag) {
    std::cout << "Current Placement is Legal" << std::endl;
    return 1;
  } else {
    std::cout << "Current Placement is Not Legal" << std::endl;
    return 0;
  }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerInit::CmdPlacerInit(const char* cmd_name) : TclCmd(cmd_name)
{
  addOption(new TclStringOption(TCL_CONFIG, 1, nullptr));
}

unsigned CmdPlacerInit::check()
{
  LOG_FATAL_IF(!getOptionOrArg(TCL_CONFIG));
  return 1;
}

unsigned CmdPlacerInit::exec()
{
  if (not check()) {
    return 0;
  }
  auto* config_json = getOptionOrArg(TCL_CONFIG)->getStringVal();
  auto* inst = iplf::PlacerIO::getInstance();
  inst->initPlacer(config_json);
  return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerDestroy::CmdPlacerDestroy(const char* cmd_name) : TclCmd(cmd_name)
{
}

unsigned CmdPlacerDestroy::check()
{
  return 1;
}

unsigned CmdPlacerDestroy::exec()
{
  auto* inst = iplf::PlacerIO::getInstance();
  inst->destroyPlacer();
  return 1;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerRunGP::CmdPlacerRunGP(const char* cmd_name) : TclCmd(cmd_name)
{
  auto* mode_option = new TclStringOption("-mode", 1, nullptr);
  addOption(mode_option);

  auto* iterations_option = new TclIntOption("-iterations", 1, 20);
  addOption(iterations_option);

  auto* random_init_option = new TclIntOption("-random_init", 1, 1);
  addOption(random_init_option);

  auto* seed_option = new TclIntOption("-seed", 1, 1000);
  addOption(seed_option);

  auto* target_density_option = new TclDoubleOption("-target_density", 1, -1.0);
  addOption(target_density_option);

  auto* init_density_penalty_option = new TclDoubleOption("-init_density_penalty", 1, -1.0);
  addOption(init_density_penalty_option);

  auto* min_phi_option = new TclDoubleOption("-min_phi_coef", 1, -1.0);
  addOption(min_phi_option);

  auto* max_phi_option = new TclDoubleOption("-max_phi_coef", 1, -1.0);
  addOption(max_phi_option);

  auto* congestion_effort_option = new TclIntOption("-congestion_effort", 1, -1);
  addOption(congestion_effort_option);

  auto* checkpoint_option = new TclStringOption("-checkpoint", 1, nullptr);
  addOption(checkpoint_option);

  auto* scope_option = new TclStringOption("-scope", 1, "global");
  addOption(scope_option);

  auto* scope_ratio_option = new TclDoubleOption("-scope_active_ratio", 1, 0.2);
  addOption(scope_ratio_option);

  auto* scope_count_option = new TclIntOption("-scope_active_count", 1, 0);
  addOption(scope_count_option);

  auto* halo_option = new TclDoubleOption("-scope_halo_coeff", 1, 0.5);
  addOption(halo_option);

  auto* halo_hops_option = new TclIntOption("-scope_halo_hops", 1, 1);
  addOption(halo_hops_option);

  auto* scope_seed_option = new TclIntOption("-scope_seed", 1, 1000);
  addOption(scope_seed_option);

  auto* scope_instances_option = new TclStringOption("-scope_instances", 1, nullptr);
  addOption(scope_instances_option);

  auto* scope_region_option = new TclStringOption("-scope_region", 1, nullptr);
  addOption(scope_region_option);

  auto* scope_density_target_option = new TclDoubleOption("-scope_density_target", 1, 1.0);
  addOption(scope_density_target_option);

  auto* scope_density_ratio_option = new TclDoubleOption("-scope_density_ratio", 1, 0.0);
  addOption(scope_density_ratio_option);

  auto* report_top_n_option = new TclIntOption("-report_top_n", 1, 64);
  addOption(report_top_n_option);

  auto* report_route_util_option = new TclIntOption("-report_route_util", 1, 0);
  addOption(report_route_util_option);

  auto* candidate_overflow_penalty_option = new TclDoubleOption("-candidate_overflow_penalty", 1, 0.0);
  addOption(candidate_overflow_penalty_option);
}

unsigned CmdPlacerRunGP::check()
{
  TclOption* mode_option = getOptionOrArg("-mode");
  if (mode_option->is_set_val()) {
    const std::string mode = mode_option->getStringVal();
    if (mode != "start" && mode != "advance" && mode != "resume" && mode != "relinearize" && mode != "restore"
        && mode != "candidate" && mode != "accept" && mode != "close") {
      LOG_ERROR << "placer_run_gp: unknown -mode value '" << mode
                << "' (expected start|advance|resume|relinearize|restore|candidate|accept|close)";
      return 0;
    }
    if (mode == "resume" || mode == "restore") {
      TclOption* checkpoint_option = getOptionOrArg("-checkpoint");
      if (!checkpoint_option->is_set_val()) {
        LOG_ERROR << "placer_run_gp: -mode " << mode << " requires -checkpoint <path>";
        return 0;
      }
    }
  }

  TclOption* scope_option = getOptionOrArg("-scope");
  if (scope_option->is_set_val()) {
    const std::string scope = scope_option->getStringVal();
    if (scope != "global" && scope != "hotspot" && scope != "random" && scope != "instances" && scope != "region"
        && scope != "longnet") {
      LOG_ERROR << "placer_run_gp: unknown -scope value '" << scope
                << "' (expected global|hotspot|random|instances|region|longnet)";
      return 0;
    }
    if (scope == "instances") {
      TclOption* scope_instances_option = getOptionOrArg("-scope_instances");
      if (!scope_instances_option->is_set_val()) {
        LOG_ERROR << "placer_run_gp: -scope instances requires -scope_instances <name[,name...]>";
        return 0;
      }
    }
    if (scope == "random" || scope == "longnet") {
      TclOption* scope_count_option = getOptionOrArg("-scope_active_count");
      if (!scope_count_option->is_set_val() || scope_count_option->getIntVal() <= 0) {
        LOG_ERROR << "placer_run_gp: -scope " << scope << " requires a positive -scope_active_count";
        return 0;
      }
    }
    if (scope == "region") {
      TclOption* scope_region_option = getOptionOrArg("-scope_region");
      if (!scope_region_option->is_set_val()) {
        LOG_ERROR << "placer_run_gp: -scope region requires -scope_region 'llx lly urx ury'";
        return 0;
      }
    }
  }
  return 1;
}

unsigned CmdPlacerRunGP::exec()
{
  if (not check()) {
    return 0;
  }
  auto* inst = iplf::PlacerIO::getInstance();

  TclOption* mode_option = getOptionOrArg("-mode");
  if (!mode_option->is_set_val()) {
    // legacy full run
    return ipl::placementTclResult(inst->runGlobalPlacement());
  }

  const std::string mode = mode_option->getStringVal();
  if (mode == "close") {
    iPLAPIInst.gpCloseSession();
    std::cout << "iPL gp session closed." << std::endl;
    return ipl::placementTclResult(true);
  }
  if (mode == "accept") {
    const auto accept_result = iPLAPIInst.gpCommitSession();
    std::cout << "iPL gp.run (accept) ok=" << accept_result.ok << " reason=" << accept_result.reason << std::endl;
    return ipl::placementTclResult(accept_result.ok);
  }

  ipl::GPRunRequest request;
  if (mode == "start") {
    request.mode = ipl::GPRunMode::kStart;
  } else if (mode == "resume") {
    request.mode = ipl::GPRunMode::kResume;
  } else if (mode == "restore") {
    request.mode = ipl::GPRunMode::kRestore;
    request.accepted_iterations = 0;
  } else if (mode == "candidate") {
    request.mode = ipl::GPRunMode::kCandidate;
  } else if (mode == "relinearize") {
    // Keep the externally-modified coordinates and rebuild all solver state
    // (gradients/steplength/momentum) from them: a fresh session, no stale state.
    request.mode = ipl::GPRunMode::kStart;
    request.random_init = false;
  } else {
    request.mode = ipl::GPRunMode::kAdvance;
  }

  TclOption* iterations_option = getOptionOrArg("-iterations");
  if (request.mode != ipl::GPRunMode::kRestore) {
    request.accepted_iterations = iterations_option->is_set_val() ? iterations_option->getIntVal() : 20;
  }
  TclOption* random_init_option = getOptionOrArg("-random_init");
  if (random_init_option->is_set_val()) {
    request.random_init = (random_init_option->getIntVal() != 0);
  }
  TclOption* seed_option = getOptionOrArg("-seed");
  if (seed_option->is_set_val()) {
    request.seed = seed_option->getIntVal();
  }
  TclOption* target_density_option = getOptionOrArg("-target_density");
  if (target_density_option->is_set_val()) {
    request.target_density = static_cast<float>(target_density_option->getDoubleVal());
  }
  TclOption* init_density_penalty_option = getOptionOrArg("-init_density_penalty");
  if (init_density_penalty_option->is_set_val()) {
    request.init_density_penalty = static_cast<float>(init_density_penalty_option->getDoubleVal());
  }
  TclOption* min_phi_option = getOptionOrArg("-min_phi_coef");
  if (min_phi_option->is_set_val()) {
    request.min_phi_coef = static_cast<float>(min_phi_option->getDoubleVal());
  }
  TclOption* max_phi_option = getOptionOrArg("-max_phi_coef");
  if (max_phi_option->is_set_val()) {
    request.max_phi_coef = static_cast<float>(max_phi_option->getDoubleVal());
  }
  TclOption* congestion_effort_option = getOptionOrArg("-congestion_effort");
  if (congestion_effort_option->is_set_val()) {
    request.congestion_effort = congestion_effort_option->getIntVal();
  }
  TclOption* checkpoint_option = getOptionOrArg("-checkpoint");
  if (checkpoint_option->is_set_val()) {
    request.checkpoint_path = checkpoint_option->getStringVal();
  }

  TclOption* scope_option = getOptionOrArg("-scope");
  const std::string scope = scope_option->is_set_val() ? scope_option->getStringVal() : "global";
  if (scope == "hotspot") {
    request.scope_mode = ipl::GPRunScopeMode::kHotspot;
  } else if (scope == "random") {
    request.scope_mode = ipl::GPRunScopeMode::kRandom;
  } else if (scope == "instances") {
    request.scope_mode = ipl::GPRunScopeMode::kInstances;
  } else if (scope == "region") {
    request.scope_mode = ipl::GPRunScopeMode::kRegion;
  } else if (scope == "longnet") {
    request.scope_mode = ipl::GPRunScopeMode::kLongNet;
  }
  TclOption* scope_ratio_option = getOptionOrArg("-scope_active_ratio");
  if (scope_ratio_option->is_set_val()) {
    request.scope_active_ratio = static_cast<float>(scope_ratio_option->getDoubleVal());
  }
  TclOption* scope_count_option = getOptionOrArg("-scope_active_count");
  if (scope_count_option->is_set_val()) {
    request.scope_active_count = scope_count_option->getIntVal();
  }
  TclOption* halo_option = getOptionOrArg("-scope_halo_coeff");
  if (halo_option->is_set_val()) {
    request.scope_halo_coeff = static_cast<float>(halo_option->getDoubleVal());
  }
  TclOption* halo_hops_option = getOptionOrArg("-scope_halo_hops");
  if (halo_hops_option->is_set_val()) {
    request.scope_halo_hops = halo_hops_option->getIntVal();
  }
  TclOption* scope_seed_option = getOptionOrArg("-scope_seed");
  if (scope_seed_option->is_set_val()) {
    request.scope_seed = static_cast<uint32_t>(scope_seed_option->getIntVal());
  }
  TclOption* scope_instances_option = getOptionOrArg("-scope_instances");
  if (scope_instances_option->is_set_val()) {
    std::stringstream stream(scope_instances_option->getStringVal());
    std::string name;
    while (std::getline(stream, name, ',')) {
      const auto first = name.find_first_not_of(" \t\r\n");
      const auto last = name.find_last_not_of(" \t\r\n");
      if (first == std::string::npos) {
        continue;
      }
      request.scope_instance_names.push_back(name.substr(first, last - first + 1));
    }
  }
  TclOption* scope_density_target_option = getOptionOrArg("-scope_density_target");
  if (scope_density_target_option->is_set_val()) {
    request.scope_density_target = static_cast<float>(scope_density_target_option->getDoubleVal());
  }
  TclOption* scope_density_ratio_option = getOptionOrArg("-scope_density_ratio");
  if (scope_density_ratio_option->is_set_val()) {
    request.scope_density_ratio = static_cast<float>(scope_density_ratio_option->getDoubleVal());
  }
  TclOption* scope_region_option = getOptionOrArg("-scope_region");
  if (scope_region_option->is_set_val()) {
    std::stringstream region_stream(scope_region_option->getStringVal());
    int32_t region_coords[4] = {0, 0, 0, 0};
    region_stream >> region_coords[0] >> region_coords[1] >> region_coords[2] >> region_coords[3];
    if (!region_stream.fail() || region_stream.eof()) {
      request.scope_region_set = true;
      request.scope_region_ll_x = region_coords[0];
      request.scope_region_ll_y = region_coords[1];
      request.scope_region_ur_x = region_coords[2];
      request.scope_region_ur_y = region_coords[3];
    }
  }
  TclOption* report_top_n_option = getOptionOrArg("-report_top_n");
  if (report_top_n_option->is_set_val()) {
    request.grid_report_top_n = report_top_n_option->getIntVal();
  }
  TclOption* report_route_util_option = getOptionOrArg("-report_route_util");
  if (report_route_util_option->is_set_val()) {
    request.evaluate_route_util = (report_route_util_option->getIntVal() != 0);
  }
  TclOption* candidate_overflow_penalty_option = getOptionOrArg("-candidate_overflow_penalty");
  if (candidate_overflow_penalty_option->is_set_val()) {
    request.candidate_overflow_penalty = static_cast<float>(candidate_overflow_penalty_option->getDoubleVal());
  }

  if (!inst->runGlobalPlacementSession(request, mode)) {
    const auto& last_result = iPLAPIInst.lastGPRunResult();
    std::cerr << "iPL gp.run failed";
    if (!last_result.reason.empty()) {
      std::cerr << ": " << last_result.reason;
    }
    std::cerr << std::endl;
    return ipl::placementTclResult(false);
  }

  // Surface the batch summary: the session API is the source of truth for the
  // accepted-iteration budget semantics.
  const auto& result = iPLAPIInst.lastGPRunResult();
  std::cout << "iPL gp.run (" << mode << ", " << request.accepted_iterations << " iterations) stop_reason="
            << ipl::gpStopReasonName(result.stop_reason) << " iterations=" << result.start_iteration << "-" << result.end_iteration
            << " hpwl=" << result.hpwl << " overflow=" << result.overflow << " step_length=" << result.step_length
            << " density_penalty=" << result.density_penalty << " route_util=" << result.route_util << std::endl;
  if (result.scope_effect.scope_applied) {
    std::cout << "  scope_effect active=" << result.scope_effect.active_written << " halo=" << result.scope_effect.halo_written
              << " context=" << result.scope_effect.context_written << " context_moved=" << result.scope_effect.context_moved
              << " max_displacement=" << result.scope_effect.max_displacement << std::endl;
  }
  if (!result.checkpoint_path.empty()) {
    std::cout << "  checkpoint=" << result.checkpoint_path << std::endl;
  }
  if (!result.parent_checkpoint_path.empty()) {
    std::cout << "  parent_checkpoint=" << result.parent_checkpoint_path << std::endl;
  }
  if (!result.grid_report_path.empty()) {
    std::cout << "  grid_report=" << result.grid_report_path << " overflowing_bins=" << result.grid_report.overflowing_bin_count
              << " total_overflow_area=" << result.grid_report.total_overflow_area << std::endl;
  }
  if (!result.experiment_record_path.empty()) {
    std::cout << "  experiment_record=" << result.experiment_record_path << std::endl;
  }
  if (result.candidate_comparison.ok) {
    std::cout << "  candidate_verdict=" << ipl::gpCandidateVerdictName(result.candidate_comparison.verdict)
              << " local=" << result.candidate_local_checkpoint_path << " global=" << result.candidate_global_checkpoint_path << std::endl;
  }
  return ipl::placementTclResult(true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerCompareGP::CmdPlacerCompareGP(const char* cmd_name) : TclCmd(cmd_name)
{
  auto* left_option = new TclStringOption("-checkpoint_a", 1, nullptr);
  addOption(left_option);

  auto* right_option = new TclStringOption("-checkpoint_b", 1, nullptr);
  addOption(right_option);
}

unsigned CmdPlacerCompareGP::check()
{
  TclOption* left_option = getOptionOrArg("-checkpoint_a");
  TclOption* right_option = getOptionOrArg("-checkpoint_b");
  if (!left_option->is_set_val() || !right_option->is_set_val()) {
    LOG_ERROR << "placer_compare_gp requires -checkpoint_a and -checkpoint_b";
    return 0;
  }
  return 1;
}

unsigned CmdPlacerCompareGP::exec()
{
  if (not check()) {
    return 0;
  }

  ipl::GPCandidateComparison comparison;
  const bool loaded = iPLAPIInst.gpCompareCheckpoints(getOptionOrArg("-checkpoint_a")->getStringVal(),
                                                       getOptionOrArg("-checkpoint_b")->getStringVal(), comparison);
  if (!loaded) {
    std::cerr << "placer_compare_gp failed: " << comparison.reason << std::endl;
    return ipl::placementTclResult(false);
  }

  std::cout << "placer_compare_gp same_origin=" << comparison.same_origin << " same_budget=" << comparison.same_budget
            << " verdict=" << ipl::gpCandidateVerdictName(comparison.verdict) << "\n"
            << "  left : iter=" << comparison.left.current_iter << " hpwl=" << comparison.left.hpwl
            << " overflow=" << comparison.left.overflow << " step=" << comparison.left.step_length << "\n"
            << "  right: iter=" << comparison.right.current_iter << " hpwl=" << comparison.right.hpwl
            << " overflow=" << comparison.right.overflow << " step=" << comparison.right.step_length;
  if (!comparison.reason.empty()) {
    std::cout << " reason=" << comparison.reason;
  }
  std::cout << std::endl;
  // The command succeeded when both checkpoints could be loaded and compared;
  // "incomparable" is a valid comparison result, not a command failure.
  return ipl::placementTclResult(true);
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerRunMP::CmdPlacerRunMP(const char* cmd_name) : TclCmd(cmd_name)
{
}

unsigned CmdPlacerRunMP::check()
{
  return 1;
}

unsigned CmdPlacerRunMP::exec()
{
  if (not check()) {
    return 0;
  }
  auto* inst = iplf::PlacerIO::getInstance();
  return ipl::placementTclResult(inst->runMacroPlacement());
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerRunLG::CmdPlacerRunLG(const char* cmd_name) : TclCmd(cmd_name)
{
}

unsigned CmdPlacerRunLG::check()
{
  return 1;
}

unsigned CmdPlacerRunLG::exec()
{
  if (not check()) {
    return 0;
  }
  auto* inst = iplf::PlacerIO::getInstance();
  return ipl::placementTclResult(inst->runLegalization());
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerRunDP::CmdPlacerRunDP(const char* cmd_name) : TclCmd(cmd_name)
{
}

unsigned CmdPlacerRunDP::check()
{
  return 1;
}

unsigned CmdPlacerRunDP::exec()
{
  if (not check()) {
    return 0;
  }
  auto* inst = iplf::PlacerIO::getInstance();
  return ipl::placementTclResult(inst->runDetailPlacement());
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
CmdPlacerReport::CmdPlacerReport(const char* cmd_name) : TclCmd(cmd_name)
{
}

unsigned CmdPlacerReport::check()
{
  return 1;
}

unsigned CmdPlacerReport::exec()
{
  if (not check()) {
    return 0;
  }
  auto* inst = iplf::PlacerIO::getInstance();
  inst->reportPlacement();
  return 1;
}

}  // namespace tcl
