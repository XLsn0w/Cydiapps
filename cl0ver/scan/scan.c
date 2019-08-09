#include <stdbool.h>            // bool, true, false
#include <stdint.h>             // uint32_t, uint64_t
#include <stdio.h>              // printf

#include <mach/kern_return.h>   // kern_return_t, KERN_SUCCESS
#include <mach/mach_error.h>    // mach_error_string
#include <mach/mach_host.h>     // host_get_io_master, mach_port_t
#include <mach/mach_traps.h>    // mach_host_self
#include <mach/port.h>          // MACH_PORT_NULL, MACH_PORT_VALID

#include <IOKit/IOKitLib.h>     // IO*, io_*
#ifndef __LP64__
#   include <IOKit/iokitmig.h>  // io_service_open_extended
#else
#   include "iokitUser.c"       // io_service_open_extended
#endif

#ifdef __OBJC__
#   import <Foundation/Foundation.h>
#   define LOG(str, args...) NSLog(@ str, ##args)
#else
#   define LOG(str, args...) printf(str, ##args)
#endif

enum
{
    kOSSerializeDictionary      = 0x01000000U,
    kOSSerializeArray           = 0x02000000U,
    kOSSerializeSet             = 0x03000000U,
    kOSSerializeNumber          = 0x04000000U,
    kOSSerializeSymbol          = 0x08000000U,
    kOSSerializeString          = 0x09000000U,
    kOSSerializeData            = 0x0a000000U,
    kOSSerializeBoolean         = 0x0b000000U,
    kOSSerializeObject          = 0x0c000000U,

    kOSSerializeTypeMask        = 0x7F000000U,
    kOSSerializeDataMask        = 0x00FFFFFFU,

    kOSSerializeEndCollection   = 0x80000000U,

    kOSSerializeMagic           = 0x000000d3U,
};

#define NUMSERVICES 107
char *names[NUMSERVICES] =
{
    "AGXShared",
    "ASP",
    "AppleARMIIC",
    "AppleAVE",
    "AppleAuthCP",
    "AppleBCMWLAN",
    "AppleBaseband",
    "AppleBiometricServices",
    "AppleCredentialManager",
    "AppleD5500",
    "AppleEffaceableStorage",
    "AppleEmbeddedPCIE",
    "AppleH2CamIn",
    "AppleH3CamIn",
    "AppleH4CamIn",
    "AppleH6CamIn",
    "AppleHDQGasGaugeControl",
    "AppleIPAppender",
    "AppleJPEGDriver",
    "AppleKeyStore",
    "AppleMobileApNonce",
    "AppleMobileFileIntegrity",
    "AppleMultitouchSPI",
    "AppleNANDFTL",
    "AppleNVMeSMART",
    "AppleOscarCMA",
    "AppleOscar",
    "ApplePMGRTemp",
    "AppleSEP",
    "AppleSPUHIDDevice",
    "AppleSPUHIDDriver",
    "AppleSPUProfileDriver",
    "AppleSPU",
    "AppleSRSDriver",
    "AppleSSE",
    "AppleSmartIO",
    "AppleStockholmControl",
    "AppleT700XTempSensor",
    "AppleTempSensor",
    "AppleUSBHostDevice",
    "AppleUSBHostInterface",
    "AppleUSBHost",
    "AppleVXD375",
    "AppleVXD390",
    "AppleVXD393",
    "AppleVXE380",
    "CCDataPipe",
    "CCLogPipe",
    "CCPipe",
    "CoreCapture",
    "EffacingMediaFilter",
    "EncryptedMediaFilter",
    "H3H264VideoEncoderDriver",
    "IOAESAccelerator",
    "IOAVAudioInterface",
    "IOAVCECControlInterface",
    "IOAVController",
    "IOAVDevice",
    "IOAVInterface",
    "IOAVService",
    "IOAVVideoInterface",
    "IOAccelMemoryInfo",
    "IOAccelRestart",
    "IOAccelShared",
    "IOAccessoryEAInterface",
    "IOAccessoryIDBus",
    "IOAccessoryManager",
    "IOAccessoryPort",
    "IOAudio2Device",
    "IOAudio2Transformer",
    "IOAudioCodecs",
    "IOCEC",
    "IODPAudioInterface",
    "IODPController",
    "IODPDevice",
    "IODPDisplayInterface",
    "IODPService",
    "IOHDIXController",
    "IOHIDEventService",
    "IOHIDLib",
    "IOHIDResourceDevice",
    "IOMikeyBusBulkPipe",
    "IOMikeyBusDevice",
    "IOMikeyBusFunctionGroup",
    "IOMobileFramebuffer",
    "IONetworkStack",
    "IONetwork",
    "IOPKEAccelerator",
    "IOPRNGAccelerator",
    "IOReport",
    "IOSHA1Accelerator",
    "IOStreamAudio",
    "IOStream",
    "IOSurfaceRoot",
    "IOUSBDeviceInterface",
    "IOUserEthernetResource",
    "KDIDiskImageNub",
    "LwVM",
    "ProvInfoIOKit",
    "RTBuddyLoader",
    "RTBuddy",
    "RootDomain",
    "com_apple_audio_IOBorealisOwl",
    "com_apple_driver_FairPlayIOKit",
    "com_apple_driver_KeyDeliveryIOKit",
    "mDNSOffload",
    "wlDNSOffload",
};

uint32_t dict[15] =
{
    kOSSerializeMagic,
    kOSSerializeEndCollection | kOSSerializeDictionary | 4,

    kOSSerializeSymbol | 7,
    's' | ('i' << 8) | ('g' << 16) | ('u' << 24),
    'z' | ('a' << 8),
    kOSSerializeBoolean | 1,

    kOSSerializeSymbol | 4,
    'n' | ('u' << 8) | ('m' << 16), // "num"
    kOSSerializeNumber | 64,
    0x69696969,
    0x69696969,

    kOSSerializeSymbol | 4,
    's' | ('t' << 8) | ('r' << 16), // "str"
    kOSSerializeEndCollection | kOSSerializeString | 4,
    'a' | ('b' << 8) | ('c' << 16), // "abc"
};

int main()
{
    mach_port_t master = MACH_PORT_NULL;
    if(host_get_io_master(mach_host_self(), &master) != KERN_SUCCESS || !MACH_PORT_VALID(master))
    {
        LOG("Failed to get IO master port\n");
        return 1;
    }

    LOG("%-64s%-12s%-6s%17s %-12s\n", "Service name", "Valid", "Spawn", "num", "str");
    for(uint32_t i = 0; i < NUMSERVICES; ++i)
    {
        bool valid = false,
             spawn = false;
        uint64_t num = 0;
        char *str = NULL;
        io_service_t service = IOServiceGetMatchingService(master, IOServiceMatching(names[i]));
        if(MACH_PORT_VALID(service))
        {
             valid = true;
             io_connect_t client = MACH_PORT_NULL;
             kern_return_t err;
             if(io_service_open_extended(service, mach_task_self(), 0, NDR_record, (char*)dict, sizeof(dict), &err, &client) == KERN_SUCCESS && err == KERN_SUCCESS && MACH_PORT_VALID(client))
             {
                 spawn = true;
                 io_iterator_t it = 0;
                 if(IORegistryEntryCreateIterator(service, "IOService", kIORegistryIterateRecursively, &it) == KERN_SUCCESS)
                 {
                     io_object_t o;
                     while((o = IOIteratorNext(it)) != 0)
                     {
                         char buf[100];
                         uint32_t buflen = sizeof(buf);
                         if(IORegistryEntryGetProperty(o, "siguza", buf, &buflen) == KERN_SUCCESS)
                         {
                             buflen = sizeof(buf);
                             if(IORegistryEntryGetProperty(o, "num", buf, &buflen) == KERN_SUCCESS)
                             {
                                 num = *(uint64_t*)buf;
                             }
                             buflen = sizeof(buf);
                             if(IORegistryEntryGetProperty(o, "str", buf, &buflen) == KERN_SUCCESS)
                             {
                                 str = buf;
                             }
                         }
                         IOObjectRelease(o);
                     }
                     IOObjectRelease(it);
                 }
                 IOServiceClose(client);
             }
        }
        LOG("%-64s%-12s%-6s%17llx %-12s\n", names[i], valid ? "yes" : "---", spawn ? "yes" : "---", num, str ? str : "---");
    }
    return 0;
}
