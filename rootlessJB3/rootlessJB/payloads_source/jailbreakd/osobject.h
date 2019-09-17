#define OSDictionary_ItemCount(dict) rk32(dict+20)
#define OSDictionary_ItemBuffer(dict) rk64(dict+32)
#define OSDictionary_ItemKey(buffer, idx) rk64(buffer+16*idx)
#define OSDictionary_ItemValue(buffer, idx) rk64(buffer+16*idx+8)
#define OSString_CStringPtr(str) rk64(str + 0x10)
#define OSArray_ItemCount(arr) rk32(arr+0x14)
#define OSArray_ItemBuffer(arr) rk64(arr+32)

// see osobject.c for info

int OSDictionary_SetItem(uint64_t dict, const char *key, uint64_t val);
uint64_t OSDictionary_GetItem(uint64_t dict, const char *key);
int OSDictionary_Merge(uint64_t dict, uint64_t aDict);
void OSArray_RemoveObject(uint64_t array, unsigned int idx);
uint64_t OSArray_GetObject(uint64_t array, unsigned int idx);
int OSArray_Merge(uint64_t array, uint64_t aArray);
uint64_t OSUnserializeXML(const char* buffer);

void OSObject_Release(uint64_t osobject);
void OSObject_Retain(uint64_t osobject);
uint32_t OSObject_GetRetainCount(uint64_t osobject);

unsigned int OSString_GetLength(uint64_t osstring);
char *OSString_CopyString(uint64_t osstring);
