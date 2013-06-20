module wall(input logic                clk,
            input logic signed [10:0] spotX,
            input logic signed [10:0] spotY,
            input logic signed [10:0] centerXW,
            input logic signed [10:0] centerYW,
            input logic [3:0]         sprite_num,
		    output logic [7:0]        wall_color  // code couleur (qui peut eventuellement etre
                                                       // un code de transparence
               );

   // taille de la partie active, fonction de la résolution
   localparam integer                    VACTIVE = 600;
   localparam integer                    HACTIVE = 800;

   // ROM qui contient les pixels du sprite (64x64 pixels)
   logic [31:0]  rom[0:32*32-1];
   logic [11:0]  rom_addr;
   logic [7:0]   color_pixel;

   always@(*)
     if (sprite_num <7)
     rom_addr <= spotX-centerXW + (spotY-centerYW)*32 + sprite_num*32*32;

   always @(posedge clk)
     color_pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/wall.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(posedge clk)
     begin
        wall_color <= {137};
        if ((spotX>=centerXW) && (spotX<(centerXW+32)) &&
            (spotY>=centerYW) && (spotY<(centerYW+32)))
	      wall_color <= color_pixel;
     end

endmodule // wall


























