#include "gp.h"

#include <math.h>
#include <stdlib.h>

#ifndef MAX
#define MAX(a,b) (a > b ? a : b)
#endif

#ifndef MIN
#define MIN(a,b) (a < b ? a : b)
#endif

gpPolyHierarchy *h = NULL;

void idle()
{
  // do nothing
}

bool keyboard(int c)
{
  bool render = true;

  switch (c) {
    case 'w':
      gpTranslatePolyHierarchy(h, 0.f, 0.f, -.2f);
      break;
    case 'a':
      gpRotatePolyHierarchy(h, 0.f, .05f, 0.f);
      break;
    case 's':
      gpTranslatePolyHierarchy(h, 0.f, 0.f, .2f);
      break;
    case 'd':
      gpRotatePolyHierarchy(h, 0.f, -.05f, 0.f);
      break;
    case 'r':
      gpRotatePolyHierarchy(h, .05f, 0.f, 0.f);
      break;
    case 'f':
      gpRotatePolyHierarchy(h, -.05f, 0.f, 0.f);
      break;
    case 'h':
      gpTranslatePolyHierarchy(h, .2f, 0.f, 0.f);
      break;
    case 'l':
      gpTranslatePolyHierarchy(h, -.2f, 0.f, 0.f);
      break;
    case 'k':
      gpTranslatePolyHierarchy(h, 0.f, -.2f, 0.f);
      break;
    case 'j':
      gpTranslatePolyHierarchy(h, 0.f, .2f, 0.f);
      break;
    case 'q':
      return true;
    default:
      render = false;
      break;
  }

  if (render) {
    gpRenderAll(h);
  }

  return false;
}

gpPolyList *createStairs()
{
  gpPolyList *stairs = gpCreatePolyList();

  static const int NUM_STAIRS = 20;
  static const float DELTA_ANGLE = 2 * 3.14159265f / NUM_STAIRS;
  static const float INNER_RADIUS = .25f;
  static const float OUTER_RADIUS = 3.5f;
  static const float HEIGHT = .4f;

  for (int i = 0; i < NUM_STAIRS; i++) {
    float angle = -i * DELTA_ANGLE;

    gpPoly *z = gpCreatePoly(4);
    gpSetPolyVertex(z, 0, INNER_RADIUS, i * HEIGHT, 0.f);
    gpSetPolyVertex(z, 1, OUTER_RADIUS, i * HEIGHT, 0.f);
    gpSetPolyVertex(z, 2, OUTER_RADIUS, (i + 1) * HEIGHT, 0.f);
    gpSetPolyVertex(z, 3, INNER_RADIUS, (i + 1) * HEIGHT, GP_INFER_COORD);
    gpSetPolyColor(z, 0xff - i, 0xff - i, 0xff - i);
    gpRotatePoly(z, 0.f, angle, 0.f);

    gpPoly *y = gpCreatePoly(4);
    gpSetPolyVertex(y, 0, INNER_RADIUS, (i + 1) * HEIGHT, 0.f);
    gpSetPolyVertex(y, 1, OUTER_RADIUS, (i + 1) * HEIGHT, 0.f);
    gpSetPolyVertex(y, 2, OUTER_RADIUS * cosf(DELTA_ANGLE), (i + 1) * HEIGHT, OUTER_RADIUS * sinf(DELTA_ANGLE));
    gpSetPolyVertex(y, 3, INNER_RADIUS * cosf(DELTA_ANGLE), GP_INFER_COORD, INNER_RADIUS * sinf(DELTA_ANGLE));
    gpSetPolyColor(y, 0xff - i - 4 * NUM_STAIRS, 0xff - i - 4 * NUM_STAIRS, 0xff - i - 4 * NUM_STAIRS);
    gpRotatePoly(y, 0.f, angle, 0.f);

    gpPoly *x = gpCreatePoly(4);
    gpSetPolyVertex(x, 0, INNER_RADIUS, 0.f, 0.f);
    gpSetPolyVertex(x, 1, INNER_RADIUS, (i + 1) * HEIGHT, 0.f);
    gpSetPolyVertex(x, 2, INNER_RADIUS * cosf(DELTA_ANGLE), (i + 1) * HEIGHT, INNER_RADIUS * sinf(DELTA_ANGLE));
    gpSetPolyVertex(x, 3, GP_INFER_COORD, 0.f, INNER_RADIUS * sinf(DELTA_ANGLE));
    gpSetPolyColor(x, 0x7f + 2 * NUM_STAIRS, 0x7f + 2 * NUM_STAIRS, 0x7f + 2 * NUM_STAIRS);
    gpRotatePoly(x, 0.f, angle, 0.f);

    gpAddPolyToList(stairs, z);
    gpAddPolyToList(stairs, y);
    gpAddPolyToList(stairs, x);
  }

  return stairs;
}

/* User program */
int main()
{
  gpSetBackgroundColor(0x60, 0x00, 0xe0);
  gpEnable(GP_ZBUFFER);
  gpEnable(GP_PERSPECTIVE);
  gpSetFrustrum(2.f, 50.f);

  gpPolyList *stair_list = createStairs();

  static const int FLOOR_LEN = 4.f;
  gpPoly *floor = gpCreatePoly(4);
  gpSetPolyVertex(floor, 0, 0.f, 0.f, -FLOOR_LEN);
  gpSetPolyVertex(floor, 1, FLOOR_LEN, 0.f, 0.f);
  gpSetPolyVertex(floor, 2, 0.f, 0.f, FLOOR_LEN);
  gpSetPolyVertex(floor, 3, -FLOOR_LEN, GP_INFER_COORD, 0.f);
  gpSetPolyColor(floor, 0x40, 0x20, 0x20);
  gpAddPolyToList(stair_list, floor);

  h = gpCreatePolyHierarchy();
  gpSetPolyHierarchyList(h, stair_list);
  gpRotatePolyHierarchy(h, 0.f, .7854f, 0.f);
  gpTranslatePolyHierarchy(h, 0.f, -2.f, 10.f);

  gpRenderAll(h);

  gpCallbacks(keyboard, idle);

  gpDeletePolyHierarchy(h);

  return 0;
}
