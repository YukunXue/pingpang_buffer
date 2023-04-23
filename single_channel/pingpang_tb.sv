`timescale 1ns / 1ps


module pingpang_tb(

    );
    logic clk,rst_n;
    logic [15:0] data_m_m2s; 
    logic [15:0] data_s_m2s;
    logic [15:0] data_m_s2m;
    logic [15:0] data_s_s2m;
    logic switch;
    initial begin 
        clk <= 1; 
    end
    always begin 
        #5 clk <= !clk; 
    end
    initial begin
        rst_n <= 0;
        #15 rst_n <= 1;
        #5 data_m_m2s <= 16'b0;
           switch <= 1;
        #10 data_s_s2m <= data_s_m2s+1;
            data_m_m2s <= data_m_m2s+10;
            switch <= 0;
        #10 switch <= 1;
        #10 data_s_s2m <= data_s_m2s+1;
            data_m_m2s <= data_m_m2s+10;
            switch <= 0;
        #10 switch <= 1;
        #10 data_s_s2m <= data_s_m2s+1;
            data_m_m2s <= data_m_m2s+10;
            switch <= 0;
        #10 switch <= 1;
        #10 data_s_s2m <= data_s_m2s+1;
            data_m_m2s <= data_m_m2s+10;
            switch <= 0;
        #10 switch <= 1;
    end
    pingpang_top pingpang_top1(.data_m_m2s(data_m_m2s),
    .data_s_s2m(data_s_s2m),
    .clk(clk),
    .rst_n(rst_n),
    .switch(switch),
    .data_m_s2m(data_m_s2m),
    .data_s_m2s(data_s_m2s));
endmodule
