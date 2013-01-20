#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <cv.h>
#include <highgui.h>

#define GP_DISPLAY_TIMEOUT_IN_MS 5000
#define GP_BG_COLOR (CV_RGB(0x60, 0x00, 0xe0))

/* Struct definitions */

//  3-d coordinate
typedef struct {
  float x, y, z;
} gpVertex3;

// RGB colour
typedef struct {
  unsigned char r, g, b;
} gpColor;

// 3-d shape
typedef struct {
  gpVertex3 *vertices;
  int num_vertices;
  gpColor color;
} gpPoly;

/* Library functions */
gpPoly * gpCreatePoly(int num_vertices)
{
  assert(num_vertices > 0 && "gpPoly must have at least 1 vertex");

  gpPoly *poly = malloc(sizeof(gpPoly));
  poly->vertices = malloc(num_vertices * sizeof(gpVertex3));
  poly->num_vertices = num_vertices;

  // initialize all vertices to 0
  for (int i = 0; i < num_vertices; i++) {
    poly->vertices[i] = (gpVertex3){0.f, 0.f, 0.f};
  }

  // default colour is white
  poly->color = (gpColor){0xff, 0xff, 0xff};

  return poly;
}

void gpSetPolyVertex(gpPoly *poly, int num, float x, float y, float z)
{
  assert(num >= 0 && num < poly->num_vertices && "invalid vertex number");

  poly->vertices[num] = (gpVertex3){x, y, z};
}

void gpDeletePoly(gpPoly *poly)
{
  assert(poly->num_vertices > 0 && "invalid gpPoly, possibly already deleted");

  free(poly->vertices);
  poly->num_vertices = 0;
  free(poly);
}

void gpScanline(gpPoly *poly, unsigned char *img)
{
}

void gpRender(gpPoly *poly)
{
  printf("Polygon vertices:");
  for (int i = 0; i < poly->num_vertices; i++) {
    printf(" (%f, %f)", poly->vertices[i].x, poly->vertices[i].y);
  }
  printf("\n");

  int xres = 600, yres = 400;
  IplImage *img = cvCreateImage(cvSize(xres, yres), IPL_DEPTH_8U, 3);
  cvSet(img, GP_BG_COLOR, NULL);

  // scanline algorithm
  gpScanline(poly, img->imageData);

  // display image
  cvNamedWindow("GP display", CV_WINDOW_AUTOSIZE);

  cvShowImage("GP display", img);
  cvWaitKey(GP_DISPLAY_TIMEOUT_IN_MS);
}

/* User program */
int main()
{
  // Create a triangle
  gpPoly *tri = gpCreatePoly(3);
  gpSetPolyVertex(tri, 0, -1.f, 0.f, 0.f);
  gpSetPolyVertex(tri, 1, 1.f, 0.f, 0.f);
  gpSetPolyVertex(tri, 2, 0.f, 1.f, 0.f);

  // Render it
  gpRender(tri);

  // Clean up
  gpDeletePoly(tri);

  return 0;
}
