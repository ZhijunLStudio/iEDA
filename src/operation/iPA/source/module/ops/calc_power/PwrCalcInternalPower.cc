// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of
// Sciences Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// You can use this software according to the terms and conditions of the Mulan
// PSL v2. You may obtain a copy of Mulan PSL v2 at:
// http://license.coscl.org.cn/MulanPSL2
//
// THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY
// KIND, EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
// NON-INFRINGEMENT, MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
//
// See the Mulan PSL v2 for more details.
// ***************************************************************************************
/**
 * @file PwrCalcInternalPower.cc
 * @author shaozheqing (707005020@qq.com)
 * @brief Calc internal power.
 * @version 0.1
 * @date 2023-04-16
 */

#include "PwrCalcInternalPower.hh"

#include <cmath>
#include <string_view>

#include "PwrCalcSPData.hh"
namespace ipower {
using ieda::Stats;

namespace {

double finiteOrZero(double value, const char* context, std::string_view object)
{
  if (std::isfinite(value)) {
    return value;
  }
  LOG_ERROR_IF_EVERY_N(true, 100) << "non-finite internal power input in " << context << " for " << object
                                  << ", use 0 for this pin/arc.";
  return 0.0;
}

}  // namespace

/**
 * @brief Get toggle data.
 *
 * @param pin
 * @return double
 */
double PwrCalcInternalPower::getToggleData(Pin* pin) {
  /*find the vertex.*/
  auto* the_pwr_graph = get_the_pwr_graph();
  auto* the_sta_graph = the_pwr_graph->get_sta_graph();
  auto the_sta_vertex = the_sta_graph->findVertex(pin);
  if (!the_sta_vertex || !*the_sta_vertex) {
    LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << pin->getFullName() << " has no STA vertex for toggle annotation.";
    return 0.0;
  }
  auto* the_pwr_vertex = the_pwr_graph->staToPwrVertex(*the_sta_vertex);
  if (!the_pwr_vertex) {
    LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << pin->getFullName() << " has no power vertex for toggle annotation.";
    return 0.0;
  }

  // get toggle data.
  double toggle_value = the_pwr_vertex->getToggleData(std::nullopt);
  return finiteOrZero(toggle_value, "toggle annotation", pin->getFullName());
}

/**
 * @brief Calc sp data of the when condition.
 *
 * @param when
 * @param inst
 * @return double
 */
double PwrCalcInternalPower::calcSPByWhen(const char* when, Instance* inst) {
  /*Parse conditional statements of the leakage power*/
  RustLibertyExprBuilder expr_builder(when);
  expr_builder.execute();
  auto* expr = expr_builder.get_result_expr();

  /*Calc sp data.*/
  PwrCalcSPData calc_sp_data;
  calc_sp_data.set_the_pwr_graph(get_the_pwr_graph());
  double sp_value = calc_sp_data.calcSPData(expr, inst);
  return finiteOrZero(sp_value, "when SP", inst->get_name());
}

/**
 * @brief Clac comb input pin internal power.
 *
 * @param pin
 * @param input_sum_toggle
 * @return double
 */
double PwrCalcInternalPower::calcCombInputPinPower(Instance* inst,
                                                   Pin* input_pin,
                                                   double input_sum_toggle,
                                                   double output_pin_toggle) {
  double pin_internal_power = 0;
  static std::ofstream out_debug;

  bool is_debug = false;
  if (0) {
    is_debug = true;
    out_debug.open("internal_input.txt", std::ios::app);
  }

  /*find the vertex.*/
  auto* the_pwr_graph = get_the_pwr_graph();
  auto* the_sta_graph = the_pwr_graph->get_sta_graph();

  auto the_input_sta_vertex = the_sta_graph->findVertex(input_pin);
  if (!the_input_sta_vertex || !*the_input_sta_vertex) {
    LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << input_pin->getFullName()
                                    << " has no STA vertex, skip comb input internal power.";
    return 0.0;
  }

  auto* cell_port = input_pin->get_cell_port();
  auto* lib_cell = cell_port->get_ower_cell();

  LibInternalPowerInfo* internal_power;
  FOREACH_INTERNAL_POWER(cell_port, internal_power) {
    /*get internal power of this condition.*/
    // rise power
    auto rise_slew = (*the_input_sta_vertex)
                         ->getSlewNs(AnalysisMode::kMax, TransType::kRise);
    if (!rise_slew) {
      LOG_ERROR_IF(!rise_slew)
          << (*the_input_sta_vertex)->getName() << " rise slew is not exist.";
      continue;
    }

    double rise_power = internal_power->gatePower(
        TransType::kRise, rise_slew.value_or(0.0), std ::nullopt);
    double rise_power_mw = finiteOrZero(lib_cell->convertTablePowerToMw(rise_power), "comb input rise power",
                                        input_pin->getFullName());
    // fall power
    auto fall_slew = (*the_input_sta_vertex)
                         ->getSlewNs(AnalysisMode::kMax, TransType::kFall);
    LOG_FATAL_IF(!fall_slew)
        << (*the_input_sta_vertex)->getName() << " fall slew is not exist.";
    double fall_power = internal_power->gatePower(
        TransType::kFall, fall_slew.value_or(0.0), std ::nullopt);
    double fall_power_mw = finiteOrZero(lib_cell->convertTablePowerToMw(fall_power), "comb input fall power",
                                        input_pin->getFullName());

    // When the input causes the output to be flipped, the toggle needs to
    // be calculated based on the percentage of the input toggle.
    double input_pin_toggle = getToggleData(input_pin);
    input_pin_toggle = finiteOrZero(input_pin_toggle, "comb input toggle", input_pin->getFullName());
    output_pin_toggle = finiteOrZero(output_pin_toggle, "comb output toggle", input_pin->getFullName());
    double output_flip_toggle = (output_pin_toggle > 0 && input_sum_toggle > 0)
                                    ? (input_pin_toggle / input_sum_toggle) * output_pin_toggle
                                    : 0;
    double output_no_flip_toggle = input_pin_toggle - output_flip_toggle;

    // the internal power of this condition.
    double average_power_mw =
        finiteOrZero(CalcAveragePower(rise_power_mw, fall_power_mw), "comb input average power", input_pin->getFullName());
    double the_internal_power =
        finiteOrZero(output_no_flip_toggle * average_power_mw, "comb input internal power", input_pin->getFullName());

    if (is_debug) {
      
      out_debug
          << "input pin " << input_pin->getFullName() << " toggle "
          << output_no_flip_toggle << " average power(mW) " << average_power_mw
          << " rise slew " << rise_slew.value_or(0.0)
          << " rise power(mW) "
          << cell_port->get_ower_cell()->convertTablePowerToMw(rise_power_mw)
          << " fall slew " << fall_slew.value_or(0.0)
          << " fall_power(mW) "
          << cell_port->get_ower_cell()->convertTablePowerToMw(fall_power_mw) << "\n";
      
    }

    auto& when = internal_power->get_when();
    if (!when.empty()) {
      // get the sp data of this condition.
      double sp_value = calcSPByWhen(when.c_str(), inst);
      pin_internal_power += finiteOrZero(sp_value * the_internal_power, "comb input conditional power", input_pin->getFullName());
    } else {
      pin_internal_power += the_internal_power;
    }
  }

  if (is_debug) {
    out_debug.close();
  }
  
  return pin_internal_power;
}

/**
 * @brief Clac comb/seq output pin internal power.
 *
 * @param inst
 * @param pin
 * @return double
 */
double PwrCalcInternalPower::calcOutputPinPower(Instance* inst,
                                                Pin* output_pin) {
  double pin_internal_power = 0;
  bool is_debug = false;

  /*find the vertex.*/
  auto* the_pwr_graph = get_the_pwr_graph();
  auto* the_sta_graph = the_pwr_graph->get_sta_graph();
  StaVertex* the_output_sta_vertex =
      the_sta_graph->findVertex(output_pin).value_or(nullptr);
  if (!the_output_sta_vertex) {
    LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << output_pin->getFullName()
                                    << " has no STA vertex, skip output internal power.";
    return 0.0;
  }
  if (output_pin->isInout()) {
    // for inout pin, get the assistant node.
    LOG_FATAL_IF(!the_output_sta_vertex)
        << "not found sta vertex " << output_pin->getFullName();
    the_output_sta_vertex = the_sta_graph->getAssistant(the_output_sta_vertex);
  }

  // lambda function, convert load to power lib unit.
  auto convert_load_to_lib_unit = [](LibPowerArc* power_arc,
                                     double load_pf) -> double {
    auto* the_lib = power_arc->get_owner_cell()->get_owner_lib();

    double load = 0.0;
    if (the_lib->get_cap_unit() == CapacitiveUnit::kFF) {
      load = PF_TO_FF(load_pf);
    } else if (the_lib->get_cap_unit() == CapacitiveUnit::kPF) {
      load = load_pf;
    }

    return load;
  };

  auto* the_output_pwr_vertex =
      the_pwr_graph->staToPwrVertex(the_output_sta_vertex);
  if (!the_output_pwr_vertex) {
    LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << output_pin->getFullName()
                                    << " has no power vertex, skip output internal power.";
    return 0.0;
  }
  FOREACH_SNK_PWR_ARC(the_output_pwr_vertex, snk_arc) {
    if (snk_arc->isNetArc()) {
      continue;
    }

    auto* pwr_inst_arc = dynamic_cast<PwrInstArc*>(snk_arc);
    if (!pwr_inst_arc) {
      continue;
    }

    // get src vertex
    auto* src_input_pwr_vertex = snk_arc->get_src();
    auto* src_input_sta_vertex =
        the_pwr_graph->pwrToStaVertex(src_input_pwr_vertex);

    // get sta arc, theoretically only one arc.
    auto sta_arcs = the_output_sta_vertex->getSrcArc(src_input_sta_vertex);
    if (sta_arcs.empty()) {
      LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << output_pin->getFullName()
                                      << " has no source STA arc, skip output internal power arc.";
      continue;
    }
    auto* sta_arc = sta_arcs.front();

    auto query_power =
        [sta_arc, convert_load_to_lib_unit](
            LibPowerArc* power_arc,
            TransType trans_type) -> std::tuple<double, double, double> {
      auto* internal_power_info = power_arc->get_internal_power_info().get();
      auto input_slew_ns = sta_arc->get_src()->getSlewNs(
          AnalysisMode::kMax,
          sta_arc->isPositiveArc() ? trans_type : FLIP_TRANS(trans_type));
      LOG_ERROR_IF_EVERY_N(!input_slew_ns, 10)
          << sta_arc->get_src()->getName() << " input slew is not exist.";

      double output_load_pf =
          sta_arc->get_snk()->getLoad(AnalysisMode::kMax, trans_type);
      double output_load = convert_load_to_lib_unit(power_arc, output_load_pf);
      // lut power
      double internal_power_value = internal_power_info->gatePower(
          trans_type, input_slew_ns.value_or(0.0), output_load);

      double internal_power_value_mw =
          power_arc->get_owner_cell()->convertTablePowerToMw(
              internal_power_value);

      return {finiteOrZero(internal_power_value_mw, "output arc table power", sta_arc->get_snk()->getName()),
              input_slew_ns ? *input_slew_ns : 0.0, output_load};
    };

    auto* power_arc_set = pwr_inst_arc->get_power_arc_set();

    if (!power_arc_set) {
      continue;
    }

    LibPowerArc* power_arc;
    FOREACH_POWER_LIB_ARC(power_arc_set, power_arc) {
      auto [rise_power_mw, rise_input_slew_ns, rise_output_load] =
          query_power(power_arc, TransType::kRise);
      auto [fall_power_mw, fall_input_slew_ns, fall_output_load] =
          query_power(power_arc, TransType::kFall);
      // the internal power of this power arc.
      double table_average_power_mw =
          finiteOrZero(CalcAveragePower(rise_power_mw, fall_power_mw), "output arc average power", output_pin->getFullName());

      double output_toggle = getToggleData(output_pin);
      double the_arc_power =
          finiteOrZero(output_toggle * table_average_power_mw, "output arc internal power", output_pin->getFullName());

      VERBOSE_LOG(1) << "output pin " << output_pin->getFullName()
                     << " arc power(mW) " << the_arc_power << " toggle "
                     << output_toggle << " table average power(mW) "
                     << table_average_power_mw << " rise power(mW) "
                     << rise_power_mw << " fall_power(mW) " << fall_power_mw;

      auto* internal_power_info = power_arc->get_internal_power_info().get();
      auto& when = internal_power_info->get_when();
      if (!when.empty()) {
        // get the sp data of this condition.
        double sp_value = calcSPByWhen(when.c_str(), inst);
        the_arc_power = finiteOrZero(sp_value * the_arc_power, "output conditional power", output_pin->getFullName());
        pin_internal_power += the_arc_power;
      } else {
        pin_internal_power += the_arc_power;
      }

      pwr_inst_arc->set_internal_power(the_arc_power);

      // for debug
      if (is_debug) {
        std::ofstream out_debug("internal_out.txt");
        out_debug << "inst: " << inst->get_name();
        out_debug << "\nrise power :" << rise_power_mw;
        out_debug << "\nrise input slew :" << rise_input_slew_ns;
        out_debug << "\nrise output load :" << rise_output_load;

        out_debug << "\nfall power :" << fall_power_mw;
        out_debug << "\nfall input slew :" << fall_input_slew_ns;
        out_debug << "\nfall output load :" << fall_output_load;

        out_debug << "\nouput pin :" << output_pin->getFullName();
        out_debug << "\ntoggle :" << output_toggle;

        out_debug.close();
      }
    }
  }

  VERBOSE_LOG(1) << "output pin " << output_pin->getFullName()
                 << " internal power(mW) " << pin_internal_power;

  return pin_internal_power;
}

/**
 * @brief   Clac seq clock pin internal power.
 *
 * @param inst
 * @param pin
 * @param toggle_output_data
 * @return double
 */
double PwrCalcInternalPower::calcClockPinPower(Instance* inst, Pin* clock_pin,
                                               double output_pin_toggle) {
  double pin_internal_power = 0;

  /*find the vertex.*/
  auto* the_pwr_graph = get_the_pwr_graph();
  auto* the_sta_graph = the_pwr_graph->get_sta_graph();
  auto the_clock_sta_vertex = the_sta_graph->findVertex(clock_pin);
  if (!the_clock_sta_vertex || !*the_clock_sta_vertex) {
    LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << clock_pin->getFullName()
                                    << " has no STA vertex, skip clock internal power.";
    return 0.0;
  }
  auto* cell_port = clock_pin->get_cell_port();
  auto* lib_cell = cell_port->get_ower_cell();

  LibInternalPowerInfo* internal_power;
  FOREACH_INTERNAL_POWER(cell_port, internal_power) {
    /*get internal power of this condition.*/
    // rise power
    auto rise_slew = (*the_clock_sta_vertex)
                         ->getSlewNs(AnalysisMode::kMax, TransType::kRise);
    if (!rise_slew) {
      LOG_ERROR_IF(!rise_slew)
          << (*the_clock_sta_vertex)->getName() << " rise slew is not exist.";
      rise_slew = 0.0;
    }

    double rise_power = internal_power->gatePower(
        TransType::kRise, rise_slew.value_or(0.0), std ::nullopt);
    double rise_power_mw =
        finiteOrZero(lib_cell->convertTablePowerToMw(rise_power), "clock rise power", clock_pin->getFullName());
    // fall power
    auto fall_slew = (*the_clock_sta_vertex)
                         ->getSlewNs(AnalysisMode::kMax, TransType::kFall);
    if (!fall_slew) {
      LOG_ERROR_IF(!fall_slew)
          << (*the_clock_sta_vertex)->getName() << " fall slew is not exist.";
      fall_slew = 0.0;
    }

    double fall_power = internal_power->gatePower(
        TransType::kFall, fall_slew.value_or(0.0), std ::nullopt);
    double fall_power_mw =
        finiteOrZero(lib_cell->convertTablePowerToMw(fall_power), "clock fall power", clock_pin->getFullName());

    double average_power_mw =
        finiteOrZero(CalcAveragePower(rise_power_mw, fall_power_mw), "clock average power", clock_pin->getFullName());

    double clock_pin_toggle = getToggleData(clock_pin);
    output_pin_toggle = finiteOrZero(output_pin_toggle, "clock output toggle", clock_pin->getFullName());

    // the internal power of this condition.
    double output_flip_power =
        finiteOrZero(HalfToggle(clock_pin_toggle) *
        ((*the_clock_sta_vertex)->isRisingTriggered() ? rise_power_mw
                                                      : fall_power_mw), "clock flip power", clock_pin->getFullName());

    double output_no_flip_power =
        finiteOrZero(
        (clock_pin_toggle - output_pin_toggle) * average_power_mw +
        HalfToggle(clock_pin_toggle) *
            ((*the_clock_sta_vertex)->isRisingTriggered() ? rise_power_mw
                                                          : fall_power_mw),
        "clock no-flip power", clock_pin->getFullName());

    VERBOSE_LOG(1) << "clock pin " << clock_pin->getFullName()
                   << " output flip power(mW) " << output_flip_power
                   << " output no flip power(mW) " << output_no_flip_power
                   << " toggle " << clock_pin_toggle << " rise power(mW) "
                   << rise_power << " fall_power(mW) " << fall_power;

    auto& when = internal_power->get_when();
    if (!when.empty()) {
      // get the sp data of this condition.
      double sp_value = calcSPByWhen(when.c_str(), inst);
      pin_internal_power +=
          finiteOrZero(sp_value * (output_flip_power + output_no_flip_power), "clock conditional power",
                       clock_pin->getFullName());
    } else {
      pin_internal_power += output_flip_power + output_no_flip_power;
    }
  }

  return pin_internal_power;
}

/**
 * @brief Clac seq input pin internal power.
 *
 * @param inst
 * @param pin
 * @return double
 */
double PwrCalcInternalPower::calcSeqInputPinPower(Instance* inst,
                                                  Pin* input_pin) {
  double pin_internal_power = 0;

  /*find the vertex.*/
  auto* the_pwr_graph = get_the_pwr_graph();
  auto* the_sta_graph = the_pwr_graph->get_sta_graph();
  auto the_input_sta_vertex = the_sta_graph->findVertex(input_pin);
  if (!the_input_sta_vertex || !*the_input_sta_vertex) {
    LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << input_pin->getFullName()
                                    << " has no STA vertex, skip seq input internal power.";
    return 0.0;
  }

  auto* cell_port = input_pin->get_cell_port();
  auto* lib_cell = cell_port->get_ower_cell();

  LibInternalPowerInfo* internal_power;
  FOREACH_INTERNAL_POWER(cell_port, internal_power) {
    if ((*the_input_sta_vertex)->getSlewBucket().empty()) {
      // no slew data not need to calc power.
      continue;
    }
    /*get internal power of this condition.*/
    // rise power
    auto rise_slew = (*the_input_sta_vertex)
                         ->getSlewNs(AnalysisMode::kMax, TransType::kRise);

    double rise_power_mw = 0.0;
    LOG_ERROR_IF(!rise_slew)
        << (*the_input_sta_vertex)->getName() << " rise slew is not exist.";
    if (rise_slew) {
      double rise_power = internal_power->gatePower(
          TransType::kRise, rise_slew.value_or(0.0), std ::nullopt);
      rise_power_mw =
          finiteOrZero(lib_cell->convertTablePowerToMw(rise_power), "seq input rise power", input_pin->getFullName());
    }

    // fall power
    auto fall_slew = (*the_input_sta_vertex)
                         ->getSlewNs(AnalysisMode::kMax, TransType::kFall);
    LOG_ERROR_IF(!fall_slew)
        << (*the_input_sta_vertex)->getName() << " fall slew is not exist.";
    double fall_power_mw = rise_power_mw;
    if (fall_slew) {
      double fall_power = internal_power->gatePower(
          TransType::kFall, fall_slew.value_or(0.0), std ::nullopt);
      fall_power_mw =
          finiteOrZero(lib_cell->convertTablePowerToMw(fall_power), "seq input fall power", input_pin->getFullName());
    }

    double average_power_mw =
        finiteOrZero(CalcAveragePower(rise_power_mw, fall_power_mw), "seq input average power", input_pin->getFullName());

    double input_pin_toggle = getToggleData(input_pin);

    // the internal power of this condition.
    double the_internal_power =
        finiteOrZero(input_pin_toggle * average_power_mw, "seq input internal power", input_pin->getFullName());

    VERBOSE_LOG(1) << "input pin " << input_pin->getFullName() << " toggle "
                   << input_pin_toggle << " average power(mW) "
                   << average_power_mw << " rise power(mW) " << rise_power_mw
                   << " fall_power(mW) " << fall_power_mw;

    auto& when = internal_power->get_when();
    if (!when.empty()) {
      // get the sp data of this condition.
      double sp_value = calcSPByWhen(when.c_str(), inst);
      pin_internal_power += finiteOrZero(sp_value * the_internal_power, "seq input conditional power", input_pin->getFullName());
    } else {
      pin_internal_power += the_internal_power;
    }
  }
  return pin_internal_power;
}

/**
 * @brief Calc comb instance internal power.
 *
 * @param inst
 * @return double
 */
double PwrCalcInternalPower::calcCombInternalPower(Instance* inst) {
  double inst_internal_power = 0;

  bool is_debug = false;

  double input_sum_toggle = 0;
  double output_pin_toggle = 0;

  Pin* pin;
  FOREACH_INSTANCE_PIN(inst, pin) {
    if (pin->isInput()) {
      // get toggle input port sum data;
      double toggle_data = getToggleData(pin);
      input_sum_toggle += toggle_data;
    } else {
      // get one of output toggle data.
      output_pin_toggle = getToggleData(pin);
    }
  }

  FOREACH_INSTANCE_PIN(inst, pin) {
    auto* the_pwr_graph = get_the_pwr_graph();
    auto* the_sta_graph = the_pwr_graph->get_sta_graph();
    auto the_sta_vertex = the_sta_graph->findVertex(pin);
    if (!the_sta_vertex || !*the_sta_vertex) {
      LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << pin->getFullName()
                                      << " has no STA vertex, skip comb pin internal power.";
      continue;
    }
    auto* the_pwr_vertex = the_pwr_graph->staToPwrVertex(*the_sta_vertex);
    if (!the_pwr_vertex) {
      LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << pin->getFullName()
                                      << " has no power vertex, skip comb pin internal power.";
      continue;
    }
    
    double pin_internal_power = 0;
    // for inout pin, we need calc input and output both.
    if (pin->isInput()) {
      /*calc input port power*/
      pin_internal_power =
          calcCombInputPinPower(inst, pin, input_sum_toggle, output_pin_toggle);

      the_pwr_vertex->set_internal_power(pin_internal_power);
      inst_internal_power += pin_internal_power;
    }

    if (pin->isOutput()) {
      /*calc output port power*/
      if (pin->get_net()) {
        pin_internal_power = calcOutputPinPower(inst, pin);
        inst_internal_power += pin_internal_power;
      }
    }

    if (is_debug) {
      LOG_INFO << "pin " << pin->getFullName() << " toggle "
               << getToggleData(pin) << " power " << pin_internal_power;
    }
  }

  return inst_internal_power;
}

/**
 * @brief Calc seq instance internal power.
 *
 * @param inst
 * @return double
 */
double PwrCalcInternalPower::calcSeqInternalPower(Instance* inst) {
  double inst_internal_power = 0;

  bool is_debug = false;

  double output_pin_toggle = 0;
  // get output pin toggle data
  Pin* pin;
  FOREACH_INSTANCE_PIN(inst, pin) {
    if (pin->isOutput()) {
      output_pin_toggle = getToggleData(pin);
    }
  }

  FOREACH_INSTANCE_PIN(inst, pin) {
    /*find the vertex.*/
    auto* the_pwr_graph = get_the_pwr_graph();
    auto* the_sta_graph = the_pwr_graph->get_sta_graph();
    auto the_sta_vertex = the_sta_graph->findVertex(pin);
    if (!the_sta_vertex || !*the_sta_vertex) {
      LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << pin->getFullName()
                                      << " has no STA vertex, skip seq pin internal power.";
      continue;
    }
    auto* the_pwr_vertex = the_pwr_graph->staToPwrVertex(*the_sta_vertex);
    if (!the_pwr_vertex) {
      LOG_ERROR_IF_EVERY_N(true, 100) << "pin " << pin->getFullName()
                                      << " has no power vertex, skip seq pin internal power.";
      continue;
    }

    if (the_pwr_vertex->is_const()) {
      continue;
    }

    if (pin->isInput()) {
      double pin_internal_power = 0.0;
      /*calc input port power*/
      if ((*the_sta_vertex)->is_clock()) {
        /*calc clk power*/
        pin_internal_power = calcClockPinPower(inst, pin, output_pin_toggle);
        inst_internal_power += pin_internal_power;
      } else {
        pin_internal_power = calcSeqInputPinPower(inst, pin);
        inst_internal_power += pin_internal_power;
      }

      if (is_debug) {
        LOG_INFO << "input pin " << pin->getFullName() << " toggle "
                 << getToggleData(pin) << " power " << pin_internal_power;
      }

      the_pwr_vertex->set_internal_power(pin_internal_power);

    } else {
      /*calc output port power*/
      double pin_internal_power = calcOutputPinPower(inst, pin);
      inst_internal_power += pin_internal_power;

      if (is_debug) {
        LOG_INFO << "output pin " << pin->getFullName() << " toggle "
                 << getToggleData(pin) << " power " << pin_internal_power;
      }
    }
  }

  return inst_internal_power;
}

/**
 * @brief print internal power sorted by worst.
 *
 * @param out
 * @param the_graph
 */
void PwrCalcInternalPower::printInternalPower(std::ostream& out,
                                              PwrGraph* the_graph) {
  std::ranges::sort(_internal_powers, [](auto& left, auto& right) {
    return left->get_internal_power() > right->get_internal_power();
  });

  for (auto& internal_power : _internal_powers) {
    auto* design_obj = internal_power->get_design_obj();
    auto* design_inst = dynamic_cast<Instance*>(design_obj);

    out << design_inst->get_name() << " : "
        << internal_power->get_internal_power() << " mW"
        << "\n";
  }
}

/**
 * @brief Calc internal power.
 *
 * @param the_graph
 * @return unsigned
 */
unsigned PwrCalcInternalPower::operator()(PwrGraph* the_graph) {
  Stats stats;
  LOG_INFO << "calc internal power start";

  set_the_pwr_graph(the_graph);

  PwrCell* cell;
  FOREACH_PWR_CELL(the_graph, cell) {
    auto* design_inst = cell->get_design_inst();
    auto* inst_cell = design_inst->get_inst_cell();
    double inst_internal_power = 0.0;

    if (inst_cell->isMacroCell()) {
      // TODO
    } else if (inst_cell->isSequentialCell()) {
      /*Calc seq internal power.*/
      inst_internal_power = calcSeqInternalPower(design_inst);
    } else {
      /*Calc comb internal power.*/
      inst_internal_power = calcCombInternalPower(design_inst);
    }

    double nom_voltage = inst_cell->get_owner_lib()->get_nom_voltage();
    // add power analysis data.
    auto internal_data = std::make_unique<PwrInternalData>(
        design_inst, MW_TO_W(finiteOrZero(inst_internal_power, "instance internal power", design_inst->get_name())));
    internal_data->set_nom_voltage(nom_voltage);

    addInternalPower(std::move(internal_data));
    VERBOSE_LOG(1) << "cell  " << design_inst->get_name()
                   << "  internal power: " << inst_internal_power << "mW";
    _internal_power_result += finiteOrZero(inst_internal_power, "internal power sum", design_inst->get_name());
  }

// debug internal power
#if 0
  std::ofstream out("internal.txt");
  printInternalPower(out, the_graph);
  out.close();
#endif

  LOG_INFO << "calc internal power result " << _internal_power_result << "mW";

  LOG_INFO << "calc internal power end";
  double memory_delta = stats.memoryDelta();
  LOG_INFO << "calc internal power memory usage " << memory_delta << "MB";
  double time_delta = stats.elapsedRunTime();
  LOG_INFO << "calc internal power time elapsed " << time_delta << "s";
  return 1;
}
}  // namespace ipower
