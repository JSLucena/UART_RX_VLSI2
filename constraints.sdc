## DEFINE VARS
set sdc_version 1.5
set_load_unit -picofarads 1


## CLOCK
create_clock -name clock_in -period 5 [get_ports clock_in]

set_clock_transition -rise 0.1 [get_clocks clock_in]
set_clock_transition -fall 0.1 [get_clocks clock_in]

## OUTPUTS
set_load -min 0.0014 [all_outputs]
set_load -max 0.32 [all_outputs]
