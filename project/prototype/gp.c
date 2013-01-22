#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <assert.h>

#include <cv.h>
#include <highgui.h>

#include "gp.h"

#define POLY_LIST_CHUNK_SIZE 16

/* Struct definitions */

// 2-d fixed point for rendering and matrix ops
typedef struct {
  int x, y;
} gpVertex2Fixed;

/* Library functions */

gpPolyList * gpCreatePolyList()
{
  gpPolyList *list = malloc(sizeof(gpPolyList));

  list->capacity = POLY_LIST_CHUNK_SIZE;
  list->polys = malloc(list->capacity * sizeof(gpPoly *));
  list->num_polys = 0;

  return list;
}

void gpAddPolyToList(gpPolyList *list, gpPoly *poly)
{
  if (list->num_polys == list->capacity) {
    list->capacity += POLY_LIST_CHUNK_SIZE;
    list->polys = realloc(list->polys, list->capacity * sizeof(gpPoly *));
  }

  list->polys[list->num_polys] = poly;
  list->num_polys++;
}

void gpDeletePolyList(gpPolyList *list)
{
  for (int i = 0; i < list->num_polys; i++) {
    gpDeletePoly(list->polys[i]);
  }

  free(list->polys);
  free(list);
}

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

#ifndef MAX
#define MAX(a,b) (a<b?b:a)
#endif
#ifndef MIN
#define MIN(a,b) (a<b?a:b)
#endif

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

  int x_start = MAX(0, GP_XRES/2+1+MIN(vertices[0].x, MIN(vertices[1].x, vertices[2].x)));
  int x_end   = MIN(GP_XRES, GP_XRES/2+1+MAX(vertices[0].x, MAX(vertices[1].x, vertices[2].x)));

  int y_start = MIN(GP_YRES, GP_YRES/2+1-MAX(vertices[0].y, MAX(vertices[1].y, vertices[2].y)));
  int y_end   = MAX(0, GP_YRES/2+1-MIN(vertices[0].y, MIN(vertices[1].y, vertices[2].y)));

  // scanline algorithm
  for (int x = x_start; x < x_end; x++) {
    int x_coord = x - GP_XRES/2;
    for (int y = y_start; y < y_end; y++) {
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

void gpRenderPoly(gpPoly *poly)
{
  assert(poly);

  IplImage *img = cvCreateImage(cvSize(GP_XRES, GP_YRES), IPL_DEPTH_8U, 3);
  cvSet(img, GP_BG_COLOR, NULL);

  // fill polygon algorithm
  gpFillPoly(poly, img->imageData);

  // display image
  cvNamedWindow("GP display", CV_WINDOW_AUTOSIZE);

  cvShowImage("GP display", img);
  cvWaitKey(GP_DISPLAY_TIMEOUT_IN_MS);
}

void gpRender(gpPolyList *list)
{
  assert(list);

  IplImage *img = cvCreateImage(cvSize(GP_XRES, GP_YRES), IPL_DEPTH_8U, 3);
  cvSet(img, GP_BG_COLOR, NULL);

  // fill polygon algorithm for each polygon
  for (int i = 0; i < list->num_polys; i++) {
    gpFillPoly(list->polys[i], img->imageData);
  }

  // display image
  cvNamedWindow("GP display", CV_WINDOW_AUTOSIZE);

  cvShowImage("GP display", img);
  cvWaitKey(GP_DISPLAY_TIMEOUT_IN_MS);
}
