# Evaluate placement timing with the same HPWL-based pre-route RC model used
# by the placement timing evaluator.  This is deliberately separate from the
# plain iSTA `run_sta` command: the latter reports cell-only timing when no
# routed parasitics are present, while placement comparison needs geometric RC.
if {![info exists ::env(INPUT_DEF)] || $::env(INPUT_DEF) eq ""} { error "Missing INPUT_DEF" }
if {![info exists ::env(RESULT_DIR)] || $::env(RESULT_DIR) eq ""} { error "Missing RESULT_DIR" }

flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_sdc.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl
def_init -path $::env(INPUT_DEF)

run_timing_eval -eval_output_path $::env(RESULT_DIR) -routing_type HPWL
flow_exit
