#include "gp.h"

#include <math.h>
#include <stdlib.h>

gpPolyHierarchy *scene = NULL;
// Color constants for the scene
int GROUND_R = 0x10;
int GROUND_G = 0x7f;
int GROUND_B = 0x10;
int BUILDING_R = 0x3f;
int BUILDING_G = 0x3f;
int BUILDING_B = 0x3f;
// Int constants for the ground
int GROUND_DIV = 10;
// Floating point constants for traversal and math
double pi = 3.14159;
double ROT_SPEED = 0.05f;
double FLIGHT_SPEED = 0.1f;
int dir = -1;

void idle()
{
    gpTranslatePolyHierarchy(scene, 0.f, 0.f, dir*FLIGHT_SPEED);
    gpRenderAll(scene);
}

bool keyboard(int c)
{
    switch (c) {
        // control roll
        case 'j':
            gpRotatePolyHierarchy(scene, 0.0f, 0.0f, 0.1f);
            break;
        case 'k':
            gpRotatePolyHierarchy(scene, 0.0f, 0.0f, -0.1f);
            break;
        // control forward or backward (-1 is forwards)
        case 'r':
            dir = -1;
            break;
        case 'e':
            dir = 1;
            break;
        case 't':
            dir = 0;
            break;
        // control pitch
        case 'w':
            gpRotatePolyHierarchy(scene, ROT_SPEED, 0.f, 0.f);
            break;
        case 's':
            gpRotatePolyHierarchy(scene, -ROT_SPEED, 0.f, 0.f);
            break;
        // control yaw
        case 'a':
            gpRotatePolyHierarchy(scene, 0.f, ROT_SPEED, 0.f);
            break;
        case 'd':
            gpRotatePolyHierarchy(scene, 0.f, -ROT_SPEED, 0.f);
            break;
        // quit
        case 'q':
            return true;
        default:
            return false;
    }

    gpRenderAll(scene);
    return false;
}

gpPolyList *createBlock(double xin, double yin, double zin, int r, int g, int b)
{
  // Create a rectangular prism with dimensions x, y, z 
    double xdim = xin/2;
    double ydim = yin/2;
    double zdim = zin/2;
    gpPoly *z = gpCreatePoly(4);
    gpSetPolyVertex(z, 0, -xdim, -ydim, -zdim);
    gpSetPolyVertex(z, 1, -xdim, ydim, -zdim);
    gpSetPolyVertex(z, 2, xdim, ydim, -zdim);
    gpSetPolyVertex(z, 3, xdim, -ydim, GP_INFER_COORD);
    gpSetPolyColor(z, 2*r, 2*g, 2*b);

    gpPoly *z2 = gpCreatePoly(4);
    gpSetPolyVertex(z2, 0, -xdim, -ydim, zdim);
    gpSetPolyVertex(z2, 1, -xdim, ydim, zdim);
    gpSetPolyVertex(z2, 2, xdim, ydim, zdim);
    gpSetPolyVertex(z2, 3, xdim, -ydim, GP_INFER_COORD);
    gpSetPolyColor(z2, 2*r, 2*g, 2*b);

    gpPoly *y = gpCreatePoly(4);
    gpSetPolyVertex(y, 0, -xdim, ydim, -zdim);
    gpSetPolyVertex(y, 1, -xdim, ydim, zdim);
    gpSetPolyVertex(y, 2, xdim, ydim, zdim);
    gpSetPolyVertex(y, 3, xdim, GP_INFER_COORD, -zdim);
    gpSetPolyColor(y, r, g, b);

    gpPoly *y2 = gpCreatePoly(4);
    gpSetPolyVertex(y2, 0, -xdim, -ydim, -zdim);
    gpSetPolyVertex(y2, 1, -xdim, -ydim, zdim);
    gpSetPolyVertex(y2, 2, xdim, -ydim, zdim);
    gpSetPolyVertex(y2, 3, xdim, GP_INFER_COORD, -zdim);
    gpSetPolyColor(y2, r, g, b);

    gpPoly *x = gpCreatePoly(4);
    gpSetPolyVertex(x, 0, xdim, -ydim, -zdim);
    gpSetPolyVertex(x, 1, xdim, -ydim, zdim);
    gpSetPolyVertex(x, 2, xdim, ydim, zdim);
    gpSetPolyVertex(x, 3, GP_INFER_COORD, ydim, -zdim);
    gpSetPolyColor(x, r/2, g/2, b/2);

    gpPoly *x2 = gpCreatePoly(4);
    gpSetPolyVertex(x2, 0, -xdim, -ydim, -zdim);
    gpSetPolyVertex(x2, 1, -xdim, -ydim, zdim);
    gpSetPolyVertex(x2, 2, -xdim, ydim, zdim);
    gpSetPolyVertex(x2, 3, GP_INFER_COORD, ydim, -zdim);
    gpSetPolyColor(x2, r/2, g/2, b/2);

    gpPolyList *cube = gpCreatePolyList();
    gpAddPolyToList(cube, z);
    gpAddPolyToList(cube, y);
    gpAddPolyToList(cube, x);
    gpAddPolyToList(cube, z2);
    gpAddPolyToList(cube, y2);
    gpAddPolyToList(cube, x2);

    return cube;
}

int main () {
    gpSetBackgroundColor(0x0, 0x7f, 0xff);
    gpEnable(GP_ZBUFFER);
    gpEnable(GP_PERSPECTIVE);
    gpSetFrustrum(1.f, 50.f);

    // Create the scene

    scene = gpCreatePolyHierarchy();

    gpPolyList *ground_list = gpCreatePolyList();

    double x = -2.f * GROUND_DIV/2;

    for (int i = 0; i < GROUND_DIV; i++, x+= 2.0f) {
        double y = -2.f * GROUND_DIV/2;
        for (int j = 0; j < GROUND_DIV; j++, y+= 2.0f) {
            gpPoly *ground = gpCreatePoly(4);
            gpSetPolyVertex(ground, 0, 1.1f, 1.1f, 0.f);
            gpSetPolyVertex(ground, 1, 1.1f, -1.1f, 0.f);
            gpSetPolyVertex(ground, 2, -1.1f, -1.1f, 0.f);
            gpSetPolyVertex(ground, 3, -1.1f, 1.1f, GP_INFER_COORD);
            gpTranslatePoly(ground, x, y, 0.f);
            gpSetPolyColor(ground, GROUND_R, GROUND_G, GROUND_B);
            gpAddPolyToList(ground_list, ground);
        }
    }

    // Define the scene from a TOP DOWN point of view
    gpPolyList *b1 = createBlock(1.0f, 1.0f, 4.0f, BUILDING_R, BUILDING_G, BUILDING_B);
    gpTranslatePolyList(b1, 0.f, 0.f, -2.f);
    gpPolyList *b2 = createBlock(1.0f, 2.0f, 3.0f, BUILDING_R, BUILDING_G, BUILDING_B);
    gpTranslatePolyList(b2, 3.f, 2.f, -1.5f);
    gpPolyList *b3 = createBlock(3.0f, 1.0f, 2.0f, BUILDING_R, BUILDING_G, BUILDING_B);
    gpTranslatePolyList(b3, -4.f, 2.f, -1.f);

    gpSetPolyHierarchyList(scene, ground_list);
    gpPolyHierarchy * scene_1 = gpCreatePolyHierarchy();
    gpPolyHierarchy * scene_2 = gpCreatePolyHierarchy();
    gpPolyHierarchy * scene_3 = gpCreatePolyHierarchy();
    gpSetPolyHierarchyList(scene_1, b1);
    gpSetPolyHierarchyList(scene_2, b2);
    gpSetPolyHierarchyList(scene_3, b3);
    gpSetPolyHierarchyChild(scene, scene_1);
    gpSetPolyHierarchyChild(scene_1, scene_2);
    gpSetPolyHierarchyChild(scene_2, scene_3);

    gpRotatePolyHierarchy(scene, pi/2, 0.f, 0.f);
    gpTranslatePolyHierarchy(scene, 0.f, -2.0f, 5.f);
    gpRenderAll(scene);
    gpCallbacks(keyboard, idle);
}
