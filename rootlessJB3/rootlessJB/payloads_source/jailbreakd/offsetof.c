
unsigned offsetof_p_pid = 0x60;               // proc_t::p_pid
unsigned offsetof_task = 0x10;                // proc_t::task
unsigned offsetof_p_uid = 0x28;               // proc_t::p_uid
unsigned offsetof_p_gid = 0x2c;               // proc_t::p_uid
unsigned offsetof_p_ruid = 0x30;              // proc_t::p_uid
unsigned offsetof_p_rgid = 0x34;              // proc_t::p_uid
unsigned offsetof_p_ucred = 0xf8;            // proc_t::p_ucred
unsigned offsetof_p_csflags = 0x290;          // proc_t::p_csflags
unsigned offsetof_itk_self = 0xD8;            // task_t::itk_self (convert_task_to_port)
unsigned offsetof_itk_sself = 0xE8;           // task_t::itk_sself (task_get_special_port)
unsigned offsetof_itk_bootstrap = 0x2b8;      // task_t::itk_bootstrap (task_get_special_port)
unsigned offsetof_itk_space = 0x300;          // task_t::itk_space
unsigned offsetof_ip_mscount = 0x9C;          // ipc_port_t::ip_mscount (ipc_port_make_send)
unsigned offsetof_ip_srights = 0xA0;          // ipc_port_t::ip_srights (ipc_port_make_send)
unsigned offsetof_ip_kobject = 0x68;          // ipc_port_t::ip_kobject
unsigned offsetof_p_textvp = 0x230;           // proc_t::p_textvp
unsigned offsetof_p_textoff = 0x238;          // proc_t::p_textoff
unsigned offsetof_p_cputype = 0x2a8;          // proc_t::p_cputype
unsigned offsetof_p_cpu_subtype = 0x2ac;      // proc_t::p_cpu_subtype
unsigned offsetof_special = 2 * sizeof(long); // host::special
unsigned offsetof_ipc_space_is_table = 0x20;  // ipc_space::is_table?..

unsigned offsetof_ucred_cr_uid = 0x18;        // ucred::cr_uid
unsigned offsetof_ucred_cr_ruid = 0x1c;       // ucred::cr_ruid
unsigned offsetof_ucred_cr_svuid = 0x20;      // ucred::cr_svuid
unsigned offsetof_ucred_cr_ngroups = 0x24;    // ucred::cr_ngroups
unsigned offsetof_ucred_cr_groups = 0x28;     // ucred::cr_groups
unsigned offsetof_ucred_cr_rgid = 0x68;       // ucred::cr_rgid
unsigned offsetof_ucred_cr_svgid = 0x6c;      // ucred::cr_svgid

unsigned offsetof_v_type = 0x70;              // vnode::v_type
unsigned offsetof_v_id = 0x74;                // vnode::v_id
unsigned offsetof_v_ubcinfo = 0x78;           // vnode::v_ubcinfo
unsigned offsetof_v_flags = 0x54;             // vnode::v_flags

unsigned offsetof_ubcinfo_csblobs = 0x50;     // ubc_info::csblobs

unsigned offsetof_csb_cputype = 0x8;          // cs_blob::csb_cputype
unsigned offsetof_csb_flags = 0x12;           // cs_blob::csb_flags
unsigned offsetof_csb_base_offset = 0x16;     // cs_blob::csb_base_offset
unsigned offsetof_csb_entitlements_offset = 0x98; // cs_blob::csb_entitlements
unsigned offsetof_csb_signer_type = 0xA0;     // cs_blob::csb_signer_type
unsigned offsetof_csb_platform_binary = 0xA8; // cs_blob::csb_platform_binary
unsigned offsetof_csb_platform_path = 0xAc;   // cs_blob::csb_platform_path

unsigned offsetof_t_flags = 0x390; // task::t_flags
