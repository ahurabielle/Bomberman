`default_nettype none
 module audio (clk,
               reset_n,

               audio_lr,
               audio_clk,
               audio_data,

               tictac, explosion,
               debug
               );

   // Gestion du son
   input               clk;
   input               reset_n;

   input               audio_lr;
   input               audio_clk;
   output              audio_data;

   input logic         tictac,   explosion;
   logic               tictac_r, explosion_r;

   output [31:0]       debug;

   logic               audio_lr_r,audio_lr_rr,
                       audio_clk_r, audio_clk_rr;
   logic               lire;
   logic [16:0]        reg_decal;

   // ROMS audio
   logic [16:0]        snd_address;
   logic [16:0]        end_address;
   logic signed [7:0]  snd_data;

   // Début et fin des samples dans le fichier sounds.lst
   parameter [16:0]    tictac_start = 0;
   parameter [16:0]    tictac_end = 3846;

   parameter [16:0]    explosion_start = 3847;
   parameter [16:0]    explosion_end = explosion_start + 8117;

   parameter taille_sons = explosion_end;

   reg [7:0]           snd_rom [0:taille_sons-1];

   initial
     begin
        $readmemh("../sounds/sounds.lst", snd_rom);
     end

   // Resynchro de tout
   always @(posedge clk)
     begin
        explosion_r <= explosion;
        tictac_r <= tictac;
        audio_lr_r <= audio_lr;
        audio_clk_r <= audio_clk;
        audio_lr_rr <= audio_lr_r;
        audio_clk_rr <= audio_clk_r;
     end


   always_ff @(posedge clk)
     snd_data <= snd_rom[snd_address];

   always_ff @(posedge clk or negedge reset_n)
     if (~reset_n)
       begin
          snd_address <= 0;
          end_address <= 0;
          lire <= 0;
       end
     else
       begin

          if(~lire)
            begin
               if (tictac_r)
                 begin
                    snd_address <= tictac_start;
                    end_address <= tictac_end;
                    lire <= 1;
                 end
               else if (explosion_r)
                 begin
                    snd_address <= explosion_start;
                    end_address <= explosion_end;
                    lire <= 1;
                 end
            end

          if (lire)
            begin
               if (audio_lr_rr != audio_lr_r)
                 // On a eu une transition de trame, on charge le registre à décalage avec l'échantillon courant
                 begin
                    reg_decal <= {1'b0, snd_data, 8'b0};
                    if (~audio_lr_r)
                      begin
                         if (snd_address == end_address)
                           lire <= 0;
                         else
                           snd_address <= snd_address + 1;
                      end
                 end
               else if (audio_clk_rr & ~audio_clk_r)
                 begin
                    reg_decal[16:1] <= reg_decal[15:0];
                 end
            end // if (lire)
       end // else: !if(~reset_n)

   assign debug = {snd_address[16:0], 4'b0, audio_lr, audio_clk, audio_data, lire};
   assign audio_data = reg_decal[15];

endmodule