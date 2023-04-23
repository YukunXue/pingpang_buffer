`timescale 1ns / 1ps

module pingpang_top(
    input [15:0] data_m_m2s,
    input [15:0] data_s_s2m,
    input clk,
    input rst_n,
    input switch,
    output [15:0] data_m_s2m,
    output [15:0] data_s_m2s
    );
    pingpong_buffer wr_channel(.rst_n(rst_n),
    .data_in(data_m_m2s),
    .clk(clk),
    .switch(switch),
    .data_out(data_s_m2s));
    pingpong_buffer rd_channel(.rst_n(rst_n),
    .data_in(data_s_s2m),
    .clk(clk),
    .switch(switch),
    .data_out(data_m_s2m));
endmodule