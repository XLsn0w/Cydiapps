//
//  Extension.h
//  IPAForce
//
//  Created by Lakr Sakura on 2018/9/26.
//  Copyright © 2018 Lakr Sakura. All rights reserved.
//

#ifndef Extension_h
#define Extension_h


#endif /* Extension_h */


#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>
#import <NMSSH/NMSSH.h>

void startiProxy(void);
NSString *getListOfApps(void);
NSString *checkSystemStatus(void);
int execCommandFromURL(NSURL *where);
BOOL ifOpenShellWorking(NSString *whereToCheck, int portNumber);
NSString *getOutputOfThisCommand(NSString *command, double timeOut);
NSString *replaceCharacterAtInextWithLenthAndWhat(NSString* whoTo, int whereToHave, int howlong, NSString* wahtTo);
