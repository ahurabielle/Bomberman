module maze (input logic         clk,
             input logic signed [10:0]  spotX,
             input logic signed [10:0]  spotY,
             output logic [9:0] wall_centerX,
             output logic [9:0] wall_centerY,
             output logic [3:0]  wall_num
             );

   // taille de la partie active, fonction de la résolution
   localparam integer           VACTIVE = 600;
   localparam integer           HACTIVE = 800;
   localparam integer           MAZEX = 25;
   localparam integer           MAZEY = 17;


   // ROM qui contient le plan du labyrinthe(25X17 --> 32x32)
   logic [3:0]                  rom[0:32*32-1];
   logic [9:0]                  rom_raddr;

   // On définit les coins (en haut à gauche)des sprites à afficher
   // spotX : un numéro de carré sur 5 bits + une offset dans le carré sur 5 bits
   logic [4:0] offsetX;
   logic [4:0] num_carreX;
   logic [4:0] offsetY;
   logic [4:0] num_carreY;

   assign {num_carreX, offsetX} = spotX;
   assign {num_carreY, offsetY} = spotY;

   always @(*)
     if(active)
       begin
          // Si on est en dehors du labyrinthe, on affiche du vide
          if ((spotX > (24*32+31)) || (spotX < 0) || (spotY > (16*32+31)) || (spotY < 0))
            rom_raddr <= 0;
          else
            rom_raddr <= {num_carreY, num_carreX};
       end
     else
       rom_raddr <= addr_from_controleur; // XXX : replace with ???

   // On charge le plan du jeu dans la ROM
   initial
     $readmemh("../maze/maze2.lst", rom);

   // Partie lecture de la RAM
   always @(posedge clk)
       wall_num <= rom[rom_raddr];

   // Partie écriture de la RAM
   always @(posedge clk)
     if(rom_we)
       rom[rom_waddr]< = rom_wdata; // XXX : déclarer et remplacer rom_waddr et rom_wdata par ce qu'il faut


   // Génération de la position du mur sur lequel se trouve le spot
   // On le fait de façon synchrone, pour que wall_centerX/Y soient
   // synchronisés avec wall_num
   always @(posedge clk)
     begin
        wall_centerX <= num_carreX*32;
        wall_centerY <= num_carreY*32;
     end

endmodule // maze
