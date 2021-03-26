
/*-------------------------------------------------------------------------------------------------------------------------------
 Author: postmaster@rtldev.com

 Filename: UART_TOP.sv

 Project: UART Controller

 Purpose: Top level module
 The followeing are some common UART baude rates and their respective ACC_SIZE and FCW paramerters
╔====================================╗
║ Baude Rate    │ ACC_SIZE │ FCW     ║
╠====================================╣
║ 1200 bits/s   │ 32       │ 103080  ║
╟───────────────┼──────────┼─────────╢
║ 9600 bits/s   │ 32       │ 824634  ║
╟───────────────┼──────────┼─────────╢
║ 38400 bits/s  │ 32       │ 3298536 ║
╟───────────────┼──────────┼─────────╢
║ 115200 bits/s │ 32       │ 9895605 ║
╚=====================================
 Licensing:  The MIT License (MIT)
 Copyright © 2021 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
 documentation files (the “Software�?), to deal in the Software without restriction, including without limitation 
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
 and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED “AS IS�?, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
 THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
------------------------------------------------------------------------------------------------------------------------------------ */

//`begin_keywords "1800_2012"
`resetall
`default_nettype none

module UART_TOP #(parameter DATA_WIDTH = 8, ACC_SIZE = 32, FCW = 9895605)(

    output      logic                           data_rdy_o, data_err_o, serial_o, busy_o,
    output      logic       [DATA_WIDTH-1:0]    rcvr_data_o,   
    input  wire logic                       serial_i, start_tx_i, clk_i, rst_i, data_rdy_clr_i, data_err_clr_i, 
    input  wire logic   [DATA_WIDTH-1:0]    xmit_data_i  
);
    
    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision
    
    logic baud_clk, serial_sync;

    UART_RCVR       #(.DATA_WIDTH(DATA_WIDTH))          RCVR (.data_rdy_o(data_rdy_o) , .data_err_o(data_err_o), .rcvr_data_o(rcvr_data_o) , .baud_i(baud_clk), .serial_i(serial_sync), .data_err_clr_i(data_err_clr_i), .data_rdy_clr_i(data_rdy_clr_i), .clk_i(clk_i), .rst_i(rst_i));
    UART_XMTR       #(.DATA_WIDTH(DATA_WIDTH))          XMTR (.xmit_data_i(xmit_data_i) , .start_tx_i(start_tx_i), .baud_i(baud_clk), .clk_i(clk_i), .rst_i(rst_i), .busy_o(busy_o) , .serial_o(serial_o));
    SYNC_DEBOUNCE   #(.debounce_prd(50))                SERIAL_I_DEBOUNCE (.sync_sig_o(serial_sync), .raw_sig_i(serial_i), .dest_clk_i(clk_i), .dest_rst_i(rst_i));
    (* use_dsp ="yes" *) ACC_CLK_GEN     #(.ACC_SIZE(ACC_SIZE), .FCW (FCW))  BAUD_GEN (.clk_o(baud_clk), .clk_i(clk_i), .rst_i(rst_i));

endmodule

//`end_keywords