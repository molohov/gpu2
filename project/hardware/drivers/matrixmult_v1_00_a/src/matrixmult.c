/*****************************************************************************
* Filename:          C:\cygwin\home\Blair\gpu2\project\hardware\drivers/matrixmult_v1_00_a/src/matrixmult.c
* Version:           1.00.a
* Description:       matrixmult (new FSL core) Driver Source File
* Date:              Tue Mar 19 11:58:35 2013 (by Create and Import Peripheral Wizard)
*****************************************************************************/

#include "matrixmult.h"
/*
* Write your driver implementation in this file.
*/

/*
#include "xparameters.h"
#include "mb_interface.h"
#include "xbasic_types.h"
*/

int main(void) 
{
  int i,j,k,r;

  int data_to_local_link[] = {
        0x4124CCCD, //10.3
        0xBF07AE14, //-0.53     --- pixel0
	0x40C80000, //6.25
        0x4141999A, //12.1      --- pixel1
	0x40A9999A, //5.3000002
        0xC1691EB8, //-14.57    --- pixel2
	0x3C4CCCCD, //0.0125
        0x4040A3D7 //3.01       --- pixel3

	0x40600000, //3.5
        0xBF07AE14, //-0.53     --- pixel0
	0x40980000, //4.75
        0x4141999A, //12.1      --- pixel1
	0x4111999A, //9.1
        0xC1691EB8, //-14.57    --- pixel2
	0x43164CCD, //150.3
        0x4040A3D7 //3.01       --- pixel3

	0xBF07AE14, //-0.53
        0xBF07AE14, //-0.53     --- pixel0
	0x4141999A, //12.1
        0x4141999A, //12.1      --- pixel1
	0xC1691EB8, //-14.57
        0xC1691EB8, //-14.57    --- pixel2
        0x4040A3D7, //3.01
        0x4040A3D7 //3.01       --- pixel3

        0x3C4CCCCD, //0.0125
        0xBF07AE14, //-0.53     --- pixel0
        0x40A9999A, //5.3000002
        0x4141999A, //12.1      --- pixel1
        0x40C80000, //6.25
        0xC1691EB8, //-14.57    --- pixel2
        0x4124CCCD, //10.3
        0x4040A3D7 //3.01       --- pixel3

      }; 

  int data_back_local_link[32];

  // Printing a banner on the Hyper Terminal.
  print("\t#########################################\n\r");
  print("\t#                                       #\n\r");
  print("\t#      FSL Interface to Matrixmult      #\n\r");
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
    for (i=0;i<32;i++){
      nputfsl(data_to_local_link[k],0);
      xil_printf("%d; ",data_to_local_link[k]);
      k++;
    };
    print("\n\r\n\r");
    print("Read transformed values back from FSL Channel bus\n\r");
    for (i=0;i<4;i++){
      ngetfsl(data_back_local_link[r],0);
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
  print("\t#      FSL Interface to Matrixmult      #\n\r");
  print("\t#          finished successfully        #\n\r");
  print("\t#                                       #\n\r");
  print("\t#########################################\n\r");
  print("\n\r\n\r");

  return 1;
} 

