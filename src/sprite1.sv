module sprite1(input logic                clk,
               input logic signed [10:0] spotX,
               input logic signed [10:0] spotY,
		       input logic signed [10:0] centerX, // centre du cercle en X
		       input logic signed [10:0] centerY, // centre du cerlce en Y
               output logic [31:0]       spr1_rgba  // composantes couleurs
               );

   // taille de la partie active, fonction de la résolution
   localparam integer                    VACTIVE = 600;
   localparam integer                    HACTIVE = 800;
   localparam integer                    R       = 50;

   // ROM qui contient les pixels du sprite (64x64 pixels)
   logic [31:0]  rom[0:64*64-1];
   logic [11:0]  rom_addr;
   logic [31:0]  pixel;

   always@(*)
     rom_addr <= spotX-centerX + (spotY-centerY)*64;

   always @(posedge clk)
     pixel <= rom[rom_addr];

   initial
     $readmemh("../sprites/sprite1.lst", rom);

   // création de cercle blanc sur fond noir
   always @(posedge clk)
     begin
        spr1_rgba <= {8'd0, 8'd0, 8'd0, 8'd255};

        if ((spotX>=centerX) && (spotX<(centerX+64)) &&
            (spotY>=centerY) && (spotY<(centerY+64)))
	      spr1_rgba <= pixel;
     end

endmodule // sprite1


























