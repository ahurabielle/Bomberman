module gene_reset(clk, in, reset_n);
   input logic  clk;
   input logic in;
   output logic reset_n;

   logic [15:0] count;

   initial
     count = 0;

   always @(posedge clk)
     if(~in)
       count <= 0;
     else if(count != 16'hffff)
       count <= count +1;

   assign reset_n = count[15];

endmodule