#include <dlfcn.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <spawn.h>
#include <sys/types.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/sysctl.h>
#include <dlfcn.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <pthread.h>
#include <Foundation/Foundation.h>
#include "fishhook.h"
#include "common.h"

#define PSPAWN_PAYLOAD_DEBUG 1

#ifdef PSPAWN_PAYLOAD_DEBUG
#define LAUNCHD_LOG_PATH "/var/log/pspawn_payload_launchd.log"
// XXX multiple xpcproxies opening same file
// XXX not closing logfile before spawn
#define XPCPROXY_LOG_PATH "/var/log/pspawn_payload_xpcproxy.log"
FILE *log_file;
#define DEBUGLOG(fmt, args...)\
do {\
if (log_file == NULL) {\
log_file = fopen(XPCPROXY_LOG_PATH, "a"); \
if (log_file == NULL) break; \
} \
fprintf(log_file, fmt "\n", ##args); \
fflush(log_file); \
} while(0)
#else
#define DEBUGLOG(fmt, args...)
#endif

#define AMFID_PAYLOAD_DYLIB "/var/containers/Bundle/iosbinpack64/amfid_payload.dylib"
#define SBINJECT_PAYLOAD_DYLIB "/var/ulb/TweakInject.dylib"

const char* xpcproxy_blacklist[] = {
 "lskdmsed",                  // Netflix!
 "trustd",                    // Crash!
 "seputil",                   // Crash!
 "TVRemoteConnectionService", // Crash!
 "debugserver",               // Xcode debugging
 "com.apple.diagnosticd",     // syslog
 "MTLCompilerService",        // ?_?
 "OTAPKIAssetTool",           // h_h
 "cfprefsd",                  // o_o
 "jailbreakd",                // don't inject into jbd since we'd have to call to it
 NULL
 };

typedef int (*pspawn_t)(pid_t * pid, const char* path, const posix_spawn_file_actions_t *file_actions, posix_spawnattr_t *attrp, char const* argv[], const char* envp[]);

pspawn_t old_pspawn, old_pspawnp;

int fake_posix_spawn_common(pid_t * pid, const char* path, const posix_spawn_file_actions_t *file_actions, posix_spawnattr_t *attrp, char const* argv[], const char* envp[], pspawn_t old) {
    DEBUGLOG("We got called (fake_posix_spawn)! %s", path);
    
    const char *inject_me = SBINJECT_PAYLOAD_DYLIB;
    
    if (path != NULL) {
        const char **blacklist = xpcproxy_blacklist;
        
        while (*blacklist) {
            if (strstr(path, *blacklist)) {
                DEBUGLOG("xpcproxy for '%s' which is in blacklist, not injecting", path);
                inject_me = NULL;
                break;
            }
            ++blacklist;
        }
    }
    
    // XXX log different err on inject_me == NULL and nonexistent inject_me
    if (inject_me == NULL || !file_exist(inject_me)) {
        DEBUGLOG("Nothing to inject");
        return old(pid, path, file_actions, attrp, argv, envp);
    }
    
    if (strcmp(path, "/usr/libexec/amfid") == 0) {
        DEBUGLOG("Starting amfid -- special handling");
        inject_me = AMFID_PAYLOAD_DYLIB;
    }
 
    //if (strstr(path, "/var/containers/Bundle/Application") || strstr(path, "/usr/libexec")) calljailbreakdforexec((char *)path);
    
    DEBUGLOG("Injecting %s into %s", inject_me, path);
    
#ifdef PSPAWN_PAYLOAD_DEBUG
    if (argv != NULL){
        DEBUGLOG("Args: ");
        const char** currentarg = argv;
        while (*currentarg != NULL){
            DEBUGLOG("\t%s", *currentarg);
            currentarg++;
        }
    }
#endif
    
    int envcount = 0;
    
    if (envp != NULL){
        DEBUGLOG("Env: ");
        const char** currentenv = envp;
        while (*currentenv != NULL){
            DEBUGLOG("\t%s", *currentenv);
            if (strstr(*currentenv, "DYLD_INSERT_LIBRARIES") == NULL) {
                envcount++;
            }
            currentenv++;
        }
    }
    
    char const** newenvp = malloc((envcount+2) * sizeof(char **));
    int j = 0;
    for (int i = 0; i < envcount; i++){
        if (strstr(envp[j], "DYLD_INSERT_LIBRARIES") != NULL){
            continue;
        }
        newenvp[i] = envp[j];
        j++;
    }
    
    char *envp_inject = malloc(strlen("DYLD_INSERT_LIBRARIES=") + strlen(inject_me) + 1);
    
    envp_inject[0] = '\0';
    strcat(envp_inject, "DYLD_INSERT_LIBRARIES=");
    strcat(envp_inject, inject_me);
    
    newenvp[j] = envp_inject;
    newenvp[j+1] = NULL;
    
#ifdef PSPAWN_PAYLOAD_DEBUG
    DEBUGLOG("New Env:");
    const char** currentenv = newenvp;
    while (*currentenv != NULL){
        DEBUGLOG("\t%s", *currentenv);
        currentenv++;
    }
#endif
    
    posix_spawnattr_t attr;
    posix_spawnattr_t *newattrp = &attr;
    
    if (attrp) {
        newattrp = attrp;
        short flags;
        posix_spawnattr_getflags(attrp, &flags);
        flags |= POSIX_SPAWN_START_SUSPENDED;
        posix_spawnattr_setflags(attrp, flags);
    } else {
        posix_spawnattr_init(&attr);
        posix_spawnattr_setflags(&attr, POSIX_SPAWN_START_SUSPENDED);
    }
    
    int origret;
    
    // dont leak logging fd into execd process
#ifdef PSPAWN_PAYLOAD_DEBUG
    if (log_file != NULL) {
        fclose(log_file);
        log_file = NULL;
    }
#endif
    
    calljailbreakd(getpid(), JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT_FROM_XPCPROXY);
    
    // dont leak jbd fd into execd process
    closejailbreakfd();

    origret = old(pid, path, file_actions, newattrp, argv, newenvp);
    
    return origret;
}


int fake_posix_spawn(pid_t * pid, const char* file, const posix_spawn_file_actions_t *file_actions, posix_spawnattr_t *attrp, const char* argv[], const char* envp[]) {
    return fake_posix_spawn_common(pid, file, file_actions, attrp, argv, envp, old_pspawn);
}

int fake_posix_spawnp(pid_t * pid, const char* file, const posix_spawn_file_actions_t *file_actions, posix_spawnattr_t *attrp, const char* argv[], const char* envp[]) {
    return fake_posix_spawn_common(pid, file, file_actions, attrp, argv, envp, old_pspawnp);
}

void rebind_pspawns(void) {
    struct rebinding rebindings[] = {
        {"posix_spawn", (void *)fake_posix_spawn, (void **)&old_pspawn},
        {"posix_spawnp", (void *)fake_posix_spawnp, (void **)&old_pspawnp},
    };
    
    rebind_symbols(rebindings, 2);
}

__attribute__ ((constructor))
static void ctor(void) {
    rebind_pspawns();
}
