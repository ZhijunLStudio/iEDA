#include "DRNode.hpp"

#include <cstdlib>
#include <iostream>
#include <map>

namespace {

auto require(bool condition, const char* message) -> bool
{
  if (!condition) {
    std::cerr << message << '\n';
  }
  return condition;
}

}  // namespace

int main()
{
  bool ok = true;

  irt::DRNode node;
  ok &= require(node.getViolationCost(irt::Orientation::kEast, 7.0) == 0.0, "empty history must have zero cost");
  ok &= require(!node.hasOrientViolationNumber(), "empty history must report no violations");

  node.addViolationNumber(irt::Orientation::kEast);
  node.addViolationNumber(irt::Orientation::kEast, 4);
  node.addViolationNumber(irt::Orientation::kNone, 100);
  node.addViolationNumber(irt::Orientation::kWest, 0);

  ok &= require(node.getViolationNumber(irt::Orientation::kEast) == 5, "east history count must accumulate");
  ok &= require(node.getViolationNumber(irt::Orientation::kNone) == 0, "invalid orientation must be ignored");
  ok &= require(node.hasOrientViolationNumber(), "node must report non-empty violation history");
  ok &= require(node.getViolationCost(irt::Orientation::kEast, 7.0) == 7.0, "legacy path must stay binary");
  ok &= require(node.getViolationCost(irt::Orientation::kEast, 7.0, true, 8) == 35.0, "enabled path scales by count");
  ok &= require(node.getViolationCost(irt::Orientation::kEast, 7.0, true, 3) == 21.0, "enabled path caps history scale");

  std::map<irt::Orientation, int32_t> replacement{{irt::Orientation::kNorth, 9}, {irt::Orientation::kOblique, 11}};
  node.set_orient_violation_number_map(replacement);
  ok &= require(node.getViolationNumber(irt::Orientation::kEast) == 0, "replacement must clear old orientations");
  ok &= require(node.getViolationNumber(irt::Orientation::kNorth) == 9, "replacement must load valid orientations");
  ok &= require(node.getViolationCost(irt::Orientation::kNorth, 2.0, true, 4) == 8.0, "replacement cost must cap");

  int32_t visited_count = 0;
  node.forEachViolationNumber([&visited_count](irt::Orientation orientation, int32_t violation_number) {
    if (orientation == irt::Orientation::kNorth && violation_number == 9) {
      ++visited_count;
    }
  });
  ok &= require(visited_count == 1, "forEachViolationNumber must visit active valid orientations once");

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
