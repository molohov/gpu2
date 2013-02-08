#include "display.h"

#ifdef SW

#include <cv.h>
#include <highgui.h>

gpImg *gpCreateImage(int xres, int yres)
{
  gpImg *img = malloc(sizeof(gpImg));
  img->img = cvCreateImage(cvSize(xres, yres), IPL_DEPTH_8U, 3);
  img->xres = xres;
  img->yres = yres;
  return img;
}

void gpSetImage(gpImg *img, unsigned char r, unsigned char g, unsigned char b)
{
  cvSet(img->img, CV_RGB(r, g, b), NULL);
}

void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b)
{
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
  free(*img);
  *img = NULL;
}

#else

#include <stdlib.h>

#define BYTES_PER_PIXEL 4

gpImg *gpCreateImage(int xres, int yres)
{
  gpImg *img = malloc(sizeof(gpImg));
  img->xres = xres;
  img->yres = yres;
  img->imageData = malloc(sizeof(char) * xres * yres * BYTES_PER_PIXEL);
  return img;
}

void gpSetImage(gpImg *img, unsigned char r, unsigned char g, unsigned char b)
{
  unsigned char *ptr = img->imageData;
  for (int i = 0; i < img->xres; i++) {
    for (int j = 0; j < img->yres; j++) {
      ptr[0] = r;
      ptr[1] = g;
      ptr[2] = b;
      ptr += BYTES_PER_PIXEL;
    }
  }
}

void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b)
{
  unsigned char *ptr = img->imageData;
  ptr += (y * img->xres + x)*BYTES_PER_PIXEL;
  ptr[0] = r;
  ptr[1] = g;
  ptr[2] = b;
}

void gpDisplayImage(gpImg *img)
{
  // TODO: implement
}

void gpReleaseImage(gpImg **img)
{
  free((*img)->imageData);
  free(*img);
  *img = NULL;
}

#endif
