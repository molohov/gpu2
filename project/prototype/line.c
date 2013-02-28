#include <stdlib.h>

#include "gp.h"

/* User program */
int main()
{
    gpColor color = {255, 255, 0};

    //Create a y steep line
    gpVertex2Fixed v1 = {0, 0};
    gpVertex2Fixed v2 = {10, 600};
    gpLine(&v1, &v2, &color);

    //Create a x steep line
    v1 = (gpVertex2Fixed){0, 0};
    v2 = (gpVertex2Fixed){600, 60};
    gpLine(&v1, &v2, &color);

    //Create a y steep line in reverse
    v1 = (gpVertex2Fixed){0, 0};
    v2 = (gpVertex2Fixed){10, 600};
    gpLine(&v2, &v1, &color);

    //Create a x steep line in reverse
    v1 = (gpVertex2Fixed){0, 0};
    v2 = (gpVertex2Fixed){600, 60};
    gpLine(&v2, &v1, &color);
}
