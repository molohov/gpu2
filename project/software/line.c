#include <stdlib.h>

#include "gp.h"

/* User program */
int main()
{
    gpSetBackgroundColor(0x60, 0x00, 0xe0);

    gpPolyList *list = gpCreatePolyList();

    gpPoly *l1 = gpCreatePoly(2);
    gpSetPolyVertex(l1, 0, -.5f, -2.f, 1.f);
    gpSetPolyVertex(l1, 1, .5f, 2.f, 1.f);
    gpSetPolyColor(l1, 0x0, 0xff, 0x0);

    gpPoly *l2 = gpCreatePoly(2);
    gpSetPolyVertex(l2, 0, .5f, -2.f, 1.f);
    gpSetPolyVertex(l2, 1, -.5f, 2.f, 1.f);
    gpSetPolyColor(l2, 0x0, 0xff, 0x0);

    gpPoly *l3 = gpCreatePoly(2);
    gpSetPolyVertex(l3, 0, -1.5f, 0.f, 1.f);
    gpSetPolyVertex(l3, 1, 1.5f, 0.f, 1.f);
    gpSetPolyColor(l3, 0x0, 0xff, 0x0);

    gpPoly *l4 = gpCreatePoly(2);
    gpSetPolyVertex(l4, 0, 0.f, -2.f, 1.f);
    gpSetPolyVertex(l4, 1, 0.f, 2.f, 1.f);
    gpSetPolyColor(l4, 0x0, 0xff, 0x0);

    gpAddPolyToList(list, l1);
    gpAddPolyToList(list, l2);
    gpAddPolyToList(list, l3);
    gpAddPolyToList(list, l4);

    gpRender(list);

    // overwrite with the vertices reversed

    gpPoly *l5 = gpCreatePoly(2);
    gpSetPolyVertex(l5, 0, .5f, 2.f, 0.f);
    gpSetPolyVertex(l5, 1, -.5f, -2.f, 0.f);
    gpSetPolyColor(l5, 0xff, 0x0, 0x0);

    gpPoly *l6 = gpCreatePoly(2);
    gpSetPolyVertex(l6, 0, -.5f, 2.f, 0.f);
    gpSetPolyVertex(l6, 1, .5f, -2.f, 0.f);
    gpSetPolyColor(l6, 0xff, 0x0, 0x0);

    gpPoly *l7 = gpCreatePoly(2);
    gpSetPolyVertex(l7, 0, 1.5f, 0.f, 0.f);
    gpSetPolyVertex(l7, 1, -1.5f, 0.f, 0.f);
    gpSetPolyColor(l7, 0xff, 0x0, 0x0);

    gpPoly *l8 = gpCreatePoly(2);
    gpSetPolyVertex(l8, 0, 0.f, 2.f, 0.f);
    gpSetPolyVertex(l8, 1, 0.f, -2.f, 0.f);
    gpSetPolyColor(l8, 0xff, 0x0, 0x0);

    gpPoly *l9 = gpCreatePoly(2);
    gpSetPolyVertex(l9, 0, 2.f, .5f, 0.f);
    gpSetPolyVertex(l9, 1, -2.f, -.5f, 0.f);
    gpSetPolyColor(l9, 0xff, 0x0, 0x0);

    gpPoly *l10 = gpCreatePoly(2);
    gpSetPolyVertex(l10, 0, 2.f, -.5f, 0.f);
    gpSetPolyVertex(l10, 1, -2.f, .5f, 0.f);
    gpSetPolyColor(l10, 0xff, 0x0, 0x0);

    gpAddPolyToList(list, l5);
    gpAddPolyToList(list, l6);
    gpAddPolyToList(list, l7);
    gpAddPolyToList(list, l8);
    gpAddPolyToList(list, l9);
    gpAddPolyToList(list, l10);

    gpRender(list);

    // test a single point

    gpPoly *l11 = gpCreatePoly(1);
    gpSetPolyVertex(l11, 0, .3f, .3f, 0.f);
    gpSetPolyColor(l11, 0xff, 0xff, 0xff);

    gpAddPolyToList(list, l11);
    gpRender(list);
}
