module maze (input logic         clk,
             input logic signed [10:0] spotX,
             input logic signed [10:0] spotY,
             output logic [9:0]        wall_centerX,
             output logic [9:0]        wall_centerY,
             output logic [3:0]        wall_num,

             // Interface vers le contrôleur
             input logic [9:0]         ram_raddr, ram_waddr,
             input logic [3:0]         ram_wdata,
             input logic               ram_we,
             output logic [3:0]        ram_rdata,
             input logic               active
             );

   // taille de la partie active, fonction de la résolution
   localparam integer                  VACTIVE = 600;
   localparam integer                  HACTIVE = 800;
   localparam integer                  MAZEX = 25;
   localparam integer                  MAZEY = 17;


   // RAM qui contient le plan du labyrinthe(25X17 --> 32x32)
   logic [3:0]                         ram[0:32*32-1];
   logic [9:0]                         ram_raddr_internal;

   // On définit les coins (en haut à gauche)des sprites à afficher
   // spotX : un numéro de carré sur 5 bits + une offset dans le carré sur 5 bits
   logic [4:0]                         offsetX;
   logic [4:0]                         num_carreX;
   logic [4:0]                         offsetY;
   logic [4:0]                         num_carreY;

   assign {num_carreX, offsetX} = spotX;
   assign {num_carreY, offsetY} = spotY;

   always @(*)
     if(active)
       ram_raddr_internal <= {num_carreY, num_carreX};
     else
       ram_raddr_internal <= ram_raddr;

   // On charge le plan du jeu dans la RAM
   initial
     $readmemh("../maze/maze2.lst", ram);

   // Partie lecture de la RAM
   always @(posedge clk)
     ram_rdata <= ram[ram_raddr_internal];

   // Partie écriture de la RAM : on n'écrit que si ram_we est haut.
   always @(posedge clk)
     if(ram_we)
       ram[ram_waddr]<= ram_wdata;

   // Si on est en dehors du labyrinthe, on affiche du vide
   always @(*)
     if ((spotX > (24*32+31)) || (spotX < 0) || (spotY > (16*32+31)) || (spotY < 0))
       wall_num <= 0;
     else
       wall_num <= ram_rdata;

   // Génération de la position du mur sur lequel se trouve le spot
   // On le fait de façon synchrone, pour que wall_centerX/Y soient
   // synchronisés avec wall_num
   always @(posedge clk)
     begin
        wall_centerX <= num_carreX*32;
        wall_centerY <= num_carreY*32;
     end

endmodule // maze
