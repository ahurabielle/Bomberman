
module joueur1(input logic                clk,
               input logic signed [10:0] spotX,
               input logic signed [10:0] spotY,
               input logic [9:0]         centerX,
               input logic [9:0]         centerY,
               input logic [3:0]         sprite_num,
		       output logic [31:0]       joueur1_  // composantes couleurs
               );

   // taille de la partie active, fonction de la résolution
   localparam integer                    VACTIVE = 600;
   localparam integer                    HACTIVE = 800;

   // ROM qui contient les pixels du sprite (64x64 pixels)
   logic [31:0]  rom[0:32*32-1];
   logic [11:0]  rom_addr;
   logic [31:0]  pixel;

   always@(*)
     rom_addr <= spotX-centerX + (spotY-centerY)*32 + sprite_num*32*32;

   always @(posedge clk)
     pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/flammes.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(posedge clk)
     begin
        spr1_rgba <= {8'd0, 8'd0, 8'd0, 8'd255};
        if ((spotX>=centerX) && (spotX<(centerX+32)) &&
            (spotY>=centerY) && (spotY<(centerY+32)))
	      spr1_rgba <= pixel;
     end

endmodule // sprite1


























