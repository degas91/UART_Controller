//---------------------------------------------------------------------------------------------------------------------------------
//-- Author: postmaster@rtldev.com
//--
//-- Filename: RS_232_XMTR.sv
//--
//-- Project: UART transmitter
//--
//-- Purpose:	A UART transmitter
//-- 
//--
//--
//-- Licensing:  The MIT License (MIT)
//-- Copyright © 2020 
//-- Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
//-- documentation files (the “Software�?), to deal in the Software without restriction, including without limitation 
//-- the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
//-- and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//-- The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//-- THE SOFTWARE IS PROVIDED “AS IS�?, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
//-- THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
//-- TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------------------------------------------------------------

//`begin_keywords "1800_2012"
`resetall
`default_nettype none

module UART_XMTR #(parameter DATA_WIDTH = 8)(
    output      logic                  serial_o, busy_o,
    input  wire logic [DATA_WIDTH-1:0] xmit_data_i,
    input  wire logic                  start_tx_i, baud_i, clk_i, rst_i);

    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision
    import UART_pkg::*;


    uart_tx_e              state;
    logic [DATA_WIDTH+2:0] xmit_data;
    logic                  start_tx,baud_redg,start_tx_clr;
    int                    bit_count;

    // FSM to control the UART transmitter
    // Coded as a single always block FSM
    always_ff @(posedge clk_i) begin

        if (rst_i) begin
                                                                                                    state <= TX_IDLE;
            xmit_data       <= '0;
            start_tx_clr    <= '0;
            busy_o          <= '0;
        end else begin

                start_tx_clr    <= '0;

                case (state)
                    // wait for a start transmition pulse
                    TX_IDLE:   if (start_tx == 1)begin
                                                                                                    state <= TX_START;
                                bit_count <= 0;
                             end else                                                               state <= TX_IDLE; //@lb
                    // clear the start transmition latch
                    // capture the data to be sent over UART
                    // formulate the transmit word which consists
                    // of a start bit+ data word + 2x stop bit
                    TX_START: begin
                        start_tx_clr                            <= '1;
                        xmit_data [0]                           <= '0;                            // Start bit
                        xmit_data [DATA_WIDTH:1]                <= xmit_data_i;        // 8 bit data word        
                        xmit_data [DATA_WIDTH+2:DATA_WIDTH+1]   <= '1;    // 2 stop bits
                        busy_o    <= '1;       
                                                                                                    state <= TX_XMIT;  
                            end          
                    // Enable the UART transmition and set the busy signal
                    // Return to Idle after 11 bits are transmitted
                    // 1 start bit + 8 Data bits + 2 x stop bits
                    TX_XMIT:   if (bit_count == 11) begin
                                xmit_data <= '1;
                                busy_o    <= '0; 
                                                                                                    state <= TX_IDLE;
                            end else if (baud_redg) begin  
                                xmit_data <= {1'b1,xmit_data[DATA_WIDTH+2:1]};
                                bit_count <= bit_count+1;
                                                                                                    state <= TX_XMIT; //@lb
                            end
                    // Set the default values to X for easy
                    // debugging
                    default: begin
                                                                                                    state <= TX_XXX;
                        xmit_data       <= 'X;
                        start_tx_clr    <= 'X;
                        busy_o          <= 'X;
                    end       
                endcase
            end
    end
    // Rising edge detector to trigger the shift regster on the rising edge of 
    // the baud rate pulse
    EDGE_TO_PULSE  #(.PULSE_TYPE("redge")) baud_redg_detect(.pulse_o(baud_redg), .edge_i(baud_i), .clk_i(clk_i), .rst_i(rst_i));

    //Transmition start signal latch until the FSM clears it.
    always_ff @(posedge clk_i) begin

        if (rst_i) begin
            start_tx <= '0;
        end else begin
            if (start_tx_i)         start_tx <= '1;
            else if (start_tx_clr)  start_tx <= '0;
        end
        
    end

    assign serial_o = xmit_data [0];

endmodule

//`end_keywords