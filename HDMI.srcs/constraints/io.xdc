set_property PACKAGE_PIN Y9 [get_ports {clk}];  # "GCLK"

set_property PACKAGE_PIN P16 [get_ports {rst}];  # "BTNC"

# ----------------------------------------------------------------------------
# HDMI Output - Bank 33
# ---------------------------------------------------------------------------- 
set_property PACKAGE_PIN W18  [get_ports {hd_clk}];  # "HD-CLK"
set_property PACKAGE_PIN Y13  [get_ports {hd_data[0]}];  # "HD-D0"
set_property PACKAGE_PIN AA13 [get_ports {hd_data[1]}];  # "HD-D1"
set_property PACKAGE_PIN AA14 [get_ports {hd_data[2]}];  # "HD-D2"
set_property PACKAGE_PIN Y14  [get_ports {hd_data[3]}];  # "HD-D3"
set_property PACKAGE_PIN AB15 [get_ports {hd_data[4]}];  # "HD-D4"
set_property PACKAGE_PIN AB16 [get_ports {hd_data[5]}];  # "HD-D5"
set_property PACKAGE_PIN AA16 [get_ports {hd_data[6]}];  # "HD-D6"
set_property PACKAGE_PIN AB17 [get_ports {hd_data[7]}];  # "HD-D7"
set_property PACKAGE_PIN AA17 [get_ports {hd_data[8]}];  # "HD-D8"
set_property PACKAGE_PIN Y15  [get_ports {hd_data[9]}];  # "HD-D9"
set_property PACKAGE_PIN W13  [get_ports {hd_data[10]}];  # "HD-D10"
set_property PACKAGE_PIN W15  [get_ports {hd_data[11]}];  # "HD-D11"
set_property PACKAGE_PIN V15  [get_ports {hd_data[12]}];  # "HD-D12"
set_property PACKAGE_PIN U17  [get_ports {hd_data[13]}];  # "HD-D13"
set_property PACKAGE_PIN V14  [get_ports {hd_data[14]}];  # "HD-D14"
set_property PACKAGE_PIN V13  [get_ports {hd_data[15]}];  # "HD-D15"
set_property PACKAGE_PIN U16  [get_ports {hd_de}];  # "HD-DE"
set_property PACKAGE_PIN V17  [get_ports {hd_hsync}];  # "HD-HSYNC"
set_property PACKAGE_PIN W17  [get_ports {hd_vsync}];  # "HD-VSYNC"
set_property PACKAGE_PIN AA18 [get_ports {hd_scl}];  # "HD-SCL"
set_property PACKAGE_PIN Y16  [get_ports {hd_sda}];  # "HD-SDA"

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];
