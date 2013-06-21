module wall(input logic                clk,
            input logic signed [10:0] spotX,
            input logic signed [10:0] spotY,
            input logic [9:0]         wall_centerX,
            input logic [9:0]         wall_centerY,
            input logic [3:0]         sprite_num,
		    output logic [7:0]        wall_color
            );

   // wall_xxx a un coup de retard par rapport à spotX. Il faut donc retarder
   // aussi spotX d'un coup d'horloge.
   logic signed [10:0]                spotX_r;
   always @(posedge clk)
     spotX_r <= spotX;

   // ROM qui contient les pixels des 12 sprites (64x64 pixels)
   logic [7:0]  rom[0:12*1024-1];
   logic [13:0]  rom_addr;
   logic [7:0]   color_pixel;
   logic [4:0]   offsetX, offsetY;

   assign offsetX = spotX_r-wall_centerX;
   assign offsetY = spotY-wall_centerY;
   assign rom_addr = {sprite_num, offsetY, offsetX};

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
        if ((spotX_r>wall_centerX) && (spotX_r<=(wall_centerX+32)) &&
            (spotY>=wall_centerY) && (spotY<(wall_centerY+32)))
	      wall_color <= color_pixel;
     end

endmodule // wall


























