module controleur (input                      clk,
		   input 		      reset_n, 
		   input logic 		      SOF, // va délimiter le temps durant lequel center pourra etre modifie
		   input logic 		      EOF, // va délimiter le temps durant lequel center pourra etre modifie
		   input logic [3:0] 	      key, // va permettre de modifier le centre
		   output logic signed [10:0] centerX,// coordonnee en X du centre
		   output logic signed [10:0] centerY // coordonnee en Y du centre
		   );


   logic 				      verou_trame ;
   logic [11:0] 			      compt;
   localparam integer 			      HACTIVE = 800;
   localparam integer 			      VACTIVE = 600;
 			      
   // instantiation du verou, a 1 quand le spot trace l'image sur l ecran    
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       verou_trame <= 1;
     else if(EOF)
       verou_trame <= 0;
     else if(SOF)
       verou_trame <= 1;
     else
       verou_trame <= verou_trame;

   // instantiation du compteur pour reduire la vistesse de l horloge
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       compt <= 0;
     else if(~verou_trame)
       compt <= compt + 1;
    
   // bouger le centre a l aide de key
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       begin
	  centerX <= 400;
	  centerY <= 300;
       end
     else if(~verou_trame && compt == 3000)
       case(key)
	 4'b1110 : if(centerX < HACTIVE)   centerX <= centerX + 1;
	 4'b1101 : if(centerY < VACTIVE)   centerY <= centerY + 1;
	 4'b1011 : if(centerY >= 0)        centerY <= centerY - 1;
	 4'b0111 : if(centerX >= 0)        centerX <= centerX - 1;
	 4'b1100 : if((centerX < HACTIVE) && (centerY < VACTIVE))
	   begin
	      centerX <= centerX + 1;
	      centerY <= centerY +1 ;
	   end
	 
	 4'b1010 : if((centerX < HACTIVE) && (centerY >= 0))
	   begin
	      centerX <= centerX + 1;
	      centerY <= centerY - 1;
	   end	 
	 4'b0011 : if ((centerX >= 0) && (centerY >= 0))
	   begin
	      centerX <= centerX - 1;
	      centerY <= centerY - 1;
	   end	 
	 4'b0101 : if((centerX >= 0) && (centerY < VACTIVE))
	   begin
	      centerX <= centerX - 1;
	      centerY <= centerY + 1;
	   end	 
	 default : 
	   begin
	      centerX <= centerX;
	      centerY <= centerY;
	   end
       endcase // case (key)
endmodule // controleur






	 
	  
	
      
	  
   
		    
