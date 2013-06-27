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

                   // Couleur du fond
                   input logic                new_game,
                   output logic [7:0]         bck_r, bck_g, bck_b,

                   // numéros des sprites joueur
                   output logic [2:0]         player1_sprite,
                   output logic [2:0]         player2_sprite,

                   // Vies des joueurs
                   output logic [6:0]         life1,
                   output logic [6:0]         life2,
                   // Interface avec la RAM du labyrinthe
                   output logic [9:0]         ram_raddr, ram_waddr,
                   output logic [3:0]         ram_wdata,
                   output logic               ram_we,
                   input logic [3:0]          ram_rdata,

                   // Interface avec la RAM des flammes
                   output logic [9:0]         flame_ram_raddr, flame_ram_waddr,
                   output logic [2:0]         flame_ram_wdata,
                   output logic               flame_ram_we,
                   input logic [2:0]          flame_ram_rdata,

                   // Numéro du labyrinthe
                   output logic [2:0]         maze_num,

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
   localparam WALL_EMPTY   = 0;
   localparam WALL_1       = 1;
   localparam WALL_2       = 2;
   localparam GATE_RIGHT   = 3;
   localparam GATE_LEFT    = 4;
   localparam GATE_UP      = 5;
   localparam GATE_DOWN    = 6;
   localparam MULTIPLE_BOMB= 7;
   localparam HUGE_FLAME   = 8;
   localparam SPEED_UP     = 9;
   localparam GHOST        = 10;
   localparam PUSH_BOMB    = 11;
   localparam BOMB         = 12;

   // Nombre d'objets affichés au total sur l'écran
   localparam NB_OBJETS    = 3;
   logic [2:0]                                compt_objet;

   // Dégats infligés aux joueurs
   localparam BOMB_DMG     = 1;

   // Variables des effets ces objets
   logic [7:0]                                ghost1;
   logic [7:0]                                ghost2;
   logic                                      multiple_bomb1;
   logic                                      multiple_bomb2;
   logic [10:0]                               huge_flame1, huge_flame2;
   logic [32:0]                               alea1;
   logic [9:0]                                alea;
   logic [10:0]                               speed_up_delay1, speed_up_delay2;
   logic [10:0]                               push_bomb_delay1, push_bomb_delay2;

   // Numéros de sprites des flammes
   localparam FLAME_EMPTY = 0;
   localparam FLAME_INTERSECT = 1;
   localparam FLAME_H = 2;
   localparam FLAME_V = 3;
   localparam FLAME_LEFT = 4;
   localparam FLAME_UP = 5;
   localparam FLAME_RIGHT = 6;
   localparam FLAME_DOWN = 7;

   // Détermine les paramètres de flammes
   logic [3:0] bomb_radius;
   localparam TIME_HUGE_FLAME  = 8;
   localparam SMALL_FLAME_SIZE = 3;
   localparam HUGE_FLAME_SIZE  = 7;

   // Paramètres du speed_up : 10 secondes de durée
   localparam SPEED_UP_DELAY = 10;

   // Délai d'activité du push_bomb
   localparam PUSH_BOMB_DELAY = 10;

   // Constante de déplacement = 32 (taille du sprite)
   localparam SIZE    = 32;

   // Déplacement en x, y pour le joueur1
   logic signed [14:0]                        dx1,dy1;
   // Déplacement en x, y pour le joueur2
   logic signed [14:0]                        dx2,dy2;

   // Coordonnee "décimale" des joueurs
   logic [3:0]                                fplayer1X, fplayer1Y;
   logic [3:0]                                fplayer2X, fplayer2Y;

   // Destination en x, y
   logic signed [14:0]                        player1_goalX, player1_goalY;
   logic signed [14:0]                        player2_goalX, player2_goalY;

   // Machine à etat
   integer                                    state;
   integer                                    return_addr, return_addr2;
   integer                                    count;
   integer                                    player_num;

   // État du jeu
   logic                                      game_state;
   localparam GAME_PLAY = 0;
   localparam GAME_OVER = 1;
   localparam GAME_INIT = 2;

   // État des joueurs
   logic [1:0]                                player1_state, player2_state;
   localparam WAITING = 0;
   localparam MOVING  = 1;
   localparam DEAD    = 2;

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

   // Compteur gérant la modification du fond après la mort d'un personnage
   logic [7:0]                                color_compt;


   //Machine à etats
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       //On place les joueurs au milieu
       begin
          player1_state <= WAITING;
          state         <= 0;
          player1X      <= 128;
          player1Y      <= 128;
          player2X      <= 448;
          player2Y      <= 448;
          v1 <= 32;
          v2 <= 32;
          ram_raddr     <= 0;
          ram_waddr     <= 0;
          ram_wdata     <= 0;
          ram_we        <= 0;
          bomb_ram_raddr <= 0;
          bomb_ram_waddr <= 0;
          bomb_ram_wdata <= 0;
          bomb_ram_we <= 0;

          count  <= 0;
          ghost1  <= 0;
          ghost2  <= 0;
          multiple_bomb1  <= 0;
          multiple_bomb2  <= 0;
          huge_flame1 <= 0;
          huge_flame2 <= 0;
          compt_objet <= 0;
          count <= 0;
          flame_ram_we <= 0;
          flame_ram_waddr <= 0;
          bck_r <= 0;
          bck_g <= 0;
          bck_b <= 230;
          color_compt <= 0;
          game_state <= GAME_INIT;
          maze_num <= 0;
          bomb_radius <= SMALL_FLAME_SIZE;
          life1 <= 100;
          life2 <= 100;
          speed_up_delay1 <= 0;
          speed_up_delay2 <= 0;
          player_num <= 0;
          push_bomb_delay1 <= 0;
          push_bomb_delay2 <= 0;
       end
     else
       begin
          // Par défaut, on ne fait PAS d'écriture dans la RAM
          ram_we <= 0;
          bomb_ram_we <= 0;
          flame_ram_we <= 0;
          flame_ram_waddr <= 0;

          case(state)
            /**************************
             * Phases d'initialisation
             **************************/
            // On commence par effacer de la RAM maze tout ce qui n'est pas un mur.
            // Au passage, on se met en mode GAME_INIT et on initialise les variables internes
            0:
              begin
                 game_state <= GAME_INIT;
                 ram_raddr <= 0;
                 compt_objet <= 0;
                 player1_state <= WAITING;
                 player2_state <= WAITING;
                 count  <= 0;
                 ghost1  <= 0;
                 ghost2  <= 0;
                 multiple_bomb1  <= 0;
                 multiple_bomb2  <= 0;
                 huge_flame1 <= 0;
                 huge_flame2 <= 0;
                 count <= 0;
                 bck_r <= 0;
                 bck_g <= 0;
                 bck_b <= 230;
                 color_compt <= 0;
                 state <= state + 1;
                 bomb_radius <= SMALL_FLAME_SIZE;
                 life1 <= 100;
                 life2 <= 100;
                 speed_up_delay1 <= 0;
                 speed_up_delay2 <= 0;
                 v1 <= 32;
                 v2 <= 32;
                 player_num <= 0;
                 push_bomb_delay1 <= 0;
                 push_bomb_delay2 <= 0;
              end

            1:
              begin
                 // Temps d'attente
                 state <= state +1;
              end
            2:
              // On regarde s'il y a autre chose qu'un mur à l'emplacement que l'on lit.
              // Si c'est le cas, on le remplace par du vide.
              // Enfin on passe à l'adresse suivante, jusqu'à la fin de la RAM.
              begin
                 if(ram_rdata > GATE_DOWN)
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
                   state <= state + 1;
              end

            5: // Ré-initialisation de la RAM flammes
              begin
                 flame_ram_waddr <= 0;
                 state <= state + 1;
              end

            6: // Ré-initialisation de la RAM flammes
              begin
                 flame_ram_wdata <= 0;
                 flame_ram_we <= 1;
                 flame_ram_waddr <= flame_ram_waddr + 1;
                 if (flame_ram_waddr == (32*32-1))
                   state <= state + 1;
              end

            7:
              // On instancie des objets, jusqu'à qu'on en ait placé NB_OBJETS.
              // On se place sur une case tirée aléatoirement (alea[9:0]).
              // Si cette case est en dehors du terrain de jeu, on en tire une autre.
              if((alea[4:0] < 25) && (alea[9:5]<17))
                begin
                   ram_raddr <= alea;
                   state <= state +1;
                end

            8: begin
               // État d'attente pour lecture RAM
               state <= state + 1;
            end

            9 : begin
               // Si la case tirée au hasard contient du vide, on y place un objet (tiré
               // aléatoirement lui aussi). Sinon, on tire une autre case au hasard.
               state <= state + 1;
               if(ram_rdata == WALL_EMPTY)
                 begin
                    case(alea1[2:0])
                      0, 1:
                        begin
                           ram_wdata <= HUGE_FLAME;
                           ram_we <= 1;
                           ram_waddr <= ram_raddr;
                        end
                      2, 3:
                        begin
                           ram_wdata <= PUSH_BOMB;
                           ram_we <= 1;
                           ram_waddr <= ram_raddr;
                        end
                      4, 5:
                        begin
                           ram_wdata <= SPEED_UP;
                           ram_we <= 1;
                           ram_waddr <= ram_raddr;
                        end
                      6:
                        begin
                           ram_wdata <= GHOST;
                           ram_we <= 1;
                           ram_waddr <= ram_raddr;
                        end
                      7:
                        begin
                           ram_wdata <= MULTIPLE_BOMB;
                           ram_we <= 1;
                           ram_waddr <= ram_raddr;
                        end
                    endcase
                    compt_objet <= compt_objet +1;
                 end
               else
                 state <= 7;
            end // case: 9

            10:
              begin
               // Si on a placé sufisamment d'objets, on démarre le jeu.
               if (compt_objet == NB_OBJETS)
                 begin
                    state <= state + 1;
                    game_state <= GAME_PLAY;
                 end
               else
                 state <= 7;
            end // case: 10

            // On place aléatoirement les joueurs
            11:
              // On tire une position au hasard. Si on est en dehors du labyrinthe, on
              // en retire une autre.
              if((alea[4:0] < 25) && (alea[9:5]<17))
                begin
                   ram_raddr <= alea;
                   state <= state +1;
                end

            12: begin
               // État d'attente pour lecture RAM
               state <= state + 1;
            end

            13 : begin
               // Si la case tirée au hasard contient du vide, on y place le joueur1
               // Sinon on en tire une autre
               state <= state + 1;
               if(ram_rdata == WALL_EMPTY)
                 begin
                    player1X <= ram_raddr[4:0]*32;
                    player1Y <= ram_raddr[9:5]*32;
                    state <= state + 1;
                 end
               else
                 state <= 11;
            end // case: 13

            14:
              // On tire une position au hasard. Si on est en dehors du labyrinthe, on
              // en retire une autre.
              if((alea[4:0] < 25) && (alea[9:5]<17) && (alea[4:0] != player1X[9:5]) && (alea[9:5] != player1Y[9:5]))
                begin
                   ram_raddr <= alea;
                   state <= state +1;
                end

            15: begin
               // État d'attente pour lecture RAM
               state <= state + 1;
            end

            16 : begin
               // Si la case tirée au hasard contient du vide, on y place le joueur2
               // Sinon on en tire une autre
               state <= state + 1;
               if(ram_rdata == WALL_EMPTY)
                 begin
                    player2X <= ram_raddr[4:0]*32;
                    player2Y <= ram_raddr[9:5]*32;
                    state <= state + 1;
                 end
               else
                 state <= 14;
            end // case: 13

            17:
              state <= 100;


            /**************************
             * Traitement du jeu
             **************************/
            100: begin
               // On commence par attendre que EOF soit haut.
               if (EOF)
                 begin
                    state <= state + 1;
                    // Si on est en mode GAME_OVER et qu'on a appuyé sur la touche de RAZ, alors on recommence
                    // la partie (au passage on change de labyrinthe).
                    // Sinon, on va dans l'état de gestion du GAME_OVER et on revient ici
                    if(game_state == GAME_OVER)
                      if(new_game)
                        begin
                           state <= 0;
                           maze_num <= maze_num + 1;
                        end
                      else
                        begin
                           state <= 700;
                           return_addr <= 100;
                        end
                 end
            end

            // XXX TODO : charger le nouveau labyrinthe
            101: begin
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
              begin
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
              end

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
              // Gestion des timers et des flammes
              begin
                 state <= 400;
                 return_addr <= state + 1;
              end

            106:
              // Gestion des explosions en chaîne
              begin
                 state <= 600;
                 return_addr <= state +1;
              end

            107: begin
               // On décrémente les objets s'ils sont différents de zero
               state <= 550;
               return_addr <= state +1;
            end

            108:
              // Gestion de la mort d'un des personnages
              begin
                 state <= 700;
                 return_addr <= state + 1;
              end

            109: begin
               // On repart en attente du EOF
               state <= 100;
            end

            /**************************
             * Déplacement du joueur 1
             **************************/
            200:
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
                        end
                   end
                 else
                   // On est déjà entrain de bouger, on va à l'état qui actualise playerX et playerY
                   begin
                      state <= 220;
                   end
              end // case: 200

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
               // Si on a un objet on va dans la partie qui traite les objets (500)
               // XXX TODO : check la partie en 500
               if (((ram_rdata == WALL_1) || (ram_rdata == WALL_2)) && (ghost1 == 0))
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

            207 :
              begin
                 // Si il y a une bombe, soit on annule le mouvement soit (si le joueur est en
                 // push_bomb) on fait faire un saut quantique à la bombe et on continue le mouvement
                 if (ram_rdata == BOMB)
                   begin
                      if (push_bomb_delay1 != 0)
                        begin
                           // Fait faire un saut quantique à la bombe. En revenant, on est sûr que
                           // l'emplacement actuel est vide donc on peut continuer tranquillement
                           // le mouvement
                           state <= 350;
                           return_addr2 <= state + 1;
                        end
                      else
                        // Annule le mouvement
                        state <= 218;
                   end
                 else
                   state <= state +1;
              end

            208: // Si on a un objet on le traite
              begin
                 if ((ram_rdata == MULTIPLE_BOMB) || (ram_rdata == HUGE_FLAME) || (ram_rdata == SPEED_UP) || (ram_rdata == GHOST) || (ram_rdata == PUSH_BOMB))
                   begin
                      state <= 500;
                      player_num <= 1;
                      return_addr2 <= 220;
                   end
                 else
                   state <= 220;
              end

            218: begin
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
            250:
              begin
                 // Si on n'est pas déjà en train de se déplacer, on regarde les touches et on déclenche éventuellement
                 // un nouveau déplacement. Sinon, on continue le déplacement.
                 if (player2_state == WAITING)
                   begin
                      state <= state + 1;
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
                        begin
                           state <= return_addr;
                           player2_sprite <= 0;
                        end // else: !if(j2_left)
                   end // if (player2_state == WAITING)
                 else
                   //  On est déjà entrain de bouger, on va à l'état qui actualise playerX et playerY
                   begin
                      state <= 280;
                   end
              end // case: 250

            251: begin
               // On se prépare à bouger. On vérifie d'abord si la case de destination est libre.
               ram_raddr <= {player2_goalY[13:9], player2_goalX[13:9]};
               state <= state + 1;
            end

            252: begin
               // État d'attente (dans l'état actuel on présente à la RAM l'adresse de la valeur à lire,
               // on n'aura la donnée qu'au prochain cycle)
               state <= state + 1;
            end

            253: begin
               // Vérifie que la case de destination est bien vide. Si oui, on effectue le mouvement.
               // Si non on passe au test suivant (porte et qu'on va dans la bonne direction)
               if (ram_rdata == WALL_EMPTY)
                 state <= 280;
               else
                 state <= state + 1;
            end

            254 : begin
               // Si on a un mur, on annule le mouvement
               // Si on a un objet on va dans la partie qui traite les objets (500)
               // XXX TODO : check la partie en 500
               if ((ram_rdata == WALL_1) || (ram_rdata == WALL_2) && (ghost2 == 0))
                 state <= 268;
               else
                 state <= state + 1;
            end

            255 : begin
               // Si on est sur une porte et qu'on ne va pas dans le bon sens, annule le mouvement
               if (((ram_rdata == GATE_RIGHT) & (dx2 <= 0)) ||
                   ((ram_rdata == GATE_LEFT)  & (dx2 >= 0)) ||
                   ((ram_rdata == GATE_DOWN)  & (dy2 <= 0)) ||
                   ((ram_rdata == GATE_UP)    & (dy2 >= 0)))
                 state <= 268;
               else
                 state <= state + 1;
            end

            256 : begin
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

            257 :
              begin
                 // Si il y a une bombe, soit on annule le mouvement soit (si le joueur est en
                 // push_bomb) on fait faire un saut quantique à la bombe et on continue le mouvement
                 if (ram_rdata == BOMB)
                   begin
                      if (push_bomb_delay2 != 0)
                        begin
                           // Fait faire un saut quantique à la bombe. En revenant, on est sûr que
                           // l'emplacement actuel est vide donc on peut continuer tranquillement
                           // le mouvement
                           state <= 350;
                           return_addr2 <= state + 1;
                        end
                      else
                        // Annule le mouvement
                        state <= 268;
                   end
                 else
                   state <= state +1;
              end

            258 :// Si on a un objet on le traite sinon on arrete le mouvement
              begin
                 if ((ram_rdata == MULTIPLE_BOMB) || (ram_rdata == HUGE_FLAME) || (ram_rdata == SPEED_UP) || (ram_rdata == GHOST) || (ram_rdata == PUSH_BOMB))
                   begin
                      state <= 500;
                      player_num <= 2;
                      return_addr2 <= 280;
                   end

                 else state <= 280;
              end

            268 : begin
               // Annule le mouvement
               dx2 <= 0;
               dy2 <= 0;
               player2_state <= WAITING;
               player2_goalX <= {player2X, 4'b0000};
               player2_goalY <= {player2Y, 4'b0000};
               state <= return_addr;
            end

            280 :
              begin
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

                 // Revient à la routine de gestion principale
                 state <= state +1;
              end // case: 251

            281 :
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


            282 :
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
            283:
              // On va a gauche
              begin
                 if(player2X - player2_goalX[14:4]< 16  )
                   player2_sprite <= 6;
                 else
                   player2_sprite <= 5;
                 state <= return_addr;
              end // case: 223

            284:
              // On se déplace vers le bas
              begin
                 if( player2_goalY[14:4] - player2Y  < 16)
                   player2_sprite <= 2;
                 else
                   player2_sprite <= 1;
                 state <= return_addr;
              end // case: 224
            285 :
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


            /****************************************************************
             * Saut quantique des bombes
             * Si la bombe a déjà explosé, on ne fait rien.
             * Sinon, on cherche une case libre, et on y déplace la bombe
             ***************************************************************/
            350: begin
               // Si on a une flamme à l'emplacement courant, la bombe a déjà explosé, on ne fait rien.
               // BTW ram_raddr contient {player1_goalY[13:9], player1_goalX[13:9]} (ou player2)
               flame_ram_raddr <= ram_raddr;
               state <= state + 1;
            end

            351: begin
               // Attente lecture RAM
               state <= state + 1;
            end

            352: begin
               if(flame_ram_rdata != FLAME_EMPTY)
                 state <= return_addr2;
               else
                 state <= state + 1;
            end

            353: begin
               // Tire une case au hasard et lit ce qui se trouve là
               if((alea[4:0] < 25) && (alea[9:5]<17))
                begin
                   ram_raddr <= alea;
                   state <= state+1;
                end
            end

            354:
              // État d'attente pour lecture sur la ram
              state <= state + 1;

            355:
              // Si la case tirée au hasard ne contient rien, on y écrit le sprite
              // de la bombe, sinon on en retire une autre.
              if(ram_rdata == WALL_EMPTY)
                begin
                   ram_wdata <= BOMB;
                   ram_we <= 1;
                   ram_waddr <= ram_raddr;
                   state <= state + 1;
                end
              else
                state <= 353;

            356: begin
               // Cherche dans la RAM bombes l'entrée correspondant à la bombe actuelle
               bomb_ram_raddr <= 0;
               state <= state + 1;
            end

            357: begin
               // Cycle attente RAM
               state <= state + 1;
            end

            358: begin
               // Actualise la position de la bombe
               if(bomb_ram_rdata[9:0] == flame_ram_raddr)
                 begin
                    bomb_ram_wdata <= bomb_ram_rdata;
                    bomb_ram_wdata[9:0] <= ram_raddr;
                    bomb_ram_we <= 1;
                    bomb_ram_waddr <= bomb_ram_raddr;
                    state <= state + 1;
                 end
               else
                 begin
                    state <= 357;
                    bomb_ram_raddr <= bomb_ram_raddr + 1;
                 end
            end

            359: begin
               // Efface la bombe de son emplacement d'origine
               // ram_raddr a été modifié, la case d'origine est sauvée dans flame_ram_raddr
               ram_waddr <= flame_ram_raddr;
               ram_raddr <= flame_ram_raddr;
               ram_we <= 1;
               ram_wdata <= WALL_EMPTY;
               state <= state + 1;
            end

            360:
              // Retour
              state <= return_addr2;





            /**********************
             *     Timers         *
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
                 if(bomb_ram_rdata[18:10] <= 72)
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
              // On remplace tous les sprites flammes autour de la bombe
              // par du vide.
              // On commence par retirer le centre
              begin
                 flame_ram_wdata <= FLAME_EMPTY;
                 flame_ram_waddr <= bomb_ram_rdata[9:0];
                 flame_ram_we <= 1;
                 state <= state + 1;
                 count <= 1;
              end

            411:
              //On va retirer les flammes sur la gauche
              if(count < HUGE_FLAME_SIZE)
                begin
                   flame_ram_wdata <= FLAME_EMPTY;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] - count;
                   flame_ram_we <= 1;
                   count <= count + 1;
                end
              else
                begin
                   count <= 1;
                   state <= state + 1;
                end // else: !if(count < bomb_radius)


            412:
              //On va retirer les flammes sur la droite
              if(count < HUGE_FLAME_SIZE)
                begin
                   flame_ram_wdata <= FLAME_EMPTY;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] + count;
                   flame_ram_we <= 1;
                   count <= count + 1;
                end
              else
                begin
                   count <= 1;
                   state <= state + 1;
                end // else: !if(count < bomb_radius)


            413:
              //On va retirer les flammes vers le haut
              if(count < HUGE_FLAME_SIZE)
                begin
                   flame_ram_wdata <= FLAME_EMPTY;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] - (count * 32);
                   flame_ram_we <= 1;
                   count <= count + 1;
                end
              else
                begin
                   count <= 1;
                   state <= state + 1;
                end // else: !if(count < bomb_radius)

            414:
              //On va retirer les flammes vers le bas
              if(count < HUGE_FLAME_SIZE)
                begin
                   flame_ram_wdata <= FLAME_EMPTY;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] + (count * 32);
                   flame_ram_we <= 1;
                   count <= count + 1;
                end
              else
                begin
                   count <= 1;
                   state <= state + 1;
                end // else: !if(count < bomb_radius)


            415:
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


            416:
              // On passe à la prochaine bombe dans la liste
              state <= 403;


            /****************************************
             * Gestion des flammes
             * (on doit revenir en 403)
             ****************************************/
            420 :
              begin
                 // On commence par mettre une intersection flamme à l'endroit où se trouve la bombe
                 flame_ram_wdata <= FLAME_INTERSECT;
                 flame_ram_we <= 1;
                 flame_ram_waddr <= bomb_ram_rdata[9:0];
                 state <= state +1;
              end

            421:
              // On initialise le compteur count à 1
              begin
                 count <= 1;
                 state <= state + 1;
              end

            422 :
              // Lecture de la Ram maze pour savoir ce qu'on a à gauche de la bombe
              // dans son rayon d'action
              begin
                 if(count < bomb_radius)
                   begin
                      ram_raddr <= bomb_ram_rdata[9:0] - count;
                   end
                 state <= state + 1;
              end

            423:
              //attente de la lecture
              state <= state + 1;

            424:
              // On regarde dans la Ram maze
              // S'il y a un mur, on abandonne la propagation des flammes et on passe à
              // l'étude de la prochaine direction de feu.
              // S'il y a une bombe, on affiche un intersection et on passe à l'étude de la prochaine direction de feu.
              // Sinon, on affiche une flamme
              if((ram_rdata == WALL_1) ||
                 (ram_rdata == GATE_UP) || (ram_rdata == GATE_DOWN) ||
                 (ram_rdata == GATE_LEFT) || (ram_rdata == GATE_RIGHT))
                state <= state + 1;
              else if (ram_rdata == BOMB)
                begin
                   flame_ram_wdata <= FLAME_INTERSECT;
                   flame_ram_we <= 1;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] - count;
                   state <= state + 1;
                end
              else
                begin
                   //On détruit le mur s'il est destructible
                   if (ram_rdata == WALL_2)
                     begin
                        ram_wdata <= WALL_EMPTY;
                        ram_we <= 1;
                        ram_waddr <= ram_raddr ;
                     end
                   if (count == (bomb_radius - 1))
                     begin
                        flame_ram_wdata <= FLAME_LEFT;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] - count;
                        state <= state + 1;
                     end
                   else
                     begin
                        flame_ram_wdata <= FLAME_H;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] - count;
                        count <= count + 1;
                        state <= 422;
                     end // else: !if(count == (radius - 1))
                end // else: !if((ram_rdata == WALL_1) ||...

            425:
              // On initialise le compteur count à 1
              begin
                 count <= 1;
                 state <= state + 1;
              end

            426:
              // Lecture de la Ram maze pour savoir ce qu'on a à droite de la bombe
              // dans son rayon d'action
              begin
                 if(count < bomb_radius)
                   begin
                      ram_raddr <= bomb_ram_rdata[9:0] + count;
                   end
                 state <= state + 1;
              end

            427:
              //attente de la lecture
              state <= state + 1;

            428:
              // On regarde dans la Ram maze
              // S'il y a un mur, on passe à la suite
              // Sinon, on affiche une flamme
              if((ram_rdata == WALL_1) ||
                 (ram_rdata == GATE_UP) || (ram_rdata == GATE_DOWN) ||
                 (ram_rdata == GATE_LEFT) || (ram_rdata == GATE_RIGHT))
                state <= state + 1;
              else if (ram_rdata == BOMB)
                begin
                   flame_ram_wdata <= FLAME_INTERSECT;
                   flame_ram_we <= 1;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] + count;
                   state <= state + 1;
                end
              else
                begin
                   //On détruit le mur s'il est destructible
                   if (ram_rdata == WALL_2)
                     begin
                        ram_wdata <= WALL_EMPTY;
                        ram_we <= 1;
                        ram_waddr <= ram_raddr ;
                     end
                   if (count == (bomb_radius - 1))
                     begin
                        flame_ram_wdata <= FLAME_RIGHT;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] + count;
                        state <= state + 1;
                     end
                   else
                     begin
                        flame_ram_wdata <= FLAME_H;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] + count;
                        count <= count + 1;
                        state <= 426;
                     end // else: !if(count == (radius - 1))
                end // else: !if((ram_rdata == WALL_1) ||...

            429:
              // On initialise le compteur count à 1
              begin
                 count <= 1;
                 state <= state + 1;
              end

            430:
              // Lecture de la Ram maze pour savoir ce qu'on a au-dessus de la bombe
              // dans son rayon d'action
              begin
                 if(count < bomb_radius)
                   begin
                      ram_raddr <= bomb_ram_rdata[9:0] - (count * 32) ;
                   end
                 state <= state + 1;
              end

            431:
              //attente de la lecture
              state <= state + 1;

            432:
              // On regarde dans la Ram maze
              // S'il y a un mur, on passe à la suite
              // Sinon, on affiche une flamme
              if((ram_rdata == WALL_1) ||
                 (ram_rdata == GATE_UP) || (ram_rdata == GATE_DOWN) ||
                 (ram_rdata == GATE_LEFT) || (ram_rdata == GATE_RIGHT))
                state <= state + 1;
              else if (ram_rdata == BOMB)
                begin
                   flame_ram_wdata <= FLAME_INTERSECT;
                   flame_ram_we <= 1;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] - (count * 32);
                   state <= state + 1;
                end
              else
                begin
                   //On détruit le mur s'il est destructible
                   if (ram_rdata == WALL_2)
                     begin
                        ram_wdata <= WALL_EMPTY;
                        ram_we <= 1;
                        ram_waddr <= ram_raddr ;
                     end
                   if (count == (bomb_radius - 1))
                     begin
                        flame_ram_wdata <= FLAME_UP;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] - (count * 32) ;
                        state <= state + 1;
                     end
                   else
                     begin
                        flame_ram_wdata <= FLAME_V;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] - (count * 32) ;
                        state <= 430;
                        count <= count + 1;
                     end
                end // else: !if((ram_rdata == WALL_1) ||...

            433:
              // On initialise le compteur count à 1
              begin
                 count <= 1;
                 state <= state + 1;
              end

            434:
              // Lecture de la Ram maze pour savoir ce qu'on a au-dessous de la bombe
              // dans son rayon d'action
              begin
                 if(count < bomb_radius)
                   begin
                      ram_raddr <= bomb_ram_rdata[9:0] + (count * 32) ;
                   end
                 state <= state + 1;
              end

            435:
              //attente de la lecture
              state <= state + 1;

            436:
              // On regarde dans la Ram maze
              // S'il y a un mur, on passe à la suite
              // Sinon, on affiche une flamme
              if((ram_rdata == WALL_1) ||
                 (ram_rdata == GATE_UP) || (ram_rdata == GATE_DOWN) ||
                 (ram_rdata == GATE_LEFT) || (ram_rdata == GATE_RIGHT))
                state <= state + 1;
              else if (ram_rdata == BOMB)
                begin
                   flame_ram_wdata <= FLAME_INTERSECT;
                   flame_ram_we <= 1;
                   flame_ram_waddr <= bomb_ram_rdata[9:0] + (count * 32);
                   state <= state + 1;
                end
              else
                begin
                   //On détruit le mur s'il est destructible
                   if (ram_rdata == WALL_2)
                     begin
                        ram_wdata <= WALL_EMPTY;
                        ram_we <= 1;
                        ram_waddr <= ram_raddr ;
                     end
                   if (count == (bomb_radius - 1))
                     begin
                        flame_ram_wdata <= FLAME_DOWN;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] + (count * 32) ;
                        state <= state + 1;
                     end
                   else
                     begin
                        flame_ram_wdata <= FLAME_V;
                        flame_ram_we <= 1;
                        flame_ram_waddr <= bomb_ram_rdata[9:0] + (count * 32) ;
                        state <= 434;
                        count <= count + 1;
                     end // else: !if(count == (radius - 1))
                end // else: !if((ram_rdata == WALL_1) ||...

            437:
              state <= 403;

            /************************
             * Attrapage d'un objet
             ************************/
            500:
              // On s'occupe de l'attrapage d'un objet après on retourne au traitement
              // du mouvement (player_num).
              // Si on a un objet on affecte les effets et on l'enlève de l'écran.
              begin
                 if(ram_rdata == MULTIPLE_BOMB)
                   begin
                      if (player_num == 1)
                        multiple_bomb1 <= multiple_bomb1 + 10;
                      if (player_num == 2)
                        multiple_bomb2 <= multiple_bomb2 + 10;
                   end
                 if(ram_rdata == HUGE_FLAME)
                   begin
                      if (player_num == 1)
                        huge_flame1 <= TIME_HUGE_FLAME*72;
                      if (player_num == 2)
                        huge_flame2 <= TIME_HUGE_FLAME*72;
                   end
                 if(ram_rdata == SPEED_UP)
                   begin
                      if ((player_num == 1) && (v1<128))
                        begin
                           v1 <= v1+32;
                           speed_up_delay1 <= SPEED_UP_DELAY * 72;
                        end
                      if ((player_num == 2) && (v2<128))
                        begin
                           v2 <= v2+32;
                           speed_up_delay2 <= SPEED_UP_DELAY * 72;
                        end
                   end
                 if(ram_rdata == GHOST)
                   begin
                      if (player_num == 1)
                        ghost1 <= 72*3;
                      if (player_num == 2)
                        ghost2 <= 72*3;
                   end
                 if(ram_rdata == PUSH_BOMB)
                   begin
                      if (player_num == 1)
                        push_bomb_delay1 <= 72*PUSH_BOMB_DELAY;
                      if (player_num == 2)
                        push_bomb_delay2 <= 72*PUSH_BOMB_DELAY;
                   end


                 ram_wdata <= WALL_EMPTY;
                 ram_we <= 1;
                 ram_waddr <= ram_raddr;
                 state <= state +1;
              end // case: 500


            501 :
              // On fait arriver un nouvel objet à un emplacement aléatoire.
              // Trouvons une case du labyrinthe vide.
              // alea[9:0] contient l'adresse d'une case aléatoire. Si on est en dehors
              // du labyrinthe, on retire une autre case. Sinon, on passe à la suite
              if((alea[4:0] < 25) && (alea[9:5]<17))
                begin
                   ram_raddr <= alea;
                   state <= state +2;
                end

            503 :
              // État d'attente pour lecture sur la ram
              state <= state + 1;

            504 :
              // Si la case tirée au hasard ne contient rien, on y écrit le sprite
              // du nouvel objet et on revient au traitement normal du jeu.
              // Sinon, on retire une autre case au hasard.
              if(ram_rdata == WALL_EMPTY)
                begin
                   case(alea1[2:0])
                     0, 1:
                       begin
                          ram_wdata <= HUGE_FLAME;
                          ram_we <= 1;
                          ram_waddr <= ram_raddr;
                       end
                     2, 3:
                       begin
                          ram_wdata <= PUSH_BOMB;
                          ram_we <= 1;
                          ram_waddr <= ram_raddr;
                       end
                     4, 5:
                       begin
                          ram_wdata <= SPEED_UP;
                          ram_we <= 1;
                          ram_waddr <= ram_raddr;
                       end
                     6:
                       begin
                          ram_wdata <= GHOST;
                          ram_we <= 1;
                          ram_waddr <= ram_raddr;
                       end
                     7:
                       begin
                          ram_wdata <= MULTIPLE_BOMB;
                          ram_we <= 1;
                          ram_waddr <= ram_raddr;
                       end
                   endcase

                   state <= return_addr2;
                end // if (ram_rdata == WALL_EMPTY)
              else
                state <= 501;


            /*************************
             * Gestion des objets
             *************************/
            550 : // Décrémente les objets à effet temporaire
              begin
                 if (ghost1 != 0)
                   ghost1 <= ghost1 -1;
                 if (ghost2 != 0)
                   ghost2 <= ghost2 -1;
                 if (huge_flame1 != 0)
                   huge_flame1 <= huge_flame1 -1;
                 if (huge_flame2 != 0)
                   huge_flame2 <= huge_flame2 -1;

                 if((huge_flame1>0) || (huge_flame2>0))
                   bomb_radius <= HUGE_FLAME_SIZE;
                 else
                   bomb_radius <= SMALL_FLAME_SIZE;

                 if(speed_up_delay1 != 0)
                   speed_up_delay1 <= speed_up_delay1 - 1;
                 if(speed_up_delay2 != 0)
                   speed_up_delay2 <= speed_up_delay2 - 2;
                 if(speed_up_delay1 == 0)
                   v1 <= 32;
                 if(speed_up_delay2 == 0)
                   v2 <= 32;

                 if(push_bomb_delay1 != 0)
                   push_bomb_delay1 <= push_bomb_delay1 - 1;
                 if(push_bomb_delay2 != 0)
                   push_bomb_delay2 <= push_bomb_delay1 - 2;

                 state <= return_addr;
              end // case: 550

            // XXX TODO :
            // Gestion du push bomb
            // si on a une push bomb on va bouger la bomb qu'on a lu et la mettre n'importe ou
            // donc il faut aller la chercher dans la ram des bombes, modifier ses 10 dernier bits en leur affectant si c'est valide les 10 derniers bits de alea1
            // sinon rechercher une autre place et il faut aussi modifier le sprite


            /*************************************************
             * Gestion des explosions en chaîne
             *************************************************/
            600:
              // On parcourt à la fois la ram maze et la ram flame
              // afin de regarder si une flamme est superposée à une bombe.
              // Si c'est le cas, on provoque l'explosion de la bombe en question
              begin
                 flame_ram_raddr <= 0;
                 ram_raddr <= 0;
                 state <= state + 1;
              end

            601:
              // Attente de lecture
              begin
                 state <= state + 1;
              end

            602:
              // Comparaison des valeurs des 2 Ram
              begin
                 // Si une flamme est superposée à une bombe, cette dernière explose.
                 if((flame_ram_rdata != FLAME_EMPTY) && (ram_rdata == BOMB))
                   // Il faut chercher la bombe dont les coordonnées sont pointés
                   state <= 605;
                 else
                   state <= state + 1;
              end

            603:
              if(ram_raddr !=1023)
                begin
                   flame_ram_raddr <= ram_raddr + 1;
                   ram_raddr <= ram_raddr + 1;
                   state <= 601;
                end
              else
                state <= return_addr;

            605:
              // On parcourt la ram des bombes pour trouver celle qui doit exploser
              begin
                 bomb_ram_raddr <= 0;
                 state <= state + 1;
              end

            606:
              // Attente de lecture
              state <= state + 1;

            607:
              // On regarde les coordonnées de la bombe.
              // Si c'est les bons, on a trouvé la bombe adéquate.
              // On vérifie alors son timer. S'il est supérieur à 72
              // on le met à 72. Sinon, on n'y touche pas.
              begin
                 if(bomb_ram_rdata[9:0] == ram_raddr)
                   if(bomb_ram_rdata[18:10] > 72)
                     begin
                        bomb_ram_wdata <= {9'd72, ram_raddr} ;
                        bomb_ram_we <= 1;
                        bomb_ram_waddr <= bomb_ram_raddr;
                        state <= 603;
                     end
                   else
                     state <= 603;
                 else
                   begin
                      bomb_ram_raddr <= bomb_ram_raddr + 1;
                      state <= 606;
                   end
              end


            /******************************************************************
             * Game over
             * On regarde s'il y a une flamme sous chacun des joueurs. Si oui,
             * on passe en mode game over.
             ******************************************************************/
            700:
              // Lit la RAM flammes à l'endroit du joueur1;
              begin
                 flame_ram_raddr <= {player1Y[9:5], player1X[9:5]};
                 state <= state + 1;
              end

            701 : begin
               // Cycle d'attente lecture RAM
               state <= state + 1;
            end

            702 : begin
               // Si on a une flamme, alors on marque le joueur1 comme mort
               if (flame_ram_rdata != FLAME_EMPTY)
                 begin
                    if((life1 > 100) || (life1 == 0))
                      begin
                         game_state <= GAME_OVER;
                         player1_state <= DEAD;
                         life1 <= 0;
                      end
                    else
                    life1 <= life1 - BOMB_DMG;
                 end

                       state <= state + 1;
            end


            703:
              // Lit la RAM flammes à l'endroit du joueur2;
              begin
                 flame_ram_raddr <= {player2Y[9:5], player2X[9:5]};
                 state <= state + 1;
              end

            704 :
              begin
                 // Cycle d'attente lecture RAM
                 state <= state + 1;
              end

            705 : begin
               // Si on a une flamme, alors on marque le joueur2 comme mort
               if (flame_ram_rdata != FLAME_EMPTY)
                 begin
                    if((life2 > 100) || (life2 == 0))
                         begin
                            game_state <= GAME_OVER;
                            player2_state <= DEAD;
                         end
                    else
                      life2 <= life2 - BOMB_DMG;
                 end

               state <= state + 1;
            end

            706:
              // On change la couleur du fond si on est en GAME_OVER
                       begin
                          if ((bck_r < 230) && (game_state == GAME_OVER))
                            begin
                               bck_r <= bck_r +1;
                               bck_b <= bck_b -1;
                            end
                          state <= return_addr;
                       end



          endcase // case (state)
       end

   // BOMB RAM
   always @(posedge clk)
     if(bomb_ram_we)
       bomb_ram[bomb_ram_waddr] <= bomb_ram_wdata;

   always @(posedge clk)
     bomb_ram_rdata <= bomb_ram[bomb_ram_raddr];

   // Instantiation du générateur aléatoire
   lfsr lfsr(.clk(clk),
             .reset_n(reset_n),
             .data(alea1)
             );

   always @(*)
     alea <= alea1[7:0];

   // debug
   assign  debug = {huge_flame2, 4'b0, huge_flame1};

endmodule // controleur
