# Signoff from a placed DEF: clock tree, then routing, then DRC.
#
# The project's per-stage scripts read the SDC before the DEF, which cannot resolve
# a clock port that only the DEF introduces. This script keeps the same stages but
# orders the reads as: config, tech LEF, cell LEF, DEF, library, SDC, then the stage.
if {![info exists ::env(INPUT_DEF)] || $::env(INPUT_DEF) eq ""} { error "missing INPUT_DEF" }
if {![info exists ::env(RESULT_DIR)] || $::env(RESULT_DIR) eq ""} { error "missing RESULT_DIR" }
if {![info exists ::env(STAGE)] || $::env(STAGE) eq ""} { error "missing STAGE (cts|rt|drc)" }

flow_init -config $::env(CONFIG_DIR)/flow_config.json
db_init -config $::env(CONFIG_DIR)/db_default_config.json -output_dir_path $::env(RESULT_DIR)
tech_lef_init -path $::env(TECH_LEF)
lef_init -path $::env(LEF)
def_init -path $::env(INPUT_DEF)
db_init -lib_path $::env(LIB)
db_init -sdc_path $::env(SDC)

if {$::env(STAGE) eq "cts"} {
  run_cts -config $::env(CONFIG_DIR)/cts_default_config.json -work_dir $::env(RESULT_DIR)/cts
  def_save -path $::env(OUTPUT_DEF)
} elseif {$::env(STAGE) eq "rt"} {
  init_rt
  run_rt
  destroy_rt
  def_save -path $::env(OUTPUT_DEF)
} elseif {$::env(STAGE) eq "drc"} {
  run_drc -config $::env(CONFIG_DIR)/drc_default_config.json -path $::env(RESULT_DIR)/report/drc.rpt
  save_drc -path $::env(RESULT_DIR)/drc/detail.json
} else {
  error "unknown STAGE $::env(STAGE)"
}
flow_exit
