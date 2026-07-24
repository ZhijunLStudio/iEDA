add_executable(ifp_floorplan_geometry_test FloorplanGeometryTest.cc)
target_include_directories(
  ifp_floorplan_geometry_test
  PRIVATE
    ${HOME_OPERATION}/iFP/source/utility
)
add_test(NAME ifp_floorplan_geometry_test COMMAND ifp_floorplan_geometry_test)
