#include "display.h"

#include <stdbool.h>

extern int GLOBAL_ZBUFFER;

bool time_out = true;

#ifdef SW

#include <assert.h>
#include <string.h>

#include <cv.h>
#include <highgui.h>

#define BYTES_PER_PIXEL 4

gpImg *gpCreateImage(int xres, int yres)
{
  gpImg *img = malloc(sizeof(gpImg));
  img->img = cvCreateImage(cvSize(xres, yres), IPL_DEPTH_8U, BYTES_PER_PIXEL);
  img->xres = xres;
  img->yres = yres;
  img->zbuffer = NULL;

  return img;
}

void gpSetImageBackground(gpImg *img, unsigned char r, unsigned char g, unsigned char b)
{
  cvSet(img->img, CV_RGB(r, g, b), NULL);

  if (GLOBAL_ZBUFFER) {
    img->zbuffer = (zbuffer_t)malloc(img->xres * img->yres * sizeof(img->zbuffer));
    // initialize to maximum
    memset(img->zbuffer, 0xff, img->xres * img->yres * sizeof(img->zbuffer));
  }
}

void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b)
{
  assert(x >= 0 && x < img->xres);
  assert(y >= 0 && y < img->yres);

  unsigned *ptr = (unsigned *)img->img->imageData;
  ptr += (y * img->xres + x);

  // bgr
  *ptr = b | (g << 8) | (r << 16);
}

void gpDisplayImage(gpImg *img)
{
  cvNamedWindow("GP display", CV_WINDOW_AUTOSIZE);

#ifdef DISPLAY_Z_BUFFER
  if (GLOBAL_ZBUFFER) {
    for (int i = 0; i < img->yres; i++) {
      for (int j = 0; j < img->xres; j++) {
        img->img->imageData[(i * img->xres + j) * BYTES_PER_PIXEL] = img->zbuffer[(i * img->xres + j)] >> 23;
        img->img->imageData[(i * img->xres + j) * BYTES_PER_PIXEL + 1] = img->zbuffer[(i * img->xres + j)] >> 23;
        img->img->imageData[(i * img->xres + j) * BYTES_PER_PIXEL + 2] = img->zbuffer[(i * img->xres + j)] >> 23;
      }
    }
  }
#endif

  cvShowImage("GP display", img->img);

  if (time_out) {
    cvWaitKey(GP_DISPLAY_TIMEOUT_IN_MS);
  }
}

void gpReleaseImage(gpImg **img)
{
  cvReleaseImage(&(*img)->img);
  free((*img)->zbuffer);
  free(*img);
  *img = NULL;
}

void gpSetImageHLine(gpImg *img, int y, int x1, int x2, unsigned char r, unsigned char g, unsigned char b)
{
  assert(x1 >= 0 && x1 < img->xres);
  assert(x2 >= 0 && x2 < img->xres);
  assert(y >= 0 && y < img->yres);

  if (x1 > x2)
  {
      int tmp = x1;
      x1 = x2;
      x2 = tmp;
  }

  unsigned *ptr = (unsigned *)img->img->imageData;
  ptr += (y * img->xres + x1);

  for (int i = x1; i <= x2; i++)
  {
    *ptr++ = b | (g << 8) | (r << 16);
  }
}

int gpWaitKey()
{
  int c = cvWaitKey(GP_DISPLAY_TIMEOUT_IN_MS);
  return (c == -1) ? 0 : c & 0xff;
}

#else

#include <stdlib.h>

#include "xparameters.h"
#include "xuartlite_l.h"

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

  img->zbuffer = (zbuffer_t)(render_addr + xres * yres * BYTES_PER_PIXEL * 2);

  return img;
}

void gpPollImageWriteReady()
{
  volatile int * burst_write_addr = (volatile int *)XPAR_BURST_WRITE_0_BASEADDR;

  // poll done bit
  while (!(burst_write_addr[64] & 0x100)) {
  }

  // clear done bit
  burst_write_addr[64] &= ~0x100;
}

void gpSetImageBackground(gpImg *img, unsigned char r, unsigned char g, unsigned char b)
{
  static bool initialized = false;

  volatile int * burst_write_addr = (volatile int *)XPAR_BURST_WRITE_0_BASEADDR;

  if (!initialized) {
    burst_write_addr[64] = (1 << 1) | (1 << 3); // burst write
    burst_write_addr[66] = 0xffff; // byte enable
    initialized = true;
  }

  if (GLOBAL_ZBUFFER) {
    // initialize to maximum
    burst_write_addr[0] = 0xffffffff;

    for (int i = 0; i < img->yres; i++) {
      burst_write_addr[65] = (int)img->zbuffer + i * sizeof(*img->zbuffer) * img->xres;
      burst_write_addr[67] = 0x0a000000 | (sizeof(*img->zbuffer) * img->xres); // go and transfer length
      gpPollImageWriteReady();
    }
  }

  burst_write_addr[0] = (r << 24) | (g << 16) | (b << 8);

  for (int i = 0; i < img->yres; i++) {
    burst_write_addr[65] = (int)img->imageData + i * BYTES_PER_PIXEL * img->xres;
    burst_write_addr[67] = 0x0a000000 | (BYTES_PER_PIXEL * img->xres); // go and transfer length
    gpPollImageWriteReady();
  }
}

void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b)
{
  volatile unsigned *ptr = (volatile unsigned *)img->imageData;
  ptr += (y * img->xres + x);
  *ptr = (r << 24) | (g << 16) | (b << 8);
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
    if (GP_DISPLAY_TIMEOUT_IN_MS == -1 && time_out) {
      // wait for user input
      XUartLite_RecvByte(XPAR_RS232_UART_1_BASEADDR);
    }

    hdmi_addr[1] = (int)img->imageData; // set frame base address
  }
}

void gpReleaseImage(gpImg **img)
{
  free(*img);
  *img = NULL;
}

void gpSetImageHLine(gpImg *img, int y, int x1, int x2, unsigned char r, unsigned char g, unsigned char b)
{
  if (x1 > x2)
  {
      int tmp = x1;
      x1 = x2;
      x2 = tmp;
  }

  volatile unsigned *ptr = (volatile unsigned *)img->imageData;
  ptr += (y * img->xres + x1);

  for (int i = x1; i <= x2; i++)
  {
    *ptr++ = (r << 24) | (g << 16) | (b << 8);
  }
}

int gpWaitKey()
{
  if (!XUartLite_IsReceiveEmpty(XPAR_RS232_UART_1_BASEADDR)) {
    return XUartLite_ReadReg(XPAR_RS232_UART_1_BASEADDR, XUL_RX_FIFO_OFFSET);
  }
  return 0;
}
#endif
 
void gpSetImageHLineZBuff(gpImg *img, int y, int x1, int x2, unsigned int z1, unsigned int z2, int x_slope, unsigned char r, unsigned char g, unsigned char b)
{
#ifdef SW
  assert(x1 >= 0 && x1 < img->xres);
  assert(x2 >= 0 && x2 < img->xres);
  assert(y >= 0 && y < img->yres);
#endif

  unsigned z;

  if (x1 > x2) {
      int tmp = x1;
      x1 = x2;
      x2 = tmp;
      tmp = z1;
      z = z2;
  } else {
      z = z1;
  }

#ifdef SW
  unsigned *ptr = (unsigned *)img->img->imageData;
#else
  volatile unsigned *ptr = (volatile unsigned *)img->imageData;
#endif
  ptr += (y * img->xres + x1);

  for (;; x1++) {
      if (img->zbuffer[y*img->xres + x1] > z) {
          img->zbuffer[y*img->xres + x1] = z;
#ifdef SW
          *ptr++ = b | (g << 8) | (r << 16);
#else
          *ptr++ = (r << 24) | (g << 16) | (b << 8);
#endif
      } else {
          ptr++;
      }
      if (x1 == x2) break;
      z += x_slope;
  }
}

void gpSetTimeout(bool val)
{
  time_out = val;
}
