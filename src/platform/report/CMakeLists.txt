include(${HOME_CMAKE}/operation/idb.cmake)

add_subdirectory(report_basic)
add_subdirectory(report_db)
add_subdirectory(report_evaluator)
add_subdirectory(report_route)
add_subdirectory(report_place)
add_subdirectory(report_drc)

add_library(ieda_report
  report_manager.cpp
  quality_gate.cpp
)

target_link_libraries(ieda_report 
    PRIVATE
        report_basic 
        ieda_report_db
        ieda_report_evaluator
        ieda_report_route
        ieda_report_place
        ieda_report_drc
)

target_include_directories(ieda_report 
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${HOME_THIRDPARTY}/json
)

add_executable(ieda_quality_gate_test EXCLUDE_FROM_ALL
    tests/QualityGateTest.cpp
    quality_gate.cpp
)

target_include_directories(ieda_quality_gate_test
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${HOME_THIRDPARTY}/json
)

add_test(NAME ieda_quality_gate_test COMMAND ieda_quality_gate_test)
