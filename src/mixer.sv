module mixer(input  logic        active,            // correspond au blank
             input  logic [7:0]  bck_r1, bck_r2,    // composantes rouges
             input  logic [7:0]  bck_g1, bck_g2,    // composantes vertes
             input  logic [7:0]  bck_b1, bck_b2,    // composantes bleues
             output logic [9:0]  vga_r,             // sortie rouge
             output logic [9:0]  vga_g,             // sortie verte
             output logic [9:0]  vga_b);            // sortie bleue

   // Vérifie qu'on est dans la zone active, sinon, c'est noir
   always @(*)
     if(active)
       begin
	      if(bck_r2 !=0)                         // on sait alors qu'on est dans le cercle blanc, donc on affiche le background2
	        begin
               vga_r <= {bck_r2, bck_r2[0], bck_r2[0]};
               vga_g <= {bck_g2, bck_g2[0], bck_g2[0]};
               vga_b <= {bck_b2, bck_b2[0], bck_b2[0]};
	        end
	      else
	        begin
	           vga_r <= {bck_r1, bck_r1[0], bck_r1[0]};
               vga_g <= {bck_g1, bck_g1[0], bck_g1[0]};
               vga_b <= {bck_b1, bck_b1[0], bck_b1[0]};
	        end // else: !if(bck_r2 !=0)
       end
     else                                     // on affiche l'autre background (sprite 1)
       {vga_r,vga_b,vga_g} <= 0;

endmodule