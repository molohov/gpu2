//-----------------------------------------------------------------------------
//
// This is a Booth recoded 8x8 multiplier producing a 16-bit product.
//
// Shift and add are done in the same cycle
//
// Paul Chow
// Department of Electrical and Computer Engineering
// University of Toronto
//
// October 2004
//
// $Id: booth.v,v 1.4 2004/11/04 16:37:50 pc Exp pc $
//
//-----------------------------------------------------------------------------

module booth(
             iClk,      // input clock
             iReset_b,  // reset signal
             iGo,       // indicates inputs are ready
             oDone,     // indicates that the result is ready
             iMer,      // 8-bit multiplier
             iMand,     // 8-bit multiplicand
             oProduct   // 16-bit product
             );

    input iClk,iReset_b,iGo;
    input [7:0] iMer,iMand;
    output oDone;
    output [15:0] oProduct;


    // State names

    parameter	WaitForGoState = 0,
		InitState = 1,
		AddShiftState = 2,
		DoneState =3;

    reg [1:0] PresentState, NextState;

    reg [1:0] NumShifts;

    reg [18:0] Product;
    reg [9:0] Sum;


//-----------------------------------------------------------------------------
//  This is the main FSM controller
//-----------------------------------------------------------------------------

    always @(iGo,PresentState,NumShifts)
        
    begin :  Controller
        case (PresentState)

            WaitForGoState:
                if (iGo)
                    NextState = InitState;
                else
                    NextState = WaitForGoState;

            InitState:
                NextState = AddShiftState;

            AddShiftState:
                if (NumShifts == 2'b00)
                    NextState = DoneState;
                else
                    NextState = AddShiftState;

            DoneState:
                NextState = DoneState;

	    default:
		NextState = InitState;
        endcase //  PresentState
    end // Controller;
    


    always @(posedge iClk or negedge iReset_b)
    
    begin //  StateRegs
        if (!iReset_b)
            PresentState <= WaitForGoState;
        else
            PresentState <= NextState;
    end // StateRegs;


//-----------------------------------------------------------------------------
//  This does the addition of the appropriate version of the multiplicand
//-----------------------------------------------------------------------------

    reg [9:0] Mand1,Mand2;

    always @(Product,iMand)
        
    begin //  Adder
        Mand1 = {iMand[7],iMand[7],iMand};  // sign extend to 10 bits
        Mand2 = Mand1<<1;

        case (Product[2:0])
            3'b000:
                Sum = Product[18:9];
            3'b001:
                Sum = Product[18:9] + Mand1;
            3'b010:
                Sum = Product[18:9] + Mand1;
            3'b011:
                Sum = Product[18:9] + Mand2;
            3'b100:
                Sum = Product[18:9] - Mand2;
            3'b101:
                Sum = Product[18:9] - Mand1;
            3'b110:
                Sum = Product[18:9] - Mand1;
            default:
                Sum = Product[18:9];
        endcase  //  Product[2:0]
    end // Adder


//-----------------------------------------------------------------------------
//  This is the Product register and counter
//-----------------------------------------------------------------------------

    always @(posedge iClk)
        
    begin //  ProdReg
            case (PresentState)

                WaitForGoState:
		    ;
                InitState:
		  begin
                    Product[18:9] <= 10'b0000000000;
                    Product[8:1] <= iMer;
                    Product[0] <= 1'b0;
                    NumShifts <= 2'b11;
		  end

                AddShiftState:
		  begin
                    //---------------------------------------------------------
                    //  This takes the Sum, sign extends it to 12 bits and
                    //  puts that into the top part of the Product register,
                    //  effectively shifting it at the same time.  The bottom
                    //  part of the register is loaded with a shifted value of
                    //  the previous contents in that part.
                    //  The counter is also updated here.
                    //---------------------------------------------------------
                    Product[18:7] <= {Sum[9],Sum[9],Sum};
                    Product[6:0] <= Product[8:2];
                    NumShifts <= NumShifts - 2'b01;
		  end
                DoneState:
		;
            endcase //  PresentState

    end //ProdReg;

    
//-----------------------------------------------------------------------------
//  The output product and done signal.
//-----------------------------------------------------------------------------

    assign oProduct = Product[16:1];

    assign oDone = (PresentState == DoneState) ? 1'b1:1'b0;

endmodule  // of booth

