module controleur (input                      clk,
		           input                      reset_n,
		           input logic                SOF, // va délimiter le temps durant lequel
                   //  center pourra etre modifie
		           input logic                EOF, // va délimiter le temps durant lequel
                   //  center pourra etre modifie
                   input logic                j1_up,
                   input logic                j1_down,
                   input logic                j1_left,
                   input logic                j1_right,
                   input logic                j2_up,
                   input logic                j2_down,
                   input logic                j2_left,
                   input logic                j2_right,
                   output logic [2:0]          player1_num, // correspond au sprite du j1 affiché
                   output logic [2:0]          player2_num, // correspond au sprite du j2 affiché
                   output logic signed [10:0] centerX1,// coordonnee en X du centre
		           output logic signed [10:0] centerY1, // coordonnee en Y du centre
                   output logic signed [10:0] centerX2,
                   output logic signed [10:0] centerY2

		           );

   // variables locales
   logic                                      verou_trame ; // est on ou pas dans la trame
   logic [10:0]                               compt;        // compteur
   localparam integer                         HACTIVE = 800;// taille horizontale de la frame
   localparam integer                         VACTIVE = 600;// taille verticale de la frame
   logic [24:0]                                compt_player1;
   logic [25:0]                                compt_player2;

   // instantiation des compteurs qui vont servir a alterner les sprites quand le bonhomme marche
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       begin
          compt_player1 <= 0;
          compt_player2 <= 0;
       end
     else
       begin
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
	      centerX1 <= 400;
	      centerY1 <= 300;
          centerX2 <= 450;
          centerY2 <= 300;
       end
    // si le verou est a un et que j ai recu une donnée du clavier alors je bouge
     else if(verou_trame)
       begin
          if(j1_up &&  (centerY1 >= 0))
            centerY1 <= centerY1 - 1;
          if(j1_down && (centerY1 < VACTIVE-32))
            centerY1 <= centerY1 + 1;
          if(j1_right && (centerX1 < (HACTIVE - 32)))
            centerX1 <= centerX1 + 1;
          if(j1_left && (centerX1 >= 32))
            centerX1 <= centerX1 - 1;
          if(j2_up &&  (centerY2 >= 0))
             centerY2 <= centerY2 - 1;
          if(j2_down && (centerY2 < VACTIVE-32))
            centerY2 <= centerY2 + 1;
          if(j2_right && (centerX2 < (HACTIVE - 32)))
            centerX2 <= centerX2 + 1;
          if(j2_left && (centerX2 >= 32))
            centerX2 <= centerX2 - 1;
       end // if (verou_trame)


   // En fonction du mouvement du bonhomme on va afficher des sprites différents
   always @ (posedge clk)
     begin
        // De base le bonhomme nous fait fasse
        player1_num <= 2;
        player2_num <= 2;
        if(j1_up | j1_down)
          player1_num <= (compt_player1 > 16777215); // permet l'alternance des sprites pour donner l'illusion qu'il marche
        else if(j1_left)
          player1_num <= 5 + (compt_player1 > 16777215); // meme chose
        else if(j1_right)
          player1_num <= 3 + (compt_player1 > 16777215); // meme chose
// permet l'alternance des sprites pour donner l'illusion qu'il marche
        if(j2_up | j2_down)
          player2_num <= 5 + (compt_player2 > 16777215);
        else if(j2_left)
          player2_num <= 3 + (compt_player2 > 16777215); // meme chose
        else if(j2_right)
          player2_num <= (compt_player2 > 16777215); // meme chose
     end // always @ (posedge clk)

endmodule // controleur













