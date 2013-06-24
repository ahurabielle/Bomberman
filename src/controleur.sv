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
                   // correspond au sprite du j1 affiché
                   output logic [2:0] player1_num,
                   // correspond au sprite du j2 affiché
                   output logic [2:0] player2_num,
                   // coordonnee du centre
                   output logic [9:0] player1_centerX,
		           output logic [9:0] player1_centerY,
                   output logic [9:0] player2_centerX,
                   output logic [9:0] player2_centerY

		           );

   localparam FACE    = 0;
   localparam UP1     = 1;
   localparam UP2     = 2;
   localparam RIGHT1  = 3;
   localparam RIGHT2  = 4;
   localparam LEFT1   = 5;
   localparam LEFT2   = 6;


   // variables locales
   // est on ou pas dans la trame
   logic                              verou_trame ;
   // compteur permettant la réduction de vitesse de l'horloge
   logic [10:0]                       compt;
   // taille de la fenetre active
   localparam integer                 HACTIVE = 800;
   localparam integer                 VACTIVE = 600;
   // compteur permettant de faire marcher les sprites
   logic [24:0]                       compt_player1;
   logic [24:0]                       compt_player2;

   // instantiation des compteurs qui vont servir a alterner les sprites quand le bonhomme marche
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       begin
          compt_player1 <= 0;
          compt_player2 <= 0;
       end
     else
       begin
          // si on appuye sur une touche de mouvement le compteur correspondant
          // est incrémenté
          if((j1_up)|(j1_down)|(j1_left)|(j1_right))
            compt_player1 <= compt_player1 + 1;
          if((j2_up)|(j2_down)|(j2_left)|(j2_right))
            compt_player2 <= compt_player2 + 1;
       end

   // instantiation du verou, est à 1 quand on est à la fin d'une trame pendant un front d'horloge
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       verou_trame <= 0;
     else
       verou_trame <= (EOF);

   // instantiation du compteur pour reduire la vistesse de l horloge
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       compt <= 0;
     else if(~verou_trame)
       compt <= compt + 1;

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
          if(j1_up &&  (player1_centerY >= 0))
            player1_centerY <= player1_centerY - 1;
          if(j1_down && (player1_centerY < VACTIVE-32))
            player1_centerY <= player1_centerY + 1;
          if(j1_right && (player1_centerX < (HACTIVE - 32)))
            player1_centerX <= player1_centerX + 1;
          if(j1_left && (player1_centerX >= 32))
            player1_centerX <= player1_centerX - 1;
          if(j2_up &&  (player2_centerY >= 0))
            player2_centerY <= player2_centerY - 1;
          if(j2_down && (player2_centerY < VACTIVE-32))
            player2_centerY <= player2_centerY + 1;
          if(j2_right && (player2_centerX < (HACTIVE - 32)))
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

endmodule // controleur













