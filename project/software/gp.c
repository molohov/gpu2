#ifndef SW
// Reduce code size by removing asserts
#define NDEBUG
#endif

#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>

#include "gp.h"
#include "display.h"

#define POLY_LIST_CHUNK_SIZE 16

#ifndef MAX
#define MAX(a,b) (a > b ? a : b)
#endif

#ifndef MIN
#define MIN(a,b) (a < b ? a : b)
#endif

// global perspective enable
int GLOBAL_PERSPECTIVE = 0;
int GLOBAL_PERSPECTIVE_SET = 0;
float GLOBAL_NEAR = 0.f;
float GLOBAL_FAR = 10.f;

// global z-buffer
int GLOBAL_ZBUFFER = 0;
unsigned GLOBAL_ZBUFFER_MAX = 0x000fffff; // maximum of 20-bit int

// global background color
unsigned char GP_BG_COLOR[3] = {0xff, 0xff, 0xff};

/* Library functions */

#ifdef SW
#include <stdio.h>

void warn(bool cond, const char *msg)
{
  if (!cond) {
    puts(msg);
  }
}
#else
void warn(bool cond, const char *msg)
{
  // do nothing
}
#endif

/* Forward declarations */

void gpFillConvexPoly(gpImg *img, gpVertex2Fixed * vertices, int num_vertices, gpColor *color);
void gpFillConvexPolyZBuff(gpImg *img, gpVertex3Fixed * vertices, int num_vertices, gpColor *color);

gpPolyHierarchy * gpCreatePolyHierarchy()
{
  gpPolyHierarchy *h = malloc(sizeof(gpPolyHierarchy));
  h->list = NULL;
  h->child = NULL;
  h->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity

  return h;
}

void gpSetPolyHierarchyList(gpPolyHierarchy *hierarchy, gpPolyList *list)
{
  assert(hierarchy->list == NULL);
  hierarchy->list = list;
}

void gpSetPolyHierarchyChild(gpPolyHierarchy *hierarchy, gpPolyHierarchy *child)
{
  assert(hierarchy->child == NULL);
  hierarchy->child = child;
}

void gpDeletePolyHierarchy(gpPolyHierarchy *hierarchy)
{
  if (hierarchy->child) {
    gpDeletePolyHierarchy(hierarchy->child);
  }

  if (hierarchy->list) {
    gpDeletePolyList(hierarchy->list);
  }

  free(hierarchy);
}

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
  poly->t_vertices = malloc(num_vertices * sizeof(gpVertex4));
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

gpVertex3Fixed32 gpVertex3Fixed32CrossProduct(gpVertex3Fixed32 a, gpVertex3Fixed32 b)
{
  return (gpVertex3Fixed32){a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x};
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

#ifndef SW

// Hack for std=c99
#define asm __asm

#include "mb_interface.h"

// dst can be the same as either srca or srcb
void gpApply4x4x4TMatrix(gpTMatrix *dst, gpTMatrix *srca, gpTMatrix *srcb)
{
  // Note: srcb is a transposed matrix!

  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      for (int k = 0; k < 4; k++) {
        putfsl(srca->m[i][k], 0);
        putfsl(srcb->m[k][j], 0);
      }
    }
  }

  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 4; j++) {
      getfsl(dst->m[i][j], 1);
    }
  }
}

// srcb is split into 2 parts, srcb is the first 3 elements and srcb4 is the 4th element
void gpApply4x4x1TMatrix(float *dst, gpTMatrix *srca, float *srcb, float srcb4)
{
  for (int i = 0; i < 4; i++) {
    for (int j = 0; j < 3; j++) {
      putfsl(srca->m[j][i], 0);
      putfsl(srcb[j], 0);
    }
    putfsl(srca->m[3][i], 0);
    putfsl(srcb4, 0);
  }

  for (int i = 0; i < 4; i++) {
    getfsl(dst[i], 1);
  }
}
#endif

// dst = dst * src
void gpApplyTMatrix(gpTMatrix *dst, gpTMatrix *src)
{
#ifndef SW
  gpApply4x4x4TMatrix(dst, dst, src);
#else
  float temp[4][4];
  memcpy(temp, dst->m, sizeof(dst->m));

  gpMatrixMult((float *)temp, (float *)src->m, (float *)dst->m, 4, 4);
#endif
}

// dst = src * dst
void gpAppliedTMatrix(gpTMatrix *dst, gpTMatrix *src)
{
#ifndef SW
  gpApply4x4x4TMatrix(dst, src, dst);
#else
  float temp[4][4];
  memcpy(temp, dst->m, sizeof(dst->m));

  gpMatrixMult((float *)src->m, (float *)temp, (float *)dst->m, 4, 4);
#endif
}

// return if going to be rendered
bool gpApplyTMatrixToCoord(gpPoly *poly, gpTMatrix *trans)
{
  for (int i = 0; i < poly->num_vertices; i++) {
#ifndef SW
	  gpApply4x4x1TMatrix((float *)&poly->t_vertices[i], trans, (float *)&poly->vertices[i], 1.f);
#else
    float temp[1][4] = {{poly->vertices[i].x, poly->vertices[i].y, poly->vertices[i].z, 1.f}};

    gpMatrixMult((float *)temp, (float *)trans->m, (float *)&poly->t_vertices[i], 1, 4);
#endif

    // won't get rendered anyway, exit here
    if (poly->t_vertices[i].w < 0.f) {
      return false;
    }

    poly->t_vertices[i].x /= poly->t_vertices[i].w;
    poly->t_vertices[i].y /= poly->t_vertices[i].w;
    poly->t_vertices[i].z /= poly->t_vertices[i].w;
  }

  return true;
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

void gpTranslatePolyHierarchy(gpPolyHierarchy *hierarchy, float x, float y, float z)
{
  gpApplyTranslate(&hierarchy->trans, x, y, z);
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

void gpScalePolyHierarchy(gpPolyHierarchy *hierarchy, float x, float y, float z)
{
  gpApplyScale(&hierarchy->trans, x, y, z);
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

void gpRotatePolyHierarchy(gpPolyHierarchy *hierarchy, float x, float y, float z)
{
  gpApplyRotate(&hierarchy->trans, x, y, z);
}

void gpApplyPerspective(gpTMatrix *trans, float near, float far)
{
  // perspective is a transpose!
  float a = 1/(GLOBAL_NEAR*(1 - GLOBAL_NEAR/GLOBAL_FAR));
  float b = -1/(1 - GLOBAL_NEAR/GLOBAL_FAR);
  gpTMatrix perspective = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, a, 1/near}, {0.f, 0.f, b, 0.f}}};
  gpApplyTMatrix(trans, &perspective);
}

void gpClearTMatrixPoly(gpPoly *poly)
{
  poly->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity
}

void gpClearTMatrixPolyList(gpPolyList *list)
{
  list->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity
}

void gpClearTMatrixPolyHierarchy(gpPolyHierarchy *hierarchy)
{
  hierarchy->trans = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity
}

int gpClipXY(gpVertex2Fixed **vertices_p, int num_vertices)
{
  assert(num_vertices > 0);

  int max_vertices = 2 * num_vertices;

  // clip x < 0
  {
    gpVertex2Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex2Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex2Fixed));
    gpVertex2Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex2Fixed E = (*vertices_p)[i];
      if (E.x >= 0) {
        if (S.x < 0) {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex2Fixed){0, E.y - E.x * (E.y - S.y) / (E.x - S.x)};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.x < 0) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex2Fixed){0, S.y - S.x * (S.y - E.y) / (S.x - E.x)};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip x >= xres
  {
    gpVertex2Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex2Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex2Fixed));
    gpVertex2Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex2Fixed E = (*vertices_p)[i];
      if (E.x < GP_XRES) {
        if (S.x >= GP_XRES) {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex2Fixed){GP_XRES - 1, E.y - (E.x - GP_XRES + 1) * (E.y - S.y) / (E.x - S.x)};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.x >= GP_XRES) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex2Fixed){GP_XRES - 1, S.y - (S.x - GP_XRES + 1) * (S.y - E.y) / (S.x - E.x)};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip y < 0
  {
    gpVertex2Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex2Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex2Fixed));
    gpVertex2Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex2Fixed E = (*vertices_p)[i];
      if (E.y >= 0) {
        if (S.y < 0) {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex2Fixed){E.x - E.y * (E.x - S.x) / (E.y - S.y), 0};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.y < 0) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex2Fixed){S.x - S.y * (S.x - E.x) / (S.y - E.y), 0};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip y >= yres
  {
    gpVertex2Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex2Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex2Fixed));
    gpVertex2Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex2Fixed E = (*vertices_p)[i];
      if (E.y < GP_YRES) {
        if (S.y >= GP_YRES) {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex2Fixed){E.x - (E.y - GP_YRES + 1) * (E.x - S.x) / (E.y - S.y), GP_YRES - 1};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.y >= GP_YRES) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex2Fixed){S.x - (S.y - GP_YRES + 1) * (S.x - E.x) / (S.y - E.y), GP_YRES - 1};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }

  return num_vertices;
}

int gpClipXYZ(gpVertex3Fixed **vertices_p, int num_vertices, float near, float far)
{
  assert(num_vertices > 0);

  int max_vertices = 2 * num_vertices;

  // clip x < 0
  {
    gpVertex3Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex3Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex3Fixed));
    gpVertex3Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex3Fixed E = (*vertices_p)[i];
      if (E.x >= 0) {
        if (S.x < 0) {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex3Fixed){0, E.y - E.x * (E.y - S.y) / (E.x - S.x),
                                                    {E.z.f - E.x * (E.z.f - S.z.f) / (E.x - S.x)}};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.x < 0) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex3Fixed){0, S.y - S.x * (S.y - E.y) / (S.x - E.x),
                                                    {S.z.f - S.x * (S.z.f - E.z.f) / (S.x - E.x)}};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip x >= xres
  {
    gpVertex3Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex3Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex3Fixed));
    gpVertex3Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex3Fixed E = (*vertices_p)[i];
      if (E.x < GP_XRES) {
        if (S.x >= GP_XRES) {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex3Fixed){GP_XRES - 1, E.y - (E.x - GP_XRES + 1) * (E.y - S.y) / (E.x - S.x),
                                                              {E.z.f - (E.x - GP_XRES + 1) * (E.z.f - S.z.f) / (E.x - S.x)}};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.x >= GP_XRES) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.x - S.x != 0);
          output_vertices[idx] = (gpVertex3Fixed){GP_XRES - 1, S.y - (S.x - GP_XRES + 1) * (S.y - E.y) / (S.x - E.x),
                                                              {S.z.f - (S.x - GP_XRES + 1) * (S.z.f - E.z.f) / (S.x - E.x)}};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip y < 0
  {
    gpVertex3Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex3Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex3Fixed));
    gpVertex3Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex3Fixed E = (*vertices_p)[i];
      if (E.y >= 0) {
        if (S.y < 0) {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex3Fixed){E.x - E.y * (E.x - S.x) / (E.y - S.y), 0,
                                                 {E.z.f - E.y * (E.z.f - S.z.f) / (E.y - S.y)}};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.y < 0) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex3Fixed){S.x - S.y * (S.x - E.x) / (S.y - E.y), 0,
                                                 {S.z.f - S.y * (S.z.f - E.z.f) / (S.y - E.y)}};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip y >= yres
  {
    gpVertex3Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex3Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex3Fixed));
    gpVertex3Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex3Fixed E = (*vertices_p)[i];
      if (E.y < GP_YRES) {
        if (S.y >= GP_YRES) {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex3Fixed){E.x - (E.y - GP_YRES + 1) * (E.x - S.x) / (E.y - S.y), GP_YRES - 1,
                                                 {E.z.f - (E.y - GP_YRES + 1) * (E.z.f - S.z.f) / (E.y - S.y)}};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.y >= GP_YRES) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.y - S.y != 0);
          output_vertices[idx] = (gpVertex3Fixed){S.x - (S.y - GP_YRES + 1) * (S.x - E.x) / (S.y - E.y), GP_YRES - 1,
                                                 {S.z.f - (S.y - GP_YRES + 1) * (S.z.f - E.z.f) / (S.y - E.y)}};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip z < near
  {
    gpVertex3Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex3Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex3Fixed));
    gpVertex3Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex3Fixed E = (*vertices_p)[i];
      if (E.z.f >= near) {
        if (S.z.f < near) {
          // intersection
          assert(E.z.f - S.z.f != 0.f);
          output_vertices[idx] = (gpVertex3Fixed){E.x - (int)((E.z.f - near) * (E.x - S.x) / (E.z.f - S.z.f) + .5f),
                                                  E.y - (int)((E.z.f - near) * (E.y - S.y) / (E.z.f - S.z.f) + .5f), {near}};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.z.f < near) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.z.f - S.z.f != 0.f);
          output_vertices[idx] = (gpVertex3Fixed){S.x - (int)((S.z.f - near) * (S.x - E.x) / (S.z.f - E.z.f) + .5f),
                                                  S.y - (int)((S.z.f - near) * (S.y - E.y) / (S.z.f - E.z.f) + .5f), {near}};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }
  // clip z > far
  {
    gpVertex3Fixed *output_vertices = malloc(max_vertices * sizeof(gpVertex3Fixed));
    memcpy(output_vertices, *vertices_p, num_vertices * sizeof(gpVertex3Fixed));
    gpVertex3Fixed S = output_vertices[num_vertices - 1];

    int idx = 0;
    int new_num_vertices = num_vertices;
    for (int i = 0; i < num_vertices; i++) {
      gpVertex3Fixed E = (*vertices_p)[i];
      if (E.z.f <= far) {
        if (S.z.f > far) {
          // intersection
          assert(E.z.f - S.z.f != 0.f);
          output_vertices[idx] = (gpVertex3Fixed){E.x - (int)((E.z.f - far) * (E.x - S.x) / (E.z.f - S.z.f) + .5f),
                                                  E.y - (int)((E.z.f - far) * (E.y - S.y) / (E.z.f - S.z.f) + .5f), {far}};
          idx++;
          new_num_vertices++;
        }
        output_vertices[idx] = E;
      } else {
        if (S.z.f > far) {
          // remove
          new_num_vertices--;
          idx--;
        } else {
          // intersection
          assert(E.z.f - S.z.f != 0.f);
          output_vertices[idx] = (gpVertex3Fixed){S.x - (int)((S.z.f - far) * (S.x - E.x) / (S.z.f - E.z.f) + .5f),
                                                  S.y - (int)((S.z.f - far) * (S.y - E.y) / (S.z.f - E.z.f) + .5f), {far}};
        }
      }
      S = E;
      idx++;
    }
    num_vertices = new_num_vertices;
    free(*vertices_p);
    *vertices_p = output_vertices;
  }

  return num_vertices;
}

void gpFillPoly(gpPoly *poly, gpImg *img)
{
    assert(poly);

    // convert floating point to fixed point
    if (GLOBAL_ZBUFFER)
    {
        gpVertex3Fixed *vertices = malloc(poly->num_vertices * sizeof(gpVertex3Fixed));

        for (int i = 0; i < poly->num_vertices; i++) {
          vertices[i].x = (int)(poly->t_vertices[i].x * MIN(GP_XRES, GP_YRES) / 2) + GP_XRES/2;
          vertices[i].y = (int)(poly->t_vertices[i].y * MIN(GP_XRES, GP_YRES) / 2) + GP_YRES/2;
          vertices[i].z.f = poly->t_vertices[i].z;
          if (poly->t_vertices[i].w < 0.f) {
            return;
          }
        }

        float near = (GLOBAL_PERSPECTIVE) ? 0.f : GLOBAL_NEAR;
        float far = (GLOBAL_PERSPECTIVE) ? 1.f : GLOBAL_FAR;

        int fill_vertices = gpClipXYZ(&vertices, poly->num_vertices, near, far);

        for (int i = 0; i < fill_vertices; i++) {
          if (GLOBAL_PERSPECTIVE) {
            vertices[i].z.u = (unsigned)(vertices[i].z.f * GLOBAL_ZBUFFER_MAX);
          } else {
            vertices[i].z.u = (unsigned)((vertices[i].z.f - GLOBAL_NEAR) / (GLOBAL_FAR - GLOBAL_NEAR) * GLOBAL_ZBUFFER_MAX);
          }
        }

        if (fill_vertices) {
          gpFillConvexPolyZBuff(img, vertices, fill_vertices, &poly->color);
        }

        free(vertices);
    }
    else
    {
        gpVertex2Fixed *vertices = malloc(poly->num_vertices * sizeof(gpVertex2Fixed));

        for (int i = 0; i < poly->num_vertices; i++) {
          vertices[i].x = (int)(poly->t_vertices[i].x * MIN(GP_XRES, GP_YRES) / 2) + GP_XRES/2;
          vertices[i].y = (int)(poly->t_vertices[i].y * MIN(GP_XRES, GP_YRES) / 2) + GP_YRES/2;
          if (poly->t_vertices[i].w < 0.f) {
            return;
          }
        }

        int fill_vertices = gpClipXY(&vertices, poly->num_vertices);

        if (fill_vertices) {
          gpFillConvexPoly(img, vertices, fill_vertices, &poly->color);
        }

        free(vertices);
    }
}

void gpRenderPoly(gpPoly *poly)
{
  assert(poly);

  gpImg *img = gpCreateImage(GP_XRES, GP_YRES);
  gpSetImageBackground(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

  // apply transformations
  if (GLOBAL_PERSPECTIVE)
  {
    assert(GLOBAL_PERSPECTIVE_SET);
    gpApplyPerspective(&poly->trans, GLOBAL_NEAR, GLOBAL_FAR);
  }
  gpApplyTMatrixToCoord(poly, &poly->trans);

  // fill polygon algorithm
  gpFillPoly(poly, img);

  gpDisplayImage(img);

  gpReleaseImage(&img);
}

// compare z-coordinate of polygons a and b in descending order
int poly_painters(const void *a, const void *b)
{
  const gpPoly *pa = *(const gpPoly **)a;
  const gpPoly *pb = *(const gpPoly **)b;

  if (pa->avg_z == pb->avg_z) return 0;

  return (pa->avg_z > pb->avg_z) ? -1 : 1;
}

// compare z-coordinate of polygons a and b in ascending order
int poly_reverse_painters(const void *a, const void *b)
{
  return poly_painters(b, a);
}

void gpRender(gpPolyList *list)
{
  assert(list);

  gpImg *img = gpCreateImage(GP_XRES, GP_YRES);
  gpSetImageBackground(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

  gpTMatrix last;

  if (GLOBAL_PERSPECTIVE) {
    assert(GLOBAL_PERSPECTIVE_SET);
    memcpy(&last, &list->trans.m, sizeof(list->trans.m));
    gpApplyPerspective(&last, GLOBAL_NEAR, GLOBAL_FAR);
  }

  for (int i = 0; i < list->num_polys; i++) {
    gpPoly *poly = list->polys[i];

    // apply transformations
    gpTMatrix temp;
#ifndef SW
    if (GLOBAL_PERSPECTIVE) {
      gpApply4x4x4TMatrix(&temp, &poly->trans, &last);
    } else {
      gpApply4x4x4TMatrix(&temp, &poly->trans, &list->trans);
    }
#else
    if (GLOBAL_PERSPECTIVE) {
      gpMatrixMult((float *)poly->trans.m, (float *)last.m, (float *)temp.m, 4, 4);
    } else {
      gpMatrixMult((float *)poly->trans.m, (float *)list->trans.m, (float *)temp.m, 4, 4);
    }
#endif
    bool render = gpApplyTMatrixToCoord(poly, &temp);
    if (!render) {
      continue;
    }

    // compute avg_z for each polygon
    float sum_z = 0.f;
    for (int j = 0; j < poly->num_vertices; j++) {
      sum_z += poly->t_vertices[j].z;
    }
    poly->avg_z = sum_z / poly->num_vertices;
  }

  // sort polygons by decreasing z (use average for now)
  if (GLOBAL_ZBUFFER) {
    qsort(list->polys, list->num_polys, sizeof(gpPoly *), poly_reverse_painters);
  } else {
    qsort(list->polys, list->num_polys, sizeof(gpPoly *), poly_painters);
  }

  // fill polygon algorithm for each polygon
  for (int i = 0; i < list->num_polys; i++) {
    gpFillPoly(list->polys[i], img);
  }

  gpDisplayImage(img);

  gpReleaseImage(&img);
}

void gpRenderAll(gpPolyHierarchy *hierarchy)
{
  gpPolyList *list = gpCreatePolyList();

  gpTMatrix trans = {{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, 1.f, 0.f}, {0.f, 0.f, 0.f, 1.f}}}; // Identity

  if (GLOBAL_PERSPECTIVE) {
      assert(GLOBAL_PERSPECTIVE_SET);
      gpApplyPerspective(&trans, GLOBAL_NEAR, GLOBAL_FAR);
  }

  while (hierarchy) {
    gpAppliedTMatrix(&trans, &hierarchy->trans);

    if (hierarchy->list) {
      gpTMatrix list_trans;
#ifndef SW
      gpApply4x4x4TMatrix(&list_trans, &hierarchy->list->trans, &trans);
#else
      gpMatrixMult((float *)hierarchy->list->trans.m, (float *)trans.m, (float *)list_trans.m, 4, 4);
#endif
      for (int i = 0; i < hierarchy->list->num_polys; i++) {
        gpPoly *poly = hierarchy->list->polys[i];
        gpAddPolyToList(list, poly);
        gpTMatrix temp;
#ifndef SW
        gpApply4x4x4TMatrix(&temp, &poly->trans, &list_trans);
#else
        gpMatrixMult((float *)poly->trans.m, (float *)list_trans.m, (float *)temp.m, 4, 4);
#endif
        bool render = gpApplyTMatrixToCoord(poly, &temp);

        if (!render) {
          continue;
        }

        // compute avg_z for each polygon
        float sum_z = 0.f;
        for (int j = 0; j < poly->num_vertices; j++) {
          sum_z += poly->t_vertices[j].z;
        }
        poly->avg_z = sum_z / poly->num_vertices;
      }
    }

    hierarchy = hierarchy->child;
  }

  gpImg *img = gpCreateImage(GP_XRES, GP_YRES);
  gpSetImageBackground(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

  // sort polygons by decreasing z (use average for now)
  if (GLOBAL_ZBUFFER) {
    qsort(list->polys, list->num_polys, sizeof(gpPoly *), poly_reverse_painters);
  } else {
    qsort(list->polys, list->num_polys, sizeof(gpPoly *), poly_painters);
  }

  // fill polygon algorithm for each polygon
  for (int i = 0; i < list->num_polys; i++) {
    gpFillPoly(list->polys[i], img);
  }

  gpDisplayImage(img);

  gpReleaseImage(&img);

  free(list->polys);
  free(list);
}

void gpEnable(int gpFunction)
{
    switch (gpFunction)
    {
        case GP_PERSPECTIVE:
            GLOBAL_PERSPECTIVE = 1;
            break;
        case GP_ZBUFFER:
            GLOBAL_ZBUFFER = 1;
            break;
    }
}

void gpDisable (int gpFunction)
{
    switch (gpFunction)
    {
        case GP_PERSPECTIVE:
            GLOBAL_PERSPECTIVE = 0;
            break;
        case GP_ZBUFFER:
            GLOBAL_ZBUFFER = 0;
            break;
    }
}

void gpSetBackgroundColor(unsigned char r, unsigned char g, unsigned char b)
{
    GP_BG_COLOR[0] = r;
    GP_BG_COLOR[1] = g;
    GP_BG_COLOR[2] = b;
}

void gpSetFrustrum(float near, float far)
{
    GLOBAL_PERSPECTIVE_SET = 1;
    GLOBAL_NEAR = near;
    GLOBAL_FAR = far;
}

// Note: this is not symmetric, ie drawing (v1, v2) will not draw the same line as (v2, v1)
void gpFillLine(gpImg *img, gpVertex2Fixed *v1, gpVertex2Fixed *v2, gpColor *color)
{
    // flip y
    int y0 = GP_YRES - 1 - v1->y;
    int y1 = GP_YRES - 1 - v2->y;
    int x0 = v1->x;
    int x1 = v2->x;

    int dx = abs(x1 - x0);
    int dy = abs(y1 - y0);
    int sx = (x0 < x1) ? 1 : -1;
    int sy = (y0 < y1) ? 1 : -1;
    int err = dx-dy;

    while (1) {
        gpSetImagePixel(img, x0, y0, color->r, color->g, color->b);
        if (x0 == x1 && y0 == y1) break;
        int e2 = 2*err;
        if (e2 > -dy) {
            err -= dy;
            x0 += sx;
        }
        if (e2 < dx) {
            err += dx;
            y0 += sy;
        }
    }
}

void gpFillConvexPoly(gpImg *img, gpVertex2Fixed * vertices, int num_vertices, gpColor *color)
{
    if (num_vertices == 1) {
        gpFillLine(img, vertices, vertices, color);
        return;
    }
    if (num_vertices == 2) {
        gpFillLine(img, vertices, vertices + 1, color);
        return;
    }

    int y_min = GP_YRES;
    int start_index = -1;

    for (int i = 0; i < num_vertices; i++) {
        if (vertices[i].y < y_min) {
            y_min = vertices[i].y;
            start_index = i;
        }
    }

    int left_index = start_index, right_index = start_index;

    unsigned char r = color->r;
    unsigned char g = color->g;
    unsigned char b = color->b;
    
    int y = vertices[start_index].y;

    int y_left_0 = y, y_left_1 = y;
    int y_right_0 = y, y_right_1 = y;
    int x_left_0 = vertices[start_index].x;
    int x_left_1 = x_left_0;
    int x_right_0 = x_left_0;
    int x_right_1 = x_left_0;

    int left_dx = 0, right_dx = 0;
    int left_dy = 0, right_dy = 0;
    int left_sx = 0, right_sx = 0;
    int left_err = 0, right_err = 0;

    do {
        if (vertices[left_index].y <= y) {
            left_index = left_index - 1;
            if (left_index < 0) left_index = num_vertices - 1;

            if (left_index == right_index && vertices[right_index].y <= y) {
                gpSetImageHLine(img, GP_YRES - 1 - y, x_left_1, x_right_1, r, g, b);
                break;
            }

            y_left_0 = y_left_1;
            x_left_0 = x_left_1;
            y_left_1 = vertices[left_index].y;
            x_left_1 = vertices[left_index].x;
            left_dx = abs(x_left_1 - x_left_0);
            left_dy = y_left_1 - y_left_0;
            left_sx = (x_left_0 < x_left_1) ? 1 : -1;
            left_err = left_dx - left_dy;
            warn(y_left_1 >= y_left_0, "You are probably trying to render a concave polygon, which isn't supported");
        }
        if (vertices[right_index].y <= y) {
            right_index = right_index + 1;
            if (right_index == num_vertices) right_index = 0;

            y_right_0 = y_right_1;
            x_right_0 = x_right_1;
            y_right_1 = vertices[right_index].y;
            x_right_1 = vertices[right_index].x;
            right_dx = abs(x_right_1 - x_right_0);
            right_dy = y_right_1 - y_right_0;
            right_sx = (x_right_0 < x_right_1) ? 1 : -1;
            right_err = right_dx - right_dy;
            warn(y_right_1 >= y_right_0, "You are probably trying to render a concave polygon, which isn't supported");
        }

        do {
            // left
            while (1) {
                int e2 = 2*left_err;
                if (y == y_left_1 && x_left_0 == x_left_1) break;
                if (e2 > -left_dy) {
                    left_err -= left_dy;
                    x_left_0 += left_sx;
                }
                if (e2 < left_dx) {
                    left_err += left_dx;
                    break;
                }
            }
            // right
            while (1) {
                int e2 = 2*right_err;
                if (y == y_right_1 && x_right_0 == x_right_1) break;
                if (e2 > -right_dy) {
                    right_err -= right_dy;
                    x_right_0 += right_sx;
                }
                if (e2 < right_dx) {
                    right_err += right_dx;
                    break;
                }
            }
            gpSetImageHLine(img, GP_YRES - 1 - y, x_left_0, x_right_0, r, g, b);
            y++;
        } while (y < vertices[left_index].y && y < vertices[right_index].y);
    } while (left_index != right_index);
}

// Note: this is not symmetric, ie drawing (v1, v2) will not draw the same line as (v2, v1)
void gpFillLineZBuff(gpImg *img, gpVertex3Fixed *v1, gpVertex3Fixed *v2, gpColor *color)
{
    // flip y
    int y0 = GP_YRES - 1 - v1->y;
    int y1 = GP_YRES - 1 - v2->y;
    int x0 = v1->x;
    int x1 = v2->x;
    unsigned z0 = v1->z.u;
    unsigned z1 = v2->z.u;

    int dx = abs(x1 - x0);
    int dy = abs(y1 - y0);
    int sx = (x0 < x1) ? 1 : -1;
    int sy = (y0 < y1) ? 1 : -1;
    int err = dx-dy;

    int dz = z1 - z0;
    int dxy = dx + dy;
    int slope = (dxy) ? dz / dxy : 0;
    int rem = abs(dz - slope * dxy);
    int zerr = (dxy + 1) / 2;
    int sz = (dz > 0) ? 1 : -1;

    while (1) {
        if (img->zbuffer[y0*img->xres + x0] > z0) {
            img->zbuffer[y0*img->xres + x0] = z0;
            gpSetImagePixel(img, x0, y0, color->r, color->g, color->b);
        }
        if (x0 == x1 && y0 == y1) break;
        int e2 = 2*err;
        if (e2 > -dy) {
            err -= dy;
            x0 += sx;

            z0 += slope;
            zerr += rem;
            if (zerr > dxy) {
                z0 += sz;
                zerr -= dxy;
            }
        }
        if (e2 < dx) {
            err += dx;
            y0 += sy;

            z0 += slope;
            zerr += rem;
            if (zerr > dxy) {
                z0 += sz;
                zerr -= dxy;
            }
        }
    }
}

void gpFillConvexPolyZBuff(gpImg *img, gpVertex3Fixed * vertices, int num_vertices, gpColor *color)
{
    if (num_vertices == 1) {
        gpFillLineZBuff(img, vertices, vertices, color);
        return;
    }
    if (num_vertices == 2) {
        gpFillLineZBuff(img, vertices, vertices + 1, color);
        return;
    }

    int y_min = GP_YRES;
    int start_index = -1;

    for (int i = 0; i < num_vertices; i++) {
        if (vertices[i].y < y_min) {
            y_min = vertices[i].y;
            start_index = i;
        }
    }

    int left_index = start_index, right_index = start_index;

    unsigned char r = color->r;
    unsigned char g = color->g;
    unsigned char b = color->b;
    
    int y = vertices[start_index].y;

    int y_left_0 = y, y_left_1 = y;
    int y_right_0 = y, y_right_1 = y;
    int x_left_0 = vertices[start_index].x;
    int x_left_1 = x_left_0;
    int x_right_0 = x_left_0;
    int x_right_1 = x_left_0;

    int left_dx = 0, right_dx = 0;
    int left_dy = 0, right_dy = 0;
    int left_sx = 0, right_sx = 0;
    int left_err = 0, right_err = 0;

    unsigned z_left = vertices[start_index].z.u;
    unsigned z_right = vertices[start_index].z.u;

    // find the normal of the polygon plane
    int index1 = start_index - 1;
    if (index1 < 0) index1 = num_vertices - 1;
    int index2 = start_index + 1;
    if (index2 == num_vertices) index2 = 0;

    gpVertex3Fixed32 l1 = (gpVertex3Fixed32){vertices[index1].x - vertices[start_index].x, vertices[index1].y - vertices[start_index].y,
                                            vertices[index1].z.s - vertices[start_index].z.s};
    gpVertex3Fixed32 l2 = (gpVertex3Fixed32){vertices[index2].x - vertices[start_index].x, vertices[index2].y - vertices[start_index].y,
                                            vertices[index2].z.s - vertices[start_index].z.s};
    gpVertex3Fixed32 nl = gpVertex3Fixed32CrossProduct(l1, l2);

    // Fix divide by zero hack for now...
    if (nl.z == 0) nl.z = 1;

    int x_slope = -nl.x / nl.z;
    int y_slope = -nl.y / nl.z;

    do {
        if (vertices[left_index].y <= y) {

            while (x_left_0 != x_left_1) {
                z_left += x_slope * left_sx;
                x_left_0 += left_sx;
            }

            left_index = left_index - 1;
            if (left_index < 0) left_index = num_vertices - 1;

            if (left_index == right_index && vertices[right_index].y <= y) {
                gpSetImageHLineZBuff(img, GP_YRES - 1 - y, x_left_1, x_right_1, z_left, z_right, x_slope, r, g, b);
                break;
            }

            y_left_0 = y_left_1;
            x_left_0 = x_left_1;
            y_left_1 = vertices[left_index].y;
            x_left_1 = vertices[left_index].x;
            left_dx = abs(x_left_1 - x_left_0);
            left_dy = y_left_1 - y_left_0;
            left_sx = (x_left_0 < x_left_1) ? 1 : -1;
            left_err = left_dx - left_dy;
            warn(y_left_1 >= y_left_0, "You are probably trying to render a concave polygon, which isn't supported");
        }
        if (vertices[right_index].y <= y) {

            while (x_right_0 != x_right_1) {
                z_right += x_slope * right_sx;
                x_right_0 += right_sx;
            }

            right_index = right_index + 1;
            if (right_index == num_vertices) right_index = 0;

            y_right_0 = y_right_1;
            x_right_0 = x_right_1;
            y_right_1 = vertices[right_index].y;
            x_right_1 = vertices[right_index].x;
            right_dx = abs(x_right_1 - x_right_0);
            right_dy = y_right_1 - y_right_0;
            right_sx = (x_right_0 < x_right_1) ? 1 : -1;
            right_err = right_dx - right_dy;
            warn(y_right_1 >= y_right_0, "You are probably trying to render a concave polygon, which isn't supported");
        }

        do {
            // left
            while (y <= y_left_1) {
                int e2 = 2*left_err;
                if (y == y_left_1 && x_left_0 == x_left_1) break;
                if (e2 > -left_dy) {
                    left_err -= left_dy;
                    x_left_0 += left_sx;
                    z_left += x_slope * left_sx;
                }
                if (e2 < left_dx) {
                    left_err += left_dx;
                    break;
                }
            }
            // right
            while (y <= y_right_1) {
                int e2 = 2*right_err;
                if (y == y_right_1 && x_right_0 == x_right_1) break;
                if (e2 > -right_dy) {
                    right_err -= right_dy;
                    x_right_0 += right_sx;
                    z_right += x_slope * right_sx;
                }
                if (e2 < right_dx) {
                    right_err += right_dx;
                    break;
                }
            }
            if (y >= 0) {
                gpSetImageHLineZBuff(img, GP_YRES - 1 - y, x_left_0, x_right_0, z_left, z_right, x_slope, r, g, b);
            }
            y++;
            z_left += y_slope;
            z_right += y_slope;
        } while (y < vertices[left_index].y && y < vertices[right_index].y && y < GP_YRES);
    } while (left_index != right_index && y < GP_YRES);
}

void gpCallbacks(bool (*keyboard)(int c), void (*idle)())
{
  gpSetTimeout(false);

  while (1) {
    int c = gpWaitKey();
    if (c) {
      if (keyboard(c)) {
        break;
      }
    } else {
      idle();
    }
  }

  gpSetTimeout(true);
}
