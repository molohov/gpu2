#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <assert.h>
#include <stdio.h>

#include "gp.h"
#include "display.h"

#define POLY_LIST_CHUNK_SIZE 16

#ifndef SW
// Hack to reduce code size by half by removing asserts (ignore warning)
#define assert(x)
#endif

#ifndef MAX
#define MAX(a,b) (a > b ? a : b)
#endif

#ifndef MIN
#define MIN(a,b) (a < b ? a : b)
#endif

// global perspective enable
int GLOBAL_PERSPECTIVE = 0;
int GLOBAL_PERSPECTIVE_SET = 0;
float GLOBAL_NEAR;
float GLOBAL_FAR;

// global z-buffer
int GLOBAL_ZBUFFER = 0;
unsigned GLOBAL_ZBUFFER_MAX = 0x7fffffff; // maximum of signed int

// global background color
unsigned char GP_BG_COLOR[3] = {0xff, 0xff, 0xff};

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

    gpMatrixMult((float *)temp, (float *)trans->m, (float *)&poly->t_vertices[i], 1, 4);

    poly->t_vertices[i].x /= poly->t_vertices[i].w;
    poly->t_vertices[i].y /= poly->t_vertices[i].w;
    poly->t_vertices[i].z /= poly->t_vertices[i].w;
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
  float x_position = list->trans.m[3][0];
  float y_position = list->trans.m[3][1];
  float z_position = list->trans.m[3][2];
  gpTranslatePolyListOrigin(list);
  gpApplyRotate(&list->trans, x, y, z);
  gpTranslatePolyList(list, x_position, y_position, z_position);
}

void gpApplyPerspective(gpTMatrix *trans, float near, float far)
{
  // perspective is a transpose!
  //gpTMatrix perspective = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, (far+near)/(near*(far - near)), 1/near}, {0.f, 0.f, 2*far/(far - near), 0.f}}};
  float a = 1/(GLOBAL_NEAR*(1 - GLOBAL_NEAR/GLOBAL_FAR));
  float b = -1/(1 - GLOBAL_NEAR/GLOBAL_FAR);
  gpTMatrix perspective = (gpTMatrix){{{1.f, 0.f, 0.f, 0.f}, {0.f, 1.f, 0.f, 0.f}, {0.f, 0.f, a, 1/near}, {0.f, 0.f, b, 0.f}}};
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

void gpTranslatePolyListOrigin(gpPolyList *list)
{
    //try to revert all the translations away from original position
    list->trans.m[3][0] = 0.f;
    list->trans.m[3][1] = 0.f;
    list->trans.m[3][2] = 0.f;
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

  if (poly->num_vertices < 3) {
    return;
  } else {
    // convert floating point to fixed point
    if (GLOBAL_ZBUFFER)
    {
        // ensure the viewing frustrum has been set such that near and far planes are defined
        assert(GLOBAL_PERSPECTIVE_SET);
        gpVertex3Fixed *vertices = malloc(poly->num_vertices * sizeof(gpVertex3Fixed));

        for (int i = 0; i < poly->num_vertices; i++) {
          vertices[i].x = (int)(poly->t_vertices[i].x * MIN(GP_XRES, GP_YRES) / 2) + GP_XRES/2;
          vertices[i].y = (int)(poly->t_vertices[i].y * MIN(GP_XRES, GP_YRES) / 2) + GP_YRES/2;
          if (!GLOBAL_PERSPECTIVE)
            vertices[i].z = (unsigned)(((GLOBAL_FAR + GLOBAL_NEAR)/(2*(GLOBAL_FAR - GLOBAL_NEAR)) + (1/poly->t_vertices[i].z)*(-GLOBAL_FAR*GLOBAL_NEAR)/(GLOBAL_FAR - GLOBAL_NEAR) + 1/2) * GLOBAL_ZBUFFER_MAX);
          else
            vertices[i].z = (unsigned)(poly->t_vertices[i].z * GLOBAL_ZBUFFER_MAX);
          /* DEBUG
          printf("floating point: x: %f, y: %f, z: %f\n", poly->t_vertices[i].x, poly->t_vertices[i].y, poly->t_vertices[i].z);
          printf("fixed point: x: %d, y: %d, z: %x\n", vertices[i].x, vertices[i].y, vertices[i].z);
          */
        }
        // DEBUG printf("end poly\n");

        gpFillConvexPolyZBuff(img, vertices, poly->num_vertices, &poly->color);

        free(vertices);
    }
    else
    {
        gpVertex2Fixed *vertices = malloc(poly->num_vertices * sizeof(gpVertex2Fixed));

        for (int i = 0; i < poly->num_vertices; i++) {
          vertices[i].x = (int)(poly->t_vertices[i].x * MIN(GP_XRES, GP_YRES) / 2) + GP_XRES/2;
          vertices[i].y = (int)(poly->t_vertices[i].y * MIN(GP_XRES, GP_YRES) / 2) + GP_YRES/2;
        }

        gpFillConvexPoly(img, vertices, poly->num_vertices, &poly->color);

        free(vertices);
    }
  }
}

void gpRenderPoly(gpPoly *poly)
{
  assert(poly);

  gpImg *img = gpCreateImage(GP_XRES, GP_YRES);
  gpSetImage(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

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
  gpSetImage(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

  for (int i = 0; i < list->num_polys; i++) {
    gpPoly *poly = list->polys[i];

    // apply transformations
    gpTMatrix temp;
    gpMatrixMult((float *)poly->trans.m, (float *)list->trans.m, (float *)temp.m, 4, 4);
    gpApplyTMatrixToCoord(poly, &temp);

    // compute avg_z for each polygon
    float sum_z = 0.f;
    for (int j = 0; j < poly->num_vertices; j++) {
      sum_z += poly->t_vertices[j].z;
    }
    poly->avg_z = sum_z / poly->num_vertices;

    // avg_z doesn't seem to work after a perspective transform, so do perspective after
    if (GLOBAL_PERSPECTIVE)
    {
        assert(GLOBAL_PERSPECTIVE_SET);
        gpApplyPerspective(&temp, GLOBAL_NEAR, GLOBAL_FAR);
        gpApplyTMatrixToCoord(poly, &temp);
    }
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

void gpLine (gpVertex2Fixed * v1, gpVertex2Fixed *v2, gpColor * color)
{
    gpImg *img = gpCreateImage(GP_XRES, GP_YRES);
    gpSetImage(img, GP_BG_COLOR[0], GP_BG_COLOR[1], GP_BG_COLOR[2]);

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

    gpDisplayImage(img);
    gpReleaseImage(&img);
}

void gpFillConvexPoly(gpImg *img, gpVertex2Fixed * vertices, int num_vertices, gpColor *color)
{
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

            y_left_0 = y_left_1;
            x_left_0 = x_left_1;
            y_left_1 = vertices[left_index].y;
            x_left_1 = vertices[left_index].x;
            left_dx = abs(x_left_1 - x_left_0);
            left_dy = y_left_1 - y_left_0;
            left_sx = (x_left_0 < x_left_1) ? 1 : -1;
            left_err = left_dx - left_dy;
            assert(y_left_1 >= y_left_0);
        }
        if (vertices[right_index].y <= y) {
            if (left_index == right_index) break;

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
            assert(y_right_1 >= y_right_0);
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
            if (y >= 0) {
            	gpSetImageHLine(img, GP_YRES - 1 - y, x_left_0, x_right_0, r, g, b);
            }
            y++;
        } while (y < vertices[left_index].y && y < vertices[right_index].y && y < GP_YRES);
    } while (left_index != right_index && y < GP_YRES);
}

void gpFillConvexPolyZBuff(gpImg *img, gpVertex3Fixed * vertices, int num_vertices, gpColor *color)
{
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

    // zbuffer bresenham's variables
    unsigned z = vertices[start_index].z;
    unsigned z_left_0 = z, z_right_0 = z;
    unsigned z_left_1 = z, z_right_1 = z;
    int left_dz = 0, right_dz = 0;
    int left_sz = 0, right_sz = 0;
    int left_slope = 0, right_slope = 0;
    int left_rem = 0, right_rem = 0;
    int left_zerr = 0, right_zerr = 0;


    do {
        if (vertices[left_index].y <= y) {
            left_index = left_index - 1;
            if (left_index < 0) left_index = num_vertices - 1;

            y_left_0 = y_left_1;
            x_left_0 = x_left_1;
            y_left_1 = vertices[left_index].y;
            x_left_1 = vertices[left_index].x;
            left_dx = abs(x_left_1 - x_left_0);
            left_dy = y_left_1 - y_left_0;
            left_sx = (x_left_0 < x_left_1) ? 1 : -1;
            left_err = left_dx - left_dy;
            assert(y_left_1 >= y_left_0);

            // zbuffer additions
            z_left_0 = z_left_1;
            z_left_1 = vertices[left_index].z;
            left_dz = z_left_1 - z_left_0;
            if (left_dy) {
                left_slope = left_dz / left_dy;
                left_rem = abs(left_dz - left_slope * left_dy);
            }
            left_sz = (left_dz > 0) ? 1 : -1;
            left_zerr = (left_dy + 1) / 2;
        }
        if (vertices[right_index].y <= y) {
            if (left_index == right_index) break;

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
            assert(y_right_1 >= y_right_0);

            // zbuffer additions
            z_right_0 = z_right_1;
            z_right_1 = vertices[right_index].z;
            right_dz = z_right_1 - z_right_0;
            if (right_dy) {
                right_slope = right_dz / right_dy;
                right_rem = abs(right_dz - right_slope * right_dy);
            }
            right_sz = (right_dz > 0) ? 1 : -1;
            right_zerr = (right_dy + 1) / 2;
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
            if (y >= 0) {
            	gpSetImageHLineZBuff(img, GP_YRES - 1 - y, x_left_0, x_right_0, z_left_0, z_right_0, r, g, b);
            }
            y++;
            z_left_0 += left_slope;
            left_zerr += left_rem;
            if (left_zerr > left_dy) {
                z_left_0 += left_sz;
                left_zerr -= left_dy;
            }
            z_right_0 += right_slope;
            right_zerr += right_rem;
            if (right_zerr > right_dy) {
                z_right_0 += right_sz;
                right_zerr -= right_dy;
            }
        } while (y < vertices[left_index].y && y < vertices[right_index].y && y < GP_YRES);
    } while (left_index != right_index && y < GP_YRES);
}
