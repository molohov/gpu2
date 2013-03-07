#ifndef _DISPLAY_H
#define _DISPLAY_H

#ifndef GP_DISPLAY_TIMEOUT_IN_MS
#define GP_DISPLAY_TIMEOUT_IN_MS -1
#endif

#ifdef SW
#include <cv.h>

typedef unsigned int * zbuffer_t;

typedef struct {
  int xres, yres;
  IplImage *img;
  zbuffer_t zbuffer;
} gpImg;
#else
typedef volatile unsigned int * zbuffer_t;

typedef struct {
  int xres, yres;
  volatile unsigned char *imageData;
  zbuffer_t zbuffer;
} gpImg;
#endif

gpImg *gpCreateImage(int xres, int yres);

void gpSetImage(gpImg *img, unsigned char r, unsigned char g, unsigned char b);

void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b);

void gpSetImageHLine(gpImg *img, int y, int x1, int x2, unsigned char r, unsigned char g, unsigned char b);

void gpSetImageHLineZBuff(gpImg *img, int y, int x1, int x2, unsigned int z1, unsigned int z2, unsigned char r, unsigned char g, unsigned char b);

void gpDisplayImage(gpImg *img);

void gpReleaseImage(gpImg **img);

#endif
