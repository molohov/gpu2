#include "gp.h"

#include <math.h>
#include <stdlib.h>

gpPolyList *last = NULL;
gpPolyHierarchy *objs = NULL;

gpPolyList *createCube();

void idle()
{
}

bool keyboard(int c)
{
  gpPolyHierarchy *temp = NULL;

  switch (c) {
    case 'c':
      last = createCube();
      temp = gpCreatePolyHierarchy();
      gpSetPolyHierarchyList(temp, last);
      gpSetPolyHierarchyChild(temp, objs);
      objs = temp;
      break;
    case 'w':
      gpTranslatePolyHierarchy(objs, 0.f, .2f, 0.f);
      break;
    case 's':
      gpTranslatePolyHierarchy(objs, 0.f, -.2f, 0.f);
      break;
    case 'a':
      gpTranslatePolyHierarchy(objs, -.2f, 0.f, 0.f);
      break;
    case 'd':
      gpTranslatePolyHierarchy(objs, .2f, 0.f, 0.f);
      break;
    case 'r':
      gpRotatePolyHierarchy(objs, 0.f, .05f, 0.f);
      break;
    case 'f':
      gpRotatePolyHierarchy(objs, 0.f, -.05f, 0.f);
      break;
    case 'x':
      gpScalePolyHierarchy(objs, .75f, .75f, .75f);
      break;
    case 'z':
      gpScalePolyHierarchy(objs, 1.333f, 1.333f, 1.333f);
      break;
    case 'i':
      gpTranslatePolyList(last, 0.f, .2f, 0.f);
      break;
    case 'k':
      gpTranslatePolyList(last, 0.f, -.2f, 0.f);
      break;
    case 'j':
      gpTranslatePolyList(last, -.2f, 0.f, 0.f);
      break;
    case 'l':
      gpTranslatePolyList(last, .2f, 0.f, 0.f);
      break;
    case 'p':
      gpRotatePolyList(last, 0.f, .05f, 0.f);
      break;
    case ';':
      gpRotatePolyList(last, 0.f, -.05f, 0.f);
      break;
    case 'm':
      gpScalePolyList(last, .75f, .75f, .75f);
      break;
    case 'n':
      gpScalePolyList(last, 1.333f, 1.333f, 1.333f);
      break;
    case 'q':
      return true;
    default:
      break;
  }

  gpTranslatePolyHierarchy(objs, 0.f, 0.f, 4.f);
  gpRenderAll(objs);
  gpTranslatePolyHierarchy(objs, 0.f, 0.f, -4.f);

  return false;
}

gpPolyList *createCube()
{
  static int color_offset = 0;

  // Cube
  gpPoly *z = gpCreatePoly(4);
  gpSetPolyVertex(z, 0, -.5f, -.5f, -.5f);
  gpSetPolyVertex(z, 1, -.5f, .5f, -.5f);
  gpSetPolyVertex(z, 2, .5f, .5f, -.5f);
  gpSetPolyVertex(z, 3, .5f, -.5f, GP_INFER_COORD);
  gpSetPolyColor(z, 0xff + color_offset, 0x0 + color_offset, 0x0 + color_offset);

  gpPoly *z2 = gpCreatePoly(4);
  gpSetPolyVertex(z2, 0, -.5f, -.5f, .5f);
  gpSetPolyVertex(z2, 1, -.5f, .5f, .5f);
  gpSetPolyVertex(z2, 2, .5f, .5f, .5f);
  gpSetPolyVertex(z2, 3, .5f, -.5f, GP_INFER_COORD);
  gpSetPolyColor(z2, 0x0 + color_offset, 0xdf + color_offset, 0x0 + color_offset);

  gpPoly *y = gpCreatePoly(4);
  gpSetPolyVertex(y, 0, -.5f, .5f, -.5f);
  gpSetPolyVertex(y, 1, -.5f, .5f, .5f);
  gpSetPolyVertex(y, 2, .5f, .5f, .5f);
  gpSetPolyVertex(y, 3, .5f, GP_INFER_COORD, -.5f);
  gpSetPolyColor(y, 0xbf + color_offset, 0x0 + color_offset, 0x0 + color_offset);

  gpPoly *y2 = gpCreatePoly(4);
  gpSetPolyVertex(y2, 0, -.5f, -.5f, -.5f);
  gpSetPolyVertex(y2, 1, -.5f, -.5f, .5f);
  gpSetPolyVertex(y2, 2, .5f, -.5f, .5f);
  gpSetPolyVertex(y2, 3, .5f, GP_INFER_COORD, -.5f);
  gpSetPolyColor(y2, 0x0 + color_offset, 0xaf + color_offset, 0x0 + color_offset);

  gpPoly *x = gpCreatePoly(4);
  gpSetPolyVertex(x, 0, .5f, -.5f, -.5f);
  gpSetPolyVertex(x, 1, .5f, -.5f, .5f);
  gpSetPolyVertex(x, 2, .5f, .5f, .5f);
  gpSetPolyVertex(x, 3, GP_INFER_COORD, .5f, -.5f);
  gpSetPolyColor(x, 0x7f + color_offset, 0x0 + color_offset, 0x0 + color_offset);

  gpPoly *x2 = gpCreatePoly(4);
  gpSetPolyVertex(x2, 0, -.5f, -.5f, -.5f);
  gpSetPolyVertex(x2, 1, -.5f, -.5f, .5f);
  gpSetPolyVertex(x2, 2, -.5f, .5f, .5f);
  gpSetPolyVertex(x2, 3, GP_INFER_COORD, .5f, -.5f);
  gpSetPolyColor(x2, 0x0 + color_offset, 0x5f + color_offset, 0x0 + color_offset);

  gpPolyList *cube = gpCreatePolyList();
  gpAddPolyToList(cube, z);
  gpAddPolyToList(cube, y);
  gpAddPolyToList(cube, x);
  gpAddPolyToList(cube, z2);
  gpAddPolyToList(cube, y2);
  gpAddPolyToList(cube, x2);

  color_offset += 39;

  gpRotatePolyList(cube, 0.f, 0.785f, 0.f);

  return cube;
}

/* User program */
int main()
{
  gpSetBackgroundColor(0xff, 0xff, 0xff);
  gpEnable(GP_ZBUFFER);
  gpEnable(GP_PERSPECTIVE);
  gpSetFrustrum(2.f, 50.f);

  last = createCube();
  objs = gpCreatePolyHierarchy();
  gpSetPolyHierarchyList(objs, last);

  gpTranslatePolyHierarchy(objs, 0.f, 0.f, 4.f);
  gpRenderAll(objs);
  gpTranslatePolyHierarchy(objs, 0.f, 0.f, -4.f);

  gpCallbacks(keyboard, idle);

  gpDeletePolyHierarchy(objs);

  return 0;
}
