module background(input logic clk,
	              input logic signed [10:0] spotX,
                  input logic [7:0]              bck_r, bck_g, bck_b,
                  // composantes couleurs du fond
                  output logic [23:0]       bck_rgb
                  );

   // taille de la partie active, fonction de la résolution
   localparam integer                       HACTIVE = 800;

   // Création du fond en dégradé
   always @(posedge clk)
     begin
	    bck_rgb  <= 0;
	    if(spotX < HACTIVE)
	      bck_rgb[23:16] <= bck_r - ((HACTIVE - spotX)/4);
	      bck_rgb[15:8] <= bck_g - ((HACTIVE - spotX)/4);
	      bck_rgb[7:0] <= bck_b - ((HACTIVE - spotX)/4);
     end

endmodule // background


























