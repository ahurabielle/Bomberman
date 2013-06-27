module life(input logic clk,
	        input logic signed [10:0] spotX,
            input logic signed [10:0] spotY,
            input logic [6:0]         life1,
            input logic [6:0]         life2,
            // composantes couleurs de la vie
            output logic [23:0]       life_rgb
            );


   // paramètre pour la barre de vie du joueur 1
   // debut de la barre de vie 1 (support)
   localparam integer                 STARTX1  = 10;
   localparam integer                 STARTY1  = 17*32+10;
   // debut de la barre de vie 2 (support)
   localparam integer                 STARTX2  = 800-10;
   // eppaisseur du support de la barre et paramètres dessus
   localparam integer                 LARGEUR = 3;
   localparam integer                 LONGUEUR_SUPPORT_VERTICAL  = 15;
   // espace entre le support et la barre
   localparam integer                 ESPACE  = 1;
   // inutile pour l'instant mais ....
   localparam integer                 CONTOUR = 0;
   // longueur du support horizontal
   localparam integer                 LONGUEUR_SUPPORT_HORIZONTAL = 110;
   // début de la barre de vie en elle meme
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
        if ((spotX >= STARTX2 - LARGEUR) && (spotX < STARTX2) && (spotY >= STARTY1) && (spotY < (STARTY1 + LONGUEUR_SUPPORT_VERTICAL)))
          case(spotX - (800-13))
            0: life_rgb <=  {8'd193,8'd191,8'd177};
            1: life_rgb <=  {8'd206,8'd206,8'd206};
            2: life_rgb <=  {8'd230,8'd230,8'd230};
          endcase // case (spotX - STARTX)
        // barre horizontale
        if ((spotX >= STARTX2 - LARGEUR - 100) && (spotX < STARTX2) && (spotY >= (STARTY1 + LONGUEUR_SUPPORT_VERTICAL))
            && (spotY <= STARTY1 + LONGUEUR_SUPPORT_VERTICAL + LARGEUR))
          case ( spotY - (STARTY1 + LONGUEUR_SUPPORT_VERTICAL))
            0: life_rgb <= {8'd193,8'd191,8'd177};
            1: life_rgb <= {8'd206,8'd206,8'd206};
            2: life_rgb <= {8'd230,8'd230,8'd230};
          endcase // case ( spotY - (STARTY1 + LONGUEUR_SUPPORT_VERTICAL))
        // barre de vie
        if((spotX >= STARTX2 - ESPACE - LARGEUR - life2) && (spotX <= STARTX2 - ESPACE - LARGEUR) && (spotY <= (LIFE1_STARTY + LONGUEUR_SUPPORT_VERTICAL - ESPACE)) && (spotY >= LIFE1_STARTY))
          begin
             if ( life2 >= 50 )
               life_rgb <= {8'd20,8'd148,8'd20};
             else
               life_rgb <= {8'd238,8'd16,8'd16};
          end



     end // always @ (posedge clk)

endmodule // life


