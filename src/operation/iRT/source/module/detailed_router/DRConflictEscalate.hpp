// ***************************************************************************************
// Copyright (c) 2023-2025 Peng Cheng Laboratory
// Copyright (c) 2023-2025 Institute of Computing Technology, Chinese Academy of Sciences
// Copyright (c) 2023-2025 Beijing Institute of Open Source Chip
//
// iEDA is licensed under Mulan PSL v2.
// ***************************************************************************************
#pragma once

#include <algorithm>
#include <cstdint>
#include <numeric>
#include <set>
#include <tuple>
#include <utility>
#include <vector>

#include "ViolationType.hpp"

namespace irt {

/**
 * WP-RT-01b: conflict connected-component escalate helpers.
 *
 * Two violations are adjacent if they share a net OR their expanded bboxes overlap
 * (caller supplies overlap predicate). Components are built with union-find.
 * Default-off at call sites → zero regression.
 */
struct DRConflictViolationRef
{
  int32_t index = 0;
  ViolationType type = ViolationType::kNone;
  int32_t layer_idx = -1;
  int32_t ll_x = 0;
  int32_t ll_y = 0;
  int32_t ur_x = 0;
  int32_t ur_y = 0;
  int32_t severity = 1;
  std::vector<int32_t> net_ids;
};

struct DRConflictComponent
{
  std::vector<int32_t> violation_indices;
  std::set<int32_t> net_ids;
  int64_t severity_sum = 0;
  int32_t ll_x = 0;
  int32_t ll_y = 0;
  int32_t ur_x = 0;
  int32_t ur_y = 0;
};

inline auto boxesOverlap(int32_t a_ll_x, int32_t a_ll_y, int32_t a_ur_x, int32_t a_ur_y, int32_t b_ll_x, int32_t b_ll_y, int32_t b_ur_x,
                         int32_t b_ur_y) -> bool
{
  return a_ll_x <= b_ur_x && b_ll_x <= a_ur_x && a_ll_y <= b_ur_y && b_ll_y <= a_ur_y;
}

inline auto expandBox(int32_t ll_x, int32_t ll_y, int32_t ur_x, int32_t ur_y, int32_t halo)
    -> std::tuple<int32_t, int32_t, int32_t, int32_t>
{
  return {ll_x - halo, ll_y - halo, ur_x + halo, ur_y + halo};
}

inline auto shareNet(const DRConflictViolationRef& a, const DRConflictViolationRef& b) -> bool
{
  if (a.net_ids.empty() || b.net_ids.empty()) {
    return false;
  }
  std::set<int32_t> a_set(a.net_ids.begin(), a.net_ids.end());
  for (int32_t net : b.net_ids) {
    if (a_set.count(net) != 0) {
      return true;
    }
  }
  return false;
}

class UnionFind
{
 public:
  explicit UnionFind(int32_t n) : _parent(n), _rank(n, 0)
  {
    std::iota(_parent.begin(), _parent.end(), 0);
  }

  auto find(int32_t x) -> int32_t
  {
    while (_parent[x] != x) {
      _parent[x] = _parent[_parent[x]];
      x = _parent[x];
    }
    return x;
  }

  void unite(int32_t a, int32_t b)
  {
    a = find(a);
    b = find(b);
    if (a == b) {
      return;
    }
    if (_rank[a] < _rank[b]) {
      std::swap(a, b);
    }
    _parent[b] = a;
    if (_rank[a] == _rank[b]) {
      _rank[a]++;
    }
  }

 private:
  std::vector<int32_t> _parent;
  std::vector<int32_t> _rank;
};

inline auto buildConflictComponents(const std::vector<DRConflictViolationRef>& violations, int32_t halo) -> std::vector<DRConflictComponent>
{
  const int32_t n = static_cast<int32_t>(violations.size());
  if (n == 0) {
    return {};
  }
  UnionFind uf(n);
  for (int32_t i = 0; i < n; ++i) {
    const auto [ai_ll_x, ai_ll_y, ai_ur_x, ai_ur_y]
        = expandBox(violations[i].ll_x, violations[i].ll_y, violations[i].ur_x, violations[i].ur_y, halo);
    for (int32_t j = i + 1; j < n; ++j) {
      if (shareNet(violations[i], violations[j])) {
        uf.unite(i, j);
        continue;
      }
      if (violations[i].layer_idx != violations[j].layer_idx) {
        continue;
      }
      const auto [bj_ll_x, bj_ll_y, bj_ur_x, bj_ur_y]
          = expandBox(violations[j].ll_x, violations[j].ll_y, violations[j].ur_x, violations[j].ur_y, halo);
      if (boxesOverlap(ai_ll_x, ai_ll_y, ai_ur_x, ai_ur_y, bj_ll_x, bj_ll_y, bj_ur_x, bj_ur_y)) {
        uf.unite(i, j);
      }
    }
  }

  std::vector<DRConflictComponent> components;
  std::vector<int32_t> root_to_comp(n, -1);
  for (int32_t i = 0; i < n; ++i) {
    const int32_t root = uf.find(i);
    if (root_to_comp[root] < 0) {
      root_to_comp[root] = static_cast<int32_t>(components.size());
      DRConflictComponent comp;
      comp.ll_x = violations[i].ll_x;
      comp.ll_y = violations[i].ll_y;
      comp.ur_x = violations[i].ur_x;
      comp.ur_y = violations[i].ur_y;
      components.push_back(std::move(comp));
    }
    DRConflictComponent& comp = components[root_to_comp[root]];
    comp.violation_indices.push_back(i);
    comp.severity_sum += std::max(1, violations[i].severity);
    for (int32_t net : violations[i].net_ids) {
      if (net >= 0) {
        comp.net_ids.insert(net);
      }
    }
    comp.ll_x = std::min(comp.ll_x, violations[i].ll_x);
    comp.ll_y = std::min(comp.ll_y, violations[i].ll_y);
    comp.ur_x = std::max(comp.ur_x, violations[i].ur_x);
    comp.ur_y = std::max(comp.ur_y, violations[i].ur_y);
  }
  return components;
}

inline auto selectHighestSeverityComponent(const std::vector<DRConflictComponent>& components) -> int32_t
{
  if (components.empty()) {
    return -1;
  }
  int32_t best = 0;
  for (int32_t i = 1; i < static_cast<int32_t>(components.size()); ++i) {
    if (components[i].severity_sum > components[best].severity_sum) {
      best = i;
    } else if (components[i].severity_sum == components[best].severity_sum
               && components[i].net_ids.size() > components[best].net_ids.size()) {
      best = i;
    }
  }
  return best;
}

/** Priority for rip-up scheduling: short > PRL > min-area > other. Higher = earlier. */
inline auto prlShortRepairPriority(ViolationType type) -> int32_t
{
  switch (type) {
    case ViolationType::kMetalShort:
      return 400;
    case ViolationType::kParallelRunLengthSpacing:
      return 300;
    case ViolationType::kMinimumArea:
      return 200;
    default:
      return 100;
  }
}

inline auto componentWeightBoost(int32_t base_weight, int32_t escalate_level, int32_t max_boost = 4) -> int32_t
{
  if (escalate_level <= 0) {
    return std::max(1, base_weight);
  }
  const int32_t boost = std::min(max_boost, escalate_level);
  return std::max(1, base_weight) * (1 + boost);
}

}  // namespace irt
