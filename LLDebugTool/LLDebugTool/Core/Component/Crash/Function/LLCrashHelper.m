//
//  LLCrashHelper.m
//
//  Copyright (c) 2018 LLDebugTool Software Foundation (https://github.com/HDB-Li/LLDebugTool)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "LLCrashHelper.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "LLStorageManager.h"
#import "LLCrashModel.h"
#import "LLConfig.h"
#import "LLFormatterTool.h"
#import "NSObject+LL_Utils.h"
#import "LLAppInfoHelper.h"
#import "LLTool.h"

static LLCrashHelper *_instance = nil;

@interface LLCrashHelper ()

@end

@implementation LLCrashHelper

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[LLCrashHelper alloc] init];
    });
    return _instance;
}

- (void)setEnable:(BOOL)enable {
    if (_enable != enable) {
        _enable = enable;
        if (enable) {
            [self registerCatch];
        } else {
            [self unregisterCatch];
        }
    }
}

#pragma mark - Primary
- (void)registerCatch {
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGHUP, SignalHandler);
    signal(SIGINT, SignalHandler);
    signal(SIGQUIT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGTRAP, SignalHandler);
    signal(SIGABRT, SignalHandler);
#ifdef SIGPOLL
    signal(SIGPOLL, SignalHandler);
#endif
#ifdef SIGEMT
    signal(SIGEMT, SignalHandler);
#endif
    signal(SIGFPE, SignalHandler);
    signal(SIGKILL, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGSYS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
    signal(SIGALRM, SignalHandler);
    signal(SIGTERM, SignalHandler);
    signal(SIGURG, SignalHandler);
    signal(SIGSTOP, SignalHandler);
    signal(SIGTSTP, SignalHandler);
    signal(SIGCONT, SignalHandler);
    signal(SIGCHLD, SignalHandler);
    signal(SIGTTIN, SignalHandler);
    signal(SIGTTOU, SignalHandler);
#ifdef SIGIO
    signal(SIGIO, SignalHandler);
#endif
    signal(SIGXCPU, SignalHandler);
    signal(SIGXFSZ, SignalHandler);
    signal(SIGVTALRM, SignalHandler);
    signal(SIGPROF, SignalHandler);
#ifdef SIGWINCH
    signal(SIGWINCH, SignalHandler);
#endif
#ifdef SIGINFO
    signal(SIGINFO, SignalHandler);
#endif
    signal(SIGUSR1, SignalHandler);
    signal(SIGUSR2, SignalHandler);
}

- (void)unregisterCatch {
    NSSetUncaughtExceptionHandler(nil);
    signal(SIGHUP, SIG_DFL);
    signal(SIGINT, SIG_DFL);
    signal(SIGQUIT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGTRAP, SIG_DFL);
    signal(SIGABRT, SIG_DFL);
#ifdef SIGPOLL
    signal(SIGPOLL, SIG_DFL);
#endif
#ifdef SIGEMT
    signal(SIGEMT, SIG_DFL);
#endif
    signal(SIGFPE, SIG_DFL);
    signal(SIGKILL, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGSYS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    signal(SIGALRM, SIG_DFL);
    signal(SIGTERM, SIG_DFL);
    signal(SIGURG, SIG_DFL);
    signal(SIGSTOP, SIG_DFL);
    signal(SIGTSTP, SIG_DFL);
    signal(SIGCONT, SIG_DFL);
    signal(SIGCHLD, SIG_DFL);
    signal(SIGTTIN, SIG_DFL);
    signal(SIGTTOU, SIG_DFL);
#ifdef SIGIO
    signal(SIGIO, SIG_DFL);
#endif
    signal(SIGXCPU, SIG_DFL);
    signal(SIGXFSZ, SIG_DFL);
    signal(SIGVTALRM, SIG_DFL);
    signal(SIGPROF, SIG_DFL);
#ifdef SIGWINCH
    signal(SIGWINCH, SIG_DFL);
#endif
#ifdef SIGINFO
    signal(SIGINFO, SIG_DFL);
#endif
    signal(SIGUSR1, SIG_DFL);
    signal(SIGUSR2, SIG_DFL);
}

- (void)saveException:(NSException *)exception {
    NSString *date = [[LLFormatterTool shared] stringFromDate:[NSDate date] style:FormatterToolDateStyle1];
    NSArray *appInfos = [[LLAppInfoHelper shared] appInfos];

    if (self.crashModel) {
        LLCrashModel *model = [[LLCrashModel alloc] initWithName:exception.name reason:exception.reason userInfo:exception.userInfo stackSymbols:exception.callStackSymbols date:date userIdentity:[LLConfig shared].userIdentity appInfos:appInfos launchDate:[NSObject LL_launchDate]];
        for (LLCrashSignalModel *signal in self.crashModel.signals) {
            [model appendSignalModel:signal];
        }
        self.crashModel = model;
        [[LLStorageManager shared] updateModel:model complete:^(BOOL result) {
            [LLTool log:@"Save crash model success"];
        } synchronous:YES];
    } else {
        LLCrashModel *model = [[LLCrashModel alloc] initWithName:exception.name reason:exception.reason userInfo:exception.userInfo stackSymbols:exception.callStackSymbols date:date userIdentity:[LLConfig shared].userIdentity appInfos:appInfos launchDate:[NSObject LL_launchDate]];
        self.crashModel = model;
        [[LLStorageManager shared] saveModel:model complete:^(BOOL result) {
            [LLTool log:@"Save crash model success"];
        } synchronous:YES];
    }
}

void HandleException(NSException *exception)
{
    [[LLCrashHelper shared] saveException:exception];
    [exception raise];
}

void SignalHandler(int sig)
{
    // See https://stackoverflow.com/questions/40631334/how-to-intercept-exc-bad-instruction-when-unwrapping-nil.
    NSString *name = @"Unknown signal";
    switch (sig) {
        case SIGHUP:{
            name = @"SIGHUP";
        }
            break;
        case SIGINT:{
            name = @"SIGINT";
        }
            break;
        case SIGQUIT:{
            name = @"SIGQUIT";
        }
            break;
        case SIGILL:{
            name = @"SIGILL";
        }
            break;
        case SIGTRAP:{
            name = @"SIGTRAP";
        }
            break;
        case SIGABRT:{
            name = @"SIGABRT";
        }
            break;
#ifdef SIGPOLL
        case SIGPOLL:{
            name = @"SIGPOLL";
        }
            break;
#endif
        case SIGEMT:{
            name = @"SIGEMT";
        }
            break;
        case SIGFPE:{
            name = @"SIGFPE";
        }
            break;
        case SIGKILL:{
            name = @"SIGKILL";
        }
            break;
        case SIGBUS:{
            name = @"SIGBUS";
        }
            break;
        case SIGSEGV:{
            name = @"SIGSEGV";
        }
            break;
        case SIGSYS:{
            name = @"SIGSYS";
        }
            break;
        case SIGPIPE:{
            name = @"SIGPIPE";
        }
            break;
        case SIGALRM:{
            name = @"SIGALRM";
        }
            break;
        case SIGTERM:{
            name = @"SIGTERM";
        }
            break;
        case SIGURG:{
            name = @"SIGURG";
        }
            break;
        case SIGSTOP:{
            name = @"SIGSTOP";
        }
            break;
        case SIGTSTP:{
            name = @"SIGTSTP";
        }
            break;
        case SIGCONT:{
            name = @"SIGCONT";
        }
            break;
        case SIGCHLD:{
            name = @"SIGCHLD";
        }
            break;
        case SIGTTIN:{
            name = @"SIGTTIN";
        }
            break;
        case SIGTTOU:{
            name = @"SIGTTOU";
        }
            break;
#ifdef SIGIO
        case SIGIO:{
            name = @"SIGIO";
        }
            break;
#endif
        case SIGXCPU:{
            name = @"SIGXCPU";
        }
            break;
        case SIGXFSZ:{
            name = @"SIGXFSZ";
        }
            break;
        case SIGVTALRM:{
            name = @"SIGVTALRM";
        }
            break;
        case SIGPROF:{
            name = @"SIGPROF";
        }
            break;
#ifdef SIGWINCH
        case SIGWINCH:{
            name = @"SIGWINCH";
        }
            break;
#endif
#ifdef SIGINFO
        case SIGINFO:{
            name = @"SIGINFO";
        }
            break;
#endif
        case SIGUSR1:{
            name = @"SIGUSR1";
        }
            break;
        case SIGUSR2:{
            name = @"SIGUSR2";
        }
            break;
        default:{}
            break;
    }

    NSArray *callStackSymbols = [NSThread callStackSymbols];
    NSString *date = [[LLFormatterTool shared] stringFromDate:[NSDate date] style:FormatterToolDateStyle1];
    NSDictionary *appInfos = [[LLAppInfoHelper shared] dynamicAppInfos];
    LLCrashSignalModel *signalModel = [[LLCrashSignalModel alloc] initWithName:name stackSymbols:callStackSymbols date:date userIdentity:[LLConfig shared].userIdentity appInfos:appInfos];
    if ([LLCrashHelper shared].crashModel) {
        [[LLCrashHelper shared].crashModel updateAppInfos:[[LLAppInfoHelper shared] appInfos]];
        [[LLCrashHelper shared].crashModel appendSignalModel:signalModel];
        [[LLStorageManager shared] updateModel:[LLCrashHelper shared].crashModel complete:^(BOOL result) {
            [LLTool log:@"Save signal model success"];
        } synchronous:YES];
    } else {
        LLCrashModel *model = [[LLCrashModel alloc] initWithName:signalModel.name reason:@"Catch Signal" userInfo:nil stackSymbols:callStackSymbols date:date userIdentity:[LLConfig shared].userIdentity appInfos:[[LLAppInfoHelper shared] appInfos] launchDate:[NSObject LL_launchDate]];
        [model appendSignalModel:signalModel];
        [LLCrashHelper shared].crashModel = model;
        [[LLStorageManager shared] saveModel:model complete:^(BOOL result) {
            [LLTool log:@"Save signal model success"];
        } synchronous:YES];
    }
}

@end
