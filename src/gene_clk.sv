`default_nettype none
  module gene_clk(clk_50,
                  clk_1s);
   
   input logic  clk_50;
   output logic clk_1s;
   
   // Compteur de division de l'horloge à 50MHz
   logic [25:0] cpt;

   always_ff @(posedge clk_50)
     if (cpt == 49_999_999)
       cpt <= 0;
     else
       cpt <= cpt + 1;

   always_ff @(posedge clk_50)
     clk_1s <= cpt < 25_000_000;

  
endmodule // gene_clk






   