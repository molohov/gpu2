#ifndef _GP_H
#define _GP_H

#include <math.h>

#include "display.h"

#define GP_XRES 1280
#define GP_YRES 720
#define GP_INFER_COORD NAN

/* Struct definitions */

// 2-d fixed point for rendering
typedef struct {
  int x, y;
} gpVertex2Fixed;

// typedef for z-buff unsigned shorts
typedef unsigned short zbuff;

// 3-d fixed point for rendering with zbuffer
typedef struct {
  int x, y;
  zbuff z;
} gpVertex3Fixed;

//  3-d coordinate
typedef struct {
  float x, y, z;
} gpVertex3;

// homogeneous 3-d coordinate
typedef struct {
  float x, y, z, w;
} gpVertex4;

// RGB colour
typedef struct {
  unsigned char r, g, b;
} gpColor;

// 4x4 matrix for transformation calculations
typedef struct {
  float m[4][4];
} gpTMatrix;

// 3-d shape
typedef struct {
  gpVertex3 *vertices;
  gpVertex4 *t_vertices;
  int num_vertices;
  gpColor color;
  gpVertex3 normal;
  float avg_z;
  gpTMatrix trans;
} gpPoly;

// list of 3-d shapes
typedef struct {
  int num_polys;
  int capacity;
  gpPoly **polys;
  gpTMatrix trans;
} gpPolyList;

/* Library functions */
enum { GP_PERSPECTIVE, GP_ZBUFFER };

gpPolyList * gpCreatePolyList();
void gpAddPolyToList(gpPolyList *list, gpPoly *poly);
void gpDeletePolyList(gpPolyList *list);

gpPoly * gpCreatePoly(int num_vertices);
void gpSetPolyVertex(gpPoly *poly, int num, float x, float y, float z);
void gpSetPolyColor(gpPoly *poly, unsigned char r, unsigned char g, unsigned b);
void gpDeletePoly(gpPoly *poly);

void gpTranslatePoly(gpPoly *poly, float x, float y, float z);
void gpTranslatePolyList(gpPolyList *list, float x, float y, float z);
void gpScalePoly(gpPoly *poly, float x, float y, float z);
void gpScalePolyList(gpPolyList *list, float x, float y, float z);
void gpRotatePoly(gpPoly *poly, float x, float y, float z);
void gpRotatePolyList(gpPolyList *list, float x, float y, float z);
void gpPerspectivePoly(gpPoly *poly, float near, float far);
void gpPerspectivePolyList(gpPolyList *list, float near, float far);
void gpTranslatePolyListOrigin(gpPolyList *list);

void gpClearTMatrixPoly(gpPoly *poly);
void gpClearTMatrixPolyList(gpPolyList *list);

void gpRenderPoly(gpPoly *poly);
void gpRender(gpPolyList *list);

void gpEnable(int gpFunction);
void gpDisable(int gpFunction);
void gpSetBackgroundColor(unsigned char r, unsigned char g, unsigned char b);

void gpSetFrustrum(float near, float far);
void gpLine(gpVertex2Fixed *v1, gpVertex2Fixed *v2, gpColor *color);

void gpFillConvexPoly(gpImg *img, gpVertex2Fixed * vertices, int num_vertices, gpColor *color);
void gpRenderConvexPoly(gpVertex2Fixed * vertices, int num_vertices, gpColor *color);
void gpFillConvexPolyZBuff(gpImg *img, gpVertex3Fixed * vertices, int num_vertices, gpColor *color);
#endif
