#ifndef PAYLOADS_COMMON_H
#define PAYLOADS_COMMON_H

#include <inttypes.h>

int file_exist(const char *filename);

#define JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT 2
#define JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT_AFTER_DELAY 4
#define JAILBREAKD_COMMAND_ENTITLE_AND_SIGCONT_FROM_XPCPROXY 5
#define JAILBREAKD_COMMAND_FIXUP_EXECUTABLE 9
#define JAILBREAKD_COMMAND_UNSANDBOX 7

void calljailbreakd(pid_t PID, uint8_t command);
void closejailbreakfd(void);
void calljailbreakdforexec(char *exec);

struct __attribute__((__packed__)) JAILBREAKD_FIXUP_EXECUTABLE {
    uint8_t Command;
    char exec[1024];
};

#endif  // PAYLOADS_COMMON_H

