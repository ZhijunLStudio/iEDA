add_library(ilvs_core
    LayoutConnectivityExtractor.cpp
    LvsCore.cpp
    VerilogReferenceLoader.cpp
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

add_library(ilvs_idb_adapter
    IdbLayoutConnectivityAdapter.cpp
)

target_link_libraries(ilvs_idb_adapter
    PUBLIC
    ilvs_core
    idb
)

target_include_directories(ilvs_idb_adapter
    PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)
