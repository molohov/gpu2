#include "gp.h"

/* User program */
int main()
{
  gpSetBackgroundColor(0x60, 0x00, 0xe0);
  gpEnable(GP_ZBUFFER);

  // Cube
  gpPoly *z = gpCreatePoly(4);
  gpSetPolyVertex(z, 0, -.5f, -.5f, -.5f);
  gpSetPolyVertex(z, 1, -.5f, .5f, -.5f);
  gpSetPolyVertex(z, 2, .5f, .5f, -.5f);
  gpSetPolyVertex(z, 3, .5f, -.5f, GP_INFER_COORD);
  gpSetPolyColor(z, 0xff, 0x0, 0x0);

  gpPoly *z2 = gpCreatePoly(4);
  gpSetPolyVertex(z2, 0, -.5f, -.5f, .5f);
  gpSetPolyVertex(z2, 1, -.5f, .5f, .5f);
  gpSetPolyVertex(z2, 2, .5f, .5f, .5f);
  gpSetPolyVertex(z2, 3, .5f, -.5f, GP_INFER_COORD);
  gpSetPolyColor(z2, 0x0, 0xdf, 0x0);

  gpPoly *y = gpCreatePoly(4);
  gpSetPolyVertex(y, 0, -.5f, .5f, -.5f);
  gpSetPolyVertex(y, 1, -.5f, .5f, .5f);
  gpSetPolyVertex(y, 2, .5f, .5f, .5f);
  gpSetPolyVertex(y, 3, .5f, GP_INFER_COORD, -.5f);
  gpSetPolyColor(y, 0xbf, 0x0, 0x0);

  gpPoly *y2 = gpCreatePoly(4);
  gpSetPolyVertex(y2, 0, -.5f, -.5f, -.5f);
  gpSetPolyVertex(y2, 1, -.5f, -.5f, .5f);
  gpSetPolyVertex(y2, 2, .5f, -.5f, .5f);
  gpSetPolyVertex(y2, 3, .5f, GP_INFER_COORD, -.5f);
  gpSetPolyColor(y2, 0x0, 0xaf, 0x0);

  gpPoly *x = gpCreatePoly(4);
  gpSetPolyVertex(x, 0, .5f, -.5f, -.5f);
  gpSetPolyVertex(x, 1, .5f, -.5f, .5f);
  gpSetPolyVertex(x, 2, .5f, .5f, .5f);
  gpSetPolyVertex(x, 3, GP_INFER_COORD, .5f, -.5f);
  gpSetPolyColor(x, 0x7f, 0x0, 0x0);

  gpPoly *x2 = gpCreatePoly(4);
  gpSetPolyVertex(x2, 0, -.5f, -.5f, -.5f);
  gpSetPolyVertex(x2, 1, -.5f, -.5f, .5f);
  gpSetPolyVertex(x2, 2, -.5f, .5f, .5f);
  gpSetPolyVertex(x2, 3, GP_INFER_COORD, .5f, -.5f);
  gpSetPolyColor(x2, 0x0, 0x5f, 0x0);

  gpPolyList *cube = gpCreatePolyList();
  gpAddPolyToList(cube, z);
  gpAddPolyToList(cube, y);
  gpAddPolyToList(cube, x);
  gpAddPolyToList(cube, z2);
  gpAddPolyToList(cube, y2);
  gpAddPolyToList(cube, x2);

  gpEnable(GP_PERSPECTIVE);
  gpSetFrustrum(1.0, 10.0);

  gpPolyHierarchy *translations = gpCreatePolyHierarchy();
  gpSetPolyHierarchyList(translations, cube);
  gpTranslatePolyHierarchy(translations, 0.f, 0.f, -1.5f);

  gpRotatePolyList(cube, -0.4f, 0.4f, 0.2f);

  for (int c = 0; c < 50; c++) {
    int i;
    for (i = 0; i < 128; i++) {
      gpTranslatePolyHierarchy(translations, 0.f, 0.f, 0.05f);
      gpRotatePolyList(cube, 0.3f, 0.3f, 0.0f);
      gpRenderAll(translations);
    }
    gpTranslatePolyHierarchy(translations, 0.f, 0.f, -i * 0.05f);
  }

  gpDeletePolyHierarchy(translations);

  return 0;
}
