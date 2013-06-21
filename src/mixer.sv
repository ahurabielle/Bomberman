module mixer(input              clk,
             // correspond au blank
             input logic        active,
             // composantes rouges vertes et bleues du fond
             input logic [23:0] bck_rgb,
             // composantes rouges bleues vertes et d'opacité des sprites
	         input logic [31:0] spr1_rgba,
             input logic [7:0]  player1_color,
             input logic [7:0]  player2_color,
             input logic [7:0]  wall_color,
             input logic [7:0]  flame_color,
             output logic [9:0] vga_r,
             output logic [9:0] vga_g,
             output logic [9:0] vga_b
             );



   // Définition de la rom
   logic [23:0]                 rom[0:255];
   logic [7:0]                  rom_addr;
   logic [23:0]                 pixel;
   // Chargement de la pallette
   initial
     $readmemh("../sprites/palette.lst",rom);

   always @(posedge clk)
     pixel <= rom[rom_addr+1]     ;

   // Vérifie qu'on est dans la zone active, sinon, c'est noir
   always @(*)
     begin
        rom_addr <= 8'd137;
        // Si on a des flammes alors on les met par dessus tout
	    if(~(flame_color == 8'd137))
          rom_addr <= flame_color;
        // le joueur 1 vient ensuite dans la hiérarchie
	    else if(~(player1_color == 8'd137))
          rom_addr <= player1_color;
        else if(~(player2_color == 8'd137))
          rom_addr <= player2_color;
        else if(~(wall_color == 8'd137))
          rom_addr <= wall_color;
     end


   // Génération du pixel de sortie
   always_comb
     if(active)
       begin
          // De base on affiche le background
          {vga_r, vga_g, vga_b} <= {bck_rgb[23:16], bck_rgb[16],bck_rgb[16] ,
                                    bck_rgb[15:8], bck_rgb[8] ,  bck_rgb[8],
                                    bck_rgb[7:0],  bck_rgb[0],  bck_rgb[0]};

          if (rom_addr != 137)
            {vga_r, vga_g, vga_b} <=  {pixel[23:16], pixel[16],pixel[16] ,
                                       pixel[15:8], pixel[8] ,  pixel[8],
                                       pixel[7:0],  pixel[0],  pixel[0]};
       end // if (active)
     else
       {vga_r, vga_g, vga_b} <= 0;


endmodule




