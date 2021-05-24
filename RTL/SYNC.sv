/*-------------------------------------------------------------------------------------------------------------------------------
 Author: postmaster@rtldev.com

 Filename: SYNC.sv


 Purpose:	Synchronizes a signal or bus from the source to destination clock domain

 Licensing:  The MIT License (MIT)
 Copyright © 2020 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated 
 documentation files (the “Software"), to deal in the Software without restriction, including without limitation 
 the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
 and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 THE SOFTWARE IS PROVIDED “AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
 THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
 TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
----------------------------------------------------------------------------------------------------------------------------------*/

`resetall
`default_nettype none

module SYNC 
    #(parameter int WIDTH = 1, 
                int PIPE_LENGTH = 2
    )
    (   output       logic   [WIDTH-1:0] sync_sig_o,
        input  wire  logic   [WIDTH-1:0] sig_i,
        input  wire  logic               dest_clk_i
    );

    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision

    logic [PIPE_LENGTH-1:0] sync_sig;

    generate

        for ( genvar i = 0 ; i<WIDTH ; i++ ) begin
            
            always_ff @(posedge dest_clk_i) begin
                sync_sig <= {sync_sig,sig_i[i]};
            end
            
            assign sync_sig_o[i] = sync_sig[PIPE_LENGTH-1];
        end

    endgenerate

endmodule //SYNC

