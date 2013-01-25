#include <stdlib.h>

#include "gp.h"

/* User program */
int main()
{
  // Create a triangle
  gpPoly *tri = gpCreatePoly(3);
  gpSetPolyVertex(tri, 0, 0.f, 1.f, 1.f);
  gpSetPolyVertex(tri, 1, -1.f, 0.f, 1.f);
  gpSetPolyVertex(tri, 2, 1.f, 0.f, 1.f);
  gpSetPolyColor(tri, 0xff, 0xff, 0x0); // yellow

  // Render it
  gpRenderPoly(tri);

  gpTranslatePoly(tri, 0.2f, 0.2f, 0.f);
  gpRenderPoly(tri);

  // Create a quadrilateral
  gpPoly *quad = gpCreatePoly(4);
  gpSetPolyVertex(quad, 0, 0.f, 1.f, 2.f);
  gpSetPolyVertex(quad, 1, -1.f, 0.f, 2.f);
  gpSetPolyVertex(quad, 2, 0.f, -1.f, 2.f);
  gpSetPolyVertex(quad, 3, 1.f, 0.5f, GP_INFER_COORD);
  gpSetPolyColor(quad, 0x0, 0xff, 0x0); // green

  // Render it
  gpRenderPoly(quad);

  gpScalePoly(quad, 0.8f, 0.8f, 1.f);
  gpRenderPoly(quad);

  // Create a hexagon
  gpPoly *hex = gpCreatePoly(6);
  gpSetPolyVertex(hex, 0, -.5486f, 1.f, 3.f);
  gpSetPolyVertex(hex, 1, -1.f, 0.f, 3.f);
  gpSetPolyVertex(hex, 2, -.5486f, -1.f, 3.f);
  gpSetPolyVertex(hex, 3, .5486f, -1.f, GP_INFER_COORD);
  gpSetPolyVertex(hex, 4, 1.f, 0.f, GP_INFER_COORD);
  gpSetPolyVertex(hex, 5, .5486f, 1.f, GP_INFER_COORD);
  gpSetPolyColor(hex, 0xff, 0x0, 0x0); // red

  // Render it
  gpRenderPoly(hex);

  // Render all polygons as a list

  gpPolyList *list = gpCreatePolyList();
  gpAddPolyToList(list, tri);
  gpAddPolyToList(list, quad);
  gpAddPolyToList(list, hex);

  // Render it
  gpRender(list);

  gpRotatePolyList(list, 0.f, 0.f, 0.5f);
  gpRender(list);

  // Cleanup
  gpDeletePolyList(list);

  // Cube
  gpPoly *z = gpCreatePoly(4);
  gpSetPolyVertex(z, 0, -.5f, -.5f,-.5f);
  gpSetPolyVertex(z, 1, -.5f, .5f, -.5f);
  gpSetPolyVertex(z, 2, .5f, .5f, -.5f);
  gpSetPolyVertex(z, 3, .5f, -.5f, GP_INFER_COORD);
  gpSetPolyColor(z, 0xff, 0x0, 0x0);

  gpPoly *y = gpCreatePoly(4);
  gpSetPolyVertex(y, 0, -.5f, .5f, -.5f);
  gpSetPolyVertex(y, 1, -.5f, .5f, .5f);
  gpSetPolyVertex(y, 2, .5f, .5f, .5f);
  gpSetPolyVertex(y, 3, .5f, GP_INFER_COORD, -.5f);
  gpSetPolyColor(y, 0xbf, 0x0, 0x0);

  gpPoly *x = gpCreatePoly(4);
  gpSetPolyVertex(x, 0, .5f, -.5f, -.5f);
  gpSetPolyVertex(x, 1, .5f, -.5f, .5f);
  gpSetPolyVertex(x, 2, .5f, .5f, .5f);
  gpSetPolyVertex(x, 3, GP_INFER_COORD, .5f, -.5f);
  gpSetPolyColor(x, 0x7f, 0x0, 0x0);

  gpPolyList *cube = gpCreatePolyList();
  gpAddPolyToList(cube, z);
  gpAddPolyToList(cube, y);
  gpAddPolyToList(cube, x);

  gpRotatePolyList(cube, -0.4f, 0.4f, 0.2f);
  gpRender(cube);

  gpDeletePolyList(cube);

  return 0;
}
