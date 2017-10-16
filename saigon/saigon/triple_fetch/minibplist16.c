#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "minibplist16.h"

/*
NSXPC uses the undocumented bplist16 format

this is a very very minimal implementation, just enough to get to the function I want!

header: "bplist16"

then a list of values; everything is packed, no alignment

variable length types are encoded using two nibbles of a byte:

0xAB where A denotes the type and B the length.

type nibbles are:
  1 : integer
  7 : ascii string
  6 : utf16 string
  e : null
  d : dictionary

length nibbles: if the length nibble is < 0xf, then it is the length of the serialized type in
  type defined units (for ascii string it's the number of bytes, for utf16 string it's the number
  of utf16 characters (so half the number of bytes))

  if the length nibble is 0xf then the type byte is followed by an integer object whose value
  defines the length of this type. remember that integer itself is variable-length!

dictionary type:
  0xd0 <uint64>

  the dictionary type byte is followed by a uint64. This uint64 is the offset (from the start of the 
  bplist16) of the *last* byte of all values which should be considered to be in this dictionary.
  That is, if this byte is 0x20 then the byte at address base+0x21 is the first byte of a value which
  is outside of this dictionary)

  inside the dictionary the types alternate key,value,key,value...

null:
  0xe0

  used as a "generic key" for a dictionary

format for invoking methods on remote NSXPC objects:

{ "inv" : 
    { "$class" : ascii_string("NSInvocation"), // the class of this serialized object
      "ty" : ascii_string("v@:@@"),            // type descriptor for the arguments
      "se" : ascii_string("foo:bar:"),         // selector to be invoked
      null : arg_0,                            // these unnamed keys can be accessed as generic keys (I think using $0,$1 syntax)
      null : arg_1
    }
}

arg_0, arg_1 are then the serialized representations for those arguments (eg ascii string for ascii NSString,
integer for integer NSNumber).

actually invoking a method:

lookup the service with launchd and get a service port

do an XPC connection handshake with a w00t message to connect a client and reply port

send the following message on that connected client xpc port:

(this is XPC serialized, not bplist16):

{ "root" : xpc_data(bplist16 serialized NSInvocation),
  "proxynum": uint64(1) }
*/


static void
ERROR(
  char* msg)
{
  printf("%s\n", msg);
  exit(EXIT_FAILURE);
}


#define OBP16_TYPE_ASCII_STRING 0
#define OBP16_TYPE_INTEGER 1
#define OBP16_TYPE_NULL 2
#define OBP16_TYPE_DICTIONARY 3

typedef void (*obp16_free)(obp16_object_t);
typedef size_t (*obp16_serialized_size)(obp16_object_t);
typedef void (*obp16_serialize_to_buffer)(obp16_object_t, void*, size_t);

struct obp16_type_descriptor {
  obp16_free free;
  obp16_serialized_size serialized_size;
  obp16_serialize_to_buffer serialize_to_buffer;
};

static struct obp16_type_descriptor*
obp16_get_type_descriptor(
  obp16_object_t obj);

void
obp16_object_free(
  obp16_object_t obj)
{
  obp16_get_type_descriptor(obj)->free(obj);
}

size_t
obp16_object_serialized_size(
  obp16_object_t obj)
{
  return obp16_get_type_descriptor(obj)->serialized_size(obj);
}

void
obp16_object_serialize_to_buffer(
  obp16_object_t obj,
  void* buffer,
  size_t offset)
{
  return obp16_get_type_descriptor(obj)->serialize_to_buffer(obj, buffer, offset);
}


/* integer type */

typedef struct _obp16_integer {
  uint32_t type;
  size_t length;
  uint64_t value;
}* obp16_integer_t;

// how many bytes long is this value?
static size_t
byte_count_for_u64(
  uint64_t value)
{
  if (value == 0) {
    return 1; //always one byte for 0?
  }
  uint8_t* bytes = (uint8_t*)&value;
  size_t count = 0;
  for (int i = 0; i < 7; i++) {
    if (bytes[i] != 0) {
      count = i+1;
    }
  }
  return count;
}

obp16_object_t
obp16_integer_alloc(
  uint64_t value)
{
  obp16_integer_t integer = malloc(sizeof(struct _obp16_integer));
  integer->type = OBP16_TYPE_INTEGER;
  integer->length = byte_count_for_u64(value);
  integer->value = value;
  return (obp16_object_t)integer;
}

static size_t
obp16_integer_serialized_size(
  obp16_object_t obj)
{
  obp16_integer_t integer = (obp16_integer_t)obj;
  return 1 + integer->length;
}

static void
obp16_integer_serialize_to_buffer(
  obp16_object_t obj,
  void* buffer,
  size_t offset)
{
  obp16_integer_t integer = (obp16_integer_t)obj;
  uint8_t tag = 0x10;
  tag |= integer->length;
  uint8_t* buf = (uint8_t*)buffer;
  *buf = tag;
  buf += 1;
  memcpy(buf, &integer->value, integer->length);
}

static void
obp16_integer_free(
  obp16_object_t obj)
{
  free(obj);
}

struct obp16_type_descriptor obp16_integer_type_descriptor = {
  .free = obp16_integer_free,
  .serialized_size = obp16_integer_serialized_size,
  .serialize_to_buffer = obp16_integer_serialize_to_buffer,
};

/* null type */

typedef struct _obp16_null {
  uint32_t type;
}* obp16_null_t;

obp16_object_t
obp16_null_alloc()
{
  obp16_null_t null = malloc(sizeof(struct _obp16_null));
  null->type = OBP16_TYPE_NULL;
  return (obp16_object_t)null;
}

static size_t
obp16_null_serialized_size(
  obp16_object_t obj)
{
  return 1;
}

static void
obp16_null_serialize_to_buffer(
  obp16_object_t obj,
  void* buffer,
  size_t offset)
{
  uint8_t* bytes = buffer;
  *bytes = 0xe0;
}

static void
obp16_null_free(
  obp16_object_t obj)
{
  free(obj);
}

struct obp16_type_descriptor obp16_null_type_descriptor = {
  .free = obp16_null_free,
  .serialized_size = obp16_null_serialized_size,
  .serialize_to_buffer = obp16_null_serialize_to_buffer,
};


/* ascii string type */

typedef struct _obp16_ascii_string {
  uint32_t type;
  char* bytes;
  size_t length;
  obp16_object_t packed_length;
}* obp16_ascii_string_t;

obp16_object_t
obp16_ascii_string_alloc(
  char* bytes,
  size_t length) {
  obp16_ascii_string_t str = malloc(sizeof(struct _obp16_ascii_string));
  str->type = OBP16_TYPE_ASCII_STRING;
  str->bytes = malloc(length);
  memcpy(str->bytes, bytes, length);
  
  str->length = length;
  str->packed_length = obp16_integer_alloc(length);

  return (obp16_object_t) str;
}

obp16_object_t
obp16_ascii_string_alloc_with_cstring(
  char* str)
{
  return obp16_ascii_string_alloc(str, strlen(str)+1);
}

size_t obp16_ascii_string_serialized_size(
  obp16_object_t obj) {
  obp16_ascii_string_t str = (obp16_ascii_string_t)obj;
  if (str->length < 0xf) {
    return 1 + str->length;
  }

  // otherwise need an integer
  return 1 + str->length + obp16_integer_serialized_size(str->packed_length);
}

static void
obp16_ascii_string_serialize_to_buffer(
  obp16_object_t obj,
  void* buffer,
  size_t offset)
{
  obp16_ascii_string_t str = (obp16_ascii_string_t)obj;
  uint8_t tag = 0x70;

  uint8_t* bytes = buffer;
  if (str->length < 0xf) {
    tag |= str->length;
    *bytes = tag;
    bytes++;
  } else {
    tag |= 0xf;
    *bytes = tag;
    bytes++;
    // append the integer representation of the size
    obp16_integer_serialize_to_buffer(str->packed_length, bytes, offset+1);
    bytes += obp16_object_serialized_size(str->packed_length);
  }

  memcpy(bytes, str->bytes, str->length);
}

static void
obp16_ascii_string_free(
  obp16_object_t obj)
{
  obp16_ascii_string_t str = (obp16_ascii_string_t)obj;
  obp16_object_free(str->packed_length);
  free(str->bytes);
  free(str);
}

struct obp16_type_descriptor obp16_ascii_string_type_descriptor = {
  .free = obp16_ascii_string_free,
  .serialized_size = obp16_ascii_string_serialized_size,
  .serialize_to_buffer = obp16_ascii_string_serialize_to_buffer,
};


/* dictionary */

typedef struct _obp16_dictionary {
  uint32_t type;
  size_t serialized_size;
  size_t count;
  obp16_object_t* keys;
  obp16_object_t* values;
}* obp16_dictionary_t;

obp16_object_t
obp16_dictionary_alloc()
{
  obp16_dictionary_t dict = malloc(sizeof(struct _obp16_dictionary));
  dict->type = OBP16_TYPE_DICTIONARY;
  dict->serialized_size = 0;
  dict->count = 0;
  dict->keys = NULL;
  dict->values = NULL;
  return (obp16_object_t)dict;
}

void
obp16_dictionary_append(
  obp16_object_t obj,
  obp16_object_t key,
  obp16_object_t value)
{
  obp16_dictionary_t dict = (obp16_dictionary_t)obj;

  size_t new_count = dict->count + 1;
  dict->keys   = realloc(dict->keys,   new_count*sizeof(obp16_object_t));
  dict->values = realloc(dict->values, new_count*sizeof(obp16_object_t));

  dict->keys[new_count - 1] = key;
  dict->values[new_count - 1] = value;

  dict->count = new_count;
}

static size_t
obp16_dictionary_serialized_size(
  obp16_object_t obj)
{
  obp16_dictionary_t dict = (obp16_dictionary_t)obj;

  if (dict->serialized_size != 0) {
    return dict->serialized_size;
  }

  size_t total = 9; // dictionary tag + offset
  for (size_t i = 0; i < dict->count; i++) {
    total += obp16_object_serialized_size(dict->keys[i]);
    total += obp16_object_serialized_size(dict->values[i]);
  }

  dict->serialized_size = total;

  return total;
}

// (serializer needs to know start offset
static void
obp16_dictionary_serialize_to_buffer(
  obp16_object_t obj,
  void* buffer,  // serialize directly to here
  size_t offset) // offset is just how far we are from the beginning of the overall serialized structure
{
  obp16_dictionary_t dict = (obp16_dictionary_t)obj;

  uint8_t* bytes = buffer;
  *bytes = 0xd0; // dictionary start tag
  uint64_t* end_offset_ptr = (uint64_t*)(bytes+1);
  *end_offset_ptr = offset + obp16_object_serialized_size(obj) - 1;
  bytes = (uint8_t*) (end_offset_ptr+1);

  offset += (1 + 8); // byte type + uint64 global offset of end

  for (size_t i = 0; i < dict->count; i++) {
    obp16_object_serialize_to_buffer(dict->keys[i], (void*)bytes, offset);
    offset += obp16_object_serialized_size(dict->keys[i]);
    bytes  += obp16_object_serialized_size(dict->keys[i]);

    obp16_object_serialize_to_buffer(dict->values[i], (void*)bytes, offset);
    offset += obp16_object_serialized_size(dict->values[i]);
    bytes  += obp16_object_serialized_size(dict->values[i]);
  }
}

static void
obp16_dictionary_free(
  obp16_object_t obj)
{
  obp16_dictionary_t dict = (obp16_dictionary_t)obj;
  for (size_t i = 0; i < dict->count; i++) {
    obp16_object_free(dict->keys[i]);
    obp16_object_free(dict->values[i]);
  }
  free(dict);
}

struct obp16_type_descriptor obp16_dictionary_type_descriptor = {
  .free = obp16_dictionary_free,
  .serialized_size = obp16_dictionary_serialized_size,
  .serialize_to_buffer = obp16_dictionary_serialize_to_buffer,
};

size_t
obp16_full_serialized_size(
  obp16_object_t obj)
{
  return 8 + obp16_object_serialized_size(obj);
}

void
obp16_full_serialize_to_buffer(
  obp16_object_t obj,
  void* buffer)
{
  uint8_t* bytes = buffer;
  memcpy(bytes, "bplist16", 8);
  obp16_object_serialize_to_buffer(obj, bytes+8, 8);
}

void* obp16_full_serialize(
  obp16_object_t obj,
  size_t* out_size)
{
  size_t size = obp16_full_serialized_size(obj);
  void* buffer = malloc(size);

  obp16_full_serialize_to_buffer(obj, buffer);
  *out_size = size;

  return buffer;
}

static struct obp16_type_descriptor*
obp16_get_type_descriptor(
  obp16_object_t obj)
{
  switch(obj->type) {
    case OBP16_TYPE_ASCII_STRING:
      return &obp16_ascii_string_type_descriptor;
    case OBP16_TYPE_INTEGER:
      return &obp16_integer_type_descriptor;
    case OBP16_TYPE_NULL:
      return &obp16_null_type_descriptor;
    case OBP16_TYPE_DICTIONARY:
      return &obp16_dictionary_type_descriptor;
    default:
      ERROR("unrecognised type");
  }
  return NULL;
}


