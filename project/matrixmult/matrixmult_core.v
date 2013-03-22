//----------------------------------------------------------------------------
// matrixmult - module
//----------------------------------------------------------------------------
// IMPORTANT:
// DO NOT MODIFY THIS FILE EXCEPT IN THE DESIGNATED SECTIONS.
//
// SEARCH FOR --USER TO DETERMINE WHERE CHANGES ARE ALLOWED.
//
// TYPICALLY, THE ONLY ACCEPTABLE CHANGES INVOLVE ADDING NEW
// PORTS AND GENERICS THAT GET PASSED THROUGH TO THE INSTANTIATION
// OF THE USER_LOGIC ENTITY.
//----------------------------------------------------------------------------
//
// ***************************************************************************
// ** Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.            **
// **                                                                       **
// ** Xilinx, Inc.                                                          **
// ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
// ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
// ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
// ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
// ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
// ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
// ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
// ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
// ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
// ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
// ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
// ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
// ** FOR A PARTICULAR PURPOSE.                                             **
// **                                                                       **
// ***************************************************************************
//
//----------------------------------------------------------------------------
// Filename:          matrixmult
// Version:           1.00.a
// Description:       Example FSL core (Verilog).
// Date:              Tue Mar 19 11:58:28 2013 (by Create and Import Peripheral Wizard)
// Verilog Standard:  Verilog-2001
//----------------------------------------------------------------------------
// Naming Conventions:
//   active low signals:                    "*_n"
//   clock signals:                         "clk", "clk_div#", "clk_#x"
//   reset signals:                         "rst", "rst_n"
//   generics:                              "C_*"
//   user defined types:                    "*_TYPE"
//   state machine next state:              "*_ns"
//   state machine current state:           "*_cs"
//   combinatorial signals:                 "*_com"
//   pipelined or register delay signals:   "*_d#"
//   counter signals:                       "*cnt*"
//   clock enable signals:                  "*_ce"
//   internal version of output port:       "*_i"
//   device pins:                           "*_pin"
//   ports:                                 "- Names begin with Uppercase"
//   processes:                             "*_PROCESS"
//   component instantiations:              "<ENTITY_>I_<#|FUNC>"
//----------------------------------------------------------------------------

////////////////////////////////////////////////////////////////////////////////
//
//
// Definition of Ports
// FSL_Clk             : Synchronous clock
// FSL_Rst           : System reset, should always come from FSL bus
// FSL_S_Clk       : Slave asynchronous clock
// FSL_S_Read      : Read signal, requiring next available input to be read
// FSL_S_Data      : Input data
// FSL_S_Control   : Control Bit, indicating the input data are control word
// FSL_S_Exists    : Data Exist Bit, indicating data exist in the input FSL bus
// FSL_M_Clk       : Master asynchronous clock
// FSL_M_Write     : Write signal, enabling writing to output FSL bus
// FSL_M_Data      : Output data
// FSL_M_Control   : Control Bit, indicating the output data are contol word
// FSL_M_Full      : Full Bit, indicating output FSL bus is full
//
////////////////////////////////////////////////////////////////////////////////

//----------------------------------------
// Module Section
//----------------------------------------
module matrixmult 
	(
		// ADD USER PORTS BELOW THIS LINE 
		// -- USER ports added here 
		// ADD USER PORTS ABOVE THIS LINE 

		// DO NOT EDIT BELOW THIS LINE ////////////////////
		// Bus protocol ports, do not add or delete. 
		FSL_Clk,
		FSL_Rst,
		FSL_S_Clk,
		FSL_S_Read,
		FSL_S_Data,
		FSL_S_Control,
		FSL_S_Exists,
		FSL_M_Clk,
		FSL_M_Write,
		FSL_M_Data,
		FSL_M_Control,
		FSL_M_Full
		// DO NOT EDIT ABOVE THIS LINE ////////////////////
	);

// ADD USER PORTS BELOW THIS LINE 
// -- USER ports added here 
// ADD USER PORTS ABOVE THIS LINE 

input                                     FSL_Clk;
input                                     FSL_Rst;
input                                     FSL_S_Clk;
output                                    FSL_S_Read;
input      [0 : 31]                       FSL_S_Data;
input                                     FSL_S_Control;
input                                     FSL_S_Exists;
input                                     FSL_M_Clk;
output                                    FSL_M_Write;
output     [0 : 31]                       FSL_M_Data;
output                                    FSL_M_Control;
input                                     FSL_M_Full;

// ADD USER PARAMETERS BELOW THIS LINE 
// --USER parameters added here 
// ADD USER PARAMETERS ABOVE THIS LINE


//----------------------------------------
// Implementation Section
//----------------------------------------
// In this section, we povide an example implementation of MODULE matrixmult
// that does the following:
//
// 1. Read all inputs
// 2. Add each input to the contents of register 'sum' which
//    acts as an accumulator
// 3. After all the inputs have been read, write out the
//    content of 'sum' into the output FSL bus NUMBER_OF_OUTPUT_WORDS times
//
// You will need to modify this example for
// MODULE matrixmult to implement your coprocessor

   // Total number of input data.
   localparam NUMBER_OF_INPUT_WORDS  = 8;

   // Total number of output data
   localparam NUMBER_OF_OUTPUT_WORDS = 1; //4;

   // Define the states of state machine
   localparam Idle  = 3'b100;
   localparam Read_Inputs = 3'b010;
   localparam Write_Outputs  = 3'b001;

   reg [0:2] state;

   // Accumulator to hold sum of inputs read at any point in time
   //reg [0:31] sum;



   // Counters to store the number inputs read & outputs written
   reg [0:NUMBER_OF_INPUT_WORDS - 1] nr_of_reads;
   reg [0:NUMBER_OF_OUTPUT_WORDS - 1] nr_of_writes;

   // CAUTION:
   // The sequence in which data are read in should be
   // consistent with the sequence they are written in the
   // driver's matrixmult.c file

   wire write_enable;
   assign FSL_S_Read  = (state == Read_Inputs) ? FSL_S_Exists : 0; 
   assign FSL_M_Write = (state == Write_Outputs & write_enable == 1) ? ~FSL_M_Full : 0;

   wire [31:0] result0;	
   wire [31:0] result1;	
   wire [31:0] result2;	
   wire [31:0] result3;
   reg [31:0] data_out;
   assign FLS_S_Data = data_out;

   wire [2:0] count;	
   wire done;
   wire toggle_avalid, toggle_bvalid;
	
   //INSTANTIATE MATRIX MULTIPLIER MODULES//
   //note: expected to provide inputs in order of multiplication 
   //example for row 0: element00, pixel0, element01, pixel1, element02, pixel2, element03, pixel3
   matrixmultiplier matrixmult(
		.clk(FSL_Clk),
		.reset(FSL_Rst),
		.a(FSL_S_Data),
		.b(FSL_S_Data),
		.a_tvalid(FLS_S_Exists & toggle_avalid), //??????????????
		.b_tvalid(FLS_S_Exists & toggle_bvalid), //??????????????
		.result0(result0),
		.result1(result1),
		.result2(result2),
		.result3(result3),
		.count(count),
		.done_matrixmult(done)
	);

    //this flip flop starts at 0, toggles every clock cycle
    tff tff_avlalid(
		.clk(clk),
		.reset(reset),
		.set(1'b0),
		.t(1'b1),
		.q(toggle_avalid)
	);

    //this flip flop starts at 1, toggles every clock cycle
    tff tff_bvalid(
		.clk(clk),
		.reset(1'b0),
		.set(reset),
		.t(1'b1),
		.q(toggle_bvalid)
	);


   posedge_pulse write_enabler(
		.clk(FLS_Clk),
		.reset(FSL_Rst),
		.signal(count),
		.signal_pulse(write_enable)
	);




   always @(posedge FSL_Clk) 
   begin
	if (count == 1) begin
		data_out <= result0;
	end
	else if (count == 2) begin
		data_out <= result1;
	end
	else if (count == 3) begin
		data_out <= result2;
	end
	else if (count == 0) begin
		data_out <= result3;
	end
   end	

   always @(posedge FSL_Clk) 
   begin  // process The_SW_accelerator
      if (FSL_Rst)               // Synchronous reset (active high)
        begin
           // CAUTION: make sure your reset polarity is consistent with the
           // system reset polarity
           state        <= Idle;
           nr_of_reads  <= 0;
           nr_of_writes <= 0;
           //sum          <= 0;
        end
      else
        case (state)
          Idle: 
            if (FSL_S_Exists == 1)
            begin
              state       <= Read_Inputs;
              nr_of_reads <= NUMBER_OF_INPUT_WORDS - 1;
              //sum         <= 0;
            end

          Read_Inputs: 
            if (FSL_S_Exists == 1) 
            begin
              // Coprocessor function (Adding) happens here
              //sum         <= sum + FSL_S_Data;
              if (nr_of_reads == 0)
                begin
                  state        <= Write_Outputs;
                  nr_of_writes <= NUMBER_OF_OUTPUT_WORDS - 1;
                end
              else
                nr_of_reads <= nr_of_reads - 1;
            end

          Write_Outputs: 
            if (nr_of_writes == 0) 
              state <= Idle;
            else
              if (FSL_M_Full == 0 & write_enable == 1)  nr_of_writes <= nr_of_writes - 1;
        endcase
   end

endmodule



////////////////////////////////////////////////////////////////////////////
//                 FLOATING POINT MATRIX MULTIPLICATION MODULES           //
////////////////////////////////////////////////////////////////////////////

//stay high for only one cycle on posedge of signal
module posedge_pulse(
		input clk,
		input reset,
		input [2:0] signal,
		output reg signal_pulse

		);

	wire [2:0] prev;

	always @(posedge clk)
		if (reset)
			signal_pulse <= 0;
		else if (prev == 0 & signal == 1) //posedge
			signal_pulse <= 1'b1;
		else if (prev == 1)
			signal_pulse <= 1'b0;

endmodule


//toggle flip-flop
module tff(
		input clk,
		input reset,
		input set,
		input t,
		output q
		);
	reg tff;

	always @ (posedge clk)
		if (reset)
			tff <= 1'b0;
		else if (set)
			tff <= 1'b1;
		else if (t)
			tff <= ~tff;
		else
			tff <= tff;

	assign q = tff;
endmodule

//latch matrix result elements and count up to 4 (then you have all elements of result matrix ready)
module latch_matrixmult(
		input clk,
		input reset,
		input [31:0] element_in,
		input new_element,	//need to pulse for one cycle only
		output reg [31:0] element0,
		output reg [31:0] element1,
		output reg [31:0] element2,
		output reg [31:0] element3,
		output reg [2:0] count,
		output reg done_matrix

	);

	//reg [2:0] count;

	always @ (posedge clk)
	begin
		if (reset)
			begin 
			element0 <= 32'b0;
			element1 <= 32'b0;
			element2 <= 32'b0;
			element3 <= 32'b0;
			count <= 3'b0;
			done_matrix <= 1'b0;
			end
		else if (new_element && count == 0)	
			begin
			element0 <= element_in;
			element1 <= element1;
			element2 <= element2;
			element3 <= element3;
			count <= count + 1'b1;
			done_matrix <= 1'b0;
			end
		else if (new_element && count == 1)	
			begin
			element0 <= element0;
			element1 <= element_in;
			element2 <= element2;
			element3 <= element3;
			count <= count + 1'b1;
			done_matrix <= 1'b0;
			end
		else if (new_element && count == 2)	
			begin
			element0 <= element0;
			element1 <= element1;
			element2 <= element_in;
			element3 <= element3;
			count <= count + 1'b1;
			done_matrix <= 1'b0;
			end
		else if (new_element && count == 3)	
			begin
			element0 <= element0;
			element1 <= element1;
			element2 <= element2;
			element3 <= element_in;
			count <= 3'b0;
			done_matrix <= 1'b1;
			end
		else
			begin
			element0 <= element0;
			element1 <= element1;
			element2 <= element2;
			element3 <= element3;
			count <= count;
			done_matrix <= 1'b0;
			end
	end


endmodule

//provide 2 inputs at a time and assert inputs_ready to start, then keep going
//computes a[i]*b[i]=c[i] when inputs are given, then then computes result = (c[0] + c[1]) + (c[2] + c[3])
module matrixmultiplier (
		input clk,
		input reset,
		input a_tvalid,
		input b_tvalid,
		input [31:0] a,
		input [31:0] b,
		output [31:0] result0,
		output [31:0] result1,
		output [31:0] result2,
		output [31:0] result3,
		output done_matrixmult
		);


	wire [31:0] product_tdata;
	wire product_tvalid; 
	wire t_inner, t_outer;

	wire sum_inner_tvalid, sum_outer_tvalid;

	wire [31:0] sum_inner_tdata;
	wire [31:0] sum_outer_tdata;

	floating_point_v6_1 fmul (
	  .aclk(clk), // input aclk
	  .s_axis_a_tvalid(a_tvalid), // input s_axis_a_tvalid
	  .s_axis_a_tready(), // output s_axis_a_tready
	  .s_axis_a_tdata(a), // input [31 : 0] s_axis_a_tdata
	  .s_axis_b_tvalid(b_tvalid), // input s_axis_b_tvalid
	  .s_axis_b_tready(), // output s_axis_b_tready
	  .s_axis_b_tdata(b), // input [31 : 0] s_axis_b_tdata
	  .m_axis_result_tvalid(product_tvalid), // output m_axis_result_tvalid
	  .m_axis_result_tready(1'b1), // input m_axis_result_tready
	  .m_axis_result_tdata(product_tdata), // output [31 : 0] m_axis_result_tdata
	  .m_axis_result_tuser() // output [2 : 0] m_axis_result_tuser
	);

	floating_point_add_sub_v6_1 fadd_inner (
	  .aclk(clk), // input aclk
	  .s_axis_a_tvalid(product_tvalid & t_inner), // input s_axis_a_tvalid
	  .s_axis_a_tready(), // output s_axis_a_tready
	  .s_axis_a_tdata(product_tdata), // input [31 : 0] s_axis_a_tdata
	  .s_axis_b_tvalid(product_tvalid & ~t_inner), // input s_axis_b_tvalid
	  .s_axis_b_tready(), // output s_axis_b_tready
	  .s_axis_b_tdata(product_tdata), // input [31 : 0] s_axis_b_tdata
	  .s_axis_operation_tvalid(product_tvalid & t_inner), // input s_axis_operation_tvalid
	  .s_axis_operation_tready(), // output s_axis_operation_tready
	  .s_axis_operation_tdata(8'b0), // input [7 : 0] s_axis_operation_tdata
	  .m_axis_result_tvalid(sum_inner_tvalid), // output m_axis_result_tvalid
	  .m_axis_result_tready(1'b1), // input m_axis_result_tready
	  .m_axis_result_tdata(sum_inner_tdata), // output [31 : 0] m_axis_result_tdata
	  .m_axis_result_tuser() // output [2 : 0] m_axis_result_tuser
	);

	floating_point_add_sub_v6_1 fadd_outer (
	  .aclk(clk), // input aclk
	  .s_axis_a_tvalid(sum_inner_tvalid & t_outer), // input s_axis_a_tvalid
	  .s_axis_a_tready(), // output s_axis_a_tready
	  .s_axis_a_tdata(sum_inner_tdata), // input [31 : 0] s_axis_a_tdata
	  .s_axis_b_tvalid(sum_inner_tvalid & ~t_outer), // input s_axis_b_tvalid
	  .s_axis_b_tready(), // output s_axis_b_tready
	  .s_axis_b_tdata(sum_inner_tdata), // input [31 : 0] s_axis_b_tdata
	  .s_axis_operation_tvalid(sum_inner_tvalid & t_outer), // input s_axis_operation_tvalid
	  .s_axis_operation_tready(), // output s_axis_operation_tready
	  .s_axis_operation_tdata(8'b0), // input [7 : 0] s_axis_operation_tdata
	  .m_axis_result_tvalid(sum_outer_tvalid), // output m_axis_result_tvalid
	  .m_axis_result_tready(1'b1), // input m_axis_result_tready
	  .m_axis_result_tdata(sum_outer_tdata), // output [31 : 0] m_axis_result_tdata
	  .m_axis_result_tuser() // output [2 : 0] m_axis_result_tuser
	);

	tff tff_inner(
		.clk(clk),
		.reset(reset),
		.set(1'b0),
		.t(product_tvalid),
		.q(t_inner)
	);

	tff tff_outer(
		.clk(clk),
		.reset(reset),
		.set(1'b0),
		.t(sum_inner_tvalid),
		.q(t_outer)
	);

	latch_matrixmult latch(
		.clk(clk),
		.reset(reset),
		.element_in(sum_outer_tdata),
		.new_element(sum_outer_tvalid),	//need to pulse for one cycle only
		.element0(result0),
		.element1(result1),
		.element2(result2),
		.element3(result3),
		.done_matrix(done_matrixmult)
		);

endmodule