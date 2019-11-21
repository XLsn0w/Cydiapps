#include "apt-pkg/tagfile-keys.h"
#ifdef __GNUC__
typedef uint16_t __attribute__((aligned (1))) triehash_uu16;
typedef char static_assert16[__alignof__(triehash_uu16) == 1 ? 1 : -1];
typedef uint32_t __attribute__((aligned (1))) triehash_uu32;
typedef char static_assert32[__alignof__(triehash_uu32) == 1 ? 1 : -1];
typedef uint64_t __attribute__((aligned (1))) triehash_uu64;
//\0[__alignof__(triehash_uu64) == 1 ? 1 : -1];
#if __BYTE_ORDER__ == __ORDER_LITTLE_ENDIAN__
#define onechar(c, s, l) (((uint64_t)(c)) << (s))
#else
#define onechar(c, s, l) (((uint64_t)(c)) << (l-8-s))
#endif
#if (!defined(__ARM_ARCH) || defined(__ARM_FEATURE_UNALIGNED)) && !defined(TRIE_HASH_NO_MULTI_BYTE)
#define TRIE_HASH_MULTI_BYTE
#endif
#endif /*GNUC */
#ifdef TRIE_HASH_MULTI_BYTE
static enum pkgTagSection::Key pkgTagHash3(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('t', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('a', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('g', 0, 8):
                return pkgTagSection::Key::Tag;
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash4(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('b', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('u', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('g', 0, 8):
                switch(string[3] | 0x20) {
                case 0| onechar('s', 0, 8):
                    return pkgTagSection::Key::Bugs;
                }
            }
        }
        break;
    case 0| onechar('s', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('h', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('a', 0, 8):
                switch(string[3]) {
                case 0| onechar('1', 0, 8):
                    return pkgTagSection::Key::SHA1;
                }
            }
            break;
        case 0| onechar('i', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('z', 0, 8):
                switch(string[3] | 0x20) {
                case 0| onechar('e', 0, 8):
                    return pkgTagSection::Key::Size;
                }
            }
        }
        break;
    case 0| onechar('t', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('a', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[3] | 0x20) {
                case 0| onechar('k', 0, 8):
                    return pkgTagSection::Key::Task;
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash5(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('c', 0, 32)| onechar('l', 8, 32)| onechar('a', 16, 32)| onechar('s', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('s', 0, 8):
            return pkgTagSection::Key::Class;
        }
        break;
    case 0| onechar('f', 0, 32)| onechar('i', 8, 32)| onechar('l', 16, 32)| onechar('e', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('s', 0, 8):
            return pkgTagSection::Key::Files;
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash6(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('b', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('i', 0, 32)| onechar('n', 8, 32)| onechar('a', 16, 32)| onechar('r', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('y', 0, 8):
                return pkgTagSection::Key::Binary;
            }
            break;
        case 0| onechar('r', 0, 32)| onechar('e', 8, 32)| onechar('a', 16, 32)| onechar('k', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('s', 0, 8):
                return pkgTagSection::Key::Breaks;
            }
        }
        break;
    case 0| onechar('f', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('o', 0, 32)| onechar('r', 8, 32)| onechar('m', 16, 32)| onechar('a', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('t', 0, 8):
                return pkgTagSection::Key::Format;
            }
        }
        break;
    case 0| onechar('m', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('d', 0, 8):
            switch(string[2]) {
            case 0| onechar('5', 0, 8):
                switch(string[3] | 0x20) {
                case 0| onechar('s', 0, 8):
                    switch(string[4] | 0x20) {
                    case 0| onechar('u', 0, 8):
                        switch(string[5] | 0x20) {
                        case 0| onechar('m', 0, 8):
                            return pkgTagSection::Key::MD5sum;
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('o', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('r', 0, 32)| onechar('i', 8, 32)| onechar('g', 16, 32)| onechar('i', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('n', 0, 8):
                return pkgTagSection::Key::Origin;
            }
        }
        break;
    case 0| onechar('s', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('h', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('a', 0, 8):
                switch(string[3]) {
                case 0| onechar('2', 0, 8):
                    switch(string[4]) {
                    case 0| onechar('5', 0, 8):
                        switch(string[5]) {
                        case 0| onechar('6', 0, 8):
                            return pkgTagSection::Key::SHA256;
                        }
                    }
                    break;
                case 0| onechar('5', 0, 8):
                    switch(string[4]) {
                    case 0| onechar('1', 0, 8):
                        switch(string[5]) {
                        case 0| onechar('2', 0, 8):
                            return pkgTagSection::Key::SHA512;
                        }
                    }
                }
            }
            break;
        case 0| onechar('o', 0, 8):
            switch(*((triehash_uu32*) &string[2]) | 0x20202020) {
            case 0| onechar('u', 0, 32)| onechar('r', 8, 32)| onechar('c', 16, 32)| onechar('e', 24, 32):
                return pkgTagSection::Key::Source;
            }
            break;
        case 0| onechar('t', 0, 8):
            switch(*((triehash_uu32*) &string[2]) | 0x20202020) {
            case 0| onechar('a', 0, 32)| onechar('t', 8, 32)| onechar('u', 16, 32)| onechar('s', 24, 32):
                return pkgTagSection::Key::Status;
            }
        }
        break;
    case 0| onechar('v', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('c', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[3]) {
                case 0| onechar('-', 0, 8):
                    switch(string[4] | 0x20) {
                    case 0| onechar('h', 0, 8):
                        switch(string[5] | 0x20) {
                        case 0| onechar('g', 0, 8):
                            return pkgTagSection::Key::Vcs_Hg;
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash7(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('d', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('e', 0, 32)| onechar('p', 8, 32)| onechar('e', 16, 32)| onechar('n', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('d', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('s', 0, 8):
                    return pkgTagSection::Key::Depends;
                }
            }
        }
        break;
    case 0| onechar('p', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('a', 0, 32)| onechar('c', 8, 32)| onechar('k', 16, 32)| onechar('a', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('g', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('e', 0, 8):
                    return pkgTagSection::Key::Package;
                }
            }
        }
        break;
    case 0| onechar('s', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('e', 0, 32)| onechar('c', 8, 32)| onechar('t', 16, 32)| onechar('i', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('o', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('n', 0, 8):
                    return pkgTagSection::Key::Section;
                }
            }
        }
        break;
    case 0| onechar('v', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('c', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[3]) {
                case 0| onechar('-', 0, 8):
                    switch(string[4] | 0x20) {
                    case 0| onechar('b', 0, 8):
                        switch(string[5] | 0x20) {
                        case 0| onechar('z', 0, 8):
                            switch(string[6] | 0x20) {
                            case 0| onechar('r', 0, 8):
                                return pkgTagSection::Key::Vcs_Bzr;
                            }
                        }
                        break;
                    case 0| onechar('c', 0, 8):
                        switch(string[5] | 0x20) {
                        case 0| onechar('v', 0, 8):
                            switch(string[6] | 0x20) {
                            case 0| onechar('s', 0, 8):
                                return pkgTagSection::Key::Vcs_Cvs;
                            }
                        }
                        break;
                    case 0| onechar('g', 0, 8):
                        switch(string[5] | 0x20) {
                        case 0| onechar('i', 0, 8):
                            switch(string[6] | 0x20) {
                            case 0| onechar('t', 0, 8):
                                return pkgTagSection::Key::Vcs_Git;
                            }
                        }
                        break;
                    case 0| onechar('m', 0, 8):
                        switch(string[5] | 0x20) {
                        case 0| onechar('t', 0, 8):
                            switch(string[6] | 0x20) {
                            case 0| onechar('n', 0, 8):
                                return pkgTagSection::Key::Vcs_Mtn;
                            }
                        }
                        break;
                    case 0| onechar('s', 0, 8):
                        switch(string[5] | 0x20) {
                        case 0| onechar('v', 0, 8):
                            switch(string[6] | 0x20) {
                            case 0| onechar('n', 0, 8):
                                return pkgTagSection::Key::Vcs_Svn;
                            }
                        }
                    }
                }
            }
            break;
        case 0| onechar('e', 0, 8):
            switch(*((triehash_uu32*) &string[2]) | 0x20202020) {
            case 0| onechar('r', 0, 32)| onechar('s', 8, 32)| onechar('i', 16, 32)| onechar('o', 24, 32):
                switch(string[6] | 0x20) {
                case 0| onechar('n', 0, 8):
                    return pkgTagSection::Key::Version;
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash8(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('e', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('n', 0, 32)| onechar('h', 8, 32)| onechar('a', 16, 32)| onechar('n', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('c', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('e', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        return pkgTagSection::Key::Enhances;
                    }
                }
            }
        }
        break;
    case 0| onechar('f', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('i', 0, 32)| onechar('l', 8, 32)| onechar('e', 16, 32)| onechar('n', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('a', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('m', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('e', 0, 8):
                        return pkgTagSection::Key::Filename;
                    }
                }
            }
        }
        break;
    case 0| onechar('h', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('o', 0, 32)| onechar('m', 8, 32)| onechar('e', 16, 32)| onechar('p', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('a', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('g', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('e', 0, 8):
                        return pkgTagSection::Key::Homepage;
                    }
                }
            }
        }
        break;
    case 0| onechar('o', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('p', 0, 32)| onechar('t', 8, 32)| onechar('i', 16, 32)| onechar('o', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('n', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('a', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('l', 0, 8):
                        return pkgTagSection::Key::Optional;
                    }
                }
            }
        }
        break;
    case 0| onechar('p', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('r', 0, 32)| onechar('i', 8, 32)| onechar('o', 16, 32)| onechar('r', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('i', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('t', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('y', 0, 8):
                        return pkgTagSection::Key::Priority;
                    }
                }
            }
            break;
        case 0| onechar('r', 0, 32)| onechar('o', 8, 32)| onechar('v', 16, 32)| onechar('i', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('d', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('e', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        return pkgTagSection::Key::Provides;
                    }
                }
            }
        }
        break;
    case 0| onechar('r', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('e', 0, 32)| onechar('p', 8, 32)| onechar('l', 16, 32)| onechar('a', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('c', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('e', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        return pkgTagSection::Key::Replaces;
                    }
                }
            }
            break;
        case 0| onechar('e', 0, 32)| onechar('v', 8, 32)| onechar('i', 16, 32)| onechar('s', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('i', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('o', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('n', 0, 8):
                        return pkgTagSection::Key::Revision;
                    }
                }
            }
        }
        break;
    case 0| onechar('s', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('u', 0, 32)| onechar('g', 8, 32)| onechar('g', 16, 32)| onechar('e', 24, 32):
            switch(string[5] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('t', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        return pkgTagSection::Key::Suggests;
                    }
                }
            }
        }
        break;
    case 0| onechar('v', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('c', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[3]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
                    case 0| onechar('a', 0, 32)| onechar('r', 8, 32)| onechar('c', 16, 32)| onechar('h', 24, 32):
                        return pkgTagSection::Key::Vcs_Arch;
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash9(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('c', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('o', 0, 64)| onechar('n', 8, 64)| onechar('f', 16, 64)| onechar('f', 24, 64)| onechar('i', 32, 64)| onechar('l', 40, 64)| onechar('e', 48, 64)| onechar('s', 56, 64):
            return pkgTagSection::Key::Conffiles;
            break;
        case 0| onechar('o', 0, 64)| onechar('n', 8, 64)| onechar('f', 16, 64)| onechar('l', 24, 64)| onechar('i', 32, 64)| onechar('c', 40, 64)| onechar('t', 48, 64)| onechar('s', 56, 64):
            return pkgTagSection::Key::Conflicts;
        }
        break;
    case 0| onechar('d', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('i', 0, 64)| onechar('r', 8, 64)| onechar('e', 16, 64)| onechar('c', 24, 64)| onechar('t', 32, 64)| onechar('o', 40, 64)| onechar('r', 48, 64)| onechar('y', 56, 64):
            return pkgTagSection::Key::Directory;
        }
        break;
    case 0| onechar('e', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('s', 0, 64)| onechar('s', 8, 64)| onechar('e', 16, 64)| onechar('n', 24, 64)| onechar('t', 32, 64)| onechar('i', 40, 64)| onechar('a', 48, 64)| onechar('l', 56, 64):
            return pkgTagSection::Key::Essential;
        }
        break;
    case 0| onechar('i', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('m', 0, 64)| onechar('p', 8, 64)| onechar('o', 16, 64)| onechar('r', 24, 64)| onechar('t', 32, 64)| onechar('a', 40, 64)| onechar('n', 48, 64)| onechar('t', 56, 64):
            return pkgTagSection::Key::Important;
        }
        break;
    case 0| onechar('t', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('e', 0, 64)| onechar('s', 8, 64)| onechar('t', 16, 64)| onechar('s', 24, 64)| onechar('u', 32, 64)| onechar('i', 40, 64)| onechar('t', 48, 64)| onechar('e', 56, 64):
            return pkgTagSection::Key::Testsuite;
        }
        break;
    case 0| onechar('u', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('p', 0, 64)| onechar('l', 8, 64)| onechar('o', 16, 64)| onechar('a', 24, 64)| onechar('d', 32, 64)| onechar('e', 40, 64)| onechar('r', 48, 64)| onechar('s', 56, 64):
            return pkgTagSection::Key::Uploaders;
        }
        break;
    case 0| onechar('v', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('c', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[3]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
                    case 0| onechar('d', 0, 32)| onechar('a', 8, 32)| onechar('r', 16, 32)| onechar('c', 24, 32):
                        switch(string[8] | 0x20) {
                        case 0| onechar('s', 0, 8):
                            return pkgTagSection::Key::Vcs_Darcs;
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash10(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('m', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('a', 0, 32)| onechar('i', 8, 32)| onechar('n', 16, 32)| onechar('t', 24, 32):
            switch(*((triehash_uu32*) &string[5]) | 0x20202020) {
            case 0| onechar('a', 0, 32)| onechar('i', 8, 32)| onechar('n', 16, 32)| onechar('e', 24, 32):
                switch(string[9] | 0x20) {
                case 0| onechar('r', 0, 8):
                    return pkgTagSection::Key::Maintainer;
                }
            }
            break;
        case 0| onechar('u', 0, 32)| onechar('l', 8, 32)| onechar('t', 16, 32)| onechar('i', 24, 32):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[6]) | 0x20202020) {
                case 0| onechar('a', 0, 32)| onechar('r', 8, 32)| onechar('c', 16, 32)| onechar('h', 24, 32):
                    return pkgTagSection::Key::Multi_Arch;
                }
            }
        }
        break;
    case 0| onechar('r', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('e', 0, 64)| onechar('c', 8, 64)| onechar('o', 16, 64)| onechar('m', 24, 64)| onechar('m', 32, 64)| onechar('e', 40, 64)| onechar('n', 48, 64)| onechar('d', 56, 64):
            switch(string[9] | 0x20) {
            case 0| onechar('s', 0, 8):
                return pkgTagSection::Key::Recommends;
            }
        }
        break;
    case 0| onechar('v', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('c', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[3]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
                    case 0| onechar('b', 0, 32)| onechar('r', 8, 32)| onechar('o', 16, 32)| onechar('w', 24, 32):
                        switch(string[8] | 0x20) {
                        case 0| onechar('s', 0, 8):
                            switch(string[9] | 0x20) {
                            case 0| onechar('e', 0, 8):
                                return pkgTagSection::Key::Vcs_Browse;
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash11(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('b', 0, 8):
        switch(*((triehash_uu32*) &string[1]) | 0x20202020) {
        case 0| onechar('u', 0, 32)| onechar('i', 8, 32)| onechar('l', 16, 32)| onechar('t', 24, 32):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[6]) | 0x20202020) {
                case 0| onechar('u', 0, 32)| onechar('s', 8, 32)| onechar('i', 16, 32)| onechar('n', 24, 32):
                    switch(string[10] | 0x20) {
                    case 0| onechar('g', 0, 8):
                        return pkgTagSection::Key::Built_Using;
                    }
                }
            }
        }
        break;
    case 0| onechar('d', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('e', 0, 64)| onechar('s', 8, 64)| onechar('c', 16, 64)| onechar('r', 24, 64)| onechar('i', 32, 64)| onechar('p', 40, 64)| onechar('t', 48, 64)| onechar('i', 56, 64):
            switch(string[9] | 0x20) {
            case 0| onechar('o', 0, 8):
                switch(string[10] | 0x20) {
                case 0| onechar('n', 0, 8):
                    return pkgTagSection::Key::Description;
                }
            }
        }
        break;
    case 0| onechar('p', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('r', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('e', 0, 8):
                switch(string[3]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
                    case 0| onechar('d', 0, 32)| onechar('e', 8, 32)| onechar('p', 16, 32)| onechar('e', 24, 32):
                        switch(string[8] | 0x20) {
                        case 0| onechar('n', 0, 8):
                            switch(string[9] | 0x20) {
                            case 0| onechar('d', 0, 8):
                                switch(string[10] | 0x20) {
                                case 0| onechar('s', 0, 8):
                                    return pkgTagSection::Key::Pre_Depends;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('r', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('e', 0, 64)| onechar('c', 8, 64)| onechar('o', 16, 64)| onechar('m', 24, 64)| onechar('m', 32, 64)| onechar('e', 40, 64)| onechar('n', 48, 64)| onechar('d', 56, 64):
            switch(string[9] | 0x20) {
            case 0| onechar('e', 0, 8):
                switch(string[10] | 0x20) {
                case 0| onechar('d', 0, 8):
                    return pkgTagSection::Key::Recommended;
                }
            }
        }
        break;
    case 0| onechar('v', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('c', 0, 8):
            switch(string[2] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[3]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
                    case 0| onechar('b', 0, 32)| onechar('r', 8, 32)| onechar('o', 16, 32)| onechar('w', 24, 32):
                        switch(string[8] | 0x20) {
                        case 0| onechar('s', 0, 8):
                            switch(string[9] | 0x20) {
                            case 0| onechar('e', 0, 8):
                                switch(string[10] | 0x20) {
                                case 0| onechar('r', 0, 8):
                                    return pkgTagSection::Key::Vcs_Browser;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash12(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('a', 0, 32)| onechar('r', 8, 32)| onechar('c', 16, 32)| onechar('h', 24, 32):
        switch(*((triehash_uu64*) &string[4]) | 0x2020202020202020) {
        case 0| onechar('i', 0, 64)| onechar('t', 8, 64)| onechar('e', 16, 64)| onechar('c', 24, 64)| onechar('t', 32, 64)| onechar('u', 40, 64)| onechar('r', 48, 64)| onechar('e', 56, 64):
            return pkgTagSection::Key::Architecture;
        }
        break;
    case 0| onechar('p', 0, 32)| onechar('a', 8, 32)| onechar('c', 16, 32)| onechar('k', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('a', 0, 8):
            switch(string[5] | 0x20) {
            case 0| onechar('g', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('e', 0, 8):
                    switch(string[7]) {
                    case 0| onechar('-', 0, 8):
                        switch(*((triehash_uu32*) &string[8]) | 0x20202020) {
                        case 0| onechar('l', 0, 32)| onechar('i', 8, 32)| onechar('s', 16, 32)| onechar('t', 24, 32):
                            return pkgTagSection::Key::Package_List;
                            break;
                        case 0| onechar('t', 0, 32)| onechar('y', 8, 32)| onechar('p', 16, 32)| onechar('e', 24, 32):
                            return pkgTagSection::Key::Package_Type;
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash13(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('b', 0, 32)| onechar('u', 8, 32)| onechar('i', 16, 32)| onechar('l', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('d', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[6]) | 0x20202020) {
                case 0| onechar('d', 0, 32)| onechar('e', 8, 32)| onechar('p', 16, 32)| onechar('e', 24, 32):
                    switch(string[10] | 0x20) {
                    case 0| onechar('n', 0, 8):
                        switch(string[11] | 0x20) {
                        case 0| onechar('d', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('s', 0, 8):
                                return pkgTagSection::Key::Build_Depends;
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('c', 0, 32)| onechar('h', 8, 32)| onechar('e', 16, 32)| onechar('c', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('k', 0, 32)| onechar('s', 8, 32)| onechar('u', 16, 32)| onechar('m', 24, 32):
            switch(string[8] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[9]) {
                case 0| onechar('-', 0, 8):
                    switch(string[10] | 0x20) {
                    case 0| onechar('m', 0, 8):
                        switch(string[11] | 0x20) {
                        case 0| onechar('d', 0, 8):
                            switch(string[12]) {
                            case 0| onechar('5', 0, 8):
                                return pkgTagSection::Key::Checksums_Md5;
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash14(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('c', 0, 32)| onechar('h', 8, 32)| onechar('e', 16, 32)| onechar('c', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('k', 0, 32)| onechar('s', 8, 32)| onechar('u', 16, 32)| onechar('m', 24, 32):
            switch(string[8] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[9]) {
                case 0| onechar('-', 0, 8):
                    switch(string[10] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        switch(string[11] | 0x20) {
                        case 0| onechar('h', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('a', 0, 8):
                                switch(string[13]) {
                                case 0| onechar('1', 0, 8):
                                    return pkgTagSection::Key::Checksums_Sha1;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('c', 0, 32)| onechar('o', 8, 32)| onechar('n', 16, 32)| onechar('f', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('i', 0, 8):
            switch(string[5] | 0x20) {
            case 0| onechar('g', 0, 8):
                switch(string[6]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[7]) | 0x20202020) {
                    case 0| onechar('v', 0, 32)| onechar('e', 8, 32)| onechar('r', 16, 32)| onechar('s', 24, 32):
                        switch(string[11] | 0x20) {
                        case 0| onechar('i', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('o', 0, 8):
                                switch(string[13] | 0x20) {
                                case 0| onechar('n', 0, 8):
                                    return pkgTagSection::Key::Config_Version;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('i', 0, 32)| onechar('n', 8, 32)| onechar('s', 16, 32)| onechar('t', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('a', 0, 32)| onechar('l', 8, 32)| onechar('l', 16, 32)| onechar('e', 24, 32):
            switch(string[8] | 0x20) {
            case 0| onechar('d', 0, 8):
                switch(string[9]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[10]) | 0x20202020) {
                    case 0| onechar('s', 0, 32)| onechar('i', 8, 32)| onechar('z', 16, 32)| onechar('e', 24, 32):
                        return pkgTagSection::Key::Installed_Size;
                    }
                }
            }
        }
        break;
    case 0| onechar('k', 0, 32)| onechar('e', 8, 32)| onechar('r', 16, 32)| onechar('n', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('e', 0, 8):
            switch(string[5] | 0x20) {
            case 0| onechar('l', 0, 8):
                switch(string[6]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[7]) | 0x20202020) {
                    case 0| onechar('v', 0, 32)| onechar('e', 8, 32)| onechar('r', 16, 32)| onechar('s', 24, 32):
                        switch(string[11] | 0x20) {
                        case 0| onechar('i', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('o', 0, 8):
                                switch(string[13] | 0x20) {
                                case 0| onechar('n', 0, 8):
                                    return pkgTagSection::Key::Kernel_Version;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('m', 0, 32)| onechar('s', 8, 32)| onechar('d', 16, 32)| onechar('o', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('s', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu64*) &string[6]) | 0x2020202020202020) {
                case 0| onechar('f', 0, 64)| onechar('i', 8, 64)| onechar('l', 16, 64)| onechar('e', 24, 64)| onechar('n', 32, 64)| onechar('a', 40, 64)| onechar('m', 48, 64)| onechar('e', 56, 64):
                    return pkgTagSection::Key::MSDOS_Filename;
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash15(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('b', 0, 32)| onechar('u', 8, 32)| onechar('i', 16, 32)| onechar('l', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('d', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu64*) &string[6]) | 0x2020202020202020) {
                case 0| onechar('c', 0, 64)| onechar('o', 8, 64)| onechar('n', 16, 64)| onechar('f', 24, 64)| onechar('l', 32, 64)| onechar('i', 40, 64)| onechar('c', 48, 64)| onechar('t', 56, 64):
                    switch(string[14] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        return pkgTagSection::Key::Build_Conflicts;
                    }
                }
            }
        }
        break;
    case 0| onechar('d', 0, 32)| onechar('e', 8, 32)| onechar('s', 16, 32)| onechar('c', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('r', 0, 32)| onechar('i', 8, 32)| onechar('p', 16, 32)| onechar('t', 24, 32):
            switch(string[8] | 0x20) {
            case 0| onechar('i', 0, 8):
                switch(string[9] | 0x20) {
                case 0| onechar('o', 0, 8):
                    switch(string[10] | 0x20) {
                    case 0| onechar('n', 0, 8):
                        switch(string[11]) {
                        case 0| onechar('-', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('m', 0, 8):
                                switch(string[13] | 0x20) {
                                case 0| onechar('d', 0, 8):
                                    switch(string[14]) {
                                    case 0| onechar('5', 0, 8):
                                        return pkgTagSection::Key::Description_md5;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('s', 0, 32)| onechar('u', 8, 32)| onechar('b', 16, 32)| onechar('a', 24, 32):
        switch(*((triehash_uu64*) &string[4]) | 0x2020202020202020) {
        case 0| onechar('r', 0, 64)| onechar('c', 8, 64)| onechar('h', 16, 64)| onechar('i', 24, 64)| onechar('t', 32, 64)| onechar('e', 40, 64)| onechar('c', 48, 64)| onechar('t', 56, 64):
            switch(string[12] | 0x20) {
            case 0| onechar('u', 0, 8):
                switch(string[13] | 0x20) {
                case 0| onechar('r', 0, 8):
                    switch(string[14] | 0x20) {
                    case 0| onechar('e', 0, 8):
                        return pkgTagSection::Key::Subarchitecture;
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash16(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('c', 0, 32)| onechar('h', 8, 32)| onechar('e', 16, 32)| onechar('c', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('k', 0, 32)| onechar('s', 8, 32)| onechar('u', 16, 32)| onechar('m', 24, 32):
            switch(string[8] | 0x20) {
            case 0| onechar('s', 0, 8):
                switch(string[9]) {
                case 0| onechar('-', 0, 8):
                    switch(string[10] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        switch(string[11] | 0x20) {
                        case 0| onechar('h', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('a', 0, 8):
                                switch(string[13]) {
                                case 0| onechar('2', 0, 8):
                                    switch(string[14]) {
                                    case 0| onechar('5', 0, 8):
                                        switch(string[15]) {
                                        case 0| onechar('6', 0, 8):
                                            return pkgTagSection::Key::Checksums_Sha256;
                                        }
                                    }
                                    break;
                                case 0| onechar('5', 0, 8):
                                    switch(string[14]) {
                                    case 0| onechar('1', 0, 8):
                                        switch(string[15]) {
                                        case 0| onechar('2', 0, 8):
                                            return pkgTagSection::Key::Checksums_Sha512;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('p', 0, 32)| onechar('a', 8, 32)| onechar('c', 16, 32)| onechar('k', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('a', 0, 8):
            switch(string[5] | 0x20) {
            case 0| onechar('g', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('e', 0, 8):
                    switch(string[7]) {
                    case 0| onechar('-', 0, 8):
                        switch(*((triehash_uu64*) &string[8]) | 0x2020202020202020) {
                        case 0| onechar('r', 0, 64)| onechar('e', 8, 64)| onechar('v', 16, 64)| onechar('i', 24, 64)| onechar('s', 32, 64)| onechar('i', 40, 64)| onechar('o', 48, 64)| onechar('n', 56, 64):
                            return pkgTagSection::Key::Package_Revision;
                        }
                        break;
                    case 0| onechar('_', 0, 8):
                        switch(*((triehash_uu64*) &string[8]) | 0x2020202020202020) {
                        case 0| onechar('r', 0, 64)| onechar('e', 8, 64)| onechar('v', 16, 64)| onechar('i', 24, 64)| onechar('s', 32, 64)| onechar('i', 40, 64)| onechar('o', 48, 64)| onechar('n', 56, 64):
                            return pkgTagSection::Key::Package__Revision;
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('t', 0, 32)| onechar('r', 8, 32)| onechar('i', 16, 32)| onechar('g', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('g', 0, 32)| onechar('e', 8, 32)| onechar('r', 16, 32)| onechar('s', 24, 32):
            switch(string[8]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[9]) | 0x20202020) {
                case 0| onechar('a', 0, 32)| onechar('w', 8, 32)| onechar('a', 16, 32)| onechar('i', 24, 32):
                    switch(string[13] | 0x20) {
                    case 0| onechar('t', 0, 8):
                        switch(string[14] | 0x20) {
                        case 0| onechar('e', 0, 8):
                            switch(string[15] | 0x20) {
                            case 0| onechar('d', 0, 8):
                                return pkgTagSection::Key::Triggers_Awaited;
                            }
                        }
                    }
                    break;
                case 0| onechar('p', 0, 32)| onechar('e', 8, 32)| onechar('n', 16, 32)| onechar('d', 24, 32):
                    switch(string[13] | 0x20) {
                    case 0| onechar('i', 0, 8):
                        switch(string[14] | 0x20) {
                        case 0| onechar('n', 0, 8):
                            switch(string[15] | 0x20) {
                            case 0| onechar('g', 0, 8):
                                return pkgTagSection::Key::Triggers_Pending;
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash17(const char *string)
{
    switch(string[0] | 0x20) {
    case 0| onechar('d', 0, 8):
        switch(string[1] | 0x20) {
        case 0| onechar('m', 0, 8):
            switch(string[2]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[3]) | 0x20202020) {
                case 0| onechar('u', 0, 32)| onechar('p', 8, 32)| onechar('l', 16, 32)| onechar('o', 24, 32):
                    switch(string[7] | 0x20) {
                    case 0| onechar('a', 0, 8):
                        switch(string[8] | 0x20) {
                        case 0| onechar('d', 0, 8):
                            switch(string[9]) {
                            case 0| onechar('-', 0, 8):
                                switch(*((triehash_uu32*) &string[10]) | 0x20202020) {
                                case 0| onechar('a', 0, 32)| onechar('l', 8, 32)| onechar('l', 16, 32)| onechar('o', 24, 32):
                                    switch(string[14] | 0x20) {
                                    case 0| onechar('w', 0, 8):
                                        switch(string[15] | 0x20) {
                                        case 0| onechar('e', 0, 8):
                                            switch(string[16] | 0x20) {
                                            case 0| onechar('d', 0, 8):
                                                return pkgTagSection::Key::Dm_Upload_Allowed;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('s', 0, 8):
        switch(*((triehash_uu64*) &string[1]) | 0x2020202020202020) {
        case 0| onechar('t', 0, 64)| onechar('a', 8, 64)| onechar('n', 16, 64)| onechar('d', 24, 64)| onechar('a', 32, 64)| onechar('r', 40, 64)| onechar('d', 48, 64)| onechar('s', 56, 64):
            switch(string[9]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[10]) | 0x20202020) {
                case 0| onechar('v', 0, 32)| onechar('e', 8, 32)| onechar('r', 16, 32)| onechar('s', 24, 32):
                    switch(string[14] | 0x20) {
                    case 0| onechar('i', 0, 8):
                        switch(string[15] | 0x20) {
                        case 0| onechar('o', 0, 8):
                            switch(string[16] | 0x20) {
                            case 0| onechar('n', 0, 8):
                                return pkgTagSection::Key::Standards_Version;
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash18(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('b', 0, 32)| onechar('u', 8, 32)| onechar('i', 16, 32)| onechar('l', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('d', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[6]) | 0x20202020) {
                case 0| onechar('d', 0, 32)| onechar('e', 8, 32)| onechar('p', 16, 32)| onechar('e', 24, 32):
                    switch(string[10] | 0x20) {
                    case 0| onechar('n', 0, 8):
                        switch(string[11] | 0x20) {
                        case 0| onechar('d', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('s', 0, 8):
                                switch(string[13]) {
                                case 0| onechar('-', 0, 8):
                                    switch(*((triehash_uu32*) &string[14]) | 0x20202020) {
                                    case 0| onechar('a', 0, 32)| onechar('r', 8, 32)| onechar('c', 16, 32)| onechar('h', 24, 32):
                                        return pkgTagSection::Key::Build_Depends_Arch;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            break;
        case 0| onechar('t', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(string[6] | 0x20) {
                case 0| onechar('f', 0, 8):
                    switch(string[7] | 0x20) {
                    case 0| onechar('o', 0, 8):
                        switch(string[8] | 0x20) {
                        case 0| onechar('r', 0, 8):
                            switch(string[9]) {
                            case 0| onechar('-', 0, 8):
                                switch(*((triehash_uu64*) &string[10]) | 0x2020202020202020) {
                                case 0| onechar('p', 0, 64)| onechar('r', 8, 64)| onechar('o', 16, 64)| onechar('f', 24, 64)| onechar('i', 32, 64)| onechar('l', 40, 64)| onechar('e', 48, 64)| onechar('s', 56, 64):
                                    return pkgTagSection::Key::Built_For_Profiles;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('t', 0, 32)| onechar('e', 8, 32)| onechar('s', 16, 32)| onechar('t', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('s', 0, 32)| onechar('u', 8, 32)| onechar('i', 16, 32)| onechar('t', 24, 32):
            switch(string[8] | 0x20) {
            case 0| onechar('e', 0, 8):
                switch(string[9]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu64*) &string[10]) | 0x2020202020202020) {
                    case 0| onechar('t', 0, 64)| onechar('r', 8, 64)| onechar('i', 16, 64)| onechar('g', 24, 64)| onechar('g', 32, 64)| onechar('e', 40, 64)| onechar('r', 48, 64)| onechar('s', 56, 64):
                        return pkgTagSection::Key::Testsuite_Triggers;
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash19(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('b', 0, 32)| onechar('u', 8, 32)| onechar('i', 16, 32)| onechar('l', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('d', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu32*) &string[6]) | 0x20202020) {
                case 0| onechar('d', 0, 32)| onechar('e', 8, 32)| onechar('p', 16, 32)| onechar('e', 24, 32):
                    switch(string[10] | 0x20) {
                    case 0| onechar('n', 0, 8):
                        switch(string[11] | 0x20) {
                        case 0| onechar('d', 0, 8):
                            switch(string[12] | 0x20) {
                            case 0| onechar('s', 0, 8):
                                switch(string[13]) {
                                case 0| onechar('-', 0, 8):
                                    switch(*((triehash_uu32*) &string[14]) | 0x20202020) {
                                    case 0| onechar('i', 0, 32)| onechar('n', 8, 32)| onechar('d', 16, 32)| onechar('e', 24, 32):
                                        switch(string[18] | 0x20) {
                                        case 0| onechar('p', 0, 8):
                                            return pkgTagSection::Key::Build_Depends_Indep;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('i', 0, 32)| onechar('n', 8, 32)| onechar('s', 16, 32)| onechar('t', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('a', 0, 32)| onechar('l', 8, 32)| onechar('l', 16, 32)| onechar('e', 24, 32):
            switch(string[8] | 0x20) {
            case 0| onechar('r', 0, 8):
                switch(string[9]) {
                case 0| onechar('-', 0, 8):
                    switch(*((triehash_uu32*) &string[10]) | 0x20202020) {
                    case 0| onechar('m', 0, 32)| onechar('e', 8, 32)| onechar('n', 16, 32)| onechar('u', 24, 32):
                        switch(string[14]) {
                        case 0| onechar('-', 0, 8):
                            switch(*((triehash_uu32*) &string[15]) | 0x20202020) {
                            case 0| onechar('i', 0, 32)| onechar('t', 8, 32)| onechar('e', 16, 32)| onechar('m', 24, 32):
                                return pkgTagSection::Key::Installer_Menu_Item;
                            }
                        }
                    }
                }
            }
        }
        break;
    case 0| onechar('o', 0, 32)| onechar('r', 8, 32)| onechar('i', 16, 32)| onechar('g', 24, 32):
        switch(*((triehash_uu32*) &string[4]) | 0x20202020) {
        case 0| onechar('i', 0, 32)| onechar('n', 8, 32)| onechar('a', 16, 32)| onechar('l', 24, 32):
            switch(string[8]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu64*) &string[9]) | 0x2020202020202020) {
                case 0| onechar('m', 0, 64)| onechar('a', 8, 64)| onechar('i', 16, 64)| onechar('n', 24, 64)| onechar('t', 32, 64)| onechar('a', 40, 64)| onechar('i', 48, 64)| onechar('n', 56, 64):
                    switch(string[17] | 0x20) {
                    case 0| onechar('e', 0, 8):
                        switch(string[18] | 0x20) {
                        case 0| onechar('r', 0, 8):
                            return pkgTagSection::Key::Original_Maintainer;
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash20(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('b', 0, 32)| onechar('u', 8, 32)| onechar('i', 16, 32)| onechar('l', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('d', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu64*) &string[6]) | 0x2020202020202020) {
                case 0| onechar('c', 0, 64)| onechar('o', 8, 64)| onechar('n', 16, 64)| onechar('f', 24, 64)| onechar('l', 32, 64)| onechar('i', 40, 64)| onechar('c', 48, 64)| onechar('t', 56, 64):
                    switch(string[14] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        switch(string[15]) {
                        case 0| onechar('-', 0, 8):
                            switch(*((triehash_uu32*) &string[16]) | 0x20202020) {
                            case 0| onechar('a', 0, 32)| onechar('r', 8, 32)| onechar('c', 16, 32)| onechar('h', 24, 32):
                                return pkgTagSection::Key::Build_Conflicts_Arch;
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash21(const char *string)
{
    switch(*((triehash_uu32*) &string[0]) | 0x20202020) {
    case 0| onechar('b', 0, 32)| onechar('u', 8, 32)| onechar('i', 16, 32)| onechar('l', 24, 32):
        switch(string[4] | 0x20) {
        case 0| onechar('d', 0, 8):
            switch(string[5]) {
            case 0| onechar('-', 0, 8):
                switch(*((triehash_uu64*) &string[6]) | 0x2020202020202020) {
                case 0| onechar('c', 0, 64)| onechar('o', 8, 64)| onechar('n', 16, 64)| onechar('f', 24, 64)| onechar('l', 32, 64)| onechar('i', 40, 64)| onechar('c', 48, 64)| onechar('t', 56, 64):
                    switch(string[14] | 0x20) {
                    case 0| onechar('s', 0, 8):
                        switch(string[15]) {
                        case 0| onechar('-', 0, 8):
                            switch(*((triehash_uu32*) &string[16]) | 0x20202020) {
                            case 0| onechar('i', 0, 32)| onechar('n', 8, 32)| onechar('d', 16, 32)| onechar('e', 24, 32):
                                switch(string[20] | 0x20) {
                                case 0| onechar('p', 0, 8):
                                    return pkgTagSection::Key::Build_Conflicts_Indep;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
#else
static enum pkgTagSection::Key pkgTagHash3(const char *string)
{
    switch(string[0] | 0x20) {
    case 't':
        switch(string[1] | 0x20) {
        case 'a':
            switch(string[2] | 0x20) {
            case 'g':
                return pkgTagSection::Key::Tag;
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash4(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'g':
                switch(string[3] | 0x20) {
                case 's':
                    return pkgTagSection::Key::Bugs;
                }
            }
        }
        break;
    case 's':
        switch(string[1] | 0x20) {
        case 'h':
            switch(string[2] | 0x20) {
            case 'a':
                switch(string[3]) {
                case '1':
                    return pkgTagSection::Key::SHA1;
                }
            }
            break;
        case 'i':
            switch(string[2] | 0x20) {
            case 'z':
                switch(string[3] | 0x20) {
                case 'e':
                    return pkgTagSection::Key::Size;
                }
            }
        }
        break;
    case 't':
        switch(string[1] | 0x20) {
        case 'a':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 'k':
                    return pkgTagSection::Key::Task;
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash5(const char *string)
{
    switch(string[0] | 0x20) {
    case 'c':
        switch(string[1] | 0x20) {
        case 'l':
            switch(string[2] | 0x20) {
            case 'a':
                switch(string[3] | 0x20) {
                case 's':
                    switch(string[4] | 0x20) {
                    case 's':
                        return pkgTagSection::Key::Class;
                    }
                }
            }
        }
        break;
    case 'f':
        switch(string[1] | 0x20) {
        case 'i':
            switch(string[2] | 0x20) {
            case 'l':
                switch(string[3] | 0x20) {
                case 'e':
                    switch(string[4] | 0x20) {
                    case 's':
                        return pkgTagSection::Key::Files;
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash6(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'i':
            switch(string[2] | 0x20) {
            case 'n':
                switch(string[3] | 0x20) {
                case 'a':
                    switch(string[4] | 0x20) {
                    case 'r':
                        switch(string[5] | 0x20) {
                        case 'y':
                            return pkgTagSection::Key::Binary;
                        }
                    }
                }
            }
            break;
        case 'r':
            switch(string[2] | 0x20) {
            case 'e':
                switch(string[3] | 0x20) {
                case 'a':
                    switch(string[4] | 0x20) {
                    case 'k':
                        switch(string[5] | 0x20) {
                        case 's':
                            return pkgTagSection::Key::Breaks;
                        }
                    }
                }
            }
        }
        break;
    case 'f':
        switch(string[1] | 0x20) {
        case 'o':
            switch(string[2] | 0x20) {
            case 'r':
                switch(string[3] | 0x20) {
                case 'm':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 't':
                            return pkgTagSection::Key::Format;
                        }
                    }
                }
            }
        }
        break;
    case 'm':
        switch(string[1] | 0x20) {
        case 'd':
            switch(string[2]) {
            case '5':
                switch(string[3] | 0x20) {
                case 's':
                    switch(string[4] | 0x20) {
                    case 'u':
                        switch(string[5] | 0x20) {
                        case 'm':
                            return pkgTagSection::Key::MD5sum;
                        }
                    }
                }
            }
        }
        break;
    case 'o':
        switch(string[1] | 0x20) {
        case 'r':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'g':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5] | 0x20) {
                        case 'n':
                            return pkgTagSection::Key::Origin;
                        }
                    }
                }
            }
        }
        break;
    case 's':
        switch(string[1] | 0x20) {
        case 'h':
            switch(string[2] | 0x20) {
            case 'a':
                switch(string[3]) {
                case '2':
                    switch(string[4]) {
                    case '5':
                        switch(string[5]) {
                        case '6':
                            return pkgTagSection::Key::SHA256;
                        }
                    }
                    break;
                case '5':
                    switch(string[4]) {
                    case '1':
                        switch(string[5]) {
                        case '2':
                            return pkgTagSection::Key::SHA512;
                        }
                    }
                }
            }
            break;
        case 'o':
            switch(string[2] | 0x20) {
            case 'u':
                switch(string[3] | 0x20) {
                case 'r':
                    switch(string[4] | 0x20) {
                    case 'c':
                        switch(string[5] | 0x20) {
                        case 'e':
                            return pkgTagSection::Key::Source;
                        }
                    }
                }
            }
            break;
        case 't':
            switch(string[2] | 0x20) {
            case 'a':
                switch(string[3] | 0x20) {
                case 't':
                    switch(string[4] | 0x20) {
                    case 'u':
                        switch(string[5] | 0x20) {
                        case 's':
                            return pkgTagSection::Key::Status;
                        }
                    }
                }
            }
        }
        break;
    case 'v':
        switch(string[1] | 0x20) {
        case 'c':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3]) {
                case '-':
                    switch(string[4] | 0x20) {
                    case 'h':
                        switch(string[5] | 0x20) {
                        case 'g':
                            return pkgTagSection::Key::Vcs_Hg;
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash7(const char *string)
{
    switch(string[0] | 0x20) {
    case 'd':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 'p':
                switch(string[3] | 0x20) {
                case 'e':
                    switch(string[4] | 0x20) {
                    case 'n':
                        switch(string[5] | 0x20) {
                        case 'd':
                            switch(string[6] | 0x20) {
                            case 's':
                                return pkgTagSection::Key::Depends;
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'p':
        switch(string[1] | 0x20) {
        case 'a':
            switch(string[2] | 0x20) {
            case 'c':
                switch(string[3] | 0x20) {
                case 'k':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'g':
                            switch(string[6] | 0x20) {
                            case 'e':
                                return pkgTagSection::Key::Package;
                            }
                        }
                    }
                }
            }
        }
        break;
    case 's':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 'c':
                switch(string[3] | 0x20) {
                case 't':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5] | 0x20) {
                        case 'o':
                            switch(string[6] | 0x20) {
                            case 'n':
                                return pkgTagSection::Key::Section;
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'v':
        switch(string[1] | 0x20) {
        case 'c':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3]) {
                case '-':
                    switch(string[4] | 0x20) {
                    case 'b':
                        switch(string[5] | 0x20) {
                        case 'z':
                            switch(string[6] | 0x20) {
                            case 'r':
                                return pkgTagSection::Key::Vcs_Bzr;
                            }
                        }
                        break;
                    case 'c':
                        switch(string[5] | 0x20) {
                        case 'v':
                            switch(string[6] | 0x20) {
                            case 's':
                                return pkgTagSection::Key::Vcs_Cvs;
                            }
                        }
                        break;
                    case 'g':
                        switch(string[5] | 0x20) {
                        case 'i':
                            switch(string[6] | 0x20) {
                            case 't':
                                return pkgTagSection::Key::Vcs_Git;
                            }
                        }
                        break;
                    case 'm':
                        switch(string[5] | 0x20) {
                        case 't':
                            switch(string[6] | 0x20) {
                            case 'n':
                                return pkgTagSection::Key::Vcs_Mtn;
                            }
                        }
                        break;
                    case 's':
                        switch(string[5] | 0x20) {
                        case 'v':
                            switch(string[6] | 0x20) {
                            case 'n':
                                return pkgTagSection::Key::Vcs_Svn;
                            }
                        }
                    }
                }
            }
            break;
        case 'e':
            switch(string[2] | 0x20) {
            case 'r':
                switch(string[3] | 0x20) {
                case 's':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5] | 0x20) {
                        case 'o':
                            switch(string[6] | 0x20) {
                            case 'n':
                                return pkgTagSection::Key::Version;
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash8(const char *string)
{
    switch(string[0] | 0x20) {
    case 'e':
        switch(string[1] | 0x20) {
        case 'n':
            switch(string[2] | 0x20) {
            case 'h':
                switch(string[3] | 0x20) {
                case 'a':
                    switch(string[4] | 0x20) {
                    case 'n':
                        switch(string[5] | 0x20) {
                        case 'c':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7] | 0x20) {
                                case 's':
                                    return pkgTagSection::Key::Enhances;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'f':
        switch(string[1] | 0x20) {
        case 'i':
            switch(string[2] | 0x20) {
            case 'l':
                switch(string[3] | 0x20) {
                case 'e':
                    switch(string[4] | 0x20) {
                    case 'n':
                        switch(string[5] | 0x20) {
                        case 'a':
                            switch(string[6] | 0x20) {
                            case 'm':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    return pkgTagSection::Key::Filename;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'h':
        switch(string[1] | 0x20) {
        case 'o':
            switch(string[2] | 0x20) {
            case 'm':
                switch(string[3] | 0x20) {
                case 'e':
                    switch(string[4] | 0x20) {
                    case 'p':
                        switch(string[5] | 0x20) {
                        case 'a':
                            switch(string[6] | 0x20) {
                            case 'g':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    return pkgTagSection::Key::Homepage;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'o':
        switch(string[1] | 0x20) {
        case 'p':
            switch(string[2] | 0x20) {
            case 't':
                switch(string[3] | 0x20) {
                case 'i':
                    switch(string[4] | 0x20) {
                    case 'o':
                        switch(string[5] | 0x20) {
                        case 'n':
                            switch(string[6] | 0x20) {
                            case 'a':
                                switch(string[7] | 0x20) {
                                case 'l':
                                    return pkgTagSection::Key::Optional;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'p':
        switch(string[1] | 0x20) {
        case 'r':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'o':
                    switch(string[4] | 0x20) {
                    case 'r':
                        switch(string[5] | 0x20) {
                        case 'i':
                            switch(string[6] | 0x20) {
                            case 't':
                                switch(string[7] | 0x20) {
                                case 'y':
                                    return pkgTagSection::Key::Priority;
                                }
                            }
                        }
                    }
                }
                break;
            case 'o':
                switch(string[3] | 0x20) {
                case 'v':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5] | 0x20) {
                        case 'd':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7] | 0x20) {
                                case 's':
                                    return pkgTagSection::Key::Provides;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'r':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 'p':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'c':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7] | 0x20) {
                                case 's':
                                    return pkgTagSection::Key::Replaces;
                                }
                            }
                        }
                    }
                }
                break;
            case 'v':
                switch(string[3] | 0x20) {
                case 'i':
                    switch(string[4] | 0x20) {
                    case 's':
                        switch(string[5] | 0x20) {
                        case 'i':
                            switch(string[6] | 0x20) {
                            case 'o':
                                switch(string[7] | 0x20) {
                                case 'n':
                                    return pkgTagSection::Key::Revision;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 's':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'g':
                switch(string[3] | 0x20) {
                case 'g':
                    switch(string[4] | 0x20) {
                    case 'e':
                        switch(string[5] | 0x20) {
                        case 's':
                            switch(string[6] | 0x20) {
                            case 't':
                                switch(string[7] | 0x20) {
                                case 's':
                                    return pkgTagSection::Key::Suggests;
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'v':
        switch(string[1] | 0x20) {
        case 'c':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3]) {
                case '-':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'r':
                            switch(string[6] | 0x20) {
                            case 'c':
                                switch(string[7] | 0x20) {
                                case 'h':
                                    return pkgTagSection::Key::Vcs_Arch;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash9(const char *string)
{
    switch(string[0] | 0x20) {
    case 'c':
        switch(string[1] | 0x20) {
        case 'o':
            switch(string[2] | 0x20) {
            case 'n':
                switch(string[3] | 0x20) {
                case 'f':
                    switch(string[4] | 0x20) {
                    case 'f':
                        switch(string[5] | 0x20) {
                        case 'i':
                            switch(string[6] | 0x20) {
                            case 'l':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        return pkgTagSection::Key::Conffiles;
                                    }
                                }
                            }
                        }
                        break;
                    case 'l':
                        switch(string[5] | 0x20) {
                        case 'i':
                            switch(string[6] | 0x20) {
                            case 'c':
                                switch(string[7] | 0x20) {
                                case 't':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        return pkgTagSection::Key::Conflicts;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'd':
        switch(string[1] | 0x20) {
        case 'i':
            switch(string[2] | 0x20) {
            case 'r':
                switch(string[3] | 0x20) {
                case 'e':
                    switch(string[4] | 0x20) {
                    case 'c':
                        switch(string[5] | 0x20) {
                        case 't':
                            switch(string[6] | 0x20) {
                            case 'o':
                                switch(string[7] | 0x20) {
                                case 'r':
                                    switch(string[8] | 0x20) {
                                    case 'y':
                                        return pkgTagSection::Key::Directory;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'e':
        switch(string[1] | 0x20) {
        case 's':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 'e':
                    switch(string[4] | 0x20) {
                    case 'n':
                        switch(string[5] | 0x20) {
                        case 't':
                            switch(string[6] | 0x20) {
                            case 'i':
                                switch(string[7] | 0x20) {
                                case 'a':
                                    switch(string[8] | 0x20) {
                                    case 'l':
                                        return pkgTagSection::Key::Essential;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'i':
        switch(string[1] | 0x20) {
        case 'm':
            switch(string[2] | 0x20) {
            case 'p':
                switch(string[3] | 0x20) {
                case 'o':
                    switch(string[4] | 0x20) {
                    case 'r':
                        switch(string[5] | 0x20) {
                        case 't':
                            switch(string[6] | 0x20) {
                            case 'a':
                                switch(string[7] | 0x20) {
                                case 'n':
                                    switch(string[8] | 0x20) {
                                    case 't':
                                        return pkgTagSection::Key::Important;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 't':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 't':
                    switch(string[4] | 0x20) {
                    case 's':
                        switch(string[5] | 0x20) {
                        case 'u':
                            switch(string[6] | 0x20) {
                            case 'i':
                                switch(string[7] | 0x20) {
                                case 't':
                                    switch(string[8] | 0x20) {
                                    case 'e':
                                        return pkgTagSection::Key::Testsuite;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'u':
        switch(string[1] | 0x20) {
        case 'p':
            switch(string[2] | 0x20) {
            case 'l':
                switch(string[3] | 0x20) {
                case 'o':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'd':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7] | 0x20) {
                                case 'r':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        return pkgTagSection::Key::Uploaders;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'v':
        switch(string[1] | 0x20) {
        case 'c':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3]) {
                case '-':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5] | 0x20) {
                        case 'a':
                            switch(string[6] | 0x20) {
                            case 'r':
                                switch(string[7] | 0x20) {
                                case 'c':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        return pkgTagSection::Key::Vcs_Darcs;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash10(const char *string)
{
    switch(string[0] | 0x20) {
    case 'm':
        switch(string[1] | 0x20) {
        case 'a':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'n':
                    switch(string[4] | 0x20) {
                    case 't':
                        switch(string[5] | 0x20) {
                        case 'a':
                            switch(string[6] | 0x20) {
                            case 'i':
                                switch(string[7] | 0x20) {
                                case 'n':
                                    switch(string[8] | 0x20) {
                                    case 'e':
                                        switch(string[9] | 0x20) {
                                        case 'r':
                                            return pkgTagSection::Key::Maintainer;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            break;
        case 'u':
            switch(string[2] | 0x20) {
            case 'l':
                switch(string[3] | 0x20) {
                case 't':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'a':
                                switch(string[7] | 0x20) {
                                case 'r':
                                    switch(string[8] | 0x20) {
                                    case 'c':
                                        switch(string[9] | 0x20) {
                                        case 'h':
                                            return pkgTagSection::Key::Multi_Arch;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'r':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 'c':
                switch(string[3] | 0x20) {
                case 'o':
                    switch(string[4] | 0x20) {
                    case 'm':
                        switch(string[5] | 0x20) {
                        case 'm':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7] | 0x20) {
                                case 'n':
                                    switch(string[8] | 0x20) {
                                    case 'd':
                                        switch(string[9] | 0x20) {
                                        case 's':
                                            return pkgTagSection::Key::Recommends;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'v':
        switch(string[1] | 0x20) {
        case 'c':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3]) {
                case '-':
                    switch(string[4] | 0x20) {
                    case 'b':
                        switch(string[5] | 0x20) {
                        case 'r':
                            switch(string[6] | 0x20) {
                            case 'o':
                                switch(string[7] | 0x20) {
                                case 'w':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            return pkgTagSection::Key::Vcs_Browse;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash11(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 't':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'u':
                                switch(string[7] | 0x20) {
                                case 's':
                                    switch(string[8] | 0x20) {
                                    case 'i':
                                        switch(string[9] | 0x20) {
                                        case 'n':
                                            switch(string[10] | 0x20) {
                                            case 'g':
                                                return pkgTagSection::Key::Built_Using;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'd':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 'c':
                    switch(string[4] | 0x20) {
                    case 'r':
                        switch(string[5] | 0x20) {
                        case 'i':
                            switch(string[6] | 0x20) {
                            case 'p':
                                switch(string[7] | 0x20) {
                                case 't':
                                    switch(string[8] | 0x20) {
                                    case 'i':
                                        switch(string[9] | 0x20) {
                                        case 'o':
                                            switch(string[10] | 0x20) {
                                            case 'n':
                                                return pkgTagSection::Key::Description;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'p':
        switch(string[1] | 0x20) {
        case 'r':
            switch(string[2] | 0x20) {
            case 'e':
                switch(string[3]) {
                case '-':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5] | 0x20) {
                        case 'e':
                            switch(string[6] | 0x20) {
                            case 'p':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    switch(string[8] | 0x20) {
                                    case 'n':
                                        switch(string[9] | 0x20) {
                                        case 'd':
                                            switch(string[10] | 0x20) {
                                            case 's':
                                                return pkgTagSection::Key::Pre_Depends;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'r':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 'c':
                switch(string[3] | 0x20) {
                case 'o':
                    switch(string[4] | 0x20) {
                    case 'm':
                        switch(string[5] | 0x20) {
                        case 'm':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7] | 0x20) {
                                case 'n':
                                    switch(string[8] | 0x20) {
                                    case 'd':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'd':
                                                return pkgTagSection::Key::Recommended;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'v':
        switch(string[1] | 0x20) {
        case 'c':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3]) {
                case '-':
                    switch(string[4] | 0x20) {
                    case 'b':
                        switch(string[5] | 0x20) {
                        case 'r':
                            switch(string[6] | 0x20) {
                            case 'o':
                                switch(string[7] | 0x20) {
                                case 'w':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'r':
                                                return pkgTagSection::Key::Vcs_Browser;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash12(const char *string)
{
    switch(string[0] | 0x20) {
    case 'a':
        switch(string[1] | 0x20) {
        case 'r':
            switch(string[2] | 0x20) {
            case 'c':
                switch(string[3] | 0x20) {
                case 'h':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5] | 0x20) {
                        case 't':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7] | 0x20) {
                                case 'c':
                                    switch(string[8] | 0x20) {
                                    case 't':
                                        switch(string[9] | 0x20) {
                                        case 'u':
                                            switch(string[10] | 0x20) {
                                            case 'r':
                                                switch(string[11] | 0x20) {
                                                case 'e':
                                                    return pkgTagSection::Key::Architecture;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'p':
        switch(string[1] | 0x20) {
        case 'a':
            switch(string[2] | 0x20) {
            case 'c':
                switch(string[3] | 0x20) {
                case 'k':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'g':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7]) {
                                case '-':
                                    switch(string[8] | 0x20) {
                                    case 'l':
                                        switch(string[9] | 0x20) {
                                        case 'i':
                                            switch(string[10] | 0x20) {
                                            case 's':
                                                switch(string[11] | 0x20) {
                                                case 't':
                                                    return pkgTagSection::Key::Package_List;
                                                }
                                            }
                                        }
                                        break;
                                    case 't':
                                        switch(string[9] | 0x20) {
                                        case 'y':
                                            switch(string[10] | 0x20) {
                                            case 'p':
                                                switch(string[11] | 0x20) {
                                                case 'e':
                                                    return pkgTagSection::Key::Package_Type;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash13(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'd':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    switch(string[8] | 0x20) {
                                    case 'p':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'n':
                                                switch(string[11] | 0x20) {
                                                case 'd':
                                                    switch(string[12] | 0x20) {
                                                    case 's':
                                                        return pkgTagSection::Key::Build_Depends;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'c':
        switch(string[1] | 0x20) {
        case 'h':
            switch(string[2] | 0x20) {
            case 'e':
                switch(string[3] | 0x20) {
                case 'c':
                    switch(string[4] | 0x20) {
                    case 'k':
                        switch(string[5] | 0x20) {
                        case 's':
                            switch(string[6] | 0x20) {
                            case 'u':
                                switch(string[7] | 0x20) {
                                case 'm':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 'm':
                                                switch(string[11] | 0x20) {
                                                case 'd':
                                                    switch(string[12]) {
                                                    case '5':
                                                        return pkgTagSection::Key::Checksums_Md5;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash14(const char *string)
{
    switch(string[0] | 0x20) {
    case 'c':
        switch(string[1] | 0x20) {
        case 'h':
            switch(string[2] | 0x20) {
            case 'e':
                switch(string[3] | 0x20) {
                case 'c':
                    switch(string[4] | 0x20) {
                    case 'k':
                        switch(string[5] | 0x20) {
                        case 's':
                            switch(string[6] | 0x20) {
                            case 'u':
                                switch(string[7] | 0x20) {
                                case 'm':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 's':
                                                switch(string[11] | 0x20) {
                                                case 'h':
                                                    switch(string[12] | 0x20) {
                                                    case 'a':
                                                        switch(string[13]) {
                                                        case '1':
                                                            return pkgTagSection::Key::Checksums_Sha1;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            break;
        case 'o':
            switch(string[2] | 0x20) {
            case 'n':
                switch(string[3] | 0x20) {
                case 'f':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5] | 0x20) {
                        case 'g':
                            switch(string[6]) {
                            case '-':
                                switch(string[7] | 0x20) {
                                case 'v':
                                    switch(string[8] | 0x20) {
                                    case 'e':
                                        switch(string[9] | 0x20) {
                                        case 'r':
                                            switch(string[10] | 0x20) {
                                            case 's':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 'o':
                                                        switch(string[13] | 0x20) {
                                                        case 'n':
                                                            return pkgTagSection::Key::Config_Version;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'i':
        switch(string[1] | 0x20) {
        case 'n':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 't':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'l':
                            switch(string[6] | 0x20) {
                            case 'l':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    switch(string[8] | 0x20) {
                                    case 'd':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 's':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 'z':
                                                        switch(string[13] | 0x20) {
                                                        case 'e':
                                                            return pkgTagSection::Key::Installed_Size;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'k':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 'r':
                switch(string[3] | 0x20) {
                case 'n':
                    switch(string[4] | 0x20) {
                    case 'e':
                        switch(string[5] | 0x20) {
                        case 'l':
                            switch(string[6]) {
                            case '-':
                                switch(string[7] | 0x20) {
                                case 'v':
                                    switch(string[8] | 0x20) {
                                    case 'e':
                                        switch(string[9] | 0x20) {
                                        case 'r':
                                            switch(string[10] | 0x20) {
                                            case 's':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 'o':
                                                        switch(string[13] | 0x20) {
                                                        case 'n':
                                                            return pkgTagSection::Key::Kernel_Version;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'm':
        switch(string[1] | 0x20) {
        case 's':
            switch(string[2] | 0x20) {
            case 'd':
                switch(string[3] | 0x20) {
                case 'o':
                    switch(string[4] | 0x20) {
                    case 's':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'f':
                                switch(string[7] | 0x20) {
                                case 'i':
                                    switch(string[8] | 0x20) {
                                    case 'l':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'n':
                                                switch(string[11] | 0x20) {
                                                case 'a':
                                                    switch(string[12] | 0x20) {
                                                    case 'm':
                                                        switch(string[13] | 0x20) {
                                                        case 'e':
                                                            return pkgTagSection::Key::MSDOS_Filename;
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash15(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'c':
                                switch(string[7] | 0x20) {
                                case 'o':
                                    switch(string[8] | 0x20) {
                                    case 'n':
                                        switch(string[9] | 0x20) {
                                        case 'f':
                                            switch(string[10] | 0x20) {
                                            case 'l':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 'c':
                                                        switch(string[13] | 0x20) {
                                                        case 't':
                                                            switch(string[14] | 0x20) {
                                                            case 's':
                                                                return pkgTagSection::Key::Build_Conflicts;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'd':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 'c':
                    switch(string[4] | 0x20) {
                    case 'r':
                        switch(string[5] | 0x20) {
                        case 'i':
                            switch(string[6] | 0x20) {
                            case 'p':
                                switch(string[7] | 0x20) {
                                case 't':
                                    switch(string[8] | 0x20) {
                                    case 'i':
                                        switch(string[9] | 0x20) {
                                        case 'o':
                                            switch(string[10] | 0x20) {
                                            case 'n':
                                                switch(string[11]) {
                                                case '-':
                                                    switch(string[12] | 0x20) {
                                                    case 'm':
                                                        switch(string[13] | 0x20) {
                                                        case 'd':
                                                            switch(string[14]) {
                                                            case '5':
                                                                return pkgTagSection::Key::Description_md5;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 's':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'b':
                switch(string[3] | 0x20) {
                case 'a':
                    switch(string[4] | 0x20) {
                    case 'r':
                        switch(string[5] | 0x20) {
                        case 'c':
                            switch(string[6] | 0x20) {
                            case 'h':
                                switch(string[7] | 0x20) {
                                case 'i':
                                    switch(string[8] | 0x20) {
                                    case 't':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'c':
                                                switch(string[11] | 0x20) {
                                                case 't':
                                                    switch(string[12] | 0x20) {
                                                    case 'u':
                                                        switch(string[13] | 0x20) {
                                                        case 'r':
                                                            switch(string[14] | 0x20) {
                                                            case 'e':
                                                                return pkgTagSection::Key::Subarchitecture;
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash16(const char *string)
{
    switch(string[0] | 0x20) {
    case 'c':
        switch(string[1] | 0x20) {
        case 'h':
            switch(string[2] | 0x20) {
            case 'e':
                switch(string[3] | 0x20) {
                case 'c':
                    switch(string[4] | 0x20) {
                    case 'k':
                        switch(string[5] | 0x20) {
                        case 's':
                            switch(string[6] | 0x20) {
                            case 'u':
                                switch(string[7] | 0x20) {
                                case 'm':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 's':
                                                switch(string[11] | 0x20) {
                                                case 'h':
                                                    switch(string[12] | 0x20) {
                                                    case 'a':
                                                        switch(string[13]) {
                                                        case '2':
                                                            switch(string[14]) {
                                                            case '5':
                                                                switch(string[15]) {
                                                                case '6':
                                                                    return pkgTagSection::Key::Checksums_Sha256;
                                                                }
                                                            }
                                                            break;
                                                        case '5':
                                                            switch(string[14]) {
                                                            case '1':
                                                                switch(string[15]) {
                                                                case '2':
                                                                    return pkgTagSection::Key::Checksums_Sha512;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'p':
        switch(string[1] | 0x20) {
        case 'a':
            switch(string[2] | 0x20) {
            case 'c':
                switch(string[3] | 0x20) {
                case 'k':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'g':
                            switch(string[6] | 0x20) {
                            case 'e':
                                switch(string[7]) {
                                case '-':
                                    switch(string[8] | 0x20) {
                                    case 'r':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'v':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 's':
                                                        switch(string[13] | 0x20) {
                                                        case 'i':
                                                            switch(string[14] | 0x20) {
                                                            case 'o':
                                                                switch(string[15] | 0x20) {
                                                                case 'n':
                                                                    return pkgTagSection::Key::Package_Revision;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    break;
                                case '_':
                                    switch(string[8] | 0x20) {
                                    case 'r':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'v':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 's':
                                                        switch(string[13] | 0x20) {
                                                        case 'i':
                                                            switch(string[14] | 0x20) {
                                                            case 'o':
                                                                switch(string[15] | 0x20) {
                                                                case 'n':
                                                                    return pkgTagSection::Key::Package__Revision;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 't':
        switch(string[1] | 0x20) {
        case 'r':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'g':
                    switch(string[4] | 0x20) {
                    case 'g':
                        switch(string[5] | 0x20) {
                        case 'e':
                            switch(string[6] | 0x20) {
                            case 'r':
                                switch(string[7] | 0x20) {
                                case 's':
                                    switch(string[8]) {
                                    case '-':
                                        switch(string[9] | 0x20) {
                                        case 'a':
                                            switch(string[10] | 0x20) {
                                            case 'w':
                                                switch(string[11] | 0x20) {
                                                case 'a':
                                                    switch(string[12] | 0x20) {
                                                    case 'i':
                                                        switch(string[13] | 0x20) {
                                                        case 't':
                                                            switch(string[14] | 0x20) {
                                                            case 'e':
                                                                switch(string[15] | 0x20) {
                                                                case 'd':
                                                                    return pkgTagSection::Key::Triggers_Awaited;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            break;
                                        case 'p':
                                            switch(string[10] | 0x20) {
                                            case 'e':
                                                switch(string[11] | 0x20) {
                                                case 'n':
                                                    switch(string[12] | 0x20) {
                                                    case 'd':
                                                        switch(string[13] | 0x20) {
                                                        case 'i':
                                                            switch(string[14] | 0x20) {
                                                            case 'n':
                                                                switch(string[15] | 0x20) {
                                                                case 'g':
                                                                    return pkgTagSection::Key::Triggers_Pending;
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash17(const char *string)
{
    switch(string[0] | 0x20) {
    case 'd':
        switch(string[1] | 0x20) {
        case 'm':
            switch(string[2]) {
            case '-':
                switch(string[3] | 0x20) {
                case 'u':
                    switch(string[4] | 0x20) {
                    case 'p':
                        switch(string[5] | 0x20) {
                        case 'l':
                            switch(string[6] | 0x20) {
                            case 'o':
                                switch(string[7] | 0x20) {
                                case 'a':
                                    switch(string[8] | 0x20) {
                                    case 'd':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 'a':
                                                switch(string[11] | 0x20) {
                                                case 'l':
                                                    switch(string[12] | 0x20) {
                                                    case 'l':
                                                        switch(string[13] | 0x20) {
                                                        case 'o':
                                                            switch(string[14] | 0x20) {
                                                            case 'w':
                                                                switch(string[15] | 0x20) {
                                                                case 'e':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'd':
                                                                        return pkgTagSection::Key::Dm_Upload_Allowed;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 's':
        switch(string[1] | 0x20) {
        case 't':
            switch(string[2] | 0x20) {
            case 'a':
                switch(string[3] | 0x20) {
                case 'n':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5] | 0x20) {
                        case 'a':
                            switch(string[6] | 0x20) {
                            case 'r':
                                switch(string[7] | 0x20) {
                                case 'd':
                                    switch(string[8] | 0x20) {
                                    case 's':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 'v':
                                                switch(string[11] | 0x20) {
                                                case 'e':
                                                    switch(string[12] | 0x20) {
                                                    case 'r':
                                                        switch(string[13] | 0x20) {
                                                        case 's':
                                                            switch(string[14] | 0x20) {
                                                            case 'i':
                                                                switch(string[15] | 0x20) {
                                                                case 'o':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'n':
                                                                        return pkgTagSection::Key::Standards_Version;
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash18(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'd':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    switch(string[8] | 0x20) {
                                    case 'p':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'n':
                                                switch(string[11] | 0x20) {
                                                case 'd':
                                                    switch(string[12] | 0x20) {
                                                    case 's':
                                                        switch(string[13]) {
                                                        case '-':
                                                            switch(string[14] | 0x20) {
                                                            case 'a':
                                                                switch(string[15] | 0x20) {
                                                                case 'r':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'c':
                                                                        switch(string[17] | 0x20) {
                                                                        case 'h':
                                                                            return pkgTagSection::Key::Build_Depends_Arch;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    case 't':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'f':
                                switch(string[7] | 0x20) {
                                case 'o':
                                    switch(string[8] | 0x20) {
                                    case 'r':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 'p':
                                                switch(string[11] | 0x20) {
                                                case 'r':
                                                    switch(string[12] | 0x20) {
                                                    case 'o':
                                                        switch(string[13] | 0x20) {
                                                        case 'f':
                                                            switch(string[14] | 0x20) {
                                                            case 'i':
                                                                switch(string[15] | 0x20) {
                                                                case 'l':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'e':
                                                                        switch(string[17] | 0x20) {
                                                                        case 's':
                                                                            return pkgTagSection::Key::Built_For_Profiles;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 't':
        switch(string[1] | 0x20) {
        case 'e':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 't':
                    switch(string[4] | 0x20) {
                    case 's':
                        switch(string[5] | 0x20) {
                        case 'u':
                            switch(string[6] | 0x20) {
                            case 'i':
                                switch(string[7] | 0x20) {
                                case 't':
                                    switch(string[8] | 0x20) {
                                    case 'e':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 't':
                                                switch(string[11] | 0x20) {
                                                case 'r':
                                                    switch(string[12] | 0x20) {
                                                    case 'i':
                                                        switch(string[13] | 0x20) {
                                                        case 'g':
                                                            switch(string[14] | 0x20) {
                                                            case 'g':
                                                                switch(string[15] | 0x20) {
                                                                case 'e':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'r':
                                                                        switch(string[17] | 0x20) {
                                                                        case 's':
                                                                            return pkgTagSection::Key::Testsuite_Triggers;
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash19(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'd':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    switch(string[8] | 0x20) {
                                    case 'p':
                                        switch(string[9] | 0x20) {
                                        case 'e':
                                            switch(string[10] | 0x20) {
                                            case 'n':
                                                switch(string[11] | 0x20) {
                                                case 'd':
                                                    switch(string[12] | 0x20) {
                                                    case 's':
                                                        switch(string[13]) {
                                                        case '-':
                                                            switch(string[14] | 0x20) {
                                                            case 'i':
                                                                switch(string[15] | 0x20) {
                                                                case 'n':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'd':
                                                                        switch(string[17] | 0x20) {
                                                                        case 'e':
                                                                            switch(string[18] | 0x20) {
                                                                            case 'p':
                                                                                return pkgTagSection::Key::Build_Depends_Indep;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'i':
        switch(string[1] | 0x20) {
        case 'n':
            switch(string[2] | 0x20) {
            case 's':
                switch(string[3] | 0x20) {
                case 't':
                    switch(string[4] | 0x20) {
                    case 'a':
                        switch(string[5] | 0x20) {
                        case 'l':
                            switch(string[6] | 0x20) {
                            case 'l':
                                switch(string[7] | 0x20) {
                                case 'e':
                                    switch(string[8] | 0x20) {
                                    case 'r':
                                        switch(string[9]) {
                                        case '-':
                                            switch(string[10] | 0x20) {
                                            case 'm':
                                                switch(string[11] | 0x20) {
                                                case 'e':
                                                    switch(string[12] | 0x20) {
                                                    case 'n':
                                                        switch(string[13] | 0x20) {
                                                        case 'u':
                                                            switch(string[14]) {
                                                            case '-':
                                                                switch(string[15] | 0x20) {
                                                                case 'i':
                                                                    switch(string[16] | 0x20) {
                                                                    case 't':
                                                                        switch(string[17] | 0x20) {
                                                                        case 'e':
                                                                            switch(string[18] | 0x20) {
                                                                            case 'm':
                                                                                return pkgTagSection::Key::Installer_Menu_Item;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        break;
    case 'o':
        switch(string[1] | 0x20) {
        case 'r':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'g':
                    switch(string[4] | 0x20) {
                    case 'i':
                        switch(string[5] | 0x20) {
                        case 'n':
                            switch(string[6] | 0x20) {
                            case 'a':
                                switch(string[7] | 0x20) {
                                case 'l':
                                    switch(string[8]) {
                                    case '-':
                                        switch(string[9] | 0x20) {
                                        case 'm':
                                            switch(string[10] | 0x20) {
                                            case 'a':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 'n':
                                                        switch(string[13] | 0x20) {
                                                        case 't':
                                                            switch(string[14] | 0x20) {
                                                            case 'a':
                                                                switch(string[15] | 0x20) {
                                                                case 'i':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'n':
                                                                        switch(string[17] | 0x20) {
                                                                        case 'e':
                                                                            switch(string[18] | 0x20) {
                                                                            case 'r':
                                                                                return pkgTagSection::Key::Original_Maintainer;
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash20(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'c':
                                switch(string[7] | 0x20) {
                                case 'o':
                                    switch(string[8] | 0x20) {
                                    case 'n':
                                        switch(string[9] | 0x20) {
                                        case 'f':
                                            switch(string[10] | 0x20) {
                                            case 'l':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 'c':
                                                        switch(string[13] | 0x20) {
                                                        case 't':
                                                            switch(string[14] | 0x20) {
                                                            case 's':
                                                                switch(string[15]) {
                                                                case '-':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'a':
                                                                        switch(string[17] | 0x20) {
                                                                        case 'r':
                                                                            switch(string[18] | 0x20) {
                                                                            case 'c':
                                                                                switch(string[19] | 0x20) {
                                                                                case 'h':
                                                                                    return pkgTagSection::Key::Build_Conflicts_Arch;
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
static enum pkgTagSection::Key pkgTagHash21(const char *string)
{
    switch(string[0] | 0x20) {
    case 'b':
        switch(string[1] | 0x20) {
        case 'u':
            switch(string[2] | 0x20) {
            case 'i':
                switch(string[3] | 0x20) {
                case 'l':
                    switch(string[4] | 0x20) {
                    case 'd':
                        switch(string[5]) {
                        case '-':
                            switch(string[6] | 0x20) {
                            case 'c':
                                switch(string[7] | 0x20) {
                                case 'o':
                                    switch(string[8] | 0x20) {
                                    case 'n':
                                        switch(string[9] | 0x20) {
                                        case 'f':
                                            switch(string[10] | 0x20) {
                                            case 'l':
                                                switch(string[11] | 0x20) {
                                                case 'i':
                                                    switch(string[12] | 0x20) {
                                                    case 'c':
                                                        switch(string[13] | 0x20) {
                                                        case 't':
                                                            switch(string[14] | 0x20) {
                                                            case 's':
                                                                switch(string[15]) {
                                                                case '-':
                                                                    switch(string[16] | 0x20) {
                                                                    case 'i':
                                                                        switch(string[17] | 0x20) {
                                                                        case 'n':
                                                                            switch(string[18] | 0x20) {
                                                                            case 'd':
                                                                                switch(string[19] | 0x20) {
                                                                                case 'e':
                                                                                    switch(string[20] | 0x20) {
                                                                                    case 'p':
                                                                                        return pkgTagSection::Key::Build_Conflicts_Indep;
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return pkgTagSection::Key::Unknown;
}
#endif /* TRIE_HASH_MULTI_BYTE */
 enum pkgTagSection::Key pkgTagHash(const char *string, size_t length)
{
    switch (length) {
    case 3:
        return pkgTagHash3(string);
    case 4:
        return pkgTagHash4(string);
    case 5:
        return pkgTagHash5(string);
    case 6:
        return pkgTagHash6(string);
    case 7:
        return pkgTagHash7(string);
    case 8:
        return pkgTagHash8(string);
    case 9:
        return pkgTagHash9(string);
    case 10:
        return pkgTagHash10(string);
    case 11:
        return pkgTagHash11(string);
    case 12:
        return pkgTagHash12(string);
    case 13:
        return pkgTagHash13(string);
    case 14:
        return pkgTagHash14(string);
    case 15:
        return pkgTagHash15(string);
    case 16:
        return pkgTagHash16(string);
    case 17:
        return pkgTagHash17(string);
    case 18:
        return pkgTagHash18(string);
    case 19:
        return pkgTagHash19(string);
    case 20:
        return pkgTagHash20(string);
    case 21:
        return pkgTagHash21(string);
    default:
        return pkgTagSection::Key::Unknown;
    }
}
