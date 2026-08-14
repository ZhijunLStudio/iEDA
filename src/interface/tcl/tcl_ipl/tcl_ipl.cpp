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

  auto* checkpoint_option = new TclStringOption("-checkpoint", 1, nullptr);
  addOption(checkpoint_option);
}

unsigned CmdPlacerRunGP::check()
{
  TclOption* mode_option = getOptionOrArg("-mode");
  if (mode_option->is_set_val()) {
    const std::string mode = mode_option->getStringVal();
    if (mode != "start" && mode != "advance" && mode != "resume" && mode != "relinearize" && mode != "close") {
      LOG_ERROR << "placer_run_gp: unknown -mode value '" << mode << "' (expected start|advance|resume|relinearize|close)";
      return 0;
    }
    if (mode == "resume") {
      TclOption* checkpoint_option = getOptionOrArg("-checkpoint");
      if (!checkpoint_option->is_set_val()) {
        LOG_ERROR << "placer_run_gp: -mode resume requires -checkpoint <path>";
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

  ipl::GPRunRequest request;
  if (mode == "start") {
    request.mode = ipl::GPRunMode::kStart;
  } else if (mode == "resume") {
    request.mode = ipl::GPRunMode::kResume;
  } else {
    request.mode = ipl::GPRunMode::kAdvance;
  }
  TclOption* iterations_option = getOptionOrArg("-iterations");
  request.accepted_iterations = iterations_option->is_set_val() ? iterations_option->getIntVal() : 20;
  TclOption* random_init_option = getOptionOrArg("-random_init");
  if (random_init_option->is_set_val()) {
    request.random_init = (random_init_option->getIntVal() != 0);
  }
  TclOption* checkpoint_option = getOptionOrArg("-checkpoint");
  std::string checkpoint;
  if (checkpoint_option->is_set_val()) {
    checkpoint = checkpoint_option->getStringVal();
  }

  if (!inst->runGlobalPlacementSession(mode, request.accepted_iterations, request.random_init, checkpoint)) {
    std::cerr << "iPL gp.run failed." << std::endl;
    return ipl::placementTclResult(false);
  }

  // Surface the batch summary: the session API is the source of truth for the
  // accepted-iteration budget semantics.
  std::cout << "iPL gp.run (" << mode << ", " << request.accepted_iterations << " iterations) finished." << std::endl;
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
