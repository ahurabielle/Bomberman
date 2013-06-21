module keyboard( input  logic       clk,
                 input logic        reset_n,
                 input logic        ps2_clk,
                 input logic        ps2_data,
                 output logic [7:0] data_out,
                 // Sorties
                 output logic       j1_up,
                 output logic       j1_down,
                 output logic       j1_left,
                 output logic       j1_right,
                 output logic       j1_drop,

                 output logic       j2_up,
                 output logic       j2_down,
                 output logic       j2_left,
                 output logic       j2_right,
                 output logic       j2_drop
                 );
   // buffer
   logic [11:0]                     buffer;
   logic                            data_valid;

   // Dé-métastabilisateur
   logic                            ps2_clk_r, ps2_clk_clean;
   logic                            ps2_data_r, ps2_data_clean;

   localparam [7:0] fin =8'h0f;

   always @(posedge clk)
     begin
        ps2_clk_clean  <=  ps2_clk_r;
        ps2_data_clean <= ps2_data_r;
        ps2_clk_r  <=  ps2_clk;
        ps2_data_r <= ps2_data;
     end

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
          // On envoi la donnée à l'extérieur,
          // et on remet le registre dans un état de départ
          if (buffer[11])
            begin
               buffer <= 1;
               data_out <= buffer[9:2];
               data_valid <= 1;
            end
       end

   // Décodage des touches
   logic [7:0] data_out_r;
   always @(posedge clk)
     data_out_r <= data_out;


   // j1_up
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       // Au début rien ne se passe les joueurs sont au repos
       begin
          j1_up <= 0;
          j1_down <= 0;
          j1_left <= 0;
          j1_right <= 0;
          j1_drop <= 0;
          j2_up <= 0;
          j2_down <= 0;
          j2_left <= 0;
          j2_right <= 0;
          j2_drop <= 0;
       end // if (~reset_n)

   // Si on a pas eut de message de fin au front de clock précédent et
   //  qu'on est entrain denvoyer des données
     else
       begin
          // si on a recu un message de fin au front precedent venant de la touche data_out,
          // signal qu'on recoit maintenant on remet a 0 les j1_*
          // si on a pas recu de fin au coup précédent et que on recoit des données de
          // la touche data_out avec data_valide (ie un quelqu'un appuye sur la touche)
          // alors on passe le j*_* correspondant
          if((data_out_r == fin) && (data_out == 8'b10111000 ))
            j1_up <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'b10111000) && ( data_valid))
            j1_up <= 1;

          if((data_out_r == fin) && (data_out == 8'hd8 ))
            j1_down <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'hd8) && ( data_valid))
            j1_down <= 1;

          if((data_out_r == fin) && (data_out == 8'h38 ))
            j1_left <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'h38) && ( data_valid))
            j1_left <= 1;

          if((data_out_r == fin) && (data_out == 8'hc4 ))
            j1_right <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'hc4) && ( data_valid))
            j1_right <= 1;

          if((data_out_r == fin) && (data_out == 8'h94 ))
            j1_drop <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'h94) && ( data_valid))
            j1_drop <= 1;

          if((data_out_r == fin) && (data_out == 8'h22 ))
            j2_up <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'h22) && ( data_valid))
            j2_up <= 1;

          if((data_out_r == fin) && (data_out == 8'hd2 ))
            j2_down <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'hd2) && ( data_valid))
            j2_down <= 1;

          if((data_out_r == fin) && (data_out == 8'h42 ))
            j2_left <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'h42) && ( data_valid))
            j2_left <= 1;

          if((data_out_r == fin) && (data_out == 8'h32 ))
            j2_right <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'h32) && ( data_valid))
            j2_right <= 1;

          if((data_out_r == fin) && (data_out == 8'hba ))
            j2_drop <= 0;
          if((~(data_out_r == fin)) && (data_out == 8'hba) && ( data_valid))
            j2_drop <= 1;
       end // else: !if(~reset_n)

endmodule // keyboard


