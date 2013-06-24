`default_nettype none

  module DE2_fpga (
		           // clock input
		           clock_27,                     // 27 MHz
		           clock_50,                     // 50 MHz
		           ext_clock,                    // xternal clock
		           // push buttons
		           key,                          // pushbutton[3:0]
		           // switches
		           sw,                           // toggle switch[17:0]
		           // 7-seg display
		           hex0,                         // seven segment digit 0
		           hex1,                         // seven segment digit 1
		           hex2,                         // seven segment digit 2
		           hex3,                         // seven segment digit 3
		           hex4,                         // seven segment digit 4
		           hex5,                         // seven segment digit 5
		           hex6,                         // seven segment digit 6
		           hex7,                         // seven segment digit 7
		           // led
		           ledg,                         // led green[8:0]
		           ledr,                         // led red[17:0]
		           // uart
		           uart_txd,                     // uart transmitter
		           uart_rxd,                     // uart receiver
		           // irda
		           irda_txd,                     // irda transmitter
		           irda_rxd,                     // irda receiver
		           // sdram interface
		           dram_dq,                      // sdram data bus 16 bits
		           dram_addr,                    // sdram address bus 12 bits
		           dram_ldqm,                    // sdram low-byte data mask
		           dram_udqm,                    // sdram high-byte data mask
		           dram_we_n,                    // sdram write enable
		           dram_cas_n,                   // sdram column address strobe
		           dram_ras_n,                   // sdram row address strobe
		           dram_cs_n,                    // sdram chip select
		           dram_ba_0,                    // sdram bank address 0
		           dram_ba_1,                    // sdram bank address 0
		           dram_clk,                     // sdram clock
		           dram_cke,                     // sdram clock enable
		           // flash interface
		           fl_dq,                        // flash data bus 8 bits
		           fl_addr,                      // flash address bus 22 bits
		           fl_we_n,                      // flash write enable
		           fl_rst_n,                     // flash reset
		           fl_oe_n,                      // flash output enable
		           fl_ce_n,                      // flash chip enable
		           // sram interface
		           sram_dq,                      // sram data bus 16 bits
		           sram_addr,                    // sram address bus 18 bits
		           sram_ub_n,                    // sram high-byte data mask
		           sram_lb_n,                    // sram low-byte data mask
		           sram_we_n,                    // sram write enable
		           sram_ce_n,                    // sram chip enable
		           sram_oe_n,                    // sram output enable
		           // isp1362 interface
		           otg_data,                     // isp1362 data bus 16 bits
		           otg_addr,                     // isp1362 address 2 bits
		           otg_cs_n,                     // isp1362 chip select
		           otg_rd_n,                     // isp1362 write
		           otg_wr_n,                     // isp1362 read
		           otg_rst_n,                    // isp1362 reset
		           otg_fspeed,                   // usb full speed, 0 = enable, z = disable
		           otg_lspeed,                   // usb low speed,  0 = enable, z = disable
		           otg_int0,                     // isp1362 interrupt 0
		           otg_int1,                     // isp1362 interrupt 1
		           otg_dreq0,                    // isp1362 dma request 0
		           otg_dreq1,                    // isp1362 dma request 1
		           otg_dack0_n,                  // isp1362 dma acknowledge 0
		           otg_dack1_n,                  // isp1362 dma acknowledge 1
		           //    lcd module 16x2         ////////////////
		           lcd_on,                       // lcd power on/off
		           lcd_blon,                     // lcd back light on/off
		           lcd_rw,                       // lcd read/write select, 0 = write, 1 = read
		           lcd_en,                       // lcd enable
		           lcd_rs,                       // lcd command/data select, 0 = command, 1 = data
		           lcd_data,                     // lcd data bus 8 bits
		           // SD-Card interface
		           sd_dat,                       // sd card data
		           sd_dat3,                      // sd card data 3
		           sd_cmd,                       // sd card command signal
		           sd_clk,                       // sd card clock
		           // USB JTAG link
		           tdi,                          // cpld -> fpga (data in)
		           tck,                          // cpld -> fpga (clk)
		           tcs,                          // cpld -> fpga (cs)
		           tdo,                          // fpga -> cpld (data out)
		           // I2C
		           i2c_sdat,                     // i2c data
		           i2c_sclk,                     // i2c clock
		           // PS2
		           ps2_dat,                      // ps2 data
		           ps2_clk,                      // ps2 clock
		           // VGA
		           vga_clk,                      // vga clock
		           vga_hs,                       // vga h_sync
		           vga_vs,                       // vga v_sync
		           vga_blank,                    // vga blank
		           vga_sync,                     // vga sync
		           vga_r,                        // vga red[9:0]
		           vga_g,                        // vga green[9:0]
		           vga_b,                        // vga blue[9:0]
		           // Ethernet interface
		           enet_data,                    // dm9000a data bus 16bits
		           enet_cmd,                     // dm9000a command/data select, 0 = command, 1 = data
		           enet_cs_n,                    // dm9000a chip select
		           enet_wr_n,                    // dm9000a write
		           enet_rd_n,                    // dm9000a read
		           enet_rst_n,                   // dm9000a reset
		           enet_int,                     // dm9000a interrupt
		           enet_clk,                     // dm9000a clock 25 mhz
		           // audio codec
		           aud_adclrck,                  // audio codec adc lr clock
		           aud_adcdat,                   // audio codec adc data
		           aud_daclrck,                  // audio codec dac lr clock
		           aud_dacdat,                   // audio codec dac data
		           aud_bclk,                     // audio codec bit-stream clock
		           aud_mclk,                     // audio codec chip clock
		           // TV decoder
		           td_data,                      // tv decoder data bus 8 bits
		           td_hs,                        // tv decoder h_sync
		           td_vs,                        // tv decoder v_sync
		           td_reset,                     // tv decoder reset
		           td_clk,                       // tv decoder clock
		           // gpio
		           gpio_0,                       // gpio connection 0
		           gpio_1                        // gpio connection 1
		           );

   // clock input
   input logic            clock_27;     // 27 MHz
   input logic            clock_50;     // 50 MHz
   input logic            ext_clock;    // external clock
   // push buttons
   input logic [3:0]      key;          // pushbutton[3:0]
   // switches
   input logic [17:0]     sw;           // toggle switch[17:0]
   // 7-seg display
   output logic [6:0]     hex0;         // seven segment digit 0
   output logic [6:0]     hex1;         // seven segment digit 1
   output logic [6:0]     hex2;         // seven segment digit 2
   output logic [6:0]     hex3;         // seven segment digit 3
   output logic [6:0]     hex4;         // seven segment digit 4
   output logic [6:0]     hex5;         // seven segment digit 5
   output logic [6:0]     hex6;         // seven segment digit 6
   output logic [6:0]     hex7;         // seven segment digit 7
   // led
   output logic [8:0]     ledg;         // led green[8:0]
   output logic [17:0]    ledr;         // led red[17:0]
   // UART
   output logic           uart_txd;     // uart transmitter
   input logic            uart_rxd;     // uart receiver
   // IrDA
   output logic           irda_txd;     // irda transmitter
   input logic            irda_rxd;     // irda receiver
   // SDRAM interface
   inout wire [15:0]      dram_dq;      // sdram data bus 16 bits
   output logic [11:0]    dram_addr;    // sdram address bus 12 bits
   output logic           dram_ldqm;    // sdram low-byte data mask
   output logic           dram_udqm;    // sdram high-byte data mask
   output logic           dram_we_n;    // sdram write enable
   output logic           dram_cas_n;   // sdram column address strobe
   output logic           dram_ras_n;   // sdram row address strobe
   output logic           dram_cs_n;    // sdram chip select
   output logic           dram_ba_0;    // sdram bank address 0
   output logic           dram_ba_1;    // sdram bank address 0
   output logic           dram_clk;     // sdram clock
   output logic           dram_cke;     // sdram clock enable
   // flash interface
   inout wire [7:0]       fl_dq;        // flash data bus 8 bits
   output logic [21:0]    fl_addr;      // flash address bus 22 bits
   output logic           fl_we_n;      // flash write enable
   output logic           fl_rst_n;     // flash reset
   output logic           fl_oe_n;      // flash output logic  enable
   output logic           fl_ce_n;      // flash chip enable
   // SRAM interface
   inout wire [15:0]      sram_dq;      // sram data bus 16 bits
   output logic [17:0]    sram_addr;    // sram address bus 18 bits
   output logic           sram_ub_n;    // sram high-byte data mask
   output logic           sram_lb_n;    // sram low-byte data mask
   output logic           sram_we_n;    // sram write enable
   output logic           sram_ce_n;    // sram chip enable
   output logic           sram_oe_n;    // sram output logic  enable
   // ISPL362 interface
   inout wire [15:0]      otg_data;     // isp1362 data bus 16 bits
   output logic [1:0]     otg_addr;     // isp1362 address 2 bits
   output logic           otg_cs_n;     // isp1362 chip select
   output logic           otg_rd_n;     // isp1362 write
   output logic           otg_wr_n;     // isp1362 read
   output logic           otg_rst_n;    // isp1362 reset
   output logic           otg_fspeed;   // usb full speed, 0 = enable, z = disable
   output logic           otg_lspeed;   // usb low speed,  0 = enable, z = disable
   input logic            otg_int0;     // isp1362 interrupt 0
   input logic            otg_int1;     // isp1362 interrupt 1
   input logic            otg_dreq0;    // isp1362 dma request 0
   input logic            otg_dreq1;    // isp1362 dma request 1
   output logic           otg_dack0_n;  // isp1362 dma acknowledge 0
   output logic           otg_dack1_n;  // isp1362 dma acknowledge 1
   // LCD module 16x2
   inout wire [7:0]       lcd_data;     // lcd data bus 8 bits
   output logic           lcd_on;       // lcd power on/off
   output logic           lcd_blon;     // lcd back light on/off
   output logic           lcd_rw;       // lcd read/write select, 0 = write, 1 = read
   output logic           lcd_en;       // lcd enable
   output logic           lcd_rs;       // lcd command/data select, 0 = command, 1 = data
   // SD Card interface
   inout wire             sd_dat;       // sd card data
   inout wire             sd_dat3;      // sd card data 3
   inout wire             sd_cmd;       // sd card command signal
   output logic           sd_clk;       // sd card clock
   // I2C
   inout wire             i2c_sdat;     // i2c data
   output logic           i2c_sclk;     // i2c clock
   // PS2g
   input logic            ps2_dat;      // ps2 data
   input logic            ps2_clk;      // ps2 clock
   // USB JTAG link
   input logic            tdi;          // cpld -> fpga (data in)
   input logic            tck;          // cpld -> fpga (clk)
   input logic            tcs;          // cpld -> fpga (cs)
   output logic           tdo;          // fpga -> cpld (data out)
   // VGA
   output logic           vga_clk;      // vga clock
   output logic           vga_hs;       // vga h_sync
   output logic           vga_vs;       // vga v_sync
   output logic           vga_blank;    // vga blank
   output logic           vga_sync;     // vga sync
   output logic [9:0]     vga_r;        // vga red[9:0]
   output logic [9:0]     vga_g;        // vga green[9:0]
   output logic [9:0]     vga_b;        // vga blue[9:0]

   // Ethernet interface
   inout wire [15:0]      enet_data;    // dm9000a data bus 16bits
   output logic           enet_cmd;     // dm9000a command/data select, 0 = command, 1 = data
   output logic           enet_cs_n;    // dm9000a chip select
   output logic           enet_wr_n;    // dm9000a write
   output logic           enet_rd_n;    // dm9000a read
   output logic           enet_rst_n;   // dm9000a reset
   input logic            enet_int;     // dm9000a interrupt
   output logic           enet_clk;     // dm9000a clock 25 mhz
   // Audio codec
   output logic           aud_adclrck;  // audio codec adc lr clock
   input logic            aud_adcdat;   // audio codec adc data
   output logic           aud_daclrck;  // audio codec dac lr clock
   output logic           aud_dacdat;   // audio codec dac data
   output logic           aud_bclk;     // audio codec bit-stream clock
   output logic           aud_mclk;     // audio codec chip clock
   // TV  Decoder
   input logic [7:0]      td_data;      // tv decoder data bus 8 bits
   input logic            td_hs;        // tv decoder h_sync
   input logic            td_vs;        // tv decoder v_sync
   output logic           td_reset;     // tv decoder reset
   input logic            td_clk;       // tv decoder clock
   // GPIO
   inout wire [35:0]      gpio_0;       // gpio connection 0
   inout wire [35:0]      gpio_1;       // gpio connection 1

   // GÃ©nÃ©ration d'un reset
   logic                  reset_n;
   gene_reset gene_reset(.clk(clock_50), .reset_n(reset_n));

   // Turn on all displays except LCD
   assign  ledg[3:0]       =       key;
   assign  ledr            =       sw;
   assign  lcd_on          =       1'b0;
   assign  lcd_blon        =       1'b0;

   //Commande du numÃ©ro des sprites par les switchs
   logic [2:0]            play1_num;
   logic [2:0]            play2_num;
   logic [2:0]            flame_num;
   logic [3:0]            wall_num;

   //les sw 11 et 10 controlent les flammes
   assign  flame_num       =       sw[11:10];

   // Turn unused ports to tri-state
   assign  dram_dq         =       16'hzzzz;
   assign  fl_dq           =       8'hzz;
   assign  sram_dq         =       16'hzzzz;
   assign  otg_data        =       16'hzzzz;
   assign  lcd_data        =       8'hzz;
   assign  sd_dat          =       1'bz;
   assign  enet_data       =       16'hzzzz;
   assign  gpio_0          =       36'hzzzzzzzzz;
   assign  gpio_1          =       36'hzzzzzzzzz;

   // Signaux internes
   // debut de trame
   logic                  vga_SOF;
   // fin de trame
   logic                  vga_EOF;
   // debut de ligne
   logic                  vga_SOL;
   // fin de ligne
   logic                  vga_EOL;
   // numero de ligne dans la zone active
   logic signed [10:0]    vga_spotX;
   // numero de colonne dans la zone active
   logic signed [10:0]    vga_spotY;
   // fond rouge, bleu, vert
   logic [23:0]           bck_rgb;

   logic [7:0]            player1_color;
   logic [7:0]            player2_color;
   logic [7:0]            flame_color;
   logic [7:0]            wall_color;
   // coin haut gauche du sprite du joueur1
   logic [9:0]            player1_centerX, player1_centerY;
   // coin haut gauche du sprite du joueur2
   logic [9:0]            player2_centerX, player2_centerY;
   // coin haut gauche du sprite des flammes
   logic [9:0]            flame_centerX, flame_centerY;
   // coin haut gauche du sprite des murs et objets
   logic [9:0]            wall_centerX, wall_centerY;
   logic [7:0]            data_out;
   logic                  j1_up;
   logic                  j1_down;
   logic                  j1_left;
   logic                  j1_right;
   logic                  j1_drop;
   logic                  j2_up;
   logic                  j2_down;
   logic                  j2_left;
   logic                  j2_right;
   logic                  j2_drop;
   // la vie
   logic [6:0]            life1;
   logic [6:0]            life2;
   logic [23:0]           life_rgb;

   // Horloge VGA
   always  @(*)
     vga_clk <= clock_50;

   // XXX Pour le moment, on donne des valeurs de flame_centerX et flame_centerY
   // alors qu'Ã  terme ces positions seront donnÃ©es par le maze
   assign  flame_centerX        =        100;
   assign  flame_centerY        =        100;
   // pour le moment on donne des valeurs Ã  life
   assign  life1 = 35;
   assign  life2 = 75;
   // Instanciation des decodeurs 7 segments pour le debug
   logic [31:0]           debug;
   seven_seg s0 (debug[3:0],   hex0);
   seven_seg s1 (debug[7:4],   hex1);
   seven_seg s2 (debug[11:8],  hex2);
   seven_seg s3 (debug[15:12], hex3);
   seven_seg s4 (debug[19:16], hex4);
   seven_seg s5 (debug[23:20], hex5);
   seven_seg s6 (debug[27:24], hex6);
   seven_seg s7 (debug[31:28], hex7);

   // Instantiation de life
   life vie(.clk(vga_clk),
            .spotX(vga_spotX),
            .spotY(vga_spotY),
            .life1(life1),
            .life2(life2),
            .life_rgb(life_rgb)
            );

   // Instanciation du module de synchro
   synchro sync1(.clk(vga_clk) ,
                 .reset_n(reset_n),
                 .blank(vga_blank),
                 .HS(vga_hs),
                 .VS(vga_vs),
                 .SOF(vga_SOF),
                 .EOF(vga_EOF),
                 .SOL(vga_SOL),
                 .EOL(vga_EOL),
                 .spotX(vga_spotX),
                 .spotY(vga_spotY),
                 .sync(vga_sync));

   //Instantiation du clavier PS/2
   keyboard kb(  .clk(vga_clk),
                 .reset_n(reset_n),
                 .ps2_clk(ps2_clk),
                 .ps2_data(ps2_dat),
                 .j1_up(j1_up),
                 .j1_down(j1_down),
                 .j1_right(j1_right),
                 .j1_left(j1_left),
                 .j1_drop(j1_drop),
                 .j2_up(j2_up),
                 .j2_down(j2_down),
                 .j2_right(j2_right),
                 .j2_left(j2_left),
                 .j2_drop(j2_drop),
                 .data_out(data_out)
                 );


   // Instantiation du module controleur
   controleur ctr(.clk(vga_clk),
		          .reset_n(reset_n),
		          .SOF(vga_SOF),
		          .EOF(vga_EOF),
                  .j1_up(j1_up),
                  .j1_down(j1_down),
                  .j1_right(j1_right),
                  .j1_left(j1_left),
                  .j2_up(j2_up),
                  .j2_down(j2_down),
                  .j2_right(j2_right),
                  .j2_left(j2_left),
                  .player1_num(play1_num),
                  .player2_num(play2_num),
		          .player1_centerX(player1_centerX),
		          .player1_centerY(player1_centerY),
                  .player2_centerX(player2_centerX),
                  .player2_centerY(player2_centerY)
		          );

   // Instanciation du module maze
   maze maze(.clk(vga_clk),
             .spotX(vga_spotX),
             .spotY(vga_spotY),
             .wall_num(wall_num),
		     .wall_centerX(wall_centerX),
		     .wall_centerY(wall_centerY)
             );
   // Instantiation du module background
   background bck(.clk(vga_clk),
		          .spotX(vga_spotX),
		          .bck_rgb(bck_rgb)
		          );

   //Instantiation du module joueur1
   player1 ply1(.clk(vga_clk),
                .spotX(vga_spotX),
                .spotY(vga_spotY),
		        .player1_centerX(player1_centerX),
		        .player1_centerY(player1_centerY),
                .sprite_num(play1_num),
                .player1_color(player1_color)
		        );

   //Instantiation du module joueur2
   player2 play2(.clk(vga_clk),
                 .spotX(vga_spotX),
                 .spotY(vga_spotY),
		         .player2_centerX(player2_centerX),
		         .player2_centerY(player2_centerY),
                 .sprite_num(play2_num),
                 .player2_color(player2_color)
		         );

   //Instantiation du module flame
   flame flame(.clk(vga_clk),
               .spotX(vga_spotX),
               .spotY(vga_spotY),
		       .flame_centerX(flame_centerX),
		       .flame_centerY(flame_centerY),
               .sprite_num(flame_num),
               .flame_color(flame_color)
		       );

   //Instantiation du module wall
   wall wall(.clk(vga_clk),
             .spotX(vga_spotX),
             .spotY(vga_spotY),
		     .wall_centerX(wall_centerX),
		     .wall_centerY(wall_centerY),
             .sprite_num(wall_num),
             .wall_color(wall_color)
		     );

   // Instantiation du mixer
   mixer mix(.clk(vga_clk),
             .active(vga_blank),
             .bck_rgb(bck_rgb),
	         .player2_color(player2_color),
             .flame_color(flame_color),
             .wall_color(wall_color),
             .player1_color(player1_color),
             .vga_r(vga_r),
             .vga_g(vga_g),
             .vga_b(vga_b),
             .life_rgb(life_rgb)
	         );

   // Debug
   assign debug = {data_out};

endmodule
