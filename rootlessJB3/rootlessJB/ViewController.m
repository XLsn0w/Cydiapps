//
//  ViewController.m
//  rootlessJB
//
//  Created by Jake James on 8/28/18.
//  Copyright © 2018 Jake James. All rights reserved.
//

#import "ViewController.h"
#import "jelbrekLib.h"
#import "exploit/voucher_swap/voucher_swap.h"
#import "libjb.h"
#import "payload.h"
#import "offsetsDump.h"
#import "exploit/voucher_swap/kernel_slide.h"
#import "insert_dylib.h"
#import "vnode.h"
#import "exploit/v3ntex/exploit.h"

#import <mach/mach.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import <dlfcn.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UISwitch *enableTweaks;
@property (weak, nonatomic) IBOutlet UIButton *jailbreakButton;
@property (weak, nonatomic) IBOutlet UISwitch *installiSuperSU;

@property (weak, nonatomic) IBOutlet UITextView *logs;
@end

@implementation ViewController

-(void)log:(NSString*)log {
    self.logs.text = [NSString stringWithFormat:@"%@%@", self.logs.text, log];
}

#define LOG(what, ...) [self log:[NSString stringWithFormat:@what"\n", ##__VA_ARGS__]];\
printf("\t"what"\n", ##__VA_ARGS__)

#define in_bundle(obj) strdup([[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@obj] UTF8String])

#define failIf(condition, message, ...) if (condition) {\
LOG(message);\
goto end;\
}

#define maxVersion(v)  ([[[UIDevice currentDevice] systemVersion] compare:@v options:NSNumericSearch] != NSOrderedDescending)


#define fileExists(file) [[NSFileManager defaultManager] fileExistsAtPath:@(file)]
#define removeFile(file) if (fileExists(file)) {\
[[NSFileManager defaultManager]  removeItemAtPath:@(file) error:&error]; \
if (error) { \
LOG("[-] Error: removing file %s (%s)", file, [[error localizedDescription] UTF8String]); \
error = NULL; \
}\
}

#define copyFile(copyFrom, copyTo) [[NSFileManager defaultManager] copyItemAtPath:@(copyFrom) toPath:@(copyTo) error:&error]; \
if (error) { \
LOG("[-] Error copying item %s to path %s (%s)", copyFrom, copyTo, [[error localizedDescription] UTF8String]); \
error = NULL; \
}

#define moveFile(copyFrom, moveTo) [[NSFileManager defaultManager] moveItemAtPath:@(copyFrom) toPath:@(moveTo) error:&error]; \
if (error) {\
LOG("[-] Error moviing item %s to path %s (%s)", copyFrom, moveTo, [[error localizedDescription] UTF8String]); \
error = NULL; \
}

int system_(char *cmd) {
    return launch("/var/bin/bash", "-c", cmd, NULL, NULL, NULL, NULL, NULL);
}

struct utsname u;
vm_size_t psize;
int csops(pid_t pid, unsigned int  ops, void * useraddr, size_t usersize);

- (void)viewDidLoad {
    [super viewDidLoad];
    
    uint32_t flags;
    csops(getpid(), 0, &flags, 0);
    
    if ((flags & 0x4000000)) { // platform
        [self.jailbreakButton setTitle:@"Jailbroken" forState:UIControlStateNormal];
        [self.jailbreakButton setEnabled:NO];
        [self.enableTweaks setEnabled:NO];
        [self.installiSuperSU setEnabled:NO];
    }
    
    uname(&u);
    if (strstr(u.machine, "iPad5,")) psize = 0x1000;
    else _host_page_size(mach_host_self(), &psize);
}

- (IBAction)jailbreak:(id)sender {
    //---- tfp0 ----//
    __block mach_port_t taskforpidzero = MACH_PORT_NULL;
    
    uint64_t sb = 0;
    BOOL debug = NO; // kids don't enable this
    
    // for messing with files
    NSError *error = NULL;
    NSArray *plists;
    
    if (debug) {
        kern_return_t ret = host_get_special_port(mach_host_self(), HOST_LOCAL_NODE, 4, &taskforpidzero);
        if (ret) {
            printf("[-] Error using hgsp! '%s'\n", mach_error_string(ret));
            printf("[*] Using exploit!\n");
            
            if (psize == 0x1000 && maxVersion("12.4.1")) {
                
                // v3ntex is so bad we have to treat it specially for it not to freak out
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                dispatch_group_t group = dispatch_group_create();
                dispatch_semaphore_t sm = dispatch_semaphore_create(0);
                
                dispatch_group_async(group, queue, ^{
                    taskforpidzero = v3ntex();
                    dispatch_semaphore_signal(sm);
                });
                
                dispatch_semaphore_wait(sm, DISPATCH_TIME_FOREVER);
            }
            
            else if (maxVersion("12.1.2")) {
                taskforpidzero = voucher_swap();
            }
            else {
                [sender setTitle:@"Not supported!" forState:UIControlStateNormal];
                [sender setEnabled:false];
                return;
            }
            if (!MACH_PORT_VALID(taskforpidzero)) {
                LOG("[-] Exploit failed");
                LOG("[i] Please try again");
                sleep(1);
                return;
            }
        }
    }
    else {
        if (psize == 0x1000 && maxVersion("12.1.2")) {
            
            // v3ntex is so bad we have to treat it specially for it not to freak out
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_group_t group = dispatch_group_create();
            dispatch_semaphore_t sm = dispatch_semaphore_create(0);
            
            dispatch_group_async(group, queue, ^{
                taskforpidzero = v3ntex();
                dispatch_semaphore_signal(sm);
            });
            
            dispatch_semaphore_wait(sm, DISPATCH_TIME_FOREVER);
        }
        
        else if (maxVersion("12.1.2")) {
            taskforpidzero = voucher_swap();
        }
        else {
            [sender setTitle:@"Not supported!" forState:UIControlStateNormal];
            [sender setEnabled:false];
            return;
        }
        if (!MACH_PORT_VALID(taskforpidzero)) {
            LOG("[-] Exploit failed");
            LOG("[i] Please try again");
            sleep(1);
            return;
        }
    }
    LOG("[*] Starting fun");
    
    if (!KernelBase) {
        kernel_slide_init();
        init_with_kbase(taskforpidzero, 0xfffffff007004000 + kernel_slide);
    }
    else init_with_kbase(taskforpidzero, KernelBase);
    
    LOG("[i] Kernel base: 0x%llx", KernelBase);
    
    //---- basics ----//
    rootify(getpid()); // give us root
    failIf(getuid(), "[-] Failed to get root");
    LOG("[i] uid: %d\n", getuid());
    
    sb = unsandbox(getpid()); // escape sandbox
    FILE *f = fopen("/var/mobile/.roottest", "w");
    failIf(!f, "[-] Failed to escape sandbox!");
    
    LOG("[+] Escaped sandbox!\n\tWrote file %p", f);
    fclose(f);
    removeFile("/var/mobile/.roottest");
    
    setcsflags(getpid()); // set some csflags
    platformize(getpid()); // set TF_PLATFORM
    
    //---- host special port 4 ----//
    failIf(setHSP4(), "[-] Failed to set tfp0 as hsp4!");
    if (debug) PatchHostPriv(mach_host_self());
    
    //---- remount -----//
    // this is against the point of this jb but if you can why not do it
    
    if (maxVersion("11.4.1")) {
        if (remountRootFS()) LOG("[-] Failed to remount rootfs, no big deal");
    }
    
    //---- nvram ----//
    // people say that this ain't stable
    // and that ya should lock it later
    // but, I haven't experienced issues
    // nor so rootlessJB people
    
    UnlockNVRAM(); // use nvram command for nonce setting!
    
    //---- bootstrap ----//
    if (!fileExists("/var/containers/Bundle/.installed_rootlessJB3")) {
        
        if (fileExists("/var/containers/Bundle/iosbinpack64")) {
            
            LOG("[*] Uninstalling previous build...");
            
            removeFile("/var/LIB");
            removeFile("/var/ulb");
            removeFile("/var/bin");
            removeFile("/var/sbin");
            removeFile("/var/containers/Bundle/tweaksupport/Applications");
            removeFile("/var/Apps");
            removeFile("/var/profile");
            removeFile("/var/motd");
            removeFile("/var/dropbear");
            removeFile("/var/containers/Bundle/tweaksupport");
            removeFile("/var/containers/Bundle/iosbinpack64");
            removeFile("/var/containers/Bundle/dylibs");
            removeFile("/var/log/testbin.log");
            
            if (fileExists("/var/log/jailbreakd-stdout.log")) removeFile("/var/log/jailbreakd-stdout.log");
            if (fileExists("/var/log/jailbreakd-stderr.log")) removeFile("/var/log/jailbreakd-stderr.log");
        }
        
        LOG("[*] Installing bootstrap...");
        
        chdir("/var/containers/Bundle/");
        FILE *bootstrap = fopen((char*)in_bundle("tars/iosbinpack.tar"), "r");
        untar(bootstrap, "/var/containers/Bundle/");
        fclose(bootstrap);
        
        FILE *tweaks = fopen((char*)in_bundle("tars/tweaksupport.tar"), "r");
        untar(tweaks, "/var/containers/Bundle/");
        fclose(tweaks);
        
        failIf(!fileExists("/var/containers/Bundle/tweaksupport") || !fileExists("/var/containers/Bundle/iosbinpack64"), "[-] Failed to install bootstrap");
        
        LOG("[+] Creating symlinks...");
        
        symlink("/var/containers/Bundle/tweaksupport/Library", "/var/LIB");
        symlink("/var/containers/Bundle/tweaksupport/usr/lib", "/var/ulb");
        symlink("/var/containers/Bundle/tweaksupport/Applications", "/var/Apps");
        symlink("/var/containers/Bundle/tweaksupport/bin", "/var/bin");
        symlink("/var/containers/Bundle/tweaksupport/sbin", "/var/sbin");
        symlink("/var/containers/Bundle/tweaksupport/usr/libexec", "/var/libexec");
        
        close(open("/var/containers/Bundle/.installed_rootlessJB3", O_CREAT));
        
        //limneos
        symlink("/var/containers/Bundle/iosbinpack64/etc", "/var/etc");
        symlink("/var/containers/Bundle/tweaksupport/usr", "/var/usr");
        symlink("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "/var/bin/killall");
        
        LOG("[+] Installed bootstrap!");
    }
    
    //---- for jailbreakd & amfid ----//
    failIf(dumpOffsetsToFile("/var/containers/Bundle/tweaksupport/offsets.data"), "[-] Failed to save offsets");
    
    //---- different tools ----//
    
    if (!fileExists("/var/bin/strings")) {
        chdir("/");
        FILE *essentials = fopen((char*)in_bundle("tars/bintools.tar"), "r");
        untar(essentials, "/");
        fclose(essentials);
        
        FILE *dpkg = fopen((char*)in_bundle("tars/dpkg-rootless.tar"), "r");
        untar(dpkg, "/");
        fclose(dpkg);
    }
   
    //---- update dropbear ----//
    chdir("/var/containers/Bundle/");
    
    removeFile("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear");
    removeFile("/var/containers/Bundle/iosbinpack64/usr/bin/scp");

    FILE *fixed_dropbear = fopen((char*)in_bundle("tars/dropbear.v2018.76.tar"), "r");
    untar(fixed_dropbear, "/var/containers/Bundle/");
    fclose(fixed_dropbear);
    
    //---- update jailbreakd ----//
    
    removeFile("/var/containers/Bundle/iosbinpack64/bin/jailbreakd");
    if (!fileExists(in_bundle("bins/jailbreakd"))) {
        chdir(in_bundle("bins/"));
        
        FILE *jbd = fopen(in_bundle("bins/jailbreakd.tar"), "r");
        untar(jbd, in_bundle("bins/jailbreakd"));
        fclose(jbd);
        
        removeFile(in_bundle("bins/jailbreakd.tar"));
    }
    copyFile(in_bundle("bins/jailbreakd"), "/var/containers/Bundle/iosbinpack64/bin/jailbreakd");
    
    removeFile("/var/containers/Bundle/iosbinpack64/pspawn.dylib");
    if (!fileExists(in_bundle("bins/pspawn.dylib"))) {
        chdir(in_bundle("bins/"));
        
        FILE *jbd = fopen(in_bundle("bins/pspawn.dylib.tar"), "r");
        untar(jbd, in_bundle("bins/pspawn.dylib"));
        fclose(jbd);
        
        removeFile(in_bundle("bins/pspawn.dylib.tar"));
    }
    copyFile(in_bundle("bins/pspawn.dylib"), "/var/containers/Bundle/iosbinpack64/pspawn.dylib");
    
    removeFile("/var/containers/Bundle/iosbinpack64/amfid_payload.dylib");
    if (!fileExists(in_bundle("bins/amfid_payload.dylib"))) {
        chdir(in_bundle("bins/"));
        
        FILE *jbd = fopen(in_bundle("bins/amfid_payload.dylib.tar"), "r");
        untar(jbd, in_bundle("bins/amfid_payload.dylib"));
        fclose(jbd);
        
        removeFile(in_bundle("bins/amfid_payload.dylib.tar"));
    }
    copyFile(in_bundle("bins/amfid_payload.dylib"), "/var/containers/Bundle/iosbinpack64/amfid_payload.dylib");
    
    removeFile("/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
    if (!fileExists(in_bundle("bins/TweakInject.dylib"))) {
        chdir(in_bundle("bins/"));
        
        FILE *jbd = fopen(in_bundle("bins/TweakInject.tar"), "r");
        untar(jbd, in_bundle("bins/TweakInject.dylib"));
        fclose(jbd);
        
        removeFile(in_bundle("bins/TweakInject.tar"));
    }
    copyFile(in_bundle("bins/TweakInject.dylib"), "/var/containers/Bundle/tweaksupport/usr/lib/TweakInject.dylib");
    
    removeFile("/var/log/pspawn_payload_xpcproxy.log");
    
    //---- codesign patch ----//
    
    if (!fileExists(in_bundle("bins/tester"))) {
        chdir(in_bundle("bins/"));
        
        FILE *f1 = fopen(in_bundle("bins/tester.tar"), "r");
        untar(f1, in_bundle("bins/tester"));
        fclose(f1);
        
        removeFile(in_bundle("bins/tester.tar"));
    }
    
    chmod(in_bundle("bins/tester"), 0777); // give it proper permissions
    
    if (launch(in_bundle("bins/tester"), NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
        failIf(trustbin("/var/containers/Bundle/iosbinpack64"), "[-] Failed to trust binaries!");
        failIf(trustbin("/var/containers/Bundle/tweaksupport"), "[-] Failed to trust binaries!");
        
        // test
        int ret = launch("/var/containers/Bundle/iosbinpack64/test", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
        failIf(ret, "[-] Failed to trust binaries!");
        LOG("[+] Successfully trusted binaries!");
    }
    else {
        LOG("[+] binaries already trusted?");
    }
    
    //---- let's go! ----//
    
    prepare_payload(); // this will chmod 777 everything
    
    //----- setup SSH -----//
    mkdir("/var/dropbear", 0777);
    removeFile("/var/profile");
    removeFile("/var/motd");
    chmod("/var/profile", 0777);
    chmod("/var/motd", 0777);
    
    copyFile("/var/containers/Bundle/iosbinpack64/etc/profile", "/var/profile");
    copyFile("/var/containers/Bundle/iosbinpack64/etc/motd", "/var/motd");
    
    // kill it if running
    launch("/var/containers/Bundle/iosbinpack64/usr/bin/killall", "-SEGV", "dropbear", NULL, NULL, NULL, NULL, NULL);
    failIf(launchAsPlatform("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL), "[-] Failed to launch dropbear");
    pid_t dpd = pid_of_procName("dropbear");
    usleep(1000);
    if (!dpd) failIf(launchAsPlatform("/var/containers/Bundle/iosbinpack64/usr/local/bin/dropbear", "-R", "-E", NULL, NULL, NULL, NULL, NULL), "[-] Failed to launch dropbear");
    
    //------------- launch daeamons -------------//
    //-- you can drop any daemon plist in iosbinpack64/LaunchDaemons and it will be loaded automatically --//
    
    plists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/containers/Bundle/iosbinpack64/LaunchDaemons" error:nil];
    
    for (__strong NSString *file in plists) {
        printf("[*] Adding permissions to plist %s\n", [file UTF8String]);
        
        file = [@"/var/containers/Bundle/iosbinpack64/LaunchDaemons" stringByAppendingPathComponent:file];
        
        if (strstr([file UTF8String], "jailbreakd")) {
            printf("[*] Found jailbreakd plist, special handling\n");
            
            NSMutableDictionary *job = [NSPropertyListSerialization propertyListWithData:[NSData dataWithContentsOfFile:file] options:NSPropertyListMutableContainers format:nil error:nil];
            
            job[@"EnvironmentVariables"][@"KernelBase"] = [NSString stringWithFormat:@"0x%16llx", KernelBase];
            [job writeToFile:file atomically:YES];
        }
        
        chmod([file UTF8String], 0644);
        chown([file UTF8String], 0, 0);
    }
    
    // clean up
    removeFile("/var/log/testbin.log");
    removeFile("/var/log/jailbreakd-stderr.log");
    removeFile("/var/log/jailbreakd-stdout.log");
    
    launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "unload", "/var/containers/Bundle/iosbinpack64/LaunchDaemons", NULL, NULL, NULL, NULL, NULL);
    launch("/var/containers/Bundle/iosbinpack64/bin/launchctl", "load", "/var/containers/Bundle/iosbinpack64/LaunchDaemons", NULL, NULL, NULL, NULL, NULL);
    
    sleep(1);
    
    failIf(!fileExists("/var/log/testbin.log"), "[-] Failed to load launch daemons");
    failIf(!fileExists("/var/log/jailbreakd-stdout.log"), "[-] Failed to load jailbreakd");
    
    if (self.enableTweaks.isOn) {
        
        //----- magic start here -----//
        LOG("[*] Time for magic");
        
        char *xpcproxy = "/var/libexec/xpcproxy";
        char *dylib = "/var/ulb/pspawn.dylib";
        
        if (!fileExists(xpcproxy)) {
            bool cp = copyFile("/usr/libexec/xpcproxy", xpcproxy);
            failIf(!cp, "[-] Can't copy xpcproxy!");
            symlink("/var/containers/Bundle/iosbinpack64/pspawn.dylib", dylib);
            
            LOG("[*] Patching xpcproxy");
            
            const char *args[] = { "insert_dylib", "--all-yes", "--inplace", "--overwrite", dylib, xpcproxy, NULL};
            int argn = 6;
            
            failIf(add_dylib(argn, args), "[-] Failed to patch xpcproxy :(");
            
            LOG("[*] Resigning xpcproxy");
            
            failIf(system_("/var/containers/Bundle/iosbinpack64/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/iosbinpack64/default.ent /var/libexec/xpcproxy"), "[-] Failed to resign xpcproxy!");
        }
        
        chown(xpcproxy, 0, 0);
        chmod(xpcproxy, 755);
        failIf(trustbin(xpcproxy), "[-] Failed to trust xpcproxy!");
        
        uint64_t realxpc = getVnodeAtPath("/usr/libexec/xpcproxy");
        uint64_t fakexpc = getVnodeAtPath(xpcproxy);
        
        struct vnode rvp, fvp;
        KernelRead(realxpc, &rvp, sizeof(struct vnode));
        KernelRead(fakexpc, &fvp, sizeof(struct vnode));
        
        fvp.v_usecount = rvp.v_usecount;
        fvp.v_kusecount = rvp.v_kusecount;
        fvp.v_parent = rvp.v_parent;
        fvp.v_freelist = rvp.v_freelist;
        fvp.v_mntvnodes = rvp.v_mntvnodes;
        fvp.v_ncchildren = rvp.v_ncchildren;
        fvp.v_nclinks = rvp.v_nclinks;
        
        KernelWrite(realxpc, &fvp, sizeof(struct vnode)); // :o
  
        LOG("[?] Are we still alive?!");
        
        //----- magic end here -----//
        
        // cache pid and we're done
        pid_t installd = pid_of_procName("installd");
        pid_t bb = pid_of_procName("backboardd");
        pid_t amfid = pid_of_procName("amfid");
        if (amfid) kill(amfid, SIGKILL);
        
        // AppSync
        
        fixMmap("/var/ulb/libsubstitute.dylib");
        fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
        fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
        
        if (installd) kill(installd, SIGKILL);
        
        if ([self.installiSuperSU isOn]) {
            LOG("[*] Installing iSuperSU");
            
            removeFile("/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app");
            copyFile(in_bundle("apps/iSuperSU.app"), "/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app");
            
            failIf(system_("/var/containers/Bundle/tweaksupport/usr/local/bin/jtool --sign --inplace --ent /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/ent.xml /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU && /var/containers/Bundle/tweaksupport/usr/bin/inject /var/containers/Bundle/tweaksupport/Applications/iSuperSU.app/iSuperSU"), "[-] Failed to sign iSuperSU");
            
            
            // just in case
            fixMmap("/var/ulb/libsubstitute.dylib");
            fixMmap("/var/LIB/Frameworks/CydiaSubstrate.framework/CydiaSubstrate");
            fixMmap("/var/LIB/MobileSubstrate/DynamicLibraries/AppSyncUnified.dylib");
            
            failIf(launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL), "[-] Failed to install iSuperSU");

        }
        
        // kill any daemon/executable being hooked by tweaks (except for the obvious, assertiond, backboardd and SpringBoard)

        NSArray *tweaks = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/ulb/TweakInject" error:NULL];
        for (NSString *afile in tweaks) {
            if ([afile hasSuffix:@"plist"]) {
                
                NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"/var/ulb/TweakInject/%@",afile]];
                NSString *dylibPath = [afile stringByReplacingOccurrencesOfString:@".plist" withString:@".dylib"];
                fixMmap((char *)[[NSString stringWithFormat:@"/var/ulb/TweakInject/%@", dylibPath] UTF8String]);
                NSArray *executables = [[plist objectForKey:@"Filter"] objectForKey:@"Executables"];

                for (NSString *processName in executables) {
                    if (![processName isEqual:@"SpringBoard"] && ![processName isEqual:@"backboardd"] && ![processName isEqual:@"assertiond"] && ![processName isEqual:@"launchd"]) { //really?
                        int procpid = pid_of_procName((char *)[processName UTF8String]);
                        if (procpid) {
                            kill(procpid, SIGKILL);
                        }
                    }
                }
                
                NSArray *bundles = [[plist objectForKey:@"Filter"] objectForKey:@"Bundles"];
                for (NSString *bundleID in bundles) {
                    if (![bundleID isEqual:@"com.apple.springboard"] && ![bundleID isEqual:@"com.apple.backboardd"] && ![bundleID isEqual:@"com.apple.assertiond"] && ![bundleID isEqual:@"com.apple.launchd"]) {
                        NSString *processName = [bundleID stringByReplacingOccurrencesOfString:@"com.apple." withString:@""];
                        int procpid = pid_of_procName((char *)[processName UTF8String]);
                        if (procpid) {
                            kill(procpid, SIGKILL);
                        }
                    }
                    
                }
            }
        }
     
        // find which applications are jailbreak applications and inject their executable
        NSArray *applications = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:@"/var/containers/Bundle/Application/" error:NULL];
        
        for (NSString *string in applications) {
            NSString *fullPath = [@"/var/containers/Bundle/Application/" stringByAppendingString:string];
            NSArray *innerContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:NULL];
            for (NSString *innerFile in innerContents) {
                if ([innerFile hasSuffix:@"app"]) {
                    
                    NSString *fullAppBundlePath = [fullPath stringByAppendingString:[NSString stringWithFormat:@"/%@",innerFile]];
                    NSString *_CodeSignature = [fullPath stringByAppendingString:[NSString stringWithFormat:@"/%@/_CodeSignature",innerFile]];
                    
                    NSDictionary *infoPlist = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Info.plist",fullAppBundlePath]];
                    NSString *executable = [infoPlist objectForKey:@"CFBundleExecutable"];
                    NSString *BuildMachineOSBuild = [infoPlist objectForKey:@"BuildMachineOSBuild"];
                    BOOL hasDTCompilerRelatedKeys=NO;
                    for (NSString *KEY in [infoPlist allKeys]) {
                        if ([KEY rangeOfString:@"DT"].location==0) {
                            hasDTCompilerRelatedKeys=YES;
                            break;
                        }
                    }
                    // check for keys added by native/appstore apps and exclude (theos and friends don't add BuildMachineOSBuild and DT_ on apps :-D )
                    // Xcode-added apps set CFBundleExecutable=Executable, exclude them too
                    
                    executable = [NSString stringWithFormat:@"%@/%@", fullAppBundlePath, executable];
                    
                    if (([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/.jb",fullAppBundlePath]] || ![[NSFileManager defaultManager] fileExistsAtPath:_CodeSignature] || (executable && ![executable isEqual:@"Executable"] && !BuildMachineOSBuild & !hasDTCompilerRelatedKeys)) && fileExists([executable UTF8String])) {
                        
                        LOG("Injecting executable %s",[executable UTF8String]);
                        system_((char *)[[NSString stringWithFormat:@"/var/containers/Bundle/iosbinpack64/usr/bin/inject %s", [executable UTF8String]] UTF8String]);
                    }
                    
                }
            }
        }
        

        LOG("[+] Really jailbroken!");
        term_jelbrek();
        
        // bye bye
        kill(bb, 9);
        //launch("/var/containers/Bundle/iosbinpack64/bin/bash", "-c", "/var/containers/Bundle/iosbinpack64/usr/bin/nohup /var/containers/Bundle/iosbinpack64/bin/bash -c \"/var/containers/Bundle/iosbinpack64/bin/launchctl unload /System/Library/LaunchDaemons/com.apple.backboardd.plist && /var/containers/Bundle/iosbinpack64/usr/bin/ldrestart; /var/containers/Bundle/iosbinpack64/bin/launchctl load /System/Library/LaunchDaemons/com.apple.backboardd.plist\" 2>&1 >/dev/null &", NULL, NULL, NULL, NULL, NULL);
        exit(0);
    }
    
    /// FIX THIS
    /*
     pid_t installd = pid_of_procName("installd");
     failIf(!installd, "[-] Can't find installd's pid");
     
     failIf(!setcsflags(installd), "[-] Failed to entitle installd");
     failIf(!entitlePidOnAMFI(installd, "get-task-allow", true), "[-] Failed to entitle installd");
     failIf(!entitlePidOnAMFI(installd, "com.apple.private.skip-library-validation", true), "[-] Failed to entitle installd");
     
     inject_dylib(installd, "/var/containers/Bundle/tweaksupport/usr/lib/TweakInject/AppSyncUnified.dylib");
     
     if ([self.installiSuperSU isOn]) {
     LOG("[*] Installing iSuperSU");
     copyFile(in_bundle("apps/iSuperSU.app"), "/var/containers/Bundle/tweaksupport/Applications/iSuperSU.app");
     launch("/var/containers/Bundle/tweaksupport/usr/bin/uicache", NULL, NULL, NULL, NULL, NULL, NULL, NULL);
     } */
    
    LOG("[+] Jailbreak succeeded. Enjoy");
    
end:;
    
    if (sb) sandbox(getpid(), sb);
    term_jelbrek();
}
- (IBAction)uninstall:(id)sender {
    //---- tfp0 ----//
    __block mach_port_t taskforpidzero = MACH_PORT_NULL;
    
    uint64_t sb = 0;
    BOOL debug = NO; // kids don't enable this
    
    NSError *error = NULL;
    
    if (debug) {
        kern_return_t ret = host_get_special_port(mach_host_self(), HOST_LOCAL_NODE, 4, &taskforpidzero);
        if (ret) {
            printf("[-] Error using hgsp! '%s'\n", mach_error_string(ret));
            printf("[*] Using exploit!\n");
            
            if (psize == 0x1000 && maxVersion("12.1.2")) {
                
                // v3ntex is so bad we have to treat it specially for it not to freak out
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
                dispatch_group_t group = dispatch_group_create();
                dispatch_semaphore_t sm = dispatch_semaphore_create(0);
                
                dispatch_group_async(group, queue, ^{
                    taskforpidzero = v3ntex();
                    dispatch_semaphore_signal(sm);
                });
                
                dispatch_semaphore_wait(sm, DISPATCH_TIME_FOREVER);
            }
            
            else if (maxVersion("12.1.2")) {
                taskforpidzero = voucher_swap();
            }
            else {
                [sender setTitle:@"Not supported!" forState:UIControlStateNormal];
                [sender setEnabled:false];
                return;
            }
            
            if (!MACH_PORT_VALID(taskforpidzero)) {
                LOG("[-] Exploit failed");
                LOG("[i] Please try again");
                sleep(1);
                return;
            }
        }
    }
    else {
        if (psize == 0x1000 && maxVersion("12.1.2")) {
            
            // v3ntex is so bad we have to treat it specially for it not to freak out
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
            dispatch_group_t group = dispatch_group_create();
            dispatch_semaphore_t sm = dispatch_semaphore_create(0);
            
            dispatch_group_async(group, queue, ^{
                taskforpidzero = v3ntex();
                dispatch_semaphore_signal(sm);
            });
            
            dispatch_semaphore_wait(sm, DISPATCH_TIME_FOREVER);
        }
        
        else if (maxVersion("12.1.2")) {
            taskforpidzero = voucher_swap();
        }
        else {
            [sender setTitle:@"Not supported!" forState:UIControlStateNormal];
            [sender setEnabled:false];
            return;
        }
        
        if (!MACH_PORT_VALID(taskforpidzero)) {
            LOG("[-] Exploit failed");
            LOG("[i] Please try again");
            sleep(1);
            return;
        }
    }
    LOG("[*] Starting fun");
    
    if (!KernelBase) {
        kernel_slide_init();
        init_with_kbase(taskforpidzero, 0xfffffff007004000 + kernel_slide);
    }
    else init_with_kbase(taskforpidzero, KernelBase);
    
    LOG("[i] Kernel base: 0x%llx", KernelBase);
    
    //---- basics ----//
    rootify(getpid()); // give us root
    LOG("[i] uid: %d\n", getuid());
    failIf(getuid(), "[-] Failed to get root");
    
    sb = unsandbox(getpid()); // escape sandbox
    FILE *f = fopen("/var/mobile/.roottest", "w");
    failIf(!f, "[-] Failed to escape sandbox!");
    
    LOG("[+] Escaped sandbox!\n\tWrote file %p", f);
    fclose(f);
    removeFile("/var/mobile/.roottest");
    
    setcsflags(getpid()); // set some csflags
    platformize(getpid()); // set TF_PLATFORM
    
    if (debug) setHSP4();
    if (debug) PatchHostPriv(mach_host_self());
    
    LOG("[*] Uninstalling...");
    
    failIf(!fileExists("/var/containers/Bundle/.installed_rootlessJB3"), "[-] rootlessJB was never installed before! (this version of it)");
    
    removeFile("/var/LIB");
    removeFile("/var/ulb");
    removeFile("/var/bin");
    removeFile("/var/sbin");
    removeFile("/var/libexec");
    removeFile("/var/containers/Bundle/tweaksupport/Applications");
    removeFile("/var/Apps");
    removeFile("/var/profile");
    removeFile("/var/motd");
    removeFile("/var/dropbear");
    removeFile("/var/containers/Bundle/tweaksupport");
    removeFile("/var/containers/Bundle/iosbinpack64");
    removeFile("/var/log/testbin.log");
    removeFile("/var/log/jailbreakd-stdout.log");
    removeFile("/var/log/jailbreakd-stderr.log");
    removeFile("/var/log/pspawn_payload_xpcproxy.log");
    removeFile("/var/containers/Bundle/.installed_rootlessJB3");
    removeFile("/var/lib");
    removeFile("/var/etc");
    removeFile("/var/usr");
    
end:;
    if (sb) sandbox(getpid(), sb);
    term_jelbrek();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

