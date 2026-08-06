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
#include "tcl_power.h"

#include <cstdlib>
#include <string>

#include "tool_manager.h"

using ieda::TclDoubleOption;
using ieda::TclSwitchOption;

namespace tcl {

CmdPowerRun::CmdPowerRun(const char* cmd_name) : TclCmd(cmd_name)
{
  auto* file_name_option = new TclStringOption(TCL_OUTPUT_PATH, 1, nullptr);
  addOption(file_name_option);

  // Mirror report_power: allow explicit vectorless activity without VCD/SAIF.
  auto* default_toggle = new TclDoubleOption("-toggle", 0, 0.02);
  addOption(default_toggle);
  auto* allow_default_toggle = new TclSwitchOption("-allow_default_toggle");
  addOption(allow_default_toggle);
}

unsigned CmdPowerRun::check()
{
  // TclOption* file_name_option = getOptionOrArg(TCL_OUTPUT_PATH);
  // LOG_FATAL_IF(!file_name_option);
  return 1;
}

unsigned CmdPowerRun::exec()
{
  if (!check()) {
    return 0;
  }

  TclOption* option = getOptionOrArg(TCL_OUTPUT_PATH);
  auto path = option->getStringVal() != nullptr ? option->getStringVal() : "";

  auto* default_toggle_option = getOptionOrArg("-toggle");
  auto* allow_default_toggle_option = getOptionOrArg("-allow_default_toggle");
  const bool toggle_is_explicit =
      default_toggle_option && default_toggle_option->is_set_val();
  const bool vectorless_is_explicit =
      allow_default_toggle_option && allow_default_toggle_option->is_set_val();
  if (toggle_is_explicit || vectorless_is_explicit) {
    const double default_toggle = toggle_is_explicit
                                      ? default_toggle_option->getDoubleVal()
                                      : 0.02;
    // PowerIO::reportSummaryPower reads this before runCompleteFlow().
    ::setenv("IEDA_POWER_DEFAULT_TOGGLE", std::to_string(default_toggle).c_str(), 1);
  } else {
    ::unsetenv("IEDA_POWER_DEFAULT_TOGGLE");
  }

  if (!iplf::tmInst->autoRunPower(path)) {
    LOG_ERROR << "run_power failed";
    return 0;
  }
  std::cout << "iPA run successfully." << std::endl;
  return 1;
}

}  // namespace tcl
