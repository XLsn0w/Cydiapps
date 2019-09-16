#ifndef _KERN_FUNCS_H_
#define _KERN_FUNCS_H_

#define SETOFFSET(offset, val) (offs.offset = val)
#define GETOFFSET(offset) offs.offset

typedef struct {
    uint64_t trustcache;
    uint64_t kernel_task;
    uint64_t pmap_load_trust_cache;
    uint64_t paciza_pointer__l2tp_domain_module_start;
    uint64_t paciza_pointer__l2tp_domain_module_stop;
    uint64_t l2tp_domain_inited;
    uint64_t sysctl__net_ppp_l2tp;
    uint64_t sysctl_unregister_oid;
    uint64_t mov_x0_x4__br_x5;
    uint64_t mov_x9_x0__br_x1;
    uint64_t mov_x10_x3__br_x6;
    uint64_t kernel_forge_pacia_gadget;
    uint64_t kernel_forge_pacda_gadget;
    uint64_t IOUserClient__vtable;
    uint64_t IORegistryEntry__getRegistryEntryID;
    uint64_t pmap_loaded_trust_caches;
} offsets_t;

extern offsets_t offs;
extern uint64_t kernel_base;
extern uint64_t kernel_slide;

void set_tfp0(mach_port_t port);
void wk32(uint64_t kaddr, uint32_t val);
void wk64(uint64_t kaddr, uint64_t val);
uint32_t rk32(uint64_t kaddr);
uint64_t rk64(uint64_t kaddr);
uint64_t kmem_alloc(uint64_t size);
size_t kread(uint64_t where, void *p, size_t size);
size_t kwrite(uint64_t where, const void *p, size_t size);
uint64_t task_self_addr(void);
extern int (*pmap_load_trust_cache)(uint64_t kernel_trust, size_t length);
int _pmap_load_trust_cache(uint64_t kernel_trust, size_t length);

#endif // _KERN_FUNCS_H_
