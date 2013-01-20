#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <cv.h>
#include <highgui.h>

/* Struct definitions */

//  3-d coordinate
typedef struct {
  float x, y, z;
} gpVertex3;

typedef struct {
  gpVertex3 *vertices;
  int num_vertices;
} gpPoly;

/* Library functions */
gpPoly * gpCreatePoly(int num_vertices)
{
  assert(num_vertices > 0 && "gpPoly must have at least 1 vertex");

  gpPoly *poly = malloc(sizeof(gpPoly));
  poly->vertices = malloc(num_vertices * sizeof(gpVertex3));
  poly->num_vertices = num_vertices;

  // initialize all vertices to 0
  gpVertex3 zeroVertex = {0.f, 0.f, 0.f};
  for (int i = 0; i < num_vertices; i++) {
    memcpy(&poly->vertices[i], &zeroVertex, sizeof(zeroVertex));
  }

  return poly;
}

void gpSetPolyVertex(gpPoly *poly, int num, float x, float y, float z)
{
  assert(num >= 0 && num < poly->num_vertices && "invalid vertex number");

  gpVertex3 vertex = {x, y, z};
  memcpy(&poly->vertices[num], &vertex, sizeof(vertex));
}

void gpDeletePoly(gpPoly *poly)
{
  assert(poly->num_vertices > 0 && "invalid gpPoly, possibly already deleted");

  free(poly->vertices);
  poly->num_vertices = 0;
  free(poly);
}

void gpRender(gpPoly *poly)
{
  printf("Polygon vertices:");
  for (int i = 0; i < poly->num_vertices; i++) {
    printf(" (%f, %f)", poly->vertices[i].x, poly->vertices[i].y);
  }
  printf("\n");

  // scanline algorithm

  // display image
}

/* User program */
int main()
{
  // Create a triangle
  gpPoly *tri = gpCreatePoly(3);
  gpSetPolyVertex(tri, 0, -1.f, 0.f, 0.f);
  gpSetPolyVertex(tri, 1, 1.f, 0.f, 0.f);
  gpSetPolyVertex(tri, 2, 0.f, 1.f, 0.f);

  // Render it
  gpRender(tri);

  // Clean up
  gpDeletePoly(tri);

  return 0;
}
