#import <Foundation/Foundation.h>
#include <stdio.h>
#include <mach/mach.h>
#include <mach/error.h>
#include <mach/message.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <unistd.h>
#include "patchfinder64.h"
#include "kern_utils.h"
#include "kmem.h"
#include "kexecute.h"
#include "offsets.h"

#define PROC_PIDPATHINFO_MAXSIZE  (4*MAXPATHLEN)
int proc_pidpath(pid_t pid, void *buffer, uint32_t buffersize);

#define JAILBREAKD_COMMAND_ENTITLE 1
#define JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT 2
#define JAILBREAKD_COMMAND_ENTITLE_PLATFORMIZE 3
#define JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT_AFTER_DELAY 4
#define JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT_FROM_XPCPROXY 5
#define JAILBREAKD_COMMAND_FIXUP_SETUID 6
#define JAILBREAKD_COMMAND_UNSANDBOX 7
#define JAILBREAKD_COMMAND_FIXUP_DYLIB 8
#define JAILBREAKD_COMMAND_FIXUP_EXECUTABLE 9
#define JAILBREAKD_COMMAND_EXIT 13

struct __attribute__((__packed__)) JAILBREAKD_PACKET {
    uint8_t Command;
};

struct __attribute__((__packed__)) JAILBREAKD_ENTITLE_PID {
    uint8_t Command;
    int32_t Pid;
};

struct __attribute__((__packed__)) JAILBREAKD_ENTITLE_PID_AND_SIGCONT {
    uint8_t Command;
    int32_t Pid;
};

struct __attribute__((__packed__)) JAILBREAKD_FIXUP_SETUID {
    uint8_t Command;
    int32_t Pid;
};

struct __attribute__((__packed__)) JAILBREAKD_UNSANDBOX {
    uint8_t Command;
    int32_t Pid;
};

struct __attribute__((__packed__)) JAILBREAKD_FIXUP_DYLIB {
    uint8_t Command;
    char dylib[1024];
};

struct __attribute__((__packed__)) JAILBREAKD_FIXUP_EXECUTABLE {
    uint8_t Command;
    char exec[1024];
};

struct __attribute__((__packed__)) JAILBREAKD_ENTITLE_PLATFORMIZE_PID {
    uint8_t Command;
    int32_t EntitlePID;
    int32_t PlatformizePID;
};

mach_port_t tfpzero;
uint64_t kernel_base;
uint64_t kernel_slide;
struct offsets off;

extern unsigned offsetof_ip_kobject;

int runserver(){
    NSLog(@"[jailbreakd] Process Start!");

    kern_return_t err = host_get_special_port(mach_host_self(), HOST_LOCAL_NODE, 4, &tfpzero);
    if (err != KERN_SUCCESS) {
        NSLog(@"host_get_special_port 4: %s", mach_error_string(err));
        return 5;
    }

    bzero(&off, sizeof(struct offsets));
    
    if(getOffsetsFromFile("/var/containers/Bundle/tweaksupport/offsets.data", &off)) {
        NSLog(@"[jailbreakd] Failed to get offsets!");
        exit(-1);
    }
    
    // Get the slide
    kernel_base = off.kernel_base;
    kernel_slide = kernel_base - 0xFFFFFFF007004000;
    NSLog(@"[jailbreakd] slide: 0x%016llx", kernel_slide);

    init_kexecute();

    struct sockaddr_in serveraddr; /* server's addr */
    struct sockaddr_in clientaddr; /* client addr */

    NSLog(@"[jailbreakd] Running server...");
    int sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
        NSLog(@"[jailbreakd] Error opening socket");
    int optval = 1;
    setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, (const void *)&optval, sizeof(int));

    struct hostent *server;
    char *hostname = "127.0.0.1";
    /* gethostbyname: get the server's DNS entry */
    server = gethostbyname(hostname);
    if (server == NULL) {
        NSLog(@"[jailbreakd] ERROR, no such host as %s", hostname);
        exit(0);
    }

    bzero((char *) &serveraddr, sizeof(serveraddr));
    serveraddr.sin_family = AF_INET;
    //serveraddr.sin_addr.s_addr = htonl(INADDR_ANY);
    bcopy((char *)server->h_addr,
          (char *)&serveraddr.sin_addr.s_addr, server->h_length);
    serveraddr.sin_port = htons((unsigned short)5);

    if (bind(sockfd, (struct sockaddr *)&serveraddr, sizeof(serveraddr)) < 0){
        NSLog(@"[jailbreakd] Error binding...");
        term_kexecute();
        exit(-1);
    }
    NSLog(@"[jailbreakd] Server running!");
    
    unlink("/var/tmp/jailbreakd.pid");
    
    FILE *f = fopen("/var/tmp/jailbreakd.pid", "w");
    fprintf(f, "%d\n", getpid());
    fclose(f);

    char buf[2000];

    socklen_t clientlen = sizeof(clientaddr);
    while (1){
        bzero(buf, 2000);
        int size = recvfrom(sockfd, buf, 2000, 0, (struct sockaddr *)&clientaddr, &clientlen);
        if (size < 0){
            NSLog(@"Error in recvfrom");
            continue;
        }
        if (size < 1){
            NSLog(@"Packet must have at least 1 byte");
            continue;
        }
        NSLog(@"Server received %d bytes.", size);

        uint8_t command = buf[0];
        
        NSLog(@"Command: %ul\n", command);
        
        if (command == JAILBREAKD_COMMAND_UNSANDBOX){
            if (size < sizeof(struct JAILBREAKD_UNSANDBOX)){
                NSLog(@"Error: ENTITLE packet is too small");
                continue;
            }
            struct JAILBREAKD_UNSANDBOX *entitlePacket = (struct JAILBREAKD_UNSANDBOX *)buf;
            NSLog(@"Unsandboxing PID %d", entitlePacket->Pid);
            unsandbox(entitlePacket->Pid);
        }
        
        else if (command == JAILBREAKD_COMMAND_ENTITLE){
            if (size < sizeof(struct JAILBREAKD_ENTITLE_PID)){
                NSLog(@"Error: ENTITLE packet is too small");
                continue;
            }
            struct JAILBREAKD_ENTITLE_PID *entitlePacket = (struct JAILBREAKD_ENTITLE_PID *)buf;
            NSLog(@"Entitle PID %d", entitlePacket->Pid);
            setcsflagsandplatformize(entitlePacket->Pid);
        }
        
        else if (command == JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT){
            if (size < sizeof(struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT)){
                NSLog(@"Error: ENTITLE_SIGCONT packet is too small");
                continue;
            }
            struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT *entitleSIGCONTPacket = (struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT *)buf;
            NSLog(@"Entitle+SIGCONT PID %d", entitleSIGCONTPacket->Pid);
            setcsflagsandplatformize(entitleSIGCONTPacket->Pid);
            kill(entitleSIGCONTPacket->Pid, SIGCONT);
        }
        
        else if (command == JAILBREAKD_COMMAND_ENTITLE_PLATFORMIZE){
            if (size < sizeof(struct JAILBREAKD_ENTITLE_PLATFORMIZE_PID)){
                NSLog(@"Error: ENTITLE_PLATFORMIZE packet is too small");
                continue;
            }
            struct JAILBREAKD_ENTITLE_PLATFORMIZE_PID *entitlePlatformizePacket = (struct JAILBREAKD_ENTITLE_PLATFORMIZE_PID *)buf;
            NSLog(@"Entitle PID %d", entitlePlatformizePacket->EntitlePID);
            setcsflagsandplatformize(entitlePlatformizePacket->EntitlePID);
            NSLog(@"Platformize PID %d", entitlePlatformizePacket->PlatformizePID);
            setcsflagsandplatformize(entitlePlatformizePacket->PlatformizePID);
        }
        
        else if (command == JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT_AFTER_DELAY){
            if (size < sizeof(struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT)){
                NSLog(@"Error: ENTITLE_SIGCONT packet is too small");
                continue;
            }
            struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT *entitleSIGCONTPacket = (struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT *)buf;
            NSLog(@"Entitle+SIGCONT PID %d", entitleSIGCONTPacket->Pid);
            __block int PID = entitleSIGCONTPacket->Pid;
            dispatch_queue_t queue = dispatch_queue_create("org.coolstar.jailbreakd.delayqueue", NULL);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), queue, ^{
                setcsflagsandplatformize(PID);
                kill(PID, SIGCONT);
            });
            dispatch_release(queue);
        }
        
        else if (command == JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT_FROM_XPCPROXY){
            if (size < sizeof(struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT)){
                NSLog(@"Error: ENTITLE_SIGCONT packet is too small");
                continue;
            }
            struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT *entitleSIGCONTPacket = (struct JAILBREAKD_ENTITLE_PID_AND_SIGCONT *)buf;
            NSLog(@"Entitle+SIGCONT PID %d", entitleSIGCONTPacket->Pid);
            __block int PID = entitleSIGCONTPacket->Pid;
            
            dispatch_queue_t queue = dispatch_queue_create("org.coolstar.jailbreakd.delayqueue", NULL);
            dispatch_async(queue, ^{
                char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
                bzero(pathbuf, sizeof(pathbuf));
                
                NSLog(@"%@", @"Waiting to ensure it's not xpcproxy anymore...");
                int ret = proc_pidpath(PID, pathbuf, sizeof(pathbuf));
                while (ret > 0 && strcmp(pathbuf, "/usr/libexec/xpcproxy") == 0){
                    proc_pidpath(PID, pathbuf, sizeof(pathbuf));
                    usleep(100);
                }
                
                NSLog(@"%@",@"Continuing!");
                setcsflagsandplatformize(PID);
                kill(PID, SIGCONT);
            });
            dispatch_release(queue);
        }

        else if (command == JAILBREAKD_COMMAND_FIXUP_SETUID){
            if (size < sizeof(struct JAILBREAKD_FIXUP_SETUID)){
                NSLog(@"Error: ENTITLE packet is too small");
                continue;
            }
            struct JAILBREAKD_FIXUP_SETUID *setuidPacket = (struct JAILBREAKD_FIXUP_SETUID *)buf;
            NSLog(@"Fixup setuid PID %d", setuidPacket->Pid);
            fixupsetuid(setuidPacket->Pid);
        }
        
        else if (command == JAILBREAKD_COMMAND_FIXUP_DYLIB) {
            if (size < sizeof(struct JAILBREAKD_FIXUP_DYLIB)){
                NSLog(@"Error: ENTITLE packet is too small");
                continue;
            }
            struct JAILBREAKD_FIXUP_DYLIB *dylibPacket = (struct JAILBREAKD_FIXUP_DYLIB *)buf;
            
            NSLog(@"Request to fixup dylib: %s", dylibPacket->dylib);
            fixupdylib(dylibPacket->dylib);
        }
        
        else if (command == JAILBREAKD_COMMAND_FIXUP_EXECUTABLE) {
            if (size < sizeof(struct JAILBREAKD_FIXUP_EXECUTABLE)){
                NSLog(@"Error: ENTITLE packet is too small");
                continue;
            }
            struct JAILBREAKD_FIXUP_EXECUTABLE *execPacket = (struct JAILBREAKD_FIXUP_EXECUTABLE *)buf;
            
            NSLog(@"Request to fixup executable: %s", execPacket->exec);
            fixupexec(execPacket->exec);
        }
        
        else if (command == JAILBREAKD_COMMAND_EXIT){
            NSLog(@"Got Exit Command! Goodbye!");
            term_kexecute();
            exit(0);
        }
    }

    /* Exit and clean up the child process. */
    _exit(0);
    return 0;
}

int main(int argc, char **argv, char **envp)
{
    int ret = runserver();
    exit(ret);
}

