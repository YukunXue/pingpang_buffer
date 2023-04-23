`timescale 1ns / 1ps

module pingpang_ram(

    
    input rst_n,
    input[15:0] data_in,
    input clk,
    input wr,
    input switch,
    input [2:0] addr_wr,
    input [2:0] addr_rd,
    output [15:0] data_out
    );
    reg  [15:0] buffer_a [2:0];
    reg  [15:0] buffer_b [2:0];
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
        else if(wr && !buffer_sel)
            buffer_a[addr_wr] <= data_in;
    end
    always@(posedge clk or negedge rst_n) begin
        if(!rst_n)
            buffer_a <= 16'b0;
        else if(wr && buffer_sel)
            buffer_b[addr_wr] <= data_in;
    end
    assign data_out = buffer_sel?buffer_a[addr_rd]:buffer_b[addr_rd];
endmodule