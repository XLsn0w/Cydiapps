//
//  ViewController.h
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/25.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Extension.h"

@interface initVCWindowController : NSWindowController<NSWindowDelegate>
@end

@interface SetupViewController : NSViewController

    @property (weak) IBOutlet NSTextField *sysStatusLabel;
    @property (weak) IBOutlet NSProgressIndicator *setupMacProgress;
    @property (weak) IBOutlet NSProgressIndicator *setupiOSProgress;
    @property (weak) IBOutlet NSTextField *rightsLabel;
    @property (weak) IBOutlet NSTextField *appListField;
    @property (weak) IBOutlet NSTextField *secondLabel;
    @property (weak) IBOutlet NSProgressIndicator *injectRevealProgress;
    @property (unsafe_unretained) IBOutlet NSTextView *realLogWindow;
    


@end


