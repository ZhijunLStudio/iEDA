set DB_LEF_PATH "$::env(FOUNDRY_DIR)/prtech/techLEF"
set DB_LIB_PATH "$::env(FOUNDRY_DIR)/prtech/signalStormCellLib"

#===========================================================
##   set tech lef and cells lef path for ics55
#===========================================================
set TECH_LEF_PATH "$DB_LEF_PATH/N551P6M_ieda.lef"
set LEF_PATH "$DB_LIB_PATH/signalStorm55_lef.lef"

#===========================================================
##   set lib path
#===========================================================
set LIB_FILES [list \
  "$DB_LIB_PATH/signalStorm55_tt.lib" \
]

#===========================================================
##   set sdc path
#===========================================================
set SDC_PATH "$::env(SDC_FILE)"

#===========================================================
##   set netlist path
#===========================================================
set NETLIST_FILES [list \
  "$::env(NETLIST_FILE)" \
]

#===========================================================
##   set DEF path (optional, only for incremental flow)
#===========================================================
if { [info exists ::env(DEF_FILE)] } {
    set DEF_PATH "$::env(DEF_FILE)"
}
