add_library(ieco_timing
    ieco_timing.cpp
)

target_include_directories(ieco_timing
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_executable(ieco_timing_contract_test EXCLUDE_FROM_ALL
    tests/ECOTimingContractTest.cpp
)

target_include_directories(ieco_timing_contract_test
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(ieco_timing_contract_test
    PRIVATE
    ieco_timing
)

add_test(NAME ieco_timing_contract_test COMMAND ieco_timing_contract_test)
