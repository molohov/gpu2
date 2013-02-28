#include <stdlib.h>

#include "gp.h"

/* User program */
int main()
{
    //Create a line
    gpVertex2Fixed v1 = {0, 0};
    gpVertex2Fixed v2 = {10, 600};
    gpColor color = {255, 255, 0};
    gpLine(&v1, &v2, &color);
}
