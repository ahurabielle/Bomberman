module life(input logic clk,
	        input logic signed [10:0] spotX,
            input logic signed [10:0] spotY,
            input logic [6:0]         life,
            // composantes couleurs de la vie
            output logic [23:0]       life_rgb
            );



   localparam integer                 STARTX  = 10;
   localparam integer                 STARTY  = 17*32+10;
   localparam integer                 LARGEUR = 6;
   localparam integer                 LONGUEUR_SUPPORT_VERTICAL  = 10;
   localparam integer                 ESPACE  = 3;
   localparam integer                 CONTOUR = 0;
   localparam integer                 LONGUEUR_SUPPORT_HORIZONTAL = 300;
   localparam integer                 LIFE_STARTX  = STARTX + ESPACE + CONTOUR;
   localparam integer                 LIFE_STARTY  = STARTY + CONTOUR;

   always @(posedge clk)
     begin
        // couleur qui sera considérée comme transparente dans le mixeur
        life_rgb <= {8'd255,8'd255,8'd255};
        // le contour vertical
        if((spotX >= STARTX ) && ( spotX <= (STARTX + LARGEUR))
           && (spotY >= (STARTY)) && (spotY <= (STARTY + LONGUEUR_SUPPORT_VERTICAL)))
          case(spotX - STARTX)
            0: life_rgb <=  {8'd200,8'd200,8'd200};
            1: life_rgb <=  {8'd225,8'd225,8'd225};
            2: life_rgb <=  {8'd230,8'd230,8'd230};
            3: life_rgb <=  {8'd230,8'd230,8'd230};
            4: life_rgb <=  {8'd225,8'd225,8'd225};
            5: life_rgb <=  {8'd200,8'd200,8'd200};
          endcase // case (spotX - STARTX)
        // le contour horizontal
        if((spotX >= STARTX) && (spotX =< (STARTX +LONGUEUR_SUPPORT_HORIZONTAL))
           && (spotY >= (STARTY + LONGUEUR_SUPPORT_VERTICAL)) && (spotY <= STARTY + LARGEUR))
          case ( spotY - (STARTY + LONGUEUR_SUPPORT_VERTICAL))
            0: life_rgb <= {8'd200,8'd200,8'd200};
            1: life_rgb <= {8'd25,8'd225,8'd225};
            2: life_rgb <= {8'd230,8'd230,8'd245};
            3: life_rgb <= {8'd230,8'd230,8'd230};
            4: life_rgb <= {8'd225,8'd225,8'd225};
            5: life_rgb <= {8'd200,8'd200,8'd200};
          endcase // case ( spotY - (STARTY + LONGUEUR_SUPPORT_VERTICAL))
        // La bare de vie qui passe de vert à rouge quand on passe à moins de 50% de vie
        if((spotX >= LIFE_STARTX) && (spotX <= LIFE_STARTX + life)
           && (spotY >= LIFE_STARTY) && (spotY <= (LIFE_STARTY + LONGUEUR_SUPPORT_VERTICAL - ESPACE)))
          begin
             if ( life >= 50 )
               life_rgb <= {8'd20,8'd148,8'd20};
             else
               life_rgb <= {8'd238,8'd16,8'd16};
          end


     end // always @ (posedge clk)

endmodule // life


