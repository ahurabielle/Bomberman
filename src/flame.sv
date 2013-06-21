module flame(input logic                clk,
             input logic signed [10:0] spotX,
             input logic signed [10:0] spotY,
             input logic [9:0]         flame_centerX,
             input logic [9:0]         flame_centerY,
             input logic [2:0]         sprite_num,
		     output logic [7:0]        flame_color
             );

   // taille de la partie active, fonction de la résolution
   localparam integer                  VACTIVE = 600;
   localparam integer                  HACTIVE = 800;

   // ROM qui contient les pixels des 5 sprite (64x64 pixels) (3 sprites)
   logic [7:0]                         rom[0:5*1024-1];
   logic [12:0]                        rom_addr;
   logic [7:0]                         color_pixel;

   always@(*)
     rom_addr <= ((spotX-flame_centerX) + ((spotY-flame_centerY)*32) + (sprite_num*32*32));

   always @(posedge clk)
     color_pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/flame.lst", rom);

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


























