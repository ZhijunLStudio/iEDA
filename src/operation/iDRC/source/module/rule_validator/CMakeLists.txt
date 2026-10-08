if(DEBUG_IDRC_RULE_VALIDATOR)
    message(STATUS "DRC: DEBUG_IDRC_RULE_VALIDATOR")
    set(CMAKE_BUILD_TYPE "Debug")
else()
    message(STATUS "DRC: RELEASE_IDRC_RULE_VALIDATOR")
    set(CMAKE_BUILD_TYPE "Release")
endif()

add_library(idrc_rule_coverage
    ${IDRC_MODULE}/rule_validator/coverage/RuleCoverage.cpp
)

function(idrc_apply_optional_tsan target_name)
    if(IDRC_ENABLE_TSAN)
        target_compile_options(${target_name} PRIVATE -fsanitize=thread -fno-omit-frame-pointer)
        target_link_libraries(${target_name} PRIVATE -fsanitize=thread)
    endif()
endfunction()

target_include_directories(idrc_rule_coverage
    PUBLIC
    ${IDRC_MODULE}/rule_validator/coverage
    ${IDRC_MODULE}/rule_validator
)
idrc_apply_optional_tsan(idrc_rule_coverage)

add_executable(idrc_rule_coverage_test EXCLUDE_FROM_ALL
    ${IDRC_MODULE}/rule_validator/tests/RuleCoverageTest.cpp
)

target_link_libraries(idrc_rule_coverage_test
    PRIVATE
    idrc_rule_coverage
)
idrc_apply_optional_tsan(idrc_rule_coverage_test)
add_test(NAME idrc_rule_coverage_test COMMAND idrc_rule_coverage_test)

add_executable(idrc_rule_runtime_stats_test EXCLUDE_FROM_ALL
    ${IDRC_MODULE}/rule_validator/tests/RuleRuntimeStatsTest.cpp
)

target_link_libraries(idrc_rule_runtime_stats_test
    PRIVATE
    idrc_rule_coverage
)
target_include_directories(idrc_rule_runtime_stats_test
    PRIVATE
    ${IDRC_DATA_MANAGER}/advance
    ${IDRC_DATA_MANAGER}/basic
    ${IDRC_TOOLKIT}/logger
    ${IDRC_TOOLKIT}/monitor
    ${IDRC_TOOLKIT}/utility
    ${IDRC_MODULE}/rule_validator/rv_data_manager
)
idrc_apply_optional_tsan(idrc_rule_runtime_stats_test)
add_test(NAME idrc_rule_runtime_stats_test COMMAND idrc_rule_runtime_stats_test)

add_library(idrc_violation_artifact
    ${IDRC_MODULE}/rule_validator/ViolationArtifact.cpp
)

target_link_libraries(idrc_violation_artifact
    PUBLIC
    idrc_rule_coverage
)

target_include_directories(idrc_violation_artifact
    PUBLIC
    ${IDRC_MODULE}/rule_validator
    ${HOME_DATABASE}/interaction/RT_DRC
)
idrc_apply_optional_tsan(idrc_violation_artifact)

add_library(idrc_calibre_compare_tool
    ${IDRC_MODULE}/rule_validator/CalibreCompareTool.cpp
)

target_link_libraries(idrc_calibre_compare_tool
    PUBLIC
    idrc_violation_artifact
)

target_include_directories(idrc_calibre_compare_tool
    PUBLIC
    ${IDRC_MODULE}/rule_validator
)
idrc_apply_optional_tsan(idrc_calibre_compare_tool)

add_executable(idrc_calibre_compare EXCLUDE_FROM_ALL
    ${IDRC_MODULE}/rule_validator/CalibreCompareMain.cpp
)

target_link_libraries(idrc_calibre_compare
    PRIVATE
    idrc_calibre_compare_tool
)

add_executable(idrc_calibre_compare_test EXCLUDE_FROM_ALL
    ${IDRC_MODULE}/rule_validator/tests/CalibreCompareToolTest.cpp
)

target_link_libraries(idrc_calibre_compare_test
    PRIVATE
    idrc_calibre_compare_tool
)
idrc_apply_optional_tsan(idrc_calibre_compare_test)
add_test(NAME idrc_calibre_compare_test COMMAND idrc_calibre_compare_test)

add_executable(idrc_violation_artifact_test EXCLUDE_FROM_ALL
    ${IDRC_MODULE}/rule_validator/tests/ViolationArtifactTest.cpp
)

target_link_libraries(idrc_violation_artifact_test
    PRIVATE
    idrc_violation_artifact
)
idrc_apply_optional_tsan(idrc_violation_artifact_test)
add_test(NAME idrc_violation_artifact_test COMMAND idrc_violation_artifact_test)

add_library(idrc_rule_validator
    ## module rule_validator
    ${IDRC_MODULE}/rule_validator/RuleValidator.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/AdjacentCutSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/CornerFillSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/CornerSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/CutEOLSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/CutShort.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/DifferentLayerCutSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/Enclosure.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/EnclosureEdge.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/EnclosureParallel.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/EndOfLineSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/FloatingPatch.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/JogToJogSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MaximumWidth.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MaxViaStack.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MetalShort.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MinHole.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MinimumArea.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MinimumCut.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MinimumWidth.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/MinStep.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/NonsufficientMetalOverlap.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/NotchSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/OffGridOrWrongWay.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/OutOfDie.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/ParallelRunLengthSpacing.cpp
    ${IDRC_MODULE}/rule_validator/rv_design_rule/SameLayerCutSpacing.cpp
)

target_link_libraries(idrc_rule_validator
    PUBLIC
    idrc_rule_coverage
    idrc_violation_artifact
    idrc_data_manager
    idrc_module
    idrc_toolkit
)
idrc_apply_optional_tsan(idrc_rule_validator)

target_include_directories(idrc_rule_validator
    PUBLIC
    ${IDRC_MODULE}/rule_validator/rv_data_manager
    ${IDRC_MODULE}/rule_validator
)
