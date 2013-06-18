module background(input logic                clk,
                  input logic signed [10:0] spotX,
                  input logic signed [10:0] spotY,
		  input logic signed [10:0] centerX,
		  input logic signed [10:0] centerY,
                  output logic [7:0] 	    bck_r, bck_g, bck_b
                  );

// taille de la partie active, fonction de la résolution
   localparam integer                       VACTIVE = 600;
   localparam integer                       HACTIVE = 800;
   localparam integer 			    R       = 50;
 			    


// création de mire horizontale
  always @(posedge clk)
    begin
       bck_r <= 0;
       bck_g <= 0;
       bck_b <= 0;
       
       if ((spotX - centerX)*(spotX -centerX) + (spotY - centerY)*(spotY - centerY) < (R*R))
	 begin
	    bck_r <= 255;
	    bck_g <= 255;
	    bck_b <= 255;
	 end
       

    end // always @ (*)

endmodule // background


























