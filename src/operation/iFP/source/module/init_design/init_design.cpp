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
#include "init_design.h"

#include "../../utility/FloorplanGeometry.hh"
#include "IdbDesign.h"
#include "idm.h"

namespace ifp {

int32_t InitDesign::transUnitDB(double value)
{
  auto idb_design = dmInst->get_idb_design();
  auto idb_layout = idb_design->get_layout();

  return idb_layout != nullptr ? idb_layout->transUnitDB(value) : -1;
}

bool InitDesign::initDie(double die_lx, double die_ly, double die_ux, double die_uy)
{
  if (!isValidCoordinateBox(die_lx, die_ly, die_ux, die_uy)) {
    return false;
  }

  auto idb_design = dmInst->get_idb_design();
  if (idb_design == nullptr) {
    return false;
  }
  auto idb_layout = idb_design->get_layout();
  if (idb_layout == nullptr) {
    return false;
  }
  auto idb_die = idb_layout->get_die();
  if (idb_die == nullptr) {
    return false;
  }

  const FloorplanBox die_box{.low_x = transUnitDB(die_lx),
                             .low_y = transUnitDB(die_ly),
                             .high_x = transUnitDB(die_ux),
                             .high_y = transUnitDB(die_uy)};
  if (!isValidFloorplanBox(die_box)) {
    return false;
  }

  idb_die->reset();
  idb_die->add_point(die_box.low_x, die_box.low_y);
  idb_die->add_point(die_box.high_x, die_box.high_y);

  return true;
}

bool InitDesign::initCore(double core_lx, double core_ly, double core_ux, double core_uy, std::string core_site_name,
                          std::string iocell_site_name, std::string corner_site_name)
{
  if (!isValidCoordinateBox(core_lx, core_ly, core_ux, core_uy)) {
    return false;
  }

  auto idb_design = dmInst->get_idb_design();
  if (idb_design == nullptr) {
    return false;
  }
  auto idb_layout = idb_design->get_layout();
  if (idb_layout == nullptr) {
    return false;
  }
  auto idb_sites = idb_layout->get_sites();
  if (idb_sites == nullptr) {
    return false;
  }
  auto idb_die = idb_layout->get_die();
  auto core_site = idb_sites->find_site(core_site_name);
  auto io_site = idb_sites->find_site(iocell_site_name);
  auto corner_site = idb_sites->find_site(corner_site_name);
  if (nullptr == idb_die || nullptr == core_site || nullptr == corner_site) {
    return false;
  }

  /// set site
  idb_sites->set_core_site(core_site);
  idb_sites->set_io_site(io_site);
  idb_sites->set_corener_site(corner_site);

  int site_dx = core_site->get_width();
  int site_dy = core_site->get_height();
  if (site_dx <= 0 || site_dy <= 0) {
    return false;
  }

  // floor core lower left corner to multiple of core_site dx/dy.
  int core_lx_int = (transUnitDB(core_lx) / site_dx) * site_dx;
  int core_ly_int = (transUnitDB(core_ly) / site_dy) * site_dy;
  int core_ux_int = (transUnitDB(core_ux) / site_dx) * site_dx;
  int core_uy_int = (transUnitDB(core_uy) / site_dy) * site_dy;

  const FloorplanBox die_box{.low_x = idb_die->get_llx(),
                             .low_y = idb_die->get_lly(),
                             .high_x = idb_die->get_urx(),
                             .high_y = idb_die->get_ury()};
  const FloorplanBox core_box{
      .low_x = core_lx_int, .low_y = core_ly_int, .high_x = core_ux_int, .high_y = core_uy_int};
  if (!containsBox(die_box, core_box)) {
    return false;
  }

  /// make enough space for io cell
  //   int32_t io_height = io_site != nullptr ? io_site->get_height() : 0;
  //   if ((core_lx_int - idb_die->get_llx() < io_height) || (core_ly_int - idb_die->get_lly()) < io_height
  //       || (idb_die->get_urx() - core_ux_int) < io_height || (idb_die->get_ury() - core_uy_int) < io_height) {
  //     /// error report, tbd
  //     return false;
  //   }

  /// reset rows
  idb_layout->get_rows()->reset();

  /// create rows
  int site_number = abs(core_ux_int - core_lx_int) / site_dx;  // sites number on one row
  int row_number = abs(core_uy_int - core_ly_int) / site_dy;   // row number
  int index_y = core_ly_int;
  for (int row = 0; row < row_number; row++) {
    auto orient = row % 2 == 0 ? idb::IdbOrient::kFS_MX : idb::IdbOrient::kN_R0;

    /// set original horizontal
    dmInst->createRow(("ROW_" + std::to_string(row)), core_site_name, core_lx_int, index_y, orient, site_number, 1, site_dx, 0);

    index_y += site_dy;
  }

  /// set core boundary
  auto idb_core = idb_layout->get_core();
  idb_core->set_bounding_box(core_lx_int, core_ly_int, core_ux_int, core_uy_int);

  return true;
}

/**
 * @brief generate tracks
 *
 * @param layer_name
 * @param x_offset
 * @param x_pitch
 * @param y_offset
 * @param y_pitch
 * @return true
 * @return false
 */
bool InitDesign::makeTracks(std::string layer_name, int x_offset, int x_pitch, int y_offset, int y_pitch)
{
  auto idb_design = dmInst->get_idb_design();
  auto idb_layout = idb_design->get_layout();

  auto* routing_layer = dynamic_cast<idb::IdbLayerRouting*>(idb_layout->get_layers()->find_layer(layer_name));
  if (routing_layer == nullptr) {
    std::cout << "[FpApi error] : routing_layer " << layer_name << " do not exist!" << std::endl;
    return false;
  }

  auto track_grid_x = idb_layout->get_track_grid_list()->add_track_grid();
  track_grid_x->add_layer_list(routing_layer);
  routing_layer->add_track_grid(track_grid_x);
  track_grid_x->get_track()->set_direction(idb::IdbTrackDirection::kDirectionX);
  track_grid_x->get_track()->set_pitch(x_pitch);
  track_grid_x->get_track()->set_start(x_offset);
  int track_number = (int) ((idb_layout->get_die()->get_width() - x_offset) / x_pitch);
  track_grid_x->set_track_number(track_number);

  auto track_grid_y = idb_layout->get_track_grid_list()->add_track_grid();
  track_grid_y->add_layer_list(routing_layer);
  routing_layer->add_track_grid(track_grid_y);
  track_grid_y->get_track()->set_direction(idb::IdbTrackDirection::kDirectionY);
  track_grid_y->get_track()->set_pitch(y_pitch);
  track_grid_y->get_track()->set_start(y_offset);
  track_number = (int) ((idb_layout->get_die()->get_height() - y_offset) / y_pitch);
  track_grid_y->set_track_number(track_number);

  return true;
}

}  // namespace ifp