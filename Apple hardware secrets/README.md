# APRR

Some utilities to probe/explore Apple's APRR CPU feature.

Write-up [here](https://siguza.github.io/APRR/).

### Building

You'll need `vmacho` from my [misc repo](https://github.com/Siguza/misc). Once you have that, just:

    make

### Usage

Requires the ability to run shellcode in EL1 on A10 chips or newer.  
You might want to tweak `APRR0_MASK`/`APRR1_MASK` in `aprr.s` before using.

Upload the `aprr.bin` to a physically contiguous region of memory, then make one CPU jump to it right after reset. When it ran through, dump 0x13000 bytes from offset 0x10 of that memory region, and transfer back to the host. Feed the saved bindump to the `parse` util together with the `APRR0_MASK`/`APRR1_MASK` you used. Four data sets are present, at offsets `0x0`, `0x4c00`, `0x9800` and `0xe400`. Example invocation:

    ./parse result.bin 0x0    0xfffff3f3fffff3f3 0xfffff3f3fffff3f3 >results/0xfffff3f3fffff3f3-0xfffff3f3fffff3f3-PAN-WXN.txt
    ./parse result.bin 0x4c00 0xfffff3f3fffff3f3 0xfffff3f3fffff3f3 >results/0xfffff3f3fffff3f3-0xfffff3f3fffff3f3-NOPAN-WXN.txt
    ./parse result.bin 0x9800 0xfffff3f3fffff3f3 0xfffff3f3fffff3f3 >results/0xfffff3f3fffff3f3-0xfffff3f3fffff3f3-PAN-NOWXN.txt
    ./parse result.bin 0xe400 0xfffff3f3fffff3f3 0xfffff3f3fffff3f3 >results/0xfffff3f3fffff3f3-0xfffff3f3fffff3f3-NOPAN-NOWXN.txt

### Results

[`/results`](https://github.com/Siguza/APRR/tree/master/results) contains a pre-parsed set of test results, run on an A10 device.

See that folder for a format description.

### `yolo.c`

Contains a kernel info leak that gives you the address of `__PPLDATA_CONST` on A12. 0day at the time of writing, should work at least up to & including iOS 13.0 beta 6.
