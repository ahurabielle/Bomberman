module wall(input logic                clk,
            input logic signed [10:0] spotX,
            input logic signed [10:0] spotY,
            input logic [9:0]         wall_centerX,
            input logic [9:0]         wall_centerY,
            input logic [3:0]         sprite_num,
		    output logic [7:0]        wall_color  // code couleur (qui peut eventuellement etre
                                                       // un code de transparence
               );

   // ROM qui contient les pixels des 12 sprites (64x64 pixels)
   logic [7:0]  rom[0:12*1024-1];
   logic [13:0]  rom_addr;
   logic [7:0]   color_pixel;
   logic [4:0]   offsetX, offsetY;

   assign offsetX = spotX-wall_centerX;
   assign offsetY = spotY-wall_centerY;
   // warning : sprite_num nul == PAS DE SPRITE À AFFICHER
   assign rom_addr = {sprite_num-1, offsetY, offsetX};

   always @(posedge clk)
     color_pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/wall.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite et que ce n'est du vide qu'on est en train
   // d'afficher
   always @(*)
     begin
        wall_color <= 8'd137;
        if ((spotX>=wall_centerX) && (spotX<(wall_centerX+32)) &&
            (spotY>=wall_centerY) && (spotY<(wall_centerY+32)) &&
            (sprite_num != 0))
	      wall_color <= color_pixel;
     end

endmodule // wall


























