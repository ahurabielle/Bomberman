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
   input             clock_27;     // 27 MHz
   input             clock_50;     // 50 MHz
   input             ext_clock;    // external clock
   // push buttons
   input [3:0]       key;          // pushbutton[3:0]
   // switches
   input [17:0]      sw;           // toggle switch[17:0]
   // 7-seg display
   output [6:0]      hex0;         // seven segment digit 0
   output [6:0]      hex1;         // seven segment digit 1
   output [6:0]      hex2;         // seven segment digit 2
   output [6:0]      hex3;         // seven segment digit 3
   output [6:0]      hex4;         // seven segment digit 4
   output [6:0]      hex5;         // seven segment digit 5
   output [6:0]      hex6;         // seven segment digit 6
   output [6:0]      hex7;         // seven segment digit 7
   // led
   output [8:0]      ledg;         // led green[8:0]
   output [17:0]     ledr;         // led red[17:0]
   // UART
   output            uart_txd;     // uart transmitter
   input             uart_rxd;     // uart receiver
   // IrDA
   output            irda_txd;     // irda transmitter
   input             irda_rxd;     // irda receiver
   // SDRAM interface
   inout [15:0]      dram_dq;      // sdram data bus 16 bits
   output [11:0]     dram_addr;    // sdram address bus 12 bits
   output            dram_ldqm;    // sdram low-byte data mask
   output            dram_udqm;    // sdram high-byte data mask
   output            dram_we_n;    // sdram write enable
   output            dram_cas_n;   // sdram column address strobe
   output            dram_ras_n;   // sdram row address strobe
   output            dram_cs_n;    // sdram chip select
   output            dram_ba_0;    // sdram bank address 0
   output            dram_ba_1;    // sdram bank address 0
   output            dram_clk;     // sdram clock
   output            dram_cke;     // sdram clock enable
   // flash interface
   inout [7:0]       fl_dq;        // flash data bus 8 bits
   output [21:0]     fl_addr;      // flash address bus 22 bits
   output            fl_we_n;      // flash write enable
   output            fl_rst_n;     // flash reset
   output            fl_oe_n;      // flash output enable
   output            fl_ce_n;      // flash chip enable
   // SRAM interface
   inout [15:0]      sram_dq;      // sram data bus 16 bits
   output [17:0]     sram_addr;    // sram address bus 18 bits
   output            sram_ub_n;    // sram high-byte data mask
   output            sram_lb_n;    // sram low-byte data mask
   output            sram_we_n;    // sram write enable
   output            sram_ce_n;    // sram chip enable
   output            sram_oe_n;    // sram output enable
   // ISPL362 interface
   inout [15:0]      otg_data;     // isp1362 data bus 16 bits
   output [1:0]      otg_addr;     // isp1362 address 2 bits
   output            otg_cs_n;     // isp1362 chip select
   output            otg_rd_n;     // isp1362 write
   output            otg_wr_n;     // isp1362 read
   output            otg_rst_n;    // isp1362 reset
   output            otg_fspeed;   // usb full speed, 0 = enable, z = disable
   output            otg_lspeed;   // usb low speed,  0 = enable, z = disable
   input             otg_int0;     // isp1362 interrupt 0
   input             otg_int1;     // isp1362 interrupt 1
   input             otg_dreq0;    // isp1362 dma request 0
   input             otg_dreq1;    // isp1362 dma request 1
   output            otg_dack0_n;  // isp1362 dma acknowledge 0
   output            otg_dack1_n;  // isp1362 dma acknowledge 1
   // LCD module 16x2
   inout [7:0]       lcd_data;     // lcd data bus 8 bits
   output            lcd_on;       // lcd power on/off
   output            lcd_blon;     // lcd back light on/off
   output            lcd_rw;       // lcd read/write select, 0 = write, 1 = read
   output            lcd_en;       // lcd enable
   output            lcd_rs;       // lcd command/data select, 0 = command, 1 = data
   // SD Card interface
   inout             sd_dat;       // sd card data
   inout             sd_dat3;      // sd card data 3
   inout             sd_cmd;       // sd card command signal
   output            sd_clk;       // sd card clock
   // I2C
   inout             i2c_sdat;     // i2c data
   output            i2c_sclk;     // i2c clock
   // PS2g
   input             ps2_dat;      // ps2 data
   input             ps2_clk;      // ps2 clock
   // USB JTAG link
   input             tdi;          // cpld -> fpga (data in)
   input             tck;          // cpld -> fpga (clk)
   input             tcs;          // cpld -> fpga (cs)
   output            tdo;          // fpga -> cpld (data out)
   // VGA
   output            vga_clk;      // vga clock
   output            vga_hs;       // vga h_sync
   output            vga_vs;       // vga v_sync
   output            vga_blank;    // vga blank
   output            vga_sync;     // vga sync
   output [9:0]      vga_r;        // vga red[9:0]
   output [9:0]      vga_g;        // vga green[9:0]
   output [9:0]      vga_b;        // vga blue[9:0]

   // Ethernet interface
   inout [15:0]      enet_data;    // dm9000a data bus 16bits
   output            enet_cmd;     // dm9000a command/data select, 0 = command, 1 = data
   output            enet_cs_n;    // dm9000a chip select
   output            enet_wr_n;    // dm9000a write
   output            enet_rd_n;    // dm9000a read
   output            enet_rst_n;   // dm9000a reset
   input             enet_int;     // dm9000a interrupt
   output            enet_clk;     // dm9000a clock 25 mhz
   // Audio codec
   output            aud_adclrck;  // audio codec adc lr clock
   input             aud_adcdat;   // audio codec adc data
   output            aud_daclrck;  // audio codec dac lr clock
   output            aud_dacdat;   // audio codec dac data
   output            aud_bclk;     // audio codec bit-stream clock
   output            aud_mclk;     // audio codec chip clock
   // TV  Decoder
   input [7:0]       td_data;      // tv decoder data bus 8 bits
   input             td_hs;        // tv decoder h_sync
   input             td_vs;        // tv decoder v_sync
   output            td_reset;     // tv decoder reset
   input             td_clk;       // tv decoder clock
   // GPIO
   inout [35:0]      gpio_0;       // gpio connection 0
   inout [35:0]      gpio_1;       // gpio connection 1

   // Génération d'un reset
   logic             reset_n;
   gene_reset gene_reset(.clk(clock_50), .reset_n(reset_n));

   // Turn on all displays except LCD
   assign  ledg[3:0]       =       key;
   assign  ledr            =       sw;
   assign  lcd_on          =       1'b0;
   assign  lcd_blon        =       1'b0;

   //Commande du numéro des sprites par les switchs
   assign  play1_num       =       sw[17:15];   //les sw de 17 à 15 controlent le numéro du sprite pour le player2
   assign  play2_num       =       sw[14:12];   //les sw de 14 à 12 controlent le numéro du sprite pour le player2
   assign  flame_num       =       sw[11:10];   //les 11 et 10 controlent les flammes
   assign  wall_num        =       sw[9:6];     //les 9 à 6 controlent le murs et les objets

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

   // XXX Pour le moment, on donne des valeurs de centerXF et centerYF
   // ainsi que des valeurs pour centerXW et centerYW
   // alors qu'à terme ces positions seront données par le maze
   assign  centerXF        =        100;
   assign  centerYF        =        100;
   assign  centerXW        =        300;
   assign  centerYW        =        300;


   // Signaux internes
   logic             vga_SOF;                                                     // debut de trame
   logic             vga_EOF;                                                     // fin de trame
   logic             vga_SOL;                                                     // debut de ligne
   logic             vga_EOL;                                                     // fin de ligne
   logic signed [10:0] vga_spotX;                                             // numero de ligne dans la zone active
   logic signed [10:0] vga_spotY;                                             // numero de colonne dans la zone active
   logic [23:0]        bck_rgb;                                               // fond rouge, bleu, vert
   logic [2:0]         play1_num;
   logic [7:0]         player1_color;
   logic [2:0]         play2_num;
   logic [7:0]         player2_color;
   logic [1:0]         flame_num;
   logic [7:0]         flame_color;
   logic [3:0]         wall_num;
   logic [7:0]         wall_color;
   logic signed [10:0] centerX1, centerY1;                 // coin haut gauche du sprite du joueur1
   logic signed [10:0] centerX2, centerY2;                 // coin haut gauche du sprite du joueur2
   logic signed [10:0] centerXF, centerYF;                 // coin haut gauche du sprite des flammes
   logic signed [10:0] centerXW, centerYW;                 // coin haut gauche du sprite des murs
   logic [7:0]         data_out;
   logic               data_valid;
   logic               j1_up;
   logic               j1_down;
   logic               j1_left;
   logic               j1_right;
   logic               j1_drop;
   logic               j2_up;
   logic               j2_down;
   logic               j2_left;
   logic               j2_right;
   logic               j2_drop;
   logic [7:0]         lafin;


   always  @(*)
     vga_clk <= clock_50;

   // Instanciation des decodeurs 7 segments pour le debug
   logic [31:0]        debug;
   seven_seg s0 (debug[3:0],   hex0);
   seven_seg s1 (debug[7:4],   hex1);
   seven_seg s2 (debug[11:8],  hex2);
   seven_seg s3 (debug[15:12], hex3);
   seven_seg s4 (debug[19:16], hex4);
   seven_seg s5 (debug[23:20], hex5);
   seven_seg s6 (debug[27:24], hex6);
   seven_seg s7 (debug[31:28], hex7);

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
                 .data_out(data_out),
                 .lafin(lafin)
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
		          .centerX(centerX1),
		          .centerY(centerY1)
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
		        .centerX1(centerX1),
		        .centerY1(centerY1),
                .sprite_num(play1_num),
                .player1_color(player1_color)
		        );

   //Instantiation du module joueur2
   player2 play2(.clk(vga_clk),
                .spotX(vga_spotX),
                .spotY(vga_spotY),
		        .centerX2(centerX2),
		        .centerY2(centerY2),
                .sprite_num(play2_num),
                .player2_color(player2_color)
		        );

   //Instantiation du module flame
   flame flame(.clk(vga_clk),
               .spotX(vga_spotX),
               .spotY(vga_spotY),
		       .centerXF(centerXF),
		       .centerYF(centerYF),
               .sprite_num(flame_num),
               .flame_color(flame_color)
		       );

    //Instantiation du module wall
   wall wall(.clk(vga_clk),
             .spotX(vga_spotX),
             .spotY(vga_spotY),
		     .centerXW(centerXW),
		     .centerYW(centerYW),
             .sprite_num(wall_num),
             .wall_color(wall_color)
		     );

   // Instantiation du mixer
   mixer mix(.active(vga_blank),
             .bck_rgb(bck_rgb),
	         .player2_color(player2_color),
             .flame_color(flame_color),
             .wall_color(wall_color),
             .player1_color(player1_color),
             .vga_r(vga_r),
             .vga_g(vga_g),
             .vga_b(vga_b)
	         );

   // Debug
   assign debug = {lafin,data_out};
   assign ledg[8] = data_valid;

endmodule
