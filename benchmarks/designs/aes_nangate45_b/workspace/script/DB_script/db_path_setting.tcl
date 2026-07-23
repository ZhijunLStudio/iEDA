set DB_LEF_PATH "$::env(FOUNDRY_DIR)/lef"
set DB_LIB_PATH "$::env(FOUNDRY_DIR)/lib"

#===========================================================
##   set tech lef and cells lef path for nangate45
#===========================================================
set TECH_LEF_PATH "$DB_LEF_PATH/NangateOpenCellLibrary.tech.lef"
set LEF_PATH "$DB_LEF_PATH/NangateOpenCellLibrary.macro.lef"

#===========================================================
##   set lib path
#===========================================================
set LIB_FILES [list \
  "$DB_LIB_PATH/NangateOpenCellLibrary_typical.lib" \
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
