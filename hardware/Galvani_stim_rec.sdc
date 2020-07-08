create_clock -name {CLK} -period 64MHz [get_ports {CLK}]
create_generated_clock -name {CLK_DIV} -divide_by 4 -source [get_ports {CLK}] [get_registers {stim|CLK_DIVIDER_DIV_20|CLK_DIV}]
create_clock -name {NI_CLK} -period 4MHz [get_ports {NI_CLK}]
