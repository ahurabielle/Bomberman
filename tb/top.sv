`default_nettype none

  module top();

   logic          vga_clk;                      // vga clock
   logic          vga_hs;                       // vga h_sync
   logic          vga_vs;                       // vga v_sync
   logic          vga_blank;                    // vga blank
   logic          vga_sync;                     // vga sync
   logic [9:0]    vga_r;                        // vga red[9:0]
   logic [9:0]    vga_g;                        // vga green[9:0]
   logic [9:0]    vga_b;                        // vga blue[9:0]

   logic          clock_50;
   logic [17:0]   sw;
   logic [6:0]    hex0;         // seven segment digit 0
   logic [6:0]    hex1;         // seven segment digit 1
   logic [6:0]    hex2;         // seven segment digit 2
   logic [6:0]    hex3;         // seven segment digit 3
   logic [6:0]    hex4;         // seven segment digit 4
   logic [6:0]    hex5;         // seven segment digit 5
   logic [6:0]    hex6;         // seven segment digit 6
   logic [6:0]    hex7;         // seven segment digit 7

   logic [8:0]    ledg;         // led green[8:0]
   logic [17:0]   ledr;         // led red[17:0]

   logic [3:0]    key;

   // PS2
   logic          ps2_dat = 1;      // ps2 data
   logic          ps2_clk = 1;      // ps2 clock

   // Instantiation du FPGA
   DE2_fpga DE2_fpga(.clock_50,
                     .vga_clk,
                     .vga_hs,
                     .vga_vs,
                     .vga_blank,
                     .vga_sync,
                     .vga_r,
                     .vga_g,
                     .vga_b,
                     .sw,
                     .hex0, .hex1, .hex2, .hex3, .hex4, .hex5, .hex6, .hex7,
                     .ledg,
                     .ledr,
                     .ps2_dat,
                     .ps2_clk);

   // Génération de l'horloge 50MHz
   initial
     clock_50 = 0;

   always
     #20 clock_50 <= ~clock_50;

   // Valeurs des switchs, etc.
   assign sw = 0;
   assign key=4'b1111;

endmodule


