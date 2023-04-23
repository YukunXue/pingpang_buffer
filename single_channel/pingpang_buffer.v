`timescale 1ns / 1ps

module pingpang_buffer(
    input rst_n,
    input[15:0] data_in,
    input clk,
    input switch,
    output [15:0] data_out
    );
    reg  [15:0] buffer_a;
    reg  [15:0] buffer_b;
    reg buffer_sel;  //为0时，buffer_a为输入buffer
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            buffer_sel <= 0;
        else if(switch)
            buffer_sel <= !buffer_sel;
    end
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            buffer_a <= 16'b0;
        else if(!buffer_sel)
            buffer_a <= data_in;
    end
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            buffer_a <= 16'b0;
        else if(buffer_sel)
            buffer_b <= data_in;
    end
    assign data_out = buffer_sel?buffer_a:buffer_b;
endmodule