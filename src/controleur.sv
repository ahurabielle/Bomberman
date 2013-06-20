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
       end
    // si le verou est a un et que j ai recu une donnée du clavier alors je bouge
     else if(verou_trame)
       begin
          if(j1_up &&  (centerY1 >= 0))
            centerY1 <= centerY1 - 1;
          if(j1_down && (centerY1 < VACTIVE))
            centerY1 <= centerY1 + 1;
          if(j1_right && (centerX1 < (HACTIVE - 32)))
            centerX1 <= centerX1 + 1;
          if(j1_left && (centerX1 >= 0))
            centerX1 <= centerX1 - 1;
          if(j2_up &&  (centerY2 >= 0))
             centerY2 <= centerY2 - 1;
          if(j2_down && (centerY2 < VACTIVE))
            centerY2 <= centerY2 + 1;
          if(j2_right && (centerX2 < (HACTIVE - 32)))
            centerX2 <= centerX2 + 1;
          if(j2_left && (centerX2 >= 0))
            centerX2 <= centerX2 - 1;
       end // if (verou_trame)

endmodule // controleur













