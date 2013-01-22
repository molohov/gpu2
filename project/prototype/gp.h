#define GP_DISPLAY_TIMEOUT_IN_MS -1
#define GP_BG_COLOR (CV_RGB(0x60, 0x00, 0xe0))
#define GP_XRES 512
#define GP_YRES 512

/* Struct definitions */

//  3-d coordinate
typedef struct {
  float x, y, z;
} gpVertex3;

// RGB colour
typedef struct {
  unsigned char r, g, b;
} gpColor;

// 3-d shape
typedef struct {
  gpVertex3 *vertices;
  int num_vertices;
  gpColor color;
} gpPoly;

// 2-d fixed point for rendering and matrix ops
typedef struct {
  int x, y;
} gpVertex2Fixed;

/* Library functions */

gpPoly * gpCreatePoly(int num_vertices);
void gpSetPolyVertex(gpPoly *poly, int num, float x, float y, float z);
void gpSetPolyColor(gpPoly *poly, unsigned char r, unsigned char g, unsigned b);
void gpDeletePoly(gpPoly *poly);

void gpRender(gpPoly *poly);
