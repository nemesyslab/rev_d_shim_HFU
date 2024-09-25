`timescale 1ns / 1ps


module AND_gate(
    input   wire    a,
    input   wire    b,
    output  wire    and_out
);
    
    assign and_out = a & b;
    
endmodule
