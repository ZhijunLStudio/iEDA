#include "WAWirelengthGradient.hh"

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <vector>

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

auto fastExp(float value) -> float
{
  value = 1.0F + value / 1024.0F;
  for (int32_t index = 0; index < 10; ++index) {
    value *= value;
  }
  return value;
}

auto weightedAverageSpan(const std::vector<int32_t>& coordinates, float coefficient) -> float
{
  const auto [minimum, maximum] = std::minmax_element(coordinates.begin(), coordinates.end());
  float minimum_weight_sum = 0.0F;
  float minimum_coordinate_sum = 0.0F;
  float maximum_weight_sum = 0.0F;
  float maximum_coordinate_sum = 0.0F;
  for (const int32_t coordinate : coordinates) {
    const float minimum_weight = fastExp((*minimum - coordinate) * coefficient);
    const float maximum_weight = fastExp((coordinate - *maximum) * coefficient);
    minimum_weight_sum += minimum_weight;
    minimum_coordinate_sum += coordinate * minimum_weight;
    maximum_weight_sum += maximum_weight;
    maximum_coordinate_sum += coordinate * maximum_weight;
  }
  return maximum_coordinate_sum / maximum_weight_sum - minimum_coordinate_sum / minimum_weight_sum;
}

struct Fixture
{
  ipl::TopologyManager topology;
  ipl::Node* nodes[3]{};
  ipl::Group* groups[3]{};
  ipl::NetWork* network = nullptr;

  Fixture()
  {
    const int32_t x[3] = {0, 30, 100};
    const int32_t y[3] = {10, 80, 20};
    for (int32_t index = 0; index < 3; ++index) {
      nodes[index] = new ipl::Node("pin" + std::to_string(index));
      nodes[index]->set_location({x[index], y[index]});
      topology.add_node(nodes[index]);

      groups[index] = new ipl::Group("inst" + std::to_string(index));
      groups[index]->add_node(nodes[index]);
      nodes[index]->set_group(groups[index]);
      topology.add_group(groups[index]);
    }

    network = new ipl::NetWork("net");
    network->set_transmitter(nodes[0]);
    network->add_receiver(nodes[1]);
    network->add_receiver(nodes[2]);
    topology.add_network(network);
    for (auto* node : nodes) {
      node->set_network(network);
    }
  }
};

auto objective(const Fixture& fixture, float coefficient) -> float
{
  std::vector<int32_t> x;
  std::vector<int32_t> y;
  for (const auto* node : fixture.nodes) {
    x.push_back(node->get_location().get_x());
    y.push_back(node->get_location().get_y());
  }
  return weightedAverageSpan(x, coefficient) + weightedAverageSpan(y, coefficient);
}

}  // namespace

int main()
{
  bool ok = true;
  constexpr float coefficient = 0.01F;
  Fixture fixture;
  ipl::WAWirelengthGradient evaluator(&fixture.topology);
  evaluator.updateWirelengthForce(coefficient, coefficient, -300.0F, 1);

  float sum_gradient_x = 0.0F;
  float sum_gradient_y = 0.0F;
  for (int32_t index = 0; index < 3; ++index) {
    const auto gradient = evaluator.obtainWirelengthGradient(index, coefficient, coefficient);
    ok &= require(std::isfinite(gradient.get_x()) && std::isfinite(gradient.get_y()),
                  "WA wirelength gradients must remain finite");
    sum_gradient_x += gradient.get_x();
    sum_gradient_y += gradient.get_y();
  }
  ok &= require(std::fabs(sum_gradient_x) < 1.0e-4F && std::fabs(sum_gradient_y) < 1.0e-4F,
                "WA wirelength gradients must conserve translation");

  const auto original = fixture.nodes[1]->get_location();
  fixture.nodes[1]->set_location({original.get_x() + 1, original.get_y()});
  const float plus_x = objective(fixture, coefficient);
  fixture.nodes[1]->set_location({original.get_x() - 1, original.get_y()});
  const float minus_x = objective(fixture, coefficient);
  fixture.nodes[1]->set_location(original);
  const float finite_difference_x = (plus_x - minus_x) * 0.5F;
  const float analytic_x = evaluator.obtainWirelengthGradient(1, coefficient, coefficient).get_x();
  ok &= require(std::fabs(finite_difference_x + analytic_x) < 2.0e-3F,
                "WA x descent force must match the negative finite-difference oracle");

  ipl::GridManager grid({0, 0, 200, 200}, 2, 2, 1.0F, 1);
  evaluator.updateWirelengthForceDirect(coefficient, coefficient, -300.0F, 1, &grid);
  for (int32_t index = 0; index < 3; ++index) {
    const auto gradient = evaluator.obtainWirelengthGradient(index, coefficient, coefficient);
    ok &= require(std::isfinite(gradient.get_x()) && std::isfinite(gradient.get_y()),
                  "zero route utilization must not produce NaN direct gradients");
  }

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
