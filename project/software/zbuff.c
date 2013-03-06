#include <stdlib.h>

#include "gp.h"

#define PERSPECTIVE

int main()
{
  gpSetBackgroundColor(0x60, 0x00, 0xe0);

  // Create this scene to test depth. It would fail the painter's algorithm:
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

  gpPoly *quad2 = gpCreatePoly(4);
  gpSetPolyVertex(quad2, 0, -0.5f, 0.f, 0.5f);
  gpSetPolyVertex(quad2, 1, -0.5f, 1.f, 0.5f);
  gpSetPolyVertex(quad2, 2, 1.f, 1.f, 0.5f);
  gpSetPolyVertex(quad2, 3, 1.f, 0.f, GP_INFER_COORD);
  gpSetPolyColor(quad2, 0x0, 0x0, 0xff); //blue

  gpPolyList *list = gpCreatePolyList();
  gpAddPolyToList(list, tri1);
  gpAddPolyToList(list, quad2);

  gpTranslatePolyList(list, 0.0, -0.5, 2.0);

#ifdef PERSPECTIVE
  gpEnable(GP_PERSPECTIVE);
  gpSetFrustrum(1.0, 10.0);
#endif

  gpRender(list);
}

