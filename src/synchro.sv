module synchro(input clock_50,
               input              reset_n,
               output logic       HS,        //signal ligne, a 0 dans Hsync et 1 dans le reste
               output logic       VS,        // signal vertical, a0 dans Vsync et 1 dans le reste
               output logic       SOF,       // debut de trame
               output logic       EOF,       // fin de trame
               output logic       SOL,       // debut de ligne
               output logic       EOL,       // fin de ligne
               output logic [9:0] spotX,     // position X
               output logic [9:0] spotY,     // position Y
               output logic       Blank,     //a 0 dans la zone inactive
               output logic       Sync,      // a 0
               output logic [9:0] R,G,B);    // couleurs rouge vert bleu

// les compteurs en X et Y
   logic [10:0]                   comptX;
   logic [10:0]                   comptY;

   always @(posedge clock_50 or  negedge reset_n)
     if(~reset_n)

       begin
          spotX <= -1;
          spotY <= -1;
          Blank <= 0;
          R,G,B <= 0;
          Sync <= 0;
          SOL,SOF,EOL,EOF,VS,HS <= 0;
          comptX,comptY <= 0;
       end


     else

       begin
          comptX <= comptX + 1;
          if(comptX<120)
            HS <= 0;
          else if(comptX < 184)
            HS <= 1;
          else if( comptX == 184)
            begin
               EOL <= 1;







endmodule