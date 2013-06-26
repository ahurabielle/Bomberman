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
                   input logic                j1_drop,
                   input logic                j2_up,
                   input logic                j2_down,
                   input logic                j2_left,
                   input logic                j2_right,
                   input logic                j2_drop,
                   // coordonnee des joueurs
                   output logic signed [10:0] player1X,
		           output logic signed [10:0] player1Y,
                   output logic signed [10:0] player2X,
                   output logic signed [10:0] player2Y,

                   // numéros des sprites joueur
                   output logic [2:0]         player1_sprite,
                   output logic [2:0]         player2_sprite,

                   // interface avec la RAM du labyrinthe
                   output logic [9:0]         ram_raddr, ram_waddr,
                   output logic [3:0]         ram_wdata,
                   output logic               ram_we,
                   input logic [3:0]          ram_rdata,

                   // Debug
                   output logic [31:0]        debug
		           );

   // Numéros des sprites joueurs
   localparam FACE    = 0;
   localparam UP1     = 1;
   localparam UP2     = 2;
   localparam RIGHT1  = 3;
   localparam RIGHT2  = 4;
   localparam LEFT1   = 5;
   localparam LEFT2   = 6;

   // Taille de l'écran en fonction du nombre de sprites (25 horizontaux et 17 verticaux)
   localparam HSPRITE= 25*32;
   localparam VSPRITE= 17*32;

   // Numéros de sprites des portes
   localparam WALL_EMPTY = 0;
   localparam WALL_1     = 1;
   localparam WALL_2     = 2;
   localparam GATE_RIGHT = 3;
   localparam GATE_LEFT  = 4;
   localparam GATE_UP    = 5;
   localparam GATE_DOWN  = 6;
   localparam BOMB       = 12;

   // Constante de déplacement = 32 (taille du sprite)
   localparam SIZE    = 32;

   // Déplacement en x, y pour le joueur1
   logic signed [14:0]                        dx1,dy1;
   // Déplacement en x, y pour le joueur2
   logic signed [14:0]                        dx2,dy2;

   // coordonnee "décimale" des joueurs
   logic [3:0]                                fplayer1X, fplayer1Y;
   logic [3:0]                                fplayer2X, fplayer2Y;

   // Destination en x, y
   logic signed [14:0]                        player1_goalX, player1_goalY;
   logic signed [14:0]                        player2_goalX, player2_goalY;

   // Machine à etat
   integer                                    state;
   integer                                    return_addr;
   logic [9:0]                                count;

   // État des joueurs
   logic [1:0]                                player1_state, player2_state;
   localparam WAITING = 0;
   localparam MOVING  = 1;
   // Vitesse des joueurs 1 et 2
   logic signed [13:0]                        v1;
   logic signed [13:0]                        v2;

   // RAM des bombes qui contient les états (timer, X, Y) des bombes déposées
   // Elles peuvent être au nombre de 16 au total
   logic [3:0]                                bomb_ram_raddr, bomb_ram_waddr;
   logic [18:0]                               bomb_ram_wdata;
   logic                                      bomb_ram_we;
   logic [18:0]                               bomb_ram_rdata;
   logic [18:0]                               bomb_ram[0:15];
   logic [4:0]                                bombX, bombY, dummyX, dummyY;
   // Détermine la durée avant explosion de la bombe
   logic [8:0]                                bomb_timer;
   logic [3:0]                                bomb_num;

   //Machine à etats
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       //On place les joueurs au milieu
       begin
          player1_state <= 0;
          state <= 0;
          player1X <= 128;
          player1Y <= 128;
          player2X <= 448;
          player2Y <= 448;
          v1 <= 32;
          v2 <= 3;
          ram_raddr <= 0;
          ram_waddr <= 0;
          ram_wdata <= 0;
          ram_we <= 0;
          bomb_ram_raddr <= 0;
          bomb_ram_waddr <= 0;
          bomb_ram_wdata <= 0;
          bomb_ram_we <= 0;
          count <= 0;
       end
     else
       begin
          // Par défaut, on ne fait PAS d'écriture dans la RAM
          ram_we <= 0;
          bomb_ram_we <= 0;

          case(state)
            /**************************
             * Phases d'initialistations
             **************************/
            // Pour l'instant : rien à faire, on passe directement au traitement du jeu
            0:
              begin
                 ram_raddr <= 0;
                 state <= state + 1;
              end

            1:
              begin
                 // Temps d'attente
                 state <= state +1;
              end
            2:
              // On regarde s'il y a une bombe à l'emplacement que l'on lit
              // Si c'est le cas, on la remplace par du vide
              // Sinon, on n'y touche pas.
              // On vérifie l'adresse suivante jusqu'à la fin de la Ram.
              begin
                 if(ram_rdata == BOMB)
                   begin
                      ram_wdata <= WALL_EMPTY ;
                      ram_waddr <= ram_raddr;
                      ram_we <= 1;
                   end
                 ram_raddr <= ram_raddr + 1;
                 state <= 1;
                 if(ram_raddr == ((17 * 32) - 1))
                   state <= state + 1;
              end

            3: // Ré-initialisation de la RAM bomb
              begin
                 bomb_ram_waddr <= 0;
                 state <= state + 1;
              end

            4: // Ré-initialisation de la RAM bomb
              begin
                 bomb_ram_wdata <= 0;
                 bomb_ram_we <= 1;
                 bomb_ram_waddr <= bomb_ram_waddr + 1;
                 if (bomb_ram_waddr == 15)
                   state <= 100;
              end

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
               return_addr <= state + 1;
            end

            102: begin
               // Gère le déplacement du joueur 2
               state <= 250;
               return_addr <= state + 1;
            end

            103:
              // Gère le dépot des bombes du joueur 1
              if (j1_drop)
                //La position de la bombe sera la position ou le joueur
                //est placé majoritairement
                begin
                   bombX <= (player1X + 16) / 32;
                   bombY <= (player1Y + 16) / 32;
                   state <= 300;
                   return_addr <= state + 1;
                end
              else
                state <= state + 1;

            104:
              // Gère le dépot des bombes du joueur 2
              if (j2_drop)
                //La position de la bombe sera la position ou le joueur
                //est placé majoritairement
                begin
                   bombX <= (player2X + 16) / 32;
                   bombY <= (player2Y + 16) / 32;
                   state <= 300;
                   return_addr <= state + 1;
                end
              else
                state <= state + 1;

            105:
              // Gestion des timers
              begin
                 state <= 400;
                 return_addr <= state + 1;
              end

            106: begin
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
                 if (player1_state == WAITING)
                   begin
                      state <= state + 1;
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
                        begin
                           state <= return_addr;
                           player1_sprite <= 0;
                           player2_sprite <= 0;
                        end

                   end
                 else
                   // On est déjà entrain de bouger, on va à l'état qui actualise playerX et playerY
                   state <= 220;
              end

            201: begin
               // On se prépare à bouger. On vérifie d'abord si la case de destination est libre.
               ram_raddr <= {player1_goalY[13:9], player1_goalX[13:9]};
               state <= state + 1;
            end

            202: begin
               // État d'attente (dans l'état actuel on présente à la RAM l'adresse de la valeur à lire,
               // on n'aura la donnée qu'au prochain cycle)
               state <= state + 1;
            end

            203: begin
               // Vérifie que la case de destination est bien vide. Si oui, on effectue le mouvement.
               // Si non on passe au test suivant (porte et qu'on va dans la bonne direction)
               if (ram_rdata == WALL_EMPTY)
                 state <= 220;
               else
                 state <= state + 1;
            end

            204 : begin
               // Si on a un mur, on annule le mouvement
               if ((ram_rdata == WALL_1) || (ram_rdata == WALL_2))
                 state <= 218;
               else
                 state <= state + 1;
            end

            205 : begin
               // Si on est sur une porte et qu'on ne va pas dans le bon sens, annule le mouvement
               if (((ram_rdata == GATE_RIGHT) & (dx1 <= 0)) ||
                   ((ram_rdata == GATE_LEFT)  & (dx1 >= 0)) ||
                   ((ram_rdata == GATE_DOWN)  & (dy1 <= 0)) ||
                   ((ram_rdata == GATE_UP)    & (dy1 >= 0)))
                 state <= 218;
               else
                 state <= state + 1;
            end

            206 : begin
               // Si on a passé une porte, on flippe la porte
               if(ram_rdata == GATE_UP)
                 ram_wdata <= GATE_DOWN;
               if(ram_rdata == GATE_DOWN)
                 ram_wdata <= GATE_UP;
               if(ram_rdata == GATE_LEFT)
                 ram_wdata <= GATE_RIGHT;
               if(ram_rdata == GATE_RIGHT)
                 ram_wdata <= GATE_LEFT;
               // Active l'écriture en RAM
               if ((ram_rdata == GATE_UP) || (ram_rdata == GATE_DOWN) || (ram_rdata == GATE_LEFT) || (ram_rdata == GATE_RIGHT))
                 ram_we <= 1;
               // La case qu'on doit écrire est justement celle qu'on est en train de lire
               ram_waddr <= ram_raddr;
               state <= state + 1;
            end // case: 206

            207 : begin
               // Si il y a une bombe, on annule le mouvement
               if (ram_rdata == BOMB)
                 state <= 218;
               else
                 state <= 220;
            end


            218 : begin
               // Annule le mouvement
               dx1 <= 0;
               dy1 <= 0;
               player1_state <= WAITING;
               player1_goalX <= {player1X, 4'b0000};
               player1_goalY <= {player1Y, 4'b0000};
               state <= return_addr;
            end

            220 :
              begin
                 // On est en état MOVING.
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

                 // Revient à la routine de gestion principale
                 state <= state + 1;
              end // case: 220

            221 :
              // Si on va a droite on va prendre le sprite en direction de la droite
              // et de meme pour les autres directions
              begin
                 if (dx1 > 0)
                   state <= state + 1;
                 else if (dx1 < 0)
                   state <= state + 2;
                 else if (dy1 > 0)
                   state <= state + 3;
                 else if(dy1 < 0)
                   state <= state + 4;
              end // case: 221


            222 :
              // On va a droite on alterne les deux sprites, en fonction de notre avancement
              begin
                 // On regarde dans quelle proportion on a avancé par rapport a notre case d'arrivé
                 // On affiche alors dans la RAM tel ou tel autre sprite
                 // On affiche 2 sprites pour chaque case
                 if(player1_goalX[14:4]-player1X < 16)
                   player1_sprite <= 4;
                 else
                   player1_sprite <= 3;
                 state <= return_addr;
              end // case: 222
            223:
              // On va a gauche
              begin
                 if(player1X - player1_goalX[14:4]< 16  )
                   player1_sprite <= 6;
                 else
                   player1_sprite <= 5;
                 state <= return_addr;
              end // case: 223

            224:
              // On se déplace vers le bas
              begin
                 if( player1_goalY[14:4] - player1Y  < 16)
                   player1_sprite <= 2;
                 else
                   player1_sprite <= 1;
                 state <= return_addr;
              end // case: 224
            225 :
              // On se déplace vers le haut
              begin
                 if(player1Y - player1_goalY[14:4]  < 16)
                   player1_sprite <= 2;
                 else
                   player1_sprite <= 1;
                 state <= return_addr;
              end // case: 224



            /**************************
             * Déplacement du joueur 2
             **************************/
            250 :
              begin
                 // Si on n'est pas déjà en train de se déplacer, on regarde les touches et on déclenche éventuellement
                 // un nouveau déplacement. Sinon, on continue le déplacement.
                 state <= state + 1;
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
                        state <= return_addr;
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
               state <= state +1;
            end // case: 251
              252 :
              // Si on va a droite on va prendre le sprite en direction de la droite
              // et de meme pour les autres directions
              begin
                 if (dx2 > 0)
                   state <= state + 1;
                 else if (dx2 < 0)
                   state <= state + 2;
                 else if (dy2 > 0)
                   state <= state + 3;
                 else if(dy2 < 0)
                   state <= state + 4;
              end // case: 221


            253 :
              // On va a droite on alterne les deux sprites, en fonction de notre avancement
              begin
                 // On regarde dans quelle proportion on a avancé par rapport a notre case d'arrivé
                 // On affiche alors dans la RAM tel ou tel autre sprite
                 // On affiche 2 sprites pour chaque case
                 if(player2_goalX[14:4]-player2X < 16)
                   player2_sprite <= 4;
                 else
                   player2_sprite <= 3;
                 state <= return_addr;
              end // case: 222
            254:
              // On va a gauche
              begin
                 if(player2X - player2_goalX[14:4]< 16  )
                   player2_sprite <= 6;
                 else
                   player2_sprite <= 5;
                 state <= return_addr;
              end // case: 223

            255:
              // On se déplace vers le bas
              begin
                 if( player2_goalY[14:4] - player2Y  < 16)
                   player2_sprite <= 2;
                 else
                   player2_sprite <= 1;
                 state <= return_addr;
              end // case: 224
            256 :
              // On se déplace vers le haut
              begin
                 if(player2Y - player2_goalY[14:4]  < 16)
                   player2_sprite <= 2;
                 else
                   player2_sprite <= 1;
                 state <= return_addr;
              end // case: 224


            /***********************
             ******Bombes***********
             **********************/
            300 :
              begin
                 state <= state + 1;
              end // case: 300

            301 :
              //On va vérifier qu'on n'a pas encore posé la bombe à cet emplacement
              begin
                 ram_raddr <= {bombY, bombX};
                 state <= state + 1;
              end

            302 :
              // Etat d'attente de lecture de la ram
              state <= state + 1;

            303:
              // On a accès à la ram
              // On vérifie que le sprite est vide.
              // Dans ce cas, on pose une bombe, sinon, on skip
              begin
                 if (ram_rdata == WALL_EMPTY)
                   state <=  state + 1;
                 else
                   state <= return_addr;
              end

            304 :
              /// Empty state (code moved)
              state <= state + 1;

            305 :
              // Cherche une bombe libre dans la Ram de bombe
              begin
                 bomb_ram_raddr <= 0;
                 state <= state +1;
              end

            306 :
              // Attente avant lecture
              state <= state + 1;

            307 : // Lit le contenu de la RAM
              begin
                 bomb_timer <= bomb_ram_rdata[18:10];
                 state <= state + 1;
              end

            308 :
              // Si on a une case libre, on stocke le timer et les coordonnées de la bombe
              // Sinon, soit on observe la case suivante, soit on a tout parcouru.
              // Dans ce dernier cas, on n'autorise pas le dépot de la bombe
              // car il n'y a pas de bombe disponible
              begin
                 if(bomb_timer == 0)
                   begin
                      bomb_ram_waddr <= bomb_ram_raddr;
                      bomb_ram_wdata <= {9'd360, bombY, bombX};
                      bomb_ram_we <= 1;
                      state <= state + 1;
                   end
                 else if(bomb_ram_raddr != 15)
                   begin
                      state <= 306 ;
                      bomb_ram_raddr <= bomb_ram_raddr + 1;
                   end
                 else
                   state <= return_addr;
              end

            309 :
              // Dépose la bombe : stocke sprite bombe dans la Ram sprite
              begin
                 ram_waddr <= {bombY, bombX};
                 ram_wdata <= BOMB;
                 ram_we <= 1;
                 state <= state + 1;
              end

            310 :
              state <= return_addr;

            /***********************
             ******Timers***********
             **********************/
            400:
              // A chaque fin de trame, on va décrémenter les timers
              // On commence à l'addresse 0 dans la RAM des bombes
              begin
                 bomb_ram_raddr <= 0;
                 state <= state + 1;
              end

            401:
              // Attente de lecture
              state <= state + 1;

            402:
              // On parcourt l'ensemble de la Ram.
              // Pour chaque timer , on le décrémente s'il est plus grand que 1.
              begin
                 state <= state + 1;
                 // Une seconde avant que la bombe disparaisse, on déclenche les flammes.
                 if(bomb_ram_rdata[18:10] == 72)
                   state <= 420;
                 // Après les flammes, on fait disparaitre la bombe
                 if(bomb_ram_rdata[18:10] == 1)
                   state <= 410;
                 else if(bomb_ram_rdata[18:10] != 0)
                   begin
                      bomb_ram_waddr <= bomb_ram_raddr;
                      bomb_ram_we <= 1;
                      bomb_ram_wdata[9:0] <= bomb_ram_rdata[9:0];
                      bomb_ram_wdata[18:10] <= (bomb_ram_rdata[18:10] - 1);
                   end
              end // case: 402

            403 : begin
               // On passe à l'entrée suivante dans la RAM bombes
               // Si on est à la fin, on revient au traitement normal du jeu
               bomb_ram_raddr <= bomb_ram_raddr + 1;
               if (bomb_ram_raddr==15)
                 state <= return_addr;
               else
                 state <= 401;
            end

            410:
              // Fin de l'explosion
              begin
                 // On remplace le sprite de la bombe par un sprite vide dans la Ram Maze
                 ram_wdata <= WALL_EMPTY;
                 ram_we <= 1;
                 ram_waddr <= bomb_ram_rdata[9:0];

                 // On remet le timer à 0 pour pouvoir stocker de nouvelles bombes dans la Ram bombes
                 bomb_ram_wdata <= 0;
                 bomb_ram_we <= 1;
                 bomb_ram_waddr <= bomb_ram_raddr;

                 state <= state + 1;
              end // case: 403

            411:
              // On passe à la prochaine bombe dans la liste
              state <= 403;

            420 :
              begin
                 // Gestion des flammes..
                 state <= 403;
              end

          endcase // case (state)
       end

   // BOMB RAM
   always @(posedge clk)
     if(bomb_ram_we)
       bomb_ram[bomb_ram_waddr] <= bomb_ram_wdata;

   always @(posedge clk)
     bomb_ram_rdata <= bomb_ram[bomb_ram_raddr];


endmodule // controleur
