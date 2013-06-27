`default_nettype none
 module audio (clk,
               reset_n,
               
               audio_lr,
               audio_clk,
               audio_data,

               smash, plouf, 
               debug
               );

   // Gestion du son
   input               clk;
   input               reset_n;               
   
   input               audio_lr;
   input               audio_clk;
   output              audio_data;

   input logic         smash, plouf;

   output [31:0]       debug;
   
   logic               audio_lr_r,audio_lr_rr, 
                       audio_clk_r, audio_clk_rr,
                       smash_r,
                       plouf_r
                       /* synthesis ALTERA_ATTRIBUTE = "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;   
   logic               lire;
   logic [16:0]        reg_decal;

   // ROMS audio
   parameter taille_sons = 12186;

   logic [16:0]        snd_address;
   logic [16:0]        end_address;               
   logic signed [7:0]  snd_data;
   
   parameter [16:0] smash_start = 0;
   parameter [16:0] smash_end = 5243;
   
   parameter [16:0] plouf_start = 5244;
   parameter [16:0] plouf_end = 12185;
   
   reg [7:0]           snd_rom [0:taille_sons-1] /* synthesis ALTERA_ATTRIBUTE = "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101"  */;

   initial
     begin
        $readmemh("../sons/sons.lst", snd_rom);
     end

   // Resynchro de tout
   always @(posedge clk)
     begin
        plouf_r <= plouf;
        smash_r <= smash;
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
               if (smash_r)
                 begin
                    snd_address <= smash_start;
                    end_address <= smash_end;
                    lire <= 1;
                 end
               else if (plouf_r)
                 begin
                    snd_address <= plouf_start;
                    end_address <= plouf_end;
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