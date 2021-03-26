//---------------------------------------------------------------------------------------------------------------------------------
//-- Author: postmaster@rtldev.com
//--
//-- Filename: 	SYNC_DEBOUNCE.sv
//--
//--
//-- Purpose:	Synchronizes a signal to the destination clock domain and debounces the signal for the desired period
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

module SYNC_DEBOUNCE #(parameter debounce_prd = 50)( 
    
    output        logic sync_sig_o,
    input   wire  logic raw_sig_i, dest_clk_i, dest_rst_i
    );

    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision

    logic temp_sig, sync_sig, count_en;
    int count;

    always_ff@ (posedge dest_clk_i) begin
        if (dest_rst_i) temp_sig <= '0;
        else            temp_sig <= sync_sig;
    end

    assign count_en = sync_sig ^ temp_sig;

    always_ff@ (posedge dest_clk_i) begin
        if (dest_rst_i) begin
                                                count       <= 0;
        end else begin  
            if (count_en)                       count       <= 0;
            else if (count == debounce_prd-4)   sync_sig_o  <= temp_sig;
            else                                count       <= count + 1;
        end
    end

    // Synchronizer 
    SYNC  #(.WIDTH(1), .PIPE_LENGTH(2)) CDC_SYNC (.dest_clk_i(dest_clk_i), .sig_i(raw_sig_i), .sync_sig_o(sync_sig));

endmodule

//`end_keywords