#include <stdlib.h>

#include "gp.h"

int main()
{
  gpSetBackgroundColor(0x60, 0x00, 0xe0);

  // Create this scene to test depth. It would fail the painter's algorithm:
  // NOTE: diagonal square is actually a triangle, but the square is shown to illustrate the angle relative to the camera-planar square
  /*
  |\
  | \------
  |  |    |
   \ |    |
    \|-----
    */
  
  gpPoly *tri1 = gpCreatePoly(3);
  gpSetPolyVertex(tri1, 0, 0.f, 0.f, 0.f);
  gpSetPolyVertex(tri1, 1, -1.f, 0.f, 1.f);
  gpSetPolyVertex(tri1, 2, -1.f, 1.f, 1.f);
  gpSetPolyColor(tri1, 0x0, 0xff, 0x0); //green

  gpPoly *tri2 = gpCreatePoly(3);
  gpSetPolyVertex(tri2, 0, 0.f, 0.f, 0.f);
  gpSetPolyVertex(tri2, 1, 1.f, 0.f, 1.f);
  gpSetPolyVertex(tri2, 2, 1.f, 1.f, 1.f);
  gpSetPolyColor(tri2, 0x0, 0xff, 0x0); //green

  gpPoly *quad2 = gpCreatePoly(4);
  gpSetPolyVertex(quad2, 0, -5.5f, -5.f, 5.5f);
  gpSetPolyVertex(quad2, 1, -5.5f, 5.f, 5.5f);
  gpSetPolyVertex(quad2, 2, 5.5f, 5.f, 5.5f);
  gpSetPolyVertex(quad2, 3, 5.5f, -5.f, GP_INFER_COORD);
  gpSetPolyColor(quad2, 0x0, 0x0, 0xff); //blue

  gpPolyList *list = gpCreatePolyList();
  gpAddPolyToList(list, quad2);
  gpAddPolyToList(list, tri1);
  gpAddPolyToList(list, tri2);

  gpTranslatePolyList(list, 0.0, -0.5, 2.0);

  gpEnable(GP_ZBUFFER);
  gpEnable(GP_PERSPECTIVE);
  gpSetFrustrum(1.0, 10.0);

  gpRender(list);

  gpDisable(GP_PERSPECTIVE);
  gpRender(list);

  gpDisable(GP_ZBUFFER);
  gpRender(list);
}

