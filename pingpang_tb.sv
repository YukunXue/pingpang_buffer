`timescale 1ps/1ps

module pingpang_tb();


logic sys_clk;
logic sys_rst_n;

logic data_en;

logic [15:0]	data_in;
logic [15:0]	data_in_a;
logic [15:0]	data_in_b;
logic [15:0]	data_out;
logic [15:0]	data_out_a;	
logic [15:0]	data_out_b;

logic switch;

data_gen dut_gen(
	.clk	(sys_clk),
	.rst_n	(sys_rst_n),

	.data_en(data_en),
	.data_in(data_in)
);

pingpang	pingpang_rtl(
	.clk		(sys_clk),
	.rst_n		(sys_rst_n),

	.data_en	(data_en),
	.data_in_a	(data_in_a),
	.data_in_b	(data_in_b),
	.switch		(switch),
	.data_out_a	(data_out_a),
	.data_out_b	(data_out_b)
);

assign data_out = (switch)?	data_out_a : data_out_b;
assign data_in_a  = (switch)? 16'd0  : data_in;
assign data_in_b  = (switch)? data_in: 16'd0;


always #2 sys_clk = ~sys_clk;

initial begin
	sys_clk   = 1'b0;
	sys_rst_n = 1'b0;
	switch	  = 1'b0;
#10
	sys_rst_n = 1'b1;
#40 switch    = 1'b1;

#35 switch	  = ~ switch;

#21	switch	  = ~ switch;

#40	$finish;
end

initial begin
    $dumpfile("pingpang_tb.vcd");
    $dumpvars(0, pingpang_tb);    //tb模块名称
end

endmodule