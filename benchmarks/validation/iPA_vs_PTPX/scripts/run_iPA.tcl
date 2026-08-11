# iPA Power Analysis Template for Commercial Parity Validation
# This template runs iPA with full activity provenance tracking
# and outputs JSON reports per 29-iPA-iIR-todo.md P0 schema

# Load design database
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_sdc.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

# Load placed DEF (from iPL or post-routing)
def_init -path $::env(DEF_PATH)

# Configure power analysis
set_power_analysis_mode \
    -default_toggle_rate 0.02 \
    -use_default_toggle_only_when_no_vcd 1 \
    -report_activity_source 1 \
    -report_toggle_coverage 1

# Set activity source (VCD, SAIF, or none)
if {[info exists ::env(VCD_PATH)] && $::env(VCD_PATH) ne ""} {
    read_vcd \
        -file $::env(VCD_PATH) \
        -top_instance $::env(VCD_TOP_INSTANCE) \
        -start_time $::env(VCD_START_TIME) \
        -end_time $::env(VCD_END_TIME)

    puts "INFO: VCD loaded from $::env(VCD_PATH)"
} elseif {[info exists ::env(SAIF_PATH)] && $::env(SAIF_PATH) ne ""} {
    read_saif \
        -file $::env(SAIF_PATH) \
        -instance_name $::env(SAIF_INSTANCE)

    puts "INFO: SAIF loaded from $::env(SAIF_PATH)"
} else {
    puts "WARN: No VCD/SAIF provided, using default toggle rates"
    # Activity source will be marked as "toggle_default" in report
}

# Run power analysis with full flow
run_power_analysis \
    -corner $::env(CORNER) \
    -temperature $::env(TEMPERATURE) \
    -output_dir $::env(RESULT_DIR)/power

# Generate JSON report with required P0 fields
report_power \
    -format json \
    -file $::env(RESULT_DIR)/power/iPA_report.json \
    -include_activity_source \
    -include_toggle_coverage \
    -include_component_breakdown \
    -include_instance_power

# Generate CSV instance power for iIR integration
report_power \
    -format csv \
    -file $::env(RESULT_DIR)/power/instance_power.csv \
    -per_instance

# Exit cleanly
flow_exit
