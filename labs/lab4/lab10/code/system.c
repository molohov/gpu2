#include "xparameters.h"
#include "mb_interface.h"
#include "xbasic_types.h"

int main(void) 
{
  int i,j,k,r;

  int data_to_local_link[] = {
    23170, 23170, 23170, 23170, 23170, 23170, 23170, 23170,
    32138, 27246, 18205,  6393, -6393,-18205,-27246,-32138,
    30274, 12540,-12540,-30274,-30274,-12540, 12540, 30274,
    27246, -6593,-32138,-18205, 18205, 32138,  6393,-27246,
    23170,-23170,-23170, 23170, 23170,-23170,-23170, 23170,
    18205,-32138,  6393, 27246,-27246, -6393, 32138,-18205,
    12540,-30274, 30274,-12540,-12540, 30274,-30274, 12540,
     6393,-18205, 27246,-32138, 32138,-27246, 18205, -6393
  }; 

  int data_back_local_link[64];

  // Printing a banner on the Hyper Terminal.
  print("\t#########################################\n\r");
  print("\t#                                       #\n\r");
  print("\t#      FSL Channel Reference Design     #\n\r");
  print("\t#      MicroBlaze Development Board     #\n\r");
  print("\t#                                       #\n\r");
  print("\t#########################################\n\r");
  print("\n\r\n\r");

  k = 0; r = 0;
  for (j=0;j<8;j++) {
    if (j==0)
      xil_printf("Perform %dst Datablock out of 8\n\r",j+1);
    else if (j==1)
      xil_printf("Perform %dnd Datablock out of 8\n\r",j+1);
    else if (j==2)
      xil_printf("Perform %drd Datablock out of 8\n\r",j+1);
    else
      xil_printf("Perform %dth Datablock out of 8\n\r",j+1);

    print("\n\r");
    print("Write input values to FSL Channel\n\r");
    for (i=0;i<8;i++){
      nputfsl(data_to_local_link[k],0);
      xil_printf("%d; ",data_to_local_link[k]);
      k++;
    };
    print("\n\r\n\r");
    print("Read transformed values back from FSL Channel bus\n\r");
    for (i=0;i<8;i++){
      ngetfsl(data_back_local_link[r],1);
      xil_printf("%d; ",data_back_local_link[r]);
      r++;
    };
    print("\n\r\n\r");
    print("-------------------------------------------------------------");
    print("\n\r\n\r");
  };

  // Printing a banner on the Hyper Terminal.
  print("\t#########################################\n\r");
  print("\t#                                       #\n\r");
  print("\t#      FSL Channel Reference Design     #\n\r");
  print("\t#          finished successfully        #\n\r");
  print("\t#                                       #\n\r");
  print("\t#########################################\n\r");
  print("\n\r\n\r");

  return 1;
} 

