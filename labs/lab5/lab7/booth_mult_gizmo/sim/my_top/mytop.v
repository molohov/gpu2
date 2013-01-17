//
// This is the top-level that connects a 68k bus controller
// to a Booth recoded multiplier module.
//
// To use on the Gizmo board, you can drop it into the provided wrapper.
// This version of a top level was created because the names used in the
// one provided are confusing.  See naming convention below.
//
// Paul Chow
// October 31, 2004
//
// $Id: mytop.v,v 1.3 2004/11/04 03:23:07 pc Exp pc $
//
// The design is intended as an example of a reasonable coding style and
// to show usage of the 68K bus.
//
// Coding style points to consider:
//   Naming convention - Port signals prefixed by i/o/io to indicate direction
//   Polarity - Active low signals have suffix of _b
//   Meaningful names for signals
//   Use parameters to define magic numbers
//   Comments!
//   Separation of combinational and sequential logic
//   Related logic kept close together in the code as much as possible
//

module my_top (
	i68k_address,
	io68k_data,
	i68k_clk,
	i68k_as_b,
	i68k_lds_b,
	i68k_uds_b,
	i68k_reset_b,
	o68k_dtack_b,
	i68k_rw,
	o68k_irq6_b
);

   // port signals
   // 68k bus signals

   input [23:1]	i68k_address;
   inout [15:0] io68k_data;
   input 	i68k_clk;
   input 	i68k_as_b;
   input 	i68k_lds_b;
   input 	i68k_uds_b;
   input 	i68k_reset_b;
   output 	o68k_dtack_b;
   input 	i68k_rw;
   output 	o68k_irq6_b;


   // wires at top level

   wire   [7:0] wMultiplier, wMultiplicand;
   wire   [15:0] wProduct;
   wire   wDevReset_b, wGo, wDone;
   

bus_controller bus_interface
  (
   
   .i68k_address(i68k_address),
   .io68k_data(io68k_data),
   .i68k_clk(i68k_clk),
   .i68k_as_b(i68k_as_b),
   .i68k_reset_b(i68k_reset_b),
   .o68k_dtack_b(o68k_dtack_b),
   .i68k_lds_b(i68k_lds_b),
   .i68k_uds_b(i68k_uds_b),
   .i68k_rw(i68k_rw),
   .o68k_irq6_b(o68k_irq6_b),
   
   .oMultiplier(wMultiplier),
   .oMultiplicand(wMultiplicand),
   .iProduct(wProduct),
   
   .oGo(wGo),                 // Start signal to device
   .iDone(wDone),             // Done bit from device
   .oDevReset_b(wDevReset_b)  // Resets the device
   ) ;


booth multiplier
  (
   .iClk(i68k_clk),
   .iReset_b(wDevReset_b),
   .iGo(wGo),
   .oDone(wDone),
   .iMer(wMultiplier),
   .iMand(wMultiplicand),
   .oProduct(wProduct)
   );



endmodule

