#include <stdio.h>
/*
  14.1 - may get warning about an implicit declaration of xil_printf
  because it is missing from stdio.h for some reason
*/

int Counter1 = 20;

int Decrement(int Number)
{
  Number = Number - 1;
  return(Number);
}

int main(void)
{
    int Counter = 30;

    xil_printf("\r\n");
    while (Counter1 > 0)
    {
      Counter1--;
      Counter = Decrement(Counter);
      xil_printf("Counter/Counter1 = %d %d\r\n", Counter,Counter1);
    }
    xil_printf("\r\n");
    return 0;
}

