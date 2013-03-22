#include "mb_interface.h"

#include <stdio.h>

int main()
{
  int i, j, sum = 0;

  int data_to_local_link[] = {
  0x4124CCCD, //10.3
  0xBF07AE14, //-0.53   --- pixel0
  0x40C80000, //6.25
  0x4141999A, //12.1    --- pixel1
  0x40A9999A, //5.3000002
  0xC1691EB8, //-14.57  --- pixel2
  0x3C4CCCCD, //0.0125
  0x4040A3D7, //3.01     --- pixel3

  0x40600000, //3.5
  0xBF07AE14, //-0.53   --- pixel0
  0x40980000, //4.75
  0x4141999A, //12.1    --- pixel1
  0x4111999A, //9.1
  0xC1691EB8, //-14.57  --- pixel2
  0x43164CCD, //150.3
  0x4040A3D7, //3.01     --- pixel3

  0xBF07AE14, //-0.53
  0xBF07AE14, //-0.53   --- pixel0
  0x4141999A, //12.1
  0x4141999A, //12.1    --- pixel1
  0xC1691EB8, //-14.57
  0xC1691EB8, //-14.57  --- pixel2
  0x4040A3D7, //3.01
  0x4040A3D7, //3.01     --- pixel3

  0x3C4CCCCD, //0.0125
  0xBF07AE14, //-0.53   --- pixel0
  0x40A9999A, //5.3000002
  0x4141999A, //12.1    --- pixel1
  0x40C80000, //6.25
  0xC1691EB8, //-14.57  --- pixel2
  0x4124CCCD, //10.3
  0x4040A3D7 //3.01     --- pixel3
  }; 

  int expected_results[] = {
  0xC0E08E56, //-7.017375
  0x43BBB7CF, //375.436
  0x43B80498, //368.0359
  0x4082161E //4.0652
  };

  for (j = 0; j < 4; j++) {
      for (i = 0; i < 8; i++) {
        putfsl(data_to_local_link[j*8 + i], 0);
      }

      getfsl(sum, 1);
      xil_printf("Result: %d\r\n", sum);
      xil_printf("Expected: %d\r\n", expected_results[j]);
  }

  xil_printf("Done test\r\n");

  return 0;
}
