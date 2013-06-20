module mixer(input logic        active,            // correspond au blank
             input logic [23:0] bck_rgb, // composantes rouges vertes et bleues du fond
	         input logic [31:0] spr1_rgba, // composantes rouges bleues vertes et d'opacité du sprite1
             input logic [7:0]  player1_color,
             input logic [7:0]  player2_color,
             input logic [7:0]  wall_color,
             input logic [7:0]  flame_color,
             output logic [9:0] vga_r, // sortie rouge
             output logic [9:0] vga_g, // sortie verte
             output logic [9:0] vga_b);            // sortie bleue



   // Définition de la rom
   logic [31:0]                 rom[0:23];

   // Chargement de la pallette
   initial
     $readmemh("../sprites/palette.lst",rom);

       // Vérifie qu'on est dans la zone active, sinon, c'est noir
       always @(*)
         if(active)
           begin
              // De base on affiche le background
              {vga_r, vga_g, vga_b} <= {bck_rgb[23:16], bck_rgb[16],bck_rgb[16] ,
                                        bck_rgb[15:8], bck_rgb[8] ,  bck_rgb[8],
                                        bck_rgb[7:0],  bck_rgb[0],  bck_rgb[0]};
              // Si on a des flammes alors on les met par dessus tout
	          if(~(flame_color == 8'd137))
	            begin
                   {vga_r, vga_g, vga_b} <= {rom[flame_color][23:16], rom[flame_color][16],rom[flame_color][16] ,
                                             rom[flame_color][15:8], rom[flame_color][8] ,  rom[flame_color][8],
                                             rom[flame_color][7:0],  rom[flame_color][0],  rom[flame_color][0]};
	            end
              // le joueur 1 vient ensuite dans la hiérarchie
	          else if(~(player1_color == 8'd137))
	            begin
                   {vga_r, vga_g, vga_b} <= {rom[player1_color][23:16], rom[player1_color][16],rom[player1_color][16] ,
                                             rom[player1_color][15:8], rom[player1_color][8] ,  rom[player1_color][8],
                                             rom[player1_color][7:0],  rom[player1_color][0],  rom[player1_color][0]};
	            end
              else if(~(player2_color == 8'd137))
	            begin
                   {vga_r, vga_g, vga_b} <= {rom[player2_color][23:16], rom[player2_color][16],rom[player2_color][16] ,
                                             rom[player2_color][15:8], rom[player2_color][8] ,  rom[player2_color][8],
                                             rom[player2_color][7:0],  rom[player2_color][0],  rom[player2_color][0]};
	            end
              else if(~(wall_color == 8'd137))
	            begin
                   {vga_r, vga_g, vga_b} <= {rom[wall_color][23:16], rom[wall_color][16],rom[wall_color][16] ,
                                             rom[wall_color][15:8], rom[wall_color][8] ,  rom[wall_color][8],
                                             rom[wall_color][7:0],  rom[wall_color][0],  rom[wall_color][0]};
	            end
           end
         else                                     // on affiche l'autre background (sprite 1)
           {vga_r,vga_b,vga_g} <= 0;

endmodule
