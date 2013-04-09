#include "gp.h"

#include <math.h>
#include <stdlib.h>

gpPolyList *polys = NULL;
gpPolyHierarchy *scene = NULL;
gpPolyHierarchy *scene_1 = NULL;
// Color constants for the scene
int GROUND_R = 0x10;
int GROUND_G = 0x7f;
int GROUND_B = 0x10;
int BUILDING_R = 0x10;
int BUILDING_G = 0x10;
int BUILDING_B = 0x10;
// Floating point constants for traversal and math
double pi = 3.14159;
double ROT_SPEED = 0.05f;
double FLIGHT_SPEED = 0.01f;
int dir = -1;

void idle()
{
    gpTranslatePolyHierarchy(scene, 0.f, 0.f, dir*FLIGHT_SPEED);
    gpRenderAll(scene);
}

bool keyboard(int c)
{
    switch (c) {
        case 'j':
            gpRotatePolyHierarchy(scene, 0.0f, 0.0f, 0.1f);
            break;
        case 'k':
            gpRotatePolyHierarchy(scene, 0.0f, 0.0f, -0.1f);
            break;
        case 'r':
            dir = -1;
            break;
        case 'e':
            dir = 1;
            break;
        case 'w':
            gpRotatePolyHierarchy(scene, ROT_SPEED, 0.f, 0.f);
            break;
        case 's':
            gpRotatePolyHierarchy(scene, -ROT_SPEED, 0.f, 0.f);
            break;
        case 'a':
            gpRotatePolyHierarchy(scene, 0.f, ROT_SPEED, 0.f);
            break;
        case 'd':
            gpRotatePolyHierarchy(scene, 0.f, -ROT_SPEED, 0.f);
            break;
        case 'q':
            return true;
        default:
            return false;
    }

    gpRenderAll(scene);
    return false;
}

gpPolyList *createCube(double xin, double yin, double zin)
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
    gpSetPolyColor(z, BUILDING_R, BUILDING_G, BUILDING_B);

    gpPoly *z2 = gpCreatePoly(4);
    gpSetPolyVertex(z2, 0, -xdim, -ydim, zdim);
    gpSetPolyVertex(z2, 1, -xdim, ydim, zdim);
    gpSetPolyVertex(z2, 2, xdim, ydim, zdim);
    gpSetPolyVertex(z2, 3, xdim, -ydim, GP_INFER_COORD);
    gpSetPolyColor(z2, BUILDING_R, BUILDING_G, BUILDING_B);

    gpPoly *y = gpCreatePoly(4);
    gpSetPolyVertex(y, 0, -xdim, ydim, -zdim);
    gpSetPolyVertex(y, 1, -xdim, ydim, zdim);
    gpSetPolyVertex(y, 2, xdim, ydim, zdim);
    gpSetPolyVertex(y, 3, xdim, GP_INFER_COORD, -zdim);
    gpSetPolyColor(y, BUILDING_R, BUILDING_G, BUILDING_B);

    gpPoly *y2 = gpCreatePoly(4);
    gpSetPolyVertex(y2, 0, -xdim, -ydim, -zdim);
    gpSetPolyVertex(y2, 1, -xdim, -ydim, zdim);
    gpSetPolyVertex(y2, 2, xdim, -ydim, zdim);
    gpSetPolyVertex(y2, 3, xdim, GP_INFER_COORD, -zdim);
    gpSetPolyColor(y2, BUILDING_R, BUILDING_G, BUILDING_B);

    gpPoly *x = gpCreatePoly(4);
    gpSetPolyVertex(x, 0, xdim, -ydim, -zdim);
    gpSetPolyVertex(x, 1, xdim, -ydim, zdim);
    gpSetPolyVertex(x, 2, xdim, ydim, zdim);
    gpSetPolyVertex(x, 3, GP_INFER_COORD, ydim, -zdim);
    gpSetPolyColor(x, BUILDING_R, BUILDING_G, BUILDING_B);

    gpPoly *x2 = gpCreatePoly(4);
    gpSetPolyVertex(x2, 0, -xdim, -ydim, -zdim);
    gpSetPolyVertex(x2, 1, -xdim, -ydim, zdim);
    gpSetPolyVertex(x2, 2, -xdim, ydim, zdim);
    gpSetPolyVertex(x2, 3, GP_INFER_COORD, ydim, -zdim);
    gpSetPolyColor(x2, BUILDING_R, BUILDING_G, BUILDING_B);

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

    polys = gpCreatePolyList();
    scene = gpCreatePolyHierarchy();
    scene_1 = gpCreatePolyHierarchy();

    gpPoly *ground = gpCreatePoly(4);
    gpSetPolyVertex(ground, 0, 4.f, 4.f, 0.f);
    gpSetPolyVertex(ground, 1, 4.f, -4.f, 0.f);
    gpSetPolyVertex(ground, 2, -4.f, -4.f, 0.f);
    gpSetPolyVertex(ground, 3, -4.f, 4.f, GP_INFER_COORD);
    gpSetPolyColor(ground, GROUND_R, GROUND_G, GROUND_B);


    // Define the scene from a TOP DOWN point of view
    gpPolyList *b1 = createCube(1.0f, 1.0f, 4.0f);
    gpTranslatePolyList(b1, 0.f, 0.f, -2.f);

    gpAddPolyToList(polys, ground);
    gpSetPolyHierarchyList(scene, polys);
    gpSetPolyHierarchyList(scene_1, b1);
    gpSetPolyHierarchyChild(scene, scene_1);

    gpRotatePolyHierarchy(scene, pi/2, 0.f, 0.f);
    gpTranslatePolyHierarchy(scene, 0.f, -2.0f, 5.f);
    gpRenderAll(scene);
    gpCallbacks(keyboard, idle);
}
