module mixer(input  logic        active,            // correspond au blank
             input  logic [7:0]  bck_r,            // composantes rouges
             input  logic [7:0]  bck_g,            // composantes vertes
             input  logic [7:0]  bck_b,            // composantes bleues
	     input  logic [31:0] spr1_rgba,          // composantes rouges bleues vertes et d'opacité du sprite1
             output logic [9:0]  vga_r,             // sortie rouge
             output logic [9:0]  vga_g,             // sortie verte
             output logic [9:0]  vga_b);            // sortie bleue

   // Vérifie qu'on est dans la zone active, sinon, c'est noir
   always @(*)
     if(active)
       begin
              // on sait alors qu'on est dans le cercle blanc, donc on affiche le background2
	      if(spr1_rgba[7:0] !=0)
	        begin
               vga_r <= {bck_r, bck_r[0], bck_r[0]};
               vga_g <= {bck_g, bck_g[0], bck_g[0]};
               vga_b <= {bck_b, bck_b[0], bck_b[0]};
	        end
	      else
	       {vga_r, vga_g, vga_b} <= spr1_rgba[31:8];
       end
     else                                     // on affiche l'autre background (sprite 1)
       {vga_r,vga_b,vga_g} <= 0;

endmodule
