cmake_minimum_required(VERSION 3.11)

set(CMAKE_CXX_STANDARD 20)

SET(CMAKE_BUILD_TYPE "Debug")

find_package(GTest REQUIRED)

add_executable(ipa_activity_provenance_test ActivityProvenanceTest.cc)
target_link_libraries(ipa_activity_provenance_test PRIVATE GTest::gtest_main)
target_include_directories(
  ipa_activity_provenance_test PRIVATE ${PROJECT_SOURCE_DIR}/src/operation/iPA)
add_test(NAME ipa_activity_provenance_test
         COMMAND ipa_activity_provenance_test)

add_executable(ipa_activity_report_test PowerActivityReportTest.cc)
target_link_libraries(
  ipa_activity_report_test
  PRIVATE
  GTest::gtest_main
  vcd_wrapper
  log
  power
  usage
  ista-engine
  core
  calc_power
  plot_power)
target_include_directories(
  ipa_activity_report_test PRIVATE ${PROJECT_SOURCE_DIR}/src/operation/iPA)
add_test(NAME ipa_activity_report_test COMMAND ipa_activity_report_test)

aux_source_directory(./ SRC)
list(FILTER SRC EXCLUDE REGEX
     "(ActivityProvenanceTest|PowerActivityReportTest)\\.cc$")

add_executable(iPowerTest ${SRC})

target_link_libraries(
  iPowerTest
  PUBLIC
  gtest
  gtest_main
  boost_system
  PRIVATE
  vcd_wrapper
  log
  power
  usage ista-engine core calc_power plot_power

)
