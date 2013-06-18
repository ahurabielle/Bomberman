module background(input logic                clk,
                  input logic signed [10:0] spotX,
                  input logic signed [10:0] spotY,
		  input logic signed [10:0] centerX,
		  input logic signed [10:0] centerY,
                  output logic [7:0] 	    bck_r2, bck_g2, bck_b2
                  );

// taille de la partie active, fonction de la résolution
   localparam integer                       VACTIVE = 600;
   localparam integer                       HACTIVE = 800;
   localparam integer 			    R       = 50;
 			    


// création de cercle blanc sur fond noir
  always @(posedge clk)
    begin
       bck_r2 <= 0;
       bck_g2 <= 0;
       bck_b2 <= 0;
       
       if ((spotX - centerX)*(spotX -centerX) + (spotY - centerY)*(spotY - centerY) < (R*R))
	 begin
	    bck_r2 <= 255;
	    bck_g2 <= 255;
	    bck_b2 <= 255;
	 end
       

    end 

endmodule // background


























