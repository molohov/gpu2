/******************************************************************************
 *
 * FILENAME:
 *
 * lab3.c
 *
 * DESCRIPTION:
 *
 * This file contains lab 3, which builds upon lab 2. It illustrates
 * the following concepts:
 *
 * 1. Using the UART Lite with printf for diagnostics
 * 2. Using the GPIO to turn on and off an LED on the board
 * 3. Using the interrupt controller to handle the timer counter interrupt
 * 4. Using the timer counter interrupt to generate a periodic interrupt for a
 *    timeslice
 *
 * This application was designed to be used with the Xilinx Multimedia
 * board and has been updated for newer systems. It expects MicroBlaze
 * to be the processor that is contained in the hardware design.
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
 ******************************************************************************/

/***************************** Include Files *********************************/

#include <stdio.h>
#include "xparameters.h"    /* generated system parameters                  */
#include "xbasic_types.h"   /* Xilinx basic types for device drivers        */
#include "xgpio.h"          /* layer 1 GPIO device driver                   */
#include "xtmrctr.h"     /* layer 1 timer counter device driver          */
#include "xintc.h" /* layer 1 interrupt controller device driver */

/************************** Constant Definitions *****************************/

#define LED    0x1          /* bit 0 of GPIO is connected to the LED */
#define printf xil_printf   /* a smaller footprint printf */

/* The following constants are used to determine the amount of time for a time
 * slice based upon the clock frequency which the PLB is running at. The time
 * slice is generater by a timer counter which is on the PLB.
 */
#define CLOCK_MHZ       27000000 
#define CLOCKS_PER_MS   (CLOCK_MHZ / 1000)
#define TIME_SLICE_MS   1000

/* The following constant is used to set the reset value of the timer counter,
 * making this number larger reduces the amount of time this example consumes
 * because it is the value the timer counter is loaded with when it is started
 * and an interrupt is generated when it rolls over
 */
#define RESET_VALUE     (0xFFFFFFFF - (TIME_SLICE_MS * CLOCKS_PER_MS))

/* the following constant determines which timer counter of the device that is
 * used for this example, there are currently 2 timer counters in a device
 * and this example uses the first one, 0, the timer numbers are 0 based
 */
#define TIMER_COUNTER_0     0

/**************************** Type Definitions *******************************/

/***************** Macros (Inline Functions) Definitions *********************/

/************************** Function Prototypes ******************************/

void TimerCounterHandler(void *CallBackRef, Xuint8 TimerCounterNumber);

/************************** Variable Definitions *****************************/

/* The following data is declared globally such that it is easily accessible
 * from anywhere within the program. Note that it is important that these 
 * variables be zeroed no matter where they are declared because the functions
 * that perform initialization for device drivers will indicate errors if they
 * are not initialized.
 */
XGpio Gpio;
XIntc InterruptController;
XTmrCtr TimerCounter;

/* The following data is shared between interrupt and non-interrupt driven 
 * code.
 */
int TimerExpiredCount;

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
int main() {
	XStatus Status;
	int PreviousCount = 0;

	/* Using printf with the UART Lite assumes that the layer 0 device
	 * driver was selected for the UART Lite in the XPS and the standard
	 * I/O peripheral in XPS was set to the UART Lite
	 */printf("\n\rStarting the Application\n\r");

	/*************************** GPIO Setup *******************************/

	/* The second GPIO example uses the higher level (layer 1) driver to
	 * blink the LEDs, First initialize the GPIO component
	 */
	Status = XGpio_Initialize(&Gpio, XPAR_AXI_GPIO_0_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		printf("GPIO initialization error\n\r\r");
	}
	/* Set the direction for all signals to be inputs except the LED
	 * outputs
	 */
	XGpio_SetDataDirection(&Gpio, 1, ~LED);

	/************************* Timer Setup ********************************/

	/* Initialize the timer counter so that it's ready to use,
	 * specify the device ID that is generated in xparameters.h
	 */
	Status = XTmrCtr_Initialize(&TimerCounter,
			XPAR_AXI_TIMER_0_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		printf("Timer counter initialization error\n\r\r");
	}

	/* Perform a self-test to ensure that the hardware was built
	 * correctly, use the 1st timer in the device (0)
	 */
	Status = XTmrCtr_SelfTest(&TimerCounter,
			TIMER_COUNTER_0);
	if (Status != XST_SUCCESS) {
		printf("Timer counter self-test error\n\r");
	}

	/* Setup the handler for the timer counter that will be called from the
	 * interrupt context when the timer expires, specify a pointer to the
	 * timer counter driver instance as the callback reference so the handler
	 * is able to access the instance data
	 */
	XTmrCtr_SetHandler(&TimerCounter,
			TimerCounterHandler, &TimerCounter);

	/* Enable the interrupt of the timer counter so interrupts will occur
	 * and use auto reload mode such that the timer counter will reload
	 * itself automatically and continue repeatedly, without this option
	 * it would expire once only
	 */
	XTmrCtr_SetOptions(&TimerCounter, TIMER_COUNTER_0,
			XTC_INT_MODE_OPTION | XTC_AUTO_RELOAD_OPTION);

	/* Set a reset value for the timer counter such that it will expire
	 * earlier than letting it roll over from 0, the reset value is loaded
	 * into the timer counter when it is started
	 */
	XTmrCtr_SetResetValue(&TimerCounter,
			TIMER_COUNTER_0, RESET_VALUE);

	/* Start the timer counter such that it's incrementing
	 */
	XTmrCtr_Start(&TimerCounter, TIMER_COUNTER_0);

	/********************** Interrupt Controller Setup *********************/
	/*
	 * Initialize the interrupt controller driver so that it's ready to use,
	 * using the device ID that is generated in xparameters.h
	 */
	Status = XIntc_Initialize(&InterruptController, XPAR_AXI_INTC_0_DEVICE_ID);
	if (Status != XST_SUCCESS) {
		printf("Interrupt controller initialization error\n\r");
	}

	/*
	 * Connect the device driver handler that will be called when an interrupt
	 * for the device occurs, the device driver handler performs the specific
	 * interrupt processing for the device
	 */
	Status = XIntc_Connect(&InterruptController,
			XPAR_AXI_INTC_0_AXI_TIMER_0_INTERRUPT_INTR,
			(XInterruptHandler)XTmrCtr_InterruptHandler,
			&TimerCounter);
	if (Status != XST_SUCCESS) {
		printf("Interrupt controller connect error\n\r");
	}

	/*
	 * Start the interrupt controller so interrupts are enabled for all
	 * devices that cause interrupts. Specify real mode so that the timer
	 * counter can cause interrupts through the interrupt controller.
	 */
	Status = XIntc_Start(&InterruptController, XIN_REAL_MODE);
	if (Status != XST_SUCCESS) {
		printf("Interrupt controller start error\n\r");
	}

	/* Enable the interrupt for the timer counter and enable interrupts in
	 * the microblaze processor
	 */
	XIntc_Enable(&InterruptController,
			XPAR_AXI_INTC_0_AXI_TIMER_0_INTERRUPT_INTR);

	microblaze_enable_interrupts();

	/********************** Application Processing *********************/

	/* Insert foreground processing here, interrupts will handle
	 * processing in the background
	 */
	while (1) {
		/* If the timer has expired one more time, then print to indicate
		 * the new expired count
		 */
		if (TimerExpiredCount != PreviousCount) {
			PreviousCount = TimerExpiredCount;
			printf("Timer Expired Count = %d\r", TimerExpiredCount);
		}
	}

	/* The application should not ever execute the following code, but it is
	 * present to indicate if the application does exit because of an error
	 */printf("Exiting the Application\n\r");
}

/****************************************************************************
 *
 * FUNCTION:
 *
 * TimerCounterHandler
 *
 * DESCRIPTION:
 *
 * This function is the handler which performs processing for the timer counter.
 * It is called from an interrupt context such that the amount of processing
 * performed should be minimized.  It is called when the timer counter expires
 * if interrupts are enabled.
 *
 * This handler provides an example of how to handle timer counter interrupts
 * but is application specific.
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
void TimerCounterHandler(void *CallBackRef, Xuint8 TimerCounterNumber) {
	Xuint32 Leds;

	TimerExpiredCount++;

	/* Toggle the LEDs so that they are flashing at the rate specified
	 * by the time slice
	 */
	Leds = XGpio_DiscreteRead(&Gpio, 1) & LED;
	if (Leds) {
		XGpio_DiscreteWrite(&Gpio, 1, ~LED);
	} else {
		XGpio_DiscreteWrite(&Gpio, 1, LED);
	}
}

