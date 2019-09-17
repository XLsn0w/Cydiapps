
// see https://stek29.rocks/2018/01/26/sandbox.html

void extension_add(uint64_t ext, uint64_t sb, const char* desc);
uint64_t extension_create_file(const char* path, uint64_t nextptr);
int has_file_extension(uint64_t sb, const char* path);
