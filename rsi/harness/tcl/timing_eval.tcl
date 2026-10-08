# Timing rung: placement timing evaluation with the HPWL-based pre-route RC model.
# All paths come from the environment so the harness can point them at the isolated
# workspace instead of the historical source tree.
if {![info exists ::env(INPUT_DEF)] || $::env(INPUT_DEF) eq ""} { error "missing INPUT_DEF" }
if {![info exists ::env(RESULT_DIR)] || $::env(RESULT_DIR) eq ""} { error "missing RESULT_DIR" }

flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
tech_lef_init -path $::env(TECH_LEF)
lef_init -path $::env(LEF)
db_init -lib_path $::env(LIB)
db_init -sdc_path $::env(SDC)
def_init -path $::env(INPUT_DEF)
run_timing_eval -eval_output_path $::env(RESULT_DIR) -routing_type HPWL
flow_exit
