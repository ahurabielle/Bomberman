module life(input logic clk,
	        input logic signed [10:0] spotX,
            input logic signed [10:0] spotY,
            input logic [6:0]         life1,
            input logic [6:0]         life2,
            // composantes couleurs de la vie
            output logic [23:0]       life_rgb
            );


   // paramètre pour la barre de vie du joueur 1
   localparam integer                 STARTX1  = 10;
   localparam integer                 STARTY1  = 17*32+10;
   localparam integer                 LARGEUR = 3;
   localparam integer                 LONGUEUR_SUPPORT_VERTICAL  = 15;
   localparam integer                 ESPACE  = 1;
   localparam integer                 CONTOUR = 0;
   localparam integer                 LONGUEUR_SUPPORT_HORIZONTAL = 100;
   localparam integer                 LIFE1_STARTX  = STARTX1 + ESPACE + CONTOUR + LARGEUR;
   localparam integer                 LIFE1_STARTY  = STARTY1 + CONTOUR;
   // paramètre pour la barre de vie du joueur 2



   always @(posedge clk)
     begin
        // couleur qui sera considérée comme transparente dans le mixeur
        life_rgb <= {8'd255,8'd255,8'd255};
        // le contour vertical
        if((spotX >= STARTX1 ) && ( spotX <= (STARTX1 + LARGEUR))
           && (spotY >= (STARTY1)) && (spotY < (STARTY1 + LONGUEUR_SUPPORT_VERTICAL)))
          begin
             case(spotX - STARTX1)
               0: life_rgb <=  {8'd193,8'd191,8'd177};
               1: life_rgb <=  {8'd206,8'd206,8'd206};
               2: life_rgb <=  {8'd230,8'd230,8'd230};
             endcase // case (spotX - STARTX)
          end // if ((spotX >= STARTX ) && ( spotX <= (STARTX + LARGEUR))...

        // le contour horizontal
        if((spotX >= STARTX1) && (spotX <= (STARTX1 +LONGUEUR_SUPPORT_HORIZONTAL))
           && (spotY >= (STARTY1 + LONGUEUR_SUPPORT_VERTICAL)) && (spotY <= STARTY1 + LONGUEUR_SUPPORT_VERTICAL + LARGEUR))
          case ( spotY - (STARTY1 + LONGUEUR_SUPPORT_VERTICAL))
            0: life_rgb <=  {8'd193,8'd191,8'd177};
            1: life_rgb <= {8'd206,8'd206,8'd206};
            2: life_rgb <= {8'd230,8'd230,8'd230};
          endcase // case ( spotY - (STARTY + LONGUEUR_SUPPORT_VERTICAL))
        // La bare de vie qui passe de vert à rouge quand on passe à moins de 50% de vie
         if((spotX >= LIFE1_STARTX) && (spotX <= LIFE1_STARTX + life1)
         && (spotY >= LIFE1_STARTY) && (spotY <= (LIFE1_STARTY + LONGUEUR_SUPPORT_VERTICAL - ESPACE)))
         begin
         if ( life1 >= 50 )
         life_rgb <= {8'd20,8'd148,8'd20};
         else
         life_rgb <= {8'd238,8'd16,8'd16};
          end

        // pour le joueur 2
        // barre verticale
        if ((spotX >= 800 -13) && (spotX <800-10) && (spotY >= STARTY1) && (spotY < (STARTY1 + LONGUEUR_SUPPORT_VERTICAL)))
          case(spotX - (800-13))
            0: life_rgb <=  {8'd193,8'd191,8'd177};
            1: life_rgb <=  {8'd206,8'd206,8'd206};
            2: life_rgb <=  {8'd230,8'd230,8'd230};
          endcase // case (spotX - STARTX)
        // barre horizontale
        if ((spotX >= 800 -13 - 100) && (spotX < 800-10) && (spotY >= (STARTY1 + LONGUEUR_SUPPORT_VERTICAL))
            && (spotY <= STARTY1 + LONGUEUR_SUPPORT_VERTICAL + LARGEUR))
          case ( spotY - (STARTY1 + LONGUEUR_SUPPORT_VERTICAL))
            0: life_rgb <= {8'd193,8'd191,8'd177};
            1: life_rgb <= {8'd206,8'd206,8'd206};
            2: life_rgb <= {8'd230,8'd230,8'd230};
          endcase // case ( spotY - (STARTY1 + LONGUEUR_SUPPORT_VERTICAL))
        // barre de vie
        if((spotX >= 800-15-life2) && (spotX <= 800-15) && (spotY <= (LIFE1_STARTY + LONGUEUR_SUPPORT_VERTICAL - ESPACE)) && (spotY >= LIFE1_STARTY))
          begin
             if ( life2 >= 50 )
               life_rgb <= {8'd20,8'd148,8'd20};
             else
               life_rgb <= {8'd238,8'd16,8'd16};
          end



     end // always @ (posedge clk)

endmodule // life


