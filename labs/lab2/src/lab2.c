/******************************************************************************
*
* FILENAME:
*
* lab2.c
*
* DESCRIPTION:
*
* This file contains lab2 and it illustrates the following concepts: 
*
* 1. Using the UART Lite with printf for diagnostics
* 2. Using the GPIO to turn on and off an LED on the board with both layer
*    0 and 1 device drivers
*
* This application was designed to be used with the Xilinx Multimedia
* board and has since been updated as required for newer generations
* of drivers.  It expects the MicroBlaze to be the processor that is
* contained in the hardware design.
*
* This code will not compile as is. The user is expected to make changes at
* each location marked by <TO BE DONE..>.  Constants that should be used in
* some locations can be found in the file xparameters.h.
*
* NOTES:
*
* This exercise requires the UART Lite to have level 0 driver such that
* XPS connects it to standard I/O automatically. 
*
* NOTES:
*
******************************************************************************/

/***************************** Include Files *********************************/

#include <stdio.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "<TO BE DONE>"     /* layer 0/1 GPIO device driver                 */

/************************** Constant Definitions *****************************/

#define LED    0x1          /* bit 0 of GPIO is connected to the LED */
#define printf xil_printf   /* a smaller footprint printf */
#define DELAY_COUNT 1000000

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

/************************** Variable Definitions *****************************/

XGpio Gpio;

/****************************************************************************
*
* FUNCTION:
*
* main
*
* DESCRIPTION:
*
* This is the entry point for the example.  The embedded system automatically
* calls main.
*
* ARGUMENTS:
*
* None.
*
* RETURN VALUE:
*
* None. 
*
* NOTES:
*
* None.
*
****************************************************************************/
int main()
{
    XStatus Status;
    int Delay,Delay2;

    /* Using printf with the UART Lite assumes that the layer 0 device
     * driver was selected for the UART Lite in the XPS and the standard
     * I/O peripheral in XPS was set to the UART Lite
     */
    printf("Starting the Application\n\r");

    /******************* Layer 0 GPIO Example **********************/
    
    /* The first GPIO example uses the low level (layer 0) driver to
     * blink the LEDs, set the direction for all signals to be inputs 
     * except the LED outputs 
     */

    /* Set data direction */

    XGpio_WriteReg(<TO BE DONE, GPIO BASE ADDRESS>,
		   <TO BE DONE, GPIO REGISTER OFFSET>, ~LED);

    /* Turn the LEDs on, delay for some time so that they can be 
     * seen, and then turn them off
     */

    printf("Make sure LED is off first\n\r");
    XGpio_WriteReg(<TO BE DONE, GPIO BASE ADDRESS>,
		   <TO BE DONE, GPIO REGISTER OFFSET>, ~LED);

    for (Delay2 = 0; Delay2 < 5; Delay2++)
      for (Delay = 0; Delay < DELAY_COUNT; Delay++);

    printf("Now turning on LED\n\r");
    XGpio_WriteReg(<TO BE DONE, GPIO BASE ADDRESS>,
		   <TO BE DONE, GPIO REGISTER OFFSET>, LED);

    for (Delay2 = 0; Delay2 < 10; Delay2++)
      for (Delay = 0; Delay < DELAY_COUNT; Delay++);

    printf("Turning off LED\n\r");
    XGpio_WriteReg(<TO BE DONE, GPIO BASE ADDRESS>,
		   <TO BE DONE, GPIO REGISTER OFFSET>, ~LED);

    for (Delay2 = 0; Delay2 < 10; Delay2++)
      for (Delay = 0; Delay < DELAY_COUNT; Delay++);

    printf("Starting Layer 1 example\n\r");
     
    /******************* Layer 1 GPIO Example **********************/
    
    /* The second GPIO example uses the higher level (layer 1) driver to
     * blink the LEDs, First initialize the GPIO component
     */
    Status = XGpio_Initialize(<TO BE DONE, GPIO INSTANCE POINTER>, 
                              <TO BE DONE, GPIO DEVICE ID>);
    if (Status != XST_SUCCESS)
    {
        printf("GPIO initialization error\n");
    }
    /* Set the direction for all signals to be inputs except the LED 
     * outputs 
     */
    XGpio_SetDataDirection(<TO BE DONE, GPIO INSTANCE POINTER>, 1, ~LED);

    while (1)
    {
        /* Turn the LEDs on, delay for some time so that they can be 
         * seen, and then turn them off
         */
        XGpio_DiscreteWrite(<TO BE DONE, GPIO INSTANCE POINTER>, 1, LED);
        for (Delay = 0; Delay < DELAY_COUNT; Delay++);  

        XGpio_DiscreteWrite(<TO BE DONE, GPIO INSTANCE POINTER>, 1, ~LED);
        for (Delay = 0; Delay < DELAY_COUNT; Delay++);  
    }

    printf("Exiting the Application\n");
}

