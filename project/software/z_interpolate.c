#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

int interpolate(int x1, int x2, int z1, int z2)
{
  if (x1 > x2) {
      int tmp = x1;
      x1 = x2;
      x2 = tmp;
  }                
  
  int dx = x2 - x1;
  int dz = z2 - z1;

  int slope = 0;
  int rem = 0;
  if (dx) {
    slope = dz / dx;
    rem = abs(dz - slope * dx);
  }

  int error = (dx + 1) / 2;
  int sz = (dz > 0) ? 1 : -1;

  printf("Interpolating %d-%d, %d-%d:\n\n", x1, x2, z1, z2);

  while (1) {
    printf("(%d, %d)\n", x1, z1);
    if (x1 == x2) break;
    z1 += slope;
    error += rem;
    if (error > dx) {
      z1 += sz;
      error -= dx;
    }
    x1++;
  }

  assert(x1 == x2);
  assert(z1 == z2);
}

int main()
{
  interpolate(1, 10, 2, 207);
  interpolate(1, 10, 207, 2);
  interpolate(1, 10, 3, 2057);
  interpolate(1, 10, 2057, 3);
  interpolate(1, 10, 1, 11);
  interpolate(1, 10, 11, 1);
  interpolate(1, 10, 1, 5);
  interpolate(1, 10, 5, 1);
}
