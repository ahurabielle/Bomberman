module gene_reset(clk, reset_n);
   input  clk;
   output reset_n;

   logic [15:0] count;

   always @(posedge clk)
     if(count != 16'hffff)
       count <= count +1;

   assign reset_n = count[15];

endmodule