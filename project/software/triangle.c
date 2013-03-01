#include <stdlib.h>

#include "gp.h"

int main()
{
    //use gpFixed2Vertex for now
    gpColor color = {0, 255, 0};

    gpVertex2Fixed v1 = {0, 0};
    gpVertex2Fixed v2 = {10, 600};
    gpVertex2Fixed v3 = {1000, 60};
    gpTriangle(&v1, &v2, &v3, &color);

    v1 = (gpVertex2Fixed){300, 400};
    v2 = (gpVertex2Fixed){0, 400};
    v3 = (gpVertex2Fixed){0, 0};
    gpTriangle(&v1, &v2, &v3, &color);

    return 0;
}
