`default_nettype none
module keyboard( input  logic clk,
                 input  logic reset_n,
                 input  logic ps2_clk,
                 input  logic ps2_data,
                 output logic data_out,
                 output logic data_valide
                 );
   // buffer
   logic [10:0]          buffer;
   logic                parity;

   // Dé-métastabilisateur
   logic                ps2_clk_r, ps2_clk_clean;
   logic                ps2_data_r, ps2_data_clean;

   always @(posedge clk)
     begin
        ps2_clk_r  <=  ps2_clk_clean;
        ps2_data_r <= ps2_data_clean;
        ps2_clk  <=  ps2_clk_r;
        ps2_data <= ps2_data_r;
     end

   //

   //bit de parite
   always @(*)
     parity <= (buffer[0] + buffer[1] + buffer[2] + buffer[3] + buffer[4] + buffer[5] + buffer[6] + buffer[7]);


   //envoie
   always @(posedge ps2_clk_clean or negedge reset_n)
     if(~reset_n)
       begin
          data_out <= 0;
          buffer   <= 0;
          data_valide <= 0;
       end
     else
       begin
          if (((~compt) == 10) && ((~compt) == 0)))
           {buffer} <= {buffer[9:0],ps2_data_clean};
           if((parity == buffer[1]) && (compt == 10) && (buffer[0]) && (~buffer[10]))
            begin
               data_out <= buffer[9:2];
               data_valide <= 1;
            end
           else
             data_valide <= 0;


       end // else: !if(~reset_n)

   // incrementation du compteur
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       compt <= 0;
     else
       begin
          if(compt < 10)
            compt <= compt + 1;
          else
            compt <= 0;
       end



endmodule // keyboard


