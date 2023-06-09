create_clock -name clk -period 10 [get_ports clk]
set_false_path -from [get_cells adv7511_setup/finished_reg] -to [get_cells video_generator/functioning_reg]
