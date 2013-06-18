module keyboard( input  clk,
                 input  reset_n,
                 input  ps2_data,
                 output data_out
                 );
   // buffer
   logic [8:0]          buffer;
   logic                parity;

   //bit de parite
   always @(*)
     parity <= (buffer[0] + buffer[1] + buffer[2] + buffer[3] + buffer[4] + buffer[5] + buffer[6] + buffer[7]);


   //envoie
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       begin
          data_out <= 0;
          buffer   <= 0;
       end
     else
       begin
          if (((~compt) == 10) && ((~compt) == 0)))
           {buffer} <= {buffer[7:0],ps2_data};
           if((parity == buffer[8]) && (compt == 10))
            data_out <= buffer[7:0];

       end // else: !if(~reset_n)

   // incrementation du compteur
   always @(posedge clk or negedge reset_n)
     if(~reset_n)
       compt <= 0;
     else
       begin
          if(compt < 10)
            compt <= compt + 1;
          else
            compt <= 0;
       end



endmodule // keyboard


