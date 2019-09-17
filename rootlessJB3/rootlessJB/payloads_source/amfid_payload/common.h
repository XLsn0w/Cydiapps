#ifndef PAYLOADS_COMMON_H
#define PAYLOADS_COMMON_H

#include <inttypes.h>

#define JAILBREAKD_COMMAND_FIXUP_DYLIB 8

void calljailbreakd(char *dylib);
void closejailbreakfd(void);

#endif  // PAYLOADS_COMMON_H

#define AMFID_PAYLOAD_DEBUG 1
#ifndef AMFID_PAYLOAD_DEBUG
#define printf(str, ...)
#define NSLog(str, ...)
#endif
