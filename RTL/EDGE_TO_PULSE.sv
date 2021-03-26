//---------------------------------------------------------------------------------------------------------------------------------
//-- Author: postmaster@rtldev.com
//--
//-- Filename: EDGE_TO_PULSE.sv
//--
//--
//-- Purpose:	A combination of rising edge and falling edge detectors. Each function is instantiated based on the paramter passed
//-- during instantiation of the module. It defaults to a rising edge detector.
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

module EDGE_TO_PULSE #(parameter PULSE_TYPE = "redge")(
    output      logic pulse_o,
    input  wire logic edge_i, clk_i, rst_i
);

    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision

    logic ff_out;

    // Rising edge detector
    generate if (PULSE_TYPE == "redge") begin
                
                always @(posedge clk_i) begin
                    if (rst_i == 1) begin
                        ff_out <= '0;
                    end
                    else begin
                        ff_out <= edge_i;
                    end
                end
            assign pulse_o = edge_i && (~ff_out);
            end
            // Falling edge detector
            else if (PULSE_TYPE == "fedge") begin
                always @(posedge clk_i) begin
                    if (rst_i == 1) begin
                        ff_out <= '0;
                    end
                    else begin
                        ff_out <= edge_i;
                    end
                end
            assign pulse_o = (~edge_i) && (ff_out);
            end    
    endgenerate

endmodule

//`end_keywords