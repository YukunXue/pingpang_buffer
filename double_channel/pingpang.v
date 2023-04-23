`timescale 1ps/1ps

module pingpang(

	input 			clk,
	input 			rst_n,

	input			data_en,
	input	[15:0]	data_in_a,
	input	[15:0]	data_in_b,
	input			switch,
	output	[15:0]	data_out_a,
	output	[15:0]	data_out_b
);

	reg		[15:0]	buffer_a1;
	reg		[15:0]	buffer_a2;

	reg		[15:0]	buffer_b1;
	reg		[15:0]	buffer_b2;

	reg		[15:0]	data_out;
	reg		[15:0]	data_temp;

	reg		switch_r1;
	reg		switch_r2;

	wire    mux_switch = switch_r1 ^ switch_r2;

	reg	buffer1_wen;
	reg	buffer2_wen;

	reg	buffer1_ren;
	reg	buffer2_ren;

	parameter A2B		=	1'b0,
			  B2A 		=	1'b1;

	parameter MUX_B2A	=	1'b1,
			  MUX_A2B	=	1'b0;
//----------------------------start----------------------------------------\\
	//parameter	FSM --> control the buffer read & write
	parameter	IDLE		=	4'b0001, 
				WBUF1		=	4'b0010,
				WBUF2_RBUF1	=	4'b0100,
				WBUF1_RBUF2	=	4'b1000;
	
	reg	[3:0]	state_c;
	reg	[3:0]	state_n;


	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)
			state_c <= IDLE;
		else begin
			state_c <= state_n;
		end
	end

	always @(*) begin
		if(!rst_n)begin
			state_n <= IDLE;
		end
		else case(state_c)
		IDLE:
			if(data_en)begin
				state_n = WBUF1;
			end
		WBUF1:
			if(data_en)begin
				state_n = WBUF2_RBUF1;
			end
		WBUF2_RBUF1:
			if(data_en)begin
				state_n = WBUF1_RBUF2;
			end
		WBUF1_RBUF2:
			if(data_en)begin
				state_n = WBUF2_RBUF1;
			end
		default:
			state_n	<= IDLE;
		endcase
	end

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			buffer1_wen <= 1'b0;
			buffer2_wen <= 1'b0;
			buffer1_ren <= 1'b0;
			buffer2_ren <= 1'b0;
		end
		else
		case (state_n)
			IDLE:
				begin
					buffer1_wen <= 1'b0;
					buffer2_wen <= 1'b0;

					buffer1_ren <= 1'b0;
					buffer2_ren <= 1'b0;
				end
			WBUF1:
				begin
					buffer1_wen <= 1'b1;
					buffer2_wen <= 1'b0;

					buffer1_ren <= 1'b0;
					buffer2_ren <= 1'b0;
				end
			WBUF2_RBUF1:
				begin
					buffer1_wen <= 1'b0;
					buffer2_wen <= 1'b1;

					buffer1_ren <= 1'b1;
					buffer2_ren <= 1'b0;
				end
			WBUF1_RBUF2:
				begin
					buffer1_wen <= 1'b1;
					buffer2_wen <= 1'b0;

					buffer1_ren <= 1'b0;
					buffer2_ren <= 1'b1;				
				end
			default: ;
		endcase
	end

//----------------------------end----------------------------------------\\

	always @(posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			switch_r1 <= 1'b0;
			switch_r2 <= 1'b0;
		end
		else begin
			switch_r1 <= switch;
			switch_r2 <= switch_r1;
		end
	end

	//read buffer 

	always @ (posedge clk or negedge rst_n)begin
		if(!rst_n)begin
			buffer_a1 <= 16'd0;
			buffer_a2 <= 16'd0;
			buffer_b1 <= 16'd0;
			buffer_b2 <= 16'd0;
			data_out <= 16'd0;
		end
		else begin
			case(switch)
			A2B:
				begin
					if(buffer1_ren)begin
						data_out <= buffer_a1;
					end
					else if(buffer2_ren)begin
						data_out <= buffer_a2;
					end
					else begin
						data_out <= data_out;
					end
				end

			B2A:
				begin
					if(buffer1_ren)begin
						data_out <= buffer_b1;
					end
					else if(buffer2_ren)begin
						data_out <= buffer_b2;
					end
					else begin
						data_out <= data_out;
					end
				end
			endcase
		end
	end

	//write buffer

	always @(posedge clk or negedge rst_n) begin
		if(!rst_n)begin
			buffer_a1 <= 16'd0;
			buffer_a2 <= 16'd0;
			buffer_b1 <= 16'd0;
			buffer_b2 <= 16'd0;
		end
		else begin
			case(switch)
			A2B:
				begin
					if(buffer1_wen)begin
						buffer_a1 <= data_in_a;
					end
					else if(buffer2_wen)begin
						buffer_a2 <= data_in_a;
					end
				end

			B2A:
				begin
					if(buffer1_wen)begin
						buffer_b1 <= data_in_b;
					end
					else if(buffer2_wen)begin
						buffer_b2 <= data_in_b;
					end
				end
			endcase
		end
	end

	always @(*)begin
		if(!rst_n)begin
			data_temp <= 16'd0;
		end
		if(mux_switch) begin  //disp the change of switch 
			case(switch)
				MUX_B2A:// 0 -> 1
					begin
						if(!buffer1_ren)begin
							data_temp <= buffer_a1;
						end
						else if(!buffer2_ren)begin
							data_temp <= buffer_a2;
						end
						else begin
							data_temp <= data_temp;
						end
					end

				MUX_A2B:// 1 -> 0
					begin
						if(!buffer1_ren)begin
							data_temp <= buffer_b1;
						end
						else if(!buffer2_ren)begin
							data_temp <= buffer_b2;
						end
						else begin
							data_temp <= data_temp;
						end						
					end
			endcase
		end 
	end

	assign	data_out_b = (mux_switch)?	data_temp : ((switch_r2)? data_out: 16'd0 ); //	assign	data_out_b = (mux_switch)?	data_temp : ((switch)? data_out: 16'd0 ); -->组合瞬时切换
	assign	data_out_a = (mux_switch)?	data_temp : ((switch_r2)? 16'd0 : data_out);

endmodule