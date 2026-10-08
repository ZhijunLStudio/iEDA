add_library(ieco_via_contract
    ieco_via_report.cpp
)

target_include_directories(ieco_via_contract
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${HOME_THIRDPARTY}/json
)

add_library(ieco_via
    ieco_via.cpp
    ieco_via_init.cpp
    ieco_via_repair.cpp
)

target_link_libraries(ieco_via
    PUBLIC
    ieco_via_contract
    idm
    idb
    geometry_db
    solver_geometry
    solver_geometry_boost
    ieco_data
    ieco_dm

)

target_include_directories(ieco_via
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_executable(ieco_via_request_test EXCLUDE_FROM_ALL
    tests/ECOViaRequestTest.cpp
)

target_include_directories(ieco_via_request_test
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_link_libraries(ieco_via_request_test
    PRIVATE
    ieco_via_contract
)

add_test(NAME ieco_via_request_test COMMAND ieco_via_request_test)
