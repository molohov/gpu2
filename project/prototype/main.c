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

  // Create a quadrilateral
  gpPoly *quad = gpCreatePoly(4);
  gpSetPolyVertex(quad, 0, 0.f, 1.f, 2.f);
  gpSetPolyVertex(quad, 1, -1.f, 0.f, 2.f);
  gpSetPolyVertex(quad, 2, 0.f, -1.f, 2.f);
  gpSetPolyVertex(quad, 3, 1.f, 0.5f, 2.f);
  gpSetPolyColor(quad, 0x0, 0xff, 0x0); // green

  // Render it
  gpRenderPoly(quad);

  // Create a hexagon
  gpPoly *hex = gpCreatePoly(6);
  gpSetPolyVertex(hex, 0, -.5486, 1.f, 3.f);
  gpSetPolyVertex(hex, 1, -1.f, 0.f, 3.f);
  gpSetPolyVertex(hex, 2, -.5486, -1.f, 3.f);
  gpSetPolyVertex(hex, 3, .5486, -1.f, 3.f);
  gpSetPolyVertex(hex, 4, 1.f, 0.f, 3.f);
  gpSetPolyVertex(hex, 5, .5486, 1.f, 3.f);
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

  // Cleanup
  gpDeletePolyList(list);

  return 0;
}
