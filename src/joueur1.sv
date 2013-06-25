module joueur1(input logic                clk,
               input logic signed [10:0] spotX,
               input logic signed [10:0] spotY,
               input logic signed [10:0] centerX,
               input logic signed [10:0] centerY,
               input logic [3:0]         sprite_num,
		       output logic [7:0]       joueur1_color  // code couleur (qui peut eventuellement etre
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
     rom_addr <= spotX-centerX + (spotY-centerY)*32 + sprite_num*32*32;

   always @(posedge clk)
     pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/persos.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(posedge clk)
     begin
        spr1_rgba <= {137};
        if ((spotX>=centerX) && (spotX<(centerX+32)) &&
            (spotY>=centerY) && (spotY<(centerY+32)))
	      joueur1_color <= color_pixel;
     end

endmodule // sprite1


























