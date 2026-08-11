# iIR Static IR Drop Analysis Template for Commercial Parity Validation
# This template runs iIR with full convergence tracking and PG provenance
# and outputs JSON reports per 29-iPA-iIR-todo.md P0 schema

# Load design database
flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lib.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

# Load DEF with PG netlist
def_init -path $::env(DEF_PATH)

# Load PG provenance from iPDN/iPNP
# This validates that the PG netlist is from a known trusted source
if {[info exists ::env(PG_GENERATOR)] && [info exists ::env(PG_INPUT_HASH)]} {
    set_pg_provenance \
        -generator $::env(PG_GENERATOR) \
        -input_hash $::env(PG_INPUT_HASH)

    puts "INFO: PG provenance set: $::env(PG_GENERATOR) / $::env(PG_INPUT_HASH)"
} else {
    puts "ERROR: PG provenance required for signoff IR analysis"
    exit 1
}

# Load instance power from iPA (preferred) or PTPX
if {[info exists ::env(IPA_POWER_JSON)] && $::env(IPA_POWER_JSON) ne ""} {
    read_instance_power \
        -format json \
        -file $::env(IPA_POWER_JSON) \
        -source "iPA"

    puts "INFO: Instance power loaded from iPA: $::env(IPA_POWER_JSON)"
} elseif {[info exists ::env(PTPX_POWER_CSV)] && $::env(PTPX_POWER_CSV) ne ""} {
    read_instance_power \
        -format csv \
        -file $::env(PTPX_POWER_CSV) \
        -source "ptpx"

    puts "INFO: Instance power loaded from PTPX: $::env(PTPX_POWER_CSV)"
} else {
    puts "ERROR: No instance power source provided"
    exit 1
}

# Configure IR solver
set_ir_solver_options \
    -method conjugate_gradient \
    -max_iterations 1000 \
    -relative_tolerance 1e-8 \
    -absolute_tolerance 1e-10 \
    -check_numerical_health 1

# Set voltage and IR budget
set_nominal_voltage $::env(NOMINAL_VOLTAGE)
set_ir_budget -net VDD -budget $::env(IR_BUDGET_MV)mV
set_ir_budget -net VSS -budget $::env(IR_BUDGET_MV)mV

# Set bump/pad locations if available
if {[info exists ::env(BUMP_LOC_FILE)] && $::env(BUMP_LOC_FILE) ne ""} {
    read_bump_locations -file $::env(BUMP_LOC_FILE)
    puts "INFO: Bump locations loaded from $::env(BUMP_LOC_FILE)"
}

# Run static IR analysis
run_ir_analysis \
    -net_names {VDD VSS} \
    -output_dir $::env(RESULT_DIR)/ir

# Generate JSON report with required P0 fields:
# - peak_ir_mv, budget_mv, converged, iterations, residuals
# - current_source provenance
# - mapping_trace (P1 requirement)
report_ir_drop \
    -format json \
    -file $::env(RESULT_DIR)/ir/iIR_report.json \
    -include_convergence_metrics \
    -include_current_source \
    -include_mapping_trace \
    -top_n_nodes 50

# Generate detailed node report
report_ir_drop \
    -format csv \
    -file $::env(RESULT_DIR)/ir/node_voltages.csv \
    -per_node

# Gate on convergence (P0 requirement)
# If IR analysis did not converge, exit with non-zero status
set ir_report [get_ir_report]
if {![dict get $ir_report converged]} {
    puts "ERROR: IR analysis did not converge"
    puts "  Iterations: [dict get $ir_report iterations]"
    puts "  Relative residual: [dict get $ir_report relative_residual]"
    puts "  Absolute residual: [dict get $ir_report absolute_residual]"
    exit 1
}

# Gate on PG/current coverage (P1 requirement)
set mapping_trace [dict get $ir_report mapping_trace]
set coverage [expr {double([dict get $mapping_trace mapped_instances]) /
                     [dict get $mapping_trace total_power_instances]}]
if {$coverage < 0.9} {
    puts "WARN: Current mapping coverage ${coverage}% below 90% target"
    puts "  Mapped: [dict get $mapping_trace mapped_instances] / [dict get $mapping_trace total_power_instances]"
    puts "  Unmatched power: [dict get $mapping_trace unmatched_power_w]W"
}

puts "INFO: IR analysis complete"
puts "  Peak IR: [dict get $ir_report peak_ir_mv] mV"
puts "  Budget: [dict get $ir_report budget_mv] mV"
puts "  Utilization: [format %.1f [expr {[dict get $ir_report peak_ir_mv] / [dict get $ir_report budget_mv] * 100}]]%"
puts "  Converged: [dict get $ir_report converged] ([dict get $ir_report iterations] iterations)"

# Exit cleanly
flow_exit
