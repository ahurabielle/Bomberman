module sprite1(input logic clk,
	           input logic signed [10:0] spotX,
               input logic signed [10:0] spotY,
               output logic [7:0]        bck_r1, bck_g1, bck_b1 // composantes couleurs du sprite
               );

   // taille de la partie active, fonction de la résolution
   localparam integer                    VACTIVE = 600;
   localparam integer                    HACTIVE = 800;


   // création de mire horizontale
   always @(posedge clk)
     begin
	    {bck_r1, bck_g1, bck_b1} <= 0;

	    if(spotY < (VACTIVE / 6))
	      bck_r1 <= 255;
	    else if (spotY < ((VACTIVE * 2) / 6))
	      bck_g1 <= 255;
	    else if (spotY < ((VACTIVE * 3) / 6))
	      bck_b1 <= 255;
	    else if (spotY < ((VACTIVE * 4) /6))
	      begin
	         bck_r1 <= 255;
	         bck_g1 <= 255;
	      end
	    else if (spotY < ((VACTIVE * 5) / 6))
	      begin
	         bck_r1 <= 255;
	         bck_b1 <= 255;
	      end
	    else if (spotY < ((VACTIVE*6) /6))
	      begin
	         bck_g1 <= 255;
	         bck_b1 <= 255;
	      end
     end

endmodule // background


























