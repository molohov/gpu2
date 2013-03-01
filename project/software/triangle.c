#include <stdlib.h>

#include "gp.h"

int main()
{
    //use gpFixed2Vertex for now
    gpColor color = {0, 255, 0};

    gpVertex2Fixed v1[3] = {{0, 0}, {10, 600}, {1000, 60}};
    gpRenderConvexPoly(v1, 3, &color);

    gpVertex2Fixed v2[3] = {{300, 400}, {0, 400}, {0, 0}};
    gpRenderConvexPoly(v2, 3, &color);

    gpVertex2Fixed v3[4] = {{300, 400}, {10, 400}, {10, 10}, {300, 30}};
    gpRenderConvexPoly(v3, 4, &color);

    return 0;
}
