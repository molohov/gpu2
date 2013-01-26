#include <math.h>

#define GP_DISPLAY_TIMEOUT_IN_MS -1
#define GP_BG_COLOR (CV_RGB(0x60, 0x00, 0xe0))
#define GP_XRES 512
#define GP_YRES 512
#define GP_INFER_COORD NAN

/* Struct definitions */

//  3-d coordinate
typedef struct {
  float x, y, z;
} gpVertex3;

// RGB colour
typedef struct {
  unsigned char r, g, b;
} gpColor;

// 4x4 matrix for transformation calculations
typedef struct {
  float m[4][4];
} gpTMatrix;

// 3-d shape
typedef struct {
  gpVertex3 *vertices;
  gpVertex3 *t_vertices;
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

/* Library functions */

gpPolyList * gpCreatePolyList();
void gpAddPolyToList(gpPolyList *list, gpPoly *poly);
void gpDeletePolyList(gpPolyList *list);

gpPoly * gpCreatePoly(int num_vertices);
void gpSetPolyVertex(gpPoly *poly, int num, float x, float y, float z);
void gpSetPolyColor(gpPoly *poly, unsigned char r, unsigned char g, unsigned b);
void gpDeletePoly(gpPoly *poly);

void gpTranslatePoly(gpPoly *poly, float x, float y, float z);
void gpTranslatePolyList(gpPolyList *list, float x, float y, float z);
void gpScalePoly(gpPoly *poly, float x, float y, float z);
void gpScalePolyList(gpPolyList *list, float x, float y, float z);
void gpRotatePoly(gpPoly *poly, float yaw, float pitch, float roll);
void gpRotatePolyList(gpPolyList *list, float yaw, float pitch, float roll);

void gpRenderPoly(gpPoly *poly);
void gpRender(gpPolyList *list);
