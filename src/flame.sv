module flame(input logic                clk,
             input logic signed [10:0] spotX,
             input logic signed [10:0] spotY,
             input logic signed [10:0] centerXF,
             input logic signed [10:0] centerYF,
             input logic [1:0]         sprite_num,
		     output logic [7:0]        flame_color     // code couleur (qui peut eventuellement etre
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
     rom_addr <= ((spotX-centerXF) + ((spotY-centerYF)*32) + (sprite_num*32*32));

   always @(posedge clk)
     color_pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/flame.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(posedge clk)
     begin
        flame_color <= 8'd137;
        if ((spotX>=centerXF) && (spotX<(centerXF+32)) &&
            (spotY>=centerYF) && (spotY<(centerYF+32)))
	      flame_color <= color_pixel;
     end

endmodule // flame


























