//
// This is a 68k bus controller for the Booth multiplier module.
//
// Paul Chow
// October 31, 2004
//
// $Id: bus_controller.v,v 1.4 2004/11/04 03:22:57 pc Exp pc $
//
// Registers          Address
//
// Status             16'hA000   Bit 15 Multiplier Done
//                                      Cleared on read of Product regsiter
// Interrupt Enable   16'hA002   Bit 15 Enables interrupt on IRQ6 when Done
//                                      Cleared on read of Product register
// Multiplier         16'hA004   16 bits Lower byte used as multiplier
// Multiplicand       16'hA006   16 bits Lower byte used as multiplicand
// Product            16'hA008   16 bits Contains new result when Done bit set
// Control            16'hA00A   Bit 1  Reset the multiplier
//                                      Clears after the reset is sent
//                               Bit 0  Tells multiplier to start (Go)
//                                      Cleared on read of Product register

module bus_controller (
		       i68k_address,
		       io68k_data,
		       i68k_clk,
		       i68k_as_b,
		       i68k_reset_b,
		       o68k_dtack_b,
		       i68k_lds_b,
		       i68k_uds_b,
		       i68k_rw,
		       o68k_irq6_b,

		       oMultiplier,   // from Multiplier register to multiplier
		       oMultiplicand, // from Multiplicand register
		       iProduct,      // result input from multiplier
		       oGo,           // Start signal to multiplier
		       iDone,         // Done bit from multiplier
		       oDevReset_b    // Resets the multiplier
		       ) ;
   
   input [23:1]	i68k_address;
   inout [15:0] io68k_data;
   input 	i68k_clk;
   input 	i68k_as_b;
   input 	i68k_reset_b;
   output 	o68k_dtack_b;
   input 	i68k_lds_b;
   input 	i68k_uds_b;
   input 	i68k_rw;
   output 	o68k_irq6_b;

   output [7:0] oMultiplier, oMultiplicand;
   input [15:0] iProduct;
   output oGo;
   input  iDone;
   output oDevReset_b;
   

   // Define some constants for the interface

   parameter 	device_address = 4'b1010,
		
		status_address = 3'b000,
		reg_status_done = 15, // put it in the sign bit
		
		intenable_address = 3'b001,
		multiplier_address = 3'b010,
		multiplicand_address = 3'b011,
		product_address = 3'b100,
		control_address = 3'b101,
		resvd1_address = 3'b110,
		resvd2_address = 3'b111,
		reg_control_go = 0,    // go bit
		reg_control_reset = 1  // resets the multiplier for one cycle
		;
   


   // Bus interface control logic

   wire   my_address;
   wire   read_reg,write_reg;

   // Byte reads and writes are not supported so don't really need
   // the byte data strobes.
   
   assign my_address = !i68k_as_b && (i68k_address[23:20] == device_address);
   assign read_reg = my_address && i68k_rw;
   assign write_reg = my_address && !i68k_rw;
   
   assign o68k_dtack_b = my_address ? 1'b0:1'bz;


   // Registers

   // Multiplier register
   //
   // Load the multiplier here
   // Will only look at the bottom 8 bits, but declare it as a 16-bit

   reg    [15:0] reg_multiplier;

   always @ ( posedge i68k_clk or negedge i68k_reset_b ) begin
      if (!i68k_reset_b)
	 reg_multiplier <= 16'h0000;
      else if (write_reg && (i68k_address[3:1] == multiplier_address))
	reg_multiplier <= io68k_data;
   end
   
   assign oMultiplier = reg_multiplier[7:0];  // output to the multiplier
   

   // Multiplicand register
   //
   // Load the multiplicand here
   // Will only look at the bottom 8 bits, but declare it as a 16-bit

   reg    [15:0] reg_multiplicand;
   
   always @ ( posedge i68k_clk or negedge i68k_reset_b ) begin
      if (!i68k_reset_b)
	 reg_multiplicand <= 16'h0000;
      else if (write_reg && (i68k_address[3:1] == multiplicand_address))
	 reg_multiplicand <= io68k_data;
   end
   
   assign oMultiplicand = reg_multiplicand[7:0];  // output to the multiplier


   // Product register
   //
   // The 16-bit product will be found here.
   // The register is readable and writable from the bus, but
   // would normally load the result product from the multiplier when
   // the multiplier completes.

   reg    [15:0] reg_product;
   
   always @ ( posedge i68k_clk or negedge i68k_reset_b ) begin
      if (!i68k_reset_b)
	 reg_product <= 16'h0000;
      else if (write_reg && (i68k_address[3:1] == product_address))
	 reg_product <= io68k_data;
      else if (iDone)
	 reg_product <= iProduct;  // load result from multiplier
   end
   

   // Status register

   reg    [15:0] reg_status;
   
   always @ ( posedge i68k_clk or negedge i68k_reset_b ) begin
      if (!i68k_reset_b)
	 reg_status <= 16'h0000;
      else begin
	 reg_status[reg_status_done] <= iDone; // reflect the device done bit
	 reg_status[reg_status_done-1:0] <= 15'b000000000000000;
      end 
   end


   // Control register and device reset
   
   reg    [15:0] reg_control;
   reg    DevReset;
      
   always @ ( posedge i68k_clk or negedge i68k_reset_b ) begin
      if (!i68k_reset_b)
	reg_control <= 16'h0000;
      else if (write_reg && (i68k_address[3:1] == control_address))
	reg_control <= io68k_data;  // read from bus
      else if (DevReset) begin
	 // clear reset bit
      	 reg_control[reg_control_reset] <= 1'b0;
	 // clear go bit after Product register is read and reset is sent
	 reg_control[reg_control_go] <= 1'b0;
      end
   end

   assign oGo = reg_control[reg_control_go];


   // When the reg_control_reset bit is set by the user, this FF will be
   // set and the multiplier will get a reset.
   // The reg_control_reset bit will then be cleared on the next cycle
   // (see above) and this FF will get cleared, turning off the reset
   // signal to the multiplier.
   //
   // When reg_product is read, the multiplier is also reset.  This should
   // turn off the Done bit and, therefore, the interrupt request.

   always @ ( posedge i68k_clk or negedge i68k_reset_b ) begin
      if (!i68k_reset_b)
	DevReset <= 1'b1;   // reset when the bus resets
      else if (reg_control[reg_control_reset]
	       || read_reg && (i68k_address[3:1] == product_address))
	DevReset <= 1'b1;   // will be high till reg_control bit is cleared
      else begin
	 // turn off reset bit one cycle after above conditions
	 DevReset <= 1'b0;
      end      
   end
   
   assign oDevReset_b = !DevReset;


   // Interrupt enable register
   // Uses same bit positions as control register

   reg    [15:0] reg_intenable;
   
   always @ ( posedge i68k_clk or negedge i68k_reset_b ) begin
      if (!i68k_reset_b)
	 reg_intenable <= 16'h0000;
      else if (write_reg && (i68k_address[3:1] == intenable_address))
	 reg_intenable <= io68k_data;
   end


   // Request an interrupt if interrupts are enabled
   // Note that this is not actually the 68k bus signal, so don't tri-state!

   assign o68k_irq6_b = !(reg_intenable[reg_status_done]
			  && reg_status[reg_status_done]);
   

   // This is a multiplexer to select which register to drive to the bus

   reg    [15:0] read_data;

   always @*  begin  // using Verilog 2001

	 case (i68k_address[3:1]) 
	   multiplier_address: begin
	      read_data = reg_multiplier;
	   end

	   multiplicand_address: begin
	      read_data = reg_multiplicand;
	   end

	   product_address: begin
	      read_data = reg_product;
	   end

	   status_address: begin
	      read_data = reg_status;
	   end

	   control_address: begin
	      read_data = reg_control;
	   end

	   intenable_address: begin
	      read_data = reg_intenable;
	   end

	   resvd1_address: begin
	      read_data = 16'h1111;
	   end

	   resvd2_address: begin
	      read_data = 16'h2222;
	   end

	   default: begin
	      read_data = 16'hdead;
	   end
	 endcase // case(i68k_address[3:1])
   end

   // Figure out if there is a read and drive the data bus

   assign io68k_data = read_reg ? read_data : 16'hzzzz;
   

endmodule // bus_controller
