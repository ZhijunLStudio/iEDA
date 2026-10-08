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
/**
 * @file BoundSkewTreeTest.cc
 * @brief Targeted BST coverage for symmetry, guide projection, fanout, and unsupported topology failure.
 */

#include <gtest/gtest.h>

#include <cerrno>
#include <sys/wait.h>
#include <unistd.h>

#include <algorithm>
#include <limits>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include <vector>

#include "Point.hh"
#include "database/routing/SteinerTree.hh"
#include "routing/bound_skew_tree/BSTRouter.hh"
#include "routing/bound_skew_tree/config/BSTRoutingConfig.hh"

namespace icts_test {
namespace {

auto MakeTerminal(const std::string& name, int x, int y, double pin_cap = 0.2, double insertion_delay = 0.1) -> icts::ClockRoutingTerminal
{
  icts::ClockRoutingTerminal terminal;
  terminal.name = name;
  terminal.location = icts::Point<int>(x, y);
  terminal.pin_cap = pin_cap;
  terminal.insertion_delay = insertion_delay;
  return terminal;
}

auto MakeRoutingConfig(icts::BSTRoutingTopologyMode topology_mode, std::optional<icts::Point<int>> root_guide = std::nullopt)
    -> icts::BSTRoutingConfig
{
  icts::BSTRoutingConfig config;
  config.skew_bound = 0.20;
  config.dbu_per_um = 1000;
  config.unit_h_cap = 0.0004;
  config.unit_h_res = 0.002;
  config.unit_v_cap = 0.0004;
  config.unit_v_res = 0.002;
  config.topology_mode = topology_mode;
  config.root_guide = std::move(root_guide);
  return config;
}

auto MakeLineTerminals(std::size_t count, int pitch = 2000) -> std::vector<icts::ClockRoutingTerminal>
{
  std::vector<icts::ClockRoutingTerminal> terminals;
  terminals.reserve(count);
  for (std::size_t index = 0U; index < count; ++index) {
    terminals.push_back(MakeTerminal("load" + std::to_string(index), static_cast<int>(index * pitch), 0));
  }
  return terminals;
}

auto MakeGridTerminals(std::size_t rows, std::size_t cols, int pitch = 1000) -> std::vector<icts::ClockRoutingTerminal>
{
  std::vector<icts::ClockRoutingTerminal> terminals;
  terminals.reserve(rows * cols);
  std::size_t index = 0U;
  for (std::size_t row = 0U; row < rows; ++row) {
    for (std::size_t col = 0U; col < cols; ++col) {
      terminals.push_back(
          MakeTerminal("grid_" + std::to_string(index++), static_cast<int>(col * pitch), static_cast<int>(row * pitch)));
    }
  }
  return terminals;
}

auto MakeUnsupportedSourceRouteTree() -> icts::BSTRouter::ClockSteinerTreeType
{
  icts::BSTRouter::ClockSteinerTreeType tree;
  const auto root_id = tree.addNode("root", icts::Point<int>(0, 0), false);
  tree.setRoot(root_id);
  for (int index = 0; index < 5; ++index) {
    const auto child_id = tree.addNode("sink" + std::to_string(index), icts::Point<int>(index * 1000, 1000), true, 0.1, 0.1);
    (void) tree.addEdge(root_id, child_id, 1000, 1000);
  }
  return tree;
}

void TriggerUnsupportedSourceRouteFanout()
{
  const auto tree = MakeUnsupportedSourceRouteTree();
  (void) icts::BSTRouter::buildTreeFromTopology(tree, MakeRoutingConfig(icts::BSTRoutingTopologyMode::kSourceRouteTree));
}

void TriggerDuplicateTerminalName()
{
  const auto terminals = std::vector<icts::ClockRoutingTerminal>{
      MakeTerminal("sink0", 0, 0),
      MakeTerminal("sink0", 2000, 0),
  };
  (void) icts::BSTRouter::buildTree(terminals, MakeRoutingConfig(icts::BSTRoutingTopologyMode::kGreedyDistance));
}

void TriggerInvalidTerminalMetric()
{
  const auto terminals = std::vector<icts::ClockRoutingTerminal>{
      MakeTerminal("sink0", 0, 0, std::numeric_limits<double>::quiet_NaN(), 0.1),
  };
  (void) icts::BSTRouter::buildTree(terminals, MakeRoutingConfig(icts::BSTRoutingTopologyMode::kGreedyDistance));
}

bool ChildProcessFails(void (*trigger)())
{
  const pid_t child = fork();
  if (child == 0) {
    trigger();
    _exit(0);
  }
  if (child < 0) {
    return false;
  }

  int status = 0;
  while (waitpid(child, &status, 0) == -1) {
    if (errno != EINTR) {
      return false;
    }
  }
  return (WIFEXITED(status) && WEXITSTATUS(status) != 0) || WIFSIGNALED(status);
}

TEST(BoundSkewTreeTest, SymmetricSinksProduceBalancedRoot)
{
  const auto terminals = std::vector<icts::ClockRoutingTerminal>{
      MakeTerminal("sink0", 0, 0),
      MakeTerminal("sink1", 2000, 0),
  };
  const auto tree = icts::BSTRouter::buildTree(terminals, MakeRoutingConfig(icts::BSTRoutingTopologyMode::kGreedyDistance));

  ASSERT_TRUE(tree.validate());
  ASSERT_EQ(tree.node_count(), 3U);

  const auto* root = tree.get_node(tree.get_root());
  ASSERT_NE(root, nullptr);
  EXPECT_EQ(root->location.get_x(), 1000);
  EXPECT_EQ(root->location.get_y(), 0);

  const auto* sink0 = tree.findNode("sink0");
  const auto* sink1 = tree.findNode("sink1");
  ASSERT_NE(sink0, nullptr);
  ASSERT_NE(sink1, nullptr);
  EXPECT_TRUE(sink0->is_terminal);
  EXPECT_TRUE(sink1->is_terminal);
  EXPECT_DOUBLE_EQ(sink0->pin_cap, 0.2);
  EXPECT_DOUBLE_EQ(sink1->pin_cap, 0.2);
}

TEST(BoundSkewTreeTest, RootGuideProjectsIntoFeasibleRegion)
{
  const auto tree = icts::BSTRouter::buildTree(
      MakeLineTerminals(2), MakeRoutingConfig(icts::BSTRoutingTopologyMode::kGreedyDistance, icts::Point<int>(5000, 5000)));

  ASSERT_TRUE(tree.validate());
  const auto* root = tree.get_node(tree.get_root());
  ASSERT_NE(root, nullptr);
  EXPECT_GE(root->location.get_x(), 0);
  EXPECT_LE(root->location.get_x(), 2000);
  EXPECT_GE(root->location.get_y(), 0);
  EXPECT_LE(root->location.get_y(), 0);
  EXPECT_NE(root->location.get_x(), 5000);
  EXPECT_NE(root->location.get_y(), 5000);
}

TEST(BoundSkewTreeTest, ExtremeFanoutRemainsValidAndBinary)
{
  const auto terminals = MakeGridTerminals(4, 8);
  const auto tree = icts::BSTRouter::buildTree(terminals, MakeRoutingConfig(icts::BSTRoutingTopologyMode::kGreedyDistance));

  ASSERT_TRUE(tree.validate());
  EXPECT_EQ(tree.node_count(), terminals.size() * 2U - 1U);
  EXPECT_EQ(tree.edge_count(), tree.node_count() - 1U);

  const auto terminal_count = std::count_if(tree.get_nodes().begin(), tree.get_nodes().end(), [](const auto& node) {
    return node.is_terminal;
  });
  EXPECT_EQ(terminal_count, terminals.size());
}

TEST(BoundSkewTreeTest, UnsupportedSourceRouteFanoutFailsLoudly)
{
  EXPECT_TRUE(ChildProcessFails(&TriggerUnsupportedSourceRouteFanout));
}

TEST(BoundSkewTreeTest, DuplicateTerminalNameFailsLoudly)
{
  EXPECT_TRUE(ChildProcessFails(&TriggerDuplicateTerminalName));
}

TEST(BoundSkewTreeTest, InvalidTerminalMetricFailsLoudly)
{
  EXPECT_TRUE(ChildProcessFails(&TriggerInvalidTerminalMetric));
}

}  // namespace
}  // namespace icts_test
