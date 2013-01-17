
`timescale  1 ns / 1 ps



module fibonacci_tb
  (	
        );

   `define top_clk_per 100
   `define Max_Sim_Time 1000000000     // stop simulation after this time (ns)
   
   reg top_clk;
   reg top_reset;
   wire [15:0] top_fibonacci_out;
   
   
   fibonacci my_fibonacci
     (
      .clk(top_clk),
      .reset(top_reset),
      .fibonacci_out(top_fibonacci_out)
      );

   
   always #(`top_clk_per/2) top_clk = ~top_clk;

   initial begin
      // Initialize TB signals
      top_clk = 1'b0;
      top_reset = 1'b1;
      
      #800;  
      $display ("\nReset asserted at time = %t", $realtime);
      top_reset = 1'b0;
      #800;
      top_reset = 1'b1;
         
   end

   
///////////////////////////////////////////////////////////////////////////////
// Always End at Max_Sim_Time
///////////////////////////////////////////////////////////////////////////////

initial
  begin
    #(`Max_Sim_Time);
    $stop;
  end

   
endmodule
