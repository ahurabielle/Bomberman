module background(input logic signed [10:0] spotX,
                  input logic signed [10:0] spotY,
                  output logic [7:0]        bck_r,bck_g,bck_b);

// taille de la partie active, fonction de la résolution
   localparam integer                       VACTIVE = 600;
   localparam integer                       HACTIVE = 800;


// création de mire horizontale
  always @(*)
    begin
       bck_r <= 0;
       bck_g <= 0;
       bck_b <= 0;
       if (spotX < (HACTIVE/8))
         bck_r <= 255;
       else if (spotX < (HACTIVE/8)*2)
         bck_g <= 255;
       else if (spotX < (HACTIVE/8)*3)
         bck_b <= 255;
       else if (spotX < (HACTIVE/8)*4)
         begin
            bck_r <= 255;
            bck_b <= 255;
         end
       else if (spotX < (HACTIVE/8)*5)
         begin
            bck_r <= 255;
            bck_g <= 255;
         end
       else if (spotX < (HACTIVE/8)*6)
         begin
            bck_b <= 255;
            bck_g <= 255;
         end
       else if (spotX >= (HACTIVE/8)*7)
         begin
            bck_r <= 255;
            bck_g <= 255;
            bck_b <= 255;
         end
    end // always @ (*)

endmodule // background


























