module mixer(input  logic        active,            // correspond au blank
             input  logic [23:0]  bck_rgb,            // composantes rouges vertes et bleues du fond
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
               {vga_r, vga_g, vga_b} <= {bck_rgb[23:16], bck_rgb[16], bck_rgb[16],
                                         bck_rgb[15:8], bck_rgb[8], bck_rgb[8],
                                         bck_rgb[7:0], bck_rgb[0], bck_rgb[0]};
	        end
	      else
	       {vga_r, vga_g, vga_b} <= {spr1_rgba[31:24], spr1_rgba[24], spr1_rgba[24],
                                     spr1_rgba[23:16], spr1_rgba[16], spr1_rgba[16],
                                     spr1_rgba[15:8], spr1_rgba[8], spr1_rgba[8]};
       end
     else                                     // on affiche l'autre background (sprite 1)
       {vga_r,vga_b,vga_g} <= 0;

endmodule
