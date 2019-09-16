//
//  CommandLineMain.m
//  Saily.Daemon
//
//  Created by Lakr Aream on 2019/7/26.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

#include "CommandLineMain.h"

int outputLevel = 0;

int command_line_main(int argc, const char * argv[]) {
    
    NSLog(@"--- args ---");
    NSArray *args = [[NSProcessInfo processInfo] arguments];
    for (int i = 0; i < [args count]; i++) {
        NSLog(@"%@", args[i]);
        if ([args[i] isEqualToString: @"-rl"]) {
            outputLevel = 1;
        }
    }
    NSLog(@"--- ---- ---");
    
    if (outputLevel == 1) {
//        redirectConsoleLogToVarRoot();
    }
    
    NSLog(@"[i] 准备启动 Daemon, 版本代号 0.6-b1063");
    
    bool rootless = false;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath: @"/usr/lib/libjailbreak.dylib"]) {
        NSLog(@"[*] 为 Chimera 的越狱执行额外的脚本");
        someChimeraSetup();
        NSLog(@"[*] 确认存活？");
    } else {
        
        // Extra script for rootless jb
        if ([[NSFileManager defaultManager] fileExistsAtPath: @"/var/containers/Bundle/.installed_rootlessJB3"]) {
            setIsRootless();
            rootless = true;
            // call to jbd
            NSLog(@"%d", getpid());
            calljailbreakd(getpid(), JAILBREAKD_COMMAND_FIXUP_SETUID);
            calljailbreakd(getpid(), JAILBREAKD_COMMAND_UNSANDBOX);
            calljailbreakd(getpid(), JAILBREAKD_COMMAND_ENTITLE_PLATFORMIZE);
            // get us root
            setuid(0);
            setgid(0);
            int csops(pid_t pid, unsigned int  ops, void * useraddr, size_t usersize);
            uint32_t flags;
            csops(getpid(), 0, &flags, 0);
//            if (!(flags & 0x4000000)){
//                NSLog(@"[*] 初始化rootless失败");
//                exit(-1);
//            }
        } else {
            setuid(0);
            setgid(0);
        }
    }
    
    if (![[NSFileManager defaultManager] fileExistsAtPath: @"/var/root/.SailyBootstrap"] && !rootless) {
        int cnt = 0;
        while (cnt < 12 && [[NSFileManager defaultManager] fileExistsAtPath: @"/Library/dpkg/lock-frontend"]) {
            sleep(1);
            cnt++;
        }
        usleep(2333);
        NSString *installedokinstall = @"echo \"com.Lakr233.Saily install\" | dpkg --set-selections";
        run_cmd((char *)[installedokinstall UTF8String]);
        NSString *signal = @"echo \"com.Lakr233.Saily install\" &> /var/root/.SailyBootstrap";
        run_cmd((char *)[signal UTF8String]);
        NSString *uicache = @"uicache -a";
        run_cmd((char *)[uicache UTF8String]);
        NSLog(@"[*] ? -> 👌");
    } else {
        NSString *signal = @"echo \"com.Lakr233.Saily install\" &> /var/root/.SailyBootstrap";
        run_cmd((char *)[signal UTF8String]);
        NSLog(@"[*] 👌");
    }
    
    @autoreleasepool
    {
        regLinstenersOnMsgPass();
        CFRunLoopRun(); // keep it running in background
        NSLog(@"[666] 666666");
        return 0;
    }
    
}

void someChimeraSetup() {
    void* handle = dlopen("/usr/lib/libjailbreak.dylib", 1);
    if (handle) {
        dlerror();
        typedef void (*fix_setuid_prt_t)(pid_t pid);
        fix_setuid_prt_t ptr_setuid = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
        typedef void (*fix_entitle_prt_t)(pid_t pid, uint32_t what);
        fix_entitle_prt_t ptr_entitle = (fix_entitle_prt_t)dlsym(handle, "jb_oneshot_entitle_now");
        if(!dlerror()) {
            ptr_setuid(getpid());
        }
        // Come and fuck me if you can.
        for (int i = 0; i < 233; i++) {
            setuid(0);
        }
        if(!dlerror()) {
            ptr_entitle(getpid(), 2LL);
        }
    }
}


