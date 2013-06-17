module synchro(input clock_50,
               input              reset_n,
               output logic       HS,        //signal ligne, a 0 dans Hsync et 1 dans le reste
               output logic       VS,        // signal vertical, a0 dans Vsync et 1 dans le reste
               output logic       SOF,       // debut de trame
               output logic       EOF,       // fin de trame
               output logic       SOL,       // debut de ligne
               output logic       EOL,       // fin de ligne
               output logic [9:0] spotX,     // position X
               output logic [9:0] spotY,     // position Y
               output logic       Blank,     //a 0 dans la zone inactive
               output logic       Sync,      // a 0
               output logic [9:0] R,G,B);    // couleurs rouge vert bleu

   // les compteurs en X et Y
   logic [10:0]                   comptX;
   logic [10:0]                   comptY;
 /************ compteur en X ***************/
   always @(posedge clock_50 or  negedge reset_n)


     if(~reset_n)

       begin
         comptX <= 0;
       end


     else
       begin
          if (comptX <1049)
            comptX <= comptX + 1;
          else comptX <= 0;
       end // else: !if(~reset_n)

  /************ compteur en Y*************/



   always @(posedge clock_50 or  negedge reset_n)


     if(~reset_n)

       begin
         comptY <= 0;
       end


     else
       begin
          if (comptX == 1049 && comptY < 665)
            comptY <= comptY + 1;
          else if (comptX == 1049 && comptY == 665)
            comptY <= 0;
       end // else: !if(~reset_n)





























     /**  begin
          if (comptX < 1049)
            comptX <= comptX + 1;
          else                                 // Quand comptX = 1050 , on incrémente le compteur en Y et on réinitialise le comptX
            begin
               comptX <= 0;

               if(comptY <665)
                 comptY <= comptY +1;
               else comptY <=0;
            end



          if (comptY < 6)
            VS <= 0;
          else if( comptY < 29)
            VS <= 1;
          else if( comptY == 29)
            begin
               if(comptX<120)                  // réalisation du compteur en X pour la premiere ligne active
                 HS <= 0;
               else if(comptX < 184)          // fin de Hsync
                 HS <= 1;
               else if( comptX == 184)        // début de ligne et de trame
                 begin
                    SOL <= 1;
                    SOF <= 1;
                 end
               else if(comptX <983)
                 begin
                    SOL <= 0;
                    SOF <= 0;
                 end
               else if( comptX == 983)          // fin de ligne
                 begin
                    EOL <= 1;
                 end
               else if( comptX <1049)
                 begin
                    EOL <= 0;
                    R,G,B <=0;
                 end                         // fin de la premiere ligne
            end // if ( comptY == 29)
          else if( comptY < 628)
            if(comptX<120)                  // réalisation du compteur en X dans la partie active en Y
              HS <= 0;
            else if(comptX < 184)          // fin de Hsync
              HS <= 1;
            else if( comptX == 184)        // début de ligne
              begin
                 SOL <= 1;
              end
            else if(comptX <983)
              begin
                 SOL <= 0;
              end
            else if( comptX == 983)          // fin de ligne
              begin
                 EOL <= 1;
              end
            else if( comptX <1049)
              begin
                 EOL <= 0;
                 R,G,B <= 0;
              end                         // fin de la partie active en Y
       end










endmodule