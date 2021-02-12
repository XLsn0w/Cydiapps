# iOS逆向工程越狱开发 
# iOS Jailbreak Develop/hook/Reverse
# 我的微信公众号: Cydia
<img src="https://github.com/XLsn0w/XLsn0w/blob/XLsn0w/XLsn0w/Cydiapple.png?raw=true" alt="XLsn0w" width="160" height="160" align="bottom" />

# 我的私人公众号: XLsn0w
<img src="https://github.com/XLsn0w/iOS-Reverse/blob/master/XLsn0w.jpeg?raw=true" alt="XLsn0w" width="250" height="300" align="bottom" />

<img src="https://upload-images.jianshu.io/upload_images/1155391-084275e043ff1f1c.png?imageMogr2/auto-orient/strip|imageView2/2/w/928/format/webp" width="400" height="667" align="bottom" />

## raw.githubusercontent.com port 443问题
### MacOS解决安装MonkeyDev等遇见Failed to connect to raw.githubusercontent.com port 443问题 : https://www.jianshu.com/p/6ea74620caae
```
Mac 文件夹搜索进入/etc/hosts

找到hosts 输入以下文字(不要输入其他文字)  (无权限可以复制到桌面 然后替换源文件)

199.232.96.133     raw.githubusercontent.com

浏览器直接打开raw.githubusercontent.com  出现github网站就OK

199.232.96.133 raw.githubusercontent.com # comments. put the address here

然后成功下载
```

## iOS Hook Fake Detection
```
#import "iOSHookDetection.h"
#import "fishhook.h"
#import <sys/stat.h>
#include <string.h>
#import <mach-o/loader.h>
#import <mach-o/dyld.h>
#import <mach-o/arch.h>
#import <objc/runtime.h>
#import <dlfcn.h>

static char *JailbrokenPathArr[] = {"/Applications/Cydia.app","/usr/sbin/sshd","/bin/bash","/etc/apt","/Library/MobileSubstrate","/User/Applications/"};

@implementation iOSHookDetection  //实现函数

#pragma mark - 越狱检测
#pragma mark 使用NSFileManager通过检测一些越狱后的关键文件是否可以访问来判断是否越狱
+ (BOOL)isJailbroken1{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    for (int i = 0;i < sizeof(JailbrokenPathArr) / sizeof(char *);i++) {
        if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:JailbrokenPathArr[i]]]){
            return YES;
        }
    }
    return NO;
}
#pragma mark 使用stat通过检测一些越狱后的关键文件是否可以访问来判断是否越狱
+ (BOOL)isJailbroken2{
    
    if(TARGET_IPHONE_SIMULATOR)return NO;
    int ret ;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSString *fName = [NSString stringWithUTF8String:dylib_info.dli_fname];
        NSLog(@"fname--%@",fName);
        if(![fName isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]){
            return YES;
        }
    }
    
    for (int i = 0;i < sizeof(JailbrokenPathArr) / sizeof(char *);i++) {
        struct stat stat_info;
        if (0 == stat(JailbrokenPathArr[i], &stat_info)) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark 通过环境变量DYLD_INSERT_LIBRARIES检测是否越狱
+ (BOOL)isJailbroken3{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    return !(NULL == getenv("DYLD_INSERT_LIBRARIES"));
}

#pragma mark - 通过遍历dyld_image检测非法注入的动态库
+ (BOOL)isExternalLibs{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    int dyld_count = _dyld_image_count();
    for (int i = 0; i < dyld_count; i++) {
        const char * imageName = _dyld_get_image_name(i);
        NSString *res = [NSString stringWithUTF8String:imageName];
        if([res hasPrefix:@"/var/containers/Bundle/Application"]){
            if([res hasSuffix:@".dylib"]){
                //这边还需要过滤掉自己项目中本身有的动态库
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - 通过检测ipa中的embedded.mobileprovision中的我们打包Mac的公钥来确定是否签名被修改，但是需要注意的是此方法只适用于Ad Hoc或企业证书打包的情况，App Store上应用由苹果私钥统一打包，不存在embedded.mobileprovision文件
+ (BOOL)isLegalPublicKey:(NSString *)publicKey{
    if(TARGET_IPHONE_SIMULATOR)return YES;
    //来源于https://www.jianshu.com/p/a3fc10c70a29
    NSString *embeddedPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
    NSString *embeddedProvisioning = [NSString stringWithContentsOfFile:embeddedPath encoding:NSASCIIStringEncoding error:nil];
    NSArray *embeddedProvisioningLines = [embeddedProvisioning componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    for (int i = 0; i < embeddedProvisioningLines.count; i++) {
        if ([embeddedProvisioningLines[i] rangeOfString:@"application-identifier"].location != NSNotFound) {
            NSInteger fromPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"<string>"].location+8;
            
            NSInteger toPosition = [embeddedProvisioningLines[i+1] rangeOfString:@"</string>"].location;
            NSRange range;
            range.location = fromPosition;
            range.length = toPosition - fromPosition;
            NSString *fullIdentifier = [embeddedProvisioningLines[i+1] substringWithRange:range];
            NSArray *identifierComponents = [fullIdentifier componentsSeparatedByString:@"."];
            NSString *appIdentifier = [identifierComponents firstObject];
            NSLog(@"appIdentifier--%@",appIdentifier);
            if (![appIdentifier isEqualToString:publicKey]) {
                return NO;
            }
        }
    }
    return YES;
}

@end

```

### 浅析Tweak loader(MobileSubstrate的替代品)

搜到的源码是：https://github.com/chr1s0x1/TweakInject

代码本身很简单，就是去/Library/MobileSubstrate/DynamicLibraries下面去搜索，
通过plist文件里面的字段决定是否将dylib加载到当前进程中，
就和平时开发tweak去hook那些app的过程一样。
不过我感到疑问的地方在于那本身这个tweak loader dylib又是谁以及何时被加载到进程中的呢。
这里不难想到应该就是越狱后支持hook环境相关，所以我又去翻阅相关越狱源码。

#Electra
研究的越狱源码是：https://github.com/coolstar/electra

至于为什么会选择Electra，而且是早期的一个版本？有以下几点原因：
coolstar由于在开发Electra越狱后,没有开发插件hook环境
而Cydia之父saurik没有提供substrate的支持，
所以自己实现了类似Cydia Substrate完整的hook环境，
这里面很多东西都是重新研究实现的，保留了很多当时的曲折过程，而这些恰好很便于去学习。
代码开源，而且早期一切都是以实用为主，代码都比较有代表性。

#pspawn_payload
回到之前的问题，tweak loader是谁负责加载的呢？最直接相关的代码在:

https://github.com/coolstar/electra/blob/master/basebinaries/pspawn_payload/pspawn_payload.m

代码里面的SBInject.dylib就是tweak loader，如下

#define SBINJECT_PAYLOAD_DYLIB "/usr/lib/SBInject.dylib"
这个模块叫做pspawn_payload，你在coolstar系越狱里进程模块里面就会有这个模块名。

下面是该模块初始化的代码

__attribute__ ((constructor))
static void ctor(void) {
    if (getpid() == 1) {
        current_process = PROCESS_LAUNCHD;
        pthread_t thd;
        pthread_create(&thd, NULL, thd_func, NULL);
    } else {
        current_process = PROCESS_XPCPROXY;
        rebind_pspawns();
    }
}
代码就是如果当前进程不是launchd，就hook pspawns函数。pspawns正是创建一个新进程的函数，所以hook以后会在创建前注入dylib。下面简单列举里面几个关键地方的代码

int fake_posix_spawn_common(pid_t * pid, const char* path, const posix_spawn_file_actions_t *file_actions, posix_spawnattr_t *attrp, char const* argv[], const char* envp[], pspawn_t old) {

    ...
    if (strcmp(path, "/usr/libexec/amfid") == 0) {
        DEBUGLOG("Starting amfid -- special handling");
        inject_me = AMFID_PAYLOAD_DYLIB;
    } else {
        inject_me = SBINJECT_PAYLOAD_DYLIB;
    }
    ...

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

    ...

    origret = old(pid, path, file_actions, newattrp, argv, newenvp);

}
这里我分析下几个关键的地方，第一是如果当前要创建进程为/usr/libexec/amfid（也就是验证代码签名的进程），那么就注入AMFID_PAYLOAD_DYLIB模块，这个模块主要就是去patch验证签名的地方，这样才能执行任意代码；如果是其他进程，那么就注入SBINJECT_PAYLOAD_DYLIB模块（也就是tweak loader）。第二个地方是介绍了注入的实现方式，原理就是设置当前的环境变量，在调用原函数前，将当前DYLD_INSERT_LIBRARIES这个环境变量里面增加一个dylib路径，这样在进程穿件后就会去加载tweak loader。到这里，我们明白了tweak loader原来就是在这里被注入进去的。但同时又引出了一个问题，pspawn_payload模块本身又是谁加载的呢？这不又回到了之前的问题，接着分析。

#the fun part
这里的名字并不是我随便起的，因为在Electra里面就是就是。相关的代码路径在

https://github.com/coolstar/electra/blob/02858b14dac30c9ba868bd3024529e9ae6592e67/electra/the%20fun%20part/fun.c
这个文件里面的代码会做Post exploit patching所有事情，即在漏洞完成利用以后的所有事，这里当然就是指越狱环境。和其他越狱一样，主要就下面几个工作

初始化jailbreakd
setuid(0)：将当前进程设为root进程
Remap tfp0
Remount / as rw :重新挂起根目录，实现任意文件读写
Prepare bootstrap binary：准备预装的一些基本的二进制文件，包括sshd，gnu命令等
setup hook enviroment : 支持hook环境

launch some daemon：加载一些守护进程

respring ：重启Springboard
这里的最后一步如果完成，也就是平时看到的那样，代表越狱成功了。

回我之前的问题，这些步骤里面我们关心的地方就是hook环境的支持，直接相关代码在

if (enable_tweaks){
    const char* args_launchd[] = {BinaryLocation, itoa(1), "/bootstrap/pspawn_payload.dylib", NULL};
    rv = posix_spawn(&pd, BinaryLocation, NULL, NULL, (char **)&args_launchd, NULL);
    waitpid(pd, NULL, 0);

    const char* args_recache[] = {"/bootstrap/usr/bin/recache", "--no-respring", NULL};
    rv = posix_spawn(&pd, "/bootstrap/usr/bin/recache", NULL, NULL, (char **)&args_recache, NULL);
    waitpid(pd, NULL, 0);
}
也就是说如果设置了支持tweak的话，就会将pspawn_payload模块注入到1号进程，而1号进程就是launchd进程。另外你可能想问，那这里的注入又是怎么实现的呢？不可能又是hook posix_spawn注入环境变量吧，这不就产生鸡生蛋和蛋生鸡的问题了吗？事实上这里的注入并不是通过hook posix_spawn，注入的实现在

https://github.com/coolstar/electra/tree/02858b14dac30c9ba868bd3024529e9ae6592e67/basebinaries/inject_criticald
注入的原理就是通过task_for_pid来实现的，如果你的设备是用的coolstar系越狱（Electra或者Chimera）的话，你会在越狱目录下存在这个可执行文件，下面是Chimera越狱的信息

xia0:/chimera root# ls -la
total 1100
drwxr-xr-x  8 root wheel    256 Feb 26 13:19 ./
drwxr-xr-x 28 root wheel    896 Sep 16 17:44 ../
-rwxr-xr-x  1 root wheel 168736 Sep 17 10:21 inject_criticald*
-rwxr-xr-x  1 root wheel 207920 Sep 17 10:21 jailbreakd*
-rwxr-xr-x  1 root wheel 133840 Sep 17 10:21 jailbreakd_client*
-rwxr-xr-x  1 root wheel 167296 Sep 17 10:21 libjailbreak.dylib*
-rwxr-xr-x  1 root wheel 236896 Sep 17 10:21 pspawn_payload-stg2.dylib*
-rwxr-xr-x  1 root wheel 202640 Sep 17 10:21 pspawn_payload.dylib*
xia0:/chimera root# ./inject_criticald 
Usage: inject_criticald <pid> <dylib>
inject_criticald这个命令可以直接对进程进行注入dylib。到这里，关于tweak loader的加载问题已经得到了解决，整个加载的过程可以说就是越狱的整个过程。现在tweak loader由谁加载的问题解决了，但是何时被加载和初始化的问题还没解决？接下来就和越狱本身不相关了，要从DYLD_INSERT_LIBRARIES说起

#DYLD_INSERT_LIBRARIES && dyld
下面就抛开越狱，进入DYLD_INSERT_LIBRARIES和dyld的实现细节里面，由于dyld本事是开源的，所以从源码开始分析。直接搜索DYLD_INSERT_LIBRARIES最可疑的地方就在这里

// In order for register_func_for_add_image() callbacks to to be called bottom up,
// we need to maintain a list of root images. The main executable is usally the
// first root. Any images dynamically added are also roots (unless already loaded).
// If DYLD_INSERT_LIBRARIES is used, those libraries are first.
static void addRootImage(ImageLoader* image)
{
    //dyld::log("addRootImage(%p, %s)\n", image, image->getPath());
    // add to list of roots
    sImageRoots.push_back(image);
}
注释里面说到了一句，If DYLD_INSERT_LIBRARIES is used, those libraries are first.

也就是说，如果DYLD_INSERT_LIBRARIES环境变量注入的模块会被优先处理。本身这个函数的话是在下面函数中调用

void link(ImageLoader* image, bool forceLazysBound, bool neverUnload, const ImageLoader::RPathChain& loaderRPaths)
{
    // add to list of known images.  This did not happen at creation time for bundles
    if ( image->isBundle() && !image->isLinked() )
        addImage(image);

    // we detect root images as those not linked in yet 
    if ( !image->isLinked() )
        addRootImage(image);

    // process images
    try {
        image->link(gLinkContext, forceLazysBound, false, neverUnload, loaderRPaths);
    }
    catch (const char* msg) {
        garbageCollectImages();
        throw;
    }
}
接下来一个重要的函数就是initializeMainExecutable()

void initializeMainExecutable()
{
    // record that we've reached this step
    gLinkContext.startedInitializingMainExecutable = true;

    // run initialzers for any inserted dylibs
    ImageLoader::InitializerTimingList initializerTimes[sAllImages.size()];
    initializerTimes[0].count = 0;
    const size_t rootCount = sImageRoots.size();
    if ( rootCount > 1 ) {
        for(size_t i=1; i < rootCount; ++i) {
            sImageRoots[i]->runInitializers(gLinkContext, initializerTimes[0]);
        }
    }

    // run initializers for main executable and everything it brings up 
    sMainExecutable->runInitializers(gLinkContext, initializerTimes[0]);

    // register cxa_atexit() handler to run static terminators in all loaded images when this process exits
    if ( gLibSystemHelpers != NULL ) 
        (*gLibSystemHelpers->cxa_atexit)(&runAllStaticTerminators, NULL, NULL);

    // dump info if requested
    if ( sEnv.DYLD_PRINT_STATISTICS )
        ImageLoaderMachO::printStatistics((unsigned int)sAllImages.size(), initializerTimes[0]);
}
这里可以看到会去先初始化sImageRoots，然后才初始化sMainExecutable。当然后面就是一个递归的初始化过程，即是说如果初始化的模块依赖其他模块，那么又先初始化依赖的模块。在递归初始化函数之中有个地方

void ImageLoader::recursiveInitialization(const LinkContext& context, mach_port_t this_thread,
                                          InitializerTimingList& timingInfo, UninitedUpwards& uninitUps)
{
    ...
    // let objc know we are about to initialize this image
    uint64_t t1 = mach_absolute_time();
    fState = dyld_image_state_dependents_initialized;
    oldState = fState;
    context.notifySingle(dyld_image_state_dependents_initialized, this);

    // initialize this image
    bool hasInitializers = this->doInitialization(context);

    // let anyone know we finished initializing this image
    fState = dyld_image_state_initialized;
    oldState = fState;
    context.notifySingle(dyld_image_state_initialized, this);

    ...
}
从这里可以看出，+load函数确实会比mod_init_func优先执行。

最后总结一下，由于tweak loader是通过DYLD_INSERT_LIBRARIES注入的，所以会优先初始化，只有这样才能实现加载tweak模块的功能。到这里tweak loader何时被初始化的疑问也得到了解决，后面会用实验去验证这个分析。

#实验
前面分析了这么多，那实际情况到底是不是这样的呢。首先我们还是对CFBundleGetMainBundle、App里面的+load和mod_init_func下断点，首先断下来的是：

(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 4.1
  * frame #0: 0x00000001fd2d18ac CoreFoundation`CFBundleGetMainBundle
    frame #1: 0x00000001fdbfeadc Foundation`+[NSBundle mainBundle] + 112
    frame #2: 0x00000001024a2ee0 TweakInject.dylib`___lldb_unnamed_symbol1$$TweakInject.dylib + 96
    frame #3: 0x000000010256f56c dyld`ImageLoaderMachO::doModInitFunctions(ImageLoader::LinkContext const&) + 424
    frame #4: 0x000000010256f7ac dyld`ImageLoaderMachO::doInitialization(ImageLoader::LinkContext const&) + 40
    frame #5: 0x0000000102569f64 dyld`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 512
    frame #6: 0x0000000102568dd8 dyld`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 152
    frame #7: 0x0000000102568e98 dyld`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 88
    frame #8: 0x00000001025567d4 dyld`dyld::initializeMainExecutable() + 188
    frame #9: 0x000000010255b88c dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 4708
    frame #10: 0x0000000102555044 dyld`_dyld_start + 68
从调用链来看initializeMainExecutable后就是先初始化TweakInject.dylib，这时候app自身代码还没执行。接下来断下来是

(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 3.1
  * frame #0: 0x000000010244e7f0 TestAPP`+[OCClassDemo load](self=OCClassDemo, _cmd="load") at OCClassDemo.m:20:5
    frame #1: 0x00000001fc476a24 libobjc.A.dylib`call_load_methods + 188
    frame #2: 0x00000001fc477d94 libobjc.A.dylib`load_images + 148
    frame #3: 0x00000001025564c4 dyld`dyld::notifySingle(dyld_image_states, ImageLoader const*, ImageLoader::InitializerTimingList*) + 488
    frame #4: 0x0000000102569f40 dyld`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 476
    frame #5: 0x0000000102568dd8 dyld`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 152
    frame #6: 0x0000000102568e98 dyld`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 88
    frame #7: 0x00000001025567f8 dyld`dyld::initializeMainExecutable() + 224
    frame #8: 0x000000010255b88c dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 4708
    frame #9: 0x0000000102555044 dyld`_dyld_start + 68
从调用链看，这时候开始初始化主模块，而且正是+load函数，所以+load就是app最早执行代码的地方。而且是通知libobjc.A.dylib去完成的。这里可以回到dyld的源码中：

static void notifySingle(dyld_image_states state, const ImageLoader* image)
{
    //dyld::log("notifySingle(state=%d, image=%s)\n", state, image->getPath());
    std::vector<dyld_image_state_change_handler>* handlers = stateToHandlers(state, sSingleHandlers);
    if ( handlers != NULL ) {
        dyld_image_info info;
        info.imageLoadAddress    = image->machHeader();
        info.imageFilePath        = image->getRealPath();
        info.imageFileModDate    = image->lastModified();
        for (std::vector<dyld_image_state_change_handler>::iterator it = handlers->begin(); it != handlers->end(); ++it) {
            const char* result = (*it)(state, 1, &info);
            if ( (result != NULL) && (state == dyld_image_state_mapped) ) {
                //fprintf(stderr, "  image rejected by handler=%p\n", *it);
                // make copy of thrown string so that later catch clauses can free it
                const char* str = strdup(result);
                throw str;
            }
        }
    }
    ...
}
notifySingle函数会循环调用所有注册通知的处理模块

// Callback that provides a bottom-up array of images
// For dyld_image_state_[dependents_]mapped state only, returning non-NULL will cause dyld to abort loading all those images
// and append the returned string to its load failure error message. dyld does not free the string, so
// it should be a literal string or a static buffer
//
typedef const char* (*dyld_image_state_change_handler)(enum dyld_image_states state, uint32_t infoCount, const struct dyld_image_info info[]);
这里就是由libobjc.A.dylib去处理的+load函数。最后断下来的就是：

(lldb) bt
* thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
  * frame #0: 0x000000010242bd20 TestAPP`temp_init at temp.c:98:5
    frame #1: 0x000000010256f56c dyld`ImageLoaderMachO::doModInitFunctions(ImageLoader::LinkContext const&) + 424
    frame #2: 0x000000010256f7ac dyld`ImageLoaderMachO::doInitialization(ImageLoader::LinkContext const&) + 40
    frame #3: 0x0000000102569f64 dyld`ImageLoader::recursiveInitialization(ImageLoader::LinkContext const&, unsigned int, char const*, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 512
    frame #4: 0x0000000102568dd8 dyld`ImageLoader::processInitializers(ImageLoader::LinkContext const&, unsigned int, ImageLoader::InitializerTimingList&, ImageLoader::UninitedUpwards&) + 152
    frame #5: 0x0000000102568e98 dyld`ImageLoader::runInitializers(ImageLoader::LinkContext const&, ImageLoader::InitializerTimingList&) + 88
    frame #6: 0x00000001025567f8 dyld`dyld::initializeMainExecutable() + 224
    frame #7: 0x000000010255b88c dyld`dyld::_main(macho_header const*, unsigned long, int, char const**, char const**, char const**, unsigned long*) + 4708
    frame #8: 0x0000000102555044 dyld`_dyld_start + 68
这里看出就是mod_init_func了，当然在dyld中调用这个函数的地方就是

bool ImageLoaderMachO::doInitialization(const LinkContext& context)
{
    CRSetCrashLogMessage2(this->getPath());

    // mach-o has -init and static initializers
    doImageInit(context);
    doModInitFunctions(context);

    CRSetCrashLogMessage2(NULL);

    return (fHasDashInit || fHasInitializers);
}
其中doModInitFunctions就会解析load command找到_DATA,_mod_init_func列表进行初始化调用。

### 解决“XX.app”已损坏,无法打开。 您应该将它移到废纸篓。

通常在非 Mac App Store下载的软件都会提示“xxx已损坏，打不开。
您应将它移到废纸篓”或者“打不开 xxx，因为它来自身份不明的开发者”。
原因：Mac电脑启用了安全机制，默认只信任Mac App Store下载的软件以及拥有开发者 ID 签名的软件，但是同时也阻止了没有开发者签名的 “老实软件”

解决方法：

#### 1. macOS Catalina 10.15系统：

打开「终端.app」，输入以下命令并回车，输入开机密码回车

sudo xattr -rd com.apple.quarantine 空格 软件的路径

如CleanMyMac X.app
```
sudo xattr -rd com.apple.quarantine /Applications/CleanMyMac X.app
```
#### 2. macOS Mojave 10.14及以下系统：

打开「终端.app」，输入以下命令并回车，输入开机密码回车
```
sudo spctl --master-disable
```
3. macOS Catalina 10.15.4 系统：

更新10.15.4系统后软件出现意外退出，可按照下面的方法给软件签名

1.安装Command Line Tools 工具

打开「终端app」输入如下命令：

xcode-select --install

2.给软件签名

打开终端工具输入并执行如下命令：

sudo codesign --force --deep --sign - (应用路径)

3.错误解决

如出现以下错误提示：

/文件位置 : replacing existing signature

/文件位置 : resource fork,Finder information,or similar detritus not allowed

那么，先在终端执行：

xattr -cr /文件位置（直接将应用拖进去即可）

然后再次执行如下指令即可：

codesign --force --deep --sign - /文件位置（直接将应用拖进去即可）

## iOS私有库 头文件查询网址
## https://developer.limneos.net/

### Preference Bundle
插件设置项Preference Bundle
一个tweak可能要设置一些选项，就像App Store上的App一样，在设置应用里面可以设置，
在theos里，可以通过创建Preference Bundle来为插件提供设置界面,有点类似于Xcode里的Setting Bundle,
Preference Bundle安装到手机后会在/Library/PreferenceBundles/目录生成一个对应的bundle,
此bundle会基于PreferenceLoader注入到设置应用(Setting.app)，
而PreferenceLoader是基于Cydia Substrate的工具，主要为插件在系统设置界面添加一个设置入口。
```
文件	                  作用
entry.plist	        为插件在系统设置应用界面添加一个入口，一般修改icon与label即可
XXXRootListController	XXXRootListController必须继承PSListController或者PSViewController，且必须实现- (id)specifiers方法，因为PSListController依赖_specifiers来获得metadata和group
Makefile	        preference bundle的Makefile，一般不用过多修改与操作，编译Tweak的Makefile会跟随着一起编译
Resources文件夹下的文件如下	
Info.plist	        主要记录这个preference bundle的配置信息，一般不用修改
Root.plist	        重点编写的文件，主要配置插件界面的https://iphonedevwiki.net/index.php/Preferences_specifier_plist#PSSpecifier_runtime_properties_of_plist_keys
ML格式，好像还有一种类似JSON格式的
```
首先来看 entry.plist。这个文件定义了我们的 Preference Bundle 在「设置」App 中的入口信息，我们只需关注 label 和 icon 字段，它们分别决定了入口的显示名称和图标。
xxx/Resources/Root.plist 这个文件中定义。打开观察，有 Awesome Switch 1 的字样
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>cnxlsn0w First Page</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSwitchCell</string>
			<key>default</key>
			<true/>
			<key>defaults</key>
			<string>cn.xl.sn0w</string>
			<key>key</key>
			<string>AwesomeSwitch1</string>
			<key>label</key>
			<string>Awesome Switch 1</string>
		</dict>
	</array>
	<key>title</key>
	<string>cnxlsn0w</string>
</dict>
</plist>
```
编辑这个 plist 文件，构建出适合我们的设置界面UI
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>items</key>
	<array>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>Semester Setting</string>
			<key>footerText</key>
			<string>Make sure your input is in the correct format.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSEditTextCell</string>
			<key>default</key>
			<string></string>
			<key>keyboard</key>
			<string>numbers</string>
			<!-- <key>isNumeric</key>
			<true/> -->
			<key>placeholder</key>
			<string>yyyyMMdd (eg. 20160627)</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>key</key>
			<string>StartDateStr</string>
			<key>label</key>
			<string>Start Date</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>Duration</string>
			<key>id</key>
			<string>SliderLabelCell</string>
			<key>footerText</key>
			<string>Total weeks in the semester.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSliderCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>min</key>
			<integer>1</integer>
			<key>max</key>
			<integer>30</integer>
			<key>default</key>
			<integer>18</integer>
			<key>showValue</key>
			<true/>
			<key>isSegmented</key>
			<true/>
			<key>segmentCount</key>
			<integer>29</integer>
			<key>key</key>
			<string>Duration</string>
			<key>label</key>
			<string>Duration</string>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>First Weekday</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSegmentCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>key</key>
			<string>WeekStartDay</string>
			<key>label</key>
			<string>First Weekday</string>
			<key>validValues</key>
			<array>
				<string>Monday</string>
				<string>Sunday</string>
			</array>
			<key>validTitles</key>
			<array>
				<string>Monday</string>
				<string>Sunday</string>
			</array>
			<key>default</key>
			<string>Monday</string>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string>Display Settings</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSwitchCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>label</key>
			<string>Lock Screen</string>
			<key>key</key>
			<string>LockScreenEnabled</string>
			<key>default</key>
			<true/>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSSwitchCell</string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>label</key>
			<string>Notification Center</string>
			<key>key</key>
			<string>NCEnabled</string>
			<key>default</key>
			<true/>
			<key>PostNotification</key>
			<string>com.wangjinli.weekcountpb/prefsChanged</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>label</key>
			<string></string>
			<key>footerText</key>
			<string>Use %W to denote where the week number should be displayed.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSEditTextCell</string>
			<key>default</key>
			<string></string>
			<!-- <key>keyboard</key>
			<string>numbers</string> -->
			<!-- <key>isNumeric</key>
			<true/> -->
			<key>placeholder</key>
			<string></string>
			<key>defaults</key>
			<string>com.wangjinli.weekcountpb</string>
			<key>key</key>
			<string>DisplayFormat</string>
			<key>label</key>
			<string>Display Format</string>
			<key>default</key>
			<string>Week %W</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>footerText</key>
			<string>Respring to apply changes.</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSButtonCell</string>
			<key>label</key>
			<string>Respring</string>
			<key>action</key>
			<string>respring</string>
		</dict>
		<dict>
			<key>cell</key>
			<string>PSGroupCell</string>
			<key>footerText</key>
			<string>© 2016  Li</string>
		</dict>
	</array>
	<key>title</key>
	<string>WeekCount</string>
</dict>
</plist>
```
iPhone注销主屏幕
```
- (void)respring {
    system("killall -9 SpringBoard");
}
```
#### 资料:
https://iphonedevwiki.net/index.php/Preferences_specifier_plist#PSSpecifier_runtime_properties_of_plist_keys
http://iphonedevwiki.net/index.php/Preferences_specifier_plist

### 自定义微信骰子

通过发送表情的 View 找到其 Controller，再在 Controller 中找到发送表情这个操作的响应方法。
然后通过逆向二进制文件得到的反汇编源码，以该方法作为入口，逐层分析调用关系，直到找到关键方法，进而分析该表情的 Model 并完成修改。
准备工作

#### 砸壳、头文件获取
App Store 里 App 的二进制文件被进行了加密，无法直接反汇编分析，也无法通过 class-dump 获取头文件，因此首先需要对其进行解密，通常称之为「砸壳」。
~  class-dump -S -s -H ./WeChat -o ./headers/

#### debugserver 与 LLDB 配置
LLDB 是 Xcode 内置的调试器，debugserver 则是运行在 iOS 上的调试服务端，我们将使用它们对微信进行动态调试分析。
在将设备添加到 Xcode 之后，debugserver 会被自动安装到设备的 /Developer/usr/bin/ 目录下。
但由于缺少 task_for_pid 权限，这里的 debugserver 只能用来调试自己开发的 App，因此需要对其进行处理。
将 debugserver 拷贝到 Mac，首先通过以下命令对其进行「瘦身」。其中 arm64 为64位处理器架构，此参数因设备而异（如对于 iPhone 5 就应是 armv7s）。
~ lipo -thin arm64 ./debugserver -output ./debugserver

然后为其添加 task_for_pid 权限，下载这个 ent.plist 文件对其进行签名。
~ codesign -s - --entitlements ent.plist -f debugserver
完成上述步骤后将 debugserver 拷贝回设备的 /usr/bin/ 目录下，并赋予可执行权限即可。
LLDB 支持 Python 脚本，使用 Python 可以大幅提高调试效率。Chisel 是 Facebook 开源的一个 LLDB Python 命令集，我们将使用它帮助我们的调试。用 Homebrew 安装 Chisel 并将其添加进 LLDB 的初始化脚本中。
```
~ brew install chisel
~ echo command script import /path/to/fblldb.py >> ~/.lldbinit
```

#### 定位入口方法
使用 debugserver 启动微信。
iPhone:~ root# debugserver *:1234 -x backboard /path/to/WeChat.app/WeChat
然后在 Mac 上用 LLDB 连接到 debugserver，并让微信继续运行。
```
~ lldb
(lldb) process connect connect://IOS_IP:1234
Process 51735 stopped
* thread #1: tid = 0xb076f, 0x000000018270d014 libsystem_kernel.dylib`semaphore_wait_trap + 8, queue = 'com.apple.main-thread', stop reason = signal SIGSTOP
    frame #0: 0x000000018270d014 libsystem_kernel.dylib`semaphore_wait_trap + 8
libsystem_kernel.dylib`semaphore_wait_trap:
->  0x18270d014 <+8>: ret

libsystem_kernel.dylib`semaphore_wait_signal_trap:
    0x18270d018 <+0>: movn   x16, #0x24
    0x18270d01c <+4>: svc    #0x80
    0x18270d020 <+8>: ret
(lldb) c
Process 51735 resuming
```

待微信启动完毕之后，先打开微信 Mac 版，借助文件传输助手构建一个收发双端的测试环境（有小号或者有女朋友愿意配合测试的也可）。进入到发送骰子的界面，中断微信，打印出当前的 UI 结构。
```
(lldb) process interrupt
(lldb) po [[UIApp keyWindow] recursiveDescription]
<iConsoleWindow: 0x13df5dd20; baseClass = UIWindow; frame = (0 0; 375 667); autoresize = W+H; gestureRecognizers = <NSArray: 0x13df4e8f0>; layer = <UIWindowLayer: 0x13dde49a0>>
   | <UILayoutContainerView: 0x13f3ba980; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x13f3ba880>>
   |    | <UITransitionView: 0x13f3bb560; frame = (0 0; 375 667); clipsToBounds = YES; autoresize = W+H; layer = <CALayer: 0x13dd02a90>>
   ...
    <EmoticonViewWithPreview: 0x13fae98a0; frame = (116 18; 56.5 56.5); layer = <CALayer: 0x13fd2f230>>
打印出的 UI 结构非常复杂，经过一番仔细寻找，发现 EmoticonViewWithPreview 这个 View 的名称比较吻合，且数量是 7 个，和我在这个界面上的表情数相同，初步确定它就是表情显示的 View。因为骰子是第二个表情，所以找到第二个 EmoticonViewWithPreview 的地址 0x13fae98a0，尝试使用 hide 0x13fae98a0 命令，果然发现设备上的骰子消失了，猜想得到了验证。
下面定位它的 Controller，使用 presponder 命令打印其响应链。
(lldb) presponder 0x13fae98a0
<EmoticonViewWithPreview: 0x13fae98a0; frame = (202.5 18; 56.5 56.5); layer = <CALayer: 0x13fb14360>>
   | <EmoticonGridView: 0x13f8e2600; frame = (0 0; 375 187); gestureRecognizers = <NSArray: 0x13fbe45f0>; layer = <CALayer: 0x13fbc4470>>
   |    | <EmoticonBoardPageCollectionEmoticonGridCell: 0x13fd39720; baseClass = UICollectionViewCell; frame = (2250 0; 375 187); layer = <CALayer: 0x13faf4d20>>
   |    |    | <UICollectionView: 0x13e899a00; frame = (0 160; 375 187); gestureRecognizers = <NSArray: 0x13fc2cb40>; layer = <CALayer: 0x13f9f2db0>; contentOffset: {2250, 0}; contentSize: {10875, 187}> collection view layout: <UICollectionViewFlowLayout: 0x13fc29b70>
   |    |    |    | <UIView: 0x13f91c520; frame = (0 -160; 375 347); clipsToBounds = YES; layer = <CALayer: 0x13f909ea0>>
   |    |    |    |    | <EmoticonBoardView: 0x13f4c4130; frame = (0 443; 375 224); layer = <CALayer: 0x13fc035f0>>
   |    |    |    |    |    | <MMInputToolView: 0x13f5b7cf0; frame = (0 0; 375 667); text = ''; layer = <CALayer: 0x13fa6cc40>>
   |    |    |    |    |    |    | <UIView: 0x13f4981b0; frame = (0 0; 375 667); autoresize = W+H; layer = <CALayer: 0x13f90a7c0>>
   |    |    |    |    |    |    |    | <BaseMsgContentViewController: 0x13e42be00>
   |    |    |    |    |    |    |    ...
可以看到 BaseMsgContentViewController 就是它的 Controller，我们打开 BaseMsgContentViewController.h 观察一下，尝试寻找点击骰子之后的响应方法。
这个头文件有多达 600 多行（一个类写成这样真的没问题吗？），使用关键词 emoticon 搜索，容易发现 — (void)SendEmoticonMesssageToolView:(id)arg1; 方法较为可疑，我们来验证一下这个方法的作用。
使用 Hopper Disassembler v3 对「砸壳」过后的微信二进制文件进行反汇编分析，找到该方法。
-[BaseMsgContentViewController SendEmoticonMesssageToolView:]:
00000001018eb1e8    stp     x24, x23, [sp, #0xffffffc0]!
...
00000001018eb2f4    b       imp___stubs__objc_release
                            ; endp
```
下面我们在该方法入口地址处下断点。首先找到微信的 ASLR 偏移地址。
(lldb) im li -o
[  0] 0x000000000005c000
[  1] 0x000000010388c000
...
ASLR 偏移为 0x5c000，方法入口地址为 0x1018eb1e8，因此该命令在内存中的地址应为 0x5c000+0x1018eb1e8=0x1019471e8，我们在该处下断点。
(lldb) br s -a 0x5c000+0x1018eb1e8
Breakpoint 1: where = WeChat`___lldb_unnamed_function82507$$WeChat, address = 0x00000001019471e8
按照同样的方法，在该方法最后一条语句处也下断点。然后让微信恢复运行，点击骰子，入口的断点果然被触发了。
```
Process 51735 stopped
* thread #1: tid = 0xb076f, 0x00000001019471e8 WeChat`___lldb_unnamed_function82507$$WeChat, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
    frame #0: 0x00000001019471e8 WeChat`___lldb_unnamed_function82507$$WeChat
WeChat`___lldb_unnamed_function82507$$WeChat:
->  0x1019471e8 <+0>:  stp    x24, x23, [sp, #-64]!
    0x1019471ec <+4>:  stp    x22, x21, [sp, #16]
    0x1019471f0 <+8>:  stp    x20, x19, [sp, #32]
    0x1019471f4 <+12>: stp    x29, x30, [sp, #48]
(lldb)
```
这时收发双方均未出现骰子。输入 c 让微信继续运行，断点 2 随即被触发。输入 ni 跳出方法，这时可以观察到，接收方已经收到了骰子，而本机尚未出现。这说明产生骰子点数的关键就在这个方法内部，随后只会进行一些本地 UI 的更新。我们成功找到了入口方法，接下来就是顺着调用链继续摸索下去。
探索调用链

在入口方法中，我们将着重关注形如 00000001018eb23c bl imp___stubs__objc_msgSend 方法调用语句。这是因为 Objective-C 中，[SomeObject someMethod] 的底层实现是 objc_msgSend(SomeObject, someMethod)，因此在这些语句处下断点，并打印出参数，就可以得知调用的是哪个类的哪个方法，从而逐层进行寻找。
简单粗暴地在每一个 objc_msgSend 处下断点，观察执行完哪一句之后，接收方收到了骰子即可。于是顺利地定位到了 0x018eb2cc 处的语句，在该语句处查看参数就可以得知是调用的是哪个方法了。在 64 位系统中，函数的参数存放在 X0~XN 寄存器中，所以 X0 应是类/实例，而 X1 应是方法名，它可以被强制转换为字符串。
```
(lldb) po [$x0 class]
WeixinContentLogicController

(lldb) p (char *)$x1
(char *) $115 = 0x00000001026c34ce "SendEmoticonMessage:"
```
可见此处调用的是 [WeixinContentLogicController SendEmoticonMessage:] 方法。直接在 Hopper 中搜不到这个方法，打开 WeixinContentLogicController.h 观察，原来这个方法定义在其基类 BaseMsgContentLogicController 中，这样就可以成功在 Hopper 中找到它。
接下来如法炮制，在 [BaseMsgContentLogicController SendEmoticonMessage:] 中再次找到了一个关键的 objc_msgSend，调用的是 [GameController sendGameMessage:toUsr:] 这个方法。
继续顺藤摸瓜，在 Hopper 中定位到 [GameController sendGameMessage:toUsr:] 方法，大致一扫，马上观察到了嫌疑人的身影：这个方法中调用了 random 随机数函数。
Image for post
看来骰子点数就是在这之后产生的，继续从这一句之后进行分析。依然采用之前的方法层层深入，最终可以摸索出如下的调用链。
Image for post
定位 Model
整理出调用链后，我们直接在调用最后一个上传方法 [CEmoticonUploadMgr StartUpload:] 时下断点，查看它的参数（应在 X2 寄存器）。
(lldb) po [$x2 class]
CMessageWrap
至此我们成功定位了骰子表情的 Model — — 它是一个 CMessageWrap 类的实例，我们在头文件中进行搜索，发现这个类具有多个 category（实际上该类是所有微信消息的 Model，考虑到微信文字、语音、表情等多种多样的消息类型，category 是一个很自然的实现方式）。我们直接打开 CMessageWrap-Emoticon.h 查看。
Image for post
容易发现其中下面两行很有可能与我们的目标有关。
@property(nonatomic) unsigned int m_uiGameContent; // @dynamic m_uiGameContent;
@property(nonatomic) unsigned int m_uiGameType; // @dynamic m_uiGameType;

#### 下面我们编写 Tweak，

hook [CEmoticonUploadMgr StartUpload:] 这个方法，将参数的这两个属性打印出来观察。过程略过，最终经过多次实验，可以得到如下结论。

m_uiGameType 为 1 代表剪刀石头布，2 代表骰子，0 则是普通表情；m_uiGameContent 的值从 1 至 9，依次代表剪刀、石头、布以及骰子的 1 ~ 6 点。
修改结果
首先尝试直接在 [CEmoticonUploadMgr StartUpload:] 中截获传入的参数，根据 m_uiGameType 判断表情类型，然后修改 m_uiGameContent。此时结果是（感谢小伙伴们配合测试）：本机没有效果；接收方若是 iPhone 则可以显示修改后的结果，若是 Android 设备或 Mac 则同样无效果，且结果与本机显示的相同。
这说明两点问题：第一，随机数产生后，在之前得出的调用链中传递给了其他没有分析到的方法，造成本机不生效；第二，最终上传的 CMessageWrap 中除了 m_uiGameContent 属性外，仍有其他属性记录了骰子的真实值。
为验证第二点，我们打印出 [CEmoticonUploadMgr StartUpload:] 的参数的所有信息进行查看。
```
(lldb) pinternals $x2
(CMessageWrap) $129 = {
  MMObject = {
    NSObject = {
      isa = CMessageWrap
    }
  }
  m_bIsSplit = false
  m_bNew = true
  m_uiMesLocalID = 328
  m_n64MesSvrID = 0
  m_nsFromUsr = 0xa0a0d02812812039
  m_nsToUsr = 0xa0221102a012405a
  m_uiMessageType = 47
  m_nsContent = 0x000000013f489e40 @"<msg><emoji md5=\"5ba8e9694b853df10b9f2a77b312cc09\" type=\"1\" len = \"8636\" productid=\"custom_emoticon_pid\"></emoji><gameext type=\"2\" content=\"9\" ></gameext></msg>"
  m_uiStatus = 1
  ...
  
  ```
可以发现 m_nsContent 属性的值是一个 xml 格式的字符串，其中 <gameext type=\”2\” content=\”9\” ></gameext> 就是骰子的信息。也就是说，修改过后 m_nsContent 和 m_uiGameContent 两个属性中的信息出现了矛盾，而微信不同平台的客户端也许在此处的接收逻辑有所差异，导致了上述结果。
要解决这个问题，本质上与解决第一点是等价的，无非是往调用链的上游寻找遗漏点。过程与之前类似，
最终找到了 [GameController getMD5ByGameContent:] 这个方法（红色方框）与结果有关，其参数就是 m_uiGameContent 的值。
```
#import "headers/CEmoticonWrap.h"
#import "headers/CMessageWrap.h"
#import "headers/WCDUserDefaultsMgr.h"
#import <UIKit/UIKit.h>

CMessageWrap *setDice(CMessageWrap *wrap, unsigned int point) {
	if (wrap.m_uiGameType == 2) {
		wrap.m_uiGameContent = point + 3;
	}
	return wrap;
}

CMessageWrap *setJsb(CMessageWrap *wrap, unsigned int type) {
	if (wrap.m_uiGameType == 1) {
		wrap.m_uiGameContent = type;
	}
	return wrap;
}

WCDUserDefaultsMgr *prefs = nil;

%hook GameController

+ (id)getMD5ByGameContent:(unsigned int)arg1 {
	prefs = [WCDUserDefaultsMgr sharedUserDefaults];
	if (arg1 > 3 && arg1 < 10) {
		if (prefs.diceEnabled) {
			return %orig(prefs.dicePoint + 3);
		} else {
			return %orig;
		}
	} else if (arg1 > 0 && arg1 < 4) {
		if (prefs.jsbEnabled) {
			return %orig(prefs.jsbType);
		} else {
			return %orig;
		}
	} else {
		return %orig;
	}
}

%end

%hook CMessageMgr

- (void)AddEmoticonMsg:(id)arg1 MsgWrap:(id)arg2 {
	CMessageWrap *wrap = (CMessageWrap *)arg2;
	if (prefs == nil) { prefs = [WCDUserDefaultsMgr sharedUserDefaults]; }
	if (wrap.m_uiGameType == 2) {
		if (prefs.diceEnabled) {
			%orig(arg1, setDice(arg2, prefs.dicePoint));
		} else {
			%orig;
		}
	} else if (wrap.m_uiGameType == 1) {
		if (prefs.jsbEnabled) {
			%orig(arg1, setJsb(arg2, prefs.jsbType));
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}

%end

%hook CEmoticonUploadMgr

- (void)StartUpload:(id)arg1 {
	CMessageWrap *wrap = (CMessageWrap *)arg1;
	if (prefs == nil) { prefs = [WCDUserDefaultsMgr sharedUserDefaults]; }
	if (wrap.m_uiGameType == 2) {
		if (prefs.diceEnabled) {
			%orig(setDice(arg1, prefs.dicePoint));
		} else {
			%orig;
		}
	} else if (wrap.m_uiGameType == 1) {
		if (prefs.jsbEnabled) {
			%orig(setJsb(arg1, prefs.jsbType));
		} else {
			%orig;
		}
	} else {
		%orig;
	}
}

%end

```
#### hook如上3个方法，就可以成功地控制骰子/剪刀石头布游戏的结果

## DYLD_INSERT_LIBRARIES
dylib本质上是一个Mach-O格式的文件，它与普通的Mach-O执行文件几乎使用一样的结构，只是在文件类型上一个是MH_DYLIB，一个是MH_EXECUTE。
在系统的/usr/lib目录下，存放了大量供系统与应用程序调用的动态库文件

循环遍历DYLD_INSERT_LIBRARIES环境变量中指定的动态库列表，并调用loadInsertedDylib()将其(插件dylib)加载。该函数调用load()完成加载工作。

```
#ifndef SUBSTRATE_ENVIRONMENT_HPP
#define SUBSTRATE_ENVIRONMENT_HPP

#define SubstrateVariable_ "DYLD_INSERT_LIBRARIES"
#define SubstrateLibrary_ "/Library/MobileSubstrate/MobileSubstrate.dylib"

#define SubstrateSafeMode_ "_MSSafeMode"

void MSClearEnvironment();

#endif//SUBSTRATE_ENVIRONMENT_HPP
```

## 检测是否越狱
```
#import "UserCust.h"
#import <UIKit/UIKit.h>
#import <sys/stat.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>
#import <objc/runtime.h>
#import <objc/message.h>
#include <stdio.h>
#import <dlfcn.h>
#import <sys/types.h>

static char *JbPaths[] = {"/Applications/Cydia.app",
    "/usr/sbin/sshd",
    "/bin/bash",
    "/etc/apt",
    "/Library/MobileSubstrate",
    "/User/Applications/"};

static NSSet *sDylibSet ; // 需要检测的动态库
static BOOL SCHECK_USER = NO; /// 检测是否越狱

@implementation UserCust


+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sDylibSet  = [NSSet setWithObjects:
                       @"/usr/lib/CepheiUI.framework/CepheiUI",
                       @"/usr/lib/libsubstitute.dylib",
                       @"/usr/lib/substitute-inserter.dylib",
                       @"/usr/lib/substitute-loader.dylib",
                       @"/usr/lib/substrate/SubstrateLoader.dylib",
                       @"/usr/lib/substrate/SubstrateInserter.dylib",
                       @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                       @"/Library/MobileSubstrate/DynamicLibraries/0Shadow.dylib",
                  
                  nil];
    _dyld_register_func_for_add_image(_check_image);
  });
}

+ (instancetype)sharedInstance {
    
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}

// 监听image加载，从这里判断动态库是否加载，因为其他的检测动态库的方案会被hook
static void _check_image(const struct mach_header *header,
                                      intptr_t slide) {
  // hook Image load
  if (SCHECK_USER) {
    // 检测后就不在检测
    return;
  }

  // 检测的lib
  Dl_info info;
  // 0表示加载失败了，这里大概率是被hook导致的
  if (dladdr(header, &info) == 0) {
    char *dlerro = dlerror();
    // 获取失败了 但是返回了dli_fname, 说明被人hook了，目前看的方案都是直接返回0来绕过的
    if(dlerro == NULL && info.dli_fname != NULL) {
      NSString *libName = [NSString stringWithUTF8String:info.dli_fname];
      // 判断有没有在动态列表里面
      if ([sDylibSet containsObject:libName]) {
        SCHECK_USER = YES;
      }
    }
    return;
  }
}


// 越狱检测
- (BOOL)UVItinitse {
  
    if (SCHECK_USER) {
      return YES;
    }

    if (isStatNotSystemLib()) {
        return YES;
    }

    if (isDebugged()) {
        return YES;
    }

    if (isInjectedWithDynamicLibrary()) {
        return YES;
    }

    if (JCheckKuyt()) {
        return YES;
    }

    if (dyldEnvironmentVariables()) {
        return YES;
    }

    return NO;
}

CFRunLoopSourceRef gSocketSource;
BOOL fileExist(NSString* path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if([fileManager fileExistsAtPath:path isDirectory:&isDirectory]){
        return YES;
    }
    return NO;
}

BOOL directoryExist(NSString* path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if([fileManager fileExistsAtPath:path isDirectory:&isDirectory]){
        return YES;
    }
    return NO;
}

BOOL canOpen(NSString* path)
{
    FILE *file = fopen([path UTF8String], "r");
    if(file==nil){
        return fileExist(path) || directoryExist(path);
    }
    fclose(file);
    return YES;
}

#pragma mark 使用NSFileManager通过检测一些越狱后的关键文件是否可以访问来判断是否越狱
// 检测越狱
BOOL JCheckKuyt()
{
    
    if(TARGET_IPHONE_SIMULATOR)return NO;

    //Check cydia URL hook canOpenURL 来绕过
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.avl.com"]])
    {
        return YES;
    }

    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.example.package"]])
    {
        return YES;
    }

    NSArray* checks = [[NSArray alloc] initWithObjects:@"/Application/Cydia.app",
                       @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                       @"/bin/bash",
                       @"/usr/sbin/sshd",
                       @"/etc/apt",
                       @"/usr/bin/ssh",
                       @"/private/var/lib/apt",
                       @"/private/var/lib/cydia",
                       @"/private/var/tmp/cydia.log",
                       @"/Applications/WinterBoard.app",
                       @"/var/lib/cydia",
                       @"/private/etc/dpkg/origins/debian",
                       @"/bin.sh",
                       @"/private/etc/apt",
                       @"/etc/ssh/sshd_config",
                       @"/private/etc/ssh/sshd_config",
                       @"/Applications/SBSetttings.app",
                       @"/private/var/mobileLibrary/SBSettingsThemes/",
                       @"/private/var/stash",
                       @"/usr/libexec/sftp-server",
                       @"/usr/libexec/cydia/",
                       @"/usr/sbin/frida-server",
                       @"/usr/bin/cycript",
                       @"/usr/local/bin/cycript",
                       @"/usr/lib/libcycript.dylib",
                       @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                       @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                       @"/Applications/FakeCarrier.app",
                       @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                       @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                       @"/usr/libexec/ssh-keysign",
                       @"/usr/libexec/sftp-server",
                       @"/Applications/blackra1n.app",
                       @"/Applications/IntelliScreen.app",
                       @"/Applications/Snoop-itConfig.app"
                       @"/var/lib/dpkg/info", nil];
    //Check installed app
    for(NSString* check in checks)
    {
        if(canOpen(check))
        {
            return YES;
        }
    }
    //symlink verification
    struct stat sym;
    // hook lstat可以绕过
    if(lstat("/Applications", &sym) || lstat("/var/stash/Library/Ringtones", &sym) ||
       lstat("/var/stash/Library/Wallpaper", &sym) ||
       lstat("/var/stash/usr/include", &sym) ||
       lstat("/var/stash/usr/libexec", &sym)  ||
       lstat("/var/stash/usr/share", &sym) ||
       lstat("/var/stash/usr/arm-apple-darwin9", &sym))
    {
        if(sym.st_mode & S_IFLNK)
        {
            return YES;
        }
    }
  

    //Check process forking
    // hook fork
    int pid = fork();
    if(!pid)
    {
        exit(1);
    }
    if(pid >= 0)
    {
        return YES;
    }

  
//     check has class only used in breakJail like HBPreferences. 越狱常用的类，这里无法绕过，只要多找一些特征类就可以，注意，很多反越狱插件会混淆，所以可能要通过查关键方法来识别
    NSArray *checksClass = [[NSArray alloc] initWithObjects:@"HBPreferences",nil];
    for(NSString *className in checksClass)
    {
      if (NSClassFromString(className) != NULL) {
        return YES;
      }
    }
  
//    Check permission to write to /private hook FileManager 和 writeToFile来绕过
    NSString *path = @"/private/avl.txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        NSError* error;
        NSString *test = @"AVL was here";
        [test writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
        [fileManager removeItemAtPath:path error:nil];
        if(error==nil)
        {
            return YES;
        }

        return NO;
    } @catch (NSException *exception) {
        return NO;
    }
}

BOOL isInjectedWithDynamicLibrary()
{
  unsigned int outCount = 0;
  const char **images =  objc_copyImageNames(&outCount);
  for (int i = 0; i < outCount; i++) {
      printf("%s\n", images[i]);
  }
  
  
  int i=0;
    while(true){
        // hook _dyld_get_image_name方法可以绕过
        const char *name = _dyld_get_image_name(i++);
        if(name==NULL){
            break;
        }
        if (name != NULL) {
          NSString *libName = [NSString stringWithUTF8String:name];
          if ([sDylibSet containsObject:libName]) {
            return YES;
          }

        }
    }
    return NO;
}

#pragma mark 通过环境变量DYLD_INSERT_LIBRARIES检测是否越狱
BOOL dyldEnvironmentVariables ()
{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    return !(NULL == getenv("DYLD_INSERT_LIBRARIES"));
}

#pragma mark 校验当前进程是否为调试模式，hook sysctl方法可以绕过
// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
// Thanks to https://developer.apple.com/library/archive/qa/qa1361/_index.html
BOOL isDebugged()
{
    int junk;
    int mib[4];
    struct kinfo_proc info;
    size_t size;
    info.kp_proc.p_flag = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

#pragma mark 使用stat通过检测一些越狱后的关键文件是否可以访问来判断是否越狱，hook stat 方法和dladdr可以绕过
BOOL isStatNotSystemLib() {
    if(TARGET_IPHONE_SIMULATOR)return NO;
    int ret ;
    Dl_info dylib_info;
    int (*func_stat)(const char *, struct stat *) = stat;
    if ((ret = dladdr(func_stat, &dylib_info))) {
        NSString *fName = [NSString stringWithUTF8String: dylib_info.dli_fname];
        if(![fName isEqualToString:@"/usr/lib/system/libsystem_kernel.dylib"]){
            return YES;
        }
    }
    
    for (int i = 0;i < sizeof(JbPaths) / sizeof(char *);i++) {
        struct stat stat_info;
        if (0 == stat(JbPaths[i], &stat_info)) {
            return YES;
        }
    }
    
    return NO;
}

typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);

#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

// 禁止gdb调试
- (void) disable_gdb {
    if(TARGET_IPHONE_SIMULATOR)return;
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    ptrace_ptr_t ptrace_ptr = dlsym(handle, "ptrace");
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}

@end

```

## 越狱注入的原理
1.利用Cydia Substrate会将 SpringBoard 的 [FBApplicationInfo environmentVariables] hook ，

2. 将环境变量DYLD_INSERT_LIBRARIES设定新增需要载入的动态库，但是应用的二进制包无需做任何变化，

3. dyld会在载入应用的时候因为DYLD_INSERT_LIBRARIES去插入具体的库。 

屏蔽越狱检测插件shadow主要逻辑为：

shadow会维护一个列表，检索哪些文件是越狱需要保护的文件

hook相关的类，如果要检索这些文件，就影藏，返回修改后的结果。
```
hook c的类,主要是各种判断文件权限和执行命令的方法,比如：
access
getenv
fopen
freopen
stat
dlopen
hook_NSFileManager | NSFileHandle |  NSDirectoryEnumerator | hook_NSFileVersion | NSBundle
hook_NSURL
hook_UIApplication
hook_NSBundle
hook_CoreFoundation
hook UIImage
hook NSMutableArray | NSArray | NSMutableDictionary | NSDictionary | NSString
hook 第三方库检测方法
hook hook_debugging
sysctl 主要用来检测是否当前进程挂载了P_TRACED
getppid 返回当前的pid
_ptrace
hook_dyld_image 。hook image动态加载的方法
_dyld_image_count 获取image的数量
_dyld_get_image_name 获取动态库的名字
hook_dyld_dlsym。hook 用来检测是否可以加载动态库。功能和dlopen一样
hook系统一些私有方法：vfork | fork | hook_popen（打开管道）
hook runtime
hook_dladdr dladdr可以用来获取方法或image对应的信息，比如所属的动态库的名称，这里hook如果是忽略的文件，则返回0，所以如果返回0，要再判断下是否数据真的是空的。
```
### 如何防止shadow等插件绕过
```
检测这些插件的关键指纹，比如检测只有他们有的类, 查看是否有异常类和异常的动态库的实现

阻止DYLD_INSERT_LIBRARIES生效, 阻止DYLD_INSERT_LIBRARIES生效 。（这个可以通过修改macho，重新打包来绕过）

使用objc_copyImageNames方法记录使用的所有动态库，做成白名单，在运行过程中，再运行objc_copyImageNames去查看当前的动态库是否一致
```

### CALayer响应点击事件
1. 是利用containsPoint
2. 是利用hitTest
```
import UIKit

class ViewController: UIViewController {

    let layerOne = CALayer()
    let layerTwo = CALayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellowColor()

        layerOne.frame = CGRectMake(100, 100, 50, 50)
        layerOne.backgroundColor = UIColor.redColor().CGColor
        view.layer.addSublayer(layerOne)

        layerTwo.frame = CGRectMake(100, 200, 50, 50)
        layerTwo.backgroundColor = UIColor.blueColor().CGColor
        view.layer.addSublayer(layerTwo)

    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {

        //方法一:运用containsPoint
        var p = (touches as NSSet).anyObject()?.locationInView(view)
        p = view.layer.convertPoint(p!, fromLayer: view.layer)

        if view.layer.containsPoint(p!) {

            let b = layerOne.convertPoint(p!, fromLayer: view.layer)
            if layerOne.containsPoint(b) {
                let alert = UIAlertView.init(title: "提示", message: "点击了红色按钮", delegate: nil, cancelButtonTitle: "取消")
                alert.show()
            }

           let a = layerTwo.convertPoint(p!, fromLayer: view.layer)
            if layerTwo.containsPoint(a) {
                let alert = UIAlertView.init(title: "提示", message: "点击了蓝色按钮", delegate: nil, cancelButtonTitle: "取消")
                alert.show()
            }
        }

//        //方法二：运用hitTest
//        let p = (touches as NSSet).anyObject()?.locationInView(view)
//        
//        let clickLayer = layerOne.hitTest(p!)
//        
//        if clickLayer == layerOne {
//            let alert = UIAlertView.init(title: "提示", message: "点击了红色按钮", delegate: nil, cancelButtonTitle: "取消")
//            alert.show()
//        }
//        
//        let anotherLayer = layerTwo.hitTest(p!)
//        
//        if anotherLayer == layerTwo {
//            let alert = UIAlertView.init(title: "提示", message: "点击了蓝色按钮", delegate: nil, cancelButtonTitle: "取消")
//            alert.show()
//        }

    }

}
```
## OpenGL

1、OpenGL
OpenGL (Open Graphics library) 是⼀一个跨编程语⾔、跨平台的编程图形程序接⼝，它将计算机的资源抽象称为一个个OpenGL的对象，对这些资源的操作抽象为一个个的OpenGL指令。


2、OpenGL ES
OpenGL ES (OpenGL for Embedded Systems) 是 OpenGL 三维图形 API 的子集，针对⼿机、 PDA和游戏主机等嵌入式设备而设计，去除了许多不必要和性能较低的API接口。


3、DirectX
DirectX 是由很多API组成的，DirectX并不是一个单纯的图形API. 最重要的是DirectX是属于 Windows上一个多媒体处理API.并不支持Windows以外的平台,所以不是跨平台框架. 按照性 质分类，可以分为四大部分，显示部分、声音部分、输⼊部分和网络部分。


4、Metal
Metal 是Apple为游戏开发者推出了新的平台技术 Metal，该技术能够为 3D 图 像提高 10 倍的渲染性能。Metal 是Apple为了解决3D渲染⽽而推出的框架。

其实苹果自14年推出Metal之后，就已经很明确的告诉大家，在极限性能方面，Metal的表现是要更加的出色的。因为他们对Metal做了很多针对性的优化，让他在iOS的设备上能有一个更完美的发挥。
这里也可以看出，Metal是可以取代OpenGL ES的。但是现在市场上面，依然还是OpenGL ES的使用率更高。所以OpenGL ES和Metal的关系就有点像是Objective-C和Swift的关系一样。

二、OpenGL专业名词解析

1、OpenGL上下文（Context）

在应用程序调用任何OpenGL指令之前，需要安排首先创建一个OpenGL的上下文。这个上下文是一个非常庞大的状态机，保存了OpenGL中的各种状态，这也是OpenGL指令执行的基础。

其实这里的上下文，我们可以类比一下JSContext，我在之前的一篇讲JSCore的博客里面讲到过这个东西。我们在操作任何的对象的时候，都需要通过上下文去拿到对象，同时上下文里面也记录了很多的我们需要使用的信息。

OpenGL的函数不管在哪个语言中，都是类似C语言一样的面向过程的函数，本质上面都是对OpenGL上下文这个庞大的状态机中的某个状态或者对象进行操作。当然你得首先把这个对象设置为当前对象。因此，通过对OpenGL指令的封装，是可以将OpenGL的相关调用封装成为一个面向对象的图形API的。

由于OpenGL上下文是一个巨大的状态机，切换上下文往往会产生较大的开销。但是不同的绘制模块，可能需要使用完全独立的状态管理。因此，可以在应用程序中分别创建多个不同的上下文，在不同的线程中使用不同的上下文，上下文之间共享纹理、缓冲区等资源。这样的方案，会比反复切换上下文，或者大量修改渲染状态，更加合理高效的。

2、OpenGL状态机

状态机理论上是一种机器，其实我们可以这样去理解，状态机描述了一个对象在其生命周期中所经历的各种状态，状态之间的转变，发生转变的动因，条件以及转变中所执行的活动。这一点上来说，跟JSContext也可以类比一下。我们的任何行为都是依赖着状态机的，状态机会记录所有的行为，那么我们在需要使用某一个行为的时候，也是可以通过状态机去拿出来某一个行为。所以状态机也是一种行为，说明对象在其生命周期中相应事件所经历的状态序列以及对那些状态事件的相应。


因此具有以下特点：


有记忆功能，能记住其当前的状态

可以接受输入，根据输入的内容和自己的原先状态，修改自己当前状态，并且可以有对应输出

当进入特殊状态（停机状态）的时候，便不再接收输入，停止工作。

3、渲染（Rendering）

这个好理解，就是将图形/图像数据转换成3D空间图像操作叫做渲染。例如，在图片或者视频进行解码之后，形成了一大堆的二进制文件，然后我们将这一堆的二进制文件显示到屏幕上面的过程就可以理解为渲染。


4、顶点数组（VertexArray）

那么什么是顶点呢？顶点就是指我们再绘制一个图形的时候，他的顶点的位置数据，这个数据是可以直接存储在数组中或者将其缓存在GPU内存中的。如果存储在数组中就构成了顶点数组。其实顶点数据就是我们在画画的时候，最开始画的一个大致的骨架。在OpenGL中的图像都是由图元组成。在OpenGL ES中，有三种图元：点、线、三角形。我们通过设定函数的指针，将顶点数据存储在内存中，然后需要绘制的时候，直接从内存中取出来使用。这一部分的数据其实就是顶点数组。


5、顶点缓冲区（VertexBuffer）

我们上面说了，我们在调用绘制方法的时候，直接就由内存传入顶点数据。还有一种更加高性能的方法，就是提前分配一快内存，将顶点数据预先传入到显存当中，这部分的显存，就叫做顶点缓冲区。值得注意的是，这一块空间不再内存中，而是在显存的一块空间中。


6、管线

因为我们的GPU在处理数据的时候，是通过一个固定的顺序来的，这个顺序不能被打破。类似一个流水线的形式，所以被称之为管线。


7、固定管线/存储着色器

在早期的OpenGL版本，它封装了很多着色器程序块内置的一段包含了光照、坐标变换、裁剪等等诸多功能的固定shader程序来完成，来帮助开发者来完成图形的渲染。而开发者只需要传入相应的参数，就能快速完成图形的渲染，类似于iOS开发会封装很多的API。而我们只需要调用，就可以实现功能，不需要关注底层实现原理

但是犹豫OpenGL的使用场景非常丰富，固定管线或存储着色器无法完成每一个业务，这是将相关部分开放成可编程。

8、着色器程序Shader

就全面的将固定渲染管线架构变为了可编程渲染管线。因此，OpenGL在实际调⽤绘制函数之前，还需要指定一个由shader编译成的着色器程序。常见的着色器主要有顶点着⾊器(VertexShader)，⽚段着⾊器 (FragmentShader)/像素着⾊器(PixelShader)/片元着色器，⼏何着⾊器 (GeometryShader)，曲⾯细分着⾊器(TessellationShader)。⽚段着⾊器和像素着⾊器只是在OpenGL和DX中的不同叫法⽽而已。可惜的是，直到 OpenGLES 3.0，依然只支持了顶点着⾊器和片段着⾊器这两个最基础的着⾊器。

OpenGL在处理shader时，和其他编译器一样。通过编译、链接等步骤，⽣成了着⾊器程序(glProgram)，着⾊器程序同时包含了顶点着⾊器和⽚段着⾊器的运算逻辑。在OpenGL进行绘制的时候，⾸先由顶点着⾊器对传⼊的顶点数据进行运算。再通过图元装配，将顶点转换为图元。然后进行光栅化，将图元这种矢量图形，转换为栅格化数据。最后，将栅格化数据传入⽚段着⾊器中进行运算。⽚段着⾊器会对栅格化数据中的每一个像素进行运算，并决定像素的颜⾊。

9、顶点着色器VertexShader

一般用来处理图形每个顶点变换[旋转/平移/投影等]

顶点着色器是OpenGL中用于计算顶点属性的程序。顶点着色器是逐个顶点运算的程序，也就是说每个顶点数据都会执行一次顶点着色器，当然这是并行的，并且顶点着色器运算过程中无法访问其他顶点的数据

一般来说典型的需要计算的顶点属性包括顶点坐标变换、逐个顶点光照运算等等。顶点坐标由自身坐标系转换到归一化做标记的运算，就是在这里发生的。

10、片元着色器 FragmentShader

一般用来处理图形中每个像素点颜色计算和填充

片段着色器是OpenGL中用于计算片段（像素）颜色的程序。片段着色器是逐个像素运算的程序，也就是说每个像素都会执行一次片段着色器，当然也是并行的。

11、GLSL（OpenGL Shading language)

OpenGL着色语言（OpenGL Shading language)是用来在OpenGl中着色编程的语言，类似于C语言。他们是在图形卡的GPU（Graphic Proccessor Unit图形处理单元）上执行的。代替了固定的渲染管线的一部分，使渲染管线中不同层次具有可编程性。比如：视图转换、投影转换等。GLSL的着色器代码分成两个部分：顶点着色器和片段着色器

12、光栅化Rasterization

是把顶点数据转换成片元的过程，具有将图转化成为一个个栅格组成的图像的作用。特点是每个元素对应帧缓冲区中的一个像素。

光栅化就是把顶点数据转换为片元的过程。片元中的每一个元素对应于帧缓冲区中的一个像素

光栅化其实是一种将几何图元变为二维图像的过程。该过程包含了两部分的工作。第一部分工作：决定了窗口坐标中哪些整型格栅区域被基本图元占用。第二部分工作：分配一个颜色值和一个深度值到各个区域。光栅化过程产生的是片元。

把物体的数学描述以及与物体相关的颜色信息转换为屏幕上用于对应位置的像素及⽤于填充像素的颜色，这个过程称为光栅化，这是一个将模拟信号转化为离散信号的过程

13、纹理

纹理可以理解为一个图片，也就是位图。⼤家在渲染图形时需要在其编码填充图⽚,为了使得场景更加逼真.⽽这里使⽤的图片,就是常说的纹理.但是在OpenGL,我们更加习惯叫纹理,⽽不是图片。


14、混合（Blending）

在测试阶段之后，如果像素依然没有被剔除，那么像素的颜色将会和帧缓冲区中颜色附着上的颜色进行混合，混合的算法可以通过OpenGL的函数进行指定。但是OpenGL提供的混合算法是有限的，如果需要更加复杂的混合 算法，⼀般可以通过像素着⾊器进行实现，当然性能会比原生的混合算法差一些。


15、变换矩阵(Transformation)

例如图形想发生平移,缩放,旋转变换。就需要使用变换矩阵。


16、投影矩阵（Projection）

⽤于将3D坐标转换为二维屏幕坐标,实际线条也将在二维坐标下进行绘制。


17、渲染上屏/交换缓冲区(SwapBuffer)

当我们想把一个图像渲染到窗口的时候，GPU会开辟一个渲染缓冲区。但是每一个窗口又只有一个缓冲区，那么如果在绘制的过程中屏幕进行了刷新，窗口显示的画面就有可能不完整。为了解决这个问题，常规的OpenGL程序至少都会有两个缓冲区。显示在屏幕上的称为屏幕缓冲区，没有显示的称为离屏缓冲区，在一个缓冲区渲染完成之后，通过将屏幕缓冲区和离屏缓冲区交换，实现图像在屏幕上的显示。在iOS中经常遇到的离屏渲染，其实就是双缓冲区的机制引起的。如果这方面有疑问的，可以移步iOS 保持界面流畅的技巧去了解。
使用了双缓冲区和垂直同步技术之后，由于总是要等待缓冲区交换之后再进行下一帧的渲染，使得帧率无法完全达到硬件允许的最高水平。为了解决这个问题，引入了三缓冲区技术，在等待垂直同步时，来回交替渲染两个离屏的缓冲区，而垂直同步发生时，屏幕缓冲区和最近渲染完成的离屏缓冲区交换，实现充分利用硬件性能的目的。

## FFmpeg
FFmpeg是一套可以用来记录、转换数字音频、视频，并能将其转化为流的开源计算机程序。
采用LGPL或GPL许可证。它提供了录制、转换以及流化音视频的完整解决方案，包括了领先的音、视频编码库libavcodec等。
```
libavformat：用于各种音视频封装格式的生成和解析；
libavcodec： 用于各种类型声音、图像编解码；
libavutil：  包含一些公共的工具函数；
libswscale： 用于视频场景比例缩放、色彩映射转换；
libpostproc：用于后期效果处理；
ffmpeg：     该项目提供的一个工具，可用于格式转换、解码或电视卡即时编码等；
ffsever：    一个 HTTP 多媒体即时广播串流服务器；
ffplay：     是一个简单的播放器，使用ffmpeg 库解析和解码，通过SDL显示；
```

1. 下载 https://github.com/kewlbear/FFmpeg-iOS-build-script
2. cd 路径 打开终端 $  sh build-ffmpeg.sh
步骤2执行完成后运行sh build-ffmpeg.sh lipo将.a文件合并成一个；
步骤3执行完成将FFmpeg-iOS文件夹拖到目标工程并添加libz.dylib、libbz2.dylib、libiconv.dylib三个库，xcode7 及以上则是添加libz.tbd、libbz2.tbd、libiconv.tbd，
并添加框架VideoToolbox.framework（此框架是 iOS8 新增的，用于硬解码）

设置头文件路径$(PROJECT_DIR)/$(PRODUCT_NAME)/FFmpeg-iOS/include：
OC 工程在调用的时候直接#include "avformat.h"；
swift 工程创建桥接头文件，在头文件内添加#import "avformat.h"

objc
0. 静态变量和全局变量区别
作用域的区别

1. 日常使用的修饰属性的关键字都有哪些？作用分别是什么？
2. 属性的实质是什么？
3. 深拷贝和浅拷贝，`NSString` 为什么要用 `copy` 修饰，换成 `strong` 会有什么问题？`NSMutableString` 可以用 `copy` 修饰吗？会有什么问题吗？
使用 NSMutableString 肯定是想用字符串的可变这个属性，但如果你用 copy 去修饰，那么生成的将会是不可变的，当你去调用可变方法时，程序将会崩溃！

4. 说一下 `static` 关键字
5. 什么情况下会引发循环引用？怎么解决？
6. `include` 和 `import` 作用是什么？它们有什么区别？

7. 介绍一下 `KVC` 和 `KVO` 及其实现原理
KVO - Key-Value-Observing 键值观察是基于KVC实现的一种观察者机制，提供了观察对象的某一个属性变化的监听方法。
KVO利用runtime的机制，当对一个对象进行观察时，会在运行时创建一个该对象的子类，这个子类一般以NSKVONotifying_xxx（xxx为父类的名字）命名，子类中会重写所有被观察属性的set方法，除了创建子类，还会将该对象的isa指针指向这个子类，当被观察的对象属性修改时，通过isa找到子类，在通过子类的方法列表找到对应的set方法，set方法是被重写过得，里面实现了相关的通知。

8. 介绍一下 OC 的消息传递机制
9. 介绍一下 OC 的消息转发机制
10. OC 支持多继承吗？如何实现 OC 的多继承？
11. OC 支持方法重载吗？
12. `CALayer` 有哪三种树？
layer tree  分为 model layer tree(模型图层树) 、presentation layer tree（表示图层树） 、render layer tree（渲染图层树）
模型图层树 中的对象是应用程序与之交互的对象。此树中的对象是存储任何动画的目标值的模型对象。每当更改图层的属性时，都使用其中一个对象。
modelLayer

表示图层树 中的对象包含任何正在运行的动画的飞行中值。层树对象包含动画的目标值，而表示树中的对象反映屏幕上显示的当前值。您永远不应该修改此树中的对象。相反，您可以使用这些对象来读取当前动画值，也许是为了从这些值开始创建新动画。
presentationLayer

渲染图层树 中的对象执行实际动画，并且是Core Animation的私有动画。使用不上

 self.layer = self.layer.modelLayer 、self.layer != self.layer.presentationLayer。 
 ### layer本身就是一个modelLayer，只不过它拥有presentationLayer。
 
 Core Animation动画执行的时间取决于当前事务的设置，动画类型取决于图层行为。


13. 什么是隐式动画？如何关闭隐式动画？ CATransaction
任何Layer的animatable属性的设置都应该属于某个CA事务(CATransaction),事务的作用是为了保证多个animatable属性的变化同时进行,不管是同一个layer还是不同的layer之间的.CATransaction也分两类,显式的和隐式的,当在某次RunLoop中设置一个animatable属性的时候,如果发现当前没有事务,则会自动创建一个CA事务,在线程的下个RunLoop开始时自动commit这个事务,如果在没有RunLoop的地方设置layer的animatable属性,则必须使用显式的事务.

事务：包含一系列属性动画集合的机制，用指定事务去改变可以做动画的图层属性不会立刻发生变化，而是当事务一旦提交的时候开始用一个动画过渡到新值.
事务 通过CATransaction类来做管理，CATransaction可以用加号方法+begin和+commit分别来入栈或者出栈。并且遵循先进后出
任何可以做动画的图层属性都会被添加到栈顶的事务，你可以通过+setAnimationDuration:方法设置当前事务的动画时间，或者通过+animationDuration方法来获取值（默认0.25秒）。

显式事务的使用如下：
[CATransaction begin];

...  

[CATransaction commit];

事务可以嵌套.当事务嵌套时候,只有当最外层的事务commit了之后,整个动画才开始.

可以通过CATransaction来设置一个事务级别的动画属性,覆盖隐式动画的相关属性,比如覆盖隐式动画的duration,timingFunction.如果是显式动画没有设置duration或者timingFunction,那么CA事务设置的这些参数也会对这个显式动画起作用.
//关闭隐式动画
CATransaction 在 Core Animation framework中主要扮演了“整体舞台设定的角色”。

使用 CATransaction 的方式就是把我们想做的特别的设定的动画代码，用 CATransaction 的class method前后包起来。

比方说，我们现在不希望产生动画，便可以这样写：
[CATransaction begin];
[CATransaction setDisableActions:YES];
//原本动画的代码
[CATransaction commit];

如果我们想要改变动画时间：

[CATransaction begin];
[CATransaction setAnimationDuration:1.0];
    
14. 介绍一下 `block` 及其实现原理
15. 如何在`block` 内部修改外部变量？
16. `block` 种类有哪些？ `block`  为什么要用 `copy` 修饰？
17. `autoReleasePool` 的原理是什么？
18. `ARC` 和 `MRC` 的区别是什么？
19. 介绍一下引用计数。一个对象什么时候其引用计数才会变为 0?
20. 主线程和子线程的区别？为什么刷新 UI 要放到主线程？
21. 介绍一下多线程。实现多线程有哪几种方式？
22. 介绍一下 `runtime` 机制。`runtime` 在日常开发中都有哪些用途？
23. 介绍一下 `runloop`。日常开发中怎么使用的？
24. `cell` 的复用机制及原理，如何自己设计一个 `cell` 复用池？
25. `UITableView` 如何优化？优化的 9 个建议
26. 如何扩大一个按钮的点击区域？
27. `OC` 的 `category` 和 `extension` 的区别
28. 如何设计一下网络库？
29. 介绍一下 `MVC` 、`MVVM` 和 MVP， 以及它们之间的区别
30. 介绍一下 OC 中的类簇
31. `CoreAnimation` 在渲染过程中做了什么？
32. 说一下线程和 `runloop` 的关系
33. 日常开发中用到过哪些三方库？有看过三方库的源码吗？一些知名的三方库实现原理。
34. 手写一个单例
35. `Hybrid` 与原生交互原理（过程）
36. 卡顿监控方案
37. 如何解决在使用 `NSTimer` 或 `CADisplayLink` 过程中的内存泄漏问题？
38. 做过组件化吗？组件化的方案有哪几种？
39. 原子锁和非原子锁 （atomic 和 nonatomic）
40. 日常中用到的锁有哪些？
41. iOS 中内省的几个方法？class方法和objc_getClass方法有什么区别?
42. [self class] 与 [super class] 分别打印出来什么？如何获取当前类的父类？
43. self.name = object 与 _name = object 之间有何区别？在对象的 init 方法中赋值时应该使用上述二者中的哪一种及原因？
44. 如何判断两个对象是否相等？
45. weak 的实现原理
46. load 和 initialize 方法的区别及它们之间的加载顺序
47. 介绍一下 `OC` 的响应链
48. `category` 加载时机及加载顺序
49. `WKWebbiew` 白屏问题
50. 数据持久化的方案都有哪些（数据库是重点）
51. KVO，Notification, delegate 的优缺点，效率及使用场景
52. 如何监控一个页面持有的对象是否有内存泄漏问题？
53. 有看过 `OC` 底层源码？介绍一下你熟悉的

swift
0. `swift` 相比 `OC` 有什么优点？
1. `swift` 的语言有哪些特点？
2. 介绍一下函数式编程
3. `swift` 为什么不支持静态库？
4. `swift` 的 `extension` 和 `category` 的区别？ 以及它们与 `OC` 的区别？
5. `swift` 有哪些新的语言特性？
6. 介绍一下 `swift` 的泛型

计算机
0. 说一下`三次握手`和`四次挥手`
1. 说一下 `TCP` 和 `UDP` 的区别？
2. 说一下 `HTTP` 和 `HTTPs` 的区别？
3. `SSL/TSL` 的过程是怎样的？
4. 网络都分为哪几层？作用分别是什么？
5. 常见的 `HTTP` 状态值及释义
6. 什么是 `socket` 编程？什么是 `websocket`?什么是心跳？
7. 说一下 `HTTP` 的请求报文和响应报文的格式
8. 简述 https 协议是如何保证客户端与服务器之间进行安全通信的？为了保证通信不被窃听，客户端应该朋采取什么措施？
9. `GET` 与 `POST` 方法区别？
10. `HTTP` 常用的请求头都有哪些？

0. `iOS` 在 `pre-main` 阶段都做了些什么
1. 编译的过程是怎样的？
2. `clang` 接触过吗？介绍一下 `clang`
3. `OC` 的 `pre-main` 阶段都做了哪些事情？
4. 链接的过程都做了哪些事情？
5. `OC` 的内存区块都有哪些？

0. 算法时间复杂度是指什么？
1. `B` 树，`B+` 树，`B*` 树的区别是什么？什么是红黑树？
2. `C` 语言中都有哪些数据结构？
3. hash 表是怎样实现的？
4. 使用递归判断回文。如 level 就是一个回文
5. 反转链表
6. 判断镜像二叉树
7. 求一个二叉树的度
8. 快速排序，冒泡排序，插入排序
9. `LRU` 算法
10. 两个栈实现一个队列

0. `23` 种设计模式熟悉一下
1. 设计模式有哪 `6` 大设计原则？
2. 简单工厂模式，工厂模式，抽象工厂模式
3. 中介者模式
4. 外观模式
5. 观察者模式

1、说一下OC的反射机制；
系统Foundation框架为我们提供了一些方法反射的API，我们可以通过这些API执行将字符串转为SEL等操作。由于OC语言的动态性，这些操作都是发生在运行时的。
```
// SEL和字符串转换
FOUNDATION_EXPORT NSString *NSStringFromSelector(SEL aSelector);
FOUNDATION_EXPORT SEL NSSelectorFromString(NSString *aSelectorName);
// Class和字符串转换
FOUNDATION_EXPORT NSString *NSStringFromClass(Class aClass);
FOUNDATION_EXPORT Class __nullable NSClassFromString(NSString *aClassName);
// Protocol和字符串转换
FOUNDATION_EXPORT NSString *NSStringFromProtocol(Protocol *proto) NS_AVAILABLE(10_5, 2_0);
FOUNDATION_EXPORT Protocol * __nullable NSProtocolFromString(NSString *namestr) NS_AVAILABLE(10_5, 2_0);
```
2、block的实质是什么？有几种block？分别是怎样产生的？
实质也是OC对象 因为具有isa指针
根据isa指针，block一共有3种类型的block
_NSConcreteGlobalBlock 
全局静态_NSConcreteStackBlock 保存在栈中，出函数作用域就销毁
_NSConcreteMallocBlock 保存在堆中，retainCount == 0销毁


3、__block修饰的变量为什么能在block里面能改变其值？
加了__block, 并不是直接传递对象的值了，而是把对象的地址传过去了，所以在block内部便可以修改到外面的变量了。

4、说一下线程之间的通信。(多线程几种方式)
- (void)performSelectorOnMainThread:(SEL)aSelector withObject:(id)arg waitUntilDone:(BOOL)wait;
- (void)performSelector:(SEL)aSelector onThread:(NSThread *)thr withObject:(id)arg waitUntilDone:(BOOL)wait;
GCD/NSThread/NSOperation

5、应用的崩溃？
存在CPU无法运行的代码
不存在或者无法执行
操作系统执行某项策略，终止程序
启动时间过长或者消耗过多内存时，操作系统会终止程序运行
编程语言为了避免错误终止程序：抛出异常
开发者为了避免失败终止程序：Assert

符号化
app.xcarchive文件，包内容包含dSYM和应用的二进制文件。
更精确的符号化，可以结合崩溃日志、项目二进制文件、dSYM文件，对其进行反汇编，从而获得更详细的信息

6、说一下hash算法
MD5加密
哈希（Hash）算法，即散列函数。它是一种单向密码体制，即它是一个从明文到密文的不可逆的映射，只有加密过程，没有解密过程。同时，哈希函数可以将任意长度的输入经过变化以后得到固定长度的输出。哈希函数的这种单向特征和输出数据长度固定的特征使得它可以生成消息或者数据。

7、NSDictionary的实现原理是什么？
在OC中NSDictionary是使用hash表来实现key和value的映射和存储的。
哈希表（hash表）： 又叫做散列表，是根据关键码值（key value）而直接访问的 数据结构 。也就是说它通过关键码值映射到表中一个位置来访问记录，以加快查找的速度。这个映射叫做 函数 ，存放记录的 数组 叫做 哈希表 。
OC中的字典其实是一个数组，数组中每一个元素同样为一个链表实现的数组，也就是数组中套数组。

那么对应在oc中字典是如何进行存储的呢？

在oc中每一个对象创建时，都默认生成一个hashCode,也就是经过hash算法生成的一串数字，当利用key去取字典中的value时，若是使用遍历或者二分查找等方法，效率相对较低，于是出现了根据每一个key生成的hashCode将键值对放到hasCode对应的数组中的指定位置，这样当用key去取值时，便不必遍历去获取，既可以根据hashCode直接取出。因为hashCode的值过大，或许经过取余获取一个较小的数字，假如是对999进行取余运算，那么得到的结果始终处于0-999之间。但是，这样做的弊端在于取余所得到的值，可能是相同的，这样可能导致完全不相干的键值对被新的键值对（取余后值key相等）所覆盖，于是出现了数组中套链表实现的数组。这样，key值取余得到值相等的键值对，都将保存在同一个链表数组中，当查找key对应的值时，首先获取到该链表数组，然后遍历数组，取正确的key所对应的值即可。

8、你们的App是如何处理本地数据安全的（比如用户名的密码）？
Keychain是iOS所提供的一种安全存储参数的方式，最常用来存储账号，密码，用户信息，银行卡资料等信息，Keychain会以加密的方式存储在设备中

9、遇到过BAD_ACCESS的错误吗？你是怎样调试的？
向一个已经释放的对象发送消息 野指针

僵尸对象在许多情况下解决这个问题。通过保留已释放的对象，Xcode可以告诉你你试图访问哪个对象，这使的查找问题原因容易得多
选中Edit Scheme。在左侧选中Run ，在上方打开 Diagnostics选项。要启用僵尸对象，勾选 Zombie Objects选框。

10、什么是指针常量和常量指针？
“常量指针是指--指向常量的指针,顾名思义,就是指针指向的是常量,即,它不能指向变量,它指向的内容不能被改变,不能通过指针来修改它指向的内容,但是指针自身不是常量,它自身的值可以改变,从而可以指向另一个常量。 
指针常量是指--指针本身是常量

11、不借用第三个变量，如何交换两个变量的值？要求手动写出交换过程。
a = a + b;
b = a - b; // b = (a +b)-b,即 b = a
a = a - b; // a = (a+b)-a


12、若你去设计一个通知中心，你会怎样设计？

13、如何去设计一个方案去应对后端频繁更改的字段接口？



14、KVO、KVC的实现原理
一个对象的属性被观察时系统动态创建了一个子类，并且改变了原有对象的isa指针指向，指向动态创建的子类，子类中重写了被观察属性的set方法，在使用点方法和set方法给属性赋值时，最终调用的是子类中的set方法。

15、用递归算法求1到n的和
int add100(int n) {
    //定义函数f 出口为n等于1，否则将n与f(n-1)相加
    if(n == 1) {//出口
        return(1);
    }else{//递归公式
        return(f(n-1) + n);
    }
}



16、category为什么不能添加属性？
在分类里使用@property声明属性，只是将该属性添加到该类的属性列表，但是没有生成相应的成员变量，也没有实现setter和getter方法。


17、说一下runloop和线程的关系。
线程和 RunLoop 之间是一一对应的，其关系是保存在一个全局的 Dictionary 里。
线程刚创建时并没有 RunLoop，如果你不主动获取，那它一直都不会有。
RunLoop 的创建是发生在第一次获取时，RunLoop 的销毁是发生在线程结束时。
你只能在一个线程的内部获取其 RunLoop（主线程除外）。



18、说一下autoreleasePool的实现原理。
一个线程的autoreleasepool就是一个指针栈。
栈中存放的指针指向加入需要release的对象或者POOL_SENTINEL（哨兵对象，用于分隔autoreleasepool）。
栈中指向POOL_SENTINEL的指针就是autoreleasepool的一个标记。
当autoreleasepool进行出栈操作，每一个比这个哨兵对象后进栈的对象都会release。
这个栈是由一个以page为节点双向链表组成，page根据需求进行增减。
autoreleasepool对应的线程存储了指向最新page（也就是最新添加autorelease对象的page）的指针。



19、说一下简单工厂模式，工厂模式以及抽象工厂模式？
20、如何设计一个网络请求库？
21、说一下多线程，你平常是怎么用的？


22、说一下UITableViewCell的卡顿你是怎么优化的？
1.提前计算并缓存好高度，因为heightForRow最频繁的调用。

2.异步绘制，遇到复杂界面，性能瓶颈时，可能是突破口。

3.滑动时按需加载，这个在大量图片展示，网络加载时，很管用。（SDWebImage已经实现异步加载）。

4.重用cells。

5.如果cell内显示得内容来自web，使用异步加载，缓存结果请求。

6.少用或不用透明图层，使用不透明视图。

7.尽量使所有的view opaque，包括cell本身。

8.减少subViews

9.少用addView给cell动态添加view，可以初始化的时候就添加，然后通过hide控制是否显示。


23、看过哪些三方库？说一下实现原理以及好在哪里？
24、说一下HTTP协议以及经常使用的code码的含义。
404 403 500 502


25、设计一套缓存策略。
26、设计一个检测主线和卡顿的方案。


27、说一下runtime，工作是如何使用的？看过runtime源码吗？
struct isa指针 

28、说几个你在工作中使用到的线程安全的例子
@property (atomic, strong)
@synchronized(token)
NSLock
dispatch_semaphore_t

29、用过哪些锁？哪些锁的性能比较高？
多线程编程时，没有锁的情况 == 线程不安全。
递归锁/@synchronized/os_unfair_lock:(互斥锁)/条件锁NSCondition/dispatch_semaphore

30、说一下HTTP和HTTPs的请求过程？

31、说一下TCP和UDP
UDP 与 TCP 的主要区别在于 UDP 不一定提供可靠的数据传输。

1、TCP面向连接（如打电话要先拨号建立连接）;UDP是无连接的，即发送数据之前不需要建立连接

2、TCP提供可靠的服务。也就是说，通过TCP连接传送的数据，无差错，不丢失，不重复，且按序到达;UDP尽最大努力交付，即不保证可靠交付

3、TCP面向字节流，实际上是TCP把数据看成一连串无结构的字节流;UDP是面向报文的UDP没有拥塞控制，因此网络出现拥塞不会使源主机的发送速率降低（对实时应用很有用，如IP电话，实时视频会议等）

4、每一条TCP连接只能是点到点的;UDP支持一对一，一对多，多对一和多对多的交互通信

5、TCP首部开销20字节;UDP的首部开销小，只有8个字节6、TCP的逻辑通信信道是全双工的可靠信道，UDP则是不可靠信道



32、说一下静态库和动态库之间的区别
 静态库: 静态库是在编译时,完整的拷贝至可执行文件中,被多次使用就有多次冗余拷贝;
 动态库: 程序运行时由系统动态加载到内存,而不是复制,供程序调用。系统只加载一次,多个程序共用,节省内存
 静态库：以.a 和 .framework为文件后缀名。

动态库：以.tbd(之前叫.dylib) 和 .framework 为文件后缀名。（系统直接提供给我们的framework都是动态库！）

理解：.a 是一个纯二进制文件，.framework 中除了有二进制文件之外还有资源文件。 .a ，要有 .h 文件以及资源文件配合， .framework 文件可以直接使用。总的来说，.a + .h + sourceFile = .framework。所以创建静态库最好还是用.framework的形式


 
33、load和initialize方法分别在什么时候调用的？
load和initialize方法都会在实例化对象之前调用，以main函数为分水岭，load在main函数之前调用，后者在之后调用。这两个方法会被自动调用，不能手动调用它们。

load和initialize方法都不用显示的调用父类的方法而是自动调用，即使子类没有initialize方法也会调用父类的方法，而load方法则不会调用父类。

load方法通常用来进行Method Swizzle，initialize方法一般用于初始化全局变量或静态变量。

load和initialize方法内部使用了锁，因此它们是线程安全的。实现时要尽可能保持简单，避免阻塞线程，不要再使用锁。


34、NSNotificationCenter是在哪个线程发送的通知？
NSNotificationCenter通知中心是同步操作
接收通知和发送通知时所在线程一致，和监听时所在线程无关。

35、用过swift吗？如果没有，平常有学习吗？
class struct

36、说一下你对架构的理解？
MVVM

37、为什么一定要在主线程里面更新UI？
  a. UIKit并不是一个 线程安全 的类，UI操作涉及到渲染访问各种View对象的属性，如果异步操作下会存在读写问题，而为其加锁则会耗费大量资源并拖慢运行速度。
  b. 整个程序的起点UIApplication是在主线程进行初始化，所有的用户事件都是在主线程上进行传递（如点击、拖动），所以view只能在主线程上才能对事件进行响应。
  c. 渲染方面由于图像的渲染需要以60帧的刷新率在屏幕上同时更新，在非主线程异步化的情况下无法确定这个处理过程能够实现同步更新。

# iOS动画
1. CoreGraphics：

它是iOS的核心图形库，平时使用最频繁的point，size，rect等，都定义在这个框架中，类名以CG开头的都属于CoreGraphics框架，它提供的都是C语言的函数接口，是可以在iOS和macOS通用的。

2. QuartzCore：(CoreAnimation)

这个框架的名称感觉不是很清晰，不明确，但是看它的头文件可以发现，它其实就是CoreAnimation，这个框架的头文件只包含了CoreAnimation.h  类名以CA开头

CABasicAnimation的属性
属性	       说明
duration	动画的时长
repeatCount	重复的次数
repeatDuration	设置动画的时间，在改时间内一直执行，不计算次数
beginTime	指定动画开始时间
timingFunction	设置动画的速度变化
autoreverses	动画结束是否执行逆动画
fromValue	属性的起始值
toValue	结束的值
byValue	改变属性相同起始值的改变量

Keypath常用的属性：

Keypath	                 说明	   使用
transform.scale	        比例转化    @(cgfloat)
transform.scale.x	宽的比例	@(cgfloat)
transform.scale.y	高的比例	@(cgfloat)
transform.rotation.x	围绕x轴旋转	@(M_PI)
transform.rotation.y	围绕y轴旋转	@(M_PI)
transform.rotation.z	围绕z轴旋转	@(M_PI)
cornerRadius	        圆角的设置	@(50)
backgroundColor	        背景颜色的变化	(id)[uicolor redcolor].cgcolor
bounds	                大小，中心不变	[nsvalue valuewithcgrect:]
position	        位置(中心点的改变)	[nsvalue valuewithcgpoint]
contents	        内容(比如图片)	(id)image.cgimage
opacity             	透明度	@(cgfloat)
contentsRect.size.width	横向拉伸缩放(需要设置contents)	@(cgfloat)

CAKeyframeAnimation设置动画的路径分为两种

设置path
设置一组的values

CAAnimationGroup动画组
将多个动画合并到一起的动画就是CAAnimationGroup动画组

CATransition转场动画
CATransition是CAAnimation的子类，用于过渡动画或转场动画。为视图层移入移除屏幕提供转场动画

## Lua 脚本
```
     Lua 是一种轻量小巧的脚本语言，用标准C语言编写并以源代码形式开放，
     其设计目的是为了嵌入应用程序中，从而为应用程序提供灵活的扩展和定制功能。
     
     Lua的应用场景：

     游戏开发
     独立应用脚本
     Web 应用脚本
     扩展和数据库插件如：MySQL Proxy 和 MySQL
     WorkBench
     安全系统，如入侵检测系统


     触动精灵的应用场景：

     编写自己App的脚本完成自动化测试
     开挂刷机
     微信机器人（包括开发任意应用的机器人）
     因此我们可以轻易做出上面效果图的功能，但是需要移动设备必须是以下其一：

     (Root权限)越狱的iOS设备
     Root权限的Android设备
     具有Root权限的Android模拟器
     提醒：Android与iOS兼容大部分函数。
     模拟器连接编辑器比较麻烦，具体操作请查看官方文档。推荐使用天天模拟器，具有别的模拟器不具备的特性。
     
     
     开发所需的必备工具：

     具备windows/Mac环境开发(lua安装)
     在移动设备上安装触动精灵App
     IDE 脚本编辑器TouchSprite Studio
     取点抓色器TSColorPicker
```

## Mach-O 的组成结构

---- Header 包含该二进制文件的一般信息

            字节顺序、架构类型、加载指令的数量等。

---- Load commands 一张包含很多内容的表

                   内容包括区域的位置、符号表、动态符号表等。

---- __Data/__TEXT 包含Segement / Section

```
在工程编译时 , 所产生的 Mach-O 可执行文件中会预留出一段空间 , 
这个空间其实就是符号表 , 存放在 _DATA 数据段中  ( 因为 _DATA 段在运行时是可读可写的 ) 

编译时 : 工程中所有引用了共享缓存区中的系统库方法 , 其指向的地址设置成符号地址 ,  
( 例如工程中有一个 NSLog , 那么编译时就会在 Mach-O 中创建一个 NSLog 的符号 , 工程中的 NSLog 就指向这个符号 ) 

运行时 : 当 dyld将应用进程加载到内存中时 , 根据 load commands 中列出的需要加载哪些库文件 , 去做绑定的操作 
( 以 NSLog 为例 , dyld 就会去找到 Foundation 中 NSLog 的真实地址写到 _DATA 段的符号表中 NSLog 的符号上面 )
```
                   
## hook iOS App
### 1. 利用代码注入
1. .framework
下载yololib
将其复制到 usr/local/bin 中 
手动 cd 到Mach-O 文件这个目录(eg. XLsn0w.framework)
```
yololib Wechat Frameworks/XLsn0w.framework/XLsn0w
```

2. .dylib (eg. XLsn0w.dylib)
```
yololib "$TARGET_APP_PATH/$APP_BINARY" "Frameworks/XLsn0w.dylib"
```

### 2. 汇编修改Mach-O
修改 Mach-O 文件的 Load Commands

## Shell (.sh脚本)
```
# ${SRCROOT} 它是工程文件所在的目录
TEMP_PATH="${SRCROOT}/Temp"
#资源文件夹，我们提前在工程目录下新建一个APP文件夹，里面放ipa包
ASSETS_PATH="${SRCROOT}/APP"
#目标ipa包路径
TARGET_IPA_PATH="${ASSETS_PATH}/*.ipa"
#清空Temp文件夹
rm -rf "${SRCROOT}/Temp"
mkdir -p "${SRCROOT}/Temp"



#----------------------------------------
# 1. 解压IPA到Temp下
unzip -oqq "$TARGET_IPA_PATH" -d "$TEMP_PATH"
# 拿到解压的临时的APP的路径
TEMP_APP_PATH=$(set -- "$TEMP_PATH/Payload/"*.app;echo "$1")
# echo "路径是:$TEMP_APP_PATH"


#----------------------------------------
# 2. 将解压出来的.app拷贝进入工程下
# BUILT_PRODUCTS_DIR 工程生成的APP包的路径
# TARGET_NAME target名称
TARGET_APP_PATH="$BUILT_PRODUCTS_DIR/$TARGET_NAME.app"
echo "app路径:$TARGET_APP_PATH"

rm -rf "$TARGET_APP_PATH"
mkdir -p "$TARGET_APP_PATH"
cp -rf "$TEMP_APP_PATH/" "$TARGET_APP_PATH"



#----------------------------------------
# 3. 删除extension和WatchAPP.个人证书没法签名Extention
rm -rf "$TARGET_APP_PATH/PlugIns"
rm -rf "$TARGET_APP_PATH/Watch"



#----------------------------------------
# 4. 更新info.plist文件 CFBundleIdentifier
#  设置:"Set : KEY Value" "目标文件路径"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $PRODUCT_BUNDLE_IDENTIFIER" "$TARGET_APP_PATH/Info.plist"


#----------------------------------------
# 5. 给MachO文件上执行权限
# 拿到MachO文件的路径WeChat
APP_BINARY=`plutil -convert xml1 -o - $TARGET_APP_PATH/Info.plist|grep -A1 Exec|tail -n1|cut -f2 -d\>|cut -f1 -d\<`
#上可执行权限
chmod +x "$TARGET_APP_PATH/$APP_BINARY"



#----------------------------------------
# 6. 重签名第三方 FrameWorks
TARGET_APP_FRAMEWORKS_PATH="$TARGET_APP_PATH/Frameworks"
if [ -d "$TARGET_APP_FRAMEWORKS_PATH" ];
then
for FRAMEWORK in "$TARGET_APP_FRAMEWORKS_PATH/"*
do


#签名
/usr/bin/codesign --force --sign "$EXPANDED_CODE_SIGN_IDENTITY" "$FRAMEWORK"
done
fi

```

## Tagged Pointer

1️⃣ : Tagged Pointer 专门用来存储小的对象，例如 NSNumber 和 NSDate

2️⃣ : Tagged Pointer 指针的值不再是地址了，而是真正的值。所以，实际上它不再是一个对象了，它只是一个披着对象皮的普通变量而已。所以，它的内存并不存储在堆中，也不需要 malloc 和 free

3️⃣ :  在内存读取上有着 3 倍的效率，创建时比以前快 106 倍 ( objc_msgSend 能识别 Tagged Pointer，比如 NSNumber 的 intValue 方法，直接从指针提取数据 )

4️⃣ : 使用 Tagged Pointer 后，指针内存储的数据变成了 Tag + Data，也就是将数据直接存储在了指针中 .

## lldb po
p 是 expr -的缩写。它的工作是把接收到的参数在当前环境下进行编译，然后打印出对应的值。

po 即 expr -o-。它所做的操作与p相同。如果接收到的参数是一个指针，那么它会调用对象的 description 方法并打印。如果接收到的参数是一个 core foundation 对象，那么它会调用 CFShow 方法并打印。如果这两个方法都调用失败，那么 po 打印出和 p 相同的内容。

总的来说，po 相对于 p 会打印出更多内容。一般在工作中，用 p 即可，因为 p 操作较少，效率更高。

p即是print，也是expression --的缩写，与po不同，它不会打出对象的详细信息，只会打印出一个$符号，数字，再加上一段地址信息。由于po命令下，对象的description 有可能被随便乱改，没有输出地址消息。

$符号在LLDB中代表着变量的分配。每次使用p后，会自动为你分配一个变量，后面再次想使用这个变量时，就可以直接使用。我们可以直接使用这个地址做一些转换，获取对象的信息

## 什么是 dyld?

dyld 是苹果的动态加载器 , 用来加载 image ( 注意: 这里的 image 不是指图片 , 而是 Mach-O 格式的二进制文件  )

当程序启动时 , 系统内核会首先加载 dyld , 而 dyld 会将我们的 APP 所依赖的各种库加载到内存中 ,
其中就包括 libobjc ( OC 和 runtime ) , 这些工作是在 APP 的 main 函数执行之前完成的.

_objc_init 是 Object-C - runtime 库的入口函数 , 在这里主要是读取 Mach-O 文件 OC 对应的 Segment section , 
并根据其中的数据代码信息 , 完成为 OC 的内存布局 , 以及初始化 runtime 相关的数据结构.

## dpkg-deb
```
1、dpkg-deb -x ./original.deb ./repackage
2、得到头文件class-dump -H original.app -o ./header
 
但如果对其逆向，修改后，要重新打包，则步骤如下：
1、建立文件夹目录
./repackage/DEBIAN
 
2、拆包
dpkg-deb -x ./original.deb ./repackage
执行之后，目录结构为：
./repackage/DEBIAN
./repackage/Applications
./repackage/Library
./repackage/usr
 
3、得到原deb信息
dpkg-deb -e ./original.deb repackage/DEBIAN
在DEBIAN目录下会得到包含control等5个文件
 
4、打包
dpkg-deb -b repackage new.deb

```

## dpkg

安装deb -i == -install
```
$ dpkg -i cn.xlsn0w.deb
```

卸载deb -r == -remove
```
$ dpkg -r cn.xlsn0w.deb
```

查看deb信息 -s == -see
```
$ dpkg -s cn.xlsn0w.deb 
```

## iOS大神金字塔
1.OC基础、UI层：熟练掌握各种组件的业务开发

2.runloop、runtime层：熟练掌握OC实现原理，定位各种异常问题

3.源码层：OC底层源码、比如objc、GNUStep 等源码，从底层原理上分析问题，解决问题

4.汇编层：熟悉OC在机器码层面实现，例如寄存器、汇编、Mach-O等

5.系统层：学习Drawin系统、BSD等

6.知识面的拓宽：Android、flutter、swift、shell、ruby、脚本等

7.硬件层：比如说集成电路、操作系统如何运转等等

## usbmuxd
usbmuxd将依赖于TCP/IP的命令的被连接方，通过本地端口映射。

用usb连接代替了网络连接，使得在没有网络的情况下也可以连接设备。

$  iproxy 2222 22 == 将本地电脑2222端口转发到usb连接设备22端口

### Makefile
```
DEBUG = false

THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222

ARCHS = arm64 arm64e

TARGET = iphone:latest:11.0

THEOS_MAKE_PATH = /opt/theos/makefiles

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = XLsn0wTweak

XLsn0wTweak_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"

```

1.设备安装openSSH插件, 安装usbmuxd(brew install usbmuxd)
2.把当前连接设备的22端口(SSH端口)映射到电脑的2222端口:(iproxy 2222 22)
3.theos想和设备22端口通信，直接和本地的2222端口通信即可
```
iproxy 2222 22 
```

### ssh连接设备IP==连接电脑本地localhost 127.0.0.1
```
ssh -p 2222 root@127.0.0.1

ssh root@localhost -p 22222
```

## dpkg -r packageName 卸载deb插件
1. ssh连接手机(ssh -p 2222 root@127.0.0.1)
2. 使用dpkg -r packageName (packageName是创建Tweak项目时输入的包名)
3. 注销SpringBoard 

```
iPhone-6:~ root# dpkg -r cn.xlsn0w.dock:iphoneos-arm
(Reading database ... 1896 files and directories currently installed.)
Removing cn.xlsn0w.dock (1.1.6-2) ...
```

### 执行make install命令安装deb插件
```
$     make install
==> Installing…
The authenticity of host '[localhost]:2222 ([127.0.0.1]:2222)' can't be established.
RSA key fingerprint is SHA256:9BPzMfuq0HFe2lkxXBRpdZSwg+if/NSbn1m2+7RudqM.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '[localhost]:2222' (RSA) to the list of known hosts.
Selecting previously unselected package cn.xlsn0w.dock.
(Reading database ... 3893 files and directories currently installed.)
Preparing to unpack /tmp/_theos_install.deb ...
Unpacking cn.xlsn0w.dock (1.1.5-4) ...
Setting up cn.xlsn0w.dock (1.1.5-4) ...
install.exec "killall -9 SpringBoard"
```
![iPod touch4](https://github.com/XLsn0w/Cydia/blob/master/iOS%206.1.6%20jailbreak.JPG?raw=true)

## .app手动压缩改后缀.ipa
```
1: 新建“Payload”文件夹;
2: 将.app包放到Payload中;
3: 在Payload文件夹上右键压缩成zip，然后将生成的.zip文件后缀改成.ipa即可
```

## macOS/iOS 签名工具
```
$ brew install ldid
```
 ### ldid工具：ldid是mac上的命令行工具，可以用于导出的签名文件、对文件进行重签名等操作。
 ### codesign工具：Mac上的命令行工具、也可以用于权限签名操作。

### dlopen 和 dlsym 方法动态加载库和调用函数
### Linux/unix/macOS/iOS 提供了使用 dlopen 和 dlsym 方法动态加载库和调用函数

UNIX 诞生于 20 世纪 60 年代末，
Windows 诞生于 20 世纪 80 年代中期，
Linux 诞生于 20 世纪 90 年代初，
可以说 UNIX 是操作系统中的"老大哥", Windows 和 Linux 都参考了 UNIX。

dlopen 打开一个库，获取句柄。
dlsym 在打开的库中查找符号的值。
dlclose 关闭句柄。
dlerror 返回一个描述最后一次调用dlopen、dlsym，或 dlclose 的错误信息的字符串。

## Makefile
Makefile关系到了整个工程的编译规则。一个工程中的源文件不计数，其按类型、功能、模块分别放在若干个目录中，
Makefile定义了一系列的规则来指定，哪些文件需要先编译，哪些文件需要后编译，哪些文件需要重新编译，甚至于进行更复杂的功能操作，
因为makefile就像一个Shell脚本一样，其中也可以执行操作系统的命令。

makefile带来的好处就是——“自动化编译”，一旦写好，只需要一个make命令，整个工程完全自动编译，极大的提高了软件开发的效率。
make是一个命令工具，是一个解释makefile中指令的命令工具，一般来说，大多数的IDE都有这个命令，比如：Delphi的make，Visual C++的nmake，Linux下GNU的make。
可见，makefile都成为了一种在工程方面的编译方法。

## 绕过越狱检测
最近，苹果自己的App Store中有相当数量的应用程序正在实施一些程序，以检查运行该应用程序本身的设备的真实性，从而禁止或禁止某些功能甚至是整个应用程序的使用。
显而易见的原因是越狱的先天安全风险您的设备（例如，银行公司不希望将某些流氓键盘记录程序伪装成对您的帐户信息的调整来伪装）。

但是，在大多数情况下，公司似乎担心调整可能会绕过应用程序中实施的某些限制。视频流应用为此而臭名昭著。这些公司不希望用户绕过对何时何地可以流式传输其内容的限制，
因此，他们没有做负责任的事情并混淆了他们的限制尝试，而是阻止了所有越狱设备，无论它们是否出于恶意或缺乏意图。

## Kernel Syscalls -> https://www.theiphonewiki.com/wiki/Kernel_Syscalls
```
像往常一样，Args进入其普通寄存器，如R0 / X0中的arg1。Syscall＃输入IP（即过程内的，而不是指令指针！），也称为R12 / X16。

像在所有ARM中一样（在Android中也是如此），内核条目是由SVC命令（某些调试器和ARM方言中的SWI）完成的。在内核端，作为ExceptionVectorsBase的一部分安装了一个低级CPU异常处理程序（fleh_swi），并且-在发出SWI / SVC时-控件被转移到该地址。该处理程序可以检查系统调用号，以区分POSIX调用（非否定）和Mach陷阱（否定）。

Args go in their normal registers, like arg1 in R0/X0, as usual. Syscall # goes in IP (that's intra-procedural, not instruction pointer!), a.k.a R12/X16.

As in all ARM (i.e. also on Android) the kernel entry is accomplished by the SVC command (SWI in some debuggers and ARM dialects). On the kernel end, a low level CPU exception handler (fleh_swi) is installed as part of the ExceptionVectorsBase, and - upon issuing a SWI/SVC - control is transferred to that address. This handler can check the syscall number to distinguish between POSIX calls (non negative) and Mach traps (negative).

Unix
Usage
MOV IP, #x // number from following list into Intraprocedural, a.k.a. r12 on arm32 and x16 on arm64
SVC 0x80   // Formerly, SWI (software interrupt)
For example, arm32:


(gdb) disass chown
0x30d2ad54 <chown>:	mov	r12, #16	       ; 0x10, being # of chown
0x30d2ad58 <chown+4>:	svc	0x00000080
And arm64:

libsystem_kernel.dylib`chown:
    0x1866c6084 <+0>:  mov    x16, #0x10
    0x1866c6088 <+4>:  svc    #0x80
Most of these are the same as you would find in the XNU open source kernel, with ARM idiosyncrasies aside (and #372, ledger)

XNU中的系统调用表被称为“ sysent”，出于明显的原因（例如syscall挂钩），它不再是公共符号。但是，找到系统及其调用非常简单。尽管i0nic提出了一种基于导出的kdebug符号查找系统的启发式方法，但这是不可靠的，因为该符号不再被导出。更好的方法是进入struct sysent条目本身的模式，即-如bsd / sys / sysent.h中所定义：
sysent
The system call table in XNU is known as "sysent", and is no longer a public symbol, for obvious reasons (e.g. syscall hooking). It is fairly straightforward, however, to find the sysent and its calls. While i0nic proposes a heuristic of finding the sysent based on the exported kdebug symbol, this is unreliable, as the symbol is no longer exported. A better way is to home in on the pattern of the struct sysent entries itself, i.e - as defined in bsd/sys/sysent.h:


struct sysent {         /* system call table */
        int16_t         sy_narg;        /* number of args */
        int8_t          sy_resv;        /* reserved  */
        int8_t          sy_flags;       /* flags */
        sy_call_t       *sy_call;       /* implementing function */
        sy_munge_t      *sy_arg_munge32; /* system call arguments munger for 32-bit process */
        sy_munge_t      *sy_arg_munge64; /* system call arguments munger for 64-bit process */
        int32_t         sy_return_type; /* system call return types */
        uint16_t        sy_arg_bytes;   /* Total size of arguments in bytes for
                                         * 32-bit system calls
                                         */
};

Because system calls arguments are set in stone, it is straightforward to write code to find the signature of the first few syscalls (syscall, exit, fork..), and from there calculate the other sysent entries. A program to do so reliable on iOS has, in fact, been written, and produces the following output for iOS 6.0b1:

List of system calls from iOS 6.0 GM
note: Even though a syscall is present in the table, it does not in any way imply it is functional. Auditing, for example, is not enabled in iOS (no CONFIG_AUDIT in the XNU build). Most of these syscalls are the same as those of OS X, with the exception of ledger (which actually makes a comeback in OS X Mountain Lion), and 434+ (CONFIG_EMBEDDED).

A good reference on these can be found at Wiley's OS X and iOS Internals online appendix. The joker tool (shown below) can be downloaded from the same site.

$ joker -u ~/Documents/projects/iOS.6.0.iPod4.kernel 
This is an ARM binary. Applying iOS kernel signatures
Entry point is 0x80085084....This appears to be XNU 2107.2.33
Syscall names are @2a70f0
Sysent offset in file/memory (for patching purposes): 0x2ef0c0/0x802f00c0

Suppressing enosys (0x800b3429)  T = Thumb
1. exit                  801d4a74 T
2. fork                  801d7980 T
3. read                  801eb584 T
4. write                 801eb958 T
5. open                  800b13a4 T
6. close                 801ccab4 T
7. wait4                 801d56bc T
9. link                  800b18e8 T
10. unlink               800b1ff0 T
12. chdir                800b0c60 T
13. fchdir               800b0af0 T
14. mknod                800b14bc T
15. chmod                800b2b40 T
16. chown                800b2c9c T
18. getfsstat            800b088c T
20. getpid               801dc20c T
23. setuid               801dc4c0 T
24. getuid               801dc290 T
25. geteuid              801dc2a0 T
26. ptrace               801e812c T
27. recvmsg              8020a8fc T
28. sendmsg              8020a444 T
29. recvfrom             8020a528 T
30. accept               80209dfc T
31. getpeername          8020abc8 T
32. getsockname          8020ab18 T
33. access               800b24ac T
34. chflags              800b2928 T
35. fchflags             800b29f0 T
36. sync                 800b0320 T
37. kill                 801dfdcc T
39. getppid              801dc214 T
41. dup                  801cab04 T
42. pipe                 801edbe4 T
43. getegid              801dc318 T
46. sigaction            801deee8 T
47. getgid               801dc308 T
48. sigprocmask          801df42c T
49. getlogin             801dd0e8 T
50. setlogin             801dd160 T
51. acct                 801c54ec T
52. sigpending           801df5d0 T
53. sigaltstack          801dfd10 T
54. ioctl                801ebd1c T
55. reboot               801e8090 T
56. revoke               800b43f8 T
57. symlink              800b1b58 T
58. readlink             800b282c T
59. execve               801d4448 T
60. umask                800b43d0 T
61. chroot               800b0d30 T
65. msync                801d84d0 T
66. vfork                801d7018 T
73. munmap               801d857c T
74. mprotect             801d85b0 T
75. madvise              801d8668 T
78. mincore              801d86d4 T
79. getgroups            801dc328 T
80. setgroups            801dd02c T
81. getpgrp              801dc21c T
82. setpgid              801dc3c8 T
83. setitimer            801e7b78 T
85. swapon               8021be68 T
86. getitimer            801e7a30 T
89. getdtablesize        801ca6dc T
90. dup2                 801caf54 T
92. fcntl                801cb420 T
93. select               801ebfc8 T
95. fsync                800b3238 T
96. setpriority          801dd494 T
97. socket               802098a4 T
98. connect              80209e1c T
100. getpriority          801dd388 T
104. bind                 80209970 T
105. setsockopt           8020aa30 T
106. listen               80209adc T
 111. sigsuspend           801df5f8 T
116. gettimeofday         801e7840 T
117. getrusage            801de22c T
118. getsockopt           8020aa94 T
120. readv                801eb810 T
121. writev               801ebbb0 T
122. settimeofday         801e789c T
123. fchown               800b2dac T
124. fchmod               800b2c70 T
126. setreuid             801dc80c T
127. setregid             801dcba0 T
128. rename               800b3428 T
131. flock                801ce20c T
132. mkfifo               800b1798 T
133. sendto               8020a168 T
134. shutdown             8020aa00 T
135. socketpair           8020a00c T
136. mkdir                800b3d1c T
137. rmdir                800b3d5c T
138. utimes               800b2e60 T
139. futimes              800b3034 T
140. adjtime              801e79a0 T
142. gethostuuid          801ed6a4 T
147. setsid               801dc384 T
151. getpgid              801dc224 T
152. setprivexec          801dc1f4 T
153. pread                801eb774 T
154. pwrite               801ebad0 T
157. statfs               800b03c0 T
158. fstatfs              800b0678 T
159. unmount              800afe88 T
165. quotactl             800b03bc T
167. mount                800af068 T
169. csops                801dafd0 T
170. 170  old table       801db4bc T
173. waitid               801d5ab4 T
180. kdebug_trace         801c2db4 T
181. setgid               801dc9a4 T
182. setegid              801dcab0 T
183. seteuid              801dc710 T
184. sigreturn            8021e7e4 T
185. chud                 8021d4f4 T
187. fdatasync            800b32b0 T
188. stat                 800b2588 T
189. fstat                801ccfec T
190. lstat                800b26d4 T
191. pathconf             800b27c8 T
192. fpathconf            801cd048 T
194. getrlimit            801de074 T
195. setrlimit            801dd93c T
196. getdirentries        800b3f94 T
197. mmap                 801d7fc0 T
199. lseek                800b2068 T
200. truncate             800b30b4 T
201. ftruncate            800b3174 T
202. __sysctl             801e2478 T
203. mlock                801d8820 T
204. munlock              801d8878 T
205. undelete             800b1cf0 T
216. mkcomplex            800b12c4 T
220. getattrlist          8009b060 T
221. setattrlist          8009b0d8 T
222. getdirentriesattr    800b44e0 T
223. exchangedata         800b469c T
225. searchfs             800b48dc T
226. delete               800b202c T
227. copyfile             800b32cc T
228. fgetattrlist         80098488 T
229. fsetattrlist         8009b7e0 T
230. poll                 801ec72c T
231. watchevent           801ed054 T
232. waitevent            801ed1f8 T
233. modwatch             801ed368 T
234. getxattr             800b5550 T
235. fgetxattr            800b568c T
236. setxattr             800b578c T
237. fsetxattr            800b5898 T
238. removexattr          800b5994 T
239. fremovexattr         800b5a5c T
240. listxattr            800b5b1c T
241. flistxattr           800b5c00 T
242. fsctl                800b4dd4 T
243. initgroups           801dcea8 T
244. posix_spawn          801d351c T
245. ffsctl               800b5474 T
250. minherit             801d8630 T
266. shm_open             8020eb24 T
267. shm_unlink           8020f604 T
268. sem_open             8020df80 T
269. sem_close            8020e718 T
270. sem_unlink           8020e4e0 T
271. sem_wait             8020e76c T
272. sem_trywait          8020e834 T
273. sem_post             8020e8d8 T
274. sem_getvalue         8020e97c T
275. sem_init             8020e974 T
276. sem_destroy          8020e978 T
277. open_extended        800b11d8 T
278. umask_extended       800b4380 T
279. stat_extended        800b2530 T
280. lstat_extended       800b267c T
281. fstat_extended       801ccdd0 T
282. chmod_extended       800b2a30 T
283. fchmod_extended      800b2b74 T
284. access_extended      800b21a0 T
285. settid               801dcd2c T
286. gettid               801dc2b0 T
287. setsgroups           801dd03c T
288. getsgroups           801dc37c T
289. setwgroups           801dd040 T
290. getwgroups           801dc380 T
291. mkfifo_extended      800b16f4 T
292. mkdir_extended       800b3b30 T
294. shared_region_check_np 8021c3a4 T
296. vm_pressure_monitor  8021cb08 T
297. psynch_rw_longrdlock 802159ac T
298. psynch_rw_yieldwrlock 80215c60 T
299. psynch_rw_downgrade  80215c68 T
300. psynch_rw_upgrade    80215c64 T
301. psynch_mutexwait     80212bd8 T
302. psynch_mutexdrop     80213b9c T
303. psynch_cvbroad       80213bf0 T
304. psynch_cvsignal      802141c0 T
305. psynch_cvwait        80214648 T
306. psynch_rw_rdlock     80214d7c T
307. psynch_rw_wrlock     802159b0 T
308. psynch_rw_unlock     80215c6c T
309. psynch_rw_unlock2    80215f64 T
310. getsid               801dc254 T
311. settid_with_pid      801dcdcc T
312. psynch_cvclrprepost  80214c7c T
313. aio_fsync            801c5ed0 T
314. aio_return           801c60a8 T
315. aio_suspend          801c6330 T
316. aio_cancel           801c5a48 T
317. aio_error            801c5e24 T
318. aio_read             801c6088 T
319. aio_write            801c6544 T
320. lio_listio           801c6564 T
322. iopolicysys          801de420 T
323. process_policy       8021a72c T
324. mlockall             801d88b4 T
325. munlockall           801d88b8 T
327. issetugid            801dc4b0 T
328. __pthread_kill       801dfa44 T
329. __pthread_sigmask    801dfaa4 T
330. __sigwait            801dfb54 T
331. __disable_threadsignal 801df720 T
332. __pthread_markcancel 801df73c T
333. __pthread_canceled   801df784 T
334. __semwait_signal     801df924 T
336. proc_info            80218618 T
338. stat64               800b25d4 T
339. fstat64              801cd028 T
340. lstat64              800b2720 T
341. stat64_extended      800b2624 T
342. lstat64_extended     800b2770 T
343. fstat64_extended     801cd00c T
344. getdirentries64      800b4340 T
345. statfs64             800b06e0 T
346. fstatfs64            800b0828 T
347. getfsstat64          800b0a38 T
348. __pthread_chdir      800b0d28 T
349. __pthread_fchdir     800b0c58 T
350. audit                801c1a74 T
351. auditon              801c1a78 T
353. getauid              801c1a7c T
354. setauid              801c1a80 T
357. getaudit_addr        801c1a84 T
358. setaudit_addr        801c1a88 T
359. auditctl             801c1a8c T
360. bsdthread_create     80216ab8 T
361. bsdthread_terminate  80216d30 T
362. kqueue               801cf594 T
363. kevent               801cf614 T
364. lchown               800b2d94 T
365. stack_snapshot       801c520c T
366. bsdthread_register   80216d94 T
367. workq_open           802179e8 T
368. workq_kernreturn     80217e50 T
369. kevent64             801cf8ac T
370. __old_semwait_signal 801df7f8 T
371. __old_semwait_signal_nocancel 801df82c T
372. thread_selfid        80218354 T
373. ledger               801ed70c T
380. __mac_execve         801d4468 T
381. __mac_syscall        8027d0a8 T
382. __mac_get_file       8027cd50 T
383. __mac_set_file       8027cf98 T
384. __mac_get_link       8027ce74 T
385. __mac_set_link       8027d098 T
386. __mac_get_proc       8027c844 T
387. __mac_set_proc       8027c904 T
388. __mac_get_fd         8027cbfc T
389. __mac_set_fd         8027ce84 T
390. __mac_get_pid        8027c778 T
391. __mac_get_lcid       8027c9b8 T
392. __mac_get_lctx       8027ca7c T
393. __mac_set_lctx       8027cb38 T
394. setlcid              801dd228 T
395. getlcid              801dd310 T
396. read_nocancel        801eb5a4 T
397. write_nocancel       801eb978 T
398. open_nocancel        800b1434 T
399. close_nocancel       801ccad0 T
400. wait4_nocancel       801d56dc T
401. recvmsg_nocancel     8020a91c T
402. sendmsg_nocancel     8020a464 T
403. recvfrom_nocancel    8020a548 T
404. accept_nocancel      80209b1c T
405. msync_nocancel       801d84e8 T
406. fcntl_nocancel       801cb440 T
407. select_nocancel      801ebfe4 T
408. fsync_nocancel       800b32a8 T
409. connect_nocancel     80209e34 T
410. sigsuspend_nocancel  801df6b4 T
411. readv_nocancel       801eb830 T
412. writev_nocancel      801ebbd0 T
413. sendto_nocancel      8020a188 T
414. pread_nocancel       801eb794 T
415. pwrite_nocancel      801ebaf0 T
416. waitid_nocancel      801d5ad0 T
417. poll_nocancel        801ec74c T
420. sem_wait_nocancel    8020e788 T
421. aio_suspend_nocancel 801c6350 T
422. __sigwait_nocancel   801dfb8c T
423. __semwait_signal_nocancel 801df958 T
424. __mac_mount          800af08c T
425. __mac_get_mount      8027d2a0 T
426. __mac_getfsstat      800b08b0 T
427. fsgetpath            800b5ce4 T
428. audit_session_self   801c1a68 T
429. audit_session_join   801c1a6c T
430. fileport_makeport    801ce2f0 T
431. fileport_makefd      801ce494 T
432. audit_session_port   801c1a70 T
433. pid_suspend          8021c180 T
434. pid_resume           8021c1f0 T
435. pid_hibernate        8021c268 T
436. pid_shutdown_sockets 8021c2c0 T
438. shared_region_map_and_slide_np 8021c954 T
439. kas_info             8021cb50 T   ; Provides ASLR information to user space 
                                       ; (intentionally crippled in iOS, works in ML)
440. memorystatus_control 801e62a0 T   ;; Controls JetSam - supersedes old sysctl interface
441. guarded_open_np      801cead0 T  
442. guarded_close_np     801cebdc T

Mach
XNU also supports the Mach personality, which is distinct from that of the UNIX syscalls discussed above. Mach syscalls (on 32-bit systems like iOS) are encoded as negative numbers, which is clever, since POSIX system calls are all non-negative. For example, consider mach_msg_trap:

_mach_msg_trap:
0001a8b4        e1a0c00d        mov     ip, sp
0001a8b8        e92d0170        push    {r4, r5, r6, r8}
0001a8bc        e89c0070        ldm     ip, {r4, r5, r6}
0001a8c0        e3e0c01e        mvn     ip, #30 @ 0x1e    ; Move NEGATIVE -30 into IP (R12)
0001a8c4        ef000080        svc     0x00000080        ; issue a supervisor call
0001a8c8        e8bd0170        pop     {r4, r5, r6, r8}
0001a8cc        e12fff1e        bx      lr
..
_semaphore_signal_all_trap:
0001a8f8        e3e0c021        mvn     ip, #33 @ 0x21   ; NEGATIVE -33 into IP (R12)
0001a8fc        ef000080        svc     0x00000080
0001a900        e12fff1e        bx      lr

Mach system calls are commonly known as "traps", and are maintained in a Mach Trap table. iOS's fleh_swi handler (the kernel entry point on the other side of the "SWI" or "SVC" command) checks the system call number - if it is negative, it is flipped (2's complement), and interpreted as Mach trap instead.

mach_trap_table
In iOS 5.x, the mach_trap_table is not far from the page_size export, and right next to the trap names. kern_invalid is the equivalent of ENOSYS. All the traps are ARM Thumb. The joker binary can be used to find the Mach trap table, as well. The following shows iOS 6.0.b1's table:

$ ./joker -ls mach kernel.iPod4.iOS6.0b1
This is an ARM binary. Applying iOS kernel signatures
mach_trap_table offset in file (for patching purposes): 3064992 (0x2ec4a0)
Kern invalid should be 0x80027ec1. Ignoring those
..This appears to be XNU 2107.1.78
 10 _kernelrpc_mach_vm_allocate_trap         80014460 T
 12 _kernelrpc_mach_vm_deallocate_trap       800144cc T
 14 _kernelrpc_mach_vm_protect_trap          80014510 T
 16 _kernelrpc_mach_port_allocate_trap       80014564 T
 17 _kernelrpc_mach_port_destroy_trap        800145b4 T
 18 _kernelrpc_mach_port_deallocate_trap     800145f0 T
 19 _kernelrpc_mach_port_mod_refs_trap       8001462c T
 20 _kernelrpc_mach_port_move_member_trap    8001466c T
 21 _kernelrpc_mach_port_insert_right_trap   800146b0 T
 22 _kernelrpc_mach_port_insert_member_trap  80014710 T
 23 _kernelrpc_mach_port_extract_member_trap 80014754 T
 26 mach_reply_port                          8001b5b4 T
 27 thread_self_trap                         8001b598 T
 28 task_self_trap                           8001b578 T
 29 host_self_trap                           80019910 T
 31 mach_msg_trap                            80014ec0 T
 32 mach_msg_overwrite_trap                  80014d20 T
 33 semaphore_signal_trap                    80027188 T
 34 semaphore_signal_all_trap                8002720c T
 35 semaphore_signal_thread_trap             80027114 T
 36 semaphore_wait_trap                      800274b0 T
 37 semaphore_wait_signal_trap               80027658 T
 38 semaphore_timedwait_trap                 80027598 T
 39 semaphore_timedwait_signal_trap          8002773c T
 44 task_name_for_pid                        8021a838 T
 45 task_for_pid                             8021a688 T
 46 pid_for_task                             8021a63c T
 48 macx_swapon                              8021b414 T
 49 macx_swapoff                             8021b668 T
 51 macx_triggers                            8021b3f4 T
 52 macx_backing_store_suspend               8021b370 T
 53 macx_backing_store_recovery              8021b318 T
 58 pfz_exit                                 80027818 T
 59 swtch_pri                                800278e4 T
 60 swtch                                    8002781c T
 61 thread_switch                            80027ad4 T
 62 clock_sleep_trap                         80017520 T
 89 mach_timebase_info_trap                  80016658 T
 90 mach_wait_until_trap                     80016d20 T
 91 mk_timer_create_trap                     8001f2f4 T
 92 mk_timer_destroy_trap                    8001f500 T
 93 mk_timer_arm_trap                        8001f544 T
 94 mk_timer_cancel_trap                     8001f5c8 T
100 iokit_user_client_trap                   8026c11c T
```
## Apple提供的System Call Table 可以查出函数的编号
```

1. exit                  801d4a74 T
2. fork                  801d7980 T
3. read                  801eb584 T
4. write                 801eb958 T
5. open                  800b13a4 T
6. close                 801ccab4 T
7. wait4                 801d56bc T
9. link                  800b18e8 T
10. unlink               800b1ff0 T
12. chdir                800b0c60 T
13. fchdir               800b0af0 T
14. mknod                800b14bc T
15. chmod                800b2b40 T
16. chown                800b2c9c T
18. getfsstat            800b088c T
20. getpid               801dc20c T
23. setuid               801dc4c0 T
24. getuid               801dc290 T
25. geteuid              801dc2a0 T
26. ptrace               801e812c T
27. recvmsg              8020a8fc T
28. sendmsg              8020a444 T
29. recvfrom             8020a528 T
30. accept               80209dfc T
31. getpeername          8020abc8 T
32. getsockname          8020ab18 T
33. access               800b24ac T
34. chflags              800b2928 T
35. fchflags             800b29f0 T
36. sync                 800b0320 T
37. kill                 801dfdcc T
39. getppid              801dc214 T
41. dup                  801cab04 T
42. pipe                 801edbe4 T
43. getegid              801dc318 T
46. sigaction            801deee8 T
47. getgid               801dc308 T
48. sigprocmask          801df42c T
49. getlogin             801dd0e8 T
50. setlogin             801dd160 T
51. acct                 801c54ec T
52. sigpending           801df5d0 T
53. sigaltstack          801dfd10 T
54. ioctl                801ebd1c T
55. reboot               801e8090 T
56. revoke               800b43f8 T
57. symlink              800b1b58 T
58. readlink             800b282c T
59. execve               801d4448 T
60. umask                800b43d0 T
61. chroot               800b0d30 T
65. msync                801d84d0 T
66. vfork                801d7018 T
73. munmap               801d857c T
74. mprotect             801d85b0 T
75. madvise              801d8668 T
78. mincore              801d86d4 T
79. getgroups            801dc328 T
80. setgroups            801dd02c T
81. getpgrp              801dc21c T
82. setpgid              801dc3c8 T
83. setitimer            801e7b78 T
85. swapon               8021be68 T
86. getitimer            801e7a30 T
89. getdtablesize        801ca6dc T
90. dup2                 801caf54 T
92. fcntl                801cb420 T
93. select               801ebfc8 T
95. fsync                800b3238 T
96. setpriority          801dd494 T
97. socket               802098a4 T
98. connect              80209e1c T
100. getpriority          801dd388 T
104. bind                 80209970 T
105. setsockopt           8020aa30 T
106. listen               80209adc T
 111. sigsuspend           801df5f8 T
116. gettimeofday         801e7840 T
117. getrusage            801de22c T
118. getsockopt           8020aa94 T
120. readv                801eb810 T
121. writev               801ebbb0 T
122. settimeofday         801e789c T
123. fchown               800b2dac T
124. fchmod               800b2c70 T
126. setreuid             801dc80c T
127. setregid             801dcba0 T
128. rename               800b3428 T
131. flock                801ce20c T
132. mkfifo               800b1798 T
133. sendto               8020a168 T
134. shutdown             8020aa00 T
135. socketpair           8020a00c T
136. mkdir                800b3d1c T
137. rmdir                800b3d5c T
138. utimes               800b2e60 T
139. futimes              800b3034 T
140. adjtime              801e79a0 T
142. gethostuuid          801ed6a4 T
147. setsid               801dc384 T
151. getpgid              801dc224 T
152. setprivexec          801dc1f4 T
153. pread                801eb774 T
154. pwrite               801ebad0 T
157. statfs               800b03c0 T
158. fstatfs              800b0678 T
159. unmount              800afe88 T
165. quotactl             800b03bc T
167. mount                800af068 T
169. csops                801dafd0 T
170. 170  old table       801db4bc T
173. waitid               801d5ab4 T
180. kdebug_trace         801c2db4 T
181. setgid               801dc9a4 T
182. setegid              801dcab0 T
183. seteuid              801dc710 T
184. sigreturn            8021e7e4 T
185. chud                 8021d4f4 T
187. fdatasync            800b32b0 T
188. stat                 800b2588 T
189. fstat                801ccfec T
190. lstat                800b26d4 T
191. pathconf             800b27c8 T
192. fpathconf            801cd048 T
194. getrlimit            801de074 T
195. setrlimit            801dd93c T
196. getdirentries        800b3f94 T
197. mmap                 801d7fc0 T
199. lseek                800b2068 T
200. truncate             800b30b4 T
201. ftruncate            800b3174 T
202. __sysctl             801e2478 T
203. mlock                801d8820 T
204. munlock              801d8878 T
205. undelete             800b1cf0 T
216. mkcomplex            800b12c4 T
220. getattrlist          8009b060 T
221. setattrlist          8009b0d8 T
222. getdirentriesattr    800b44e0 T
223. exchangedata         800b469c T
225. searchfs             800b48dc T
226. delete               800b202c T
227. copyfile             800b32cc T
228. fgetattrlist         80098488 T
229. fsetattrlist         8009b7e0 T
230. poll                 801ec72c T
231. watchevent           801ed054 T
232. waitevent            801ed1f8 T
233. modwatch             801ed368 T
234. getxattr             800b5550 T
235. fgetxattr            800b568c T
236. setxattr             800b578c T
237. fsetxattr            800b5898 T
238. removexattr          800b5994 T
239. fremovexattr         800b5a5c T
240. listxattr            800b5b1c T
241. flistxattr           800b5c00 T
242. fsctl                800b4dd4 T
243. initgroups           801dcea8 T
244. posix_spawn          801d351c T
245. ffsctl               800b5474 T
250. minherit             801d8630 T
266. shm_open             8020eb24 T
267. shm_unlink           8020f604 T
268. sem_open             8020df80 T
269. sem_close            8020e718 T
270. sem_unlink           8020e4e0 T
271. sem_wait             8020e76c T
272. sem_trywait          8020e834 T
273. sem_post             8020e8d8 T
274. sem_getvalue         8020e97c T
275. sem_init             8020e974 T
276. sem_destroy          8020e978 T
277. open_extended        800b11d8 T
278. umask_extended       800b4380 T
279. stat_extended        800b2530 T
280. lstat_extended       800b267c T
281. fstat_extended       801ccdd0 T
282. chmod_extended       800b2a30 T
283. fchmod_extended      800b2b74 T
284. access_extended      800b21a0 T
285. settid               801dcd2c T
286. gettid               801dc2b0 T
287. setsgroups           801dd03c T
288. getsgroups           801dc37c T
289. setwgroups           801dd040 T
290. getwgroups           801dc380 T
291. mkfifo_extended      800b16f4 T
292. mkdir_extended       800b3b30 T
294. shared_region_check_np 8021c3a4 T
296. vm_pressure_monitor  8021cb08 T
297. psynch_rw_longrdlock 802159ac T
298. psynch_rw_yieldwrlock 80215c60 T
299. psynch_rw_downgrade  80215c68 T
300. psynch_rw_upgrade    80215c64 T
301. psynch_mutexwait     80212bd8 T
302. psynch_mutexdrop     80213b9c T
303. psynch_cvbroad       80213bf0 T
304. psynch_cvsignal      802141c0 T
305. psynch_cvwait        80214648 T
306. psynch_rw_rdlock     80214d7c T
307. psynch_rw_wrlock     802159b0 T
308. psynch_rw_unlock     80215c6c T
309. psynch_rw_unlock2    80215f64 T
310. getsid               801dc254 T
311. settid_with_pid      801dcdcc T
312. psynch_cvclrprepost  80214c7c T
313. aio_fsync            801c5ed0 T
314. aio_return           801c60a8 T
315. aio_suspend          801c6330 T
316. aio_cancel           801c5a48 T
317. aio_error            801c5e24 T
318. aio_read             801c6088 T
319. aio_write            801c6544 T
320. lio_listio           801c6564 T
322. iopolicysys          801de420 T
323. process_policy       8021a72c T
324. mlockall             801d88b4 T
325. munlockall           801d88b8 T
327. issetugid            801dc4b0 T
328. __pthread_kill       801dfa44 T
329. __pthread_sigmask    801dfaa4 T
330. __sigwait            801dfb54 T
331. __disable_threadsignal 801df720 T
332. __pthread_markcancel 801df73c T
333. __pthread_canceled   801df784 T
334. __semwait_signal     801df924 T
336. proc_info            80218618 T
338. stat64               800b25d4 T
339. fstat64              801cd028 T
340. lstat64              800b2720 T
341. stat64_extended      800b2624 T
342. lstat64_extended     800b2770 T
343. fstat64_extended     801cd00c T
344. getdirentries64      800b4340 T
345. statfs64             800b06e0 T
346. fstatfs64            800b0828 T
347. getfsstat64          800b0a38 T
348. __pthread_chdir      800b0d28 T
349. __pthread_fchdir     800b0c58 T
350. audit                801c1a74 T
351. auditon              801c1a78 T
353. getauid              801c1a7c T
354. setauid              801c1a80 T
357. getaudit_addr        801c1a84 T
358. setaudit_addr        801c1a88 T
359. auditctl             801c1a8c T
360. bsdthread_create     80216ab8 T
361. bsdthread_terminate  80216d30 T
362. kqueue               801cf594 T
363. kevent               801cf614 T
364. lchown               800b2d94 T
365. stack_snapshot       801c520c T
366. bsdthread_register   80216d94 T
367. workq_open           802179e8 T
368. workq_kernreturn     80217e50 T
369. kevent64             801cf8ac T
370. __old_semwait_signal 801df7f8 T
371. __old_semwait_signal_nocancel 801df82c T
372. thread_selfid        80218354 T
373. ledger               801ed70c T
380. __mac_execve         801d4468 T
381. __mac_syscall        8027d0a8 T
382. __mac_get_file       8027cd50 T
383. __mac_set_file       8027cf98 T
384. __mac_get_link       8027ce74 T
385. __mac_set_link       8027d098 T
386. __mac_get_proc       8027c844 T
387. __mac_set_proc       8027c904 T
388. __mac_get_fd         8027cbfc T
389. __mac_set_fd         8027ce84 T
390. __mac_get_pid        8027c778 T
391. __mac_get_lcid       8027c9b8 T
392. __mac_get_lctx       8027ca7c T
393. __mac_set_lctx       8027cb38 T
394. setlcid              801dd228 T
395. getlcid              801dd310 T
396. read_nocancel        801eb5a4 T
397. write_nocancel       801eb978 T
398. open_nocancel        800b1434 T
399. close_nocancel       801ccad0 T
400. wait4_nocancel       801d56dc T
401. recvmsg_nocancel     8020a91c T
402. sendmsg_nocancel     8020a464 T
403. recvfrom_nocancel    8020a548 T
404. accept_nocancel      80209b1c T
405. msync_nocancel       801d84e8 T
406. fcntl_nocancel       801cb440 T
407. select_nocancel      801ebfe4 T
408. fsync_nocancel       800b32a8 T
409. connect_nocancel     80209e34 T
410. sigsuspend_nocancel  801df6b4 T
411. readv_nocancel       801eb830 T
412. writev_nocancel      801ebbd0 T
413. sendto_nocancel      8020a188 T
414. pread_nocancel       801eb794 T
415. pwrite_nocancel      801ebaf0 T
416. waitid_nocancel      801d5ad0 T
417. poll_nocancel        801ec74c T
420. sem_wait_nocancel    8020e788 T
421. aio_suspend_nocancel 801c6350 T
422. __sigwait_nocancel   801dfb8c T
423. __semwait_signal_nocancel 801df958 T
424. __mac_mount          800af08c T
425. __mac_get_mount      8027d2a0 T
426. __mac_getfsstat      800b08b0 T
427. fsgetpath            800b5ce4 T
428. audit_session_self   801c1a68 T
429. audit_session_join   801c1a6c T
430. fileport_makeport    801ce2f0 T
431. fileport_makefd      801ce494 T
432. audit_session_port   801c1a70 T
433. pid_suspend          8021c180 T
434. pid_resume           8021c1f0 T
435. pid_hibernate        8021c268 T
436. pid_shutdown_sockets 8021c2c0 T
438. shared_region_map_and_slide_np 8021c954 T
439. kas_info             8021cb50 T   ; Provides ASLR information to user space 
                                       ; (intentionally crippled in iOS, works in ML)
440. memorystatus_control 801e62a0 T   ;; Controls JetSam - supersedes old sysctl interface
441. guarded_open_np      801cead0 T  
442. guarded_close_np     801cebdc T

```

## iPhoneIsJailbroken
```
#import "iPhoneIsJailbroken.h"
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <TargetConditionals.h>

@implementation iPhoneIsJailbroken

#define A(c)            (c) - 0x19
#define HIDE_STR(str)   do { char *p = str;  while (*p) *p++ -= 0x19; } while (0)
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

BOOL DEBUGGING = YES;

#if TARGET_IPHONE_SIMULATOR && !defined(LC_ENCRYPTION_INFO)
#define LC_ENCRYPTION_INFO 0x21
struct encryption_info_command {
    uint32_t cmd;
    uint32_t cmdsize;
    uint32_t cryptoff;
    uint32_t cryptsize;
    uint32_t cryptid;
};
#endif

void LOG(NSString* loc)
{
    NSLog(@"Found: %@", loc);
}

CFRunLoopSourceRef gSocketSource;
BOOL fileExist(NSString* path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if([fileManager fileExistsAtPath:path isDirectory:&isDirectory]){
        return YES;
    }
    return NO;
}

BOOL directoryExist(NSString* path)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if([fileManager fileExistsAtPath:path isDirectory:&isDirectory]){
        return YES;
    }
    return NO;
}

BOOL canOpen(NSString* path)
{
    FILE *file = fopen([path UTF8String], "r");
    if(file==nil){
        return fileExist(path) || directoryExist(path);
    }
    fclose(file);
    return YES;
}

// Preventing libobjc hooked, strstr implementation
const char* tuyul(const char* X, const char* Y)
{
    if (*Y == '\0')
        return X;

    for (int i = 0; i < strlen(X); i++)
    {
        if (*(X + i) == *Y)
        {
            char* ptr = tuyul(X + i + 1, Y + 1);
            return (ptr) ? ptr - 1 : NULL;
        }
    }

    return NULL;
}

BOOL isJb()
{
//    Check cydia URL
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"cydia://package/com.avl.com"]])
    {
        return YES;
    }
    NSArray* checks = [[NSArray alloc]initWithObjects:@"/Application/Cydia.app",
                       @"/Library/MobileSubstrate/MobileSubstrate.dylib",
                       @"/bin/bash",
                       @"/usr/sbin/sshd",
                       @"/etc/apt",
                       @"/usr/bin/ssh",
                       @"/private/var/lib/apt",
                       @"/private/var/lib/cydia",
                       @"/private/var/tmp/cydia.log",
                       @"/Applications/WinterBoard.app",
                       @"/var/lib/cydia",
                       @"/private/etc/dpkg/origins/debian",
                       @"/bin.sh",
                       @"/private/etc/apt",
                       @"/etc/ssh/sshd_config",
                       @"/private/etc/ssh/sshd_config",
                       @"/Applications/SBSetttings.app",
                       @"/private/var/mobileLibrary/SBSettingsThemes/",
                       @"/private/var/stash",
                       @"/usr/libexec/sftp-server",
                       @"/usr/libexec/cydia/",
                       @"/usr/sbin/frida-server",
                       @"/usr/bin/cycript",
                       @"/usr/local/bin/cycript",
                       @"/usr/lib/libcycript.dylib",
                       @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                       @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                       @"/Applications/FakeCarrier.app",
                       @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                       @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                       @"/usr/libexec/ssh-keysign",
                       @"/usr/libexec/sftp-server",
                       @"/Applications/blackra1n.app",
                       @"/Applications/IntelliScreen.app",
                       @"/Applications/Snoop-itConfig.app",
                       @"/var/checkra1n.dmg",
                       @"/var/binpack",
                       nil];
    //Check installed app
    for(NSString* check in checks)
    {
        if(canOpen(check))
        {
            if(DEBUGGING){LOG(check);}
            return YES;
        }
    }
    //symlink verification
    struct stat sym;
    if(lstat("/Applications", &sym) || lstat("/var/stash/Library/Ringtones", &sym) ||
       lstat("/var/stash/Library/Wallpaper", &sym) ||
       lstat("/var/stash/usr/include", &sym) ||
       lstat("/var/stash/usr/libexec", &sym)  ||
       lstat("/var/stash/usr/share", &sym) ||
       lstat("/var/stash/usr/arm-apple-darwin9", &sym))
    {
        if(sym.st_mode & S_IFLNK)
        {
            if(DEBUGGING){LOG(@"Symlink");}
            return YES;
        }
    }
    
    //Check process forking
    int pid = fork();
    if(!pid)
    {
        exit(1);
    }
    if(pid >= 0)
    {
        if(DEBUGGING){LOG(@"Fork");}
        return YES;
    }
    
    //Check permission to write to /private
    NSString *path = @"/private/avl.txt";
    NSFileManager *fileManager = [NSFileManager defaultManager];
    @try {
        NSError* error;
        NSString *test = @"AVL was here";
        [test writeToFile:test atomically:NO encoding:NSStringEncodingConversionAllowLossy error:&error];
        [fileManager removeItemAtPath:path error:nil];
        if(error==nil)
        {
            if(DEBUGGING){LOG(@"File creation");}
            return YES;
        }
        return NO;
    } @catch (NSException *exception) {
        return NO;
    }
}

char* UNHIDE_STR(char* str){
    do { char *p = str;  while (*p) *p++ += 0x19; } while (0);
    return str;
}

char* decryptString(char* str){
    str = UNHIDE_STR(str);
    str[strlen(str)]='\0';
    return str;
}

BOOL isInjectedWithDynamicLibrary()
{
    int i=0;
    while(true){
        const char *name = _dyld_get_image_name(i++);
        if(name==NULL){
            break;
        }
        if (name != NULL) {
            char cyinjectHide[] = {
                A('c'),
                A('y'),
                A('i'),
                A('n'),
                A('j'),
                A('e'),
                A('c'),
                A('t'),
                0
            };
            char libcycriptHide[] = {
                A('l'),
                A('i'),
                A('b'),
                A('c'),
                A('y'),
                A('c'),
                A('r'),
                A('i'),
                A('p'),
                A('t'),
                0
            };
            
            char libfridaHide[] = {
                A('F'),
                A('r'),
                A('i'),
                A('d'),
                A('a'),
                A('G'),
                A('a'),
                A('d'),
                A('g'),
                A('e'),
                A('t'),
                0
            };
            char zzzzLibertyDylibHide[] = {
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('L'),
                A('i'),
                A('b'),
                A('e'),
                A('r'),
                A('t'),
                A('y'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            char sslkillswitch2dylib[] = {
                A('S'),
                A('S'),
                A('L'),
                A('K'),
                A('i'),
                A('l'),
                A('l'),
                A('S'),
                A('w'),
                A('i'),
                A('t'),
                A('c'),
                A('h'),
                A('2'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char zeroshadowdylib[] = {
                A('0'),
                A('S'),
                A('h'),
                A('a'),
                A('d'),
                A('o'),
                A('w'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char mobilesubstratedylib[] = {
                A('M'),
                A('o'),
                A('b'),
                A('i'),
                A('l'),
                A('e'),
                A('S'),
                A('u'),
                A('b'),
                A('s'),
                A('t'),
                A('r'),
                A('a'),
                A('t'),
                A('e'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char libsparkapplistdylib[] = {
                A('l'),
                A('i'),
                A('b'),
                A('s'),
                A('p'),
                A('a'),
                A('r'),
                A('k'),
                A('a'),
                A('p'),
                A('p'),
                A('l'),
                A('i'),
                A('s'),
                A('t'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char SubstrateInserterdylib[] = {
                A('S'),
                A('u'),
                A('b'),
                A('s'),
                A('t'),
                A('r'),
                A('a'),
                A('t'),
                A('e'),
                A('I'),
                A('n'),
                A('s'),
                A('e'),
                A('r'),
                A('t'),
                A('e'),
                A('r'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
            };
            
            char zzzzzzUnSubdylib[] = {
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('z'),
                A('U'),
                A('n'),
                A('S'),
                A('u'),
                A('b'),
                A('.'),
                A('d'),
                A('y'),
                A('l'),
                A('i'),
                A('b'),
                0
                
            };
            
            char kor[] = {
                A('.'),
                A('.'),
                A('.'),
                A('!'),
                A('@'),
                A('#'),
                0
            };
            char cephei[] = {
                A('/'),A('u'),A('s'),A('r'),A('/'),A('l'),A('i'),A('b'),A('/'),A('C'),A('e'),A('p'),A('h'),A('e'),A('i'),A('.'),A('f'),A('r'),A('a'),A('m'),A('e'),A('w'),A('o'),A('r'),A('k'),A('/'),A('C'),A('e'),A('p'),A('h'),A('e'),A('i'),
                0
            };
            if (tuyul(name, decryptString(cephei)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(kor)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(mobilesubstratedylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if(tuyul(name, decryptString(libsparkapplistdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(cyinjectHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(libcycriptHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(libfridaHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(zzzzLibertyDylibHide)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(sslkillswitch2dylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(zeroshadowdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(SubstrateInserterdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
            if (tuyul(name, decryptString(zzzzzzUnSubdylib)) != NULL){
                if(DEBUGGING){LOG([[NSString alloc] initWithFormat:@"%s", name]);}
                return YES;
            }
        }
    }
    return NO;
}

// Returns true if the current process is being debugged (either
// running under the debugger or has a debugger attached post facto).
// Thanks to https://developer.apple.com/library/archive/qa/qa1361/_index.html
BOOL isDebugged()
{
    int junk;
    int mib[4];
    struct kinfo_proc info;
    size_t size;
    info.kp_proc.p_flag = 0;
    mib[0] = CTL_KERN;
    mib[1] = KERN_PROC;
    mib[2] = KERN_PROC_PID;
    mib[3] = getpid();
    size = sizeof(info);
    junk = sysctl(mib, sizeof(mib) / sizeof(*mib), &info, &size, NULL, 0);
    assert(junk == 0);
    return ( (info.kp_proc.p_flag & P_TRACED) != 0 );
}

BOOL isFromAppStore()
{
    #if TARGET_IPHONE_SIMULATOR
        return NO;
    #else
        NSString *provisionPath = [[NSBundle mainBundle] pathForResource:@"embedded" ofType:@"mobileprovision"];
        if (nil == provisionPath || 0 == provisionPath.length) {
            return YES;
        }
        return NO;
    #endif
}

BOOL isSecurityCheckPassed()
{
    if(TARGET_IPHONE_SIMULATOR)return NO;
    return !isJb() && !isInjectedWithDynamicLibrary() && !isDebugged();
    
}

@end
```

## Homebrew国内安装
### 自动脚本(全部国内地址)（在Mac终端中复制粘贴回车下面脚本)
安装脚本：
```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/Homebrew.sh)"
```
卸载脚本：
```
/bin/zsh -c "$(curl -fsSL https://gitee.com/cunkai/HomebrewCN/raw/master/HomebrewUninstall.sh)"
```

## curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to raw.githubusercontent.com:443 
### 此处出现报错, 证明当前网络不行, 切换另外的网络/热点就行
```
$     sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/AloneMonkey/MonkeyDev/master/bin/md-install)"
curl: (35) LibreSSL SSL_connect: SSL_ERROR_SYSCALL in connection to raw.githubusercontent.com:443 
此处出现报错, 证明当前网络不行, 切换另外的网络/热点就行
Password:
$     sudo /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/AloneMonkey/MonkeyDev/master/bin/md-install)"
Downloading MonkeyDev base from Github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 3452k  100 3452k    0     0   4256      0  0:13:50  0:13:50 --:--:-- 10751
Downloading Xcode templates from Github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  306k    0  306k    0     0  16915      0 --:--:--  0:00:18 --:--:-- 14798
Downloading frida-ios-dump from Github...
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  9669  100  9669    0     0   1012      0  0:00:09  0:00:09 --:--:--   396
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 11727  100 11727    0     0   3273      0  0:00:03  0:00:03 --:--:--  3273
Creating symlink to Xcode templates...
Modifying Bash personal initialization file...
   
```

## 如何检测越狱设备
为方便起见，“恶意应用程序”将指App Store中任何可主动实施越狱检测措施的应用程序。
在大多数情况下，越狱检测程序并不像人们想象的那么复杂。尽管应用程序可以采用多种方式对越狱设备进行检查，但通常可以归结为以下几点：

目录的存在 -流氓应用喜欢在文件系统中检查/Applications/Cydia.app/和/ private / var / stash等路径。
大多数情况下，这些是使用NSFileManager中的-（BOOL）fileExistsAtPath：（NSString *）path方法进行检查的，
但是更多偷偷摸摸的应用程序喜欢使用较低级别的C函数，例如fopen（），stat（）或access（）。

目录权限 -类似于检查目录是否存在，但是使用NSFileManager方法以及statfs（）之类的C函数来检查系统上特定文件和目录的Unix文件权限。
在越狱设备上的目录访问权限要比仍在监狱中的目录要多。

流程fork -沙盒不会拒绝App Store应用程序使用fork（），popen（）或任何其他C函数在越狱设备上创建子进程的能力。
沙盒明确拒绝在越狱中的设备上进行进程fork。通过检查fork（）上返回的pid，流氓应用程序可以判断它是否已成功fork，这时可以确定设备的越狱状态。

SSH环回连接 -只有极少数的应用程序可以实现此目的（因为它不如其他应用程序有效）。
由于安装了OpenSSH的越狱设备的比例很大，某些恶意应用程序将尝试在端口22上建立与127.0.0.1的连接。
如果连接成功，则表明OpenSSH已在设备上安装并运行，这显然表明越狱了

system（） -在监狱中的设备上使用NULL参数调用system（）函数将返回0；否则，将返回0。在越狱设备上执行相同操作将返回1。
这是因为该功能将检查是否/bin/sh存在，并且仅在越狱设备上才如此

dyld函数 -迄今为止最难解决的问题。调用诸如_dyld_image_count（）和_dyld_get_image_name（）之类的函数，以查看当前正在加载哪些dylib。
修补非常困难，因为修补本身就是dylib的一部分。

## 如何对iOS App进行逆向工程
为了从App Store中转储或反汇编应用程序，即使它是免费的应用程序，也必须首先将其解密（通常称为“ 砸壳 ”）。

在应用程序的解密二进制文件上使用class-dump将转储所有头文件。有时，它们包含“赠予”方法名称，
例如“ deviceIsJailbroken”或“ checkDeviceSecurity”。通常，挂接这些方法足以禁用越狱检测措施，但几乎可以保证该补丁将无法在其他应用程序上运行。

使用Objective-C解析功能在IDA中跟踪类似名称的方法可以帮助您准确地确定使用哪种方法来检测越狱。
如果类转储的头文件没有给出任何内容，则在二进制文件中搜索“ jail”，“ cydia”，“ apt”等字符串通常会导致断点。

----------------------------------------------------------------------------------------------------------------
# 汇编语言  Assembly

答：汇编语言是计算机语言，通俗来讲就是人类与计算机(CPU)交流的桥梁，
计算机不认识人类的语言，想要让计算机去完成人们的工作，就需要俺们将这些工作翻译成计算机语言，属于低级计算机语言。

iOS App与汇编语言的关系
一个APP安装到操作系统上面的可执行的文件本质上来讲就是二进制文件，操作系统本质上执行的指令也是二进制，是由CPU执行的；

## Assembly 和 fishhook
Objective-C的方法在编译后会走objc_msgSend，所以通过fishhook来hook这一个C函数即可获得Objective-C符号
由于objc_msgSend是变长参数，所以hook代码需要用汇编来实现：
```
 1//代码参考InspectiveC
 2__attribute__((__naked__))
 3static void hook_Objc_msgSend() {
 4    save()
 5    __asm volatile ("mov x2, lr\n");
 6    __asm volatile ("mov x3, x4\n");
 7    call(blr, &before_objc_msgSend)
 8    load()
 9    call(blr, orig_objc_msgSend)
10    save()
11    call(blr, &after_objc_msgSend)
12    __asm volatile ("mov lr, x0\n");
13    load()
14    ret()
15}
```
子程序调用时候要保存和恢复参数寄存器，
所以save和load分别对x0~x9, q0~q9入栈/出栈。
call则通过寄存器来间接调用函数：
```
 1#define save() \
 2__asm volatile ( \
 3"stp q6, q7, [sp, #-32]!\n"\
 4...
 5
 6#define load() \
 7__asm volatile ( \
 8"ldp x0, x1, [sp], #16\n" \
 9...
10
11#define call(b, value) \
12__asm volatile ("stp x8, x9, [sp, #-16]!\n"); \
13__asm volatile ("mov x12, %0\n" :: "r"(value)); \
14__asm volatile ("ldp x8, x9, [sp], #16\n"); \
15__asm volatile (#b " x12\n");
```
在before_objc_msgSend中用栈保存lr，在after_objc_msgSend恢复lr。
由于要生成trace文件，为了降低文件的大小，直接写入的是函数地址，且只有当前可执行文件的Mach-O(app和动态库)代码段才会写入：

iOS中，由于ALSR(https://en.wikipedia.org/wiki/Address_space_layout_randomization)的存在，在写入之前需要先减去偏移量slide：
```
1IMP imp = (IMP)class_getMethodImplementation(object_getClass(self), _cmd);
2unsigned long imppos = (unsigned long)imp;
3unsigned long addr = immpos - macho_slide
```
获取一个二进制的__text段地址范围：
```
1unsigned long size = 0;
2unsigned long start = (unsigned long)getsectiondata(mhp,  "__TEXT", "__text", &size);
3unsigned long end = start + size;
获取到函数地址后，反查linkmap既可找到方法的符号名。
```

iOS的block是一种特殊的单元，block在编译后的函数体是一个C函数，
在调用的时候直接通过指针调用，并不走objc_msgSend，所以需要单独hook。

通过Block的源码可以看到block的内存布局如下：
```
 1struct Block_layout {
 2    void *isa;
 3    int32_t flags; // contains ref count
 4    int32_t reserved;
 5    void  *invoke;
 6    struct Block_descriptor1 *descriptor;
 7};
 8struct Block_descriptor1 {
 9    uintptr_t reserved;
10    uintptr_t size;
11};
```
其中invoke就是函数的指针，hook思路是将invoke替换为自定义实现，然后在reserved保存为原始实现。
```
1
2if (layout->descriptor != NULL && layout->descriptor->reserved == NULL)
3{
4    if (layout->invoke != (void *)hook_block_envoke)
5    {
6        layout->descriptor->reserved = layout->invoke;
7        layout->invoke = (void *)hook_block_envoke;
8    }
9}
```
由于block对应的函数签名不一样，所以仍然采用汇编来实现hook_block_envoke：
```
 1__attribute__((__naked__))
 2static void hook_block_envoke() {
 3    save()
 4    __asm volatile ("mov x1, lr\n");
 5    call(blr, &before_block_hook);
 6    __asm volatile ("mov lr, x0\n");
 7    load()
 8    //调用原始的invoke，即resvered存储的地址
 9    __asm volatile ("ldr x12, [x0, #24]\n");
10    __asm volatile ("ldr x12, [x12]\n");
11    __asm volatile ("br x12\n");
12}
```

在before_block_hook中获得函数地址（同样要减去slide）。
```
1intptr_t before_block_hook(id block,intptr_t lr)
2{
3    Block_layout * layout = (Block_layout *)block;
4    //layout->descriptor->reserved即block的函数地址
5    return lr;
6}
```
同样，通过函数地址反查linkmap既可找到block符号

### .s 汇编语言源程序;  操作: 汇编
### .S 汇编语言源程序;  操作: 预处理 + 汇编

```
1.小写的 s文件，在后期阶段不会再进行预处理操作了，所以我们不能在其内写上预处理语句。

    一般是 .c 文件经过汇编器处理后的输出。 如 GCC 编译器就可以指定 -S 选项进行输出， 且是经过预处理器处理后的了。

2.大写的 S 文件，还会进行预处理、汇编等操作，所以我们可以在这里面加入预处理的命令。编译器在编译汇编大 S 

    文件之前会进行预处理操作。

    常用这种形式的汇编文件作为工程内的汇编源文件(如 Linux 和 u-boot)， 因为在文件内可以很方便的使用常用的

    预处理指令来进行宏定义，条件编译， 和文件包含操作。

    如: #include, #define, #ifdef, #else, #if, #elif, #endif 等预处理指令。

    具体的应用可以参考 Linux 或者 u-boot 的 .S 源代码。
----------------------------------------------------------------------------

    asm(汇编);

在针对ARM体系结构的编程中，一般很难直接使用C语言产生操作协处理器的相关代码，因此使用汇编语言来实现就成为了唯一的选择。

但如果完全通过汇编代码实现，又会过于复杂、难以调试。因此，C语言内嵌汇编的方式倒是一个不错的选择。

然而，使用内联汇编的一个主要问题是，内联汇编的语法格式与使用的编译器直接相关，也就是说，使用不同的C编译器内联汇编代码时，它们的写法是各不相同的。

下面介绍在ARM体系结构下GCC的内联汇编。GCC内联汇编的一般格式：asm(汇编);

asm(   
 
 
    代码列表   
    : 输出运算符列表   
    : 输入运算符列表   
    : 被更改资源列表   
);

在C代码中嵌入汇编需要使用asm关键字，在asm的修饰下，代码列表、输出运算符列表、输入运算符列表和被更改的资源列表这4个部分被3个“:”分隔。下面，我们看一个例子：

void test(void) 
{   
    ……   
    asm(   
        "mov r1,#1\n"   
        :   
        :   
        :"r1"   
    );   
    ……   
} 

注：换行符和制表符的使用可以使得指令列表看起来变得美观。你第一次看起来可能有点怪异，但是当C编译器编译C语句的是候，它就是按照上面（换行和制表）生成汇编的。

函数test中内嵌了一条汇编指令实现将立即数1赋值给寄存器R1的操作。由于没有任何形式的输出和输入，因此输出和输入列表的位置上什么都没有填写。但是，在汇编代码执行过程中R1寄存器会被修改，因此为了通知编译器，在被更改资源列表中，需要写上寄存器R1。

寄存器被修改这种现象发生的频率还是比较高的。例如，在调用某段汇编程序之前，寄存器R1可能已经保存了某个重要数据，当汇编指令被调用之后，R1寄存器被赋予了新的值，原来的值就会被修改，所以，需要将会被修改的寄存器放入到被更改资源列表中，这样编译器会自动帮助我们解决这个问题。也可以说，出现在被更改资源列表中的资源会在调用汇编代码一开始就首先保存起来，然后在汇编代码结束时释放出去。所以，上面的代码与如下代码从语义上来说是等价的。

void test(void) 
{   
    ……   
    asm(   
        "stmfd sp!,{r1}\n" 
        "mov r1,#1\n"   
        "ldmfd sp!,{r1}\n"   
    );   
    ……   
} 

这段代码中的内联汇编既无输出又无输入，也没有资源被更改，只留下了汇编代码的部分。由于程序在修改R1之前已经将寄存器R1的值压入了堆栈，在使用完之后，又将R1的值从堆栈中弹出，所以，通过被更改资源列表来临时保存R1的值就没什么必要了。

在以上两段代码中，汇编指令都是独立运行的。但更多的时候，C和内联汇编之间会存在一种交互。C程序需要把某些值传递给内联汇编运算，内联汇编也会把运算结果输出给C代码。此时就可以通过将适当的值列在输入运算符列表和输出运算符列表中来实现这一要求。请看下面的例子：

void test(void) 
{   
    int tmp=5;   
    asm(   
        "mov r4,%0\n"   
        :   
        :"r"(tmp)   
        :"r4"   
    );   
} 

上面的代码中有一条mov指令，该指令将%0赋值给R4。这里，符号%0代表出现在输入运算符列表和输出运算符列表中的第一个值。如果%1存在的话，那么它就代表出现在列表中的第二个值，依此类推。所以，在该段代码中，%0代表的就是“r”(tmp)这个表达式的值了。

那么这个新的表达式又该怎样解释呢？原来，在“r”(tmp)这个表达式中，tmp代表的正是C语言向内联汇编输入的变量，操作符“r”则代表tmp的值会通过某一个寄存器来传递。在GCC4中与之相类似的操作符还包括“m”、“I”，等等，其含义见下表：

ARM嵌入式开发中的GCC内联汇编简介

与输入运算符列表的应用方法一致，当C语言需要利用内联汇编输出结果时，可以使用输出运算符列表来实现，其格式应该是下面这样的。

void test(void) 
{   
    int tmp;   
    asm(   
        "mov %0,#1\n"   
        :"=r"(tmp)   
        :   
    );   
} 

在上面的代码中，原本应出现在输入运算符列表中的运算符，现在出现在了输出运算符列表中，同时变量tmp将会存储内联汇编的输出结果。
这里有一点可能已经引起大家的注意了，上面的代码中操作符r的前面多了一个“=”。这个等号被称为约束修饰符，其作用是对内联汇编的操作符进行修饰。

当一个操作符没有修饰符对其进行修饰时，代表这个操作符是只读的。当我们需要将内联汇编的结果输出出来，那么至少要保证该操作符是可写的。因此，“=”或者“+”也就必不可少了。

```
----------------------------------------------------------------------------------------------------------------

## dyld
动态链接器，其本质也是 Mach-O 文件，一个专门用来加载 dylib 文件的库。
dyld 位于 /usr/lib/dyld，可以在 macOS 和越狱机中找到。
dyld 会将 App 依赖的动态库和 App 文件加载到内存执行。

## Mach-O 文件

### Mach header：描述 Mach-O 的 CPU 架构、文件类型以及加载命令等；
### Load commands：描述了文件中数据的具体组织结构，不同的数据类型使用不同的加载命令；
### Data：Data 中的每个段（segment）的数据都保存在这里;

### 每个段（segment）都有Section : 存放了具体的数据与代码，主要包含以下三种类型：

__TEXT 包含 Mach header，被执行的代码和只读常量（如C 字符串）。只读可执行（r-x）。

__DATA 包含全局变量，静态变量等。可读写（rw-）。

__LINKEDIT 包含了加载程序的元数据，比如函数的名称和地址。只读（r–-）。

## MachOView : 查看MachO文件格式信息
### MachOView源码地址：https://github.com/gdbinit/MachOView

```
Mach-O格式全称为Mach Object文件格式的缩写，是mac上可执行文件的格式，
类似于windows上的PE格式 (Portable Executable ), linux上的elf格式 (Executable and Linking Format)。

Mach-O文件类型分为：

1、Executable：应用的主要二进制

2、Dylib Library：动态链接库（又称DSO或DLL）

3、Static Library：静态链接库

4、Bundle：不能被链接的Dylib，只能在运行时使用dlopen( )加载，可当做macOS的插件

5、Relocatable Object File ：可重定向文件类型

那什么又是FatFile/FatBinary？

简单来说，就是一个由不同的编译架构后的Mach-O产物所合成的集合体。
一个架构的mach-O只能在相同架构的机器或者模拟器上用，为了支持不同架构需要一个集合体。
```

```
MachOView在load Commands里面加载了这么些动态库: 

LC_SEGMENT_64：定义一个（64位）段， 当文件加载后它将被映射到地址空间。包括段内节（section）的定义。

LC_SYMTAB：为该文件定义符号表（‘stabs’ 风格）和字符串表。 他们在链接文件时被链接器使用，同时也用于调试器映射符号到源文件。具体来说，符号表定义本地符号仅用于调试，而已定义和未定义external 符号被链接器使用。

LC_DYSYMTAB：提供符号表中给出符号的额外符号信息给动态链接器，以便其处理。 包括专门为此而设的一个间接符号表的定义。

LC_DYLD_INFO_ONLY：定义一个附加 压缩的动态链接器信息节，它包含在其他事项中用到的 动态绑定符号和操作码的元数据。stub 绑定器（“dyld_stub_binder”），它涉及的动态间接链接利用了这点。 “_ONLY” 后缀t表明这个加载指令是程序运行必须的，, 这样那些旧到不能理解这个加载指令的链接器就在这里停下。

LC_LOAD_DYLINKER: 加载一个动态链接器。在OS X上，通常是“/usr/lib/dyld”。LC_LOAD_DYLIB: 加载一个动态链接共享库。举例来说，“/usr/lib/libSystem.B.dylib”，这是C标准库的实现再加上一堆其他的事务（系统调用和内核服务，其他系统库等）。每个库由动态链接器加载并包含一个符号表，符号链接名称是查找匹配的符号地址。

LC_MAIN：指明程序的入口点。在本案例，是函数themain()的地址。

LC_UUID：提供一个唯一的随机UUID，通常由静态链接器生成。

LC_VERSION_MIN_MACOSX：程序可运行的最低OS X版本要求

LC_SOURCE_VERSION:：构建二进制文件的源码版本号。

LC_FUNCTION_STARTS：定义一个函数起始地址表，使调试器和其他程序易于看到一个地址是否在函数内。

LC_DATA_IN_CODE：定义在代码段内的非指令的表。

LC_DYLIB_CODE_SIGN_DRS: 为已链接的动态库定义代码签名 指定要求。

Xcode工程里的系统库 则转化为LC_LOAD_DYLIB 所谓dylib嵌入就是指的这个过程 此在后文中予以介绍

而关于LC_SEGMENT_64头部则有如下的定义说明

__PAGEZERO：一个全用0填充的段，用于抓取空指针引用。这通常不会占用磁盘空间(或内存空间)，因为它运行时映射为一群0啊。顺便说一句，这个段是隐藏恶意代码的好地方。

__TEXT：本段只有可执行代码和其他只读数据。

__text：本段是可执行机器码。

__stubs：间接符号存根。这些跳转到非延迟加载 (“随运行加载”) 和延迟加载(“初次使用时加载”) 间接引用的（可写）位置的值 (例如条目“__la_symbol_ptr”，我们很快就会看到)。对于延迟加载引用，其地址跳转讲首先指向一个解析过程，但初始化解析后会指向一个确定的地址。 对于非延迟加载引用，其地址跳转会始终指向一个确定的地址，因为动态链接器在加载可执行文件时就修正好了。

__stub_helper：提供助手来解决延迟加载符号。如上所述，延迟加载的间接符号指针将指到这里面，直到得到确定地址。

__cstring： constant (只读) C风格字符串（如”Hello, world!n”）的节。链接器在生成最终产品时会清除重复语句。

__unwind_info：一个紧凑格式，为了存储堆栈展开信息供处理异常。此节由链接器生成，通过“__eh_frame”里供OS X异常处理的信息。

__eh_frame： 一个标准的节，用于异常处理，它提供堆栈展开信息，以DWARF格式。


__DATA：用于读取和写入数据的一个段。

__nl_symbol_ptr：非延迟导入符号指针表。

__la_symbol_ptr：延迟导入符号指针表。本节开始时，指针们指向解析助手，如前所讨述。

__got：全局偏移表–— （非延迟）导入全局指针表。


__LINKEDIT：包含给链接器（“链接编辑器‘）的原始数据的段，在本案例中，包括符号和字符串表，压缩动态链接信息，代码签名存托凭证，以及间接符号表–所有这一切的占区都被加载指令指定了。

```


theos .deb插件
```
   .
├── .theos
|   ├── _ 
|   |    └── ...  *
|   ├── obj 
|   |    └── ...  *
|   ├── packages 
|   |    └── ...   记录版本号
|   ├── build_session
|   ├── fakeroot
|   └── last_package    当前打包成功以后放的路径
├── obj   实际上跟上面.theos/obj的目录是一样的
|   └── 
