module background(input logic                clk,
                  input logic signed [10:0]  spotX,
                  input logic signed [10:0]  spotY,
                  output logic [7:0]         bck_r, bck_g, bck_b
                  );

// taille de la partie active, fonction de la résolution
   localparam integer                       VACTIVE = 600;
   localparam integer                       HACTIVE = 800;


// création de mire horizontale
  always @(posedge clk)
    begin
       bck_r <= 0;
       bck_g <= 0;
       bck_b <= 0;
       if (spotY < (VACTIVE/6))
         bck_r <= 255;
       else if (spotY < (VACTIVE*2/6))
         bck_g <= 255;
       else if (spotY < (VACTIVE*3/6))
         bck_b <= 255;
       else if (spotY < (VACTIVE*4/6))
         begin
            bck_r <= 255;
            bck_b <= 255;
         end
       else if (spotY < (VACTIVE*5/6))
         begin
            bck_r <= 255;
            bck_g <= 255;
         end
       else if (spotY < (VACTIVE*6/6))
         begin
            bck_b <= 255;
            bck_g <= 255;
         end

    end // always @ (*)

endmodule // background


























