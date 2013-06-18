module background(input logic clk,
	           input logic signed [10:0] spotX,
               input logic signed [10:0] spotY,
               output logic [23:0]        bck_rgb // composantes couleurs du fond
               );

   // taille de la partie active, fonction de la résolution
   localparam integer                    VACTIVE = 600;
   localparam integer                    HACTIVE = 800;


   // création de mire horizontale
   always @(posedge clk)
     begin
	    bck_rgb  <= 0;

	    if(spotY < (VACTIVE / 6))
	      bck_rgb[23:16] <= 255;
	    else if (spotY < ((VACTIVE * 2) / 6))
	      bck_rgb[15:8] <= 255;
	    else if (spotY < ((VACTIVE * 3) / 6))
	      bck_rgb[7:0] <= 255;
	    else if (spotY < ((VACTIVE * 4) /6))
	      begin
	         bck_rgb[23:16] <= 255;
	         bck_rgb[15:8] <= 255;
	      end
	    else if (spotY < ((VACTIVE * 5) / 6))
	      begin
	         bck_rgb[23:16] <= 255;
	         bck_rgb[7:0] <= 255;
	      end
	    else if (spotY < ((VACTIVE*6) /6))
	      begin
	         bck_rgb[15:8] <= 255;
	         bck_rgb[7:0] <= 255;
	      end
     end

endmodule // background


























