add_executable(irt_dr_convergence_test DRConvergenceTest.cpp)
target_include_directories(irt_dr_convergence_test PRIVATE ${IRT_SOURCE}/module/detailed_router)

add_executable(irt_logger_failure_test LoggerFailureTest.cpp ${IRT_SOURCE}/toolkit/logger/Logger.cpp)
target_include_directories(
  irt_logger_failure_test
  PRIVATE
    ${IRT_SOURCE}/toolkit/logger
    ${IRT_SOURCE}/data_manager/advance
    ${PROJECT_SOURCE_DIR}/src/utility/stdBase
    ${PROJECT_SOURCE_DIR}/src/utility/stdBase/include
    ${PROJECT_SOURCE_DIR}/src/third_party
)

add_test(NAME irt_dr_convergence_test COMMAND irt_dr_convergence_test)
add_test(NAME irt_logger_failure_test COMMAND irt_logger_failure_test)
