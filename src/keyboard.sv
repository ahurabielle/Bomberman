`default_nettype none
module keyboard( input logic clk,
                 input  logic reset_n,
                 input  logic ps2_clk,
                 input  logic ps2_data,
                 output logic [7:0] data_out,
                 output logic data_valide
                 );
   // buffer
   logic [10:0]          buffer;
   logic                 parity;
   logic [3:0]           compt;

   // Dé-métastabilisateur
   logic                ps2_clk_r, ps2_clk_clean;
   logic                ps2_data_r, ps2_data_clean;

  /* always @(posedge clk)
     begin
        ps2_clk_r  <=  ps2_clk_clean;
        ps2_data_r <= ps2_data_clean;
        ps2_clk  <=  ps2_clk_r;
        ps2_data <= ps2_data_r;
     end*/

   //

   //bit de parite
   always @(*)
     parity <= (buffer[0] + buffer[1] + buffer[2] + buffer[3] + buffer[4] + buffer[5] + buffer[6] + buffer[7]);


   //envoie
   always @(negedge ps2_clk or negedge reset_n)             //sur front descendant
     if(~reset_n)
       begin
          data_out <= 0;
          buffer   <= 0;
          data_valide <= 0;
       end
     else
       begin
         {buffer} <= {buffer[9:0],ps2_data};                // on charge les data
           if((parity == buffer[1]) && (compt == 10) && (buffer[0] == 1) && (buffer[10]==0)) // dans le cas ou le compteur est plein le bit de parite correct le start et end chargé
            begin
               data_out <= buffer[9:2];                  // on stocke la partie donnée dans data_out
               data_valide <= 1;                         // oui on a chargé quelque chose
            end
           else
             data_valide <= 0;                           // sinon on a rien envoyé


       end // else: !if(~reset_n)

   // incrementation du compteur
   always @(negedge ps2_clk or negedge reset_n)
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


