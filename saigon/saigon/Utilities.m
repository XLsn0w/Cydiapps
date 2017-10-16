//
//  Utilities.m
//  saïgon
//
//  Created by Abraham Masri on 8/18/17.
//

#import "Utilities.h"
#include <string.h>
#import "IOKitLib.h"
#include <sys/utsname.h>

// Used accross the exploits
mach_port_t privileged_port = MACH_PORT_NULL;
task_t launchd_task = MACH_PORT_NULL;
mach_port_name_t self_port_name = MACH_PORT_NULL;

int ami_jailbroken () {
    
    struct utsname u = { 0 };
    uname(&u);
    
    // Check if 'Marijuan' in the version (aka. we're jailbroken)
    return (strstr(u.version, "Marijuan") != NULL);
}

// Sets the ports
void set_privileged_port(mach_port_t _privileged_port, task_t _launchd_task) {
    privileged_port = _privileged_port;
    launchd_task = _launchd_task;
    
}

// returns the priveleged port
mach_port_t get_privileged_port() {
    return privileged_port;
}

// returns the launchd's task
task_t get_launchd_task() {
    return launchd_task;
}

// Sets the port name
void set_self_port_name(mach_port_name_t pt_name) {
    self_port_name = pt_name;
}

// returns launchd's port name
mach_port_name_t get_self_port_name() {
    return self_port_name;
}

// Works only on i7, otherwise, exits - thanks to @JonathanSeals
void kernel_panic () {
    @autoreleasepool {
        uint64_t input[1] = {0x0};
        
        io_iterator_t iterator;
        IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching("AppleHIDTransportHIDDevice"), &iterator);
        
        io_connect_t c = 0;
        IOServiceOpen(IOIteratorNext(iterator), mach_task_self(), 0, &c);
        
        /* bye bye kernel */
        IOConnectCallMethod(c, 13, input, 3, 0, 0, 0, 0, 0, 0);
        
        // no? exit then
        exit(0);
    }
}


static char encoding_table[] = {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3',
    '4', '5', '6', '7', '8', '9', '+', '/'};
static char *decoding_table = NULL;
static int mod_table[] = {0, 2, 1};

void build_decoding_table() {
    
    decoding_table = malloc(256);
    
    for (int i = 0; i < 64; i++)
        decoding_table[(unsigned char) encoding_table[i]] = i;
}


void base64_cleanup() {
    free(decoding_table);
}


char *base64_encode(const unsigned char *data,
                    size_t input_length,
                    size_t *output_length) {
    
    *output_length = 4 * ((input_length + 2) / 3);
    
    char *encoded_data = malloc(*output_length);
    if (encoded_data == NULL) return NULL;
    
    for (uint64_t i = 0, j = 0; i < input_length;) {
        
        uint32_t octet_a = i < input_length ? (unsigned char)data[i++] : 0;
        uint32_t octet_b = i < input_length ? (unsigned char)data[i++] : 0;
        uint32_t octet_c = i < input_length ? (unsigned char)data[i++] : 0;
        
        uint32_t triple = (octet_a << 0x10) + (octet_b << 0x08) + octet_c;
        
        encoded_data[j++] = encoding_table[(triple >> 3 * 6) & 0x3F];
        encoded_data[j++] = encoding_table[(triple >> 2 * 6) & 0x3F];
        encoded_data[j++] = encoding_table[(triple >> 1 * 6) & 0x3F];
        encoded_data[j++] = encoding_table[(triple >> 0 * 6) & 0x3F];
    }
    
    for (int i = 0; i < mod_table[input_length % 3]; i++)
        encoded_data[*output_length - 1 - i] = '=';
    
    return encoded_data;
}


unsigned char *base64_decode(const char *data,
                             size_t input_length,
                             size_t *output_length) {
    
    if (decoding_table == NULL) build_decoding_table();
    
    if (input_length % 4 != 0) return NULL;
    
    *output_length = input_length / 4 * 3;
    if (data[input_length - 1] == '=') (*output_length)--;
    if (data[input_length - 2] == '=') (*output_length)--;
    
    unsigned char *decoded_data = malloc(*output_length);
    if (decoded_data == NULL) return NULL;
    
    for (uint64_t i = 0, j = 0; i < input_length;) {
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wchar-subscripts"
        uint32_t sextet_a = data[i] == '=' ? 0 & i++ : decoding_table[data[i++]];
        uint32_t sextet_b = data[i] == '=' ? 0 & i++ : decoding_table[data[i++]];
        uint32_t sextet_c = data[i] == '=' ? 0 & i++ : decoding_table[data[i++]];
        uint32_t sextet_d = data[i] == '=' ? 0 & i++ : decoding_table[data[i++]];
#pragma clang diagnostic pop
        
        uint32_t triple = (sextet_a << 3 * 6)
        + (sextet_b << 2 * 6)
        + (sextet_c << 1 * 6)
        + (sextet_d << 0 * 6);
        
        if (j < *output_length) decoded_data[j++] = (triple >> 2 * 8) & 0xFF;
        if (j < *output_length) decoded_data[j++] = (triple >> 1 * 8) & 0xFF;
        if (j < *output_length) decoded_data[j++] = (triple >> 0 * 8) & 0xFF;
    }
    
    return decoded_data;
}


/*
 * Function name: 	utils_get_base64_payload
 * Description:		Encodes the buffer to base64.
 * Returns:			char * as the encoded buffer, or NULL on failure.
 */

char * utils_get_base64_payload(void * buffer, size_t length) {
    
    size_t output_size = 0;
    char * result = NULL;
    build_decoding_table();
    
    result = base64_encode(buffer, length, &output_size);
    base64_cleanup();
    
    return result;
}

