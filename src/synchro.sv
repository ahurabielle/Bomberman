module synchro(input                      clk,
               input                      reset_n,
               output logic               HS, //signal ligne, a 0 dans Hsync et 1 dans le reste
               output logic               VS, // signal vertical, a0 dans Vsync et 1 dans le reste
               output logic               SOF, // debut de trame
               output logic               EOF, // fin de trame
               output logic               SOL, // debut de ligne
               output logic               EOL, // fin de ligne
               output logic signed [10:0] spotX, // position X
               output logic signed [10:0] spotY, // position Y
               output logic               blank, //a 0 dans la zone inactive
               output logic               sync); // a 0

   // les compteurs en X et Y
   logic [10:0]                           comptX;
   logic [10:0]                           comptY;

   // Constantes liees a la resolution
   localparam integer                     VFP      = 37;
   localparam integer                     VSYNC    = 6;
   localparam integer                     VBP      = 23;
   localparam integer                     VACTIVE  = 600 ;
   localparam integer                     HFP      = 56;
   localparam integer                     HACTIVE  = 800;
   localparam integer                     HBP      = 64;
   localparam integer                     HSYNC    = 120;

   // compteur en X
   always @(posedge clk or  negedge reset_n)
     if(~reset_n)
       begin
          comptX <= 0;
       end
     else
       begin
          if (comptX < (HBP+HACTIVE+HSYNC+HFP-1) )
            comptX <= comptX + 1;
          else comptX <= 0;
       end // else: !if(~reset_n)


   // Compteur en Y
   always @(posedge clk or  negedge reset_n)
     if(~reset_n)
       begin
          comptY <= 0;
       end
     else
       begin
          if (comptX == (HBP+HACTIVE+HSYNC+HFP-1))
            begin
               if (comptY < (VBP+VACTIVE+VSYNC+VFP-1))
                 comptY <= comptY + 1;
               else
                 comptY <= 0;
            end
       end // else: !if(~reset_n)


   // Réglage des sorties
   always @(posedge clk)
     begin
        sync  <= 0;
        VS    <= (comptY >= VSYNC);
        HS    <= (comptX >= HSYNC);
        blank <= ((comptX >= (HSYNC + HBP)) && (comptX < (HSYNC + HBP + HACTIVE))
                   && (comptY >= (VSYNC + VBP)) && (comptY < (VSYNC + VBP + VACTIVE)));
        SOF   <= ((comptX == (HSYNC + HBP)) && (comptY == (VSYNC + VBP)));
        SOL   <= ((comptX == (HSYNC + HBP)) && (comptY>= (VSYNC + VBP)) && (comptY < VSYNC+VBP+VACTIVE));
        EOF   <= (comptX == (HSYNC + HBP + HACTIVE -1) && comptY == (VSYNC + VBP + VACTIVE -1));
        EOL   <= (comptX == (HSYNC + HBP + HACTIVE -1) && (comptY>= (VSYNC + VBP)) && (comptY < VSYNC+VBP+VACTIVE));

        if((comptY>= (VSYNC + VBP)) && (comptY < VSYNC+VBP+VACTIVE) && (comptX >=HSYNC+HBP) && (comptX < HSYNC+HBP+HACTIVE))
          begin
             // dans la zone active on incremente le long d une ligne
             spotX <= (comptX -(HSYNC+HBP));
             // et d'une colonne
             spotY <= (comptY -(VSYNC+VBP));
          end
        else
          begin
             spotX <= -1;
             spotY <= -1;
          end
     end // always @ (*)

endmodule // synchro


