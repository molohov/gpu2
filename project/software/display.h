#ifndef GP_DISPLAY_TIMEOUT_IN_MS
#define GP_DISPLAY_TIMEOUT_IN_MS -1
#endif

#ifdef SW
#include <cv.h>

typedef struct {
  int xres, yres;
  IplImage *img;
} gpImg;
#else
typedef struct {
  int xres, yres;
  volatile unsigned char *imageData;
} gpImg;
#endif

gpImg *gpCreateImage(int xres, int yres);

void gpSetImage(gpImg *img, unsigned char r, unsigned char g, unsigned char b);

void gpSetImagePixel(gpImg *img, int x, int y, unsigned char r, unsigned char g, unsigned char b);

void gpDisplayImage(gpImg *img);

void gpReleaseImage(gpImg **img);
