module mixer(input logic        blank,
             input logic  [7:0] bck_r,
             input logic  [7:0] bck_g,
             input logic  [7:0] bck_b,
             output logic [9:0] vga_r,
             output logic [9:0] vga_g,
             output logic [9:0] vga_b);

   // Vérifie qu'on est dans la zone active, sinon, c'est noir
   always @(*)
     if(blank)
       begin
          vga_r <= {bck_r,bck_r[0]*4};
          vga_b <= {bck_b,bck_b[0]*4};
          vga_g <= {bck_g,bck_g[0]*4};
       end
     else
       {vga_r,vga_b,vga_g} <= 0;

endmodule