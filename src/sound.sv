/***********************************************************
 *
 * Module Pour la Configuration du codec audio
 *
 **********************************************************/

module Sound(
             clk,          // Horloge système
             nrst,         // RESET
             I2C_SCLK,     // Horloge I2C
             I2C_SDAT,     // Données I2C
             AUD_XCK       // Horloge du CODEC
             );


   input logic        clk;
   input logic        nrst;
   output logic       I2C_SCLK;
   inout wire         I2C_SDAT;
   output logic       AUD_XCK;

   logic              I2C_CTRL_CLK;
   logic              I2C_ACK;
   logic              I2C_END;
   logic [23:0]       I2C_DATA;

   /***********************************************************
    *
    *        Diviseur de fréquences I2C
    *
    ***********************************************************/

   logic [9:0]          cpt_clk;
   logic                cpt_clk_r;

   always @(posedge clk or negedge nrst) begin
      if (!nrst)
        begin
           cpt_clk   <= 10'd0;
           cpt_clk_r <= 1'b0;
        end
      else
        begin
           cpt_clk <= cpt_clk + 1'b1;
           cpt_clk_r <= cpt_clk[9];
        end
   end

   assign I2C_CTRL_CLK = cpt_clk[9]; // clk/2^10 ie 48.828 KHz pour 50MHz
   assign AUD_XCK      = cpt_clk[1]; // clk/4 ie 12.5 for 50MHz (au lieu de 12.288)
   // Si plus de précision est necessaire,
   // utiliser une pll

   logic i2c_en =  cpt_clk[9] & !cpt_clk_r;

   /***********************************************************
    *
    *        ROM de configuration du codec
    *
    ***********************************************************/
   localparam ROM_SIZE  = 9;  // Taille de la ROM de configuration

   // Les registres à modifier
   localparam PW_DOWN_CTRL = 0;
   localparam AUDIO_FORMAT = 1;
   localparam A_AUDIO_PATH = 2;
   localparam SAMPLE_CTRL  = 3;
   localparam L_IN_CTRL    = 4;
   localparam R_IN_CTRL    = 5;
   localparam L_HEAD_CTRL  = 6;
   localparam R_HEAD_CTRL  = 7;
   localparam ACTIVE       = 8;

   reg [3:0] index;
   reg [15:0] rom_data;

   always@(index)
     case (index)
       PW_DOWN_CTRL : rom_data <= 16'h0c_00;      // Tout est allumé
       AUDIO_FORMAT : rom_data <= 16'h0e_41;      // Mode maitre, données justifiées à gauche
       A_AUDIO_PATH : rom_data <= 16'h08_30;      // Line IN
       SAMPLE_CTRL  : rom_data <= 16'h10_0C;      // Fréquence d'échantillonage
       L_IN_CTRL    : rom_data <= 16'h00_17;      // Volume D'entrée G
       R_IN_CTRL    : rom_data <= 16'h02_17;      // Volume D'entrée D
       L_HEAD_CTRL  : rom_data <= {8'h04,8'h7f};  // Volume Sortie G
       R_HEAD_CTRL  : rom_data <= {8'h06,8'h7f};  // Volume Sortie D
       ACTIVE       : rom_data <= {8'h12,8'h01};  // Activer
       default      : rom_data <= {16{1'b0}};
     endcase

   /***********************************************************
    *     Plan des registres du Codec
    ***********************************************************
    _______________________________________________________________________________________
    |15 14 13 12 11 10 9|  8 |   7 |  6  |    5   |   4   |   3    |  2  |   1    |   0     |
    ______________________|___________________|____|_____|_____|________|_______|________|_____|________|_________|
    |L Line In    R0 (00h) | 0  0  0  0  0  0 0|LRIN| LIN |  0  |    0   |                 LINVOL                  |
    |                      |                   |BOTH|MUTE |     |        |                                         |
    |______________________|___________________|____|_____|_____|________|_________________________________________|
    |R Line In    R1 (02h) | 0  0  0  0  0  0 1|RLIN| RIN |  0  |    0   |                 RINVOL                  |
    |                      |                   |BOTH|MUTE |     |        |                                         |
    |______________________|___________________|____|_____|_____|________|_________________________________________|
    |L Headphone  R2 (04h) | 0  0  0  0  0  1 0|LRHP|LZCEN|                        LHPVOL                          |
    | Out                  |                   |BOTH|     |                                                        |
    |______________________|___________________|__1_|_____|________________________________________________________|
    |R Headphone  R3 (06h) | 0  0  0  0  0  1 1|RLHP|RZCEN|                        RHPVOL                          |
    | Out                  |                   |BOTH|     |                                                        |
    |______________________|___________________|__1_|_____|________________________________________________________|
    |Analog Path  R4 (08h) | 0  0  0  0  1  0 0|  0 |  SIDEATT  |SIDETONE|DAC SEL| BYPASS |INSEL|MUTE MIC|MIC BOOST|
    |______________________|___________________|____|___________|________|_______|________|_____|________|_________|
    |Digital Path R5 (0Ah) | 0  0  0  0  1  0 1|  0 |   0 |  0  |    0   |HPOR   |DAC MU  |   DEEMPH     | ADC HPD |
    |______________________|___________________|____|_____|_____|________|_______|________|______________|_________|
    |Power Down   R6 (0Ch) | 0  0  0  0  1  1 0|  0 | PWR | CLK | OSCPD  |OUTPD  | DACPD  |ADCPD| MICPD  | LINEINPD|
    | Ctrl                 |                   |    | OFF |OUTPD|        |       |        |     |        |         |
    |______________________|___________________|____|_____|_____|________|_______|________|_____|________|_________|
    |Dig. Audio   R7 (0Eh) | 0  0  0  0  1  1 1|  0 | BCLK| MS  |LR SWAP | LRP   |      IWL     |     FORMAT       |
    |If. Format            |                   |    |  INV|     |        |       |              |      0      1    |
    |______________________|___________________|____|_____|_____|________|_______|______________|__________________|
    |Sampling     R8 (10h) | 0  0  0  1  0  0 0|  0 |CLKO | CLKI|              SR               | BOSR   |USB/NORM |
    | Ctrl                 |                   |    | DIV2| DIV2|   0        0      1    1      |        |         |
    |______________________|___________________|____|_____|_____|_______________________________|________|_________|
    |Active       R9 (12h) | 0  0  0  1  0  0 1|  0 |   0 |  0  |    0   |  0    |   0    |  0  |   0    |  ACTIVE |
    |______________________|___________________|____|_____|_____|________|_______|________|_____|________|_________|
    |Reset        R15(1Eh) | 0  0  0  1  1  1 1|                              RESET                                |
    |______________________|___________________|___________________________________________________________________|
    |      ADDRESS      |                              DATA                                 |
    |___________________|___________________________________________________________________|
    ***********************************************************/

   /***********************************************************
    *
    *        Générateur séquences I2C
    *
    ***********************************************************/
   logic        GO;

   // l'addresse du CODEC sur le bus i2c est 8'h34
   assign I2C_DATA = {8'h34,rom_data};

   I2C   I2C_i (
                .CLOCK(clk),
                .i2c_iclk(I2C_CTRL_CLK),
                .en(i2c_en),
                .nRESET(nrst),
                // Ctrl
                .GO(GO),
                .END(I2C_END),
                // Donnees //
                .I2C_DATA(I2C_DATA),
                // ACK i2c
                .ACK(I2C_ACK),
                // Donnees I2C series
                .I2C_SDAT(I2C_SDAT),
                .I2C_SCLK(I2C_SCLK)
                );

   /***********************************************************
    *
    *        Commande du generateur I2C
    *
    ***********************************************************/

logic [1:0] st;

always @(posedge clk or negedge nrst)
  if (!nrst)
    begin
       GO    <= 0;
       index <= 0;
       st    <= 0;
    end
  else if (i2c_en)
    begin
       if (index < ROM_SIZE )
         case (st)
           0: begin
              GO <= 1;
              st <= 1;
           end
           1: begin
              if (I2C_END)
                begin
                   GO <= 0;
                   st <= 2;
                   if (I2C_ACK) // transmission pas ok
                     st <= 0;   // réenvoyer
                end
           end
           2: begin
              index <= index + 1'b1; // Au suivant
              st <= 0;
           end
         endcase
    end

endmodule
