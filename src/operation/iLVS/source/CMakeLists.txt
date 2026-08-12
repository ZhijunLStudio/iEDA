add_library(ilvs_core
    LvsCore.cpp
)

target_include_directories(ilvs_core
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

target_include_directories(ilvs_core
    SYSTEM
    PUBLIC
    ${HOME_THIRDPARTY}
)
