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
#include "report_evaluator.h"

#include <algorithm>
#include <fstream>
#include <future>
#include <iostream>
#include <memory>
#include <optional>
#include <sstream>
#include <tuple>

#include "IdbPins.h"
#include "ReportTable.hh"
#include "congestion_api.h"
#include "density_api.h"
#include "fort.hpp"
#include "idm.h"
#include "wirelength_api.h"

namespace iplf {

namespace {

std::optional<std::vector<float>> readFloatCsvValues(const std::string& file_path)
{
  std::ifstream file(file_path);
  if (!file.is_open()) {
    std::cerr << "Error opening file: " << file_path << std::endl;
    return std::nullopt;
  }

  std::vector<float> values;
  std::string line;
  while (std::getline(file, line)) {
    std::stringstream stream(line);
    std::string cell;
    while (std::getline(stream, cell, ',')) {
      if (!cell.empty()) {
        values.push_back(std::stof(cell));
      }
    }
  }
  if (values.empty()) {
    std::cerr << "Empty CSV file: " << file_path << std::endl;
    return std::nullopt;
  }
  return values;
}

}  // namespace

// template <typename T>
// static void freeWrapped(std::vector<T*>& obj_vec)
// {
//   for (auto*& obj : obj_vec) {
//     for (auto*& pin : obj->get_pin_list()) {
//       if (pin) {
//         delete pin;
//         pin = nullptr;
//       }
//     }
//     delete obj;
//     obj = nullptr;
//   }
// }

/**
 * @brief given a vector<float> of data, threshold, ceiling and step,
 * return a list of range and value counts.
 */
auto ReportEvaluator::CongStats(float threshold, float step, vector<float>& data)
{
  vector<float> range;
  if (data.empty()) {
    return std::tuple(range, vector<int>{});
  }
  float ceiling = *std::max_element(data.begin(), data.end());
  if (ceiling <= threshold || step <= 0.0F) {
    range.push_back(threshold);
    vector<int> count(1, 0);
    for (auto value : data) {
      if (value >= threshold && value <= ceiling) {
        count[0]++;
      }
    }
    return std::tuple(range, count);
  }
  for (auto r = threshold; r < ceiling; r += step) {
    range.push_back(r);
  }
  vector<int> count(range.size(), 0);
  for (auto value : data) {
    if (value < threshold || value > ceiling) {
      continue;
    }
    size_t index = 0;
    for (; index + 1 < range.size() && range[index] < value; ++index)
      ;
    count[index]++;
  }
  return std::tuple(range, count);
}

std::shared_ptr<ieda::ReportTable> ReportEvaluator::createWireLengthReport()
{
  // prepare data & initialization work
  auto& nets = dmInst->get_idb_design()->get_net_list()->get_net_list();

  ieval::TotalWLSummary total_wl_summary = WIRELENGTH_API_INST->totalWL();
  auto hpwl_total = total_wl_summary.HPWL;
  auto flute_total = total_wl_summary.FLUTE;
  auto grwl_total = total_wl_summary.GRWL;

  // calculate wire length asynchronously
  auto real = std::async(std::launch::async, [&nets]() { return computeWireLength(nets, &idb::IdbNet::wireLength); });
  auto [real_total, real_max, real_max_net] = real.get();
  auto net_num = nets.size();

  // output results to report table
  // std::vector<std::string> header = {"Wire-length Model", "Total Length", "Average Length", "Longest Net Name", "Longest Length"};
  std::vector<std::string> header = {"Wire-length Model", "Total Length", "Average Length"};

  auto tbl = std::make_shared<ieda::ReportTable>("Wire Length Report", header, static_cast<int>(ReportEvaluatorType::kWireLength));
  if (real_total > 0) {
    *tbl << "Real Length" << real_total << real_total / net_num << TABLE_ENDLINE;
  }
  *tbl << "HPWL" << hpwl_total << hpwl_total / net_num << TABLE_ENDLINE;
  *tbl << "FLUTE" << flute_total << flute_total / net_num << TABLE_ENDLINE;
  *tbl << "EGR" << grwl_total << grwl_total / net_num << TABLE_ENDLINE;

  // free allocated data asynchoronously
  // std::thread([](std::vector<eval::WLNet*>&& nets) { freeWrapped(nets); }, std::move(wl_nets)).detach();

  return tbl;
}

std::shared_ptr<ieda::ReportTable> ReportEvaluator::createCongestionReport()
{
  // evaluate Instance Density & Pin Density
  std::string stage = "place";  // hard code , only for place stage
  ieval::DensityMapSummary density_map_summay = DENSITY_API_INST->densityMap(stage);

  std::string pin_density_file_path = density_map_summay.pin_map_summary.allcell_pin_density;
  std::string inst_density_file_path = density_map_summay.cell_map_summary.allcell_density;
  const auto pin_density_values = readFloatCsvValues(pin_density_file_path);
  const auto inst_density_values = readFloatCsvValues(inst_density_file_path);
  // prepare report table

  std::vector<std::string> header = {"Grid Bin Size", "Bin Partition", "Total Count"};
  auto tbl = std::make_shared<ieda::ReportTable>("Congestion Report", header, static_cast<int>(ReportEvaluatorType::kCongestion));
  // // Bin information
  // *tbl << Str::printf("%d * %d", cong_grid->get_bin_size_x(), cong_grid->get_bin_size_y())
  //      << Str::printf("%d by %d", cong_grid->get_bin_cnt_x(), cong_grid->get_bin_cnt_y())
  //      << cong_grid->get_bin_cnt_x() * cong_grid->get_bin_cnt_y() << TABLE_ENDLINE;

  // Instance Density Information
  *tbl << TABLE_HEAD << "Instance Density Range"
       << "Bins Count"
       << "Percentage " << TABLE_ENDLINE;
  if (inst_density_values) {
    std::vector<float> inst_density = *inst_density_values;
    float inst_den_max = *std::max_element(inst_density.begin(), inst_density.end());
    auto [inst_den_range, inst_den_cnt] = CongStats(inst_den_max * 0.75, 0.05 * inst_den_max, inst_density);
    inst_den_range.push_back(inst_den_max);
    for (int i = inst_den_cnt.size() - 1; i >= 0; --i) {
      *tbl << ieda::Str::printf("%.2f ~ %.2f", inst_den_range[i], inst_den_range[i + 1]) << inst_den_cnt[i]
           << ieda::Str::printf("%.2f", 100 * inst_den_cnt[i] / static_cast<double>(inst_density.size())) << TABLE_ENDLINE;
    }
  } else {
    *tbl << "N/A"
         << "N/A"
         << "N/A" << TABLE_ENDLINE;
  }

  // Pin Density Information
  *tbl << TABLE_HEAD << "Pin Count Range"
       << "Bins Count"
       << "Percentage" << TABLE_ENDLINE;
  if (pin_density_values) {
    std::vector<float> pin_density = *pin_density_values;
    float pin_den_max = *std::max_element(pin_density.begin(), pin_density.end());
    auto [pin_den_range, pin_den_cnt] = CongStats(pin_den_max * 0.5, pin_den_max * 0.1, pin_density);
    pin_den_range.push_back(pin_den_max);
    for (int i = pin_den_cnt.size() - 1; i >= 0; --i) {
      *tbl << ieda::Str::printf("%.0f ~ %.0f", pin_den_range[i], pin_den_range[i + 1]) << pin_den_cnt[i]
           << ieda::Str::printf("%.2f", 100 * pin_den_cnt[i] / static_cast<double>(pin_density.size())) << TABLE_ENDLINE;
    }
  } else {
    *tbl << "N/A"
         << "N/A"
         << "N/A" << TABLE_ENDLINE;
  }

  // evaluate EGR Congestion

  *tbl << TABLE_HEAD << "Average Congestion of Edges"
       << "Total Overflow"
       << "Maximal Overflow"
       << "Top 1% Mean"
       << "Top 5% Mean"
       << "Non-zero Bins (%)"
       << "Average Source" << TABLE_ENDLINE;

  const std::string summary_path = dmInst->get_config().get_output_path() + "/congestion_summary.json";

  CONGESTION_API_INST->egrMap(stage);
  CONGESTION_API_INST->writeCongestionSummary(stage, summary_path);

  ieval::OverflowSummary overflow_summary;
  std::optional<ieval::CongestionSummaryDocument> congestion_summary_doc = CONGESTION_API_INST->readCongestionSummary(summary_path);
  if (congestion_summary_doc && congestion_summary_doc->valid) {
    const auto& summary_doc = *congestion_summary_doc;
    overflow_summary.total_overflow_union = static_cast<int32_t>(summary_doc.union_map.total);
    overflow_summary.max_overflow_union = summary_doc.union_map.max;
    overflow_summary.weighted_average_overflow_union = static_cast<float>(summary_doc.union_map.weighted_average);
    overflow_summary.total_overflow_horizontal = static_cast<int32_t>(summary_doc.horizontal.total);
    overflow_summary.total_overflow_vertical = static_cast<int32_t>(summary_doc.vertical.total);
    overflow_summary.max_overflow_horizontal = summary_doc.horizontal.max;
    overflow_summary.max_overflow_vertical = summary_doc.vertical.max;
    overflow_summary.weighted_average_overflow_horizontal = static_cast<float>(summary_doc.horizontal.weighted_average);
    overflow_summary.weighted_average_overflow_vertical = static_cast<float>(summary_doc.vertical.weighted_average);
  } else {
    overflow_summary = CONGESTION_API_INST->egrOverflow(stage);
  }

  if (overflow_summary.isValid()) {
    *tbl << ieda::Str::printf("%.2f", overflow_summary.weighted_average_overflow_union)
         << ieda::Str::printf("%d", overflow_summary.total_overflow_union)
         << ieda::Str::printf("%d", overflow_summary.max_overflow_union);
    if (congestion_summary_doc && congestion_summary_doc->valid) {
      *tbl << ieda::Str::printf("%.2f", congestion_summary_doc->union_map.top_1_pct_mean)
           << ieda::Str::printf("%.2f", congestion_summary_doc->union_map.top_5_pct_mean)
           << ieda::Str::printf("%.2f", congestion_summary_doc->union_map.nonzero_bin_pct)
           << congestion_summary_doc->union_map.weighted_average_source;
    } else {
      *tbl << "N/A"
           << "N/A"
           << "N/A"
           << "legacy";
    }
    *tbl << TABLE_ENDLINE;
  } else {
    *tbl << "N/A"
         << "N/A"
         << "N/A"
         << "N/A"
         << "N/A"
         << "N/A"
         << "N/A" << TABLE_ENDLINE;
  }

  // Release wrapped congestion instance objects.
  // std::thread([](std::vector<eval::CongInst*>&& insts) { freeWrapped(insts); }, std::move(cong_inst)).detach();

  return tbl;
}

}  // namespace iplf
