/*-------------------------------------------------------------------------------------------------------------------------------
 Author: postmaster@rtldev.com

 Filename: UART_pkg.sv

 Project: UART package

 Purpose: Package for the UART controller, all state machine enumarated types are Gray coded 
 


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

package UART_pkg;

    timeunit 1ns; // delays in nanoseconds
    timeprecision 1ps; // 3 decimal places of precision

    typedef enum logic [2:0]    {RX_IDLE    = 3'b000,
                                RX_START    = 3'b001,
                                RX_READ     = 3'b011,
                                RX_STOP     = 3'b010,
                                RX_STOP2    = 3'b110,
                                RX_ERROR    = 3'b111,
                                RX_EOM      = 3'b101,
                                RX_XXX      = 3'bXXX } uart_rx_e;

    typedef enum logic [1:0]    {TX_IDLE    = 2'b00,
                                TX_START    = 2'b01,
                                TX_XMIT     = 2'b11,
                                TX_XXX      = 2'bXX } uart_tx_e;

endpackage //UART_pkg
