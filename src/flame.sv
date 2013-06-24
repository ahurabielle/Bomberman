module flame(input logic                clk,
             input logic signed [10:0] spotX,
             input logic signed [10:0] spotY,
             input logic [9:0]         flame_centerX,
             input logic [9:0]         flame_centerY,
             input logic [2:0]         sprite_num,
		     output logic [7:0]        flame_color
             );

   // ROM qui contient les pixels des 5 sprite (64x64 pixels) (3 sprites)
   logic [7:0]                         rom[0:5*1024-1];
   logic [12:0]                        rom_addr;
   logic [7:0]                         color_pixel;
   logic [4:0]                         offsetX, offsetY;

   assign offsetX = spotX - flame_centerX+1;
   assign offsetY = spotY - flame_centerY;
   assign rom_addr = {sprite_num, offsetY, offsetX};

   always @(posedge clk)
     color_pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/flames.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(*)
                 begin
                    flame_color <= 8'd137;
                    if ((spotX >= flame_centerX) && (spotX < (flame_centerX + 32)) &&
                        (spotY >= flame_centerY) && (spotY < (flame_centerY + 32)))
	                  flame_color <= color_pixel;
                 end

endmodule // flame


























