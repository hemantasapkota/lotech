#include <stdio.h>
#include <string.h>

#if defined(LTMINGW) || defined(LTLINUX)
#define GLEW_STATIC 1
#define AL_LIBTYPE_STATIC 1
#endif

#include <GL/glew.h>
#include <GLFW/glfw3.h>

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

static void key_handler(GLFWwindow *win, int key, int scancode, int state, int mods);
static void mouse_button_handler(GLFWwindow *win, int button, int action, int mods);
static void mouse_pos_handler(GLFWwindow *win, double x, double y);
static void resize_handler(GLFWwindow *win, int w, int h);
static LTKey convert_key(int key, bool shiftkey);

static bool fullscreen = lt_fullscreen;
static void process_args(int argc, const char **argv);
static const char *dir = STR(LTDATADIR);
static const char *title = STR(LTTITLE);
static int init_window_width = 960;
static int init_window_height = 640;
static int screen_window_width;
static int screen_window_height;
static int framebuffer_width;
static int framebuffer_height;
static GLFWwindow *window = NULL;
static GLFWmonitor *monitor = NULL;

static void setup_window();
static void compute_init_window_size();

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
    compute_init_window_size();

    if (glfwInit() != GL_TRUE) {
        fprintf(stderr, "Failed to initialize glfw. Aborting.\n");
        return 1;
    }

    monitor = glfwGetPrimaryMonitor();

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
        if (glfwWindowShouldClose(window)) {
            lt_quit = true;
        }

        if (lt_fullscreen != fullscreen) {
            ltSaveState();
            ltLuaReset();
            glfwDestroyWindow(window);
            window = NULL;
            fullscreen = lt_fullscreen;
            setup_window();
        }

        ltLuaRender();
        glfwSwapBuffers(window);

#ifdef LTOSX
        // There seems to be a bug on Mac OS X where the framerate skyrockets when the
        // window is inactive.  This works around that (except that
        // it doesn't always work, because glfwGetWindowParam returns
        // incorrect results - see below).
        //
        /* if (!glfwGetWindowParam(GLFW_ACTIVE)) { */  //GLFW 2
        if (!glfwGetWindowAttrib(window, GLFW_FOCUSED)) {
            usleep(16000);
        }
#endif
        glfwPollEvents();

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

static void compute_init_window_size() {
    LTfloat w;
    LTfloat h;
    ltGetDesignScreenSize(&w, &h);
    if (h < MIN_HEIGHT) {
        LTfloat r = w / h;
        h = MIN_HEIGHT;
        w = h * r;
    }
    init_window_width = (int)w;
    init_window_height = (int)h;
}

static void setup_window() {
    if (fullscreen) {
        GLFWmonitor* monitor = glfwGetPrimaryMonitor();
        if (monitor == NULL) {
            glfwTerminate();
            fprintf(stderr, "Unable to determine primary monitor\n");
            exit(EXIT_FAILURE);
        }
        const GLFWvidmode *mode = glfwGetVideoMode(monitor);  
        if (mode == NULL) {
            glfwTerminate();
            fprintf(stderr, "Unable to retrieve primary monitor video mode\n");
            exit(EXIT_FAILURE);
        }
        window = glfwCreateWindow(mode->width, mode->height, title, monitor, NULL);
    } else {
        int w = init_window_width/SCALE;
        int h = init_window_height/SCALE;
        window = glfwCreateWindow(w, h, title, NULL, NULL);
    }
    if (window == NULL) {
        glfwTerminate();
        fprintf(stderr, "Failed to create window\n");
        exit(EXIT_FAILURE);
    }
    glfwMakeContextCurrent(window);

    glfwSwapInterval(lt_vsync ? 1 : 0);
    if (lt_show_mouse_cursor) {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
    } else {
        glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_HIDDEN);
    }

    // We need the following so glfwGetFramebufferSize
    // returns correct results.  No idea why.
    for (int i = 0; i < 5; i++) {
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        glfwSwapBuffers(window);
        usleep(100000);
    }

    glfwGetFramebufferSize(window, &framebuffer_width, &framebuffer_height);
    glfwGetWindowSize(window, &screen_window_width, &screen_window_height);
    //ltLog("fw = %d, fh = %d, sw = %d, sh = %d", framebuffer_width, framebuffer_height, screen_window_width, screen_window_height);
    ltLuaResizeWindow(framebuffer_width, framebuffer_height);
    glfwSetKeyCallback(window, key_handler);
    glfwSetMouseButtonCallback(window, mouse_button_handler);
    glfwSetCursorPosCallback(window, mouse_pos_handler);
    if (fullscreen) {
        glfwSetWindowSizeCallback(window, NULL);
    } else {
        glfwSetWindowSizeCallback(window, resize_handler);
    }
}

static void key_handler(GLFWwindow *win, int key, int scancode, int state, int mods) {
    bool shiftkey = state == GLFW_PRESS &&
                    (glfwGetKey(window, GLFW_KEY_LEFT_SHIFT) == GLFW_PRESS ||
                     glfwGetKey(window, GLFW_KEY_RIGHT_SHIFT) == GLFW_PRESS);

    LTKey ltkey = convert_key(key, shiftkey);

    if (state == GLFW_PRESS) {
        if (key == GLFW_KEY_ESCAPE
            && (glfwGetKey(window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS
            || glfwGetKey(window, GLFW_KEY_RIGHT_CONTROL) == GLFW_PRESS))
        {
            lt_quit = true;
        }
        if (key == 'F'
            && (glfwGetKey(window, GLFW_KEY_LEFT_CONTROL) == GLFW_PRESS
            || glfwGetKey(window, GLFW_KEY_RIGHT_CONTROL) == GLFW_PRESS))
        {
            lt_fullscreen = !lt_fullscreen;
        } else {
            ltLuaKeyDown(ltkey);
        }
    } else if (state == GLFW_RELEASE) {
        ltLuaKeyUp(ltkey);
    }
}

static void mouse_button_handler(GLFWwindow *win, int button, int action, int mods) {
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
    double x, y;
    glfwGetCursorPos(window, &x, &y);
    if (action == GLFW_PRESS) {
        ltLuaMouseDown(input, x, y);
    } else {
        ltLuaMouseUp(input, x, y);
    }
}

static int to_framebuf_x(double x) {
    return (x/(double)screen_window_width)*(double)framebuffer_width;
}

static int to_framebuf_y(double y) {
    return (y/(double)screen_window_height)*(double)framebuffer_height;
}

static void mouse_pos_handler(GLFWwindow *win, double x, double y) {
    ltLuaMouseMove(to_framebuf_x(x), to_framebuf_y(y));
}

static void resize_handler(GLFWwindow *win, int w, int h) {
    glfwGetFramebufferSize(win, &framebuffer_width, &framebuffer_height);
    glfwGetWindowSize(win, &screen_window_width, &screen_window_height);
    ltLuaResizeWindow(to_framebuf_x(w), to_framebuf_y(h));
}

static LTKey convert_key(int key, bool shiftkey) {

    switch(key) {
        case GLFW_KEY_TAB: return LT_KEY_TAB;
        case GLFW_KEY_ENTER: return LT_KEY_ENTER;
        case GLFW_KEY_ESCAPE: return LT_KEY_ESC;
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

        /* case GLFW_KEY_DEL: return LT_KEY_DEL; */
        case GLFW_KEY_DELETE: return LT_KEY_DEL;

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
