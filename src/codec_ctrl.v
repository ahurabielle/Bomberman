/************************************************************
 *
 * Module Pour la Configuration du codec audio en USB SLAVE
 *                                               -----------
 ***********************************************************/

module codec_ctrl(
                  clk,          // Horloge système 50Mhz
                  reset_n,      // Reset (actif bas)
                  i2c_sclk,     // Horloge I2C
                  i2c_sdat     // Données I2C
                  );


   input        clk;
   input        reset_n;
   output       i2c_sclk;
   inout        i2c_sdat;

   wire         i2c_ctrl_clk;
   wire         i2c_ack;
   wire         i2c_done;
   wire [23:0]  i2c_data;

   /***********************************************************
    *
    *        Diviseur de fréquences I2C
    *
    ***********************************************************/

   reg [9:0]    cpt_clk;
   reg          cpt_clk_r;

   always @(posedge clk or negedge reset_n) begin
      if (~reset_n)
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

   // Horloge I2C : clk/2^10 = 48.828KHz : parfait
   assign i2c_ctrl_clk = cpt_clk[9];

   // i2c_en détecte les fronts montants de i2c_ctrl_clk
   wire i2c_en =  cpt_clk[9] & ~cpt_clk_r;

   /***********************************************************
    *
    *        ROM de configuration du codec
    *
    ***********************************************************/
   localparam ROM_SIZE  = 10;  // Taille de la ROM de configuration

   // Les registres à modifier
   localparam PW_DOWN_CTRL = 0;
   localparam AUDIO_FORMAT = 1;
   localparam D_AUDIO_PATH = 2;
   localparam A_AUDIO_PATH = 3;
   localparam SAMPLE_CTRL  = 4;
   localparam L_IN_CTRL    = 5;
   localparam R_IN_CTRL    = 6;
   localparam L_HEAD_CTRL  = 7;
   localparam R_HEAD_CTRL  = 8;
   localparam ACTIVE       = 9;

   reg [3:0] index;
   reg [15:0] rom_data;

   always@(index)
     case (index)
       L_IN_CTRL    : rom_data <= 16'h00_17;      // Volume D'entrée G à 0dB
       R_IN_CTRL    : rom_data <= 16'h02_17;      // Volume D'entrée D à 0dB
       L_HEAD_CTRL  : rom_data <= 16'h04_7f;      // Volume Sortie G : +6dB, no zero cross detect
       R_HEAD_CTRL  : rom_data <= 16'h06_7f;      // Volume Sortie D : idem
       A_AUDIO_PATH : rom_data <= 16'h08_12;      // Line IN, no MIC, no SIDETONE
       D_AUDIO_PATH : rom_data <= 16'h0a_16;      // High pass filter, 48k, no soft mute, store offset
       PW_DOWN_CTRL : rom_data <= 16'h0c_62;      // Tout est allumé sauf micro
       AUDIO_FORMAT : rom_data <= 16'h0e_03;      // Mode slave, DSP, LRP=0, 16 bits
       SAMPLE_CTRL  : rom_data <= 16'h10_0d;      // Mode USB, 250fs, 8kHz
       ACTIVE       : rom_data <= 16'h12_01;      // Activer
       default      : rom_data <= 16'h12_01;      // (Activer)
     endcase

   /***********************************************************
    *     Plan des registres du Codec
    ***********************************************************
    _______________________________________________________________________________________________________________
    |                      |15 14 13 12 11 10 9|  8 |   7 |  6  |    5   |   4   |   3    |  2  |   1    |   0     |
    |______________________|___________________|____|_____|_____|________|_______|________|_____|________|_________|
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
    |If. Format            |                   |    |  INV|  0  |    0   |   0   |   0       0  |    1        1    |
    |______________________|___________________|____|_____|_____|________|_______|______________|__________________|
    |Sampling     R8 (10h) | 0  0  0  1  0  0 0|  0 |CLKO | CLKI|              SR               | BOSR   |USB/NORM |
    | Ctrl                 |                   |    | DIV2| DIV2|   0        0      0    0      |   0    |         |
    |______________________|___________________|____|_____|_____|_______________________________|________|_________|
    |Active       R9 (12h) | 0  0  0  1  0  0 1|  0 |   0 |  0  |    0   |  0    |   0    |  0  |   0    |  ACTIVE |
    |______________________|___________________|____|_____|_____|________|_______|________|_____|________|_________|
    |Reset        R15(1Eh) | 0  0  0  1  1  1 1|                              RESET                                |
    |______________________|___________________|___________________________________________________________________|
    |                      |      ADDRESS      |                              DATA                                 |
    |______________________|___________________|___________________________________________________________________|

    ***********************************************************/

   /***********************************************************
    *
    *        Générateur séquences I2C
    *
    ***********************************************************/
   reg        i2c_go;

   // l'addresse du CODEC sur le bus i2c est 8'h34
   assign i2c_data = {8'h34,rom_data};

   I2C   I2C (
              .clk(clk),
              .reset_n(reset_n),
              .i2c_iclk(i2c_ctrl_clk),
              .en(i2c_en),

              // Ctrl
              .go(i2c_go),
              .done(i2c_done),
              // Donnees
              .i2c_data(i2c_data),

              // ACK i2c
              .ack(i2c_ack),

              // Donnees I2C series
              .i2c_sdat(i2c_sdat),
              .i2c_sclk(i2c_sclk)
              );

   /***********************************************************
    *
    *        Commande du generateur I2C
    *
    ***********************************************************/
   reg [1:0]  st;

   always @(posedge clk or negedge reset_n)
     if (~reset_n)
       begin
          i2c_go <= 0;
          index  <= 0;
          st     <= 0;
       end
     else if (i2c_en)
       begin
          if (index < ROM_SIZE )
            case (st)
              0: begin
                 i2c_go <= 1;
                 st     <= 1;
              end
              1: begin
                 if (i2c_done)
                   begin
                      i2c_go <= 0;
                      st     <= 2;
                      if (i2c_ack) // transmission pas ok
                        st <= 0;   // réenvoyer
                   end
              end
              2: begin
                 index <= index + 1'b1; // Au suivant
                 st    <= 0;
              end
            endcase
       end

endmodule


module I2C (
	        clk,
            reset_n,
	        i2c_iclk,
            en,

            //I2C CLOCK
	        i2c_sclk,
            //I2C DATA
 	        i2c_sdat,

            //DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
	        i2c_data,

            // start transfer
	        go,

            // transfer done
	        done,

            // ACK
	        ack
            );
   input         clk;
   input         i2c_iclk;
   input         en;
   input [23:0]  i2c_data;
   input         go;
   input         reset_n;
   // input  W_R;
   inout         i2c_sdat;
   output        i2c_sclk;
   output        done;
   output        ack;

   reg           sdo;
   reg           sclk;
   reg           done;
   reg [23:0]    sd;
   reg [5:0]     sd_counter;



   reg           ack1,ack2,ack3;
   wire          ack=ack1 | ack2 |ack3;

   //--I2C COUNTER
   always @(negedge reset_n or posedge clk ) begin
      if (!reset_n)
        sd_counter=6'b111111;
      else begin
         if (go==0)
	   sd_counter=0;
         else if (en)
           begin
              if (sd_counter < 6'b111111)
                sd_counter=sd_counter+1'b1;
           end
      end
   end
   //----

   always @(negedge reset_n or  posedge clk ) begin
      if (!reset_n) begin sclk=1; sdo=1; ack1=0; ack2=0; ack3=0; done=1; end
      else
        if (en)
          begin
             case (sd_counter)
	           6'd0  : begin ack1=0 ;ack2=0 ;ack3=0 ; done=0; sdo=1; sclk=1;end

               //start
               6'd1  : begin sd=i2c_data; sdo=0;end
	           6'd2  : sclk=0;

	           //SLAVE ADDR
	           6'd3  : sdo=sd[23];
	           6'd4  : sdo=sd[22];
	           6'd5  : sdo=sd[21];
	           6'd6  : sdo=sd[20];
	           6'd7  : sdo=sd[19];
	           6'd8  : sdo=sd[18];
	           6'd9  : sdo=sd[17];
	           6'd10 : sdo=sd[16];
	           6'd11 : sdo=1'b1;//ack

	           //SUB ADDR
	           6'd12  : begin sdo=sd[15]; ack1=i2c_sdat; end
	           6'd13  : sdo=sd[14];
	           6'd14  : sdo=sd[13];
	           6'd15  : sdo=sd[12];
	           6'd16  : sdo=sd[11];
	           6'd17  : sdo=sd[10];
	           6'd18  : sdo=sd[9];
	           6'd19  : sdo=sd[8];
	           6'd20  : sdo=1'b1;//ack

	           //DATA
	           6'd21  : begin sdo=sd[7]; ack2=i2c_sdat; end
	           6'd22  : sdo=sd[6];
	           6'd23  : sdo=sd[5];
	           6'd24  : sdo=sd[4];
	           6'd25  : sdo=sd[3];
	           6'd26  : sdo=sd[2];
	           6'd27  : sdo=sd[1];
	           6'd28  : sdo=sd[0];
	           6'd29  : sdo=1'b1;//ack

	           //done
               6'd30 : begin sdo=1'b0; sclk=1'b0; ack3=i2c_sdat; end
               6'd31 : sclk=1'b1;
               6'd32 : begin sdo=1'b1; done=1; end

             endcase
          end
   end

   // outputs
   wire i2c_sdat=sdo?1'bz:1'b0 ;

   reg  i2c_sclk;

   always @(posedge clk )
     i2c_sclk <= sclk | ( ((sd_counter >= 4) & (sd_counter <=30))? ~i2c_iclk:1'b0 );

endmodule
