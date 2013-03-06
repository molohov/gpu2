#include "display.h"

#ifdef SW

#include <assert.h>

#include <cv.h>
#include <highgui.h>

gpImg *gpCreateImage(int xres, int yres)
{
  gpImg *img = malloc(sizeof(gpImg));
  img->img = cvCreateImage(cvSize(xres, yres), IPL_DEPTH_8U, 3);
  img->xres = xres;
  img->yres = yres;
  img->zbuffer = (zbuffer_t)malloc(xres * yres * sizeof(img->zbuffer));
  // initialize to maximum
  memset(img->zbuffer, 0xff, xres * yres * sizeof(img->zbuffer));
  return img;
}

void gpSetImage(gpImg *img, unsigned char r, unsigned char g, unsigned char b)
{
  cvSet(img->img, CV_RGB(r, g, b), NULL);
}

inline void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b)
{
  assert(x >= 0 && x < img->xres);
  assert(y >= 0 && y < img->yres);

  unsigned char *ptr = img->img->imageData;
  ptr += (y * img->xres + x)*3;

  // bgr
  ptr[0] = b;
  ptr[1] = g;
  ptr[2] = r;
}

void gpDisplayImage(gpImg *img)
{
  cvNamedWindow("GP display", CV_WINDOW_AUTOSIZE);

  cvShowImage("GP display", img->img);
  cvWaitKey(GP_DISPLAY_TIMEOUT_IN_MS);
}

void gpReleaseImage(gpImg **img)
{
  cvReleaseImage(&(*img)->img);
  free((*img)->zbuffer);
  free(*img);
  *img = NULL;
}

#else

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

#include "xparameters.h"

#define BYTES_PER_PIXEL 4

gpImg *gpCreateImage(int xres, int yres)
{
  volatile unsigned char *ddr_addr1 = (volatile unsigned char *)XPAR_S6DDR_0_S0_AXI_BASEADDR;
  volatile unsigned char *ddr_addr2 = (volatile unsigned char *)(XPAR_S6DDR_0_S0_AXI_BASEADDR + xres * yres * BYTES_PER_PIXEL);

  static bool render_addr1 = false;

  render_addr1 = !render_addr1;

  volatile unsigned char *render_addr = (render_addr1) ? ddr_addr1 : ddr_addr2;

  gpImg *img = malloc(sizeof(gpImg));
  img->xres = xres;
  img->yres = yres;
  img->imageData = render_addr;
  img->zbuffer = (zbuffer_t)(XPAR_S6DDR_0_S0_AXI_BASEADDR + xres * yres * BYTES_PER_PIXEL * 2);
  // initialize to maximum
  memset(img->zbuffer, 0xff, xres * yres * sizeof(img->zbuffer));
  return img;
}

void gpSetImage(gpImg *img, unsigned char r, unsigned char g, unsigned char b)
{
  volatile unsigned char *ptr = img->imageData;
  for (int i = 0; i < img->yres; i++) {
    for (int j = 0; j < img->xres; j++) {
      ptr[3] = r;
      ptr[2] = g;
      ptr[1] = b;
      ptr += BYTES_PER_PIXEL;
    }
  }
}

inline void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b)
{
  volatile unsigned char *ptr = img->imageData;
  ptr += (y * img->xres + x) * BYTES_PER_PIXEL;
  ptr[3] = r;
  ptr[2] = g;
  ptr[1] = b;
}

void gpDisplayImage(gpImg *img)
{
  static bool initialized = false;

  volatile int *hdmi_addr = (volatile int *) XPAR_HDMI_OUT_0_BASEADDR;

  if (!initialized) {
    hdmi_addr[0] = img->xres; // stride length in pixels
    hdmi_addr[1] = (int)img->imageData; // set frame base address
    hdmi_addr[2] = 1; // go
    initialized = true;
  } else {
    if (GP_DISPLAY_TIMEOUT_IN_MS == -1) {
      // wait for user input
      while (!*(volatile int *)(XPAR_RS232_UART_1_BASEADDR))
        ;
    }

    hdmi_addr[1] = (int)img->imageData; // set frame base address
  }
}

void gpReleaseImage(gpImg **img)
{
  free(*img);
  *img = NULL;
}

#endif

void gpSetImageHLine(gpImg *img, int y, int x1, int x2, unsigned char r, unsigned char g, unsigned char b)
{
  if (x1 < 0) x1 = 0;
  if (x1 >= img->xres) x1 = img->xres - 1;
  if (x2 < 0) x2 = 0;
  if (x2 >= img->xres) x2 = img->xres - 1;

#ifdef SW
  assert(y >= 0 && y < img->yres);
#endif

  if (x1 > x2)
  {
      int tmp = x1;
      x1 = x2;
      x2 = tmp;
  }

  for (int i = x1; i <= x2; i++)
  {
      gpSetImagePixel(img, i, y, r, g, b);
  }
}
