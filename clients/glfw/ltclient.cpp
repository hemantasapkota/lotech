#include <stdio.h>
#include <string.h>

#if defined(LTMINGW) || defined(LTLINUX)
#define GLEW_STATIC 1
#define AL_LIBTYPE_STATIC 1
#endif

#include <GL/glew.h>
#include <GL/glfw.h>

#include "lt.h"

#define SCALE 1
#define MIN_HEIGHT 640
#define MIN_UPDATE_TIME (1.0/400.0)

#ifndef LTDATADIR
#ifdef LTOSX
#define LTDATADIR
#else
#define LTDATADIR data
#endif
#endif

#ifndef LTTITLE
#define LTTITLE Lotech Client
#endif

static void key_handler(int key, int state);
static void mouse_button_handler(int button, int action);
static void mouse_pos_handler(int x, int y);
static void resize_handler(int w, int h);
static LTKey convert_key(int key, bool shiftkey);
static bool fullscreen = lt_fullscreen;
static void process_args(int argc, const char **argv);
static const char *dir = STR(LTDATADIR);
static const char *title = STR(LTTITLE);
static int window_width = 960;
static int window_height = 640;

static void setup_window();
static void compute_window_size();

int main(int argc, const char **argv) {

#ifdef LTOSX
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
#endif

    process_args(argc, argv);

#ifdef LTDEVMODE
    ltClientInit();
#endif

    ltSetResourcePrefix(dir);
    ltLuaSetup();
    fullscreen = lt_fullscreen;
    compute_window_size();

    if (glfwInit() != GL_TRUE) {
        fprintf(stderr, "Failed to initialize glfw. Aborting.\n");
        return 1;
    }

    setup_window();

    GLenum err = glewInit();
    if (GLEW_OK != err)
    {
        fprintf(stderr, "Error: %s\n", glewGetErrorString(err));
        return 1;
    }

    if (!GLEW_VERSION_1_5)
    {
        fprintf(stderr, "Sorry, OpenGL 1.5 is required.\n");
        return 1;
    }

    bool first_time = true;
    double t0 = glfwGetTime();
    double t = t0;
    double t_debt = 0.0;
    double fps_t0 = 0.0;
    double fps_max = 0.0;
    double dt;
    long long frame_count = 0;

    while (!lt_quit) {
        if (!glfwGetWindowParam(GLFW_OPENED)) {
            lt_quit = true;
        }

        if (lt_fullscreen != fullscreen) {
            ltSaveState();
            ltLuaReset();
            glfwCloseWindow();
            fullscreen = lt_fullscreen;
            setup_window();
        }

        ltLuaRender();
        glfwSwapBuffers();

#ifdef LTOSX
        // There seems to be a bug on Mac OS X where the framerate skyrockets when the
        // window is inactive.  This works around that (except that
        // it doesn't always work, because glfwGetWindowParam returns
        // incorrect results - see below).
        if (!glfwGetWindowParam(GLFW_ACTIVE)) {
            usleep(16000);
        }
#endif

        t = glfwGetTime();
        dt = fmin(1.0/15.0, t - t0); // fmin in case process was suspended, or last frame took very long
        t_debt += dt;

        if (lt_fixed_update_time > 0.0) {
            while (t_debt > 0.0) {
                ltLuaAdvance(lt_fixed_update_time);
                t_debt -= lt_fixed_update_time;
            }
        } else {
            if (t_debt > MIN_UPDATE_TIME) {
                ltLuaAdvance(t_debt);
                t_debt = 0.0;
            }
        }

#ifdef LTOSX
        // Sleep for a bit to try and avoid the skyrocketing framerate
        // problem described above.
        if (dt < 1.0/120.0) {
            useconds_t sleep_time = (int)((1.0/60.0 - dt) * 100000.0);
            //fprintf(stderr, "sleeping for %d\n", sleep_time);
            usleep(sleep_time);
        }
#endif

        fps_max = fmax(fps_max, dt);
        t0 = t;

        frame_count++;

#ifdef FPS
        if (t - fps_t0 >= 2.0) {
            double fps = (double)frame_count / (t - fps_t0);
            ltLog("%0.02ffps (%0.003fs max) | %6d objs %4d actions", fps, fps_max, ltNumLiveObjects(), ltNumScheduledActions());
            fps_t0 = t0;
            fps_max = 0.0;
            frame_count = 0;
        }
#endif

#ifdef LTDEVMODE
        ltClientStep();
#endif
    }

    ltSaveState();
    ltLuaTeardown();
    if (ltNumLiveObjects() != 0) {
        fprintf(stderr, "ERROR: num live objects not zero (%d in fact)\n", ltNumLiveObjects());
    }
    glfwTerminate();

#ifdef LTOSX
    [pool release];
#endif

    return 0;
}

static void compute_window_size() {
    LTfloat w;
    LTfloat h;
    ltGetDesignScreenSize(&w, &h);
    if (h < MIN_HEIGHT) {
        LTfloat r = w / h;
        h = MIN_HEIGHT;
        w = h * r;
    }
    window_width = (int)w;
    window_height = (int)h;
}

static void setup_window() {
    int w = window_width/SCALE;
    int h = window_height/SCALE;
    GLFWvidmode vidmode;
    int screen_mode = GLFW_WINDOW;
    if (fullscreen) {
        screen_mode = GLFW_FULLSCREEN;
    }

    glfwGetDesktopMode(&vidmode);
    if (!fullscreen) {
        vidmode.Width = w;
        vidmode.Height = h;
    }
    //glfwOpenWindowHint(GLFW_OPENGL_PROFILE, 0);
    if (!glfwOpenWindow(vidmode.Width, vidmode.Height, vidmode.RedBits, vidmode.GreenBits, vidmode.BlueBits, 0, 24, 0, screen_mode)) {
        glfwTerminate();
        fprintf(stderr, "Failed to create window\n");
        exit(EXIT_FAILURE);
    }
    glfwSwapInterval(lt_vsync ? 1 : 0);
    glfwSetWindowTitle(title);
    if (lt_show_mouse_cursor) {
        glfwEnable(GLFW_MOUSE_CURSOR);
    } else {
        glfwDisable(GLFW_MOUSE_CURSOR);
    }

    // We need the following so glfwGetWindowSize
    // returns correct results.  No idea why.
    for (int i = 0; i < 5; i++) {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glfwSwapBuffers();
        usleep(100000);
    }

    glfwGetWindowSize(&w, &h);
    //ltLog("w = %d, h = %d", w, h);
    ltLuaResizeWindow(w, h);
    glfwSetKeyCallback(key_handler);
    glfwSetMouseButtonCallback(mouse_button_handler);
    glfwSetMousePosCallback(mouse_pos_handler);
    if (fullscreen) {
        glfwSetWindowSizeCallback(NULL);
    } else {
        glfwSetWindowSizeCallback(resize_handler);
    }
}

static void key_handler(int key, int state) {
    bool shiftkey = state == GLFW_PRESS &&
                    (glfwGetKey(GLFW_KEY_LSHIFT) == GLFW_PRESS ||
                     glfwGetKey(GLFW_KEY_RSHIFT) == GLFW_PRESS);

    LTKey ltkey = convert_key(key, shiftkey);
    if (state == GLFW_PRESS) {
        if (key == GLFW_KEY_ESC
            && (glfwGetKey(GLFW_KEY_LCTRL) == GLFW_PRESS
            || glfwGetKey(GLFW_KEY_RCTRL) == GLFW_PRESS))
        {
            lt_quit = true;
        }
        if (key == 'F'
            && (glfwGetKey(GLFW_KEY_LCTRL) == GLFW_PRESS
            || glfwGetKey(GLFW_KEY_RCTRL) == GLFW_PRESS))
        {
            lt_fullscreen = !lt_fullscreen;
        } else {
            ltLuaKeyDown(ltkey);
        }
    } else if (state == GLFW_RELEASE) {
        ltLuaKeyUp(ltkey);
    }
}

static void mouse_button_handler(int button, int action) {
    int input = 0;
    switch (button) {
        case GLFW_MOUSE_BUTTON_1: input = 1; break;
        case GLFW_MOUSE_BUTTON_2: input = 2; break;
        case GLFW_MOUSE_BUTTON_3: input = 3; break;
        case GLFW_MOUSE_BUTTON_4: input = 4; break;
        case GLFW_MOUSE_BUTTON_5: input = 5; break;
        case GLFW_MOUSE_BUTTON_6: input = 6; break;
        case GLFW_MOUSE_BUTTON_7: input = 7; break;
        case GLFW_MOUSE_BUTTON_8: input = 8; break;
    }
    int x, y;
    glfwGetMousePos(&x, &y);
    if (action == GLFW_PRESS) {
        ltLuaMouseDown(input, x, y);
    } else {
        ltLuaMouseUp(input, x, y);
    }
}

static void mouse_pos_handler(int x, int y) {
    ltLuaMouseMove(x, y);
}

static void resize_handler(int w, int h) {
    ltLuaResizeWindow(w, h);
}

static LTKey convert_key(int key, bool shiftkey) {

    switch(key) {
        case GLFW_KEY_TAB: return LT_KEY_TAB;
        case GLFW_KEY_ENTER: return LT_KEY_ENTER;
        case GLFW_KEY_ESC: return LT_KEY_ESC;
        case GLFW_KEY_SPACE: return LT_KEY_SPACE;
        case '\'':
          if (shiftkey) return LT_KEY_QUOTES; return LT_KEY_APOS;
        case '=':
          if (shiftkey) return LT_KEY_PLUS;   return LT_KEY_EQUALS;
        case ',':
          if (shiftkey) return LT_KEY_LEFT_ANGLE; return LT_KEY_COMMA;
        case '-':
          if (shiftkey) return LT_KEY_UNDERSCORE; return LT_KEY_MINUS;
        case '.':
          if (shiftkey) return LT_KEY_RIGHT_ANGLE; return LT_KEY_PERIOD;
        case '/':
          if (shiftkey) return LT_KEY_QUESTION; return LT_KEY_SLASH;
        case '0':
          if (shiftkey) return LT_KEY_RIGHT_ROUND_BRACKET; return LT_KEY_0;
        case '1':
          if (shiftkey) return LT_KEY_EXCLAMATION; return LT_KEY_1;
        case '2':
          if (shiftkey) return LT_KEY_ATRATE; return LT_KEY_2;
        case '3':
          if (shiftkey) return LT_KEY_HASH; return LT_KEY_3;
        case '4':
          if (shiftkey) return LT_KEY_DOLLAR; return LT_KEY_4;
        case '5':
          if (shiftkey) return LT_KEY_PERCENT; return LT_KEY_5;
        case '6':
          if (shiftkey) return LT_KEY_CARET; return LT_KEY_6;
        case '7':
          if (shiftkey) return LT_KEY_AMPERSAND; return LT_KEY_7;
        case '8':
          if (shiftkey) return LT_KEY_ASTERISK; return LT_KEY_8;
        case '9':
          if (shiftkey) return LT_KEY_LEFT_ROUND_BRACKET; return LT_KEY_9;
        case ';':
          if (shiftkey) return LT_KEY_COLON; return LT_KEY_SEMI_COLON;
        case '[':
          if (shiftkey) return LT_KEY_LEFT_CURLY; return LT_KEY_LEFT_BRACKET;
        case '\\':
          if (shiftkey) return LT_KEY_PIPE; return LT_KEY_BACKSLASH;
        case ']':
          if (shiftkey) return LT_KEY_RIGHT_CURLY; return LT_KEY_RIGHT_BRACKET;
        case '`':
          if (shiftkey) return LT_KEY_TILDE; return LT_KEY_TICK;


        case 'A':
          if (shiftkey) return LT_KEY_A; return LT_KEY_a;
        case 'B':
          if (shiftkey) return LT_KEY_B; return LT_KEY_b;
        case 'C':
          if (shiftkey) return LT_KEY_C; return LT_KEY_c;
        case 'D':
          if (shiftkey) return LT_KEY_D; return LT_KEY_d;
        case 'E':
          if (shiftkey) return LT_KEY_E; return LT_KEY_e;
        case 'F':
          if (shiftkey) return LT_KEY_F; return LT_KEY_f;
        case 'G':
          if (shiftkey) return LT_KEY_G; return LT_KEY_g;
        case 'H':
          if (shiftkey) return LT_KEY_H; return LT_KEY_h;
        case 'I':
          if (shiftkey) return LT_KEY_I; return LT_KEY_i;
        case 'J':
          if (shiftkey) return LT_KEY_J; return LT_KEY_j;
        case 'K':
          if (shiftkey) return LT_KEY_K; return LT_KEY_k;
        case 'L':
          if (shiftkey) return LT_KEY_L; return LT_KEY_l;
        case 'M':
          if (shiftkey) return LT_KEY_M; return LT_KEY_m;
        case 'N':
          if (shiftkey) return LT_KEY_N; return LT_KEY_n;
        case 'O':
          if (shiftkey) return LT_KEY_O; return LT_KEY_o;
        case 'P':
          if (shiftkey) return LT_KEY_P; return LT_KEY_p;
        case 'Q':
          if (shiftkey) return LT_KEY_Q; return LT_KEY_q;
        case 'R':
          if (shiftkey) return LT_KEY_R; return LT_KEY_r;
        case 'S':
          if (shiftkey) return LT_KEY_S; return LT_KEY_s;
        case 'T':
          if (shiftkey) return LT_KEY_T; return LT_KEY_t;
        case 'U':
          if (shiftkey) return LT_KEY_U; return LT_KEY_u;
        case 'V':
           if (shiftkey) return LT_KEY_V; return LT_KEY_v;
        case 'W':
          if (shiftkey) return LT_KEY_W; return LT_KEY_w;
        case 'X':
          if (shiftkey) return LT_KEY_X; return LT_KEY_x;
        case 'Y':
          if (shiftkey) return LT_KEY_B; return LT_KEY_y;
        case 'Z':
          if (shiftkey) return LT_KEY_Z; return LT_KEY_z;

        case GLFW_KEY_DEL: return LT_KEY_DEL;
        case GLFW_KEY_BACKSPACE: return LT_KEY_DEL;
        case GLFW_KEY_UP: return LT_KEY_UP;
        case GLFW_KEY_DOWN: return LT_KEY_DOWN;
        case GLFW_KEY_RIGHT: return LT_KEY_RIGHT;
        case GLFW_KEY_LEFT: return LT_KEY_LEFT;
    }

    return LT_KEY_UNKNOWN;
}

static void process_args(int argc, const char **argv) {
    bool in_osx_bundle = false;
#ifdef LTOSX
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    in_osx_bundle = (bundleIdentifier != nil);
#endif
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "-fullscreen") == 0) {
            fullscreen = true;
            lt_fullscreen = true;
        } else if (!in_osx_bundle) {
            // Do not set dir if in an OSX bundle as extra argument may
            // be sent to the executable in that case.
            dir = argv[i];
        }
    }
}
