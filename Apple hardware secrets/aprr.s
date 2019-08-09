//#define APRR0_MASK 0xffffffffffffffff
//#define APRR1_MASK 0xffffffffffffffff
//#define APRR0_MASK 0xfff0fff0fff0fff0
//#define APRR1_MASK 0xfff0fff0fff0fff0
#define APRR0_MASK 0xfffff3f3fffff3f3
#define APRR1_MASK 0xfffff3f3fffff3f3
//#define APRR0_MASK 0xfff0fff0fff0fff0
//#define APRR1_MASK 0xffffffffffffffff
//#define APRR0_MASK 0xfff5fff5fff5fff5
//#define APRR1_MASK 0xfff5fff5fff5fff5
//#define APRR0_MASK 0xf3f5f3f5f3f5f3f5
//#define APRR1_MASK 0xf3f5f3f5f3f5f3f5

#define vmsa_lockdown_el1   s3_4_c15_c1_2
#define aprr0_el1           s3_4_c15_c2_0
#define aprr1_el1           s3_4_c15_c2_1
#define ktrr_lock_el1       s3_4_c15_c2_2
#define ktrr_lower_el1      s3_4_c15_c2_3
#define ktrr_upper_el1      s3_4_c15_c2_4
#define ktrr_unknown        s3_4_c15_c2_5
#define aprr_mask_en_el1    s3_4_c15_c2_6
#define aprr_mask_el0       s3_4_c15_c2_7

#define PAGE_BITS           14
#define PAGE_SIZE           (1 << PAGE_BITS)
#define PAGE_IDX_BITS       (PAGE_BITS - 3)
#define PAGE_IDX_MASK       ((1 << PAGE_IDX_BITS) - 1)

#define TCR_BITS            (PAGE_BITS + PAGE_IDX_BITS + PAGE_IDX_BITS)
#define TCR_SIZE            (1 << TCR_BITS)

#define TTE_VALID           0x3
#define TTE_NS              0x20
#define TTE_SH_OSH          0x200
#define TTE_AF              0x400

#define AP_UXN              0x1
#define AP_PXN              0x2
#define AP_RWNA             0x0
#define AP_RWRW             0x4
#define AP_RONA             0x8
#define AP_RORO             0xc

#define SCTLR_NOSPAN        0x00800000
#define SCTLR_WXN           0x00080000
#define SCTLR_MMU           0x00000001

// ==================== ==================== TESTING ==================== ====================
//
// Results are written to Lresult, which should have offset 0x10.
// Each FUZZ_REG writes 0x30 bytes, containing pairs of (flag, value)
// for the target register in 3 states: reset, max and min.
// The flag is:
//  0 if not recorded
//  1 if successfully read & recorded
// NN if we hit an exception vector, in which case value will be invalid

.macro TEST_REG_VAL
    mov x18, 0x1
    mov x17, $1
    msr $0, x17
    isb
    mrs x17, $0
    stp x18, x17, [x16], 0x10
.endmacro

.macro TEST_REG
    TEST_REG_VAL $0, 0xffffffffffffffff
    TEST_REG_VAL $0, 0x0
.endmacro

.macro TEST_VMSA
    TEST_REG ttbr0_el1
    TEST_REG ttbr1_el1
    TEST_REG tcr_el1
    mrs x8, vbar_el1
    TEST_REG vbar_el1
    msr vbar_el1, x8
    TEST_REG_VAL sctlr_el1, 0xfffffffffffffffe
    TEST_REG_VAL sctlr_el1, 0x0
.endmacro

.macro FUZZ_REG
    // Reset value
    mov x18, 0x1
    mov x17, 0x0
    mrs x17, $0
    stp x18, x17, [x16], 0x10

    TEST_REG $0
.endmacro

.text
.globl _entry

.align 14
Lentry:
_entry:
    b Lstart

.align 2
Lflag:
    .4byte 0x1

.align 2
Lpgnum:
    .4byte 0x0

.align 4
Lresult:
    .space 0x13ff0

.align 14
Lstart:
    msr far_el1, x18
    ldr w18, Lflag
    cbnz w18, Lreal
    mrs x18, far_el1
    ret

Lreal:
    // x0-x15 args/local
    // x16 result ptr
    // x17 scratch
    // x18 vector flag
    // x19 vector scratch
    // x20 callee saved

    adr x17, Lflag
    str wzr, [x17]

    adr x17, Lvector
    msr vbar_el1, x17

    adr x16, Lresult

    /*FUZZ_REG aprr0_el1                      // 0x010
    FUZZ_REG aprr1_el1                      // 0x040
    FUZZ_REG aprr_mask_en_el1               // 0x070
    FUZZ_REG aprr_mask_el0                  // 0x0a0
    FUZZ_REG ktrr_unknown                   // 0x0d0

    TEST_REG_VAL vmsa_lockdown_el1, 0x1
    //TEST_REG_VAL vmsa_lockdown_el1, 0x2
    TEST_REG_VAL vmsa_lockdown_el1, 0x4
    TEST_REG_VAL vmsa_lockdown_el1, 0x8
    TEST_REG_VAL vmsa_lockdown_el1, 0x10
    TEST_REG_VAL vmsa_lockdown_el1, 0x20
    TEST_REG_VAL vmsa_lockdown_el1, 0x40
    TEST_REG_VAL vmsa_lockdown_el1, 0x80
    TEST_REG_VAL vmsa_lockdown_el1, 0x100
    TEST_REG_VAL vmsa_lockdown_el1, 0x200
    TEST_REG_VAL vmsa_lockdown_el1, 0x400
    TEST_REG_VAL vmsa_lockdown_el1, 0x800
    TEST_REG_VAL vmsa_lockdown_el1, 0x1000
    TEST_REG_VAL vmsa_lockdown_el1, 0x2000
    TEST_REG_VAL vmsa_lockdown_el1, 0x4000
    TEST_REG_VAL vmsa_lockdown_el1, 0x8000
    TEST_REG_VAL vmsa_lockdown_el1, 0x10000
    TEST_REG_VAL vmsa_lockdown_el1, 0x20000
    TEST_REG_VAL vmsa_lockdown_el1, 0x40000
    TEST_REG_VAL vmsa_lockdown_el1, 0x80000
    TEST_REG_VAL vmsa_lockdown_el1, 0x100000
    TEST_REG_VAL vmsa_lockdown_el1, 0x200000
    TEST_REG_VAL vmsa_lockdown_el1, 0x400000
    TEST_REG_VAL vmsa_lockdown_el1, 0x800000
    TEST_REG_VAL vmsa_lockdown_el1, 0x1000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x2000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x4000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x8000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x10000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x20000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x40000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x80000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x100000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x200000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x400000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x800000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x1000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x2000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x4000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x8000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x10000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x20000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x40000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x80000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x100000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x200000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x400000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x800000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x1000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x2000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x4000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x8000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x10000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x20000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x40000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x80000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x100000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x200000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x400000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x800000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x1000000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x2000000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x4000000000000000
    TEST_REG_VAL vmsa_lockdown_el1, 0x8000000000000000*/

    /*
    TEST_REG_VAL vmsa_lockdown_el1, 0x00    // 0x100
    TEST_VMSA                               // 0x110
    TEST_REG_VAL vmsa_lockdown_el1, 0x01    // 0x1b0
    TEST_VMSA                               // 0x1c0
    //TEST_REG_VAL vmsa_lockdown_el1, 0x02    // 0x260
    //TEST_VMSA                               // 0x270
    TEST_REG_VAL vmsa_lockdown_el1, 0x04    // 0x310
    TEST_VMSA                               // 0x320
    TEST_REG_VAL vmsa_lockdown_el1, 0x08    // 0x3c0
    TEST_VMSA                               // 0x3d0
    TEST_REG_VAL vmsa_lockdown_el1, 0x10    // 0x470
    TEST_VMSA                               // 0x480
    TEST_REG_VAL vmsa_lockdown_el1, 0x20    // 0x520
    TEST_VMSA                               // 0x530
    TEST_REG_VAL vmsa_lockdown_el1, 0x40    // 0x5d0
    TEST_VMSA                               // 0x5e0
    TEST_REG_VAL vmsa_lockdown_el1, 0x80    // 0x680
    TEST_VMSA                               // 0x690

    TEST_REG_VAL vmsa_lockdown_el1, 0xfffffffffffffffe  // 0x730
    TEST_REG_VAL vmsa_lockdown_el1, 0x0                 // 0x740

    FUZZ_REG vmsa_lockdown_el1              // 0x750
    */

    // Set error flag = 0
    mov x18, 0

    // Set up page tables.
    // Under ttbr0, we create a V=P mapping with:
    //   [Lentry - Lstart ] rw-
    //   [Lstart - Lvictim] r-x
    // At the base of ttbr1, we map Lvictim over and over
    // with different protections, including HPD remaps.
    // In the middle of ttbr1, we replicate the ttbr0 mapping,
    // but for EL0 instead.

    adr x20, Lentry
    adr x21, Lstart
    adr x22, Lvictim

    // Map [Lentry - Lstart] under ttbr0
1:
    adr x0, LTT0L2
    mov x1, TCR_BITS
    mov x2, x20
    mov x3, x20
    mov x4, (AP_UXN | AP_PXN | AP_RWNA)
    bl Lmap_page
    add x20, x20, #(1 << (PAGE_BITS - 12)), lsl 12 // ugly (1 << PAGE_BITS)
    cmp x20, x21
    b.lo 1b

    // Map [Lstart - Lvictim] under ttbr0
1:
    adr x0, LTT0L2
    mov x1, TCR_BITS
    mov x2, x21
    mov x3, x21
    mov x4, (AP_UXN | AP_RONA)
    bl Lmap_page
    add x21, x21, #(1 << (PAGE_BITS - 12)), lsl 12 // ugly (1 << PAGE_BITS)
    cmp x21, x22
    b.lo 1b

    adr x20, Lentry
    adr x21, Lstart
    mov x23, -(TCR_SIZE / 2) // base

    // Map [Lentry - Lstart] under ttbr1
1:
    adr x0, LTT1L2
    mov x1, TCR_BITS
    mov x2, x23
    mov x3, x20
    mov x4, (AP_UXN | AP_PXN | AP_RWRW)
    bl Lmap_page
    add x20, x20, #(1 << (PAGE_BITS - 12)), lsl 12 // ugly (1 << PAGE_BITS)
    add x23, x23, #(1 << (PAGE_BITS - 12)), lsl 12 // ugly (1 << PAGE_BITS)
    cmp x20, x21
    b.lo 1b

    // Map [Lstart - Lvictim] under ttbr1
1:
    adr x0, LTT1L2
    mov x1, TCR_BITS
    mov x2, x23
    mov x3, x21
    mov x4, (AP_PXN | AP_RORO)
    bl Lmap_page
    add x21, x21, 0x4, lsl 12 // XXX: can't say (1 << PAGE_BITS)
    add x23, x23, 0x4, lsl 12 // XXX: can't say (1 << PAGE_BITS)
    cmp x21, x22
    b.lo 1b

    // Map Lvictim into L3 with 16 different prots
    mov x20, 0
    mov x23, -TCR_SIZE // base
1:
    adr x0, LTT1L3
    mov x1, (TCR_BITS - PAGE_IDX_BITS)
    add x2, x23, x20, lsl PAGE_BITS
    mov x3, x22
    mov x4, x20
    bl Lmap_page
    add x20, x20, 1
    cmp x20, 0x10
    b.lo 1b

    // And now map L3 into L2 with 16 different prots
    mov x20, 0
    adr x21, LTT1L2
1:
    adr x11, LTT1L3
    orr x11, x11, TTE_VALID
    bfi x11, x20, 60, 1 // UXN
    lsr x12, x20, 1
    bfi x11, x12, 59, 1 // PXN
    lsr x12, x12, 1
    bfi x11, x12, 61, 2 // AP
    str x11, [x21, x20, lsl 3]

    add x20, x20, 1
    cmp x20, 0x10
    b.lo 1b

    mov x17, 0x44 // tag 0 = non-cacheable
    msr mair_el1, x17

    movz x17, 0x1, lsl 32                        // IPS = 36b
    movk x17, (0x6000 | (64 - TCR_BITS)), lsl 16 // TG1 = 16k, SH1 = OSH
    movk x17, (0xa000 | (64 - TCR_BITS))         // TG0 = 16k, SH1 = OSH
    msr tcr_el1, x17

    adr x17, LTT0L2
    msr ttbr0_el1, x17

    adr x17, LTT1L2
    msr ttbr1_el1, x17

    // Enable PAN
    .4byte 0xd500419f // msr pan, 1

    msr tpidr_el0, xzr
    msr tpidr_el1, xzr

    // Clear TLBs
    dsb sy
    isb
    ic ialluis
    tlbi vmalle1

    // Turn on MMU
    mov x17, SCTLR_WXN
    movk x17, SCTLR_MMU
    msr sctlr_el1, x17
    isb

    cbz x18, 1f
    // If x18 != 0, shit hit the fan!
    hlt 0x42
    b .

1:
    // APRR config
    ldr x20, Lmask0
    mrs x17, aprr0_el1
    and x17, x17, x20
    msr aprr0_el1, x17

    ldr x20, Lmask1
    mrs x17, aprr1_el1
    and x17, x17, x20
    msr aprr1_el1, x17

    bl Ltest_translation
    bl Ltest_access
    bl Lsyscall_return

    // Disable PAN
    .4byte 0xd500409f // msr pan, 0
    mrs x17, sctlr_el1
    orr x17, x17, SCTLR_NOSPAN
    msr sctlr_el1, x17
    isb

    bl Ltest_translation
    bl Ltest_access
    bl Lsyscall_return

    // Enable PAN, disable WXN
    .4byte 0xd500419f // msr pan, 0
    mrs x17, sctlr_el1
    and x17, x17, ~SCTLR_NOSPAN
    and x17, x17, ~SCTLR_WXN
    msr sctlr_el1, x17
    isb

    bl Ltest_translation
    bl Ltest_access
    bl Lsyscall_return

    // Disable PAN
    .4byte 0xd500409f // msr pan, 0
    mrs x17, sctlr_el1
    orr x17, x17, SCTLR_NOSPAN
    msr sctlr_el1, x17
    isb

    bl Ltest_translation
    bl Ltest_access
    bl Lsyscall_return

    // Attempt reset
    mov x17, 0x3
    msr rmr_el1, x17
    isb
    hlt 0x69
    b .

.align 2
Lmap_page:
    // x0 table
    // x1 bits on level
    // x2 va
    // x3 pa
    // x4 prot (AP:PXN:UXN)

    // calc bits and idx on this stage
    // x8 = bits
    // x9 = idx
    sub x8, x1, PAGE_BITS
    lsr x9, x2, PAGE_BITS
1:
    cmp x8, PAGE_IDX_BITS
    b.ls 2f
    sub x8, x8, PAGE_IDX_BITS
    lsr x9, x9, PAGE_IDX_BITS
    b 1b
2:
    mov x10, 1
    lsl x10, x10, x8
    sub x10, x10, 1
    and x9, x9, x10

    // x10 = next level bits
    sub x10, x1, x8
    cmp x10, PAGE_BITS
    b.hi Lmap_L2
Lmap_L3:
    // x11 = TTE
    and x11, x3, 0x0000ffffffffc000 // addr
    mov x12, (TTE_VALID | TTE_NS | TTE_SH_OSH | TTE_AF)
    orr x11, x11, x12   // flags
    bfi x11, x4, 54, 1  // UXN
    lsr x12, x4, 1
    bfi x11, x12, 53, 1 // PXN
    lsr x12, x12, 1
    bfi x11, x12, 6, 2  // AP
    // Write TTE
    str x11, [x0, x9, lsl 3]
    ret

Lmap_L2:
    // x11 = TTE
    ldr x11, [x0, x9, lsl 3]
    tbnz x11, 0, 1f

    // Map a new L3 page
    adr x11, LTTXL3
    adr x12, Lpgnum
    ldr w13, [x12]
    add x11, x11, x13, lsl PAGE_BITS
    add w13, w13, 1
    str w13, [x12]
    adr x13, LTTXL3_end
    cmp x11, x13
    b.lo 2f
    // If we're here, we ran out of pages
    hlt 0x77
    b .
2:
    orr x11, x11, TTE_VALID // flags
    // Write TTE
    str x11, [x0, x9, lsl 3]
1:
    and x0, x11, 0x0000ffffffffc000 // L3 table
    mov x1, x10
    // x2-x4 stay the same
    b Lmap_page

Lsyscall_enter:
    adr x17, Lresult
    add x16, x16, x17
    mrs x30, tpidr_el1
    ret

Lsyscall_return:
    msr tpidr_el1, x30
    // Translate x16
    adr x17, Lresult
    sub x16, x16, x17
    // Set branch addr
    adr x17, LEL0_stub
    adr x19, Lentry
    sub x17, x17, x19
    mov x19, -(TCR_SIZE / 2) // base
    add x17, x17, x19
    msr elr_el1, x17
    // Set state
    .4byte 0xd5384271 // mrs x17, pan
    orr x17, x17, 0x3c0 // DAIF
    msr spsr_el1, x17
    eret

LEL0_stub:
    adr x17, Lresult
    add x16, x16, x17
    bl Ltest_access
    adr x17, Lresult
    sub x16, x16, x17
    svc 0x0
    hlt 0x44
    b .

// Space required: 0x4000
Ltest_translation:
    mov x18, 0x1
    mov x0, -TCR_SIZE // base
    mov x2, 0x0
2:
    add x1, x0, x2, lsl #(PAGE_BITS + PAGE_IDX_BITS)
    mov x3, 0x0
3:
    add x8, x1, x3, lsl PAGE_BITS

    at s1e1r, x8
    mrs x9, par_el1
    stp x18, x9, [x16], 0x10

    at s1e1w, x8
    mrs x9, par_el1
    stp x18, x9, [x16], 0x10

    at s1e0r, x8
    mrs x9, par_el1
    stp x18, x9, [x16], 0x10

    at s1e0w, x8
    mrs x9, par_el1
    stp x18, x9, [x16], 0x10

    //at s1e1rp, x8
    //mrs x9, par_el1
    //stp x18, x9, [x16], 0x10

    //at s1e1wp, x8
    //mrs x9, par_el1
    //stp x18, x9, [x16], 0x10

    add x3, x3, 0x1
    cmp x3, 0x10
    b.lo 3b

    add x2, x2, 0x1
    cmp x2, 0x10
    b.lo 2b
    ret

// Space required: 0x600
Ltest_access:
    mov x29, x30
    mov x0, -TCR_SIZE // base
    mov x2, 0x0
2:
    add x1, x0, x2, lsl #(PAGE_BITS + PAGE_IDX_BITS)
    mov x3, 0x0
3:
    add x8, x1, x3, lsl PAGE_BITS

    mov w18, 0x1
    ldrb w17, [x8, Lvictim_r@pageoff]
    strb w18, [x16], 0x1
    strb w17, [x16], 0x1

    mov w18, 0x1
    mov w17, 0xaa
    strb w17, [x8, Lvictim_w@pageoff]
    strb w18, [x16], 0x1
    strb w17, [x16], 0x1

    mov x18, 0x1
    msr tpidr_el0, x18
    mov w17, 0x0
    add x9, x8, Lvictim_x@pageoff
    blr x9
    msr tpidr_el0, xzr
    strb w18, [x16], 0x1
    strb w17, [x16], 0x1

    add x3, x3, 0x1
    cmp x3, 0x10
    b.lo 3b

    add x16, x16, 0xf
    and x16, x16, ~0xf

    add x2, x2, 0x1
    cmp x2, 0x10
    b.lo 2b

    mov x30, x29
    ret

.align 3
Lmask0:
    .8byte APRR0_MASK
Lmask1:
    .8byte APRR1_MASK

// ==================== ==================== VECTORS ==================== ====================

.macro EXC_VECTOR
    mrs x18, elr_el1
    add x18, x18, 0x4
    msr elr_el1, x18
    mov x18, $0
    eret
.endmacro

.align 14
Lvector:
.align 7
    EXC_VECTOR 0x10
.align 7
    EXC_VECTOR 0x11
.align 7
    EXC_VECTOR 0x12
.align 7
    EXC_VECTOR 0x13
.align 7
    mrs x18, elr_el1
    add x18, x18, 0x4
    mrs x19, tpidr_el0
    cmp x19, 0
    csel x18, x18, x30, eq
    msr elr_el1, x18
    mov x18, 0x20
    eret
.align 7
    EXC_VECTOR 0x21
.align 7
    EXC_VECTOR 0x22
.align 7
    EXC_VECTOR 0x23
.align 7 // EL0_64
    mrs x19, esr_el1
    ubfx x19, x19, 26, 6
    cmp x19, 0x15 // svc
    b.eq Lsyscall_enter

    mrs x18, elr_el1
    add x18, x18, 0x4
    mrs x19, tpidr_el0
    cmp x19, 0
    csel x18, x18, x30, eq
    msr elr_el1, x18
    mov x18, 0x30
    eret
.align 7
    EXC_VECTOR 0x31
.align 7
    EXC_VECTOR 0x32
.align 7
    EXC_VECTOR 0x33
.align 7
    EXC_VECTOR 0x40
.align 7
    EXC_VECTOR 0x41
.align 7
    EXC_VECTOR 0x42
.align 7
    EXC_VECTOR 0x43



// ==================== ==================== VICTIM ==================== ====================

.align 14
Lvictim:

.align 4
Lvictim_r:
    .8byte 0x42

.align 4
Lvictim_w:
    .8byte 0xff

.align 4
Lvictim_x:
    mov x17, 0x69
    ret



// ==================== ==================== TABLES ==================== ====================

// Special purpose
.align 14
LTT0L2:
    .space 0x4000
.align 14
LTT1L2:
    .space 0x4000
.align 14
LTT1L3:
    .space 0x4000

// General purpose
.align 14
LTTXL3:
    .space 0x10000 // should be enough
LTTXL3_end:
