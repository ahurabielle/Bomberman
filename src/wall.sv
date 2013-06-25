module wall(input logic                clk,
            input logic signed [10:0] spotX,
            input logic signed [10:0] spotY,
            input logic [9:0]         wallX,
            input logic [9:0]         wallY,
            input logic [3:0]         sprite_num,
		    output logic [7:0]        wall_color
            );

   // wall_xxx a un coup de retard par rapport à spotX. Il faut donc retarder
   // aussi spotX d'un coup d'horloge.
   logic signed [10:0]                spotX_r;
   always @(posedge clk)
     spotX_r <= spotX;

   // ROM qui contient les pixels des 12 sprites (64x64 pixels)
   logic [7:0]  rom[0:13*1024-1];
   logic [13:0]  rom_addr;
   logic [7:0]   color_pixel;
   logic [4:0]   offsetX, offsetY;

   assign offsetX = spotX_r-wallX;
   assign offsetY = spotY-wallY;
   assign rom_addr = {sprite_num, offsetY, offsetX};

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(posedge clk)
        if ((spotX_r>=wallX) && (spotX_r<(wallX+32)) &&
            (spotY>=wallY) && (spotY<(wallY+32)))
          wall_color <= rom[rom_addr];
        else
          wall_color <= 8'd137;

   initial
     $readmemh("../sprites/wall.lst", rom);

endmodule // wall


























