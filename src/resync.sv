module resync(input logic clk,
              input logic  in,
              output logic out);

   logic                   in1, in2, in3, in4;
   always @(posedge clk)
     begin
        in1 <= in;
        in2 <= in1;
        in3 <= in2;
        in4 <= in3;
        out <= in || in1 || in2 || in3 || in4;
     end


endmodule // resync
