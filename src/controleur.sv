module controleur (input              clk,
		           input                      reset_n,
                   // va délimiter le temps durant lequel center pourra etre modifie
		           input logic                SOF,
		           input logic                EOF,
                   // commandes des joueurs
                   input logic                j1_up,
                   input logic                j1_down,
                   input logic                j1_left,
                   input logic                j1_right,
                   input logic                j2_up,
                   input logic                j2_down,
                   input logic                j2_left,
                   input logic                j2_right,
                   // coordonnee des joueurs
                   output logic signed [10:0] player1X,
		           output logic signed [10:0] player1Y,
                   output logic signed [10:0] player2X,
                   output logic signed [10:0] player2Y,

                   // numéros des sprites joueur
                   output logic [2:0]         player1_sprite,
                   output logic [2:0]         player2_sprite
		           );

   // Numéros des sprites joueurs
   localparam FACE    = 0;
   localparam UP1     = 1;
   localparam UP2     = 2;
   localparam RIGHT1  = 3;
   localparam RIGHT2  = 4;
   localparam LEFT1   = 5;
   localparam LEFT2   = 6;
   // taille de l'écran en fonction du nombre de sprites (25 horizontaux et 17 verticaux)
   localparam HSPRITE= 25*32;
   localparam VSPRITE= 17*32;

   // Constante de déplacement = 32 (taille du sprite)
   localparam SIZE    = 32;

   // Déplacement en x, y pour le joueur1
   logic signed [14:0]                dx1,dy1;
   // Déplacement en x, y pour le joueur2
   logic signed [14:0]                dx2,dy2;

   // coordonnee "décimale" des joueurs
   logic [3:0]                        fplayer1X, fplayer1Y;
   logic [3:0]                        fplayer2X, fplayer2Y;

   // Destination en x, y
   logic signed [14:0]                player1_goalX, player1_goalY;
   logic signed [14:0]                player2_goalX, player2_goalY;

   // Machine à etat
   integer                            state;

   // État des joueurs
   logic [1:0]                        player1_state, player2_state;
   localparam WAITING = 0;
   localparam MOVING  = 1;
   // Vitesse des joueurs 1 et 2
   logic signed [13:0]                 v1;
   logic signed [13:0]                 v2;

   //déplacement du joueur 1
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       //On place les joueus au milieu
       begin
          player1_state <= 0;
          state <= 0;
          player1X <= 128;
          player1Y <= 128;
          player2X <= 448;
          player2Y <= 448;
          v1 <= 16;
          v2 <= 3;
       end
     else
       case(state)
         /**************************
          * Phases d'initialistations
          **************************/
         // Pour l'instant : rien à faire, on passe directement au traitement du jeu
         0:
           state <= 100;


<<<<<<< HEAD
   // bouger le centre a l aide de key et le bloquer lorsque le centre touche un bord
   always @(posedge clk or negedge reset_n)
     if(~reset_n)               // on commence au milieu
       begin
	      player1_centerX <= 400;
	      player1_centerY <= 300;
          player2_centerX <= 450;
          player2_centerY <= 300;
       end
   // si le verou est a un et que j ai recu une donnée du clavier alors je bouge
     else if(verou_trame)
       begin
          // On conditionne pour que le sprite (32*32) ne sorte pas de la fenetre
          if(j1_up &&  (player1_centerY >= 32))
            player1_centerY <= player1_centerY - 1;
          if(j1_down && (player1_centerY < VSPRITE-32))
            player1_centerY <= player1_centerY + 1;
          if(j1_right && (player1_centerX < (HSPRITE - 32)))
            player1_centerX <= player1_centerX + 1;
          if(j1_left && (player1_centerX >= 32))
            player1_centerX <= player1_centerX - 1;
          if(j2_up &&  (player2_centerY >= 32))
            player2_centerY <= player2_centerY - 1;
          if(j2_down && (player2_centerY < VSPRITE-32))
            player2_centerY <= player2_centerY + 1;
          if(j2_right && (player2_centerX < (HSPRITE - 32)))
            player2_centerX <= player2_centerX + 1;
          if(j2_left && (player2_centerX >= 32))
            player2_centerX <= player2_centerX - 1;
       end // if (verou_trame)


   // En fonction du mouvement du bonhomme on va afficher des sprites différents
   always @ (posedge clk)
     begin
        // De base le bonhomme nous fait face
        player1_num <= FACE;
        player2_num <= FACE;

        // On alterne les sprites pour donner l'illusion qu'il marche
        if(j1_up | j1_down)
          player1_num <= UP1 + (compt_player1 > 16777215);
        else if(j1_left)
          player1_num <= LEFT1 + (compt_player1 > 16777215);
        else if(j1_right)
          player1_num <= RIGHT1 + (compt_player1 > 16777215);

        if(j2_up | j2_down)
          player2_num <= UP1 + (compt_player2 > 16777215);
        else if(j2_left)
          player2_num <= LEFT1 + (compt_player2 > 16777215);
        else if(j2_right)
          player2_num <= RIGHT1 + (compt_player2 > 16777215);
     end // always @ (posedge clk)
=======
         /**************************
          * Traitement du jeu
          **************************/
         100:
           begin
              // On commence par attendre que EOF soit haut
              if (EOF)
                state <= 101;
           end
>>>>>>> a147b96dac694f44ea187f8c00dcaece3a0fffdb

         101:begin
            // Gère le déplacement du joueur 1
            state <= 200;
         end

         102: begin
            // Gère le déplacement du joueur 2
            state <= 250;
         end

         103: begin
            // On repart en attente du EOF
            state <= 100;
         end

         /**************************
          * Déplacement du joueur 1
          **************************/
         200 :
           begin
              // Si on n'est pas déjà en train de se déplacer, on regarde les touches et on déclenche éventuellement
              // un nouveau déplacement. Sinon, on continue le déplacement.
              state <= 201;
              if (player1_state == WAITING)
                begin
                   if(j1_up)
                     begin
                        player1_state <= MOVING;
                        player1_goalX <= {player1X, 4'd0};
                        player1_goalY <= {player1Y - SIZE, 4'd0} ;
                        dx1 <= 0;
                        dy1 <= -v1;
                     end
                   else if(j1_down)
                     begin
                        player1_state <= MOVING;
                        player1_goalX <= {player1X, 4'd0};
                        player1_goalY <= {player1Y + SIZE, 4'd0} ;
                        dx1 <= 0;
                        dy1 <= v1;
                     end
                   else if(j1_right)
                     begin
                        player1_state <= MOVING;
                        player1_goalX <= {player1X + SIZE, 4'd0} ;
                        player1_goalY <= {player1Y, 4'd0};
                        dx1 <= v1;
                        dy1 <= 0;
                     end
                   else if(j1_left)
                     begin
                        player1_state <= MOVING;
                        player1_goalX <= {player1X - SIZE, 4'd0} ;
                        player1_goalY <= {player1Y, 4'd0};
                        dx1 <= -v1;
                        dy1 <= 0;
                     end
                   else
                     // On n'a appuyé sur aucune touche, le traitement du déplacement est fini !
                     state <= 102;
                end // if (player1_state == WAITING)
           end // case: 200

         201 : begin
            // On sait qu'on est en état MOVING.
            // Si on est sur le point d'arriver à destination ou de dépasser le cible,
            // on se positionne directement dessus
            if ((((dx1 > 0) && (({player1X, fplayer1X} + dx1) >= player1_goalX)) || ((dx1 < 0) && (({player1X, fplayer1X} + dx1) <= player1_goalX)) || (dx1==0))
              && (((dy1 > 0) && (({player1Y, fplayer1Y} + dy1) >= player1_goalY)) || ((dy1 < 0) && (({player1Y, fplayer1Y} + dy1) <= player1_goalY)) || (dy1 ==0)))
              begin
                 {player1X, fplayer1X} <= player1_goalX;
                 {player1Y, fplayer1Y} <= player1_goalY;
                 player1_state <= WAITING;
              end // if ((((dx1 > 0) && ((player1X+dx1) >= player1_goalX)) ||...

            else
              begin
                 // On n'est pas encore arrivé (et pas sur le point d'y arriver), on bouge tranquilou bilou
                 {player1X, fplayer1X} <= {player1X, fplayer1X} + dx1;
                 {player1Y, fplayer1Y} <= {player1Y, fplayer1Y} + dy1;
              end // else: !if((((dx1 > 0) && ((player1X+dx1) >= player1_goalX)) ||...

            // XXX : TODO gérer les débordements (passage d'un côté à l'autre de l'écran)
            state <= 102;
         end // case: 201

          /**************************
          * Déplacement du joueur 2
          **************************/
         250 :
           begin
              // Si on n'est pas déjà en train de se déplacer, on regarde les touches et on déclenche éventuellement
              // un nouveau déplacement. Sinon, on continue le déplacement.
              state <= 251;
              if (player2_state == WAITING)
                begin
                   if(j2_up)
                     begin
                        player2_state <= MOVING;
                        player2_goalX <= {player2X, 4'd0};
                        player2_goalY <= {player2Y - SIZE, 4'd0} ;
                        dx2 <= 0;
                        dy2 <= -v2;
                     end
                   else if(j2_down)
                     begin
                        player2_state <= MOVING;
                        player2_goalX <= {player2X, 4'd0};
                        player2_goalY <= {player2Y + SIZE, 4'd0} ;
                        dx2 <= 0;
                        dy2 <= v2;
                     end
                   else if(j2_right)
                     begin
                        player2_state <= MOVING;
                        player2_goalX <= {player2X + SIZE, 4'd0} ;
                        player2_goalY <= {player2Y, 4'd0};
                        dx2 <= v2;
                        dy2 <= 0;
                     end
                   else if(j2_left)
                     begin
                        player2_state <= MOVING;
                        player2_goalX <= {player2X - SIZE, 4'd0} ;
                        player2_goalY <= {player2Y, 4'd0};
                        dx2 <= -v2;
                        dy2 <= 0;
                     end
                   else
                     // On n'a appuyé sur aucune touche, le traitement du déplacement est fini !
                     state <= 103;
                end // if (player2_state == WAITING)
           end // case: 250

         251 : begin
            // On sait qu'on est en état MOVING.
            // Si on est sur le point d'arriver à destination ou de dépasser le cible,
            // on se positionne directement dessus
            if ((((dx2 > 0) && (({player2X, fplayer2X} + dx2) >= player2_goalX)) || ((dx2 < 0) && (({player2X, fplayer2X} + dx2) <= player2_goalX)) || (dx2==0))
              && (((dy2 > 0) && (({player2Y, fplayer2Y} + dy2) >= player2_goalY)) || ((dy2 < 0) && (({player2Y, fplayer2Y} + dy2) <= player2_goalY)) || (dy2 ==0)))
              begin
                 {player2X, fplayer2X} <= player2_goalX;
                 {player2Y, fplayer2Y} <= player2_goalY;
                 player2_state <= WAITING;
              end // if ((((dx2 > 0) && ((player2X+dx2) >= player2_goalX)) ||...

            else
              begin
                 // On n'est pas encore arrivé (et pas sur le point d'y arriver), on bouge tranquilou bilou
                 {player2X, fplayer2X} <= {player2X, fplayer2X} + dx2;
                 {player2Y, fplayer2Y} <= {player2Y, fplayer2Y} + dy2;
              end // else: !if((((dx2 > 0) && ((player2X+dx) >= player2_goalX)) ||...

            // XXX : TODO gérer les débordements (passage d'un côté à l'autre de l'écran)
            state <= 103;
         end // case: 251

       endcase // case (state)


endmodule // controleur
