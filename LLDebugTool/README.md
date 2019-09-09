<p align="center" >
  <img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/header.png" alt="LLDebugTool" title="LLDebugTool">
</p>

[![Version](https://img.shields.io/badge/iOS-%3E%3D8.0-f07e48.svg)](https://img.shields.io/badge/iOS-%3E%3D8.0-f07e48.svg)
[![CocoaPods Compatible](https://img.shields.io/badge/pod-v1.3.1-blue.svg)](https://img.shields.io/badge/pod-v1.3.1-blue.svg)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)](https://img.shields.io/badge/Platform-iOS-lightgrey.svg)
[![License](https://img.shields.io/badge/License-Anti%20996-blue.svg)](https://github.com/996icu/996.ICU/blob/master/LICENSE)
[![Language](https://img.shields.io/badge/Language-Objective--C%20%7C%20Swift-yellow.svg)](https://img.shields.io/badge/Language-Objective--C%20%7C%20Swift-yellow.svg)
[![Twitter](https://img.shields.io/badge/Twitter-@HdbLi-1DA1F2.svg)](https://twitter.com/HdbLi)

## Introduction

[点击查看中文简介](https://github.com/HDB-Li/LLDebugTool/blob/master/README-cn.md)

LLDebugTool is a debugging tool for developers and testers that can help you analyze and manipulate data in non-xcode situations.

[LLDebugToolSwift](https://github.com/HDB-Li/LLDebugToolSwift) is the extension of [LLDebugTool](https://github.com/HDB-Li/LLDebugTool), it provide swift interface for LLDebugTool, LLDebugToolSwift will release with LLDebugTool at same time. 

If your project is a Objective-C project, you can use `LLDebugTool`, if your project is a Swift project or contains swift files, you can use `LLDebugToolSwift`.

Choose LLDebugTool for your next project, or migrate over your existing projects—you'll be happy you did! 🎊🎊🎊

#### Gif

<div align="left">
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/screenGif.gif" width="20%"></img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenGif-Screenshot.gif" width="20%"></img>
</div>

#### Preview

<div align="left">
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-1.png" width="18%"></img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-2.png" width="18%"> </img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-3.png" width="18%"> </img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-4.png" width="18%"> </img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-5.png" width="18%"> </img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-6.png" width="18%"></img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-7.png" width="18%"> </img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-8.png" width="18%"> </img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-9.png" width="18%"> </img>
<img src="https://raw.githubusercontent.com/HDB-Li/HDBImageRepository/master/LLDebugTool/ScreenShot-10.png" width="18%"> </img>
</div>

## What's new in 1.3.1

###  Hierarchy and magnifying is coming.

Hierarchy function : Now you can use `Hierarchy` function to see every element on screen, and you can visually see their frame and properties, `Hierarchy info` will come soon.

Magnifying function : Now you can use `Magnifying` function to see the contents or color of each pixel, this makes it easier for you to communicate with the UI designer.

More changes can be viewed in [Version 1.3.1 Project](https://github.com/HDB-Li/LLDebugTool/projects/8).

#### Add

* Refactory UI hierarchy, now use many windows to display functions, each function use one window, more information you can see `LLWindowManager.m`.

#### Update

* Changed folder path.
* Update a new user interface.
* Fix in iOS 13.

#### Remove

* `LLDebugTool` didn't supports component-based now. This is a useless feature and adds to the difficulty of calling between modules. `LLDebugTool` is later maintained as a single app rather than as multiple functional modules.
* Remove some unused files, methods and macros.
        
## What can you do with LLDebugTool?

- Always check the network request or view log information for certain events without having to run under XCode. This is useful in solving the testers' problems.

- Easier filtering and filtering of useful information.

- Easier analysis of occasional problems.

- Easier analysis of the cause of the crash.

- Easier sharing, previewing, or removing sandbox files, which can be very useful in the development stage.

- Easier observe app's memory, CPU, FPS and other information.

- take screenshots, tag and share.

- more intuitive view of view structure.

- determine UI elements and colors in your App more accurately.

## Adding LLDebugTool to your project

### CocoaPods

[CocoaPods](http://cocoapods.org) is the recommended way to add `LLDebugTool` to your project.

##### Objective - C

> 1. Add a pod entry for LLDebugTool to your Podfile `pod 'LLDebugTool' , '~> 1.0.0'`. 
> 2. If only you want to use it only in Debug mode, Add a pod entry for LLDebugTool to your Podfile `pod 'LLDebugTool' , '~> 1.0.0' ,:configurations => ['Debug']`, Details also see [Wiki/Use in Debug environment](https://github.com/HDB-Li/LLDebugTool/wiki/Use-in-Debug-environment). If you want to specify the version, use as `pod 'LLDebugTool' , '1.3.1' ,:configurations => ['Debug']`.
> 3. The recommended approach is to use multiple targets and only add `pod 'LLDebugTool', '~> 1.0.0'` to Debug Target. This has the advantage of not contamiling the code in the Product environment and can be integrated into the App in the Archive Debug environment (if `:configurations => ['Debug']`, it can only run through XCode. It is not possible to Archive as an App).
> 4. Install the pod(s) by running `pod install`. If you can't search `LLDebugTool` or you can't find the newest release version, running `pod repo update` before `pod install`.
> 5. Include LLDebugTool wherever you need it with `#import "LLDebug.h"` or you can write `#import "LLDebug.h"` in your .pch  in your .pch file.

##### Swift

> 1. Add a pod entry for LLDebugToolSwift to your Podfile `pod 'LLDebugToolSwift' , '~> 1.0.0'`.
> 2. If only you want to use it only in Debug mode, Add a pod entry for LLDebugToolSwift to your Podfile `pod 'LLDebugToolSwift' , '~> 1.0.0' ,:configurations => ['Debug']`, Details also see [Wiki/Use in Debug environment](https://github.com/HDB-Li/LLDebugTool/wiki/Use-in-Debug-environment). If you want to specify the version, use as `pod 'LLDebugToolSwift' , '1.3.1' ,:configurations => ['Debug']`.
> 3. The recommended approach is to use multiple targets and only add `pod 'LLDebugToolSwift', '~> 1.0.0'` to Debug Target. This has the advantage of not contamiling the code in the Product environment and can be integrated into the App in the Archive Debug environment (if `:configurations => ['Debug']`, it can only run through XCode. It is not possible to Archive as an App).
> 4. Must be added in the Podfile **`use_frameworks!`**.
> 5. Install the pod(s) by running `pod install`. If you can't search `LLDebugToolSwift` or you can't find the newest release version, running `pod repo update` before `pod install`.
> 6. Include LLDebugTool wherever you need it with `import "LLDebugToolSwift`.

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

##### Objective - C

> 1. To integrate LLDebugTool into your Xcode project using Carthage, specify it in your `Cartfile`:
>
>     `github "LLDebugTool"`
> 
> 2. Run `carthage` to build the framework and drag the built `LLDebugTool.framework` into your Xcode project.

##### Swift

> 1. To integrate LLDebugToolSwift into your Xcode project using Carthage, specify it in your `Cartfile`:
>
>     `github "LLDebugToolSwift"`
> 
> 2. Run `carthage` to build the framework and drag the built `LLDebugToolSwift.framework` into your Xcode project.

### Source files

Alternatively you can directly add the source folder named LLDebugTool.  to your project.

##### Objective - C

> 1. Download the [latest code version](https://github.com/HDB-Li/LLDebugTool/archive/master.zip) or add the repository as a git submodule to your git-tracked project.
> 2. Open your project in Xcode, then drag and drop the source folder named `LLDebugTool`. When you are prompted to "Choose options for adding these files", be sure to check the "Copy items if needed".
> 3. Integrated [FMDB](https://github.com/ccgus/fmdb) to your project,FMDB is an Objective-C wrapper around SQLite.
> 4. Include LLDebugTool wherever you need it with `#import "LLDebug.h"` or you can write `#import "LLDebug.h"` in your .pch  in your .pch file.

##### Swift

> 1. Download the [LLDebugTool latest code version](https://github.com/HDB-Li/LLDebugTool/archive/master.zip) or add the repository as a git submodule to your git-tracked project.
> 2. Download the [LLDebugToolSwift latest code version](https://github.com/HDB-Li/LLDebugToolSwift/archive/master.zip) or add the repository as a git submodule to your git-tracked project.
> 3. Open your project in Xcode, then drag and drop the source folder named `LLDebugTool` and `LLDebugToolSwift`. When you are prompted to "Choose options for adding these files", be sure to check the "Copy items if needed".
> 4. Integrated [FMDB](https://github.com/ccgus/fmdb) to your project,FMDB is an Objective-C wrapper around SQLite.
> 5. Include LLDebugTool wherever you need it with `import LLDebugToolSwift"`.

## Usage

### Get Started

You need to start LLDebugTool at "application:(UIApplication * )application didFinishLaunchingWithOptions:(NSDictionary * )launchOptions", Otherwise you will lose some information. 

If you want to configure some parameters, must configure before "startWorking". More config details see [LLConfig.h](https://github.com/HDB-Li/LLDebugTool/blob/master/LLDebugTool/Config/LLConfig.h).

* `Quick Start`

In Objective-C

```Objective-C
#import "AppDelegate.h"
#import "LLDebug.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // The default color configuration is green background and white text color. 

    // Start working.
    [[LLDebugTool sharedTool] startWorking];
    
    // Write your project code here.
    return YES;
}
```

In Swift

```Swift
import LLDebugToolSwift

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ####################### Start LLDebugTool #######################//
        // Use this line to start working.
        LLDebugTool.shared().startWorking()
        
        // Write your project code here.
        
        return true
    }
```

* `Start With Custom Config`

In Objective-C

```Objective-C
#import "AppDelegate.h"
#import "LLDebug.h"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Start working with config.
    [[LLDebugTool sharedTool] startWorkingWithConfigBlock:^(LLConfig * _Nonnull config) {

        //####################### Color Style #######################//
        // Uncomment one of the following lines to change the color configuration.
        // config.colorStyle = LLConfigColorStyleSystem;
        // [config configBackgroundColor:[UIColor orangeColor] primaryColor:[UIColor whiteColor] statusBarStyle:UIStatusBarStyleDefault];

        //####################### User Identity #######################//
        // Use this line to tag user. More config please see "LLConfig.h".
        config.userIdentity = @"Miss L";

        //####################### Window Style #######################//
        // Uncomment one of the following lines to change the window style.
        // config.entryWindowStyle = LLConfigEntryWindowStyleNetBar;

    }];

    return YES;
}
```

In Swift

```Swift
import LLDebugToolSwift

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Start working with config.
        LLDebugTool.shared().startWorking { (config) in
            //####################### Color Style #######################//
            // Uncomment one of the following lines to change the color configuration.
            // config.colorStyle = .system
            // config.configBackgroundColor(.orange, textColor: .white, statusBarStyle: .default)
        
            //####################### User Identity #######################//
            // Use this line to tag user. More config please see "LLConfig.h".
            config.userIdentity = "Miss L";
        
            //####################### Window Style #######################//
            // Uncomment one of the following lines to change the window style.
            // config.windowStyle = .netBar
        
            //####################### Features #######################//
            // Uncomment this line to change the available features.
            // config.availables = .noneAppInfo
        }
        
        return true
    }
```

### Network Request

You don't need to do anything, just call the "startWorking" will monitoring most of network requests, including the use of NSURLSession, NSURLConnection and AFNetworking. If you find that you can't be monitored in some cases, please open an issue and tell me.

### Log

Print and save a log. More log macros details see [LLDebugToolMacros.h](https://github.com/HDB-Li/LLDebugTool/blob/master/LLDebugTool/DebugTool/LLDebugToolMacros.h).

* `Save Log`

In Objective-C

```Objective-C
#import "LLDebug.h"

- (void)testNormalLog {
    // Insert an LLog where you want to print.
    LLog(@"Message you want to save or print.");
}
```

In Swift

```Swift
import LLDebugToolSwift

    func testNormalLog() {
        // Insert an LLog where you want to print.
        LLog.log(message: "Message you want to save or print.")
    }

```

* `Save Log with event and level`

In Objective-C

```Objective-C
#import "LLDebug.h"

- (void)testEventErrorLog {
    // Insert an LLog_Error_Event where you want to print an event and level log.
    LLog_Error_Event(@"The event that you want to mark. such as bugA, taskB or processC.",@"Message you want to save or print.");
}
```

In Swift

```Swift
import LLDebugToolSwift

    func testEventErrorLog() {
        // Insert an LLog_Error_Event where you want to print an event and level log.
        LLog.errorLog(message: "Message you want to save or print.", event: "The event that you want to mark. such as bugA, taskB or processC.")
    }
```

### Crash

You don't need to do anything, just call the "startWorking" to intercept the crash, store crash information, cause and stack informations, and also store the network requests and log informations at the this time.

### AppInfo

LLDebugTool monitors the app's CPU, memory, and FPS. At the same time, you can also quickly check the various information of the app.

### Sandbox

LLDebugTool provides a quick way to view and manipulate sandbox, you can easily delete the files/folders inside the sandbox, or you can share files/folders by airdrop elsewhere. As long as apple supports this file format, you can preview the files directly in LLDebugTool.

### Screenshots

LLDebugTool provides a screenshot and allows for simple painting and marking that can be easily recorded during testing or while the UI designers debugs the App.

### Hierarchy

LLDebugTool provides a view structure tool for viewing elements' properties and information in non-debug mode.

### Magnifier

LLDebugTool provides a magnify tool for magnifying local uis and viewing color values at specified pixel.

### More Usage

* You can get more help by looking at the [Wiki](https://github.com/HDB-Li/LLDebugTool/wiki).
* You can download and run the [LLDebugToolDemo](https://github.com/HDB-Li/LLDebugTool/archive/master.zip) or [LLDebugToolSwiftDemo](https://github.com/HDB-Li/LLDebugToolSwift/archive/master.zip) to find more use with LLDebugTool. The demo is build under MacOS 10.14.6, XCode 10.2.1, iOS 12.1, CocoaPods 1.7.5. If there is any version compatibility problem, please let me know.

## Requirements

LLDebugTool works on iOS 8+ and requires ARC to build. It depends on the following Apple frameworks, which should already be included with most Xcode templates:

* `UIKit`

* `Foundation`

* `SystemConfiguration`

* `Photos`

* `QuickLook`

* `CoreTelephony`

## Architecture

* `LLDebug.h` 

    > Public header file. You can refer it to the pch file.

* `DebugTool`

    > `LLDebugTool` Used to start and stop LLDebugTool, you need to look at it.
    
    > `LLConfig` Used for the custom color , size , identification and other information. If you want to configure anything, you need to focus on this file.
    
    > `LLDebugToolMacros.h` Quick macro definition file.

* `Components`
  
  - `Network` Use to monitoring network request.
  - `Log` Used to quick print and save log.
  - `Crash` Used to collect crash information when an App crashes.
  - `AppInfo` Use to monitoring app's properties.
  - `Sandbox` Used to view and operate sandbox files.
  - `Screenshot` Used to process and display screenshots.
  - `Hierarchy` Used to process and present the view structure.
  - `Magnifier` Used for magnifying glass function.
  
## Communication

- If you **need help**, open an issue.
- If you'd like to **ask a general question**, open an issue.
- If you **found a bug**, _and can provide steps to reliably reproduce it_, open an issue.
- If you **have a feature request**, open an issue.
- If you **find anything wrong or anything dislike**, open an issue.
- If you **have some good ideas or some requests**, send mail(llworkinggroup1992@gmail.com) to me.
- If you **want to contribute**, submit a pull request.

## Contact

- Send email to [llworkinggroup1992@gmail.com](llworkinggroup1992@gmail.com)
- Send message in twitter [@HdbLi](https://twitter.com/HdbLi)
- Send message in [JianShu](https://www.jianshu.com/u/a3c82fae85be)

## Change-log

A brief summary of each LLDebugTool release can be found in the [CHANGELOG](CHANGELOG.md). 

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).
