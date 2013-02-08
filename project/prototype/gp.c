#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#include "gp.h"
#include "display.h"

#define POLY_LIST_CHUNK_SIZE 16

/* Struct definitions */

// 2-d fixed point for rendering
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
  list->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity

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
  poly->t_vertices = malloc(num_vertices * sizeof(gpVertex3));
  poly->num_vertices = num_vertices;

  // initialize all vertices to 0
  for (int i = 0; i < num_vertices; i++) {
    poly->vertices[i] = (gpVertex3){0.f, 0.f, 0.f};
  }

  // default colour is white
  poly->color = (gpColor){0xff, 0xff, 0xff};

  poly->avg_z = 0.f;
  poly->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity

  return poly;
}

gpVertex3 gpVertex3CrossProduct(gpVertex3 a, gpVertex3 b)
{
  return (gpVertex3){a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x};
}

void gpSetPolyVertex(gpPoly *poly, int num, float x, float y, float z)
{
  assert(poly);
  assert(num >= 0 && num < poly->num_vertices && "invalid vertex number");

  // ensure new vertex is on the right plane, ie n dot (r - r0) = 0
  if (num > 2) {
    assert((isnan(x) || isnan(y) || isnan(z)) && "polygon vertices over 2 should allow one coordinate to be GP_INFER_COORD (NaN)");
    if (isnan(z)) {
      z = poly->vertices[0].z + (-poly->normal.x * (x - poly->vertices[0].x) - poly->normal.y * (y - poly->vertices[0].y))/poly->normal.z;
    } else if (isnan(y)) {
      y = poly->vertices[0].y + (-poly->normal.x * (x - poly->vertices[0].x) - poly->normal.z * (z - poly->vertices[0].z))/poly->normal.y;
    } else {
      x = poly->vertices[0].x + (-poly->normal.y * (y - poly->vertices[0].y) - poly->normal.z * (z - poly->vertices[0].z))/poly->normal.x;
    }
    assert(!isnan(x) && !isnan(y) && !isnan(z));
  }

  poly->vertices[num] = (gpVertex3){x, y, z};

  // compute normal via cross product for the 3rd point
  if (num == 2) {
    gpVertex3 a = (gpVertex3){poly->vertices[0].x - x, poly->vertices[0].y - y, poly->vertices[0].z - z};
    gpVertex3 b = (gpVertex3){poly->vertices[1].x - x, poly->vertices[1].y - y, poly->vertices[1].z - z};
    poly->normal = gpVertex3CrossProduct(a, b);
  }
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
  free(poly->t_vertices);
  poly->num_vertices = 0;
  free(poly);
}

int cross_product(int x, int y, int ax, int ay, int bx, int by)
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

  int cp1 = cross_product(x, y, ax, ay, bx, by);
  int cp2 = cross_product(x, y, bx, by, cx, cy);
  int cp3 = cross_product(x, y, cx, cy, ax, ay);

  return (cp1 <= 0 && cp2 <= 0 && cp3 <= 0) || (cp1 >= 0 && cp2 >= 0 && cp3 >= 0);
}

#ifndef MAX
#define MAX(a,b) (a > b ? a : b)
#endif

#ifndef MIN
#define MIN(a,b) (a < b ? a : b)
#endif

void gpFillTriangle(gpPoly *poly, gpImg *img)
{
  assert(poly);
  assert(poly->num_vertices == 3);

  // convert floating point to fixed point
  gpVertex2Fixed *vertices = malloc(poly->num_vertices * sizeof(gpVertex2Fixed));

  for (int i = 0; i < poly->num_vertices; i++) {
    vertices[i].x = (int)(poly->t_vertices[i].x * MIN(GP_XRES, GP_YRES) / 2);
    vertices[i].y = (int)(poly->t_vertices[i].y * MIN(GP_XRES, GP_YRES) / 2);
  }

  int x_start = MAX(0, GP_XRES/2+MIN(vertices[0].x, MIN(vertices[1].x, vertices[2].x)));
  int x_end   = MIN(GP_XRES, GP_XRES/2+1+MAX(vertices[0].x, MAX(vertices[1].x, vertices[2].x)));

  int y_start = MAX(0, GP_YRES/2-MAX(vertices[0].y, MAX(vertices[1].y, vertices[2].y)));
  int y_end   = MIN(GP_YRES, GP_YRES/2+1-MIN(vertices[0].y, MIN(vertices[1].y, vertices[2].y)));

  // scanline algorithm
  for (int x = x_start; x < x_end; x++) {
    int x_coord = x - GP_XRES/2;
    for (int y = y_start; y < y_end; y++) {
      int y_coord = GP_YRES/2 - y; // flip y
      if (inTriangle(x_coord, y_coord, vertices)) {
        gpSetImagePixel(img, x, y, poly->color.r, poly->color.g, poly->color.b);
      }
    }
  }

  free(vertices);
}

void gpMatrixMult(float *x, float *y, float *result, int a, int b)
{
  // Note: since y is always a square matrix, this computes result = x yT, so the input for y is a transposed matrix!
  // Dimensions: x is a x b, y = b x b, result = a x b

  for (int i = 0; i < a; i++) {
    for (int j = 0; j < b; j++) {
      result[i*b+j] = 0.f;
    }
  }

  for (int i = 0; i < a; i++) {
    for (int j = 0; j < b; j++) {
      for (int k = 0; k < b; k++) {
        result[i*b+k] += x[i*b+j] * y[j*b+k];
      }
    }
  }
}

void gpApplyTMatrix(gpTMatrix *dst, gpTMatrix *src)
{
  float temp[4][4];
  memcpy(temp, dst->m, sizeof(dst->m));

  gpMatrixMult((float *)temp, (float *)src->m, (float *)dst->m, 4, 4);
}

void gpApplyTMatrixToCoord(gpPoly *poly, gpTMatrix *trans)
{
  for (int i = 0; i < poly->num_vertices; i++) {
    float temp[1][4] = {{poly->vertices[i].x, poly->vertices[i].y, poly->vertices[i].z, 1.f}};
    float result[1][4];

    gpMatrixMult((float *)temp, (float *)trans->m, (float *)result, 1, 4);

    float h = result[0][3];

    poly->t_vertices[i].x = result[0][0] / h;
    poly->t_vertices[i].y = result[0][1] / h;
    poly->t_vertices[i].z = result[0][2] / h;
  }
}

void gpApplyTranslate(gpTMatrix *trans, float x, float y, float z)
{
  // translate is a transpose!
  gpTMatrix translate = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {x, y, z, 1.f}}};
  gpApplyTMatrix(trans, &translate);
}

void gpTranslatePoly(gpPoly *poly, float x, float y, float z)
{
  gpApplyTranslate(&poly->trans, x, y, z);
}

void gpTranslatePolyList(gpPolyList *list, float x, float y, float z)
{
  gpApplyTranslate(&list->trans, x, y, z);
}

void gpApplyScale(gpTMatrix *trans, float x, float y, float z)
{
  // scale is a transpose!
  gpTMatrix scale = (gpTMatrix){{{x, 0.f, 0.f, 0.f}, {0.f, y, 0.f, 0.f}, {0.f, 0.f, z, 0.f}, {0.f, 0.f, 0.f, 1.f}}};
  gpApplyTMatrix(trans, &scale);
}

void gpScalePoly(gpPoly *poly, float x, float y, float z)
{
  gpApplyScale(&poly->trans, x, y, z);
}

void gpScalePolyList(gpPolyList *list, float x, float y, float z)
{
  gpApplyScale(&list->trans, x, y, z);
}

void gpApplyRotate(gpTMatrix *trans, float x, float y, float z)
{
  float sinx = sinf(x);
  float cosx = cosf(x);
  float siny = sinf(y);
  float cosy = cosf(y);
  float sinz = sinf(z);
  float cosz = cosf(z);

  // rotate is a transpose!
  // this matrix applies rotation about x-axis, than y-axis, then z-axis
  gpTMatrix rotate = (gpTMatrix){{{cosz*cosy, cosz*siny*sinx+cosx*sinz, -cosz*siny*cosx+sinz*sinx, 0.f}, {-sinz*cosy, -sinz*siny*sinx+cosz*cosx, sinz*siny*cosx+cosz*sinx, 0.f}, {siny, -cosy*sinx, cosy*cosx, 0.f}, {0.f, 0.f, 0.f, 1.f}}};
  gpApplyTMatrix(trans, &rotate);
}

void gpRotatePoly(gpPoly *poly, float x, float y, float z)
{
  gpApplyRotate(&poly->trans, x, y, z);
}

void gpRotatePolyList(gpPolyList *list, float x, float y, float z)
{
  gpApplyRotate(&list->trans, x, y, z);
}

void gpApplyPerspective(gpTMatrix *trans, float near, float far)
{
  // rotate is a transpose!
  gpTMatrix perspective = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1+far/near, 1/near}, {0.f, 0.f, -far, 0.f}}};
  gpApplyTMatrix(trans, &perspective);
}

void gpPerspectivePoly(gpPoly *poly, float near, float far)
{
  gpApplyPerspective(&poly->trans, near, far);
}

void gpPerspectivePolyList(gpPolyList *list, float near, float far)
{
  gpApplyPerspective(&list->trans, near, far);
}

void gpClearTMatrixPoly(gpPoly *poly)
{
  poly->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity
}

void gpClearTMatrixPolyList(gpPolyList *list)
{
  list->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity
}

void gpFillPoly(gpPoly *poly, gpImg *img)
{
  assert(poly);

  if (poly->num_vertices < 3) return;
  else if (poly->num_vertices == 3) gpFillTriangle(poly, img);
  else {
    // Assume convex polygon with vertices in the right order!
    for (int i = 2; i < poly->num_vertices; i++) {
      gpPoly *tri = gpCreatePoly(3);
      tri->t_vertices[0] = (gpVertex3){poly->t_vertices[0].x, poly->t_vertices[0].y, poly->t_vertices[0].z};
      tri->t_vertices[1] = (gpVertex3){poly->t_vertices[i-1].x, poly->t_vertices[i-1].y, poly->t_vertices[i-1].z};
      tri->t_vertices[2] = (gpVertex3){poly->t_vertices[i].x, poly->t_vertices[i].y, poly->t_vertices[i].z};
      gpSetPolyColor(tri, poly->color.r, poly->color.g, poly->color.b);
      gpFillTriangle(tri, img);
      gpDeletePoly(tri);
    }
  }
}

void gpRenderPoly(gpPoly *poly)
{
  assert(poly);

  gpImg *img = gpCreateImage(GP_XRES, GP_YRES);
  gpSetImage(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

  // apply transformations
  gpApplyTMatrixToCoord(poly, &poly->trans);

  // fill polygon algorithm
  gpFillPoly(poly, img);

  gpDisplayImage(img);

  gpReleaseImage(&img);
}

// compare z-coordinate of polygon a and b in descending order
int poly_z_cmp(const void *a, const void *b)
{
  const gpPoly *pa = *(const gpPoly **)a;
  const gpPoly *pb = *(const gpPoly **)b;

  if (pa->avg_z == pb->avg_z) return 0;

  return (pa->avg_z > pb->avg_z) ? -1 : 1;
}

void gpRender(gpPolyList *list)
{
  assert(list);

  gpImg *img = gpCreateImage(GP_XRES, GP_YRES);
  gpSetImage(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

  // compute avg_z for each polygon
  for (int i = 0; i < list->num_polys; i++) {
    gpPoly *poly = list->polys[i];

    // apply transformations
    gpTMatrix temp;
    gpMatrixMult((float *)poly->trans.m, (float *)list->trans.m, (float *)temp.m, 4, 4);
    gpApplyTMatrixToCoord(poly, &temp);

    float sum_z = 0.f;
    for (int j = 0; j < poly->num_vertices; j++) {
      sum_z += poly->t_vertices[j].z;
    }
    poly->avg_z = sum_z / poly->num_vertices;
  }

  // sort polygons by decreasing z (use average for now)
  qsort(list->polys, list->num_polys, sizeof(gpPoly *), poly_z_cmp);

  // fill polygon algorithm for each polygon
  for (int i = 0; i < list->num_polys; i++) {
    gpFillPoly(list->polys[i], img);
  }

  gpDisplayImage(img);

  gpReleaseImage(&img);
}
