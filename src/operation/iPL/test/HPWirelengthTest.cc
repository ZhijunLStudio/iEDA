#include "HPWirelength.hh"

#include <climits>
#include <cstdlib>
#include <iostream>

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << "[FAIL] " << message << '\n';
  } else {
    std::cout << "[PASS] " << message << '\n';
  }
  return condition;
}

auto addNode(ipl::TopologyManager& topology, const char* name, int32_t x, int32_t y) -> ipl::Node*
{
  auto* node = new ipl::Node(name);
  node->set_location(ipl::Point<int32_t>(x, y));
  topology.add_node(node);
  return node;
}

auto addNetwork(ipl::TopologyManager& topology, const char* name, ipl::Node* transmitter,
                std::initializer_list<ipl::Node*> receivers, float weight = 1.0F) -> ipl::NetWork*
{
  auto* network = new ipl::NetWork(name);
  network->set_transmitter(transmitter);
  network->set_net_weight(weight);
  for (auto* receiver : receivers) {
    network->add_receiver(receiver);
  }
  topology.add_network(network);
  return network;
}

}  // namespace

int main()
{
  bool ok = true;
  ipl::TopologyManager topology;
  ipl::HPWirelength empty_hpwl(&topology);
  ok &= require(empty_hpwl.obtainTotalWirelength() == 0, "empty topology HPWL must be zero");

  auto* tx = addNode(topology, "tx", 0, 0);
  auto* sink0 = addNode(topology, "sink0", 10, 20);
  auto* sink1 = addNode(topology, "sink1", -5, 5);
  auto* normal = addNetwork(topology, "normal", tx, {sink0, sink1});

  auto* single = addNode(topology, "single", 7, 9);
  auto* single_net = addNetwork(topology, "single_net", single, {});

  auto* ignored_tx = addNode(topology, "ignored_tx", INT32_MIN, INT32_MIN);
  auto* ignored_sink = addNode(topology, "ignored_sink", INT32_MAX, INT32_MAX);
  auto* ignored = addNetwork(topology, "ignored", ignored_tx, {ignored_sink}, 0.0F);

  auto* large_tx = addNode(topology, "large_tx", INT32_MIN, 0);
  auto* large_sink = addNode(topology, "large_sink", INT32_MAX, 0);
  auto* large = addNetwork(topology, "large", large_tx, {large_sink});

  ipl::HPWirelength hpwl(&topology);
  ok &= require(hpwl.obtainNetWirelength(normal->get_network_id()) == 35, "rectangular net HPWL must match hand calculation");
  ok &= require(hpwl.obtainPartOfNetWirelength(normal->get_network_id(), sink0->get_node_id()) == 30,
                "driver-to-sink Manhattan length must match hand calculation");
  ok &= require(hpwl.obtainNetWirelength(single_net->get_network_id()) == 0, "single-pin net HPWL must be zero");
  ok &= require(hpwl.obtainNetWirelength(ignored->get_network_id()) == 0, "ignored net must not contribute HPWL");
  ok &= require(hpwl.obtainNetWirelength(large->get_network_id()) == 4294967295LL,
                "HPWL must use 64-bit deltas at INT32 coordinate limits");
  ok &= require(hpwl.obtainTotalWirelength() == 4294967330LL,
                "total HPWL must use the same filtering and 64-bit policy as per-net HPWL");
  ok &= require(hpwl.obtainPartOfNetWirelength(normal->get_network_id(), INT32_MAX) == 0,
                "unknown sink must return zero without dereferencing invalid nodes");
  ok &= require(ipl::HPWirelength(nullptr).obtainTotalWirelength() == 0, "null topology must return zero");

  const auto point_sets = hpwl.constructPointSets();
  ok &= require(point_sets.size() == 3, "point-set export must exclude ignored nets and preserve active nets");
  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
