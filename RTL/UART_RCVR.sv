//---------------------------------------------------------------------------------------------------------------------------------
//-- Author: postmaster@rtldev.com
//--
//-- Filename: UART_RCVR.sv
//--
//-- Project: UART receiver
//--
//-- Purpose:	A UART receiver
//-- The UART Receiver module is an asynchronous receiver that samples the input data in a 8 bit shift register which forms 
//-- the input message. The receiver oversamples the input data bus until a ready bit is detected. Then transitions at the agreed upon 
//-- baud rate. The receiver samples the input serial data at the falling edge of the baud rate to give ample time for the data to be 
//-- valid. Once 8 bits are sampled at the desired baud rate, the receiver samples the stop bit. If a stop bit is not detected an error 
//-- is generated to state that the data is not valid.
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

module UART_RCVR #(parameter DATA_WIDTH = 8) (
    output      logic                    data_rdy_o, data_err_o,
    output      logic [DATA_WIDTH-1 : 0] rcvr_data_o,
    input  wire logic                    baud_i, serial_i, data_err_clr_i, data_rdy_clr_i, clk_i, rst_i);

    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision
    import UART_pkg::*;

    uart_rx_e                   state, next; // enumerated type state machine variable
    logic   [DATA_WIDTH-1 : 0]  shift_reg;
    logic                       m_data_rdy,m_data_err; //combination signals
    logic                       baud_fedg,data_rdy,data_err;
    int                         bit_count;

    // 4 always block state machine to control the behaviour of the UART Receiver
    
    // Registering of the state assignment
    always_ff @(posedge clk_i) begin
        if (rst_i) state <= RX_IDLE;
        else       state <= next;
    end
    
    // Combinatorial block for states assignements
    always_comb begin
                                                                        next = RX_XXX;
        case (state)
            RX_IDLE:   if (!baud_i && !serial_i)                        next = RX_START;  
                    else                                                next = RX_IDLE;  
            RX_START:  if (baud_i)                                      next = RX_READ;    
                    else                                                next = RX_START;
            RX_READ:   if (bit_count  == DATA_WIDTH && baud_i)          next = RX_STOP;   
                    else                                                next = RX_READ;
            RX_STOP:   if (!serial_i && !baud_i)                        next = RX_ERROR;  
                    else if (serial_i && !baud_i)                       next = RX_STOP2;
                    else                                                next = RX_STOP;
            RX_STOP2:   if (!serial_i && baud_i)                        next = RX_ERROR;  
                    else if (serial_i && baud_i)                        next = RX_EOM;
                    else                                                next = RX_STOP2;
            RX_ERROR:                                                   next = RX_EOM;
            RX_EOM:                                                     next = RX_IDLE;
            default:                                                    next = RX_XXX;
        endcase
    end
    
    // Combinatorial block for signal assignments
    always_comb begin
                        {m_data_err,m_data_rdy} = '0;
        case (state)
            RX_IDLE:    ;
            RX_START:   ;
            RX_READ:    ;
            RX_STOP:    ;
            RX_STOP2:   ;
            RX_ERROR:               m_data_err  = '1;
            RX_EOM:                 m_data_rdy  = '1;
            default:    {m_data_err,m_data_rdy} = 'x; 
        endcase
    end

    always_ff @(posedge clk_i) begin
        if (rst_i) begin
                        data_rdy    <= '0;
                        data_err    <= '0;
        end else begin
                        data_rdy    <= m_data_rdy;
                        data_err    <= m_data_err;
        end
    end

    // Shift Register used to shift the serial data
    // The shift register is enabled by being in state READ and
    // by the falling edge of baud_i. 

    always_ff @(posedge clk_i) begin
       if (rst_i) begin
                                                    shift_reg <= '0;
                                                    bit_count <= '0;
       end else begin
            if (baud_fedg && (state == RX_READ)) begin
                                                    shift_reg <= {serial_i, shift_reg[DATA_WIDTH-1:1]};
                                                    bit_count <= bit_count+1;
            end else if (state == RX_IDLE) begin
                                                    bit_count <= '0;
            end  
       end
    end

    // Latches data ready and clears it once the external logic
    // asserts the clear
    // It updates the output data regs with the latest word from the
    // shift register
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
                                                data_rdy_o  <= '0;
                                                rcvr_data_o <= '0;
        end else begin
            if (data_rdy == 1) begin
                                                data_rdy_o  <= '1; 
                                                rcvr_data_o <= shift_reg;  
            end else if (data_rdy_clr_i == 1)   data_rdy_o  <= '0;
        end
    end

    // Latches data error and clears it once the external logic
    // asserts the error clear
    always_ff @(posedge clk_i) begin
        if (rst_i) begin
                                            data_err_o <= '0;
        end else begin
            if (data_err == 1)              data_err_o <= '1;
            else if (data_err_clr_i == 1)   data_err_o <= '0;
        end
    end

    // Falling edge detector to enable the shift register on the falling edge of BAUD_I
    EDGE_TO_PULSE  #(.PULSE_TYPE("fedge")) NEGEDGE_DTCT (.pulse_o(baud_fedg), .edge_i(baud_i), .clk_i(clk_i), .rst_i(rst_i));

endmodule

//`end_keywords