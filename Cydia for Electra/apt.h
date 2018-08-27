#ifndef APT_H
#define APT_H

#include <unistd.h>

template <typename Type_>
Type_ *memrchr(Type_ *data, int value, int size) {
    for (int i = 0; i != size; ++i)
        if (data[size - i - 1] == value)
            return data + size - i - 1;
    return 0;
}

template <typename Type_>
static Type_ *strchrnul(Type_ *s, int c) {
    while (*s != c && *s != '\0')
        ++s;
    return s;
}

#define faccessat(arg0, arg1, arg2, arg3) \
    access(arg1, arg2)

#if 0
#include <syslog.h>
static unsigned nonce(0);
#define _trace() syslog(LOG_ERR, "_trace():%s[%u] #%u\n", __FILE__, __LINE__, ++nonce)
#endif

#endif//APT_H
