module player1(input logic                clk,
               input logic signed [10:0] spotX,
               input logic signed [10:0] spotY,
               input logic [9:0]         player1_centerX,
               input logic [9:0]         player1_centerY,
               input logic [2:0]         sprite_num,
		       output logic [7:0]        player1_color
               );

   // ROM qui contient les pixels des 7 sprites (64x64 pixels)
   logic [7:0]                           rom[0:7*1024-1];
   logic [12:0]                          rom_addr;
   logic [7:0]                           color_pixel;
   logic [4:0]                           offsetX, offsetY;

   assign offsetX = spotX-wall_centerX;
   assign offsetY = spotY-wall_centerY;
   assign rom_addr = {sprite_num, offsetY, offsetX};

   always @(posedge clk)
     color_pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/player1.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(*)
     begin
        player1_color <= 8'd137;
        if ((spotX>=player1_centerX) && (spotX<(player1_centerX+32)) &&
            (spotY>=player1_centerY) && (spotY<(player1_centerY+32)))
	      player1_color <= color_pixel;
     end

endmodule // player1


























