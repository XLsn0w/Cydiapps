// method 7 - prepare encode frame (VXE380)

int sub_fffffff006dfe798(int arg0) {
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
    r21 = r2;
    r19 = r1;
    r20 = r0;
    if (r19 == 0x0) goto loc_fffffff006dfe82c;

/*
    Check if out is null
*/
loc_fffffff006dfe7d0:
    if (r21 == 0x0) // r21 = out
        goto loc_fffffff006dfe838;
/*
    Check if this(driver) is null
*/
loc_fffffff006dfe7d4:
    if (*(r20 + 0xd8) == 0x0) // r20 = this
        goto loc_fffffff006dfe844;

/*
    ui16Width check
*/
loc_fffffff006dfe7dc:

    r10 = *(r19 + 0x14); // r19 = r1 = input
    r8 = r10 & 0xffff;

    // we can make r8 0xfffe but it won't work for ui16FrameHeight
    // anything 0x1000078 or bigger should do
    if (r8 < 0x7f)
        goto loc_fffffff006dfe89c; 

/*
    ui16FrameHeight check
*/
loc_fffffff006dfe7ec:
    r9 = r10 >> 0x10; // r10 is same from ui16Width check

    if (r9 < 0x3f)
        goto loc_fffffff006dfe8c4;

loc_fffffff006dfe7f8:
    r11 = *(r20 + 0x148); // input + 0x148
    if (r11 == 0xf6)
        goto loc_fffffff006dfe850;

loc_fffffff006dfe804:
    if (r11 == 0xf5)
        goto loc_fffffff006dfe890;

loc_fffffff006dfe80c:
    if (r11 != 0xf4)
        goto loc_fffffff006dfe8ac;

loc_fffffff006dfe814:
    if ((r10 & 0xffff) >= 0x7f1)
        goto loc_fffffff006dfe89c;

loc_fffffff006dfe820:
    if (r9 >= 0x7f1)
        goto loc_fffffff006dfe8c4;

/*
    ui8SlicesPerField check
*/
loc_fffffff006dfe924:
    r8 = *(r19 + 0xc); // r19 = r1 = input
    
    if ((r8 >= 0x9) || (r8 == 0x0))
        goto loc_fffffff006dfea40;


loc_fffffff006dfe934:
    r22 = zero_extend_64(0x0);
    r23 = r19 + 0x334;
    goto loc_fffffff006dfe93c;

loc_fffffff006dfe93c:
    if (*(r23 + r22 * 0x4) == 0x0) goto loc_fffffff006dfe95c;

loc_fffffff006dfe944:
    r0 = *(r20 + 0xd8);
    r2 = *(r20 + 0xe8);
    r0 = sub_fffffff006dfd954(r0);
    *(0x1c + r23 + r22 * 0x8) = r0;
    if (r0 == 0x0) goto loc_fffffff006dfea60;

loc_fffffff006dfe95c:
    r22 = r22 + 0x1;
    if (r22 < 0x6) goto loc_fffffff006dfe93c;

loc_fffffff006dfe968:
    r23 = zero_extend_64(0x0);
    r22 = zero_extend_64(0x0);
    r24 = r19 + 0x3b4;
    goto loc_fffffff006dfe974;

loc_fffffff006dfe974:
    r25 = zero_extend_64(0x0);
    r26 = r23;
    goto loc_fffffff006dfe97c;

loc_fffffff006dfe97c:
    if (*(r24 + r26 * 0x4) == 0x0) goto loc_fffffff006dfe99c;

loc_fffffff006dfe984:
    r0 = *(r20 + 0xd8);
    r2 = *(r20 + 0xe8);
    r0 = sub_fffffff006dfd954(r0);
    *(0x84 + r24 + r26 * 0x8) = r0;
    if (r0 == 0x0) goto loc_fffffff006dfea50;

loc_fffffff006dfe99c:
    r25 = r25 + 0x1;
    r26 = r26 + 0x1;
    if (r25 < 0x2) goto loc_fffffff006dfe97c;

loc_fffffff006dfe9ac:
    r22 = r22 + 0x1;
    r23 = r23 + 0x2;
    if (r22 < 0x10) goto loc_fffffff006dfe974;

loc_fffffff006dfe9bc:
    r8 = zero_extend_64(0x0);
    r9 = r19 + 0x350;
    r10 = r21 + 0x100;
    do {
            r10 = r9;
            r8 = r8 + 0x8;
    } while (r8 != 0x30);
    r8 = zero_extend_64(0x0);
    r9 = r19 + 0x438;
    do {
            r10 = r31 | 0x2;
            r11 = r21;
            r12 = r9;
            do {
                    r13 = *r12;
                    r12 = r12 + 0x8;
                    *r11 = r13;
                    r11 = r11 + 0x8;
                    r10 = r10 - 0x1;
            } while (r10 != 0x0);
            r8 = r8 + 0x1;
            r9 = r9 + 0x10;
            r21 = r21 + 0x10;
    } while (r8 != 0x10);
    r0 = *(r20 + 0xd8);
    r2 = r19;
    r1 = r20;
    r3 = r19;
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
    r0 = loc_fffffff006dfbef8(r0);
    return r0;

loc_fffffff006dfea50:
    asm{ stp        x22, x25, sp };
    r0 = "VXE380UC ERROR: in->userDPBBuffer[%d][%d] NULL.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe8d0:
    r0 = sub_fffffff006e1e638();
    r0 = zero_extend_64(0xe000);
    asm{ movk       w0, #0x2bc };
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

loc_fffffff006dfea60:
    r31 = r22;
    r0 = "AVEUC ERROR: in->codedOutputBuffer[%d] NULL.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfea40:
    r31 = r8;
    r0 = "VXE380UC ERROR: VideoParams->ui8SlicesPerField  = %d.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe8c4:
    r31 = r9;
    r0 = "VXE380UC ERROR: VideoParams->ui16FrameHeight = %d.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe89c:
    r31 = r8;
    r0 = "VXE380UC ERROR: VideoParams->ui16Width = %d.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe8ac:
    r31 = r11;
    r0 = "VXE380UC ERROR: m_DeviceType (%x) not recognized. cannot SetSessionSettings\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe890:
    if ((r10 & 0xffff) < 0x801) goto loc_fffffff006dfe8bc;
    goto loc_fffffff006dfe89c;

loc_fffffff006dfe8bc:
    if (r9 < 0x7f1)
        goto loc_fffffff006dfe8f8;
    goto loc_fffffff006dfe8c4;

loc_fffffff006dfe8f8:
    if ((r10 >> 0x14) * (r8 >> 0x4) >> 0x7 < 0x7f)
        goto loc_fffffff006dfe924;

loc_fffffff006dfe910:
    r9 = zero_extend_64(0x3f7f);
    asm{ stp        x8, x9, sp };
    r0 = "VXE380UC ERROR: nmb %d > H264VIDEOENCODER_MAX_NUMER_OF_TOTAL_MACROBLOCKS_H4_H5 %d.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe850:
    if ((r10 & 0xffff) >= 0xff1) // r10 = in + 0x14
        goto loc_fffffff006dfe89c;

loc_fffffff006dfe85c:
    if (r9 >= 0xff1) goto loc_fffffff006dfe8c4;

loc_fffffff006dfe864:
    if ((r10 >> 0x14) * (r8 >> 0x4) >> 0x7 < 0xff) goto loc_fffffff006dfe924;

loc_fffffff006dfe87c:
    r9 = zero_extend_64(0x7f7f);
    asm{ stp        x8, x9, sp };
    r0 = "VXE380UC ERROR: nmb %d > H264VIDEOENCODER_MAX_NUMER_OF_TOTAL_MACROBLOCKS_H6 %d.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe844:
    r0 = "VXE380UC ERROR: m_Driver NULL.\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe838:
    r0 = "  VXE380UC: VXE380_PreInit_UserKernel_Out_Info NULL\n";
    goto loc_fffffff006dfe8d0;

loc_fffffff006dfe82c:
    r0 = "  VXE380UC: VXE380_PreInit_UserKernel_In_Info NULL\n";
    goto loc_fffffff006dfe8d0;
}