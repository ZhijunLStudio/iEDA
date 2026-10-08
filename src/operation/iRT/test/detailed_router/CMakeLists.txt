enable_testing()

add_executable(irt_dr_convergence_test DRConvergenceTest.cpp)
target_include_directories(irt_dr_convergence_test PRIVATE ${IRT_SOURCE}/module/detailed_router)

add_executable(irt_dr_rule_aware_cost_test DRRuleAwareCostTest.cpp)
target_include_directories(irt_dr_rule_aware_cost_test PRIVATE
  ${IRT_SOURCE}/module/detailed_router
  ${IRT_SOURCE}/data_manager/advance
  ${IRT_SOURCE}/toolkit/logger
)

add_executable(irt_dr_node_cost_test DRNodeCostTest.cpp)
target_include_directories(irt_dr_node_cost_test PRIVATE
  ${IRT_SOURCE}/module/detailed_router
  ${IRT_SOURCE}/module/detailed_router/dr_data_manager
  ${IRT_SOURCE}/data_manager/advance
  ${IRT_SOURCE}/data_manager/basic
  ${IRT_SOURCE}/toolkit/logger
  ${IRT_SOURCE}/toolkit/utility
)

add_executable(irt_dr_conflict_escalate_test DRConflictEscalateTest.cpp)
target_include_directories(irt_dr_conflict_escalate_test PRIVATE
  ${IRT_SOURCE}/module/detailed_router
  ${IRT_SOURCE}/data_manager/advance
  ${IRT_SOURCE}/toolkit/logger
)

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
add_test(NAME irt_dr_rule_aware_cost_test COMMAND irt_dr_rule_aware_cost_test)
add_test(NAME irt_dr_node_cost_test COMMAND irt_dr_node_cost_test)
add_test(NAME irt_dr_conflict_escalate_test COMMAND irt_dr_conflict_escalate_test)
add_test(NAME irt_logger_failure_test COMMAND irt_logger_failure_test)
