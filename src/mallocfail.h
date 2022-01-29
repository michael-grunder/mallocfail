#ifndef MALLOC_FAIL_H
#define MALLOC_FAIL_H

/*
https://stackoverflow.com/questions/1711170/unit-testing-for-failed-malloc

I saw a cool solution to this problem which was presented to me by S.
Paavolainen. The idea is to override the standard malloc(), which you can do
just in the linker, by a custom allocator which

 1. reads the current execution stack of the thread calling malloc()
 2. checks if the stack exists in a database that is stored on hard disk
    1. if the stack does not exist, adds the stack to the database and returns NULL
    2. if the stack did exist already, allocates memory normally and returns

Then you just run your unit test many times---this system automatically
enumerates through different control paths to malloc() failure and is much more
efficient and reliable than e.g. random testing.

*/

#define MALLOCFAIL_MAJOR 0
#define MALLOCFAIL_MINOR 0
#define MALLOCFAIL_PATCH 1
#define MALLOCFAIL_SONAME 0.0.1

#include <stddef.h>

int should_malloc_fail(void);

void *mallocfail_malloc(size_t size);
void *mallocfail_calloc(size_t nmemb, size_t size);
void *mallocfail_realloc(void *ptr, size_t size);
char *mallocfail_strdup(const char *str);
char *mallocfail_strndup(const char *str, size_t len);

void mallocfail_set_hook(void (*mallocfail_hook)(void));

#endif
