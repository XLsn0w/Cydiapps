//
//  CommandLineMain.h
//  Saily
//
//  Created by Lakr Aream on 2019/7/26.
//  Copyright © 2019 Lakr Aream. All rights reserved.
//

#ifndef CommandLineMain_h
#define CommandLineMain_h

#import <Foundation/Foundation.h>

#include "Operator.h"
#include "Linstener.h"
#include "common.h"

#include <dlfcn.h>

int command_line_main (int, const char *[]);
void someChimeraSetup(void);

#endif /* CommandLineMain_h */
