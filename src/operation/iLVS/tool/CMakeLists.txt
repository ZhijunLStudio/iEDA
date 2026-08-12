add_executable(iLVS
    iLVSMain.cpp
)

target_link_libraries(iLVS
    PRIVATE
    ilvs_api
)
