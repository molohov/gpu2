
module full_adder
  (	
        // full adder inputs
        a,
        b,
        cin,
        
        // full adder outputs
        sum,
        cout
        );
   
   input                a;
   input                b;
   input                cin;
   output               sum;
   output               cout;
                           
   wire                  sum;
   wire                  cout;
   
   assign               sum = a ^^ b ^^ cin;
   assign               cout = (a && b) || (a && cin) || (b && cin);

endmodule
