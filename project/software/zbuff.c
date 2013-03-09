#include <stdlib.h>

#include "gp.h"

int main()
{
  gpSetBackgroundColor(0x60, 0x00, 0xe0);
  
  gpPoly *quad1 = gpCreatePoly(4);
  gpSetPolyVertex(quad1, 0, 1.f, 1.f, 0.f);
  gpSetPolyVertex(quad1, 1, .8f, 0.f, 0.f);
  gpSetPolyVertex(quad1, 2, -1.f, 0.f, 0.f);
  gpSetPolyVertex(quad1, 3, -1.f, .5f, GP_INFER_COORD);
  gpSetPolyColor(quad1, 0x0, 0xff, 0x0); //green
  gpRotatePoly(quad1, 0.0, -3.14159/2, 0.0);

  gpPoly *quad2 = gpCreatePoly(4);
  gpSetPolyVertex(quad2, 0, -1.f, 0.f, 0.f);
  gpSetPolyVertex(quad2, 1, -1.f, .5f, 0.f);
  gpSetPolyVertex(quad2, 2, 1.f, 1.f, 0.f);
  gpSetPolyVertex(quad2, 3, .8f, 0.f, GP_INFER_COORD);
  gpSetPolyColor(quad2, 0xff, 0x0, 0x0); //red
  gpRotatePoly(quad2, 0.0, 3.14159/8, 0.0);

  gpPolyList *list = gpCreatePolyList();
  gpAddPolyToList(list, quad2);
  gpAddPolyToList(list, quad1);

  gpTranslatePolyList(list, 0.0, -0.5, 3.0);

  gpEnable(GP_ZBUFFER);
  gpEnable(GP_PERSPECTIVE);
  gpSetFrustrum(1.0, 5.0);

  gpRender(list);

  while (1) {
      gpRotatePoly(quad1, 0.0, 0.1, 0.0);
      gpRender(list);
  }

  gpDisable(GP_PERSPECTIVE);
  gpRender(list);

  gpDisable(GP_ZBUFFER);
  gpRender(list);
}

