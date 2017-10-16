#include "sploit.h"
#include "Utilities.h"
#include "ziva_main.h"
#include "unjail.h"

// Utilities
//void kernel_panic();

// Triple Fetch
mach_port_t do_exploit();
int prepare_amfid(mach_port_t tp);

// ziVA
int ziva_go();

// extra_recipe
int go_extra_recipe(void);

