/* Copyright (C) 2010 Ian MacLarty */
#include "ltimage.h"

#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "png.h"

#define BBCHUNK_KEY "LTBB"
// w and h are the width and height of the original image.
// l, b, r and t are the left, bottom, right and top dimensions of the bounding box.
#define BBCHUNK_FORMAT "w%dh%dl%db%dr%dt%d"

static bool g_textures_enabled = false;
static GLuint g_current_bound_texture = 0;

void ltEnableAtlas(LTAtlas *atlas) {
    if (!g_textures_enabled) {
        glEnable(GL_TEXTURE_2D);
        g_textures_enabled = true;
    }
    if (g_current_bound_texture != atlas->texture_id) {
        glBindTexture(GL_TEXTURE_2D, atlas->texture_id);
        g_current_bound_texture = atlas->texture_id;
    }
}

void ltDisableTextures() {
    if (g_textures_enabled) {
        glDisable(GL_TEXTURE_2D);
        g_textures_enabled = false;
        g_current_bound_texture = 0;
    }
}

LTAtlas::LTAtlas(LTImagePacker *packer, const char *dump_file) {
    static int atlas_num = 1;
    char atlas_name[64];
    snprintf(atlas_name, 64, "atlas%d", atlas_num++);
    num_live_images = 0;
    LTImageBuffer *buf = ltCreateAtlasImage(atlas_name, packer);
    if (dump_file != NULL) {
        ltLog("Dumping %s (%d x %d)", dump_file, buf->bb_width(), buf->bb_height());
        ltWriteImage(dump_file, buf);
    }
    glGenTextures(1, &texture_id);
    glBindTexture(GL_TEXTURE_2D, texture_id);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR); 
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
    #ifdef IOS
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, buf->width, buf->height, 0, GL_RGBA, GL_UNSIGNED_BYTE, buf->bb_pixels);
    #else
        glTexImage2D(GL_TEXTURE_2D, 0, 4, buf->width, buf->height, 0, GL_RGBA, GL_UNSIGNED_INT_8_8_8_8, buf->bb_pixels);
    #endif
    delete buf;
}

LTAtlas::~LTAtlas() {
    glDeleteTextures(1, &texture_id);
}

LTImageBuffer::LTImageBuffer(const char *name) {
    LTImageBuffer::name = new char[strlen(name) + 1];
    strcpy(LTImageBuffer::name, name);
    is_glyph = false;
    glyph_char = '\0';
}

LTImageBuffer::~LTImageBuffer() {
    delete[] bb_pixels;
    delete[] name;
}

int LTImageBuffer::bb_width() {
    return bb_right - bb_left + 1;
}

int LTImageBuffer::bb_height() {
    return bb_top - bb_bottom + 1;
}

int LTImageBuffer::num_bb_pixels() {
    return bb_width() * bb_height();
}

static void compute_bbox(const char *path, LTpixel **rows, int w, int h,
    int *bb_left, int *bb_top, int *bb_right, int *bb_bottom)
{
    int row;
    int col;
    LTpixel pxl;
    bool row_clear = true;
    bool found_bb_top = false;
    *bb_top = h - 1;
    *bb_left = w - 1;
    *bb_right = 0;
    *bb_bottom = 0;
    for (row = 0; row < h; row++) {
        row_clear = true;
        for (col = 0; col < w; col++) {
            pxl = rows[row][col];
            if (LT_PIXEL_VISIBLE(pxl)) {
                row_clear = false;
                if (col < *bb_left) {
                    *bb_left = col;
                }
                if (col > *bb_right) {
                    *bb_right = col;
                }
            }
        }
        if (!row_clear) {
            if (!found_bb_top) {
                *bb_top = row;
                found_bb_top = true;
            }
            *bb_bottom = row;
        }
    }

    if (*bb_left > *bb_right || *bb_top > *bb_bottom) {
        fprintf(stderr, "Error: %s has no non-transparent pixels.\n", path);
        exit(1);
    }
}

LTImageBuffer *ltReadImage(const char *path, const char *name) {
    FILE *in;
    png_structp png_ptr; 
    png_infop info_ptr; 
    png_infop end_ptr; 
    png_text *text_ptr;
    unsigned char sig[8];
    bool has_alpha;
    bool has_bbchunk = false;
    int num_txt_chunks;

    png_uint_32 uwidth;
    png_uint_32 uheight;
    int width, height;
    int bit_depth;
    int color_type;

    int png_transforms;

    int bb_left, bb_top, bb_right, bb_bottom; // Only valid if has_bbchunk == false.

    png_byte **rows;

    in = fopen(path, "rb");
    if (!in) {
        fprintf(stderr, "Error: Unable to open %s for reading.\n", path);
        exit(1);
    }

    // Check for 8 byte signature.
    int n = fread(sig, 1, 8, in);
    if (n != 8) {
        fclose(in);
        ltAbort("Unable to read first 8 bytes of %s.", path);
    }
    if (!png_check_sig(sig, 8)) {
        fclose(in);
        ltAbort("%s has an invalid signature.", path);
    }
    
    png_ptr = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    info_ptr = png_create_info_struct(png_ptr);
    end_ptr = png_create_info_struct(png_ptr);

    png_init_io(png_ptr, in);
    png_set_sig_bytes(png_ptr, 8);

    // Read the data.
    #ifdef IOS
        png_transforms = PNG_TRANSFORM_STRIP_16 | PNG_TRANSFORM_PACKING |
            PNG_TRANSFORM_GRAY_TO_RGB;
        png_set_filler(png_ptr, 0xFF, PNG_FILLER_AFTER);
    #else
        png_transforms = PNG_TRANSFORM_STRIP_16 | PNG_TRANSFORM_PACKING |
            PNG_TRANSFORM_GRAY_TO_RGB | PNG_TRANSFORM_SWAP_ALPHA | PNG_TRANSFORM_BGR;
        png_set_filler(png_ptr, 0xFF, PNG_FILLER_BEFORE);
    #endif
    png_read_png(png_ptr, info_ptr, png_transforms, NULL);
    fclose(in);
    png_get_IHDR(png_ptr, info_ptr, &uwidth, &uheight, &bit_depth, &color_type,
        NULL, NULL, NULL);
    width = (int)uwidth;
    height = (int)uheight;
    if (color_type == PNG_COLOR_TYPE_RGB_ALPHA) {
        has_alpha = true;
    } else if (color_type == PNG_COLOR_TYPE_RGB) {
        has_alpha = false;
    } else {
        fprintf(stderr, "Error: %s is not RGBA or RGB.\n", path);
        exit(1);
    }
    if (bit_depth != 8) {
        fprintf(stderr, "Error: %s does not have bit depth 8.\n", path);
        exit(1);
    }
    rows = png_get_rows(png_ptr, info_ptr);

    LTImageBuffer *imgbuf = new LTImageBuffer(name);

    // Check for bounding box chunk.
    png_get_text(png_ptr, info_ptr, &text_ptr, &num_txt_chunks);
    for (int i = 0; i < num_txt_chunks; i++) {
        if (strcmp(text_ptr[i].key, BBCHUNK_KEY) == 0) {
            has_bbchunk = true;   
            sscanf(text_ptr[i].text, BBCHUNK_FORMAT,
                &imgbuf->width, &imgbuf->height,
                &imgbuf->bb_left, &imgbuf->bb_bottom, &imgbuf->bb_right, &imgbuf->bb_top);
            break;
        }
    }

    // Compute the bounding box if no bounding box chunk found.
    if (!has_bbchunk) {
        if (has_alpha) {
            compute_bbox(path, (LTpixel**)rows, width, height, &bb_left, &bb_top, &bb_right,
                &bb_bottom);
        } else {
            // No alpha, so bbox calculation trivial.
            bb_left = 0;
            bb_top = 0;
            bb_right = width - 1;
            bb_bottom = height - 1;
        }
        imgbuf->width = width;
        imgbuf->height = height;
        imgbuf->bb_left = bb_left;
        imgbuf->bb_top = height - bb_top - 1; // Normalize coordinate system.
        imgbuf->bb_right = bb_right;
        imgbuf->bb_bottom = height - bb_bottom - 1;
    }
    
    // Copy data to new LTImageBuffer.

    int num_bb_pixels = imgbuf->num_bb_pixels();
    int bb_width = imgbuf->bb_width();
    LTpixel *pixels = new LTpixel[num_bb_pixels];

    LTpixel *pxl_ptr = pixels;
    if (has_bbchunk) {
        // png contains only bounding box pixels so copy all of them.
        for (int row = height - 1; row >= 0; row--) {
            memcpy(pxl_ptr, &rows[row][0], bb_width * 4);
            pxl_ptr += bb_width;
        }
    } else {
        // Copy only the pixels in the bounding box.
        for (int row = bb_bottom; row >= bb_top; row--) {
            memcpy(pxl_ptr, &rows[row][bb_left * 4], bb_width * 4);
            pxl_ptr += bb_width;
        }
    }

    imgbuf->bb_pixels = pixels;

    // Free libpng data (including rows).
    png_destroy_read_struct(&png_ptr, &info_ptr, &end_ptr);

    return imgbuf;
}

void ltWriteImage(const char *path, LTImageBuffer *img) {
    FILE *out;
    png_structp png_ptr; 
    png_infop info_ptr; 
    png_byte **rows;
    int bb_height = img->bb_height();
    int bb_width = img->bb_width();

    // Open the file.
    out = fopen(path, "wb");
    if (!out) {
        fprintf(stderr, "Error: Unable to open %s for writing.\n", path);
        exit(1);
    }

    // Setup.
    png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
    info_ptr = png_create_info_struct(png_ptr);
    png_init_io(png_ptr, out);
    png_set_IHDR(png_ptr, info_ptr, bb_width, bb_height,
        8, PNG_COLOR_TYPE_RGB_ALPHA, PNG_INTERLACE_NONE,
        PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT);

    // Record bounding box information in a private tEXt chunk.
    png_text bbchunk;
    char bbtext[128];
    sprintf(bbtext, BBCHUNK_FORMAT, img->width, img->height,
        img->bb_left, img->bb_bottom, img->bb_right, img->bb_top);
    bbchunk.compression = PNG_TEXT_COMPRESSION_NONE;
    bbchunk.key = (char*)BBCHUNK_KEY;
    bbchunk.text = bbtext;
    bbchunk.text_length = strlen(bbtext);
    bbchunk.itxt_length = 0;
    bbchunk.lang = 0;
    bbchunk.lang_key = NULL;
    png_set_text(png_ptr, info_ptr, &bbchunk, 1);

    // Tell libpng where the data is.
    rows = new png_byte*[bb_height];
    LTpixel *pxl_ptr = img->bb_pixels;
    for (int i = bb_height - 1; i >= 0; i--) {
        rows[i] = (png_byte*)pxl_ptr;
        pxl_ptr += bb_width;
    }
    png_set_rows(png_ptr, info_ptr, rows);

    // Write image.
    png_write_png(png_ptr, info_ptr, PNG_TRANSFORM_SWAP_ALPHA | PNG_TRANSFORM_BGR, NULL);

    // Free libpng data.
    png_destroy_write_struct(&png_ptr, &info_ptr);
    delete[] rows;

    fclose(out);
}

void ltPasteImage(LTImageBuffer *src, LTImageBuffer *dest, int x, int y, bool rotate) {
    int src_width;
    int src_height;
    src_width = src->bb_width();
    src_height = src->bb_height();
    int dest_width = dest->bb_width();
    int dest_height = dest->bb_height();
    if (!rotate && (x + src_width > dest_width)) {
        ltAbort("%s too wide to be pasted into %s at x = %d.", 
            src->name, dest->name, x);
    }
    if (!rotate && (y + src_height > dest_height)) {
        ltAbort("%s too high to be pasted into %s at y = %d.",
            src->name, dest->name, y);
    }
    if (rotate && (x + src_height > dest_width)) {
        ltAbort("%s too high to be pasted into %s at x = %d after rotation.",
            src->name, dest->name, x);
    }
    if (rotate && (y + src_width > dest_height)) {
        ltAbort("%s too wide to be pasted into %s at y = %d after rotation.",
            src->name, dest->name, y);
    }

    LTpixel *dest_ptr = dest->bb_pixels + y * dest_width + x;

    if (rotate) {
        LTpixel *src_ptr = src->bb_pixels + src_width - 1;
        int src_row = 0;
        int src_col = src_width - 1;
        while (src_col >= 0) {
            *dest_ptr = *src_ptr;
            src_ptr += src_width;
            dest_ptr++;
            src_row++;
            if (src_row >= src_height) {
                src_col--;
                src_row = 0;
                dest_ptr += dest_width - src_height;
                src_ptr = src->bb_pixels + src_col;
            }
        }
    } else {
        LTpixel *src_ptr = src->bb_pixels;
        int src_row = 0;
        while (src_row < src_height) {
            memcpy(dest_ptr, src_ptr, src_width * 4);
            src_ptr += src_width;
            dest_ptr += dest_width;
            src_row++;
        }
    }
}

//-----------------------------------------------------------------

LTImagePacker::LTImagePacker(int l, int b, int w, int h) {
    left = l;
    bottom = b;
    width = w;
    height = h;
    occupant = NULL;
    rotated = false;
    hi_child = NULL;
    lo_child = NULL;
}

LTImagePacker::~LTImagePacker() {
    if (occupant != NULL) {
        delete hi_child;
        delete lo_child;
    }
}

static bool pack_image(LTImagePacker *packer, LTImageBuffer *img) {
    int pkr_w = packer->width;
    int pkr_h = packer->height;
    int img_w = img->bb_width() + 1; // add 1 pixel buffer.
    int img_h = img->bb_height() + 1;
    if (packer->occupant == NULL) {
        bool fits_rotated = img_h <= pkr_w && img_w <= pkr_h;
        bool fits_non_rotated = img_w <= pkr_w && img_h <= pkr_h;

        if (!fits_rotated && !fits_non_rotated) {
            return false;
        }

        bool should_rotate = false;
        if (!fits_non_rotated) {
            should_rotate = true;
        }

        int hi_l;
        int hi_b;
        int hi_w;
        int hi_h;
        int lo_l;
        int lo_b;
        int lo_w;
        int lo_h;

        if (should_rotate) {
            hi_l = packer->left;
            hi_b = packer->bottom + img_w;
            hi_w = pkr_w;
            hi_h = pkr_h - img_w;
            lo_l = packer->left + img_h;
            lo_b = packer->bottom;
            lo_w = pkr_w - img_h;
            lo_h = img_w;
        } else {
            hi_l = packer->left;
            hi_b = packer->bottom + img_h;
            hi_w = pkr_w;
            hi_h = pkr_h - img_h;
            lo_l = packer->left + img_w;
            lo_b = packer->bottom;
            lo_w = pkr_w - img_w;
            lo_h = img_h;
        }

        packer->occupant = img;
        packer->rotated = should_rotate;
        packer->hi_child = new LTImagePacker(hi_l, hi_b, hi_w, hi_h);
        packer->lo_child = new LTImagePacker(lo_l, lo_b, lo_w, lo_h);

        return true;
    }

    return pack_image(packer->lo_child, img) || pack_image(packer->hi_child, img);
}

static int compare_img_bufs(const void *v1, const void *v2) {
    LTImageBuffer **img1 = (LTImageBuffer **)v1;
    LTImageBuffer **img2 = (LTImageBuffer **)v2;
    int h1 = (*img1)->bb_height();
    int h2 = (*img2)->bb_height();
    if (h1 < h2) {
        return -1;
    } else if (h1 == h2) {
        return 0;
    } else {
        return 1;
    }
}

bool ltPackImage(LTImagePacker *packer, LTImageBuffer *img) {
    if (pack_image(packer, img)) {
        return true;
    } else {
        // Sort images and try again.
        int n = packer->size() + 1;
        bool fitted = true;
        LTImagePacker *test_packer = new LTImagePacker(packer->left, packer->bottom,
            packer->width, packer->height);
        LTImageBuffer **imgs = new LTImageBuffer *[n];
        packer->getImages(imgs);
        imgs[n - 1] = img;
        qsort(imgs, n, sizeof(LTImageBuffer *), compare_img_bufs);
        for (int i = n - 1; i >= 0; i--) {
            if (!pack_image(test_packer, imgs[i])) {
                fitted = false;
                break;
            }
        }
        if (fitted) {
            packer->clear();
            for (int i = n - 1; i >= 0; i--) {
                pack_image(packer, imgs[i]);
            }
        }
        delete test_packer;
        delete[] imgs;
        return fitted;
    }
}

void LTImagePacker::deleteOccupants() {
    if (occupant != NULL) {
        delete occupant;
        occupant = NULL;
        hi_child->deleteOccupants();
        lo_child->deleteOccupants();
        delete hi_child;
        hi_child = NULL;
        delete lo_child;
        lo_child = NULL;
    }
}

void LTImagePacker::clear() {
    if (occupant != NULL) {
        occupant = NULL;
        hi_child->clear();
        lo_child->clear();
        delete hi_child;
        hi_child = NULL;
        delete lo_child;
        lo_child = NULL;
    }
}

int LTImagePacker::size() {
    if (occupant != NULL) {
        return hi_child->size() + lo_child->size() + 1;
    } else {
        return 0;
    }
}

static void get_images(LTImagePacker *packer, int *i, LTImageBuffer **imgs) {
    if (packer->occupant != NULL) {
        imgs[*i] = packer->occupant;
        *i = *i + 1;
        get_images(packer->hi_child, i, imgs);
        get_images(packer->lo_child, i, imgs);
    }
}

void LTImagePacker::getImages(LTImageBuffer **imgs) {
    int i = 0;
    get_images(this, &i, imgs);
}

static void paste_packer_images(LTImageBuffer *img, LTImagePacker *packer) {
    if (packer->occupant != NULL) {
        ltPasteImage(packer->occupant, img, packer->left, packer->bottom, packer->rotated);
        paste_packer_images(img, packer->lo_child);
        paste_packer_images(img, packer->hi_child);
    }
}

//-----------------------------------------------------------------

LTImageBuffer *ltCreateAtlasImage(const char *name, LTImagePacker *packer) {
    int num_pixels = packer->width * packer->height;
    LTImageBuffer *atlas = new LTImageBuffer(name);
    atlas->width = packer->width;
    atlas->height = packer->height;
    atlas->bb_left = 0;
    atlas->bb_right = packer->width - 1;
    atlas->bb_top = packer->height - 1;
    atlas->bb_bottom = 0;
    atlas->bb_pixels = new LTpixel[num_pixels];
    memset(atlas->bb_pixels, 0x00, num_pixels * 4);
    paste_packer_images(atlas, packer);
    return atlas;
}

//-----------------------------------------------------------------

LTImage::LTImage(LTAtlas *atls, int atlas_w, int atlas_h, LTImagePacker *packer) : LTSceneNode(LT_TYPE_IMAGE) {
    if (packer->occupant == NULL) {
        ltAbort("Packer occupant is NULL.");
    }

    atlas = atls;
    atlas->num_live_images++;
    rotated = packer->rotated;

    LTfloat fatlas_w = (LTfloat)atlas_w;
    LTfloat fatlas_h = (LTfloat)atlas_h;

    tex_left = (LTfloat)packer->left / fatlas_w;
    tex_bottom = (LTfloat)packer->bottom / fatlas_h;

    bb_left = (LTfloat)packer->occupant->bb_left / fatlas_w;
    bb_bottom = (LTfloat)packer->occupant->bb_bottom / fatlas_h;
    bb_width = (LTfloat)packer->occupant->bb_width() / fatlas_w;
    bb_height = (LTfloat)packer->occupant->bb_height() / fatlas_h;
    orig_width = (LTfloat)packer->occupant->width / fatlas_w;
    orig_height = (LTfloat)packer->occupant->height / fatlas_h;
    pixel_width = packer->occupant->width;
    pixel_height = packer->occupant->height;

    glGenBuffers(1, &vertbuf);
    glBindBuffer(GL_ARRAY_BUFFER, vertbuf);
    setAnchor(LT_ANCHOR_CENTER);

    GLfloat tex_coords[8];
    if (rotated) {
        tex_coords[0] = tex_left + bb_height;   tex_coords[1] = tex_bottom + bb_width;
        tex_coords[2] = tex_left + bb_height;   tex_coords[3] = tex_bottom;
        tex_coords[4] = tex_left;               tex_coords[5] = tex_bottom;
        tex_coords[6] = tex_left;               tex_coords[7] = tex_bottom + bb_width;
    } else {
        tex_coords[0] = tex_left;               tex_coords[1] = tex_bottom + bb_height;
        tex_coords[2] = tex_left + bb_width;    tex_coords[3] = tex_bottom + bb_height;
        tex_coords[4] = tex_left + bb_width;    tex_coords[5] = tex_bottom;
        tex_coords[6] = tex_left;               tex_coords[7] = tex_bottom;
    }
    glGenBuffers(1, &texbuf);
    glBindBuffer(GL_ARRAY_BUFFER, texbuf);
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 8, tex_coords, GL_STATIC_DRAW);
}

LTImage::~LTImage() {
    glDeleteBuffers(1, &vertbuf);
    glDeleteBuffers(1, &texbuf);
    atlas->num_live_images--;
    if (atlas->num_live_images <= 0) {
        delete atlas;
    }
}

void LTImage::draw() {
    ltEnableAtlas(atlas);
    glBindBuffer(GL_ARRAY_BUFFER, vertbuf);
    glVertexPointer(2, GL_FLOAT, 0, 0);
    glBindBuffer(GL_ARRAY_BUFFER, texbuf);
    glTexCoordPointer(2, GL_FLOAT, 0, 0);
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

LTfloat* LTImage::field_ptr(const char *field_name) {
    if (strcmp(field_name, "w") == 0) {
        return &orig_width;
    }
    if (strcmp(field_name, "h") == 0) {
        return &orig_height;
    }
    return NULL;
}

void LTImage::setAnchor(LTAnchor anchor) {
    LTfloat l = 0.0f;
    LTfloat b = 0.0f;
    switch (anchor) {
        case LT_ANCHOR_CENTER: {
            l = bb_left - orig_width * 0.5f;
            b = bb_bottom - orig_height * 0.5f;
            break;
        }
        case LT_ANCHOR_BOTTOM_LEFT: {
            l = bb_left;
            b = bb_bottom;
            break;
        }
    }
    LTfloat t = b + bb_height;
    LTfloat r = l + bb_width;
    GLfloat v[] = {
        l, t,
        r, t,
        r, b,
        l, b
    };
    glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat) * 8, v, GL_STATIC_DRAW);
}