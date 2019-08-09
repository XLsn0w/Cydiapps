#ifndef TRY_H
#define TRY_H

#include <setjmp.h>             // setjmp, longjmp
#include <stdio.h>              // asprintf
#include <stdlib.h>             // free

#include "common.h"             // ERROR_AT

typedef struct
{
    const char  * file;
    int           line;
    const char  * func;
    char        * msg;
} frame_err_t;

typedef struct frame
{
    jmp_buf         jmp;
    frame_err_t     err;
    struct frame  * prev;
} frame_t;

extern _Thread_local frame_t *_last_frame;

#define _DO_THROW(_file, _line, _func, _msg) \
do \
{ \
    if(_last_frame == NULL) \
    { \
        ERROR_AT(_file, _line, _func, "Unhandled error: %s", _msg); \
        free(_msg); \
    } \
    else \
    { \
        _last_frame->err.file = _file; \
        _last_frame->err.line = _line; \
        _last_frame->err.func = _func; \
        _last_frame->err.msg  = _msg; \
        longjmp(_last_frame->jmp, 1); \
    } \
} while(0)

#define THROW(str, args...) \
do \
{ \
    char *msg; \
    asprintf(&msg, str, ##args); \
    _DO_THROW(__FILE__, __LINE__, __func__, msg); \
} while(0)

// Braces are "misaligned" intentionally.
// You need to combine either TRY-CATCH, TRY-RETHROW or TRY-FINALLY.
#define TRY(...) \
{ \
    frame_t _frame = \
    { \
        .err = \
        { \
            .file = NULL, \
            .line = 0, \
            .func = NULL, \
            .msg  = NULL, \
        }, \
        .prev = _last_frame, \
    }; \
    _last_frame = &_frame; \
    if(setjmp(_frame.jmp) == 0) \
    { \
        { \
            __VA_ARGS__ \
        } \
        _last_frame = _frame.prev; \
    } \
    else \
    { \
        _last_frame = _frame.prev;

#define RETHROW(...) \
        { \
            __VA_ARGS__ \
        } \
        _DO_THROW(_frame.err.file, _frame.err.line, _frame.err.func, _frame.err.msg); \
    } \
}

#define CATCH(e, ...) \
        { \
            frame_err_t *e = &_frame.err; \
            TRY \
            ({ \
                __VA_ARGS__ \
            }) \
            RETHROW \
            ({ \
                if(e->msg != NULL) \
                { \
                    free(e->msg); \
                    e->msg = NULL; \
                } \
            }) \
        } \
        if(_frame.err.msg != NULL) \
        { \
            free(_frame.err.msg); \
            _frame.err.msg = NULL; \
        } \
    } \
}

#define FINALLY(...) \
        { \
            __VA_ARGS__ \
        } \
        _DO_THROW(_frame.err.file, _frame.err.line, _frame.err.func, _frame.err.msg); \
    } \
    { \
        __VA_ARGS__ \
    } \
}

#endif
