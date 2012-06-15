/* Copyright (C) 2010-2011 Ian MacLarty */
LT_INIT_DECL(ltutil)

#define LT_TRACE ltLog("%s:%d %s", __FILE__, __LINE__, __PRETTY_FUNCTION__)

#define ltAbort() ltAbortImpl(__FILE__, __LINE__)
void ltAbortImpl(const char *file, int line);
extern void ltLog(const char *fmt, ...);
bool ltFileExists(const char *file);
void ltMkDir(const char* dir);
const char *ltHomeDir();
const char *ltAppDataDir();

// Returns an array of null separated matched paths.  The last entry is two
// null characters.  The returned array should be freed by the caller with
// delete[]. The last entry in patterns should be NULL.
char* ltGlob(const char **patterns);

static inline float ltRandBetween(float lo, float hi) {
#ifdef _WIN32
    return ((float)rand() / (float)RAND_MAX) * (hi - lo) + lo;
#else
    return ((float)random() / (float)RAND_MAX) * (hi - lo) + lo;
#endif
}

static inline float ltRandMinus1_1() {
#ifdef _WIN32
    return ((float)rand() / (float)(RAND_MAX / 2)) - 1.0f;
#else
    return ((float)random() / (float)(RAND_MAX / 2)) - 1.0f;
#endif
}

static inline float ltRand0_1() {
#ifdef _WIN32
    return ((float)rand() / (float)(RAND_MAX / 2)) - 1.0f;
#else
    return (float)random() / (float)(RAND_MAX);
#endif
}
