# Run one placement stage on a DEF, from absolute paths, then save.
# Uses the same init order as the timing rung, which is known to work, instead of the
# case-root db_path_setting.tcl which expects env vars the flow driver normally sets.
if {![info exists ::env(INPUT_DEF)] || $::env(INPUT_DEF) eq ""} { error "missing INPUT_DEF" }
if {![info exists ::env(OUTPUT_DEF)] || $::env(OUTPUT_DEF) eq ""} { error "missing OUTPUT_DEF" }
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
tech_lef_init -path $::env(TECH_LEF)
lef_init -path $::env(LEF)
def_init -path $::env(INPUT_DEF)
db_init -lib_path $::env(LIB)
db_init -sdc_path $::env(SDC)
init_pl -config $::env(PL_CONFIG)
if {$::env(STAGE) eq "nfs"} { placer_run_nfs }
if {$::env(STAGE) eq "lg"} { placer_run_lg }
if {$::env(STAGE) eq "lgdp"} { placer_run_lg
placer_run_dp }
def_save -path $::env(OUTPUT_DEF)
flow_exit
