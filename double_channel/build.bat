set testbentch_module=pingpang_tb
set v_file= "*.v"
set sv_file= "*.sv"
set rtl_file= %v_file% %sv_file%
echo rtl_file = %rtl_file%
set gtkw_file="%testbentch_module%.gtkw"

iverilog -g2012 -o "%testbentch_module%.vvp" %rtl_file% 
vvp -n "%testbentch_module%.vvp" -lxt2

IF EXIST %gtkw_file%  (
        gtkwave %gtkw_file% 
) ELSE (
        gtkwave "%testbentch_module%.vcd"
)  
pause