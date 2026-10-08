add_library(ilvs_api
    ILVSAPI.cpp
)

target_link_libraries(ilvs_api
    PUBLIC
    ilvs_core
)

target_include_directories(ilvs_api
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
