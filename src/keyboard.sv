`default_nettype none
  module keyboard( input  logic clk,
                   input logic        reset_n,
                   input logic        ps2_clk,
                   input logic        ps2_data,
                   output logic [7:0] data_out,
                   output logic       data_valid
                   );
   // buffer
   logic [11:0]                       buffer;
   logic                              parity;
   logic [3:0]                        compt;

   // Dé-métastabilisateur
   logic                              ps2_clk_r, ps2_clk_clean;
   logic                              ps2_data_r, ps2_data_clean;

   always @(posedge clk)
     begin
        ps2_clk_clean  <=  ps2_clk_r;
        ps2_data_clean <= ps2_data_r;
        ps2_clk_r  <=  ps2_clk;
        ps2_data_r <= ps2_data;
     end

   //bit de parite
   always @(*)
     parity <= (buffer[2] ^ buffer[3] ^ buffer[4] ^ buffer[5] ^ buffer[6] ^ buffer[7] ^ buffer[8] ^ buffer[9]);

   // Détecte le front descendant de ps2_clk
   logic   ps2_clk_falling_edge;
   logic   ps2_clk_clean_r;

   always @(posedge clk)
     begin
        ps2_clk_clean_r <= ps2_clk_clean;
        ps2_clk_falling_edge <= ps2_clk_clean_r & ~ps2_clk_clean;
     end

   // Registre à décalage
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       buffer <= 1;
     else
       begin
          // Valeur par défaut des signaux
          data_valid <= 0;

          // Si on a un front descendant de ps2_clk, on shifte les données du registre à décalage
          if (ps2_clk_falling_edge)
            buffer <= {buffer[10:0], ps2_data_clean};

          // Si on a un 1 dans le MSB du registre à décalage, c'est qu'il est rempli
          // On vérifie alors la trame (start, stop, parity) et on envoi la donnée à l'extérieur,
          // et on remet le registre dans un état de départ
          if (buffer[11])
            begin
               buffer <= 1;
               data_out <= buffer[9:2];
               data_valid <= 1;
            end
       end


endmodule // keyboard


