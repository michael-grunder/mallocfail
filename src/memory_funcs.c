#define _GNU_SOURCE

#include "mallocfail.h"
#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>
#include <string.h>

int force_libc = 0;
static void (*hookFn)(void);

void mallocfail_set_hook(void (*mallocfail_hook)(void)) {
    hookFn = mallocfail_hook;
}

void *mallocfail_malloc(size_t size) {
    if (force_libc || !should_malloc_fail()){
        return malloc(size);
    } else {
        if (hookFn) hookFn();
        return NULL;
    }
}


void *mallocfail_calloc(size_t nmemb, size_t size) {
    if (force_libc || !should_malloc_fail()){
        return calloc(nmemb, size);
    } else {
        if (hookFn) hookFn();
        return NULL;
    }
}


void *mallocfail_realloc(void *ptr, size_t size) {
    if (force_libc || !should_malloc_fail()) {
        return realloc(ptr, size);
    } else {
        if (hookFn) hookFn();
        return NULL;
    }
}

char *mallocfail_strndup(const char *str, size_t len) {
    char *dup;

    if (force_libc || !should_malloc_fail()) {
        dup = malloc(len + 1);
        memcpy(dup, str, len);
        dup[len] = '\0';
        return dup;
    } else {
        if (hookFn) hookFn();
        return NULL;
    }
}

char *mallocfail_strdup(const char *str) {
    return mallocfail_strndup(str, strlen(str));
}
