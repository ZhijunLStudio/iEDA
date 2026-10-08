#include "FloorplanGeometry.hh"

#include <cstdlib>
#include <iostream>
#include <limits>

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

  ok &= require(ifp::isValidCoordinateBox(0.0, 0.0, 2000.0, 1000.0), "a finite, ordered die box must be accepted");
  ok &= require(!ifp::isValidCoordinateBox(2000.0, 0.0, 0.0, 1000.0), "reversed die x coordinates must be rejected");
  ok &= require(!ifp::isValidCoordinateBox(0.0, 1000.0, 2000.0, 1000.0), "zero-height boxes must be rejected");
  ok &= require(ifp::isValidCoordinateBox(-1.0, -2.0, 2000.0, 1000.0), "an ordered box with a negative origin must be accepted");
  ok &= require(!ifp::isValidCoordinateBox(0.0, 0.0, std::numeric_limits<double>::infinity(), 1000.0),
                "non-finite die coordinates must be rejected");

  {
    const ifp::FloorplanBox die{.low_x = 0, .low_y = 0, .high_x = 2000, .high_y = 1000};
    const ifp::FloorplanBox core{.low_x = 100, .low_y = 100, .high_x = 1900, .high_y = 900};
    const ifp::FloorplanBox outside{.low_x = 100, .low_y = 100, .high_x = 2100, .high_y = 900};
    ok &= require(ifp::containsBox(die, core), "a core inside the die must be accepted");
    ok &= require(!ifp::containsBox(die, outside), "a core outside the die must be rejected");
  }

  {
    const auto pitch = ifp::makePinPitch(1800, 800, 4, 10);
    ok &= require(pitch.has_value(), "a non-square core must produce valid pin pitches");
    ok &= require(pitch && pitch->horizontal == 360, "bottom/top pins must use the core-width pitch");
    ok &= require(pitch && pitch->vertical == 160, "left/right pins must use the core-height pitch");
    ok &= require(!ifp::makePinPitch(1800, 800, 4, 0).has_value(), "a zero manufacturing grid must fail");
    ok &= require(!ifp::makePinPitch(20, 20, 100, 10).has_value(), "a pitch that snaps to zero must fail");
  }

  {
    const ifp::FloorplanBox row{.low_x = 0, .low_y = 0, .high_x = 1000, .high_y = 10};
    const ifp::FloorplanBox left_overhang{.low_x = -100, .low_y = 0, .high_x = 50, .high_y = 10};
    const ifp::FloorplanBox disjoint_left{.low_x = -100, .low_y = 0, .high_x = -1, .high_y = 10};
    const ifp::FloorplanBox disjoint_right{.low_x = 1001, .low_y = 0, .high_x = 1100, .high_y = 10};
    const ifp::FloorplanBox disjoint_above{.low_x = 0, .low_y = 11, .high_x = 50, .high_y = 20};
    ok &= require(ifp::intersectsClosed(row, left_overhang), "a blockage overhanging the row's left edge must intersect");
    ok &= require(!ifp::intersectsClosed(row, disjoint_left), "a blockage strictly left of the row must not intersect");
    ok &= require(!ifp::intersectsClosed(row, disjoint_right), "a blockage strictly right of the row must not intersect");
    ok &= require(!ifp::intersectsClosed(row, disjoint_above), "a blockage above the row must not intersect");
  }

  return ok ? EXIT_SUCCESS : EXIT_FAILURE;
}
