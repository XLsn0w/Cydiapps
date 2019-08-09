#include <errno.h>              // errno
#include <stdint.h>             // uint32_t
#include <string.h>             // strncmp, strerror
#include <sys/sysctl.h>         // CTL_*, KERN_OSVERSION, HW_MODEL, sysctl

#include "common.h"             // DEBUG
#include "try.h"                // THROW

#include "device.h"

#define MODEL(name) \
do \
{ \
    if(strncmp(#name, b, s) == 0) return M_##name; \
} while(0)

#define VERSION(name) \
do \
{ \
    if(strncmp(#name, b, s) == 0) return V_##name; \
} while(0)

static uint32_t get_model_internal(void)
{
    // Static so we can use it in THROW
    static char b[32];
    size_t s = sizeof(b);
    // sysctl("hw.model")
    int cmd[2] = { CTL_HW, HW_MODEL };
    if(sysctl(cmd, sizeof(cmd) / sizeof(*cmd), b, &s, NULL, 0) != 0)
    {
        THROW("sysctl(\"hw.model\") failed: %s", strerror(errno));
    }
    DEBUG("Model: %s", b);

    MODEL(N94AP);
    MODEL(N41AP);
    MODEL(N42AP);
    MODEL(N48AP);
    MODEL(N49AP);
    MODEL(N51AP);
    MODEL(N53AP);
    MODEL(N61AP);
    MODEL(N56AP);
    MODEL(N71AP);
    MODEL(N71mAP);
    MODEL(N66AP);
    MODEL(N66mAP);
    MODEL(N69AP);
    MODEL(N69uAP);

    MODEL(N78AP);
    MODEL(N78aAP);
    MODEL(N102AP);

    MODEL(K93AP);
    MODEL(K94AP);
    MODEL(K95AP);
    MODEL(K93AAP);
    MODEL(J1AP);
    MODEL(J2AP);
    MODEL(J2AAP);
    MODEL(P101AP);
    MODEL(P102AP);
    MODEL(P103AP);
    MODEL(J71AP);
    MODEL(J72AP);
    MODEL(J73AP);
    MODEL(J81AP);
    MODEL(J82AP);
    MODEL(J98aAP);
    MODEL(J99aAP);
    MODEL(J127AP);
    MODEL(J128AP);

    MODEL(P105AP);
    MODEL(P106AP);
    MODEL(P107AP);
    MODEL(J85AP);
    MODEL(J86AP);
    MODEL(J87AP);
    MODEL(J85mAP);
    MODEL(J86mAP);
    MODEL(J87mAP);
    MODEL(J96AP);
    MODEL(J97AP);

    THROW("Unrecognized device: %s", b);
}

uint32_t get_os_version_internal(void)
{
    // Static so we can use it in THROW
    static char b[32];
    size_t s = sizeof(b);
    // sysctl("kern.osversion")
    int cmd[2] = { CTL_KERN, KERN_OSVERSION };
    if(sysctl(cmd, sizeof(cmd) / sizeof(*cmd), b, &s, NULL, 0) != 0)
    {
        THROW("sysctl(\"kern.osversion\") failed: %s", strerror(errno));
    }
    DEBUG("OS build: %s", b);

    VERSION(13A340);
    VERSION(13A342);
    VERSION(13A343);
    VERSION(13A344);
    VERSION(13A404);
    VERSION(13A405);
    VERSION(13A452);
    VERSION(13B138);
    VERSION(13B143);
    VERSION(13B144);
    VERSION(13C75);
    VERSION(13D15);
    VERSION(13D20);
    VERSION(13E233);
    VERSION(13E234);
    VERSION(13E236);
    VERSION(13E237);
    VERSION(13E238);
    VERSION(13F69);
    VERSION(13F72);
    VERSION(13G34);
    VERSION(13G35);

    THROW("Unrecognized OS version: %s", b);
}

uint32_t get_model(void)
{
    static uint32_t model = M_NONE;
    if(model == M_NONE)
    {
        model = get_model_internal();
    }
    return model;
}

uint32_t get_os_version(void)
{
    static uint32_t version = V_NONE;
    if(version == V_NONE)
    {
        version = get_os_version_internal();
    }
    return version;
}
