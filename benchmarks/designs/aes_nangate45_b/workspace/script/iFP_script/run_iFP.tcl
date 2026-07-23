source $::env(TCL_SCRIPT_DIR)/DB_script/db_path_setting.tcl
source $::env(TCL_SCRIPT_DIR)/DB_script/db_init_lef.tcl

# Read design
read_verilog $NETLIST_FILES
link_design $::env(DESIGN_TOP)

# Initialize floorplan with die area from environment
set die_area [split $::env(DIE_AREA)]
set die_llx [lindex $die_area 0]
set die_lly [lindex $die_area 1]
set die_urx [lindex $die_area 2]
set die_ury [lindex $die_area 3]

# Create floorplan
init_floorplan -die_area "$die_llx $die_lly $die_urx $die_ury" \
               -core_area "$die_llx $die_lly $die_urx $die_ury" \
               -core_site FreePDK45_38x28_10R_NP_162NW_34O

# Place IO pins
place_io_pin

# Write output
write_def $::env(RESULT_DIR)/iFP_result.def

puts "Simplified Floorplan completed"
exit
