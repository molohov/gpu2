#include "mb_interface.h"

#include <stdio.h>

int main()
{
  int i, sum = 0;

  for (i = 0; i < 8; i++) {
    putfsl(i, 0);
  }

  for (i = 0; i < 4; i++) {
    getfsl(sum, 1);
    xil_printf("Result: %d\r\n", sum);
    xil_printf("Expected: %d\r\n", 28);
  }

  xil_printf("Done test\r\n");

  return 0;
}
