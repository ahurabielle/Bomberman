module controleur (input              clk,
		           input              reset_n,
                   // va délimiter le temps durant lequel center pourra etre modifie
		           input logic        SOF,
		           input logic        EOF,
                   // commandes des joueurs
                   input logic        j1_up,
                   input logic        j1_down,
                   input logic        j1_left,
                   input logic        j1_right,
                   input logic        j2_up,
                   input logic        j2_down,
                   input logic        j2_left,
                   input logic        j2_right,
                   // coordonnee des joueurs
                   output logic signed [10:0] player1X,
		           output logic signed [10:0] player1Y,
                   output logic signed [10:0] player2X,
                   output logic signed [10:0] player2Y,

                   // numéros des sprites joueur
                   output logic [2:0] player1_sprite,
                   output logic [2:0] player2_sprite
		           );

   // Numéros des sprites joueurs
   localparam FACE    = 0;
   localparam UP1     = 1;
   localparam UP2     = 2;
   localparam RIGHT1  = 3;
   localparam RIGHT2  = 4;
   localparam LEFT1   = 5;
   localparam LEFT2   = 6;

   // Constante de déplacement = 32 (taille du sprite)
   localparam SIZE    = 32;

   // Déplacement en x, y
   logic signed [10:0]                dx,dy;

   // Destination en x, y
   logic signed [10:0]                player1_goalX, player1_goalY;

   // Machine à etat
   integer                            state;

   // État des joueurs
   logic [1:0]                        player1_state, player2_state;
   localparam WAITING = 0;
   localparam MOVING  = 1;
   // Vitesse des joueurs 1 et 2
   logic signed [9:0]                 v1;
   logic signed [9:0]                 v2;

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
          v1 <= 3;
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


         /**************************
          * Traitement du jeu
          **************************/
         100:
           begin
              // On commence par attendre que EOF soit haut
              if (EOF)
                state <= 101;
           end

         101:begin
            // Gère le déplacement du joueur 1
            state <= 200;
         end

         102: begin
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
                        player1_goalX <= player1X;
                        player1_goalY <= player1Y - SIZE ;
                        dx <= 0;
                        dy <= -v1;
                     end
                   else if(j1_down)
                     begin
                        player1_state <= MOVING;
                        player1_goalX <= player1X;
                        player1_goalY <= player1Y + SIZE ;
                        dx <= 0;
                        dy <= v1;
                     end
                   else if(j1_right)
                     begin
                        player1_state <= MOVING;
                        player1_goalX <= player1X + SIZE ;
                        player1_goalY <= player1Y;
                        dx <= v1;
                        dy <= 0;
                     end
                   else if(j1_left)
                     begin
                        player1_state <= MOVING;
                        player1_goalX <= player1X - SIZE ;
                        player1_goalY <= player1Y;
                        dx <= -v1;
                        dy <= 0;
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
            if ((((dx > 0) && ((player1X+dx) >= player1_goalX)) || ((dx < 0) && ((player1X+dx) <= player1_goalX)) || (dx==0))
              && (((dy > 0) && ((player1Y+dy) >= player1_goalY)) || ((dy < 0) && ((player1Y+dy) <= player1_goalY)) || (dy ==0)))
              begin
                 player1X <= player1_goalX;
                 player1Y <= player1_goalY;
                 player1_state <= WAITING;
              end // if ((((dx > 0) && ((player1X+dx) >= player1_goalX)) ||...

            else
              begin
                 // On n'est pas encore arrivé (et pas sur le point d'y arriver), on bouge tranquilou bilou
                 player1X <= player1X + dx;
                 player1Y <= player1Y + dy;
              end // else: !if((((dx > 0) && ((player1X+dx) >= player1_goalX)) ||...

            // XXX : TODO gérer les débordements (passage d'un côté à l'autre de l'écran)
            state <= 102;
         end // case: 201


       endcase // case (state)


endmodule // controleur
