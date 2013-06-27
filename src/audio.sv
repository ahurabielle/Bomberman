`default_nettype none
  module audio (input  logic        clk_50,       // Horloge système 50Mhz
                input logic         reset_n, // Reset (actif bas)

                // I2C configuration port
                output logic        i2c_sclk,
                inout               i2c_sdat,

                // Codec chip ports (codec in slave mode)
                output logic        aud_adclrck, // ADC l/r clock
                input logic         aud_adcdat, // ADC input data serial bitstream
                output logic        aud_daclrck, // DAC l/r clock
                output logic        aud_dacdat, // DAC output data serial bitstream
                output logic        aud_bclk, // Bitstream clock (BCLK)
                output logic        aud_mclk, // Chip clock (MCLK)

                input logic         tictac,
                input logic         explosion,
                output logic [31:0] debug
               );

   // Les signaux de lancement de son (tictac et explosion) sont synchrones sur une
   // horloge à 50MHz. Or ce module est synchrone sur l'horloge du codec (12Mhz). Il faut
   // donc d'abord les resynchroniser. La version avec "_r" est le signal resynchronisé sur 12MHz.
   logic                            tictac_r;
   logic                            explosion_r;

   resync r1(.clk(clk_50), .in(tictac), .out(tictac_r));
   resync r2(.clk(clk_50), .in(explosion), .out(explosion_r));

   // Audio data IN and OUT
   logic [15:0]  adc_data_l;
   logic [15:0]  adc_data_r;
   logic [15:0]  dac_data_l;
   logic [15:0]  dac_data_r;
   logic         data_ena;

   // Instanciation du module de gestion du codec audio
   codec codec(.clk_50(clk_50),
               .reset_n(reset_n),

               // I2C configuration port
               .i2c_sclk(i2c_sclk),
               .i2c_sdat(i2c_sdat),

               // Codec chip ports (codec in slave mode)
               .aud_adclrck(aud_adclrck),
               .aud_adcdat(aud_adcdat),
               .aud_daclrck(aud_daclrck),
               .aud_dacdat(aud_dacdat),
               .aud_bclk(aud_bclk),
               .aud_mclk(aud_mclk),

               // Audio data IN and OUT
               .adc_data_l(adc_data_l),
               .adc_data_r(adc_data_r),
               .dac_data_l(dac_data_l),
               .dac_data_r(dac_data_r),
               .data_ena(data_ena)
               );

   // Signaux internes
   logic               active;

   // Adresses de début et de fin des samples dans la ROM
   localparam tictac_start = 0;
   localparam tictac_end = 3846;

   localparam explosion_start = tictac_end + 1;
   localparam explosion_end = explosion_start + 8117;

   localparam taille_sons = explosion_end;

   // ROM des sons
   integer             snd_address;
   integer             end_address;
   logic [7:0]         snd_data;
   logic [7:0]         snd_rom [0:taille_sons-1];

   initial
     begin
        $readmemh("../sounds/sounds.lst", snd_rom);
     end

   always_ff @(posedge aud_mclk)
     snd_data <= snd_rom[snd_address];

   // Machine à état de lecture des sons
   always_ff @(posedge aud_mclk or negedge reset_n)
     if (~reset_n)
       begin
          snd_address <= 0;
          end_address <= 0;
          active <= 0;
       end
     else
       begin
          // Si on n'est pas en train de lire un sample
          if(~active)
            begin
               // Si on demande à jouer un son, on charge ses adresses de début et fin
               // et on lance la lecture (active=1)
               if (tictac_r)
                 begin
                    snd_address <= tictac_start;
                    end_address <= tictac_end;
                    active <= 1;
                 end
               if (explosion_r)
                 begin
                    snd_address <= explosion_start;
                    end_address <= explosion_end;
                    active <= 1;
                 end
            end

          // Si on est en train de jouer un son
          if (active)
            begin
               // À chaque data_ena on doit fournir un nouvel échantillon audio
               if(data_ena)
                 begin
                    dac_data_l <= {snd_data, 8'b0};
                    dac_data_r <= {snd_data, 8'b0};
                    // Si on est arrivé à la fin du son, on revient en mode inactif
                    if (snd_address == end_address)
                      active <= 0;
                    else
                      snd_address <= snd_address + 1;
                 end
            end // if (active)
       end // else: !if(~reset_n)

   assign debug = {snd_address};

endmodule