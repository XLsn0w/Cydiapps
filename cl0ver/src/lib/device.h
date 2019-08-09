#ifndef DEVICE_H
#define DEVICE_H

#include <stdint.h>             // uint32_t

enum
{
    M_NONE   = 0x0000,

    M_N94AP  = 0x0001,          // iPhone 4s
    M_N41AP  = 0x0002,          // iPhone 5
    M_N42AP  = 0x0003,          // iPhone 5
    M_N48AP  = 0x0004,          // iPhone 5c
    M_N49AP  = 0x0005,          // iPhone 5c
    M_N51AP  = 0x0006,          // iPhone 5s
    M_N53AP  = 0x0007,          // iPhone 5s
    M_N61AP  = 0x0008,          // iPhone 6
    M_N56AP  = 0x0009,          // iPhone 6+
    M_N71AP  = 0x000a,          // iPhone 6s
    M_N71mAP = 0x000b,          // iPhone 6s
    M_N66AP  = 0x000c,          // iPhone 6s+
    M_N66mAP = 0x000d,          // iPhone 6s+
    M_N69AP  = 0x000e,          // iPhone SE
    M_N69uAP = 0x000f,          // iPhone SE

    M_N78AP  = 0x0010,          // iPod touch 5G
    M_N78aAP = 0x0011,          // iPod touch 5G
    M_N102AP = 0x0012,          // iPod touch 6G

    M_K93AP  = 0x0013,          // iPad 2
    M_K94AP  = 0x0014,          // iPad 2
    M_K95AP  = 0x0015,          // iPad 2
    M_K93AAP = 0x0016,          // iPad 2
    M_J1AP   = 0x0017,          // iPad 3
    M_J2AP   = 0x0018,          // iPad 3
    M_J2AAP  = 0x0019,          // iPad 3
    M_P101AP = 0x001a,          // iPad 4
    M_P102AP = 0x001b,          // iPad 4
    M_P103AP = 0x001c,          // iPad 4
    M_J71AP  = 0x001d,          // iPad Air
    M_J72AP  = 0x001e,          // iPad Air
    M_J73AP  = 0x001f,          // iPad Air
    M_J81AP  = 0x0020,          // iPad Air 2
    M_J82AP  = 0x0021,          // iPad Air 2
    M_J98aAP = 0x0022,          // iPad Pro (12.9)
    M_J99aAP = 0x0023,          // iPad Pro (12.9)
    M_J127AP = 0x0024,          // iPad Pro (9.7)
    M_J128AP = 0x0025,          // iPad Pro (9.7)

    M_P105AP = 0x0026,          // iPad Mini
    M_P106AP = 0x0027,          // iPad Mini
    M_P107AP = 0x0028,          // iPad Mini
    M_J85AP  = 0x0029,          // iPad Mini 2
    M_J86AP  = 0x002a,          // iPad Mini 2
    M_J87AP  = 0x002b,          // iPad Mini 2
    M_J85mAP = 0x002c,          // iPad Mini 3
    M_J86mAP = 0x002d,          // iPad Mini 3
    M_J87mAP = 0x002e,          // iPad Mini 3
    M_J96AP  = 0x002f,          // iPad Mini 4
    M_J97AP  = 0x0030,          // iPad Mini 4
};

enum
{
    V_NONE   = 0x00000000,

    V_13A340 = 0x00010000,      // 9.0
    V_13A342 = 0x00020000,      // 9.0
    V_13A343 = 0x00030000,      // 9.0
    V_13A344 = 0x00040000,      // 9.0
    V_13A404 = 0x00050000,      // 9.0.1
    V_13A405 = 0x00060000,      // 9.0.1
    V_13A452 = 0x00070000,      // 9.0.2
    V_13B138 = 0x00080000,      // 9.1
    V_13B143 = 0x00090000,      // 9.1
    V_13B144 = 0x000a0000,      // 9.1
    V_13C75  = 0x000b0000,      // 9.2
    V_13D15  = 0x000c0000,      // 9.2.1
    V_13D20  = 0x000d0000,      // 9.2.1
    V_13E233 = 0x000e0000,      // 9.3
    V_13E234 = 0x000f0000,      // 9.3
    V_13E236 = 0x00100000,      // 9.3
    V_13E237 = 0x00110000,      // 9.3
    V_13E238 = 0x00120000,      // 9.3.1
    V_13F69  = 0x00130000,      // 9.3.2
    V_13F72  = 0x00140000,      // 9.3.2
    V_13G34  = 0x00150000,      // 9.3.3
    V_13G35  = 0x00160000,      // 9.3.4
};

uint32_t get_model(void);

uint32_t get_os_version(void);

#endif
