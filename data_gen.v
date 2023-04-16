`timescale 1ps/1ps
module data_gen(
	input				clk,
	input				rst_n,

	output	reg			data_en,
	output	reg [15:0]	data_in
);

always @(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0)begin
		data_en <= 1'b0;
	end
	else
		data_en <= 1'b1;
end

always @(posedge clk or negedge rst_n)begin
	if(rst_n == 1'b0)
		data_in	<= 16'd0;
	else if(data_in == 16'd199)
		data_in <= 16'd0;
	else if(data_en)
		data_in <= data_in + 1'd1;
	else
		data_in <= data_in;
end


endmodule