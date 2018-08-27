#undef WORDS_BIGENDIAN

#define HAVE_TIMEGM

//#cmakedefine HAVE_ZLIB
//#cmakedefine HAVE_BZ2
//#cmakedefine HAVE_LZMA
//#cmakedefine HAVE_LZ4

/* These two are used by the statvfs shim for glibc2.0 and bsd */
/* Define if we have sys/vfs.h */
//#cmakedefine HAVE_VFS_H
//#cmakedefine HAVE_STRUCT_STATFS_F_TYPE

#undef HAVE_MOUNT_H

#undef HAVE_SYS_ENDIAN_H
#define HAVE_MACHINE_ENDIAN_H

#define HAVE_PTHREAD

#undef HAVE_GETRESUID
#undef HAVE_GETRESGID
#undef HAVE_SETRESUID
#undef HAVE_SETRESGID

#undef HAVE_PTSNAME_R

#define COMMON_ARCH "iphoneos-arm"
#define PACKAGE "cydia" // XXX
#define PACKAGE_VERSION "${PACKAGE_VERSION}" // XXX
#define PACKAGE_MAIL "saurik@saurik.com"

#define CMAKE_INSTALL_FULL_BINDIR "/usr/bin"
#define STATE_DIR "/var/lib/apt"
#define CACHE_DIR "/var/cache/apt"
#define LOG_DIR "/var/log/apt"
#define CONF_DIR "/etc/apt"
#define LIBEXEC_DIR "/usr/lib/apt"
#define BIN_DIR "/usr/bin"

#define ROOT_GROUP "wheel"

#define APT_8_CLEANER_HEADERS
#define APT_9_CLEANER_HEADERS
#define APT_10_CLEANER_HEADERS

#define SHA2_UNROLL_TRANSFORM
