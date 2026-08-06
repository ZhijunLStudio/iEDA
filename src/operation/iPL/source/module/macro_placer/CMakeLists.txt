aux_source_directory(. SRC)
add_library(ipl-module-macro_placer ${SRC})

target_link_libraries(ipl-module-macro_placer
    PUBLIC
        ipl-configurator
        ipl-module-logger
)

target_include_directories(ipl-module-macro_placer PUBLIC
    ${iPL_SOURCE}
    ${iPL_SOURCE}/data
    ${iPL_SOURCE}/module/logger
    ${iPL_SOURCE}/module/buffer/config
    ${iPL_SOURCE}/module/detail_placer/config
    ${iPL_SOURCE}/module/filler/config
    ${iPL_SOURCE}/module/global_placer/electrostatic_placer/config
    ${iPL_SOURCE}/module/legalizer/config
    ${iPL_SOURCE}/module/macro_placer/config
    ${iPL_SOURCE}/module/post_global_placer/config
)
