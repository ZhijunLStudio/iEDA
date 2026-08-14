# # aux_source_directory(. SourceFiles)
# # add_executable(iPLTest ${iPL_SOURCE}/PlacerDB.cc ${SourceFiles})
# # set(CMAKE_BUILD_TYPE "Debug")

# set(SANITIZER OFF)
# if(SANITIZER)
#     ADD_COMPILE_OPTIONS("-fsanitize=address")
#     LINK_LIBRARIES("-fsanitize=address")
# endif()

# set(PERFTOOL OFF)
# if(PERFTOOL)
#     link_libraries(profiler)
# endif()
# add_executable(iPLTest
#     ${iPL_SOURCE}/PlacerDB.cc
#     ${iPL_API}/PLAPI.cc
#     # ${iPL_TEST}/APITest.cc
#     # ${iPL_TEST}/ReportCongTest.cc
#     ${iPL_TEST}/DCTTest.cc
#     # ${iPL_TEST}/ComputationCheck.cc
#     # ${iPL_TEST}/GlogTest.cc
#     # ${iPL_TEST}/CongEvalAPITest.cc
#     ${iPL_TEST}/NetworkFlowTest.cc
#     # ${iPL_TEST}/GridManagerTest.cc
# )
# set(OPENMP ON)
# if(OPENMP)
#     # Find OpenMP package
#     find_package(OpenMP REQUIRED)
#     # Add compiler flags for OpenMP support
#     if(OpenMP_CXX_FOUND)
#         target_compile_options(iPLTest PUBLIC ${OpenMP_CXX_FLAGS})
#     endif()
# endif()

# target_link_libraries(iPLTest
#     PUBLIC
#     ipl-api_external_libs
#     ipl-test_external_libs
#     ipl-api
#     ipl-source_external_libs
#     ipl-source

#     tool_api_icts
#     icts_api
#     icts_router
#     # icts_slew_aware
#     icts_evaluator
#     ito_api

#     tool_api_ipl
#     tool_manager
#     file_manager_placement
# )

add_executable(ipl_placement_status_test PlacementStatusTest.cc)
target_include_directories(ipl_placement_status_test PRIVATE ${iPL_API})
add_test(NAME ipl_placement_status_test COMMAND ipl_placement_status_test)

add_executable(ipl_placement_result_propagation_test PlacementResultPropagationTest.cc)
target_include_directories(ipl_placement_result_propagation_test PRIVATE ${iPL_API})
add_test(NAME ipl_placement_result_propagation_test COMMAND ipl_placement_result_propagation_test)

add_executable(ipl_command_boundary_test CommandBoundaryTest.cc)
target_include_directories(ipl_command_boundary_test PRIVATE ${iPL_API})
add_test(NAME ipl_command_boundary_test COMMAND ipl_command_boundary_test)

add_executable(ipl_api_failure_injection_test APIFailureInjectionTest.cc)
target_link_libraries(ipl_api_failure_injection_test PRIVATE ipl-api ipl-source icts_api)
target_include_directories(
  ipl_api_failure_injection_test
  PRIVATE
    ${iPL_API}
    ${CMAKE_SOURCE_DIR}/src/platform/data_manager
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder
)
target_compile_definitions(
  ipl_api_failure_injection_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_sky130_a/workspace/iEDA_config/pl_default_config.json"
    IPL_TEST_TECH_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_fd_sc_hd.tlef"
    IPL_TEST_CELLS_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"
    IPL_TEST_DEF_PATH="${CMAKE_SOURCE_DIR}/benchmarks/results/flow_20260814_gcd/gcd_sky130_a/workspace/result/iFP_result.def"
)
add_test(NAME ipl_api_failure_injection_test COMMAND ipl_api_failure_injection_test)

add_executable(ipl_run_gp_result_test RunGPResultTest.cc)
target_link_libraries(ipl_run_gp_result_test PRIVATE ipl-api ipl-source icts_api)
target_include_directories(
  ipl_run_gp_result_test
  PRIVATE
    ${iPL_API}
    ${CMAKE_SOURCE_DIR}/src/platform/data_manager
    ${CMAKE_SOURCE_DIR}/src/database/data/design
    ${CMAKE_SOURCE_DIR}/src/database/data/design/db_design
    ${CMAKE_SOURCE_DIR}/src/database/data/design/db_layout
    ${CMAKE_SOURCE_DIR}/src/database/basic/geometry
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/def_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/lef_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/verilog_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/json_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/gds_builder
)
target_compile_definitions(
  ipl_run_gp_result_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_sky130_a/workspace/iEDA_config/pl_default_config.json"
    IPL_TEST_TECH_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_fd_sc_hd.tlef"
    IPL_TEST_CELLS_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"
    IPL_TEST_DEF_PATH="${CMAKE_SOURCE_DIR}/benchmarks/results/flow_20260814_gcd/gcd_sky130_a/workspace/result/iFP_result.def"
)
add_test(NAME ipl_run_gp_result_test COMMAND ipl_run_gp_result_test)

add_executable(ipl_gp_session_test GPSessionTest.cc)
target_link_libraries(ipl_gp_session_test PRIVATE ipl-api ipl-source icts_api)
target_include_directories(
  ipl_gp_session_test
  PRIVATE
    ${iPL_API}
    ${iPL_SOURCE}
    ${CMAKE_SOURCE_DIR}/src/platform/data_manager
    ${CMAKE_SOURCE_DIR}/src/database/data/design
    ${CMAKE_SOURCE_DIR}/src/database/data/design/db_design
    ${CMAKE_SOURCE_DIR}/src/database/data/design/db_layout
    ${CMAKE_SOURCE_DIR}/src/database/basic/geometry
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/def_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/lef_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/verilog_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/json_builder
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder/gds_builder
)
target_compile_definitions(
  ipl_gp_session_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_sky130_a/workspace/iEDA_config/pl_default_config.json"
    IPL_TEST_CONFIG_PATH_CONGESTION="${CMAKE_SOURCE_DIR}/src/operation/iPL/test/configs/gp_congestion_config.json"
    IPL_TEST_CONFIG_PATH_DIVERGENCE="${CMAKE_SOURCE_DIR}/src/operation/iPL/test/configs/gp_divergence_config.json"
    IPL_TEST_CONFIG_PATH_MODIFIED="${CMAKE_SOURCE_DIR}/src/operation/iPL/test/configs/gp_modified_config.json"
    IPL_TEST_CONFIG_PATH_MULTITHREAD="${CMAKE_SOURCE_DIR}/src/operation/iPL/test/configs/gp_multithread_config.json"
    IPL_TEST_TECH_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_fd_sc_hd.tlef"
    IPL_TEST_CELLS_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_fd_sc_hd_merged.lef"
    IPL_TEST_DEF_PATH="${CMAKE_SOURCE_DIR}/benchmarks/results/flow_20260814_gcd/gcd_sky130_a/workspace/result/iFP_result.def"
)
add_test(NAME ipl_gp_session_seg20 COMMAND ipl_gp_session_test --scenario seg20)
add_test(NAME ipl_gp_session_seg40 COMMAND ipl_gp_session_test --scenario seg40)
add_test(NAME ipl_gp_session_seg10x2 COMMAND ipl_gp_session_test --scenario seg10x2)
add_test(NAME ipl_gp_session_observe COMMAND ipl_gp_session_test --scenario observe)
add_test(NAME ipl_gp_session_ckpt_save COMMAND ipl_gp_session_test --scenario ckpt_save)
add_test(NAME ipl_gp_session_ckpt_resume COMMAND ipl_gp_session_test --scenario ckpt_resume)
add_test(NAME ipl_gp_session_resume_inproc COMMAND ipl_gp_session_test --scenario resume_inproc)
add_test(NAME ipl_gp_session_seg40_cg COMMAND ipl_gp_session_test --scenario seg40_cg)
add_test(NAME ipl_gp_session_ckpt_save_cg COMMAND ipl_gp_session_test --scenario ckpt_save_cg)
add_test(NAME ipl_gp_session_ckpt_resume_cg COMMAND ipl_gp_session_test --scenario ckpt_resume_cg)
add_test(NAME ipl_gp_session_seg40_mt COMMAND ipl_gp_session_test --scenario seg40_mt)
add_test(NAME ipl_gp_session_ckpt_save_mt COMMAND ipl_gp_session_test --scenario ckpt_save_mt)
add_test(NAME ipl_gp_session_ckpt_resume_mt COMMAND ipl_gp_session_test --scenario ckpt_resume_mt)
add_test(NAME ipl_gp_session_conv_mid COMMAND ipl_gp_session_test --scenario conv_mid)
add_test(NAME ipl_gp_session_diverge COMMAND ipl_gp_session_test --scenario diverge)
add_test(NAME ipl_gp_session_mismatch COMMAND ipl_gp_session_test --scenario mismatch)
add_test(NAME ipl_gp_session_invalidate COMMAND ipl_gp_session_test --scenario invalidate)
add_test(NAME ipl_gp_session_relinearize COMMAND ipl_gp_session_test --scenario relinearize)
add_test(NAME ipl_gp_session_local_degenerate COMMAND ipl_gp_session_test --scenario local_degenerate)
add_test(NAME ipl_gp_session_local_context_frozen COMMAND ipl_gp_session_test --scenario local_context_frozen)
add_test(NAME ipl_gp_session_local_control COMMAND ipl_gp_session_test --scenario local_control)
add_test(NAME ipl_gp_session_local_ablate COMMAND ipl_gp_session_test --scenario local_ablate)
add_test(NAME ipl_gp_session_local_sweep COMMAND ipl_gp_session_test --scenario local_sweep)
add_test(NAME ipl_gp_session_seed_vary COMMAND ipl_gp_session_test --scenario seed_vary)
add_test(NAME ipl_gp_session_legacy COMMAND ipl_gp_session_test --scenario legacy)
add_test(NAME ipl_gp_session_full COMMAND ipl_gp_session_test --scenario full)
add_test(NAME ipl_gp_session_validate COMMAND ipl_gp_session_test --scenario validate)

add_executable(ipl_nesterov_place_config_test NesterovPlaceConfigTest.cc)
target_include_directories(
  ipl_nesterov_place_config_test
  PRIVATE
    ${iPL_SOURCE}
)
add_test(NAME ipl_nesterov_place_config_test COMMAND ipl_nesterov_place_config_test)

add_executable(ipl_nesterov_contract_test NesterovContractTest.cc)
target_include_directories(
  ipl_nesterov_contract_test
  PRIVATE
    ${iPL_SOURCE}
)
add_test(NAME ipl_nesterov_contract_test COMMAND ipl_nesterov_contract_test)

add_executable(ipl_config_validation_test ConfigValidationTest.cc)
target_link_libraries(ipl_config_validation_test PRIVATE ipl-configurator ipl-module-logger)
target_include_directories(ipl_config_validation_test PRIVATE ${iPL_SOURCE})
target_compile_definitions(
  ipl_config_validation_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_sky130_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_config_validation_test COMMAND ipl_config_validation_test)

add_executable(ipl_hpwirelength_test HPWirelengthTest.cc)
target_link_libraries(ipl_hpwirelength_test PRIVATE ipl_module_evaluator_wirelength ipl-module-topology_manager)
target_include_directories(
  ipl_hpwirelength_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/evaluator/wirelength
    ${iPL_SOURCE}/module/topology_manager
)
add_test(NAME ipl_hpwirelength_test COMMAND ipl_hpwirelength_test)

add_executable(ipl_wa_wirelength_gradient_test WAWirelengthGradientTest.cc)
target_link_libraries(ipl_wa_wirelength_gradient_test PRIVATE ipl_module_evaluator_wirelength ipl-module-topology_manager)
target_include_directories(
  ipl_wa_wirelength_gradient_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/evaluator/wirelength
    ${iPL_SOURCE}/module/topology_manager
)
add_test(NAME ipl_wa_wirelength_gradient_test COMMAND ipl_wa_wirelength_gradient_test)

add_executable(ipl_nfspread_result_test NFSpreadResultTest.cc)
target_include_directories(
  ipl_nfspread_result_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/detail_placer
)
add_test(NAME ipl_nfspread_result_test COMMAND ipl_nfspread_result_test)

add_executable(ipl_macro_placer_constraint_test MacroPlacerTest.cc)
target_link_libraries(ipl_macro_placer_constraint_test PRIVATE ipl-module-macro_placer ipl-source)
target_include_directories(
  ipl_macro_placer_constraint_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/macro_placer
)
target_compile_definitions(
  ipl_macro_placer_constraint_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_macro_placer_constraint_test COMMAND ipl_macro_placer_constraint_test)

add_executable(ipl_macro_placer_artifact_test MacroPlacerArtifactTest.cc)
target_link_libraries(ipl_macro_placer_artifact_test PRIVATE ipl-api ipl-source icts_api)
target_include_directories(
  ipl_macro_placer_artifact_test
  PRIVATE
    ${iPL_API}
    ${CMAKE_SOURCE_DIR}/src/platform/data_manager
    ${CMAKE_SOURCE_DIR}/src/database/manager/builder
)
target_compile_definitions(
  ipl_macro_placer_artifact_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_sky130_a/workspace/iEDA_config/pl_default_config.json"
    IPL_TEST_TECH_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_fd_sc_hd.tlef"
    IPL_TEST_MACRO_LEF_PATH="${CMAKE_SOURCE_DIR}/scripts/foundry/sky130/lef/sky130_sram_1rw1r_44x64_8.lef"
)
add_test(NAME ipl_macro_placer_artifact_test COMMAND ipl_macro_placer_artifact_test)

add_executable(ipl_layout_checker_test LayoutCheckerTest.cc)
target_link_libraries(ipl_layout_checker_test PRIVATE ipl-layout_checker ipl-source)
target_include_directories(
  ipl_layout_checker_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_CHECKER}
)
target_compile_definitions(
  ipl_layout_checker_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_layout_checker_test COMMAND ipl_layout_checker_test)

add_executable(ipl_placer_db_transaction_test PlacerDBTransactionTest.cc)
target_link_libraries(ipl_placer_db_transaction_test PRIVATE ipl-source)
target_include_directories(
  ipl_placer_db_transaction_test
  PRIVATE
    ${iPL_SOURCE}
)
target_compile_definitions(
  ipl_placer_db_transaction_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_placer_db_transaction_test COMMAND ipl_placer_db_transaction_test)

add_executable(ipl_write_back_source_database_test WriteBackSourceDatabaseTest.cc)
target_link_libraries(ipl_write_back_source_database_test PRIVATE ipl-source)
target_include_directories(
  ipl_write_back_source_database_test
  PRIVATE
    ${iPL_SOURCE}
)
target_compile_definitions(
  ipl_write_back_source_database_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_write_back_source_database_test COMMAND ipl_write_back_source_database_test)

add_executable(ipl_row_opt_test RowOptTest.cc)
target_link_libraries(ipl_row_opt_test PRIVATE ipl-module-detail_placer ipl-source)
target_include_directories(
  ipl_row_opt_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/detail_placer
)
target_compile_definitions(
  ipl_row_opt_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_row_opt_test COMMAND ipl_row_opt_test)

add_executable(ipl_instance_swap_test InstanceSwapTest.cc)
target_link_libraries(ipl_instance_swap_test PRIVATE ipl-module-detail_placer ipl-source)
target_include_directories(
  ipl_instance_swap_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/detail_placer
)
target_compile_definitions(
  ipl_instance_swap_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_instance_swap_test COMMAND ipl_instance_swap_test)

add_executable(ipl_local_reorder_test LocalReorderTest.cc)
target_link_libraries(ipl_local_reorder_test PRIVATE ipl-module-detail_placer ipl-source)
target_include_directories(
  ipl_local_reorder_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/detail_placer
)
target_compile_definitions(
  ipl_local_reorder_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_local_reorder_test COMMAND ipl_local_reorder_test)

add_executable(ipl_bin_opt_test BinOptTest.cc)
target_link_libraries(ipl_bin_opt_test PRIVATE ipl-module-detail_placer ipl-source)
target_include_directories(
  ipl_bin_opt_test
  PRIVATE
    ${iPL_SOURCE}
    ${iPL_SOURCE}/module/detail_placer
)
target_compile_definitions(
  ipl_bin_opt_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_bin_opt_test COMMAND ipl_bin_opt_test)

add_executable(ipl_sta_started_test STAStartedTest.cc)
target_link_libraries(ipl_sta_started_test PRIVATE tool_api_ista)
target_include_directories(
  ipl_sta_started_test
  PRIVATE
    ${CMAKE_SOURCE_DIR}/src/platform/tool_manager/tool_api/ista_io
    ${CMAKE_SOURCE_DIR}/src/platform/data_manager
    ${CMAKE_SOURCE_DIR}/src/platform/data_manager/config
    ${CMAKE_SOURCE_DIR}/src/platform/design_state
)
target_compile_definitions(
  ipl_sta_started_test
  PRIVATE
    IPL_TEST_CONFIG_PATH="${CMAKE_SOURCE_DIR}/benchmarks/designs/aes_nangate45_a/workspace/iEDA_config/pl_default_config.json"
)
add_test(NAME ipl_sta_started_test COMMAND ipl_sta_started_test)
