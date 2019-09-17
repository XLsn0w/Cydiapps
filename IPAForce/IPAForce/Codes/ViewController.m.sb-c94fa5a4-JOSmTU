//
//  ViewController.m
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/25.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#import "ViewController.h"




@interface initVCWindowController()
@end

@implementation initVCWindowController
- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller’s window has been loaded from its nib file.
}
- (BOOL)windowShouldClose:(id)sender {
    [NSApp hide:nil];
    return NO;
}
@end




@implementation SetupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建存档目录
    NSURL *tempDir = [[NSFileManager defaultManager] temporaryDirectory];
    NSURL *savesDir = [tempDir URLByAppendingPathComponent:(@"Saves") isDirectory:true];
    BOOL fuckThis = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:savesDir.path isDirectory:&fuckThis]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:savesDir.path withIntermediateDirectories:YES attributes:NULL error:NULL];
    }
    
    NSURL *sshAddrSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshAddress.txt"];
    NSString *inputString = [[NSString alloc] initWithContentsOfFile:sshAddrSave.path
                                                            encoding:NSUTF8StringEncoding
                                                               error:NULL];
    if (inputString == nil) {
        inputString = @"0.0.0.0:22";
        [inputString writeToURL:sshAddrSave atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    }
    
    
    
    startiProxy();
    NSString *list = [NSString alloc];
    [_secondLabel setStringValue:@"App List On iOS"];
    list = getListOfApps();
    [_appListField setAlignment:atLeft];
    [_appListField setStringValue:list];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger day = [components day];
    NSInteger month = [components month];
    
    if (day == 2 && month == 10){
        [_rightsLabel setStringValue:@"Happy Birthday to Lakr Sakura!"];
    }
    
    self.parentViewController.view.wantsLayer = YES;
    self.parentViewController.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    // 后台更新系统状态
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @autoreleasepool {
            NSString *summaryString = checkSystemStatus();
            // 回到主线程更新 UI
            NSURL *url;
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                    [self->_sysStatusLabel setStringValue:summaryString];
                });
            }];
            [task resume];
        }
    });
    
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

    // 刷新系统状态
- (IBAction)refreshSysStatus:(id)sender {
    @autoreleasepool {
        NSString *summaryString = checkSystemStatus();
        NSURL *url;
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                [self->_sysStatusLabel setStringValue:summaryString];
            });
        }];
        [task resume];
    }
}



    // 开始设置macOS的环境
- (IBAction)startSetupForMacOS:(id)sender {
    @autoreleasepool {
        
        // 获取文件路径并设置准备写入
        NSURL *tempDir = [[NSFileManager defaultManager] temporaryDirectory];
        NSURL *fileURL = [tempDir URLByAppendingPathComponent:(@"OneMonkey.command")];
        NSURL *scriptURL = [tempDir URLByAppendingPathComponent:(@"Saves/setupScriptSavedForMac.txt")];
        
        // 检查文件是否存在 不存在创建 存在检查是否为空 空则写入默认代理
        if (![[NSFileManager defaultManager] fileExistsAtPath:scriptURL.path]) {
            [@"export https_proxy=http://127.0.0.1:6152;\nexport http_proxy=http://127.0.0.1:6152;\nexport all_proxy=socks5://127.0.0.1:6153" writeToURL:scriptURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }

        // 询问执行前脚本
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Any additional command before running the script? eg: export proxy and select Xcode."];
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"Cancel"];
        NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 600, 200)];
        //  读取保存的脚本
        NSString *scriptStringFromFileAtURL = [[NSString alloc]
                                                 initWithContentsOfURL:scriptURL
                                                 encoding:NSUTF8StringEncoding
                                                 error:NULL];
        [input setStringValue:scriptStringFromFileAtURL];
        [alert setAccessoryView:input];
        NSInteger button = [alert runModal];
        NSString *script = @"";
        if (button == NSAlertFirstButtonReturn) {
            script = [input stringValue];
            // 将脚本保存到本地
            [script writeToURL:scriptURL atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        } else if (button == NSAlertSecondButtonReturn) {
            return;
        }
        
        // 判断执行前脚本是否存在
        BOOL havePreCommand = false;
        if (![script  isEqual: @""]) { havePreCommand = true; }
        
        // 更新 UI 进度条
        [_setupMacProgress setHidden:NO];
        [_setupMacProgress setDoubleValue:20];
        
        // 创建 GCD 队列 异步执行安装
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            // 设置下载路径并写入文件
            NSString *stringURL = @"https://raw.githubusercontent.com/Co2333/coreBase/master/OneMonkey.sh";
            NSURL  *url = [NSURL URLWithString:stringURL];
            NSData *urlData = [NSData dataWithContentsOfURL:url];
            if ( urlData )
            {
                // 如果文件存在那么先删除
                if ([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path isDirectory:false]) {
                    NSLog(@"[!] Removing before download script");
                    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:NULL];
                }
                [urlData writeToURL:fileURL atomically:YES];
            }
            
            // 更新 UI 进度条
            NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                    [self->_setupMacProgress setDoubleValue:50];
                });
            }];
            [task resume];

            // 检查文件是否可读取
            NSError *error;
            if ([fileURL checkResourceIsReachableAndReturnError:&error]) {
                NSLog(@"[*] Download file at url completed. At path:%@", fileURL);
            } else {
                NSLog(@"[Error] Failed to download file at path:%@%@", fileURL, error);
            }
            
            // 如果执行前脚本存在那么创建新的脚本 如果不存在那么重命名脚本
            if (havePreCommand) {
                // 重命名下载的脚本
                NSURL *oldCommand = [tempDir URLByAppendingPathComponent:(@"OneMonkey.command.tmp")];
                [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:oldCommand error:NULL];
                // 将下载的脚本读入内存
                NSString *stringFromFileAtURL = [[NSString alloc]
                                                 initWithContentsOfURL:oldCommand
                                                 encoding:NSUTF8StringEncoding
                                                 error:NULL];
                // 合并脚本
                NSString *completedScript = script;
                completedScript = [completedScript stringByAppendingString:stringFromFileAtURL];
                // 写入执行前脚本
                [completedScript writeToURL:fileURL atomically:YES
                                   encoding:NSUTF8StringEncoding error:NULL];
                // 删除临时脚本
                [[NSFileManager defaultManager] removeItemAtURL:oldCommand error:NULL];
                
            } // if (havePreCommand)
            
            // 从fileURL执行脚本
            int returnVal = execCommandFromURL(fileURL);
            NSLog(@"[!] Exec command from URL returns:%d", returnVal);
            
            
            // 更新 UI 进度条
            NSURLSessionTask *task2 = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                dispatch_async(dispatch_get_main_queue(), ^{ // Correct
                    [self->_setupMacProgress setHidden:YES];
                    [self->_setupMacProgress setDoubleValue:0];
                });
            }];
            [task2 resume];

        });
        
        
    }
}
    // 开始设置iOS的环境
- (IBAction)startSetupForiOS:(id)sender {
    
    [_setupiOSProgress setHidden:NO];
    [_setupiOSProgress setDoubleValue:10];
    
    // 检查ssh连接性
    NSURL *sshAddrSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshAddress.txt"];
    NSURL *sshPassSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshPass.txt"];
    NSString *inputString = [[NSString alloc] initWithContentsOfFile:sshAddrSave.path
                                                            encoding:NSUTF8StringEncoding
                                                               error:NULL];
    NSString *inputStringPass = [[NSString alloc] initWithContentsOfFile:sshPassSave.path
                                                                encoding:NSUTF8StringEncoding
                                                                   error:NULL];
    int ipQuads[5];
    const char *ipAddress = [inputString cStringUsingEncoding:NSUTF8StringEncoding];
    sscanf(ipAddress, "%d.%d.%d.%d:%d", &ipQuads[0], &ipQuads[1], &ipQuads[2], &ipQuads[3], &ipQuads[4]);
    NSString *iPGrabed = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", ipQuads[0], ipQuads[1], ipQuads[2], ipQuads[3]];
    int sshPortGrabed = ipQuads[4];
    
    // 创建 ssh 隧道
    NMSSHSession *session = [NMSSHSession connectToHost:iPGrabed port:sshPortGrabed withUsername:@"root"];
    BOOL sshConnectedFlag = false;
    if (session.isConnected) {
        [session authenticateByPassword:inputStringPass];
        if (session.isAuthorized) {
            sshConnectedFlag = true;
        }
    }
    if (!sshConnectedFlag) {
        NSAlert *errorAlert2 = [[NSAlert alloc] init];
        [errorAlert2 setMessageText:@"Connect to iOS device failed."];
        [errorAlert2 addButtonWithTitle:@"OK"];
        [errorAlert2 runModal];
        [session disconnect];
        [_setupiOSProgress setHidden:YES];
        return;
    }
    NSAlert *errorAlert2 = [[NSAlert alloc] init];
    [errorAlert2 setMessageText:@"This operation was designed for iOS 11.2-11.3.1\nBut should work on other iOS.\nTake it as your own risks."];
    [errorAlert2 addButtonWithTitle:@"I understand."];
    [errorAlert2 addButtonWithTitle:@"Cancel"];
    NSModalResponse responseTag2 = [errorAlert2 runModal];
    if (responseTag2 == NSAlertSecondButtonReturn) {
        [_setupiOSProgress setHidden:YES];
        [session disconnect];
        return;
    }
    NSAlert *errorAlert = [[NSAlert alloc] init];
    [errorAlert setMessageText:@"Doing this operation may looks like app is dead.\nPlease wait until it finished.\nThis may takes 3-5 minutes."];
    [errorAlert addButtonWithTitle:@"I understand."];
    [errorAlert addButtonWithTitle:@"Cancel"];
    NSModalResponse responseTag1 = [errorAlert runModal];
    if (responseTag1 == NSAlertSecondButtonReturn) {
        [_setupiOSProgress setHidden:YES];
        [session disconnect];
        return;
    }
    // 准备上传 BootStrap 文件
    NSString *lakrBootstrap = [[[NSBundle mainBundle] resourcePath]
                               stringByAppendingPathComponent:@"LakrBootstrap.tar"];
    // lakrBootstrap    NSPathStore2 *    @"/Users/lakr/Library/Developer/Xcode/DerivedData/IPAForce-fwsmflhtjerzfhcjgtaizvbzhxst/Build/Products/Debug/IPAForce.app/Contents/Resources/LakrBootstrap.tar"    0x000000010180c4c0
    BOOL isBootStrapSuccessedUpload = [session.channel uploadFile:lakrBootstrap to:@"/var/mobile/Media/"];
    isBootStrapSuccessedUpload = !isBootStrapSuccessedUpload;
    NSLog(@"[*] Upload lakrBootstrap to device returns value:%d", isBootStrapSuccessedUpload);
    // 准备解包并安装
    NSError *error = nil; NSNumber *timeout = [[NSNumber alloc] initWithInt:60];
    NSString *response = [NSString alloc];
    response = [session.channel execute:@"tar -xvf /var/mobile/Media/LakrBootstrap.tar -C /var/mobile/Media/" error:&error timeout:timeout];
    NSLog(@"[*] tar -xvf at device returns message:\n%@\n",response);
    NSNumber *timeout2 = [[NSNumber alloc] initWithInt:180];
    response = [session.channel execute:@"dpkg -i /var/mobile/Media/debs/*" error:&error timeout:timeout2];
    NSLog(@"[*] dpkg -i at device returns message:\n%@\n",response);
    [_secondLabel setStringValue:@"Logs From 'dpkg'"];
    [_appListField setStringValue:response];
    // 清理临时文件
    response = [session.channel execute:@"rm -rf /var/mobile/Media/debs/" error:&error timeout:timeout];
    response = [session.channel execute:@"rm -f /var/mobile/Media/LakrBootstrap.tar" error:&error timeout:timeout];
    response = [session.channel execute:@"uicache" error:&error timeout:timeout];
    // 准备注销
    NSAlert *errorAlert3 = [[NSAlert alloc] init];
    [errorAlert3 setMessageText:@"Job is done. Ready to restart SpringBoard.\nThis is will kill apps.\nSave your documents."];
    [errorAlert3 addButtonWithTitle:@"I understand."];
    [errorAlert3 addButtonWithTitle:@"Cancel"];
    NSModalResponse responseTag3 = [errorAlert3 runModal];
    if (responseTag3 == NSAlertSecondButtonReturn) {
        [_setupiOSProgress setHidden:YES];
        [session disconnect];
        return;
    }
    
    response = [session.channel execute:@"killall backboardd" error:&error timeout:timeout];
    
    // 断开连接
    [session disconnect];
    [_setupiOSProgress setHidden:YES];

}
    // 保存 ssh 密码
- (IBAction)startSeupSSH:(id)sender {

    NSString *grabedValue = [NSString alloc];
    NSString *iPGrabed = [NSString alloc];
    while (true) {
        
        // 检查 iP 是否有存档 准备数据
        NSURL *sshAddrSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshAddress.txt"];
        NSString *sshAddrString = [NSString alloc];
        if (![[NSFileManager defaultManager] fileExistsAtPath:sshAddrSave.path]) {
            sshAddrString = [[NSString alloc] initWithFormat:@"192.168.6.121:22"];
            [sshAddrString writeToURL:sshAddrSave atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        }else{
            sshAddrString = [[NSString alloc] initWithContentsOfURL:sshAddrSave
                                                           encoding:NSUTF8StringEncoding
                                                              error:NULL];
        }
        
        // 执行 ip 地址重新读区 解决链接l重复读取
        int ipQuads[5];
        int sshPortGrabed = 0;
        const char *ipAddress = [sshAddrString cStringUsingEncoding:NSUTF8StringEncoding];
        sscanf(ipAddress, "%d.%d.%d.%d:%d", &ipQuads[0], &ipQuads[1], &ipQuads[2], &ipQuads[3], &ipQuads[4]);
        iPGrabed = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", ipQuads[0], ipQuads[1], ipQuads[2], ipQuads[3]];
        sshPortGrabed = ipQuads[4];
        sshAddrString = [[NSString alloc] initWithFormat:@"%@:%d", iPGrabed, sshPortGrabed];
        
        while (true) {
            // 获取用户输入 ssh 地址和端口
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"Please tell me ssh address and port.\nNo port means -p 22."];
            [alert addButtonWithTitle:@"Yes"];
            [alert addButtonWithTitle:@"Cancel"];
            NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
            [input setStringValue:sshAddrString];
            [alert setAccessoryView:input];
            NSInteger button = [alert runModal];
            NSString *inputString = @"";
            if (button == NSAlertFirstButtonReturn) {
                inputString = [input stringValue];
            } else if (button == NSAlertSecondButtonReturn) {
                return;
            }
            
            BOOL hasError = false;
            
            // 检查有没有屎在这数字里
            NSCharacterSet * set = [[NSCharacterSet characterSetWithCharactersInString:@":.0123456789"] invertedSet];
            if ([inputString rangeOfCharacterFromSet:set].location != NSNotFound) {
                NSLog(@"[Error] This string contains illegal characters");
                hasError = true;
            }
            
            // 检查是不是 iP 地址
            const char *ipAddress = [inputString cStringUsingEncoding:NSUTF8StringEncoding];
            sscanf(ipAddress, "%d.%d.%d.%d:%d", &ipQuads[0], &ipQuads[1], &ipQuads[2], &ipQuads[3], &ipQuads[4]);
            iPGrabed = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", ipQuads[0], ipQuads[1], ipQuads[2], ipQuads[3]];
            sshPortGrabed = ipQuads[4];
            @try {
                for (int quad = 0; quad < 4; quad++) {
                    if ((ipQuads[quad] < 0) || (ipQuads[quad] > 255)) {
                        NSException *ipException = [NSException
                                                    exceptionWithName:@"IPNotFormattedCorrectly"
                                                    reason:@"IP range is invalid"
                                                    userInfo:nil];
                        @throw ipException;
                    }
                }
            }
            @catch (NSException *exc) {
                NSLog(@"[ERROR] %@", [exc reason]);
                hasError = true;
            }
            
            // 判断有没有错误
            if (hasError) {
                NSAlert *errorAlert = [[NSAlert alloc] init];
                [errorAlert setMessageText:@"Not a iP address. Retry!"];
                [errorAlert addButtonWithTitle:@"Retry"];
                [errorAlert runModal];
            }else{
                grabedValue = inputString;
                break;
            }
        }
        
        if (sshPortGrabed <= 0 || sshPortGrabed >= 65535) {
            sshPortGrabed = 22;
        }
        
        // 将数据写入存档
        grabedValue = [[NSString alloc] initWithFormat:@"%@:%d", grabedValue, sshPortGrabed];
        [grabedValue writeToURL:sshAddrSave atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        
        // 准备检查服务器连接性
        BOOL isConnectAble = ifOpenShellWorking(iPGrabed, sshPortGrabed);
        if (isConnectAble) {
            break;
        }
        NSAlert *errorAlert2 = [[NSAlert alloc] init];
        [errorAlert2 setMessageText:@"I can't connect to your iPhone. Retry!"];
        [errorAlert2 addButtonWithTitle:@"Retry"];
        [errorAlert2 runModal];
        // 暂时解决应用崩溃
        // [General] *** initialization method -initWithFormat:locale:arguments: cannot be sent to an abstract object of class __NSCFString: Create a concrete instance!
        return;
    }
    
    // 已经成功链接 ssh 询问密码
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Please tell me ssh password. \n!Notice that this is saved as the same as you input for now. \nCancel it if you don't want to use this feature."];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"Cancel"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    NSString *inputString = @"";
    if (button == NSAlertFirstButtonReturn) {
        inputString = [input stringValue];
    } else if (button == NSAlertSecondButtonReturn) {
        return;
    }
    NSURL *sshPassSave = [[[NSFileManager defaultManager] temporaryDirectory] URLByAppendingPathComponent:@"Saves/sshPass.txt"];
    // 保存密码
    [inputString writeToURL:sshPassSave atomically:YES encoding:NSUTF8StringEncoding error:NULL];
}
    
    // 删除本地存档
- (IBAction)cleanDocuments:(id)sender {
    NSURL *dir = [[NSFileManager defaultManager] temporaryDirectory];
    [[NSFileManager defaultManager] removeItemAtURL:dir error:NULL];
    NSAlert *errorAlert = [[NSAlert alloc] init];
    [errorAlert setMessageText:@"Please rerun this app."];
    [errorAlert addButtonWithTitle:@"OK"];
    [errorAlert runModal];
    exit(0);
}
    
    
    // 准备创建工程
- (IBAction)startCreateProject:(id)sender {
    
    // 选择工程类型
    // - 创建 MonkeyDev App
    // - 创建 IPAForce App
    // - 从设备获取解密的 ipa
    
    NSAlert *selectorAlert = [[NSAlert alloc] init];
    [selectorAlert setMessageText:@"Hey! What you want to do with me?"];
    [selectorAlert addButtonWithTitle:@"Create MonkeyApp"];
    [selectorAlert addButtonWithTitle:@"Dump Header"];
    [selectorAlert addButtonWithTitle:@"Decrypted App From iDevice"];
    NSInteger button = [selectorAlert runModal];
    
    if (false) {
        // No fucking bb I like it. QAQ
    }else if (button == NSAlertFirstButtonReturn) {
        NSString *XcodePath = getOutputOfThisCommand(@"xcode-select -p", 1);
        XcodePath = [XcodePath substringToIndex:[XcodePath length] - 20];
        [[NSWorkspace sharedWorkspace] launchApplication:XcodePath];
    }else if (button == NSAlertSecondButtonReturn) {
        NSAlert *selectorAlert = [[NSAlert alloc] init];
        [selectorAlert setMessageText:@"Indeveloping!"];
        [selectorAlert addButtonWithTitle:@"OK"];
        [selectorAlert runModal];
    }else if (button == NSAlertThirdButtonReturn) {
        
        // 向用户询问 App 名字 "Kimono namayiwa!"
        NSString *nameOfApp = [NSString alloc];
        NSAlert *selectorAlert3 = [[NSAlert alloc] init];
        [selectorAlert3 setMessageText:@"Tell me the app name!\nMake sure there is a  \\  befroe each space.\nExample: DJI\\  Go\\  4"];
        [selectorAlert3 addButtonWithTitle:@"OK"];
        [selectorAlert3 addButtonWithTitle:@"Cancel"];
        NSTextField *inputName = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 350, 24)];
        [selectorAlert3 setAccessoryView:inputName];
        NSModalResponse ret = [selectorAlert3 runModal];
        if (ret == NSAlertSecondButtonReturn) {
            return;
        }
        
        nameOfApp = [inputName stringValue];
        
        // 删除字符串前后空格
        nameOfApp =  [nameOfApp stringByTrimmingCharactersInSet:
                      [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        NSAlert *selectorAlert31 = [[NSAlert alloc] init];
        [selectorAlert31 setMessageText:@"Make sure you have exit all the process on your iOS device.\nThis process may take up to 15 min.\nSo make sure your iOS device disabled screen saver."];
        [selectorAlert31 addButtonWithTitle:@"OK"];
        [selectorAlert31 addButtonWithTitle:@"Cancel"];
        NSTextField *inputName2 = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
        [inputName2 setStringValue:nameOfApp];
        [inputName2 setEditable:NO];
        [selectorAlert31 setAccessoryView:inputName2];
        NSModalResponse ret2 = [selectorAlert31 runModal];
        if (ret2 == NSAlertSecondButtonReturn) {
            return;
        }
        
        // 创建存档目录
        getOutputOfThisCommand(@"mkdir ~/Documents/IPAForceDumped", 1);
        if (![[NSFileManager defaultManager] fileExistsAtPath:[[NSString alloc] initWithFormat:@"~/Documents/IPAForceDumped/%@/%@.ipa", nameOfApp, nameOfApp]]) {
            getOutputOfThisCommand([[NSString alloc] initWithFormat:@"mkdir ~/Documents/IPAForceDumped/%@", nameOfApp], 1);
        }else{
            NSAlert *selectorAlert311 = [[NSAlert alloc] init];
            [selectorAlert311 setMessageText:@"You already have it. Replace it?"];
            [selectorAlert311 addButtonWithTitle:@"OK"];
            [selectorAlert311 addButtonWithTitle:@"Cancel"];
            NSModalResponse ret = [selectorAlert311 runModal];
            if (ret == NSAlertSecondButtonReturn) {
                return;
            }
            getOutputOfThisCommand([[NSString alloc] initWithFormat:@"rm -rf ~/Documents/IPAForceDumped/%@", nameOfApp], 1);
        }
        
        // 如果存在空格那么在他前面前加上 "\"
        // Help Wanted!
        
        // 开始创建解密脚本
        NSString *script = [[NSString alloc] initWithFormat:@"export LAKRNB=%@\ncd ~/Documents/IPAForceDumped/$LAKRNB/\npython /usr/local/bin/fridaDP.py $LAKRNB -o $LAKRNB.ipa\n", nameOfApp];
        NSString *tmpScript = [[NSString alloc] initWithFormat:@"%@/tmp.command", [[NSFileManager defaultManager] temporaryDirectory].path];
        [script writeToFile:tmpScript atomically:YES encoding:NSUTF8StringEncoding error:NULL];
        // 执行脚本
        getOutputOfThisCommand([[NSString alloc] initWithFormat:@"chmod 777 %@", tmpScript], 1);
        [[NSWorkspace sharedWorkspace] openFile:tmpScript];
        
    }else{
        NSLog(@"[Lakr NB 666] How can you been here?");
    }
    
}


- (IBAction)refreshAppLists:(id)sender {
    NSString *list = [NSString alloc];
    list = getListOfApps();
    [_secondLabel setStringValue:@"App List On iOS"];
    [_appListField setAlignment:atLeft];
    [_appListField setStringValue:list];
}



- (IBAction)exitAllTerminal:(id)sender {
    getOutputOfThisCommand(@"killall Terminal", 1);
}
    
    

@end
