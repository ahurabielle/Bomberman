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

   // création de cercle blanc sur fond noir
   always @(posedge clk)
     begin
        spr1_rgba <= {8'd0, 8'd0, 8'd0, 8'd255};

        if ((spotX - centerX)*(spotX -centerX) + (spotY - centerY)*(spotY - centerY) < (R*R))
	      begin
	         spr1_rgba <= {8'd255, 8'd255, 8'd255, 8'd0};
	      end

     end

endmodule // sprite1


























