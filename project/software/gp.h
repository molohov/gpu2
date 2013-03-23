#ifndef _GP_H
#define _GP_H

/* include statements */

#include <stdbool.h>
#include <math.h>

#include "display.h"

/* define statements */

// x-resolution of image
#define GP_XRES 1280
// y-resolution of image
#define GP_YRES 720

// possible user input for gpSetPolyVertex (see gpSetPolyVertex for more details)
#define GP_INFER_COORD NAN

/* Internal struct definitions */

// 2-d fixed point for rendering
typedef struct {
  int x, y;
} gpVertex2Fixed;

// 3-d fixed point for rendering with zbuffer
typedef struct {
  int x, y;
  union {
    float f;
    unsigned u;
    signed s;
  } z;
} gpVertex3Fixed;

typedef struct {
  int x, y, z;
} gpVertex3Fixed32;

//  3-d coordinate
typedef struct {
  float x, y, z;
} gpVertex3;

// homogeneous 3-d coordinate
typedef struct {
  float x, y, z, w;
} gpVertex4;

// RGB colour
typedef struct {
  unsigned char r, g, b;
} gpColor;

// 4x4 matrix for transformation calculations
typedef struct {
  float m[4][4];
} gpTMatrix;

/* User struct definitions */

// 3-d shape
typedef struct {
  gpVertex3 *vertices;
  gpVertex4 *t_vertices;
  int num_vertices;
  gpColor color;
  gpVertex3 normal;
  float avg_z;
  gpTMatrix trans;
} gpPoly;

// list of 3-d shapes
typedef struct {
  int num_polys;
  int capacity;
  gpPoly **polys;
  gpTMatrix trans;
} gpPolyList;

// hierarchy of 3-d shapes
struct gpPolyHierarchy {
  gpPolyList *list;
  struct gpPolyHierarchy *child;
  gpTMatrix trans;
};
typedef struct gpPolyHierarchy gpPolyHierarchy;

// see gpEnable for more details
enum { GP_PERSPECTIVE, GP_ZBUFFER };

/* Library function declarations */

/* Create a hierarchy of polygons, add a list, a child hierarchy, and delete the hierarchy
 *
 * Usage: Hierarchies can be used to group lists of polygons under different transformations.
 *        For example, you can create a polygon list for a moving elevator and a static spiral staircase.
 *        These two lists can go under two different sets of transformations, then combined together under one hierarchy.
 *        The top-level hierarchy can then rotate or translate the whole scene together, but still allow the elevator to
 *        translate independently from the static staircase. See wasd.c for code example.
 *
 *        Deleting the hierarchy will recursively delete all child hierarchies and all lists.
 */
gpPolyHierarchy * gpCreatePolyHierarchy();
void gpSetPolyHierarchyList(gpPolyHierarchy *hierarchy, gpPolyList *list);
void gpSetPolyHierarchyChild(gpPolyHierarchy *hierarchy, gpPolyHierarchy *child);
void gpDeletePolyHierarchy(gpPolyHierarchy *hierarchy);

/* Create a list of polygons, add a polygon to the list, and delete the list
 *
 * Usage: Lists can be used to group polygons together to apply a set of transformations to all polygons.
 *        For example, a cube can be created as a polygon list of its 6 faces. The cube can then be manipulated
 *        as a whole with transformations.
 *
 *        Deletine the list will delete all of its polygons.
 */
gpPolyList * gpCreatePolyList();
void gpAddPolyToList(gpPolyList *list, gpPoly *poly);
void gpDeletePolyList(gpPolyList *list);

/* Create a polygon, set a vertex coordinates, set the polygon color, and delete the polygon
 *
 * Usage: Create a convex polygon (concave polygons may not render correctly and issue a warning).
 *        Note that gpSetPolyVertex is zero-indexed.
 *        2-vertex polygons will be rendered as lines and 1-vertex polygons will be rendered as points.
 *        For planar polygons, specify the (x,y,z) coordinates for the first 3 vertices.
 *        For simplicity, the polygon should be flat on either x,y, or z.
 *        To ensure the polygon is planar, specify the remaining vertices with the flat-coordinate as GP_INFER_COORD.
 *        The library will calculate the remaining coordinate so that it lies on the plane of the first 3 vertices.
 *        See main.c or wasd.c for examples. Note that it is generally easier to specify flat polygons and then
 *        rotate the polygon into its rotation (see how wasd.c specifies the spiral staircase polygons).
 */
gpPoly * gpCreatePoly(int num_vertices);
void gpSetPolyVertex(gpPoly *poly, int num, float x, float y, float z);
void gpSetPolyColor(gpPoly *poly, unsigned char r, unsigned char g, unsigned b);
void gpDeletePoly(gpPoly *poly);

/* Perform translation, scaling, or rotation on polygons, polygon lists, or polygon hierarchies
 *
 * Usage: This is the meat of the graphics engine, allowing the user to transform objects.
 *        During rendering, polygon transformations are applied first, then polygon list transformations,
 *        and then polygon hierarchy transformations from the child up to the root.
 *        Rotations can rotate up to 3-axis at once, and rotates in this order: x, y, then z.
 */
void gpTranslatePoly(gpPoly *poly, float x, float y, float z);
void gpTranslatePolyList(gpPolyList *list, float x, float y, float z);
void gpTranslatePolyHierarchy(gpPolyHierarchy *hierarchy, float x, float y, float z);
void gpScalePoly(gpPoly *poly, float x, float y, float z);
void gpScalePolyList(gpPolyList *list, float x, float y, float z);
void gpScalePolyHierarchy(gpPolyHierarchy *hierarchy, float x, float y, float z);
void gpRotatePoly(gpPoly *poly, float x, float y, float z);
void gpRotatePolyList(gpPolyList *list, float x, float y, float z);
void gpRotatePolyHierarchy(gpPolyHierarchy *hierarchy, float x, float y, float z);

/* Clear all transformations on polygons, polygon lists, or polygon hierarchies
 *
 * Usage: These functions reset the transformation to the identity matrix, clearing all current transformations.
 */
void gpClearTMatrixPoly(gpPoly *poly);
void gpClearTMatrixPolyList(gpPolyList *list);
void gpClearTMatrixPolyHierarchy(gpPolyHierarchy *hierarchy);

/* Render polygons, polygon lists, or polygon hierarchies
 *
 * Usage: Call these functions to actually display the scene.
 */
void gpRenderPoly(gpPoly *poly);
void gpRender(gpPolyList *list);
void gpRenderAll(gpPolyHierarchy *hierarchy);

/* Enable or disable functionality of the render
 *
 * Usage: Can be used to enable/disable perspective and the z-buffer for depth rendering.
 */
void gpEnable(int gpFunction);
void gpDisable(int gpFunction);

/* Set the background color
 *
 */
void gpSetBackgroundColor(unsigned char r, unsigned char g, unsigned char b);

/* Set the perspective frustrum
 *
 * Note: both near and far planes should be positive.
 */
void gpSetFrustrum(float near, float far);

/* Set callback functions for keyboard input and idle state.
 *
 * Usage: After this line is executed, the library will execution control.
 *        When a key is pressed, it will call the keyboard function with the key pressed.
 *        On a true return value, the library passes control back to the caller, otherwise it continues.
 *        The idle function is called if there is no keyboard input.
 *
 *        See zbuff.c for a simple example and wasd.c to see how these callback functions can be used
 *        to create an interactive environment.
 */
void gpCallbacks(bool (*keyboard)(int c), void (*idle)());
#endif
