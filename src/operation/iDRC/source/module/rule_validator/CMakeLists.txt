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

target_include_directories(idrc_rule_coverage
    PUBLIC
    ${IDRC_MODULE}/rule_validator/coverage
)

add_executable(idrc_rule_coverage_test EXCLUDE_FROM_ALL
    ${IDRC_MODULE}/rule_validator/tests/RuleCoverageTest.cpp
)

target_link_libraries(idrc_rule_coverage_test
    PRIVATE
    idrc_rule_coverage
)
add_test(NAME idrc_rule_coverage_test COMMAND idrc_rule_coverage_test)

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

add_executable(idrc_violation_artifact_test EXCLUDE_FROM_ALL
    ${IDRC_MODULE}/rule_validator/tests/ViolationArtifactTest.cpp
)

target_link_libraries(idrc_violation_artifact_test
    PRIVATE
    idrc_violation_artifact
)
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

target_include_directories(idrc_rule_validator
    PUBLIC
    ${IDRC_MODULE}/rule_validator/rv_data_manager
    ${IDRC_MODULE}/rule_validator
)
