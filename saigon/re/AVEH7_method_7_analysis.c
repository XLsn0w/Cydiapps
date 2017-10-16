// method 7 - prepare encode frame (AVEH7)

int sub_fffffff0066a4d78(int arg0) {
    r0 = arg0;
    r1 = *(r2 + 0x30); // input
    r2 = *(r2 + 0x58); // output
    *(r31 + 0xffffffffffffffb0) = r26;
    *(r31 + 0xffffffffffffffb8) = r25;
    *(r31 + 0xffffffffffffffc0) = r24;
    *(r31 + 0xffffffffffffffc8) = r23;
    *(r31 + 0xffffffffffffffd0) = r22;
    *(r31 + 0xffffffffffffffd8) = r21;
    *(r31 + 0xffffffffffffffe0) = r20;
    *(r31 + 0xffffffffffffffe8) = r19;
    *(r31 + 0xfffffffffffffff0) = r29;
    *(r31 + 0xfffffffffffffff8) = r30;
    r29 = r31 + 0xfffffffffffffff0;
    r31 = r31 + 0xffffffffffffffb0 - 0x10;
    r22 = r2;
    r20 = r1;
    r21 = r0;
    r19 = zero_extend_64(0xe000);
    asm{ movk       w19, #0x2bc };
    if (r20 == 0x0) goto loc_fffffff0066a4de8;

/*
    Check if out is null
*/
loc_fffffff0066a4db8:
    if (r22 == 0x0)
        goto loc_fffffff0066a4df4;

/*
    Check if this(driver) is null
*/
loc_fffffff0066a4dbc:
    r0 = *(r21 + 0xd8);
    if (r0 == 0x0)
        goto loc_fffffff0066a4e00;

/*
    Check if FrameQueueSurfaceId is null
*/
loc_fffffff0066a4dc4:
    if (*(r20 + 0x4) == 0x0)
        goto loc_fffffff0066a4e14;

loc_fffffff0066a4dcc:
    r8 = *(r20 + 0x8);
    if (r8 == 0x0) goto loc_fffffff0066a4e20;

loc_fffffff0066a4dd4:
    if (r8 >> 0x20 != 0x0) goto loc_fffffff0066a4e2c;

loc_fffffff0066a4ddc:
    r0 = "AVEUC ERROR: in->SPSPPSSurfaceId NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a50f0:
    r0 = sub_fffffff0066bf1b4();
    goto loc_fffffff0066a50f4;

loc_fffffff0066a50f4:
    r0 = r19;
    r31 = r29 - 0x40;
    r29 = *(r31 + 0x40);
    r30 = *(r31 + 0x48);
    r20 = *(r31 + 0x30);
    r19 = *(r31 + 0x38);
    r22 = *(r31 + 0x20);
    r21 = *(r31 + 0x28);
    r24 = *(r31 + 0x10);
    r23 = *(r31 + 0x18);
    r26 = *r31;
    r25 = *(r31 + 0x8);
    r31 = r31 + 0x50;
    return r0;

loc_fffffff0066a4e2c:
    if (*(r20 + 0x100) != 0x0) goto loc_fffffff0066a4e44;

loc_fffffff0066a4e34:
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    *(r20 + 0x100) = r0;
    if (r0 == 0x0) goto loc_fffffff0066a506c;

loc_fffffff0066a4e44:
    r0 = *(r21 + 0xd8);
    r1 = *(r20 + 0x8);
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    *(r20 + 0x108) = r0;
    if (r0 == 0x0) goto loc_fffffff0066a506c;

loc_fffffff0066a4e5c:
    r0 = *(r21 + 0xd8);
    r1 = *(r20 + 0xc);
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    *(r20 + 0x110) = r0;
    if (r0 == 0x0) goto loc_fffffff0066a5078;

loc_fffffff0066a4e74:
    r23 = zero_extend_64(0x0);
    goto loc_fffffff0066a4e78;

loc_fffffff0066a4e78:
    if (*(0x14 + r20 + r23 * 0x4) == 0x0) goto loc_fffffff0066a4e9c;

loc_fffffff0066a4e84:
    r0 = *(r21 + 0xd8);
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    *(0x120 + r20 + r23 * 0x8) = r0;
    if (r0 == 0x0) goto loc_fffffff0066a5084;

loc_fffffff0066a4e9c:
    r23 = r23 + 0x1;
    if (r23 < 0x9) goto loc_fffffff0066a4e78;

loc_fffffff0066a4ea8:
    r23 = zero_extend_64(0x0);
    r24 = r20 + 0xe8;
    r25 = r20 + 0x2c8;
    goto loc_fffffff0066a4eb4;

loc_fffffff0066a4eb4:
    if (r23 > 0x1) goto loc_fffffff0066a4ecc;

loc_fffffff0066a4ebc:
    if (*(r24 + 0xffffffffffffffec) == 0x0) goto loc_fffffff0066a50d4;

loc_fffffff0066a4ec4:
    if (r24 == 0x0) goto loc_fffffff0066a50e4;

loc_fffffff0066a4ecc:
    if (*(r24 + 0xffffffffffffff50) == 0x0) goto loc_fffffff0066a4eec;

loc_fffffff0066a4ed4:
    r0 = *(r21 + 0xd8);
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    r8 = r25 - 0x160;
    r8 = r0;
    if (r0 == 0x0) goto loc_fffffff0066a50a4;

loc_fffffff0066a4eec:
    if (*(r24 + 0xffffffffffffffec) == 0x0) goto loc_fffffff0066a4f08;

loc_fffffff0066a4ef4:
    r0 = *(r21 + 0xd8);
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    *(r25 + 0xffffffffffffffd8) = r0;
    if (r0 == 0x0) goto loc_fffffff0066a50b4;

loc_fffffff0066a4f08:
    if (r24 == 0x0) goto loc_fffffff0066a4f24;

loc_fffffff0066a4f10:
    r0 = *(r21 + 0xd8);
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    r25 = r0;
    if (r0 == 0x0) goto loc_fffffff0066a50c4;

loc_fffffff0066a4f24:
    r23 = r23 + 0x1;
    r24 = r24 + 0x4;
    r25 = r25 + 0x8;
    if (r23 < 0x5) goto loc_fffffff0066a4eb4;

loc_fffffff0066a4f38:
    r24 = zero_extend_64(0x0);
    r23 = zero_extend_64(0x0);
    goto loc_fffffff0066a4f40;

loc_fffffff0066a4f40:
    r25 = zero_extend_64(0x0);
    r26 = r24;
    goto loc_fffffff0066a4f48;

loc_fffffff0066a4f48:
    if (*(0x4c + r20 + r26 * 0x4) == 0x0) goto loc_fffffff0066a4f6c;

loc_fffffff0066a4f54:
    r0 = *(r21 + 0xd8);
    r2 = *(r21 + 0xe8);
    r0 = sub_fffffff0066a408c(r0);
    *(0x190 + r20 + r26 * 0x8) = r0;
    if (r0 == 0x0) goto loc_fffffff0066a5094;

loc_fffffff0066a4f6c:
    r25 = r25 + 0x1;
    r26 = r26 + 0x1;
    if (r25 < 0x2) goto loc_fffffff0066a4f48;

loc_fffffff0066a4f7c:
    r23 = r23 + 0x1;
    r24 = r24 + 0x2;
    if (r23 < 0x11) goto loc_fffffff0066a4f40;

loc_fffffff0066a4f8c:
    r8 = zero_extend_64(0x0);
    r22 = *(r20 + 0x110);
    *(r22 + 0x8) = *(r20 + 0x118);
    r9 = r20 + 0x120;
    r10 = r22 + 0x18;
    do {
            r10 = r9;
            r8 = r8 + 0x8;
    } while (r8 != 0x48);
    r8 = zero_extend_64(0x0);
    r9 = r20 + 0x2c8;
    r10 = r22 + 0x1c0;
    do {
            r14 = r10 + r8 - 0x160;
            r14 = r9 + r8 - 0x160;
            stack[2043] = *(0xffffffffffffffd8 + r9 + r8);
            r13 = r9 + r8;
            r8 = r8 + 0x8;
    } while (r8 != 0x28);
    r8 = zero_extend_64(0x0);
    r9 = r20 + 0x190;
    r10 = r22 + 0x88;
    do {
            r11 = r31 | 0x2;
            r12 = r10;
            r13 = r9;
            do {
                    *r12 = stack[2048];
                    r12 = r12 + 0x8;
                    r11 = r11 - 0x1;
            } while (r11 != 0x0);
            r8 = r8 + 0x1;
            r9 = r9 + 0x10;
            r10 = r10 + 0x10;
    } while (r8 != 0x11);
    *(r22 + 0x10) = *(r20 + 0x100);
    r0 = *(r21 + 0xd8);
    r2 = r20;
    r1 = r21;
    r3 = r20;
    r31 = r29 - 0x40;
    r29 = *(r31 + 0x40);
    r30 = *(r31 + 0x48);
    r20 = *(r31 + 0x30);
    r19 = *(r31 + 0x38);
    r22 = *(r31 + 0x20);
    r21 = *(r31 + 0x28);
    r24 = *(r31 + 0x10);
    r23 = *(r31 + 0x18);
    r26 = *r31;
    r25 = *(r31 + 0x8);
    r31 = r31 + 0x50;
    r0 = loc_fffffff0066a2fb4(r0);
    return r0;

loc_fffffff0066a5094:
    asm{ stp        x23, x25, sp };
    r0 = "AVEUC ERROR: in->userDPBBuffer[%d][%d] NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a50c4:
    r31 = r23;
    r0 = "AVEUC ERROR: in->codedHeaderBuffer[%d] NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a50b4:
    r31 = r23;
    r0 = "AVEUC ERROR: in->codedOutputBuffer[%d] NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a50a4:
    r31 = r23;
    r0 = "AVEUC ERROR: in->statsMapBuffer[%d] NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a50e4:
    r31 = r23;
    r0 = "AVEUC ERROR: in->codedHeaderCSID[%d] NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a50d4:
    r31 = r23;
    r0 = "AVEUC ERROR: in->codedOutputCSID[%d] NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a5084:
    r31 = r23;
    r0 = "AVEUC ERROR: in->mbComplexityMapBuffer[%d] NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a5078:
    r0 = "AVEUC ERROR: in->SPSPPSSBuffer NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a506c:
    r0 = "AVEUC ERROR: in->FrameQueueBuffer NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a4e20:
    r0 = "AVEUC ERROR: in->InitInfoSurfaceId NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a4e14:
    r0 = "AVEUC ERROR: in->FrameQueueSurfaceId NULL.\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a4e00:
    r0 = "AVEUC ERROR: m_Driver NULL.\n";
    r0 = sub_fffffff0066bf1b4();
    r19 = r19 + 0x1d;
    goto loc_fffffff0066a50f4;

loc_fffffff0066a4df4:
    r0 = "  AVEUC: AVE_SessionSettings_UserKernel_Out_Info NULL\n";
    goto loc_fffffff0066a50f0;

loc_fffffff0066a4de8:
    r0 = "  AVEUC: AVE_SessionSettings_UserKernel_In_Info NULL\n";
    goto loc_fffffff0066a50f0;
}