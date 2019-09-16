//
//  Operator.h
//  Saily
//
//  Created by Lakr Aream on 2019/7/21.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

#ifndef Operator_h
#define Operator_h

#import <Foundation/Foundation.h>
#include <spawn.h>
#include <mach/mach.h>
#include <dlfcn.h>

void setIsRootless(void);
void setAppPath(NSString *string);
void run_cmd(char *cmd);
NSString *readAppPath(void);
void redirectConsoleLogToDocumentFolder(void);
void redirectConsoleLogToVarRoot(void);
int read_status(void);
void outDaemonStatus(void);
void fix_permission(void);
void executeScriptFromApplication(void);
void executeRespring(void);
void requiredBackUpDocumentFiles(void);
void requiredRestoreBackup(void);
void requiredRestoreCheck(void);
void requiredImportAPT(void);
void requiredUnlockDPKG(void);
void requiredUnlockNetwork(void);
void requiredUICACHE(void);
void requiredEXTRACT(void);
void requiredRTLPATCH(void);
void requiredRTLINSTALL(void);

#endif /* Operator_h */
