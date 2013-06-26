module flame(input logic                clk,
             input logic signed [10:0] spotX,
             input logic signed [10:0] spotY,
		     output logic [7:0]        flame_color,

             //Interface vers le controleur
             input logic [9:0]         flame_ram_raddr, flame_ram_waddr,
             input logic [2:0]         flame_ram_wdata,
             input logic               flame_ram_we,
             output logic [2:0]        flame_ram_rdata,
             input logic               active
             );

   // ROM qui contient les pixels des 8 (7 + 1 vide) sprites (64x64 pixels)
   logic [7:0]                         rom[0:8*1024-1];
   logic [12:0]                        rom_addr;
   logic [7:0]                         color_pixel;

   // On définit les coins (haut gauche) des sprites à afficher.
   logic [9:0]                         flameX;
   logic [9:0]                         flameY;
   logic [4:0]                         num_carreX, num_carreY;
   logic [4:0]                         offsetX, offsetY;

   // Le numéro du sprite à afficher est maintenant stocké dans une Ram de la taille du labyrinthe
   logic [2:0]                         sprite_num;

   // RAM qui contient le plan des flammes du labyrinthe(25X17 --> 32x32)
   logic [2:0]                         flame_ram[0:32*32-1];
   logic [9:0]                         flame_ram_raddr_internal;

   // Affichage du sprite parcouru par le spot
   assign {num_carreX, offsetX} = spotX;
   assign {num_carreY, offsetY} = spotY;
   assign rom_addr = {sprite_num, offsetY, offsetX};

   always @(*)
     if(active)
       flame_ram_raddr_internal <= {num_carreY, num_carreX};
     else
       flame_ram_raddr_internal <= flame_ram_raddr;

   // Partie lecture de la RAM
   always @(posedge clk)
     flame_ram_rdata <= flame_ram[flame_ram_raddr_internal];

   // Partie écriture de la RAM : on n'écrit que si ram_we est haut.
   always @(posedge clk)
     if(flame_ram_we)
       flame_ram[flame_ram_waddr]<= flame_ram_wdata;

   // Si on est en dehors du labyrinthe de flamme, on affiche du vide
   always @(*)
     if ((spotX > (24*32+31)) || (spotX < 0) || (spotY > (16*32+31)) || (spotY < 0))
       sprite_num <= 0;
     else
       sprite_num <= flame_ram_rdata;

   always @(posedge clk)
     color_pixel <= rom[rom_addr];

   // On charge les sprites dans la ROM
   initial
     $readmemh("../sprites/flames.lst", rom);

   // On n'affiche le contenu de la ROM que si le spot est dans le
   // rectangle du sprite
   always @(*)
                 begin
                    flame_color <= 8'd137;
                    if ((spotX >= flameX) && (spotX < (flameX + 32)) &&
                        (spotY >= flameY) && (spotY < (flameY + 32)))
	                  flame_color <= color_pixel;
                 end // always @ begin

   // Génération de la position de la flamme sur laquelle se trouve le spot
   // On le fait de façon synchrone, pour que flameX/Y soient
   // synchronisés avec sprite_num
   always @(posedge clk)
     begin
        flameX <= num_carreX*32;
        flameY <= num_carreY*32;
     end

endmodule // flame
