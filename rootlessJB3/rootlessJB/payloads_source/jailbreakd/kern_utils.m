#import <Foundation/Foundation.h>
#import <sys/stat.h>
#import <spawn.h>
#import "kern_utils.h"
#import "kmem.h"
#import "patchfinder64.h"
#import "kexecute.h"
#import "offsetof.h"
#import "osobject.h"
#import "sandbox.h"
#import "offsets.h"
#import "cs_blob.h"

#define PROC_PIDPATHINFO_MAXSIZE  (4*MAXPATHLEN)
int proc_pidpath(pid_t pid, void *buffer, uint32_t buffersize);

uint64_t proc_find(int pd, int tries) {
    // TODO use kcall(proc_find) + ZM_FIX_ADDR
    while (tries-- > 0) {
        uint64_t proc = rk64(find_allproc());
        while (proc) {
            uint32_t pid = rk32(proc + offsetof_p_pid);
            if (pid == pd) {
                return proc;
            }
            proc = rk64(proc);
        }
    }
    return 0;
}

CACHED_FIND(uint64_t, our_task_addr) {
    uint64_t our_proc = proc_find(getpid(), 1);
    
    if (our_proc == 0) {
        printf("failed to find our_task_addr!\n");
        exit(EXIT_FAILURE);
    }
    
    uint64_t addr = rk64(our_proc + offsetof_task);
    printf("our_task_addr: 0x%llx\n", addr);
    return addr;
}

uint64_t find_port(mach_port_name_t port){
    uint64_t task_addr = our_task_addr();
    
    uint64_t itk_space = rk64(task_addr + offsetof_itk_space);
    
    uint64_t is_table = rk64(itk_space + offsetof_ipc_space_is_table);
    
    uint32_t port_index = port >> 8;
    const int sizeof_ipc_entry_t = 0x18;
    
    uint64_t port_addr = rk64(is_table + (port_index * sizeof_ipc_entry_t));
    return port_addr;
}

void fixupsetuid(int pid){
    char pathbuf[PROC_PIDPATHINFO_MAXSIZE];
    bzero(pathbuf, sizeof(pathbuf));
    
    int ret = proc_pidpath(pid, pathbuf, sizeof(pathbuf));
    if (ret < 0){
        NSLog(@"Unable to get path for PID %d", pid);
        return;
    }
    struct stat file_st;
    if (lstat(pathbuf, &file_st) == -1){
        NSLog(@"Unable to get stat for file %s", pathbuf);
        return;
    }
    if (file_st.st_mode & S_ISUID){
        uid_t fileUID = file_st.st_uid;
        NSLog(@"Fixing up setuid for file owned by %u", fileUID);
        
        uint64_t proc = proc_find(pid, 3);
        if (proc != 0) {
            uint64_t ucred = rk64(proc + offsetof_p_ucred);
            
            uid_t cr_svuid = rk32(ucred + offsetof_ucred_cr_svuid);
            NSLog(@"Original sv_uid: %u", cr_svuid);
            wk32(ucred + offsetof_ucred_cr_svuid, fileUID);
            NSLog(@"New sv_uid: %u", fileUID);
        }
    } else {
        NSLog(@"File %s is not setuid!", pathbuf);
        return;
    }
}

extern struct offsets off;
extern uint64_t kernel_slide;

int vnode_lookup(const char *path, int flags, uint64_t *vnode, uint64_t vfs_context) {
    
    size_t len = strlen(path) + 1;
    uint64_t ptr = kalloc(8);
    uint64_t ptr2 = kalloc(len);
    kwrite(ptr2, path, len);
    
    if (kexecute(off.vnode_lookup + kernel_slide, ptr2, flags, ptr, vfs_context, 0, 0, 0)) {
        return -1;
    }
    
    *vnode = rk64(ptr);
    kfree(ptr2, len);
    kfree(ptr, 8);
    return 0;
}

int vnode_put(uint64_t vnode) {
    //if (off.vnode_put) {
        return kexecute(off.vnode_put + kernel_slide, vnode, 0, 0, 0, 0, 0, 0);
    //}
    
    /*//uint32_t usecount = rk32(vnode + 0x60);
    uint32_t iocount = rk32(vnode + 0x64);
    
    if (iocount <= 1) return 0;
    
    //if (iocount > 1) {
        iocount--;
        wk32(vnode + 0x64, iocount);
    //}
    
    return 0;*/
}

uint64_t get_vfs_context() {
    return zm_fix_addr(kexecute(off.vfs_context + kernel_slide, 1, 0, 0, 0, 0, 0, 0));
}

uint64_t getVnodeAtPath(const char *path) {
    uint64_t *vnode_ptr = (uint64_t *)malloc(8);
    if (vnode_lookup(path, 0, vnode_ptr, get_vfs_context())) {
        NSLog(@"Unable to get vnode from path for %s\n", path);
        free(vnode_ptr);
        return 0;
    }
    else {
        uint64_t vnode = *vnode_ptr;
        free(vnode_ptr);
        return vnode;
    }
}

// sandbox doesn't allow mmap() from /var (except app's own container)
// checked by mpo_file_check_mmap() in sandbox kext
// it returns 0 on "allow" or something on "deny"
// patching that is a no no cus KPP/KTRR
// Apple was kind enough to add a shortcut
// if dylib is on dyld_shared_cache all checks are bypassed
// checked by vnode_isdyldsharedcache(), which just checks if VSHARED_DYLD is on dylib's vnode
// So add that flag and we're in

// vp->v_flags |= VSHARED_DYLD

int fixupdylib(char *dylib) {
    NSLog(@"Fixing up dylib %s", dylib);
    
#define VSHARED_DYLD 0x000200
    
    NSLog(@"Getting vnode");
    uint64_t vnode = getVnodeAtPath(dylib);
    
    if (!vnode) {
        NSLog(@"Failed to get vnode!");
        return -1;
    }
    
    NSLog(@"vnode of %s: 0x%llx", dylib, vnode);
    
    uint32_t v_flags = rk32(vnode + offsetof_v_flags);
    if (v_flags & VSHARED_DYLD) {
        vnode_put(vnode);
        return 0;
    }
    
    NSLog(@"old v_flags: 0x%x", v_flags);
    
    wk32(vnode + offsetof_v_flags, v_flags | VSHARED_DYLD);
    
    v_flags = rk32(vnode + offsetof_v_flags);
    NSLog(@"new v_flags: 0x%x", v_flags);

    vnode_put(vnode);
    
    return !(v_flags & VSHARED_DYLD);
}


void set_csflags(uint64_t proc) {
    uint32_t csflags = rk32(proc + offsetof_p_csflags);
    NSLog(@"Previous CSFlags: 0x%x", csflags);
    csflags = (csflags | CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW | CS_DEBUGGED) & ~(CS_RESTRICT | CS_HARD | CS_KILL);
    NSLog(@"New CSFlags: 0x%x", csflags);
    wk32(proc + offsetof_p_csflags, csflags);
}

void set_tfplatform(uint64_t proc) {
    // task.t_flags & TF_PLATFORM
    uint64_t task = rk64(proc + offsetof_task);
    uint32_t t_flags = rk32(task + offsetof_t_flags);
    
    NSLog(@"Old t_flags: 0x%x", t_flags);
    
    t_flags |= TF_PLATFORM;
    wk32(task+offsetof_t_flags, t_flags);
    
    NSLog(@"New t_flags: 0x%x", t_flags);
    
}


void set_csblob(uint64_t proc) {
    uint64_t textvp = rk64(proc + offsetof_p_textvp); //vnode of executable
    off_t textoff = rk64(proc + offsetof_p_textoff);
    
    
    NSLog(@"\t__TEXT at 0x%llx. Offset: 0x%llx", textvp, textoff);
    
    if (textvp != 0){
        uint32_t vnode_type_tag = rk32(textvp + offsetof_v_type);
        uint16_t vnode_type = vnode_type_tag & 0xffff;
        uint16_t vnode_tag = (vnode_type_tag >> 16);
        
        NSLog(@"\tVNode Type: 0x%x. Tag: 0x%x.", vnode_type, vnode_tag);
        
        
        if (vnode_type == 1){
            uint64_t ubcinfo = rk64(textvp + offsetof_v_ubcinfo);
            
            NSLog(@"\t\tUBCInfo at 0x%llx.\n", ubcinfo);
            
            
            uint64_t csblobs = rk64(ubcinfo + offsetof_ubcinfo_csblobs);
            while (csblobs != 0){
                
                NSLog(@"\t\t\tCSBlobs at 0x%llx.", csblobs);
                
                
                cpu_type_t csblob_cputype = rk32(csblobs + offsetof_csb_cputype);
                unsigned int csblob_flags = rk32(csblobs + offsetof_csb_flags);
                off_t csb_base_offset = rk64(csblobs + offsetof_csb_base_offset);
                uint64_t csb_entitlements = rk64(csblobs + offsetof_csb_entitlements_offset);
                unsigned int csb_signer_type = rk32(csblobs + offsetof_csb_signer_type);
                unsigned int csb_platform_binary = rk32(csblobs + offsetof_csb_platform_binary);
                unsigned int csb_platform_path = rk32(csblobs + offsetof_csb_platform_path);
                
                
                NSLog(@"\t\t\tCSBlob CPU Type: 0x%x. Flags: 0x%x. Offset: 0x%llx", csblob_cputype, csblob_flags, csb_base_offset);
                NSLog(@"\t\t\tCSBlob Signer Type: 0x%x. Platform Binary: %d Path: %d", csb_signer_type, csb_platform_binary, csb_platform_path);
                
                wk32(csblobs + offsetof_csb_platform_binary, 1);
                
                csb_platform_binary = rk32(csblobs + offsetof_csb_platform_binary);
                
                NSLog(@"\t\t\tCSBlob Signer Type: 0x%x. Platform Binary: %d Path: %d", csb_signer_type, csb_platform_binary, csb_platform_path);
                
                NSLog(@"\t\t\t\tEntitlements at 0x%llx.\n", csb_entitlements);
                
                csblobs = rk64(csblobs);
            }
        }
    }
}

const char* abs_path_exceptions[] = {
    "/private/var/containers/Bundle/iosbinpack64",
    "/private/var/containers/Bundle/tweaksupport",
    // XXX there's some weird stuff about linking and special
    // handling for /private/var/mobile/* in sandbox
    "/private/var/mobile/Library",
    "/private/var/mnt",
    NULL
};

uint64_t get_exception_osarray(void) {
    static uint64_t cached = 0;
    
    if (cached == 0) {
        // XXX use abs_path_exceptions
        cached = OSUnserializeXML("<array>"
                                  "<string>/private/var/containers/Bundle/iosbinpack64/</string>"
                                  "<string>/private/var/containers/Bundle/tweaksupport/</string>"
                                  "<string>/private/var/mobile/Library/</string>"
                                  "<string>/private/var/mnt/</string>"
                                  "</array>");
    }
    
    return cached;
}

static const char *exc_key = "com.apple.security.exception.files.absolute-path.read-only";

void set_amfi_entitlements(uint64_t proc) {
    // AMFI entitlements
    
    NSLog(@"%@",@"AMFI:");
    
    uint64_t proc_ucred = rk64(proc+0xf8);
    uint64_t amfi_entitlements = rk64(rk64(proc_ucred+0x78)+0x8);
    
    NSLog(@"%@",@"Setting Entitlements...");
    
    
    OSDictionary_SetItem(amfi_entitlements, "get-task-allow", find_OSBoolean_True());
    OSDictionary_SetItem(amfi_entitlements, "com.apple.private.skip-library-validation", find_OSBoolean_True());
    
    /*uint64_t present = OSDictionary_GetItem(amfi_entitlements, exc_key);
    
    int rv = 0;
    
    if (present == 0) {
        rv = OSDictionary_SetItem(amfi_entitlements, exc_key, get_exception_osarray());
    } else if (present != get_exception_osarray()) {
        unsigned int itemCount = OSArray_ItemCount(present);
        
        NSLog(@"present != 0 (0x%llx)! item count: %d", present, itemCount);
        
        BOOL foundEntitlements = NO;
        
        uint64_t itemBuffer = OSArray_ItemBuffer(present);
        
        for (int i = 0; i < itemCount; i++){
            uint64_t item = rk64(itemBuffer + (i * sizeof(void *)));
            NSLog(@"Item %d: 0x%llx", i, item);
            char *entitlementString = OSString_CopyString(item);
            if (strstr(entitlementString, "tweaksupport") != 0) {
                foundEntitlements = YES;
                free(entitlementString);
                break;
            }
            free(entitlementString);
        }
        
        if (!foundEntitlements){
            rv = OSArray_Merge(present, get_exception_osarray());
        } else {
            rv = 1;
        }
    } else {
        NSLog(@"Not going to merge array with itself :P");
        rv = 1;
    }
    
    if (rv != 1) {
        NSLog(@"Setting exc FAILED! amfi_entitlements: 0x%llx present: 0x%llx\n", amfi_entitlements, present);
    }*/
}

const char *ents =  "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
"<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">"
"<plist version=\"1.0\">"
"<dict>"
"<key>com.apple.security.exception.files.absolute-path.read-only</key>" // bypass stat()
"<array>"
"<string>/private/var/containers/Bundle/iosbinpack64/</string>"
"<string>/private/var/containers/Bundle/tweaksupport/</string>"
"<string>/private/var/mobile/Library/</string>"
"<string>/private/var/mnt/</string>"
"</array>"
"<key>platform-application</key>" // platform
"<true/>"
"<key>get-task-allow</key>" // allow task_for_pid() on that process
"<true/>"
"<key>com.apple.private.skip-library-validation</key>" // invalid libs
"<true/>"
"</dict>"
"</plist>";

static uint64_t entitlement_blob = 0;
static uint64_t unserialized_blob = 0;

int fixupexec(char *file) {
    
    int fd;
    if ((fd = open(file, O_RDONLY)) < 0) {
        NSLog(@"[-] Failed to open file '%s'\n", file);
        return -1;
    }
    
    uint32_t magic;
    read(fd, &magic, 4);
    if (magic != 0xFEEDFACF && magic != 0xBEBAFECA) {
        NSLog(@"[-] File '%s' is not a mach-o\n", file);
        close(fd);
        return -1;
    }
    close(fd);
    
    pid_t pd;
    const char* args[] = {file, NULL};
    
    posix_spawnattr_t attr;
    posix_spawnattr_init(&attr);
    posix_spawnattr_setflags(&attr, POSIX_SPAWN_START_SUSPENDED);
    
    int rv = posix_spawn(&pd, file, NULL, &attr, (char **)&args, NULL);
    
    if (!rv) {
        kill(pd, SIGKILL);
    }
    else {
        NSLog(@"[-] Can't exec file '%s', err: %d (%s) \n", file, rv, strerror(rv));
        return -1;
    }
    
    uint64_t vnode = getVnodeAtPath(file);
    if (!vnode) {
        NSLog(@"[-] Failed to get vnode for '%s'\n", file);
        return -1;
    }
    NSLog(@"[*] Found vnode: 0x%llx\n", vnode);
    
    uint16_t vtype;
    kread(vnode + offsetof_v_type, &vtype, sizeof(uint16_t));
    if (vtype != 1) {
        NSLog(@"%s", "[-] Vnode does not have correct type\n");
        goto fail;
    }
    
    uint64_t ubc_info = rk64(vnode + offsetof_v_ubcinfo);
    if (!ubc_info) {
        NSLog(@"%s", "[-] No ubc_info?\n");
        goto fail;
    }
    NSLog(@"[*] ubc_info: 0x%llx\n", ubc_info);
    
    uint64_t cs_blobs = rk64(ubc_info + offsetof_ubcinfo_csblobs);
    if (!cs_blobs) {
        NSLog(@"%s", "[-] No cs_blobs?\n");
        goto fail;
    }
    NSLog(@"[*] cs_blobs: 0x%llx\n", cs_blobs);
    
    struct cs_blob csblobs;
    kread(cs_blobs, &csblobs, sizeof(struct cs_blob));
    
    uint64_t entitlements_blob = (uint64_t)csblobs.csb_entitlements;
    NSLog(@"[*] Blob: 0x%llx\n", entitlements_blob);
    
    if (!entitlements_blob) {
        NSLog(@"%s", "[*] Found no entitlements.");
        
        if (!unserialized_blob) {
            NSLog(@"%s", "[*] Generating...");
            unserialized_blob = OSUnserializeXML(ents);
            if (!unserialized_blob) {
                NSLog(@"%s", "[-] Failed to create dictionary...\n");
                goto fail;
            }
        }
        csblobs.csb_entitlements = (void*)unserialized_blob;
        
        if (!entitlement_blob) {
            NSLog(@"%s", "[*] Creating a raw blob\n");
            
            uint32_t size = strlen(ents) + sizeof(CS_GenericBlob);
            
            CS_GenericBlob *blob = malloc(size);
            blob->magic = CSMAGIC_EMBEDDED_ENTITLEMENTS;
            blob->length = ntohl(size);
            memcpy(blob->data, ents, strlen(ents) + 1);
            
            entitlement_blob = kalloc(size);
            NSLog(@"[*] New blob: 0x%llx\n", entitlement_blob);
            kwrite(entitlement_blob, blob, size);
            
            free(blob);
        }
        csblobs.csb_entitlements_blob = (CS_GenericBlob*)entitlement_blob;
    }
    else {
        NSLog(@"%s", "[*] Found some entitlements!");
        
        if (!OSDictionary_GetItem(entitlements_blob, "platform-application")) OSDictionary_SetItem(entitlements_blob, "platform-application", find_OSBoolean_True());
        if (!OSDictionary_GetItem(entitlements_blob, "com.apple.private.skip-library-validation")) OSDictionary_SetItem(entitlements_blob, "com.apple.private.skip-library-validation", find_OSBoolean_True());
        if (!OSDictionary_GetItem(entitlements_blob, "get-task-allow")) OSDictionary_SetItem(entitlements_blob, "get-task-allow", find_OSBoolean_True());
        
        uint64_t present = OSDictionary_GetItem(entitlements_blob, "com.apple.security.exception.files.absolute-path.read-only");
        
        if (!present) OSDictionary_SetItem(entitlements_blob, "com.apple.security.exception.files.absolute-path.read-only", get_exception_osarray());
        else if (present != get_exception_osarray()) {
            unsigned int itemCount = OSArray_ItemCount(present);
            
            NSLog(@"present != 0 (0x%llx)! item count: %d", present, itemCount);
            
            BOOL foundEntitlements = NO;
            
            uint64_t itemBuffer = OSArray_ItemBuffer(present);
            
            for (int i = 0; i < itemCount; i++){
                uint64_t item = rk64(itemBuffer + (i * sizeof(void *)));
                NSLog(@"Item %d: 0x%llx", i, item);
                char *entitlementString = OSString_CopyString(item);
                if (strstr(entitlementString, "tweaksupport") != 0) {
                    foundEntitlements = YES;
                    free(entitlementString);
                    break;
                }
                free(entitlementString);
            }
            
            if (!foundEntitlements){
                rv = OSArray_Merge(present, get_exception_osarray());
            } else {
                rv = 1;
            }
        } else {
            NSLog(@"Not going to merge array with itself :P");
            rv = 1;
        }
    }
    
    csblobs.csb_flags |= ((CS_PLATFORM_BINARY | CS_INSTALLER | CS_GET_TASK_ALLOW | CS_DEBUGGED) & ~(CS_RESTRICT | CS_HARD | CS_KILL));
    csblobs.csb_platform_binary = 1;
    csblobs.csb_platform_path = 0;
    
    printf("[*] Success? Writing the blob!\n");
    
    kwrite(cs_blobs, &csblobs, sizeof(struct cs_blob));
    goto exit;
    
exit:;
    vnode_put(vnode);
    return 0;
fail:;
    vnode_put(vnode);
    return 1;
}

void set_sandbox_extensions(uint64_t proc) {
    uint64_t proc_ucred = rk64(proc + offsetof_p_ucred);
    uint64_t sandbox = rk64(rk64(proc_ucred + 0x78) + 0x10);
    
    char name[40] = {0};
    kread(proc + 0x250, name, 20);
    
    NSLog(@"proc = 0x%llx & proc_ucred = 0x%llx & sandbox = 0x%llx", proc, proc_ucred, sandbox);
    
    if (sandbox == 0) {
        NSLog(@"no sandbox, skipping");
        return;
    }
    
    if (has_file_extension(sandbox, abs_path_exceptions[0])) {
        NSLog(@"already has '%s', skipping", abs_path_exceptions[0]);
        return;
    }
    
    uint64_t ext = 0;
    const char** path = abs_path_exceptions;
    while (*path != NULL) {
        ext = extension_create_file(*path, ext);
        if (ext == 0) {
            NSLog(@"extension_create_file(%s) failed, panic!", *path);
        }
        ++path;
    }
    
    NSLog(@"last extension_create_file ext: 0x%llx", ext);
    
    if (ext != 0) {
        extension_add(ext, sandbox, exc_key);
    }
}

int setcsflagsandplatformize(int pid){
    fixupdylib("/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
    uint64_t proc = proc_find(pid, 3);
    if (proc != 0) {
        set_csflags(proc);
        set_tfplatform(proc);
        set_amfi_entitlements(proc);
        set_sandbox_extensions(proc);
        //set_csblob(proc);
        NSLog(@"setcsflagsandplatformize on PID %d", pid);
        return 0;
    }
    NSLog(@"Unable to find PID %d to entitle!", pid);
    return 1;
}

int unsandbox(int pid) {
    uint64_t proc = proc_find(pid, 3);
    uint64_t proc_ucred = rk64(proc + offsetof_p_ucred);
    uint64_t sandbox = rk64(rk64(proc_ucred+0x78) + 8 + 8);
    if (sandbox == 0) {
        NSLog(@"Already unsandboxed");
        return 0;
    } else {
        NSLog(@"Unsandboxing pid %d", pid);
        wk64(rk64(proc_ucred+0x78) + 8 + 8, 0);
        sandbox = rk64(rk64(proc_ucred+0x78) + 8 + 8);
        if (sandbox == 0) return 0;
    }
    return -1;
}

