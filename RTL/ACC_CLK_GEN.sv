/*-------------------------------------------------------------------------------------------------------------------------------
 Author: postmaster@rtldev.com

 Filename: 	ACC_CLK_GEN.sv

 Project:	Custom CLock Generator

 Purpose:	This is a custom clock generator based on the binary phase accumulator theory
 The clock is generated from the overflow of an accumulator by adding a fixed 
 integer every clock cycle, the frequency control word (FCW). The FCW is equal to
 FCW = 2*(Fout *2^N /Fclock) where Fout is the desired frequency in Hz, N is the accumulator
 size, and Fclock is the system clock frequency in Hz. The resolution of such clock generator
 is computed as follows : Fres = Fclock/2^N . The bigger the accumulator the more precise the
 clock generator gets. 
 In order to use the clock generator coded below the user needs to set the two generics 
 ACC_SIZE which is N from the equation above and FCW. The user is advised to vary the accumulator size
 until an FCW is obtained that is very close to a whole integer ( ie 3.99 vs 3.45) for the most accurate frequency output.

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
------------------------------------------------------------------------------------------------------------------------------------*/

`resetall
`default_nettype none

module ACC_CLK_GEN 
    #(parameter int ACC_SIZE = 12, 
                int FCW = 59
    ) 
    (   output      logic clk_o, 
        input  wire logic clk_i, rst_i
    );
    
    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision

    logic [ACC_SIZE : 0] acc_reg; 

    //Generate the baude rate based on accumulator overflow
    always_ff @(posedge clk_i) begin 
        if (rst_i) begin
             acc_reg <= '0;
        end
        else begin      
            acc_reg <= acc_reg [ACC_SIZE-1:0] + FCW;
        end
    end

    always_ff @(posedge clk_i) begin
            if (rst_i) begin
                 clk_o <= '0;
            end
            else if (acc_reg[ACC_SIZE]) begin
                clk_o <= ~clk_o;
            end
    end
endmodule //ACC_CLK_GEN

