#ifndef SAVELOAD_H_8VFZRR65
#define SAVELOAD_H_8VFZRR65

#include <stdio.h>
#include <stdbool.h>

#include "scalar.h"
#include "script_export.h"

SCRIPT(saveload,

        typedef struct Serializer Serializer;
        typedef struct Deserializer Deserializer;

        EXPORT Serializer *serializer_open_str();
        EXPORT Serializer *serializer_open_file(const char *filename);
        EXPORT const char *serializer_get_str(Serializer *s);
        EXPORT void serializer_close(Serializer *s);

        EXPORT Deserializer *deserializer_open_str(const char *str);
        EXPORT Deserializer *deserializer_open_file(const char *filename);
        EXPORT void deserializer_close(Deserializer *s);

      )

void scalar_save(const Scalar *f, Serializer *s);
void scalar_load(Scalar *f, Deserializer *s);

void uint_save(const unsigned int *u, Serializer *s);
void uint_load(unsigned int *u, Deserializer *s);

void int_save(const int *i, Serializer *s);
void int_load(int *i, Deserializer *s);

#define enum_save(val, s) \
    do { int e__; e__ = *(val); int_save(&e__, (s)); } while (0)
#define enum_load(val, s) \
    do { int e__; int_load(&e__, (s)); *(val) = e__; } while (0)

void bool_save(const bool *b, Serializer *s);
void bool_load(bool *b, Deserializer *s);

void string_save(const char **c, Serializer *s);
void string_load(char **c, Deserializer *s); /* must free(*c) later */

#endif

