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
#include "LocalReorder.hh"

#include <algorithm>
#include <map>
#include <numeric>

#include "module/logger/Log.hh"

namespace ipl{

LocalReorder::LocalReorder(DPConfig* config, DPDatabase* database, DPOperator* dp_operator)
{
    _config = config;
    _database = database;
    _operator = dp_operator;
}

LocalReorder::~LocalReorder()
{
}

LocalReorderResult LocalReorder::runLocalReorder()
{
    _last_result = LocalReorderResult{};
    if (_database == nullptr || _database->get_design() == nullptr || _database->get_layout() == nullptr || _operator == nullptr
        || _database->get_layout()->get_row_height() <= 0) {
        _last_result.outcome = LocalReorderOutcome::kInvalidInput;
        _last_result.reason = "local reorder has incomplete database";
        return _last_result;
    }
    _last_result.max_window = std::max(2, _config == nullptr ? 2 : _config->get_local_reorder_max_window());
    _last_result.search_budget = _config == nullptr ? -1 : _config->get_local_reorder_budget();
    if (_last_result.search_budget < -1) {
        _last_result.outcome = LocalReorderOutcome::kInvalidInput;
        _last_result.reason = "local reorder search budget must be -1 or non-negative";
        return _last_result;
    }
    if (_last_result.search_budget == 0) {
        _last_result.completed = true;
        _last_result.legal = checkOutputLegal();
        _last_result.hpwl_before = _operator->calTotalHPWL();
        _last_result.hpwl_after = _last_result.hpwl_before;
        _last_result.outcome = _last_result.legal ? LocalReorderOutcome::kNoOp : LocalReorderOutcome::kIllegalOutput;
        _last_result.reason = _last_result.legal ? "local reorder search budget is zero" : "local reorder input is illegal";
        return _last_result;
    }

    std::map<DPInstance*, Point<int32_t>> before_coordinates;
    for (auto* inst : _database->get_design()->get_inst_list()) {
        if (inst != nullptr) {
            before_coordinates.emplace(inst, inst->get_coordi());
        }
    }
    _last_result.hpwl_before = _operator->calTotalHPWL();

    bool is_clusted = _operator->checkIfClustered();
    if(!is_clusted){
        _operator->updateInstClustering();
    }

    auto& interval_2d_list = _database->get_layout()->get_interval_2d_list();

    for(auto& interval_list : interval_2d_list){
        for(auto* interval : interval_list){

            auto* cur_cluster = interval->get_cluster_root();
            while(cur_cluster){
                const auto& cluster_instances = cur_cluster->get_inst_list();
                const size_t cluster_size = cluster_instances.size();
                for (size_t start = 0; start + 1 < cluster_size; ++start) {
                    const size_t window_size = std::min(static_cast<size_t>(_last_result.max_window), cluster_size - start);
                    if (window_size < 2) {
                        continue;
                    }
                    std::vector<DPInstance*> window(cluster_instances.begin() + start,
                                                    cluster_instances.begin() + start + window_size);
                    if (std::any_of(window.begin(), window.end(), [](const DPInstance* inst) {
                          return inst == nullptr || inst->get_state() != DPINSTANCE_STATE::kPlaced;
                        })) {
                        continue;
                    }
                    ++_last_result.window_count;

                    std::vector<Point<int32_t>> original_coordinates;
                    original_coordinates.reserve(window.size());
                    for (auto* inst : window) {
                        original_coordinates.push_back(inst->get_coordi());
                    }
                    const int32_t window_start_x = original_coordinates.front().get_x();
                    const int32_t window_y = original_coordinates.front().get_y();
                    const int64_t origin_hpwl = _operator->calTotalHPWL();
                    std::vector<size_t> order(window.size());
                    std::iota(order.begin(), order.end(), 0);
                    std::vector<size_t> best_order = order;
                    int64_t best_hpwl = origin_hpwl;
                    do {
                        if (_last_result.search_budget >= 0
                            && _last_result.search_count >= _last_result.search_budget) {
                            _last_result.budget_exhausted = true;
                            break;
                        }
                        restoreWindow(window, original_coordinates);
                        ++_last_result.search_count;
                        ++_last_result.candidate_count;
                        int32_t cursor_x = window_start_x;
                        for (size_t offset = 0; offset < window.size(); ++offset) {
                            auto* inst = window[order[offset]];
                            inst->updateCoordi(cursor_x, window_y);
                            cursor_x += inst->get_shape().get_width();
                        }
                        const int64_t candidate_hpwl = _operator->calTotalHPWL();
                        if (candidate_hpwl < best_hpwl) {
                            best_hpwl = candidate_hpwl;
                            best_order = order;
                        }
                        restoreWindow(window, original_coordinates);
                    } while (std::next_permutation(order.begin(), order.end()));

                    restoreWindow(window, original_coordinates);
                    if (best_hpwl < origin_hpwl) {
                        std::vector<DPInstance*> reordered;
                        reordered.reserve(window.size());
                        for (const auto index : best_order) {
                            reordered.push_back(window[index]);
                        }
                        int32_t cursor_x = window_start_x;
                        for (size_t offset = 0; offset < reordered.size(); ++offset) {
                            reordered[offset]->updateCoordi(cursor_x, window_y);
                            cursor_x += reordered[offset]->get_shape().get_width();
                            cur_cluster->replaceInstance(reordered[offset], static_cast<int32_t>(start + offset));
                        }
                        updateClusterIds(cur_cluster);
                        ++_last_result.accepted_count;
                    }
                    if (_last_result.budget_exhausted) {
                        break;
                    }
                }
                cur_cluster = cur_cluster->get_back_cluster();
                if (_last_result.budget_exhausted) {
                    break;
                }
            }
        }
        if (_last_result.budget_exhausted) {
            break;
        }
    }

    for (const auto& before : before_coordinates) {
        if (before.first->get_coordi().get_x() != before.second.get_x()
            || before.first->get_coordi().get_y() != before.second.get_y()) {
            ++_last_result.changed_count;
        }
    }
    _last_result.hpwl_after = _operator->calTotalHPWL();
    _last_result.completed = true;
    _last_result.legal = checkOutputLegal();
    if (!_last_result.legal) {
        _last_result.outcome = LocalReorderOutcome::kIllegalOutput;
        _last_result.reason = "local reorder produced an out-of-interval instance";
    } else if (_last_result.accepted_count == 0) {
        _last_result.outcome = LocalReorderOutcome::kNoOp;
        _last_result.reason = "local reorder found no improving adjacent pair";
    } else {
        _last_result.outcome = LocalReorderOutcome::kCompleted;
        _last_result.reason = "local reorder completed";
    }
    return _last_result;
}

void LocalReorder::restoreWindow(const std::vector<DPInstance*>& instances,
                                 const std::vector<Point<int32_t>>& coordinates) const
{
    for (size_t index = 0; index < instances.size() && index < coordinates.size(); ++index) {
        if (instances[index] != nullptr) {
            instances[index]->updateCoordi(coordinates[index].get_x(), coordinates[index].get_y());
        }
    }
}

void LocalReorder::updateClusterIds(DPCluster* cluster) const
{
    if (cluster == nullptr) {
        return;
    }
    const auto& instances = cluster->get_inst_list();
    for (size_t index = 0; index < instances.size(); ++index) {
        if (instances[index] != nullptr) {
            instances[index]->set_internal_id(static_cast<int32_t>(index));
        }
    }
}

bool LocalReorder::checkOutputLegal() const
{
    auto* layout = _database->get_layout();
    const auto& intervals = layout->get_interval_2d_list();
    const int32_t row_height = layout->get_row_height();
    const int32_t site_width = layout->get_site_width();
    for (auto* inst : _database->get_design()->get_inst_list()) {
        if (inst == nullptr || inst->get_state() == DPINSTANCE_STATE::kFixed
            || inst->get_state() == DPINSTANCE_STATE::kUnPlaced) {
            continue;
        }
        const auto shape = inst->get_shape();
        const int32_t row_index = shape.get_ll_y() / row_height;
        if (row_index < 0 || row_index >= static_cast<int32_t>(intervals.size())) {
            return false;
        }
        bool in_interval = false;
        for (auto* interval : intervals.at(row_index)) {
            if (interval != nullptr && interval->checkInLine(shape.get_ll_x(), shape.get_ur_x())) {
                in_interval = true;
                break;
            }
        }
        if (!in_interval || (site_width > 0 && shape.get_ll_x() % site_width != 0)) {
            return false;
        }
    }
    return true;
}


}
