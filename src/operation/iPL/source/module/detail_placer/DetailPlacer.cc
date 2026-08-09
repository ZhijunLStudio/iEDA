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
#include "DetailPlacer.hh"

#include "json/json.hpp"
#include "module/evaluator/density/Density.hh"
#include "module/evaluator/wirelength/HPWirelength.hh"
#ifdef ENABLE_AI
#include "ai_wirelength.hh"
#endif
#include "module/checker/layout_checker/LayoutChecker.hh"
#include "operation/BinOpt.hh"
#include "operation/InstanceSwap.hh"
#include "operation/LocalReorder.hh"
#include "operation/NFSpread.hh"
#include "operation/RowOpt.hh"
#include "usage/usage.hh"
#include "utility/Utility.hh"

namespace ipl {

namespace {

using DPPlacementSnapshot = std::vector<std::pair<DPInstance*, Point<int32_t>>>;

DPPlacementSnapshot snapshotDPPlacement(DPDatabase& database)
{
  DPPlacementSnapshot snapshot;
  if (database.get_design() == nullptr) {
    return snapshot;
  }
  for (auto* inst : database.get_design()->get_inst_list()) {
    if (inst != nullptr) {
      snapshot.emplace_back(inst, inst->get_coordi());
    }
  }
  return snapshot;
}

void restoreDPPlacement(const DPPlacementSnapshot& snapshot)
{
  for (const auto& [inst, coordinate] : snapshot) {
    if (inst != nullptr) {
      inst->updateCoordi(coordinate.get_x(), coordinate.get_y());
    }
  }
}

}  // namespace

DetailPlacer::DetailPlacer(Config* pl_config, PlacerDB* placer_db)
{
  initDPConfig(pl_config);
  _config.set_grid_cnt_x(pl_config->get_nes_config().get_bin_cnt_x());
  _config.set_grid_cnt_y(pl_config->get_nes_config().get_bin_cnt_y());

  initDPDatabase(placer_db);
  _operator.initDPOperator(&_database, &_config);
}

DetailPlacer::~DetailPlacer()
{
}

void DetailPlacer::initDPConfig(Config* pl_config)
{
  _config = pl_config->get_dp_config();
}

void DetailPlacer::initDPDatabase(PlacerDB* placer_db)
{
  _database._placer_db = placer_db;
  initDPLayout();
  initDPDesign();
  initIntervalList();
}

void DetailPlacer::initDPLayout()
{
  const Layout* pl_layout = _database._placer_db->get_layout();

  auto core_shape = pl_layout->get_core_shape();
  int32_t row_height = pl_layout->get_row_height();
  int32_t row_num = std::floor(static_cast<double>(core_shape.get_height()) / row_height);

  // shift all element in core to (0,0)
  _database._shift_x = 0 - core_shape.get_ll_x();
  _database._shift_y = 0 - core_shape.get_ll_y();
  _database._layout = new DPLayout(row_num, core_shape.get_ur_x() + _database._shift_x, core_shape.get_ur_y() + _database._shift_y);
  _database._layout->set_dbu(pl_layout->get_database_unit());

  // arrange row to DPLayout _row_2d_list
  wrapRowList();

  // add DPLayout region list
  wrapRegionList();

  // add DPLayout cell list
  wrapCellList();
}

void DetailPlacer::wrapRowList()
{
  const Layout* pl_layout = _database._placer_db->get_layout();

  std::vector<std::vector<DPRow*>> row_2d_list;
  row_2d_list.resize(_database._layout->get_row_num());
  for (auto* pl_row : pl_layout->get_row_list()) {
    auto* pl_site = pl_row->get_site();
    DPSite* row_site = new DPSite(pl_site->get_name());
    row_site->set_width(pl_site->get_site_width());
    row_site->set_height(pl_site->get_site_height());

    int32_t row_shift_x = pl_row->get_coordi().get_x() + _database._shift_x;
    int32_t row_shift_y = pl_row->get_coordi().get_y() + _database._shift_y;
    int32_t row_index = std::floor(static_cast<double>(row_shift_y) / pl_row->get_site_height());
    DPRow* row = new DPRow(pl_row->get_name(), row_site, pl_row->get_site_num());
    row->set_coordinate(row_shift_x, row_shift_y);
    row->set_orient(std::move(pl_site->get_orient()));

    Rectangle<int64_t> rect(row_shift_x, row_shift_y, row_shift_x + pl_row->get_site_num() * row_site->get_width(),
                            row_shift_y + row_site->get_height());
    row->set_bound(rect);

    row_2d_list.at(row_index).push_back(row);
  }
  auto* dp_site = row_2d_list.at(0).at(0)->get_site();
  _database._layout->set_row_height(dp_site->get_height());
  _database._layout->set_site_width(dp_site->get_width());
  _database._layout->set_row_2d_list(row_2d_list);
}

void DetailPlacer::wrapRegionList()
{
  Design* pl_design = _database._placer_db->get_design();

  for (auto* pl_region : pl_design->get_region_list()) {
    DPRegion* region = new DPRegion(pl_region->get_name());
    if (pl_region->isFence()) {
      region->set_type(DPREGION_TYPE::kFence);
    }
    if (pl_region->isGuide()) {
      region->set_type(DPREGION_TYPE::kGuide);
    }
    for (auto boundary : pl_region->get_boundaries()) {
      int32_t llx = boundary.get_ll_x() + _database._shift_x;
      int32_t lly = boundary.get_ll_y() + _database._shift_y;
      int32_t urx = boundary.get_ur_x() + _database._shift_x;
      int32_t ury = boundary.get_ur_y() + _database._shift_y;
      region->add_shape(Rectangle<int32_t>(llx, lly, urx, ury));
    }
    _database._layout->add_region(region);
  }
}

void DetailPlacer::wrapCellList()
{
  const Layout* pl_layout = _database._placer_db->get_layout();

  for (auto* pl_cell : pl_layout->get_cell_list()) {
    DPCell* cell = new DPCell(pl_cell->get_name());
    if (pl_cell->isMacro()) {
      cell->set_type(DPCELL_TYPE::kMacro);
    }
    if (pl_cell->isClockBuffer() || pl_cell->isFlipflop()) {
      cell->set_type(DPCELL_TYPE::kSequence);
    }
    if (pl_cell->isLogic() || pl_cell->isPhysicalFiller()) {
      cell->set_type(DPCELL_TYPE::kStdcell);
    }
    cell->set_width(pl_cell->get_width());
    cell->set_height(pl_cell->get_height());
    _database._layout->add_cell(cell);
  }
}

void DetailPlacer::initDPDesign()
{
  _database._design = new DPDesign();
  wrapInstanceList();
  wrapNetList();
  correctOutsidePinCoordi();
  updateInstanceList();
}

void DetailPlacer::wrapInstanceList()
{
  auto* pl_design = _database._placer_db->get_design();
  auto* dp_design = _database._design;
  for (auto* pl_inst : pl_design->get_instance_list()) {
    DPInstance* dp_inst = wrapInstance(pl_inst);
    dp_design->add_instance(dp_inst);
    dp_design->connectInst(dp_inst, pl_inst);
  }
}

DPInstance* DetailPlacer::wrapInstance(Instance* pl_inst)
{
  DPInstance* dp_inst = new DPInstance(pl_inst->get_name());

  if (pl_inst->get_cell_master()) {
    std::string cell_name = pl_inst->get_cell_master()->get_name();
    auto* dp_cell = _database._layout->find_cell(cell_name);
    dp_inst->set_master(dp_cell);
  }

  // set dp_inst shape with shift x/y and right padding
  int32_t site_width = _database._layout->get_site_width();
  int32_t inst_lx = pl_inst->get_shape().get_ll_x() + _database._shift_x;
  int32_t inst_ly = pl_inst->get_shape().get_ll_y() + _database._shift_y;
  int32_t inst_ux = pl_inst->get_shape().get_ur_x() + _database._shift_x + _config.get_global_padding() * site_width;
  int32_t inst_uy = pl_inst->get_shape().get_ur_y() + _database._shift_y;
  dp_inst->set_shape(Rectangle<int32_t>(inst_lx, inst_ly, inst_ux, inst_uy));

  dp_inst->set_orient(pl_inst->get_orient());

  // set dp_inst state
  if (pl_inst->isUnPlaced()) {
    dp_inst->set_state(DPINSTANCE_STATE::kUnPlaced);
  } else if (pl_inst->isPlaced()) {
    dp_inst->set_state(DPINSTANCE_STATE::kPlaced);
  } else if (pl_inst->isFixed()) {
    dp_inst->set_state(DPINSTANCE_STATE::kFixed);
  }

  // set dp_inst reigon
  auto* pl_inst_region = pl_inst->get_belong_region();
  if (pl_inst_region) {
    auto* dp_inst_region = _database._layout->find_region(pl_inst_region->get_name());
    if (dp_inst_region) {
      dp_inst->set_belong_region(dp_inst_region);
      dp_inst_region->add_inst(dp_inst);
    } else {
      LOG_WARNING << "Region: " << pl_inst_region->get_name() << " has not been initialized!";
    }
  }

  dp_inst->set_weight(pl_inst->get_pins().size());

  return dp_inst;
}

void DetailPlacer::wrapNetList()
{
  auto* pl_design = _database._placer_db->get_design();
  auto* dp_design = _database._design;
  for (auto* pl_net : pl_design->get_net_list()) {
    DPNet* dp_net = wrapNet(pl_net);
    dp_design->add_net(dp_net);
  }
}

DPNet* DetailPlacer::wrapNet(Net* pl_net)
{
  DPNet* dp_net = new DPNet(pl_net->get_name());

  if (pl_net->isClockNet()) {
    dp_net->set_net_type(DPNET_TYPE::kClock);
  } else if (pl_net->isSignalNet()) {
    dp_net->set_net_type(DPNET_TYPE::kSignal);
  }

  if (pl_net->isDontCareNet()) {
    dp_net->set_net_state(DPNET_STATE::kDontCare);
  } else {
    dp_net->set_net_state(DPNET_STATE::kNormal);
  }

  dp_net->set_netweight(pl_net->get_net_weight());

  auto* pl_driver_pin = pl_net->get_driver_pin();
  if (pl_driver_pin) {
    DPPin* driver_pin = wrapPin(pl_driver_pin);
    driver_pin->set_net(dp_net);
    dp_net->set_driver_pin(driver_pin);
    dp_net->add_pin(driver_pin);
    _database._design->add_pin(driver_pin);
  }

  const auto& pl_pin_list = pl_net->get_sink_pins();
  for (size_t i = 0; i < pl_pin_list.size(); i++) {
    DPPin* dp_pin = wrapPin(pl_pin_list[i]);
    dp_pin->set_internal_id(i);
    dp_pin->set_net(dp_net);
    dp_net->add_pin(dp_pin);
    _database._design->add_pin(dp_pin);
  }

  return dp_net;
}

DPPin* DetailPlacer::wrapPin(Pin* pl_pin)
{
  DPPin* dp_pin = new DPPin(pl_pin->get_name());

  const auto& pin_coordi = pl_pin->get_center_coordi();
  const auto& pin_offset_coordi = pl_pin->get_offset_coordi();

  int32_t x_coordi = pin_coordi.get_x() + _database._shift_x;
  int32_t y_coordi = pin_coordi.get_y() + _database._shift_y;

  dp_pin->set_x_coordi(x_coordi);
  dp_pin->set_y_coordi(y_coordi);

  // offset compared to cell master
  dp_pin->set_offset_x(pin_offset_coordi.get_x());
  dp_pin->set_offset_y(pin_offset_coordi.get_y());

  auto* pl_pin_inst = pl_pin->get_instance();
  if (pl_pin_inst) {
    DPInstance* pin_inst = _database._design->find_instance(pl_pin_inst->get_name());
    if (pin_inst) {
      dp_pin->set_instance(pin_inst);
      pin_inst->add_pin(dp_pin);
    } else {
      LOG_WARNING << "Instance: " << pl_pin_inst->get_name() << " has not been initialized!";
    }
  }
  return dp_pin;
}

void DetailPlacer::updateInstanceList()
{
  for (auto* inst : _database.get_design()->get_inst_list()) {
    if (inst->get_state() == DPINSTANCE_STATE::kFixed) {
      continue;
    }
    auto coordi = std::move(inst->get_coordi());
    inst->updateCoordi(coordi.get_x(), coordi.get_y());
  }
}

void DetailPlacer::correctOutsidePinCoordi()
{
  int32_t core_max_x = _database.get_layout()->get_max_x();
  int32_t core_max_y = _database.get_layout()->get_max_y();
  Rectangle<int32_t> core_shape(0, 0, core_max_x, core_max_y);

  for (auto* net : _database.get_design()->get_net_list()) {
    auto bounding_box = std::move(net->obtainBoundingBox());
    if (_operator.checkInNest(bounding_box, core_shape)) {
      continue;
    }

    auto overlap_box = std::move(_operator.obtainOverlapRectangle(bounding_box, core_shape));
    int32_t overlap_wl = overlap_box.get_half_perimeter();
    if (overlap_wl != 0) {
      _database._outside_wl += (bounding_box.get_half_perimeter() - overlap_wl);

      for (auto* pin : net->get_pins()) {
        int32_t pin_x = pin->get_x_coordi();
        int32_t pin_y = pin->get_y_coordi();

        if (pin_x < 0) {
          pin_x = 0;
        }
        if (pin_y < 0) {
          pin_y = 0;
        }
        if (pin_x > core_max_x) {
          pin_x = core_max_x;
        }
        if (pin_y > core_max_y) {
          pin_y = core_max_y;
        }

        pin->set_x_coordi(pin_x);
        pin->set_y_coordi(pin_y);
      }
    }
  }
}

void DetailPlacer::initIntervalList()
{
  auto* layout = _database._layout;
  Utility utility;

  int32_t core_width = layout->get_max_x();
  int32_t core_height = layout->get_max_y();
  int32_t row_height = layout->get_row_height();
  int32_t site_width = layout->get_site_width();
  int32_t site_count_x = static_cast<double>(core_width) / site_width;
  int32_t site_count_y = layout->get_row_num();

  enum SiteInfo
  {
    kEmpty,
    kOccupied
  };
  std::vector<SiteInfo> site_grid(site_count_x * site_count_y, SiteInfo::kOccupied);

  // Deal with fragmented row case and add left global padding
  for (int32_t i = 0; i < layout->get_row_num(); i++) {
    for (auto* row : layout->get_row_2d_list().at(i)) {
      int32_t row_min_x = row->get_coordinate().get_x();
      int32_t row_max_x = row_min_x + row->get_site_num() * site_width;
      int32_t row_min_y = row->get_coordinate().get_y();
      int32_t row_max_y = row_min_y + row_height;
      std::pair<int32_t, int32_t> pair_x = utility.obtainMinMaxIdx(0, site_width, row_min_x, row_max_x);
      std::pair<int32_t, int32_t> pair_y = utility.obtainMinMaxIdx(0, row_height, row_min_y, row_max_y);

      // In order to ensure the left padding of instances
      pair_x.first = pair_x.first + _config.get_global_padding();

      for (int32_t j = pair_x.first; j < pair_x.second; j++) {
        for (int32_t k = pair_y.first; k < pair_y.second; k++) {
          LOG_FATAL_IF((k * site_count_x + j) >= static_cast<int32_t>(site_grid.size()))
              << "Row : " << row->get_name() << " is out of core boundary.";
          site_grid.at(k * site_count_x + j) = kEmpty;
        }
      }
    }
  }

  // Deal with fence region
  for (auto* region : layout->get_region_list()) {
    if (region->get_type() == DPREGION_TYPE::kFence) {
      for (auto rect : region->get_shape_list()) {
        std::pair<int32_t, int32_t> pair_x = utility.obtainMinMaxIdx(0, site_width, rect.get_ll_x(), rect.get_ur_x());
        std::pair<int32_t, int32_t> pair_y = utility.obtainMinMaxIdx(0, row_height, rect.get_ll_y(), rect.get_ur_y());

        // In order to ensure the left padding of instances
        pair_x.second = pair_x.second + _config.get_global_padding();

        for (int32_t i = pair_x.first; i < pair_x.second; i++) {
          for (int32_t j = pair_y.first; j < pair_y.second; j++) {
            LOG_FATAL_IF((j * site_count_x + i) >= static_cast<int32_t>(site_grid.size()))
                << "Region : " << region->get_name() << " is out of core boundary.";
            site_grid.at(j * site_count_x + i) = kOccupied;
          }
        }
      }
    }
  }

  // Deal with fixed instances
  for (auto* inst : _database._design->get_inst_list()) {
    if (inst->get_state() == DPINSTANCE_STATE::kFixed) {
      int32_t rect_llx = (inst->get_coordi().get_x() > 0 ? inst->get_coordi().get_x() : 0);
      int32_t rect_lly = (inst->get_coordi().get_y() > 0 ? inst->get_coordi().get_y() : 0);
      int32_t rect_urx = (inst->get_shape().get_ur_x() < core_width ? inst->get_shape().get_ur_x() : core_width);
      int32_t rect_ury = (inst->get_shape().get_ur_y() < core_height ? inst->get_shape().get_ur_y() : core_height);
      if ((rect_llx > core_width) || (rect_lly > core_height) || (rect_urx < 0) || (rect_ury < 0)) {
        continue;
      }

      std::pair<int32_t, int32_t> pair_x = utility.obtainMinMaxIdx(0, site_width, rect_llx, rect_urx);
      std::pair<int32_t, int32_t> pair_y = utility.obtainMinMaxIdx(0, row_height, rect_lly, rect_ury);

      for (int32_t i = pair_x.first; i < pair_x.second; i++) {
        for (int32_t j = pair_y.first; j < pair_y.second; j++) {
          site_grid.at(j * site_count_x + i) = kOccupied;
        }
      }
    }
  }

  // Add DPLayout interval_2d_list
  std::vector<std::vector<DPInterval*>> interval_2d_list;
  interval_2d_list.resize(_database._layout->get_row_num());
  for (int32_t j = 0; j < site_count_y; j++) {
    int32_t interval_cnt = 0;
    for (int32_t i = 0; i < site_count_x; i++) {
      if (site_grid.at(j * site_count_x + i) == kEmpty) {
        int32_t start_x = i;
        while (i < site_count_x && site_grid.at(j * site_count_x + i) == kEmpty) {
          ++i;
        }
        int32_t end_x = i;

        int32_t min_x = site_width * start_x;
        int32_t max_x = site_width * end_x;
        DPInterval* interval = new DPInterval(std::to_string(j) + "_" + std::to_string(interval_cnt++), min_x, max_x);

        // search belong row
        for (auto* row : layout->get_row_2d_list().at(j)) {
          int32_t row_lx = row->get_coordinate().get_x();
          int32_t row_ux = row_lx + row->get_site_num() * site_width;

          if (min_x >= row_lx && max_x <= row_ux) {
            interval->set_belong_row(row);
          }
        }
        interval_2d_list.at(j).push_back(interval);
      }
    }
  }
  _database._layout->set_interval_2d_list(interval_2d_list);
}

bool DetailPlacer::checkIsLegal()
{
  LayoutChecker checker(_database._placer_db);
  auto violations = checker.obtainViolationList();
  if (!violations.empty()) {
    for (const auto& violation : violations) {
      std::string names;
      for (size_t index = 0; index < violation.instance_names.size(); ++index) {
        if (index != 0) {
          names += ", ";
        }
        names += violation.instance_names.at(index);
      }
      LOG_ERROR << "Detail placement legality failed: " << layoutViolationTypeName(violation.type) << " -> " << names << " ("
                << violation.reason << ")";
    }
  }
  return violations.empty();
}

RowOptResult DetailPlacer::runRowOpt()
{
  const auto dp_snapshot = snapshotDPPlacement(_database);
  auto transaction = _database._placer_db->beginStageTransaction("row_opt");
  if (!transaction.active) {
    RowOptResult result;
    result.outcome = RowOptOutcome::kInvalidInput;
    result.reason = "row optimization could not open a PlacerDB transaction";
    return result;
  }

  RowOpt row_opt(&_config, &_database, &_operator);
  auto result = row_opt.runRowOpt();
  if (!result.completed || !result.legal) {
    restoreDPPlacement(dp_snapshot);
    _database._placer_db->rollbackStageTransaction(transaction);
    result.rolled_back = true;
    return result;
  }
  if (result.changed_count == 0) {
    _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }

  _operator.updateTopoManager();
  _database._design->writeBackToPL(_database._shift_x, _database._shift_y);
  _database._placer_db->updateTopoManager();
  _database._placer_db->updateGridManager();

  if (!checkIsLegal()) {
    result.legal = false;
    result.outcome = RowOptOutcome::kIllegalOutput;
    result.reason = "row optimization write-back produced an illegal placement";
    restoreDPPlacement(dp_snapshot);
    result.rolled_back = _database._placer_db->rollbackStageTransaction(transaction);
    if (!result.rolled_back) {
      result.reason += "; rollback failed";
    }
    return result;
  }
  if (!_database._placer_db->commitStageTransaction(transaction)) {
    result.outcome = RowOptOutcome::kIllegalOutput;
    result.reason = "row optimization could not commit its PlacerDB transaction";
    return result;
  }
  return result;
}

InstanceSwapResult DetailPlacer::runGlobalSwap()
{
  return runInstanceSwap(false);
}

InstanceSwapResult DetailPlacer::runVerticalSwap()
{
  return runInstanceSwap(true);
}

LocalReorderResult DetailPlacer::runLocalReorder()
{
  return runLocalReorderStage();
}

LocalReorderResult DetailPlacer::runLocalReorderStage()
{
  const auto dp_snapshot = snapshotDPPlacement(_database);
  auto transaction = _database._placer_db->beginStageTransaction("local_reorder");
  if (!transaction.active) {
    LocalReorderResult result;
    result.outcome = LocalReorderOutcome::kInvalidInput;
    result.reason = "local reorder could not open a PlacerDB transaction";
    return result;
  }

  LocalReorder reorder(&_config, &_database, &_operator);
  auto result = reorder.runLocalReorder();
  if (!result.completed || !result.legal) {
    restoreDPPlacement(dp_snapshot);
    result.rolled_back = _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }
  if (result.changed_count == 0) {
    _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }

  _operator.updateTopoManager();
  _database._design->writeBackToPL(_database._shift_x, _database._shift_y);
  _database._placer_db->updateTopoManager();
  _database._placer_db->updateGridManager();
  if (!checkIsLegal()) {
    result.legal = false;
    result.outcome = LocalReorderOutcome::kIllegalOutput;
    result.reason = "local reorder write-back produced an illegal placement";
    restoreDPPlacement(dp_snapshot);
    result.rolled_back = _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }
  if (!_database._placer_db->commitStageTransaction(transaction)) {
    result.reason = "local reorder could not commit its PlacerDB transaction";
  }
  return result;
}

BinOptResult DetailPlacer::runBinOpt()
{
  return runBinOptStage();
}

BinOptResult DetailPlacer::runBinOptStage()
{
  const auto dp_snapshot = snapshotDPPlacement(_database);
  auto transaction = _database._placer_db->beginStageTransaction("bin_opt");
  if (!transaction.active) {
    BinOptResult result;
    result.outcome = BinOptOutcome::kInvalidInput;
    result.reason = "bin optimization could not open a PlacerDB transaction";
    return result;
  }

  BinOpt bin_opt(&_config, &_database, &_operator);
  auto result = bin_opt.runBinOpt();
  if (!result.completed || !result.legal) {
    restoreDPPlacement(dp_snapshot);
    result.rolled_back = _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }
  if (result.changed_count == 0) {
    _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }

  _operator.updateTopoManager();
  _database._design->writeBackToPL(_database._shift_x, _database._shift_y);
  _database._placer_db->updateTopoManager();
  _database._placer_db->updateGridManager();
  if (!checkIsLegal()) {
    result.legal = false;
    result.outcome = BinOptOutcome::kIllegalOutput;
    result.reason = "bin optimization write-back produced an illegal placement";
    restoreDPPlacement(dp_snapshot);
    result.rolled_back = _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }
  if (!_database._placer_db->commitStageTransaction(transaction)) {
    result.reason = "bin optimization could not commit its PlacerDB transaction";
  }
  return result;
}

InstanceSwapResult DetailPlacer::runInstanceSwap(bool vertical)
{
  const auto dp_snapshot = snapshotDPPlacement(_database);
  auto transaction = _database._placer_db->beginStageTransaction(vertical ? "vertical_swap" : "global_swap");
  if (!transaction.active) {
    InstanceSwapResult result;
    result.outcome = InstanceSwapOutcome::kInvalidInput;
    result.reason = "instance swap could not open a PlacerDB transaction";
    return result;
  }

  InstanceSwap instance_swap(&_config, &_database, &_operator);
  auto result = vertical ? instance_swap.runVerticalSwap() : instance_swap.runGlobalSwap();
  if (!result.completed || !result.legal) {
    restoreDPPlacement(dp_snapshot);
    result.rolled_back = _database._placer_db->rollbackStageTransaction(transaction);
    if (!result.rolled_back) {
      result.outcome = InstanceSwapOutcome::kRollbackFailed;
      result.reason += "; rollback failed";
    }
    return result;
  }
  if (result.changed_count == 0) {
    _database._placer_db->rollbackStageTransaction(transaction);
    return result;
  }

  _operator.updateTopoManager();
  _database._design->writeBackToPL(_database._shift_x, _database._shift_y);
  _database._placer_db->updateTopoManager();
  _database._placer_db->updateGridManager();
  if (!checkIsLegal()) {
    result.legal = false;
    result.outcome = InstanceSwapOutcome::kIllegalOutput;
    result.reason = "instance swap write-back produced an illegal placement";
    restoreDPPlacement(dp_snapshot);
    result.rolled_back = _database._placer_db->rollbackStageTransaction(transaction);
    if (!result.rolled_back) {
      result.outcome = InstanceSwapOutcome::kRollbackFailed;
      result.reason += "; rollback failed";
    }
    return result;
  }
  if (!_database._placer_db->commitStageTransaction(transaction)) {
    result.outcome = InstanceSwapOutcome::kRollbackFailed;
    result.reason = "instance swap could not commit its PlacerDB transaction";
  }
  return result;
}

bool DetailPlacer::runDetailPlace()
{
  LOG_INFO << "-----------------Start Detail Placement-----------------";
  ieda::Stats dp_status;
  _last_result = DetailPlacementResult{};
  _last_result.legal_before = checkIsLegal();
  _last_result.hpwl_before = calTotalHPWL();
  if (!_last_result.legal_before) {
    _last_result.outcome = DetailPlacementOutcome::kInputIllegal;
    _last_result.hpwl_after = _last_result.hpwl_before;
    _last_result.reason = "placement before detail placement is illegal";
    return false;
  }

  auto transaction = _database._placer_db->beginStageTransaction("detail_placement");
  if (!transaction.active) {
    _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
    _last_result.hpwl_after = _last_result.hpwl_before;
    _last_result.reason = "detail placement could not open a PlacerDB transaction";
    return false;
  }

  const auto record_operator = [this](const std::string& name, bool enabled, bool entered, bool completed, int64_t changed,
                                      int64_t before, int64_t after, int64_t candidates, int64_t accepted,
                                      const std::string& reason, const nlohmann::json& details = nlohmann::json::object()) {
    auto record = nlohmann::json{{"operator", name},
                                 {"enabled", enabled},
                                 {"entered", entered},
                                 {"completed", completed},
                                 {"changed_count", changed},
                                 {"hpwl_before", before},
                                 {"hpwl_after", after},
                                 {"candidate_count", candidates},
                                 {"accepted_count", accepted},
                                 {"reason", reason}};
    for (const auto& item : details.items()) {
      record[item.key()] = item.value();
    }
    _last_result.operator_exhibit.push_back(record.dump());
  };

  LOG_INFO << "Execution Origin Instance Shift: ";
  if (_config.isEnableRowOpt()) {
    RowOpt row_opt(&_config, &_database, &_operator);
    auto row_opt_result = row_opt.runRowOpt();
    _operator.updateTopoManager();
    row_opt_result.hpwl_after = calTotalHPWL();
    record_operator("row_opt", true, true, row_opt_result.completed, row_opt_result.changed_count,
                    row_opt_result.hpwl_before, row_opt_result.hpwl_after, -1, -1, row_opt_result.reason);
    if (!row_opt_result.completed || !row_opt_result.legal) {
      _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
      _last_result.hpwl_after = _last_result.hpwl_before;
      _last_result.reason = "row optimization failed: " + row_opt_result.reason;
      _database._placer_db->rollbackStageTransaction(transaction);
      return false;
    }
  } else {
    record_operator("row_opt", false, false, true, 0, calTotalHPWL(), calTotalHPWL(), -1, -1,
                    "disabled by configuration");
  }
  LOG_INFO << "After RowOpt HPWL: " << calTotalHPWL();
  // _operator.updateGridManager();
  // LOG_INFO << "After Origin Peak Bin Density: " << calPeakBinDensity();

  double threshold = 0.005;

  double improve_ratio = threshold;  // NOLINT
  int64_t front_hpwl = calTotalHPWL();
  int64_t update_hpwl = front_hpwl;  // NOLINT
  int32_t swap_iter = 0;
  do {
    LOG_INFO << "Execution Swap Iteration: " << swap_iter;

    if (_config.isEnableInstanceSwap()) {
      InstanceSwap swap_opt(&_config, &_database, &_operator);
      auto global_swap_result = swap_opt.runGlobalSwap();
      _operator.updateTopoManager();
      global_swap_result.hpwl_after = calTotalHPWL();
      record_operator("instance_swap_global", true, true, global_swap_result.completed, global_swap_result.changed_count,
                      global_swap_result.hpwl_before, global_swap_result.hpwl_after, global_swap_result.candidate_count,
                      global_swap_result.accepted_count, global_swap_result.reason);
      if (!global_swap_result.isSuccessful()) {
        _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
        _last_result.hpwl_after = calTotalHPWL();
        _last_result.reason = "global swap failed: " + global_swap_result.reason;
        _database._placer_db->rollbackStageTransaction(transaction);
        return false;
      }

      auto vertical_swap_result = swap_opt.runVerticalSwap();
      _operator.updateTopoManager();
      vertical_swap_result.hpwl_after = calTotalHPWL();
      record_operator("instance_swap_vertical", true, true, vertical_swap_result.completed,
                      vertical_swap_result.changed_count, vertical_swap_result.hpwl_before, vertical_swap_result.hpwl_after,
                      vertical_swap_result.candidate_count, vertical_swap_result.accepted_count, vertical_swap_result.reason);
      if (!vertical_swap_result.isSuccessful()) {
        _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
        _last_result.hpwl_after = calTotalHPWL();
        _last_result.reason = "vertical swap failed: " + vertical_swap_result.reason;
        _database._placer_db->rollbackStageTransaction(transaction);
        return false;
      }
    } else {
      const int64_t hpwl = calTotalHPWL();
      record_operator("instance_swap_global", false, false, true, 0, hpwl, hpwl, -1, -1,
                      "disabled by configuration");
      record_operator("instance_swap_vertical", false, false, true, 0, hpwl, hpwl, -1, -1,
                      "disabled by configuration");
    }
    LOG_INFO << "---After Vertical Swap HPWL: " << calTotalHPWL();
    // _operator.updateGridManager();
    // LOG_INFO << "---After Vertical Swap Peak Density: " << calPeakBinDensity();

    if (_config.isEnableLocalReorder()) {
      LocalReorder reorder_opt(&_config, &_database, &_operator);
      auto reorder_result = reorder_opt.runLocalReorder();
      _operator.updateTopoManager();
      reorder_result.hpwl_after = calTotalHPWL();
      record_operator("local_reorder", true, true, reorder_result.completed, reorder_result.changed_count,
                      reorder_result.hpwl_before, reorder_result.hpwl_after, reorder_result.candidate_count,
                      reorder_result.accepted_count, reorder_result.reason,
                      nlohmann::json{{"window_count", reorder_result.window_count},
                                     {"search_count", reorder_result.search_count},
                                     {"search_budget", reorder_result.search_budget},
                                     {"max_window", reorder_result.max_window},
                                     {"budget_exhausted", reorder_result.budget_exhausted}});
      if (!reorder_result.isSuccessful()) {
        _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
        _last_result.hpwl_after = calTotalHPWL();
        _last_result.reason = "local reorder failed: " + reorder_result.reason;
        _database._placer_db->rollbackStageTransaction(transaction);
        return false;
      }
    } else {
      const int64_t hpwl = calTotalHPWL();
      record_operator("local_reorder", false, false, true, 0, hpwl, hpwl, -1, -1,
                      "disabled by configuration");
    }
    LOG_INFO << "---After Local Reorder HPWL: " << calTotalHPWL();
    // _operator.updateGridManager();
    // LOG_INFO << "---After Local Reorder Peak Density: " << calPeakBinDensity();

    update_hpwl = calTotalHPWL();
    improve_ratio = static_cast<double>(front_hpwl - update_hpwl) / front_hpwl;

    // BinOpt bin_opt(&_config, &_database, &_operator);
    // bin_opt.runBinOpt();
    // _operator.updateTopoManager();
    // LOG_INFO << "---After Bin Opt HPWL: " << calTotalHPWL();
    // _operator.updateGridManager();
    // LOG_INFO << "---After Bin Opt Peak Density: " << calPeakBinDensity();

    if (_config.isEnableBinOpt()) {
      BinOpt bin_opt(&_config, &_database, &_operator);
      const auto bin_opt_result = bin_opt.runBinOpt();
      record_operator("bin_opt", true, true, bin_opt_result.completed, bin_opt_result.changed_count,
                      bin_opt_result.hpwl_before, bin_opt_result.hpwl_after, bin_opt_result.candidate_count, -1,
                      bin_opt_result.reason);
      if (!bin_opt_result.isSuccessful()) {
        _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
        _last_result.hpwl_after = calTotalHPWL();
        _last_result.reason = "bin optimization failed: " + bin_opt_result.reason;
        _database._placer_db->rollbackStageTransaction(transaction);
        return false;
      }
    } else {
      record_operator("bin_opt", false, false, true, 0, calTotalHPWL(), calTotalHPWL(), -1, -1,
                      "disabled by configuration");
    }

    if (_config.isEnableRowOpt()) {
      RowOpt row_opt_test(&_config, &_database, &_operator);
      auto row_opt_test_result = row_opt_test.runRowOpt();
      _operator.updateTopoManager();
      row_opt_test_result.hpwl_after = calTotalHPWL();
      record_operator("row_opt_iteration", true, true, row_opt_test_result.completed,
                      row_opt_test_result.changed_count, row_opt_test_result.hpwl_before, row_opt_test_result.hpwl_after,
                      -1, -1, row_opt_test_result.reason);
      if (!row_opt_test_result.isSuccessful()) {
        _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
        _last_result.hpwl_after = calTotalHPWL();
        _last_result.reason = "row optimization iteration failed: " + row_opt_test_result.reason;
        _database._placer_db->rollbackStageTransaction(transaction);
        return false;
      }
    } else {
      const int64_t hpwl = calTotalHPWL();
      record_operator("row_opt_iteration", false, false, true, 0, hpwl, hpwl, -1, -1,
                      "disabled by configuration");
    }
    LOG_INFO << "---After Row Opt HPWL: " << calTotalHPWL();
    // _operator.updateGridManager();
    // LOG_INFO << "After Row Opt Peak Density: " << calPeakBinDensity();

    update_hpwl = calTotalHPWL();
    front_hpwl = update_hpwl;
    ++swap_iter;
  } while (improve_ratio > threshold && swap_iter < 10);

  int32_t shift_iter = 0;
  do {
    LOG_INFO << "Execution Final Instance Shift Iteration: " << shift_iter;

    if (_config.isEnableRowOpt()) {
      RowOpt row_opt2(&_config, &_database, &_operator);
      auto row_opt2_result = row_opt2.runRowOpt();
      _operator.updateTopoManager();
      row_opt2_result.hpwl_after = calTotalHPWL();
      record_operator("row_opt_final", true, true, row_opt2_result.completed, row_opt2_result.changed_count,
                      row_opt2_result.hpwl_before, row_opt2_result.hpwl_after, -1, -1, row_opt2_result.reason);
      if (!row_opt2_result.isSuccessful()) {
        _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
        _last_result.hpwl_after = calTotalHPWL();
        _last_result.reason = "final row optimization failed: " + row_opt2_result.reason;
        _database._placer_db->rollbackStageTransaction(transaction);
        return false;
      }
    } else {
      const int64_t hpwl = calTotalHPWL();
      record_operator("row_opt_final", false, false, true, 0, hpwl, hpwl, -1, -1,
                      "disabled by configuration");
    }

    update_hpwl = calTotalHPWL();
    improve_ratio = static_cast<double>(front_hpwl - update_hpwl) / front_hpwl;
    front_hpwl = update_hpwl;

    LOG_INFO << "---After RowOpt HPWL: " << update_hpwl;
    // _operator.updateGridManager();
    // LOG_INFO << "Iteration: " << shift_iter << " Row Opt Peak Density: " << calPeakBinDensity();
    ++shift_iter;
  } while (improve_ratio > threshold && shift_iter < 10);

  notifyPLPlaceDensity();

  _database._design->writeBackToPL(_database._shift_x, _database._shift_y);
  _database._placer_db->updateTopoManager();
  _database._placer_db->updateGridManager();
  _last_result.changed_count = transaction.changedInstanceCount();
  _last_result.hpwl_after = calTotalHPWL();
  _last_result.legal_after = checkIsLegal();
  if (!_last_result.legal_after) {
    LOG_WARNING << "Detail placement completed but legality check failed after writeback.";
    _last_result.outcome = DetailPlacementOutcome::kOutputIllegal;
    _last_result.reason = "detail placement produced an illegal placement";
    if (_database._placer_db->rollbackStageTransaction(transaction)) {
      _last_result.rolled_back = true;
    } else {
      _last_result.outcome = DetailPlacementOutcome::kRollbackFailed;
      _last_result.reason = "detail placement produced an illegal placement and rollback failed";
    }
    return false;
  }

  if (!_database._placer_db->commitStageTransaction(transaction)) {
    _last_result.outcome = DetailPlacementOutcome::kAlgorithmFailed;
    _last_result.reason = "detail placement could not commit PlacerDB transaction";
    return false;
  }
  _last_result.outcome = DetailPlacementOutcome::kCompleted;
  _last_result.execution_success = true;
  _last_result.reason = "detail placement completed";

  double time_delta = dp_status.elapsedRunTime();
  LOG_INFO << "Detail Plaement Total Time Elapsed: " << time_delta << "s";
  LOG_INFO << "-----------------Finish Detail Placement-----------------";
  return true;
}

bool DetailPlacer::runDetailPlaceNFS()
{
  LOG_INFO << "-----------------Start Network Flow Cell Spreading-----------------";
  ieda::Stats dp_status;

  NFSpread nfspread_opt(&_config, &_database, &_operator);
  _last_nfs_result = nfspread_opt.runNFSpread();
  if (!_last_nfs_result.isSuccessful()) {
    LOG_ERROR << "Network flow cell spreading failed: " << _last_nfs_result.reason;
    return false;
  }
  _operator.updateTopoManager();

  _database._design->writeBackToPL(_database._shift_x, _database._shift_y);
  _database._placer_db->updateTopoManager();
  _database._placer_db->updateGridManager();

  double time_delta = dp_status.elapsedRunTime();
  LOG_INFO << "Detail Plaement Total Time Elapsed: " << time_delta << "s";
  LOG_INFO << "-----------------Finish Network Flow Cell Spreading-----------------";
  return true;
}

void DetailPlacer::notifyPLPlaceDensity()
{
  auto* grid_manager = _operator.get_grid_manager();
  PlacerDBInst.place_density[2] = grid_manager->obtainAvgGridDensity();
}

int64_t DetailPlacer::calTotalHPWL()
{
#ifdef ENABLE_AI
  if (_use_ai_wirelength && aiPLWireLengthInst->isModelLoaded()) {
    LOG_INFO << "Calculate Total Wirelength using AI model.";
    return calTotalAIWirelength() + _database._outside_wl;
  } else {
#endif
    HPWirelength hpwl_eval(_operator.get_topo_manager());
    return hpwl_eval.obtainTotalWirelength() + _database._outside_wl;
#ifdef ENABLE_AI
  }
#endif
}

#ifdef ENABLE_AI
bool DetailPlacer::init_ai_wirelength_model(const std::string& model_path, const std::string& params_path)
{
  _use_ai_wirelength = aiPLWireLengthInst->init(model_path, params_path, _operator.get_topo_manager());

  return _use_ai_wirelength;
}

int64_t DetailPlacer::calTotalAIWirelength()
{
  if (_use_ai_wirelength && aiPLWireLengthInst->isModelLoaded()) {
    return aiPLWireLengthInst->obtainTotalWirelength();
  }
  return 0;
}
#endif

float DetailPlacer::calPeakBinDensity()
{
  Density density_eval(_operator.get_grid_manager());
  return density_eval.obtainPeakBinDensity();
}

void DetailPlacer::clearClusterInfo()
{
  _database.get_design()->clearClusterInfo();
}

void DetailPlacer::alignInstanceOrient()
{
  for (auto* inst : _database.get_design()->get_inst_list()) {
    if (inst->get_state() == DPINSTANCE_STATE::kFixed) {
      continue;
    }

    auto* inst_row = inst->get_belong_cluster()->get_belong_interval()->get_belong_row();
    inst->set_orient(inst_row->get_row_orient());
  }
}

}  // namespace ipl
