#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include <cv.h>
#include <highgui.h>

#define GP_DISPLAY_TIMEOUT_IN_MS -1
#define GP_BG_COLOR (CV_RGB(0x60, 0x00, 0xe0))
#define GP_XRES 512
#define GP_YRES 512

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

// 2-d fixed point for rendering and matrix ops
typedef struct {
  int x, y;
} gpVertex2Fixed;

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
  assert(poly);
  assert(num >= 0 && num < poly->num_vertices && "invalid vertex number");

  poly->vertices[num] = (gpVertex3){x, y, z};
}

void gpSetPolyColor(gpPoly *poly, unsigned char r, unsigned char g, unsigned b)
{
  assert(poly);

  poly->color = (gpColor){r, g, b};
}

void gpDeletePoly(gpPoly *poly)
{
  assert(poly);
  assert(poly->num_vertices > 0 && "invalid gpPoly, possibly already deleted");

  free(poly->vertices);
  poly->num_vertices = 0;
  free(poly);
}

int sign(int x, int y, int ax, int ay, int bx, int by)
{
  return (x - bx) * (ay - by) - (ax - bx) * (y - by);
}

bool inTriangle(int x, int y, gpVertex2Fixed *vertices)
{
  int ax = vertices[0].x;
  int ay = vertices[0].y;
  int bx = vertices[1].x;
  int by = vertices[1].y;
  int cx = vertices[2].x;
  int cy = vertices[2].y;

  bool b1 = sign(x, y, ax, ay, bx, by) < 0;
  bool b2 = sign(x, y, bx, by, cx, cy) < 0;
  bool b3 = sign(x, y, cx, cy, ax, ay) < 0;

  return (b1 == b2) && (b2 == b3);
}

void gpFillTriangle(gpPoly *poly, unsigned char *img)
{
  assert(poly);
  assert(poly->num_vertices == 3);

  // convert floating point to fixed point
  gpVertex2Fixed *vertices = malloc(poly->num_vertices * sizeof(gpVertex2Fixed));

  for (int i = 0; i < poly->num_vertices; i++) {
    vertices[i].x = (int)(poly->vertices[i].x * GP_XRES / 2);
    vertices[i].y = (int)(poly->vertices[i].y * GP_YRES / 2);
  }

  // scanline algorithm
  for (int x = 0; x < GP_XRES; x++) {
    int x_coord = x - GP_XRES/2;
    for (int y = 0; y < GP_YRES; y++) {
      int y_coord = GP_YRES/2 - y; // flip y
      if (inTriangle(x_coord, y_coord, vertices)) {
        img[3*(y*GP_XRES+x)] = poly->color.b;
        img[3*(y*GP_XRES+x)+1] = poly->color.g;
        img[3*(y*GP_XRES+x)+2] = poly->color.r;
      }
    }
  }
}

void gpFillPoly(gpPoly *poly, unsigned char *img)
{
  assert(poly);

  if (poly->num_vertices < 3) return;
  else if (poly->num_vertices == 3) gpFillTriangle(poly, img);
  else {
    // Assume convex polygon with vertices in the right order!
    for (int i = 2; i < poly->num_vertices; i++) {
      gpPoly *tri = gpCreatePoly(3);
      gpSetPolyVertex(tri, 0, poly->vertices[0].x, poly->vertices[0].y, poly->vertices[0].z);
      gpSetPolyVertex(tri, 1, poly->vertices[i-1].x, poly->vertices[i-1].y, poly->vertices[i-1].z);
      gpSetPolyVertex(tri, 2, poly->vertices[i].x, poly->vertices[i].y, poly->vertices[i].z);
      gpSetPolyColor(tri, poly->color.r, poly->color.g, poly->color.b);
      gpFillTriangle(tri, img);
      gpDeletePoly(tri);
    }
  }
}

void gpRender(gpPoly *poly)
{
  assert(poly);

  IplImage *img = cvCreateImage(cvSize(GP_XRES, GP_YRES), IPL_DEPTH_8U, 3);
  cvSet(img, GP_BG_COLOR, NULL);

  // scanline algorithm
  gpFillPoly(poly, img->imageData);

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
  gpSetPolyVertex(tri, 0, 0.f, 1.f, 0.f);
  gpSetPolyVertex(tri, 1, -1.f, 0.f, 0.f);
  gpSetPolyVertex(tri, 2, 1.f, 0.f, 0.f);
  gpSetPolyColor(tri, 0xff, 0xff, 0x0); // yellow

  // Render it
  gpRender(tri);

  // Clean up
  gpDeletePoly(tri);
  tri = NULL;

  // Create a quadrilateral
  gpPoly *quad = gpCreatePoly(4);
  gpSetPolyVertex(quad, 0, 0.f, 1.f, 0.f);
  gpSetPolyVertex(quad, 1, -1.f, 0.f, 0.f);
  gpSetPolyVertex(quad, 2, 0.f, -1.f, 0.f);
  gpSetPolyVertex(quad, 3, 1.f, 0.5f, 0.f);
  gpSetPolyColor(quad, 0x0, 0xff, 0x0); // green

  // Render it
  gpRender(quad);

  // Clean up
  gpDeletePoly(quad);
  quad = NULL;

  // Create a hexagon
  gpPoly *hex = gpCreatePoly(6);
  gpSetPolyVertex(hex, 0, -.5486, 1.f, 0.f);
  gpSetPolyVertex(hex, 1, -1.f, 0.f, 0.f);
  gpSetPolyVertex(hex, 2, -.5486, -1.f, 0.f);
  gpSetPolyVertex(hex, 3, .5486, -1.f, 0.f);
  gpSetPolyVertex(hex, 4, 1.f, 0.f, 0.f);
  gpSetPolyVertex(hex, 5, .5486, 1.f, 0.f);
  gpSetPolyColor(hex, 0xff, 0x0, 0x0); // red

  // Render it
  gpRender(hex);

  // Clean up
  gpDeletePoly(hex);
  hex = NULL;

  return 0;
}
