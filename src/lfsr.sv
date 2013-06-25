module lfsr(clk, reset_n, data);

   input logic         clk;
   input logic         reset_n;
   output logic [31:0] data;


   /* Signaux internes */
   logic [31:0]   shifter;

   /* Polynome générateur : [32, 31, 28, 27, 24, 23, 20, 19, 18, 15, 12, 11, 8, 7, 3, 2] */
   parameter [31:0] polynome = 32'b10011001100111001001100110001101;

   /* Implémentation du LFSR par représentation de Galois (plus rapide) */
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       shifter <= 32'haf4532c1;
     else
       shifter <= {shifter[30:0], 1'b0} ^ (polynome & {32{shifter[31]}});

   assign  data = shifter;

endmodule
