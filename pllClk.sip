set_global_assignment -entity "pllClk" -library "lib_pllClk" -name IP_TOOL_NAME "altera_pll"
set_global_assignment -entity "pllClk" -library "lib_pllClk" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "pllClk" -library "lib_pllClk" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_pllClk" -name SPD_FILE [file join $::quartus(sip_path) "pllClk.spd"]

set_global_assignment -library "lib_pllClk" -name MISC_FILE [file join $::quartus(sip_path) "pllClk_sim/pllClk.vo"]
