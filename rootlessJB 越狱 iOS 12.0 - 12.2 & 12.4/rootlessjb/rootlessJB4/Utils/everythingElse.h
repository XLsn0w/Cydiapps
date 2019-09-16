//
//  everythingElse.h
//  rootlessJB4
//
//  Created by Brandon Plank on 8/28/19.
//  Copyright © 2019 Brandon Plank. All rights reserved.
//

#ifndef everythingElse_h
#define everythingElse_h
//someone used a wrong offset lol lmao
#include <stdio.h>
#include <stdbool.h>

extern uint64_t task_self_addr_cache;
extern uint64_t selfproc_cached;
extern mach_port_t tfp0;
extern uint64_t kernel_slide;
extern uint64_t kernel_base;
extern uint64_t task_self_addr_cache;
extern uint64_t selfproc_cached;

bool runExploit(void);
bool escapeSandbox(void);

#endif /* everythingElse_h */

//
