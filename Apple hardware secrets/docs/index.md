_Siguza, 08. Aug 2019_

# APRR

Of Apple hardware secrets.

### Introduction

Almost a year ago I did a [write-up on KTRR](https://siguza.github.io/KTRR/), first introduced in Apple's A10 chip series. Now over the course of the last year, there has been a good bit of talk as well as confusion about the new mitigations shipped with Apple's A12. One big change, PAC, has already been [torn down in detail](https://googleprojectzero.blogspot.com/2019/02/examining-pointer-authentication-on.html) by [Brandon Azad](https://twitter.com/_bazad/), so I'm gonna leave that out here. What's left to cover is more than just APRR, but APRR is certainly the biggest chunk, hence the title of this post. Now the people who have attended TyphoonCon down in Seoul this year already got to see this research at an earlier stage - everyone else can get the slides [here](https://github.com/ssd-secure-disclosure/typhooncon2019/blob/master/Siguza%20-%20Mitigations.pdf). On a separate note, Apple's Head of Security Engineering [Ivan Krstić](https://twitter.com/radian/) returns to BlackHat US this year with a talk titled "[Behind the scenes of iOS and Mac Security](https://www.blackhat.com/us-19/briefings/schedule/index.html#behind-the-scenes-of-ios-and-mac-security-17220)". The bits about iOS 13 sure sound interesting, but this bit of the abstract caught my eye:

> We will also discuss previously-undisclosed VM permission and page protection technologies that are part of our overall iOS code integrity architecture.

Let's see if we can change this "previously-undisclosed" status, shall we? :P

### KTRR amended

If you've read my KTRR post and poked a bit at any A12 kernel, chances are something caught your attention: `__LAST.__pinst` lost a lot of instructions.  
Here's the entirety of `__LAST.__pinst` on A11:

```
0xfffffff007630000      202018d5       msr ttbr1_el1, x0
0xfffffff007630004      c0035fd6       ret
0xfffffff007630008      00c018d5       msr vbar_el1, x0
0xfffffff00763000c      c0035fd6       ret
0xfffffff007630010      402018d5       msr tcr_el1, x0
0xfffffff007630014      c0035fd6       ret
0xfffffff007630018      001018d5       msr sctlr_el1, x0
0xfffffff00763001c      c0035fd6       ret
0xfffffff007630020      bf4100d5       msr spsel, 1
0xfffffff007630024      c0035fd6       ret
0xfffffff007630028      00f21cd5       msr s3_4_c15_c2_0, x0
0xfffffff00763002c      c0035fd6       ret
0xfffffff007630030      20f21cd5       msr s3_4_c15_c2_1, x0
0xfffffff007630034      c0035fd6       ret
0xfffffff007630038      c0f21cd5       msr s3_4_c15_c2_6, x0
0xfffffff00763003c      c0035fd6       ret
```

And here on A12:

```
0xfffffff008edc000      bf4100d5       msr spsel, 1
0xfffffff008edc004      c0035fd6       ret
0xfffffff008edc008      00f21cd5       msr s3_4_c15_c2_0, x0
0xfffffff008edc00c      c0035fd6       ret
0xfffffff008edc010      20f21cd5       msr s3_4_c15_c2_1, x0
0xfffffff008edc014      c0035fd6       ret
0xfffffff008edc018      c0f21cd5       msr s3_4_c15_c2_6, x0
0xfffffff008edc01c      c0035fd6       ret
```

These were the instructions that should **not** exist anywhere else in the kernel, in order to not have them executable after reset. But sure enough if you go looking for the missing ones now, you'll find them scattered all throughout the kernel, apparently entirely unprotected. But while Apple is scatterbrained at times, they're not _that_ scatterbrained<sup>[\[citation needed\]](https://twitter.com/s1guza/status/1150120288983638018)</sup>. The thing is, when you try and jump to any instruction writing to `ttbr1_el1`, `vbar_el1` or `tcr_el1`, this happens:

```
panic(cpu 0 caller 0xfffffff01dd79b84): "Undefined kernel instruction: pc=0xfffffff01dbd8084 instr=d518c000\n"
Debugger message: panic
Memory ID: 0xff
OS version: 16A405
Kernel version: Darwin Kernel Version 18.0.0: Tue Aug 14 22:07:18 PDT 2018; root:xnu-4903.202.2~1/RELEASE_ARM64_T8020
Kernel UUID: BEFBC911—B1BC-3553—B7EA-1ECE60169886
iBoot version: iBoot-4513.200.297
secure boot?: YES
Paniclog version: 10
Kernel slide: 0x0000000016200000
Kernel text base: 0xfffffff01d204000
Epoch Time:        sec       usec
  Boot    : 0x5cc4e1ec 0x000c74d9
  Sleep   : 0x00000000 0x00000000
  Wake    : 0x00000000 0x00000000
  Calendar: 0x5cc4e21d 0x000d3015
```

What's that faulting instruction `d518c000`, you ask? Bad news:

```
$ rasm2 -aarm -b64 -D $(hexswap d518c000)
0x00000000   4                 00c018d5  msr vbar_el1, x0
```

It's the very instruction we wanted to run.

That makes a lot of sense when you think about it from a chip designer's point of view though. The reason why Apple no longer stuffs these instructions under `__LAST.__pinst` is because they've upgraded their silicon to provide a much stronger guarantee, one that holds up even if they leave some instructions in by mistake, or if you can pull some cache magic to inject some of your own: they just flip a switch and make the instructions undefined altogether.

And looking at `set_tcr` or `set_mmu_ttb_alternate` tells us exactly where this switch is (you can find them by just searching for the instructions):

```
;-- set_tcr
0xfffffff0079d8c18      014040ca       eor x1, x0, x0, lsr 16
0xfffffff0079d8c1c      21144092       and x1, x1, 0x3f
0xfffffff0079d8c20      e10000b5       cbnz x1, 0xfffffff0079d8c3c
0xfffffff0079d8c24      41f13cd5       mrs x1, s3_4_c15_c1_2
0xfffffff0079d8c28      21007e92       and x1, x1, 4
0xfffffff0079d8c2c      410100b5       cbnz x1, 0xfffffff0079d8c54
0xfffffff0079d8c30      402018d5       msr tcr_el1, x0
0xfffffff0079d8c34      df3f03d5       isb
0xfffffff0079d8c38      c0035fd6       ret
```
```
;-- set_mmu_ttb_alternate
0xfffffff0079d8bd0      9f3f03d5       dsb sy
0xfffffff0079d8bd4      41f13cd5       mrs x1, s3_4_c15_c1_2
0xfffffff0079d8bd8      21007c92       and x1, x1, 0x10
0xfffffff0079d8bdc      c10300b5       cbnz x1, 0xfffffff0079d8c54
0xfffffff0079d8be0      202018d5       msr ttbr1_el1, x0
0xfffffff0079d8be4      df3f03d5       isb
0xfffffff0079d8be8      c0035fd6       ret
```

Both contain something that is not in public XNU sources, namely a read from the register `s3_4_c15_c1_2`, and a jump away if some certain bits are set. The place it jumps to calls panic with string `attempt to set locked register`, which is a pretty clear message. Searching for further accesses to `s3_4_c15_c1_2` brings us to this snippet, which is run as part of the reset code:

```
0xfffffff0079d8bfc      df3f03d5       isb
0xfffffff0079d8c00      0100f0d2       mov x1, -0x8000000000000000
0xfffffff0079d8c04      a00280d2       mov x0, 0x15
0xfffffff0079d8c08      000001aa       orr x0, x0, x1
0xfffffff0079d8c0c      40f11cd5       msr s3_4_c15_c1_2, x0
0xfffffff0079d8c10      df3f03d5       isb
0xfffffff0079d8c14      c0035fd6       ret
```

So it gets the value `0x8000000000000015`. The code above tells us that `0x4` is for `tcr_el1` and `0x10` for `ttbr1_el1`, but what about the other two? The code setting `vbar_el1` contains no register check, but I'm assuming it's controlled by bit `0x1`. As for bit 63, I'm fairly confident that serves a slightly more... fine-grained purpose. Because there's one register that used to be under `__LAST.__pinst` that we haven't talked about yet: `sctlr_el1`.

The thing with `sctlr_el1` is that the instruction writing to it is _not_ made undefined. In fact, the register is actively written to by the exception handlers if coming from EL0:

```
0xfffffff0079cf304      001038d5       mrs x0, sctlr_el1
0xfffffff0079cf308      c000f837       tbnz w0, 0x1f, 0xfffffff0079cf320
0xfffffff0079cf30c      000061b2       orr x0, x0, 0x80000000
0xfffffff0079cf310      000065b2       orr x0, x0, 0x8000000
0xfffffff0079cf314      000073b2       orr x0, x0, 0x2000
0xfffffff0079cf318      001018d5       msr sctlr_el1, x0
0xfffffff0079cf31c      df3f03d5       isb
```

The `tbnz` there is a bit of a sloppy check, but under the assumption of kernel integrity it's all fine. Basically the kernel checks for the `EnIA` bit here (which controls whether `pacia` instructions are no-ops), and if not set, sets bits `EnIA`, `EnDA` and `EnDB`. What's happening here is that three of the five PAC keys are disabled for userland apps that are not arm64e, because those would otherwise crash horribly (the `IB` key is not disabled because it's used for stack frames, which are local to each function and thus not an issue). These keys need to be re-enabled on entry to the kernel, and so `sctlr_el1` actually _has_ to be writeable. This would make it a very interesting target since it controls the MMU, which, if turned off, would allow us to run shellcode at EL1. But of course it's not that simple.

Even if you jump to an instruction that writes to `sctlr_el1` and make it unset bit `0`, which should turn off the MMU - it will simply not turn off. This is where (I'm wildly assuming) bit 63 from the `s3_4_c15_c1_2` register comes in. It appears that _certain bits_ of `sctlr_el1` are locked down, while others remain writeable. I haven't gone on to test which bits these are exactly, because for one the available `sctlr_el1` gadgets are very uncomfortable to use, and for two we know that the PAC bits are writeable, the M bit is not, and the rest of the bits are, quite frankly, not of much interest to me.

Of more interest to me was the question of whether `s3_4_c15_c1_2` itself remains writeable and could be used to unlock these registers again. To which the answer is of course also no.  
The instructions writing to `s3_4_c15_c1_2` are not themselves made undefined, but as with parts of `sctlr_el1`, the register value will simply not change anymore. I'm assuming this is also controlled by bit 63.

Now, as might be obvious, my research in this area hasn't gone into great detail so far. I hope to eventually find the time to revisit the register in question, and update this post accordingly.  
It's clear though that the register's purpose is to lock down other registers. Wanting to be more specific than just "the lockdown register", I skimmed the ARMv8 spec for a place where registers are grouped together, but the most narrow group encompassing all of `ttbr1_el1`, `tcr_el1`, `sctlr_el1` and `vbar_el1` is the VMSA (Virtual Memory System Architecture), so for lack of a better name I propose `s3_4_c15_c1_2` to be called `VMSA_LOCKDOWN_EL1`.

As a side note, there seems to exist a register by the same name on chips older than the A12, but that exhibits entirely different behaviour and does not seem to affect VMSA registers at all.  
And I feel like I should also note that there is another register introduced with the A12: `s3_4_c15_c2_5`. The numbering puts it just above the other three KTRR registers:

```
0xfffffff0079d410c      71f21cd5       msr s3_4_c15_c2_3, x17
0xfffffff0079d4110      93f21cd5       msr s3_4_c15_c2_4, x19
0xfffffff0079d4114      510280d2       mov x17, 0x12
0xfffffff0079d4118      b1f21cd5       msr s3_4_c15_c2_5, x17
0xfffffff0079d411c      310080d2       mov x17, 1
0xfffffff0079d4120      51f21cd5       msr s3_4_c15_c2_2, x17
```

Being written to right in the middle of the KTRR lockdown sequence would suggest it is part of KTRR, but I have to admit I have no idea what it does, or what the value `0x12` means that is written to it.

### A thing called PPL

The `VMSA_LOCKDOWN_EL1` register from the last section seems to have neither gotten any public attention, nor affected exploitation of the A12. What got a lot more attention, of course, was PAC. Being part of the ARMv8 spec, it was fairly public, and seems to have been treated as _the big thing_ new to the A12, security-wise. And in the beginning it seemed really strong, but after Brandon Azad discovered a design flaw or two, it doesn't really hold up to a motivated attacker anymore. But the A12 came with yet another security... thing - and this one, in my humble opinion, is the real killer: PPL.

Basically A12 kernels have a bunch of new segments:

```
LC 03: LC_SEGMENT_64  Mem: 0xfffffff008eb4000-0xfffffff008ec8000  __PPLTEXT
LC 04: LC_SEGMENT_64  Mem: 0xfffffff008ec8000-0xfffffff008ed8000  __PPLTRAMP
LC 05: LC_SEGMENT_64  Mem: 0xfffffff008ed8000-0xfffffff008edc000  __PPLDATA_CONST
LC 07: LC_SEGMENT_64  Mem: 0xfffffff008ee0000-0xfffffff008ee4000  __PPLDATA
```

Of course Apple won't tell us what the acronym "PPL" stands for (~anyone at Blackhat willing to annoy Ivan over this? :P~ UPDATE: it stands for "Page Protection Layer"!), but that doesn't stop us from taking it apart.

Anyone doing post-exploitation on A12 will have undoubtedly come across PPL already. Because a bunch of memory patches that used to work just fine on A11 and earlier (namely trust cache injection and page table patches) make the A12 kernel panic with a kernel data abort (i.e. insufficient memory permissions). The thing is though, the kernel can definitely still write to that memory _somehow_ - and if you try and track down the code that does so, you'll find that all such accesses happen from inside `__PPLTEXT`. It would appear as though that code was "privileged" somehow - but of course you can't just invoke it, since that will _also_ panic, this time with an instruction fetch abort. Of course you can then go track down the code that calls into `__PPLTEXT`, which will reveal that all such invocations go through `__PPLTRAMP`.

At this point, there are two areas of interest one can dive into:

1. What kind of code exists in PPL, what parts of it are exposed through the trampoline, and how you can invoke them.
2. How this "privileged mode" works, what the underlying hardware primitives are, and what makes the PPL segments so special.

Point 1 has [already been covered in a detailed write-up](http://newosxbook.com/articles/CasaDePPL.html) by [Jonathan Levin](https://twitter.com/Morpheus______), which I encourage you to read if you want to know more about that. The gist of it is that there are a bunch of "interesting things" such as page tables, trust caches and more (again, see Jonathan's post) that are now only accessible in "privileged mode", and thus remain protected even in the face of an attacker with "normal" kernel rwx. That might seem like adding just another layer to be hacked, but you'll find that the reduction in attack surface is actually _huge_ when you start counting pages. In the iPhone XR's 12.0.1 kernel (random example because I had that one handy), there are 1339 pages in `__TEXT_EXEC` but a mere 5 pages in `__PPLTEXT`. Here's a visualisation of that:

[![PPL vs TEXT_EXEC][img1]][img1]

Page tables and equally critical things had been freely (and needlessly!) accessible from that entire red part, when the green part was all that really required such access, so it only makes sense to lock that down. In addition, locking down page tables can foil the plans of some newbie hacker who thought he was really smart once upon a time:

[![My genius tweets][img2]][img2]

So far so good for point 1 above, but point 2 is what I'm _really_ here for. This is something that has gotten zero public mention, and I was surprised to learn that barely anyone I know seems to have researched this in private as well (granted, it's not required for exploitation, but I consider it interesting nevertheless).

Going about this logically, there will have to be two parts that make up this privileged mode:

- Some switch that is flipped on entry to and exit from `__PPLTEXT`.
- Some attribute that makes the `__PPL*` segments stand out from the rest.

The former is found in `__PPLTRAMP`, right at the top of the entry/exit routines:

```
0xfffffff008ecbfe0      34423bd5       mrs x20, daif
0xfffffff008ecbfe4      df4703d5       msr daifset, 7
0xfffffff008ecbfe8      ae8ae8f2       movk x14, 0x4455, lsl 48
0xfffffff008ecbfec      ae8ac8f2       movk x14, 0x4455, lsl 32
0xfffffff008ecbff0      ce8cacf2       movk x14, 0x6466, lsl 16
0xfffffff008ecbff4      eece8cf2       movk x14, 0x6677
0xfffffff008ecbff8      2ef21cd5       msr s3_4_c15_c2_1, x14
0xfffffff008ecbffc      df3f03d5       isb
0xfffffff008ecc000      df4703d5       msr daifset, 7
0xfffffff008ecc004      ae8ae8f2       movk x14, 0x4455, lsl 48
0xfffffff008ecc008      ae8ac8f2       movk x14, 0x4455, lsl 32
0xfffffff008ecc00c      ce8cacf2       movk x14, 0x6466, lsl 16
0xfffffff008ecc010      eece8cf2       movk x14, 0x6677
0xfffffff008ecc014      35f23cd5       mrs x21, s3_4_c15_c2_1
0xfffffff008ecc018      df0115eb       cmp x14, x21
0xfffffff008ecc01c      e1050054       b.ne 0xfffffff008ecc0d8
```
```
0xfffffff008ed3fec      ae8ae8f2       movk x14, 0x4455, lsl 48
0xfffffff008ed3ff0      8e8ac8f2       movk x14, 0x4454, lsl 32
0xfffffff008ed3ff4      ce8cacf2       movk x14, 0x6466, lsl 16
0xfffffff008ed3ff8      ee8e8cf2       movk x14, 0x6477
0xfffffff008ed3ffc      2ef21cd5       msr s3_4_c15_c2_1, x14
0xfffffff008ed4000      df3f03d5       isb
```

And the latter is found in page tables (the permissions shown here are kernel/user - note that these permissions not only apply to PPL _segments_ but also data _dynamically allocated_ by PPL):

[![PPL page tables][img3]][img3]

Obviously the PPL pages don't _really_ have these permissions - that's just what's the page table entries say. The _real_ permissions are like this for "unprivileged"/normal mode:

[![PPL page tables unpriv][img4]][img4]

And get flipped to this for "privileged"/PPL mode:

[![PPL page tables priv][img5]][img5]

Before we can dive into how that works though, we have to look at something else. Something that, too, has not been publicly torn down. Something that, too, has to do with memory access permissions.

### A new JIT on the block

This tale starts, because how could it be any different, with Ivan Krstić's [2016 BlackHat talk](https://www.youtube.com/watch?v=BLGFriOKz6U). In the part about JIT, he has helpful graphics showing how JIT was implemented up to and including iOS 9 (images blatantly stolen from [his slides](https://www.blackhat.com/docs/us-16/materials/us-16-Krstic.pdf)):

[![not da wae][img6]][img6]

And how this would change with iOS 10:

[![da wae][img7]][img7]

(For more info on that, go check out his talk - going forward here, I assume you know how that works.)

That was nice and well, but just a year later with the release of the A11, Apple moved back to a unified JIT region - with a little caveat. Rather than being fully RWX, a proprietary system register would control whether the region was currently `rw-` or `r-x`, and all JIT-emitting code would access configure register accordingly. One such JIT-emitting code looks as follows (taken from the XR's 12.1 JSC, again simply because I had that one handy):

```
0x188347298      002298f2       movk x0, 0xc110
0x18834729c      e0ffbff2       movk x0, 0xffff, lsl 16
0x1883472a0      e001c0f2       movk x0, 0xf, lsl 32
0x1883472a4      0000e0f2       movk x0, 0, lsl 48
0x1883472a8      000040f9       ldr x0, [x0]
0x1883472ac      e0f21cd5       msr s3_4_c15_c2_7, x0
0x1883472b0      df3f03d5       isb
0x1883472b4      012298f2       movk x1, 0xc110
0x1883472b8      e1ffbff2       movk x1, 0xffff, lsl 16
0x1883472bc      e101c0f2       movk x1, 0xf, lsl 32
0x1883472c0      0100e0f2       movk x1, 0, lsl 48
0x1883472c4      280040f9       ldr x8, [x1]
0x1883472c8      e9f23cd5       mrs x9, s3_4_c15_c2_7
0x1883472cc      1f0109eb       cmp x8, x9
0x1883472d0      c1020054       b.ne 0x188347328
0x1883472d4      e00315aa       mov x0, x21
0x1883472d8      e10314aa       mov x1, x20
0x1883472dc      e20313aa       mov x2, x19
0x1883472e0      19a82b94       bl sym.imp._ZN3JSC4YarrL22createCharacterClass98Ev
0x1883472e4      c8024039       ldrb w8, [x22]
0x1883472e8      08020034       cbz w8, 0x188347328
0x1883472ec      002398f2       movk x0, 0xc118
0x1883472f0      e0ffbff2       movk x0, 0xffff, lsl 16
0x1883472f4      e001c0f2       movk x0, 0xf, lsl 32
0x1883472f8      0000e0f2       movk x0, 0, lsl 48
0x1883472fc      000040f9       ldr x0, [x0]
0x188347300      e0f21cd5       msr s3_4_c15_c2_7, x0
0x188347304      df3f03d5       isb
0x188347308      012398f2       movk x1, 0xc118
0x18834730c      e1ffbff2       movk x1, 0xffff, lsl 16
0x188347310      e101c0f2       movk x1, 0xf, lsl 32
0x188347314      0100e0f2       movk x1, 0, lsl 48
0x188347318      280040f9       ldr x8, [x1]
0x18834731c      e9f23cd5       mrs x9, s3_4_c15_c2_7
0x188347320      1f0109eb       cmp x8, x9
0x188347324      60020054       b.eq 0x188347370
0x188347328      200020d4       brk 1
```

So the system register in question is `s3_4_c15_c2_7`, and it gets its values from the hardcoded addresses `0xfffffc110/8` - which are on the "commpage", outside the range in which userland code is allowed to map memory. Those values are set up by the kernel in `commpage_populate`, but obviously the parts we care about are once again not in public XNU sources. You can find it in assembly though by looking for xrefs to the string `"commpage cpus==0"`, and then far down the funcation referencing that you'll see something like this:

```
0xfffffff007b85390      caee8ed2       mov x10, 0x7776
0xfffffff007b85394      0a22a2f2       movk x10, 0x1110, lsl 16
0xfffffff007b85398      eacecef2       movk x10, 0x7677, lsl 32
0xfffffff007b8539c      4a46e6f2       movk x10, 0x3232, lsl 48
0xfffffff007b853a0      ea038a9a       csel x10, xzr, x10, eq
0xfffffff007b853a4      cbee8ed2       mov x11, 0x7776
0xfffffff007b853a8      0b42a2f2       movk x11, 0x1210, lsl 16
0xfffffff007b853ac      ebcecef2       movk x11, 0x7677, lsl 32
0xfffffff007b853b0      4b46e6f2       movk x11, 0x3232, lsl 48
0xfffffff007b853b4      eb038b9a       csel x11, xzr, x11, eq
0xfffffff007b853b8      28310439       strb w8, [x9, 0x10c]
0xfffffff007b853bc      88b243f9       ldr x8, [x20, 0x760]
0xfffffff007b853c0      0a8900f9       str x10, [x8, 0x110]
0xfffffff007b853c4      88b243f9       ldr x8, [x20, 0x760]
0xfffffff007b853c8      0b8d00f9       str x11, [x8, 0x118]
```

At this point, the A11 JIT and A12 PPL look kinda similar.  
As for how both of them work and what gives it away, that brings us to the punch line of this post:

### Enter APRR

Before the release of the A12, there were rumours about "userland KTRR" coming up, and that being called "APRR". That's not what happened, but let's write down what we already know:

- PPL page tables are weirdly missing the UXN bit (which would make them executable under a standard ARMv8.\* implementation).
- Entry and exit from PPL changes `s3_4_c15_c2_1` to `0x4455445564666677`/`0x4455445464666477`.
- Entry and exit from JIT-emitting code changes `s3_4_c15_c2_7` to `0x3232767711107776`/`0x3232767712107776`.

Pretty much the only speculation I've heard on this matter is that Apple has simply repurposed the UXN page table bit somehow. On a technical level that is not true, but it's an interesting notion that we'll get back to later. As for the register values, everyone who talked about this simply treated them as magical constants, but here's the first clue: all digits in these values are between `0x0` and `0x7`, and there are none between `0x8` and `0xf`. That would make it either an odd choice or a big coincidence if it were just some random constant.

The second clue is the encoding space in which these registers are located: `s3_4_c15_c2_*`. Not only are these two registers in there, but so are the KTRR registers as well as this other register we found on the A12 that gets `0x12` written to it. This leaves us with:

| Register        | Note                        |
|:----------------|-----------------------------|
| `s3_4_c15_c2_0` | ???                         |
| `s3_4_c15_c2_1` | Used by PPL                 |
| `s3_4_c15_c2_2` | `KTRR_LOCK_EL1`             |
| `s3_4_c15_c2_3` | `KTRR_LOWER_EL1`            |
| `s3_4_c15_c2_4` | `KTRR_UPPER_EL1`            |
| `s3_4_c15_c2_5` | Gets value `0x12` on A12    |
| `s3_4_c15_c2_6` | ???                         |
| `s3_4_c15_c2_7` | Used by JIT, EL0-accessible |

That means there's two registers we haven't seen yet - let's keep an eye out for those, shall we? Also from here on out, I'll be referring to these registers simply by their last digit for brevity (e.g. as in "register `0` and `6` are the ones we have yet to see").

Alright, how do we find out more about APRR? Well we could simply search for instructions operating on these registers, but before we do that, let me introduce you to this high-tech hacking tool called `strings`...

```
$ strings kernel | fgrep APRR
"%s: invalid APRR index, " "start=%p, end=%p, aprr_index=%u, expected_index=%u"
"pmap_page_protect: modifying an APRR mapping pte_p=%p pmap=%p prot=%d options=%u, pv_h=%p, pveh_p=%p, pve_p=%p, pte=0x%llx, tmplate=0x%llx, va=0x%llx ppnum: 0x%x"
"pmap_page_protect: creating an APRR mapping pte_p=%p pmap=%p prot=%d options=%u, pv_h=%p, pveh_p=%p, pve_p=%p, pte=0x%llx, tmplate=0x%llx, va=0x%llx ppnum: 0x%x"
"Unsupported APRR index %llu for pte 0x%llx"
```

Not bad, this tells us quite a bit. For one, it seems that `pmap_page_protect` deals with APRR, so we'll go check that out in a second. But for two, something a bit more inconspicuous, it sounds like APRR has _indices_. With that in mind, let's dive into some assembly:

```
0xfffffff008eb8624      0bf23cd5       mrs x11, s3_4_c15_c2_0
0xfffffff008eb8628      2af23cd5       mrs x10, s3_4_c15_c2_1
0xfffffff008eb862c      c8f23cd5       mrs x8, s3_4_c15_c2_6
0xfffffff008eb8630      49ff44d3       lsr x9, x26, 4
0xfffffff008eb8634      29057e92       and x9, x9, 0xc
0xfffffff008eb8638      49d774b3       bfxil x9, x26, 0x34, 2
0xfffffff008eb863c      49db76b3       bfxil x9, x26, 0x36, 1
0xfffffff008eb8640      2cf57ed3       lsl x12, x9, 2
0xfffffff008eb8644      edc300b2       orr x13, xzr, 0x101010101010101
0xfffffff008eb8648      edecacf2       movk x13, 0x6767, lsl 16
0xfffffff008eb864c      ada8e8f2       movk x13, 0x4545, lsl 48
0xfffffff008eb8650      6d010dca       eor x13, x11, x13
0xfffffff008eb8654      eb0b0032       orr w11, wzr, 7
0xfffffff008eb8658      6b21cc9a       lsl x11, x11, x12
0xfffffff008eb865c      7f010dea       tst x11, x13
0xfffffff008eb8660      81010054       b.ne 0xfffffff008eb8690
0xfffffff008eb8664      ecce8cd2       mov x12, 0x6677
0xfffffff008eb8668      ccccacf2       movk x12, 0x6666, lsl 16
0xfffffff008eb866c      ac8ac8f2       movk x12, 0x4455, lsl 32
0xfffffff008eb8670      ac8ae8f2       movk x12, 0x4455, lsl 48
0xfffffff008eb8674      4a010cca       eor x10, x10, x12
0xfffffff008eb8678      7f010aea       tst x11, x10
0xfffffff008eb867c      a1000054       b.ne 0xfffffff008eb8690
0xfffffff008eb8680      ea030032       orr w10, wzr, 1
0xfffffff008eb8684      4921c99a       lsl x9, x10, x9
0xfffffff008eb8688      3f0108ea       tst x9, x8
0xfffffff008eb868c      00020054       b.eq 0xfffffff008eb86cc
```

Lo and behold, there are those two system registers we just said we hadn't seen yet! (Thought actually I lied - we've seen them already in `__LAST.__pinst`, that's just a bit moot since we have zero context there.)  
What you're looking at is part of the `pmap_page_protect_internal` function (a part which is yet again not in public sources, obviously) that has been inlined into `pmap_page_protect`, with `x26` being a TTE about to be entered into a page table.

So what's happening here? At the top we have the register reads, then we have some bit mashing, and finally a few branches to `panic()` if the resulting values are not zero. And it's the bit mashing we're interested in. Translated to C code it would probably look really ugly, but put into words, there are three simple actions:

- The register values are XOR'ed with some constants (`4545010167670101`/`0x4455445566666677`).
- A 4-bit number is constructed from the TTE in the form of `<AP[2:1]>:<PXN>:<UXN>`.
- The value `0x7` is left-shifted by that number times four, and used to mask the XOR'ed value.

That last bullet point is particularly interesting, because it precisely describes the concept of register indexing. If you're not familiar with it, the [ARMv8 Reference Manual](https://developer.arm.com/docs/ddi0487/latest) has at least one good example I know of: `MAIR_EL1`, on page `D13-3202`:

[![MAIR_EL1][img8]][img8]

Long story short, in translation table entries you have an `AttrIndx` field with 3 bits, i.e. values from `0x0` to `0x7`. Those are then used to index the `MAIR_EL1` register to get the `Attr*` fields. Since you have 8 fields in a 64bit register, that makes each field 8 bits wide.

And that is precisely what's happening with APRR here, the only difference being that instead of a 3-bit index we have a 4-bit one, and hence the registers `0` and `1` have 16 fields that are each 4 bits wide. We left out register `6` above, which is indexed a bit differently - the index itself is the same, but its fields seem to be just 1 bit wide rather than 4 (a nice property about both of these values is that this translates to exactly one digit in hexadecimal/binary).

This tells us the register _layout_, but we still don't know the _meaning_ of the individual fields. For that, it might be helpful to collect all values that are somehow used with these registers. Here's that collection:

| Value description              | Register `0`                                 | Register `1`                                 | Register `6`         | Register `7`         |
|:-------------------------------|:---------------------------------------------|:---------------------------------------------|:---------------------|:---------------------|
| XOR'ed in `pmap_page_protect`  | `0x4545010167670101`                         | `0x4455445566666677`                         | -                    | -                    |
| Assigned after CPU reset (A11) | `0x4545010165670101`<br>`0x4545010167670101` | `0x4455445564666677`                         | `0b0000000000000000` | `0x3232767612107676` |
| Assigned after CPU reset (A12) | `0x4545010065670001`<br>`0x4545010067670001` | `0x4455445464666477`<br>`0x4455445564666677` | `0b0000000000000000` | `0x3232767712107776` |
| PPL entry (A12)                | -                                            | `0x4455445564666677`                         | -                    | -                    |
| PPL exit (A12)                 | -                                            | `0x4455445464666477`                         | -                    | -                    |
| Process has JIT disabled (A11) | `0x4545010165670101`                         | -                                            | `0b0000000001000000` | -                    |
| Process has JIT enabled (A11)  | `0x4545010167670101`                         | -                                            | `0b0000000001000000` | -                    |
| Process has JIT disabled (A12) | `0x4545010065670001`                         | -                                            | `0b0000000001000000` | -                    |
| Process has JIT enabled (A12)  | `0x4545010067670001`                         | -                                            | `0b0000000001000000` | -                    |
| JIT region is `rw-`            | -                                            | -                                            | -                    | `0x3232767711107776` |
| JIT region is `r-x`            | -                                            | -                                            | -                    | `0x3232767712107776` |

And then we can do something else: we can take all possible 4-bit indices `0x0` through `0xf`, write down what permission it would normally give us when used in a TTE.

| Index | Kernel access | Userland access |
|:-----:|:-------------:|:---------------:|
| `0x0` | `rwx`         | `--x`           |
| `0x1` | `rwx`         | `---`           |
| `0x2` | `rw-`         | `--x`           |
| `0x3` | `rw-`         | `---`           |
| `0x4` | `rwx`         | `rwx`           |
| `0x5` | `rwx`         | `rw-`           |
| `0x6` | `rw-`         | `rwx`           |
| `0x7` | `rw-`         | `rw-`           |
| `0x8` | `r-x`         | `--x`           |
| `0x9` | `r-x`         | `---`           |
| `0xa` | `r--`         | `--x`           |
| `0xb` | `r--`         | `---`           |
| `0xc` | `r-x`         | `r-x`           |
| `0xd` | `r-x`         | `r--`           |
| `0xe` | `r--`         | `r-x`           |
| `0xf` | `r--`         | `r--`           |

And then we can take some of the values above, and index it for each row. Let's take for example the values A12 uses when entering/exiting PPL (as well as some reg `0` value):

| Index | Krn/Usr   | Reg `1` on PPL entry | Reg `1` on PPL exit | Changed? | Reg `0` |
|:------|:---------:|:--------------------:|:-------------------:|:---------|:-------:|
| `0x0` | `rwx/--x` | `0x7`                | `0x7`               |          | `0x1`   |
| `0x1` | `rwx/---` | `0x7`                | `0x7`               |          | `0x0`   |
| `0x2` | `rw-/--x` | `0x6`                | `0x4`               | &lt;--   | `0x0`   |
| `0x3` | `rw-/---` | `0x6`                | `0x6`               |          | `0x0`   |
| `0x4` | `rwx/rwx` | `0x6`                | `0x6`               |          | `0x7`   |
| `0x5` | `rwx/rw-` | `0x6`                | `0x6`               |          | `0x6`   |
| `0x6` | `rw-/rwx` | `0x4`                | `0x4`               |          | `0x7`   |
| `0x7` | `rw-/rw-` | `0x6`                | `0x6`               |          | `0x6`   |
| `0x8` | `r-x/--x` | `0x5`                | `0x4`               | &lt;--   | `0x0`   |
| `0x9` | `r-x/---` | `0x5`                | `0x5`               |          | `0x0`   |
| `0xa` | `r--/--x` | `0x4`                | `0x4`               |          | `0x1`   |
| `0xb` | `r--/---` | `0x4`                | `0x4`               |          | `0x0`   |
| `0xc` | `r-x/r-x` | `0x5`                | `0x5`               |          | `0x5`   |
| `0xd` | `r-x/r--` | `0x5`                | `0x5`               |          | `0x4`   |
| `0xe` | `r--/r-x` | `0x4`                | `0x4`               |          | `0x5`   |
| `0xf` | `r--/r--` | `0x4`                | `0x4`               |          | `0x4`   |

Let's first look at the reg `1` values. I've marked the two digits that change on entry/exit, and sure enough they affect precisely the protections that PPL pages are mapped with.  
Now let's see, from `0x6` and `0x5` both to `0x4`, that sound familiar? Maybe from a UNIX environment? Maybe from a tool called `chmod`?

### The big enlightenment

They are permissions in `rwx` form! `0x4` = `r`, `0x2` = `w`, `0x1` = `x`.  
The four page table bits that normally determine the access protections have lost all meaning on newer Apple chips. They are now solely used to construct that 4-bit number, which is then used to index the APRR registers, which hold the _actual_ permissions.  
Register `0` is used for EL0 permissions, register `1` for EL1. If registers `6` and `7` are still unclear, we can simply repeat the above process with them:

| Index | Krn/Usr   | Reg `0` | Reg `6` if JIT enabled  | Reg `7` if JIT `rw-` | Reg `7` if JIT `r-x` | Changed? |
|:------|:---------:|:-------:|-------------------------|:--------------------:|:--------------------:|:---------|
| `0x0` | `rwx/--x` | `0x1`   | `0x0`                   | `0x6`                | `0x6`                |          |
| `0x1` | `rwx/---` | `0x0`   | `0x0`                   | `0x7`                | `0x7`                |          |
| `0x2` | `rw-/--x` | `0x0`   | `0x0`                   | `0x7`                | `0x7`                |          |
| `0x3` | `rw-/---` | `0x0`   | `0x0`                   | `0x7`                | `0x7`                |          |
| `0x4` | `rwx/rwx` | `0x7`   | `0x0`                   | `0x0`                | `0x0`                |          |
| `0x5` | `rwx/rw-` | `0x6`   | `0x0`                   | `0x1`                | `0x1`                |          |
| `0x6` | `rw-/rwx` | `0x7`   | `0x1`                   | `0x1`                | `0x2`                | &lt;--   |
| `0x7` | `rw-/rw-` | `0x6`   | `0x0`                   | `0x1`                | `0x1`                |          |
| `0x8` | `r-x/--x` | `0x0`   | `0x0`                   | `0x7`                | `0x7`                |          |
| `0x9` | `r-x/---` | `0x0`   | `0x0`                   | `0x7`                | `0x7`                |          |
| `0xa` | `r--/--x` | `0x1`   | `0x0`                   | `0x6`                | `0x6`                |          |
| `0xb` | `r--/---` | `0x0`   | `0x0`                   | `0x7`                | `0x7`                |          |
| `0xc` | `r-x/r-x` | `0x5`   | `0x0`                   | `0x2`                | `0x2`                |          |
| `0xd` | `r-x/r--` | `0x4`   | `0x0`                   | `0x3`                | `0x3`                |          |
| `0xe` | `r--/r-x` | `0x5`   | `0x0`                   | `0x2`                | `0x2`                |          |
| `0xf` | `r--/r--` | `0x4`   | `0x0`                   | `0x3`                | `0x3`                |          |

The only digit that changed in reg `7` is the one corresponding to `rw-/rwx` - which would seem like the permissions the JIT region is mapped with. And obviously that is also the only index at which reg `6` has a `1`. To not beat around the bush any longer, register `6` tells us whether or not to consult register `7`, and if we do, we use register `7` to _mask out_ certain bits, i.e. if the digit in question is `0x1`, that will _strip_ the executable bit.

With that all figured out, we can complete our register table from above with sensible names:

| Register        | Name               |
|:----------------|:-------------------|
| `s3_4_c15_c2_0` | `APRR0_EL1`        |
| `s3_4_c15_c2_1` | `APRR1_EL1`        |
| `s3_4_c15_c2_2` | `KTRR_LOCK_EL1`    |
| `s3_4_c15_c2_3` | `KTRR_LOWER_EL1`   |
| `s3_4_c15_c2_4` | `KTRR_UPPER_EL1`   |
| `s3_4_c15_c2_5` | `KTRR_UNKNOWN_EL1` |
| `s3_4_c15_c2_6` | `APRR_MASK_EN_EL1` |
| `s3_4_c15_c2_7` | `APRR_MASK_EL0`    |

If this was a bit too much bit shifting and twiddling for you, I have some slides from my TyphoonCon talk on how you get from the page table bits to the actual `rwx` permissions (available in full [here](https://github.com/ssd-secure-disclosure/typhooncon2019/blob/master/Siguza%20-%20Mitigations.pdf), pages pages 103-119).

Here's how it would work in a standard ARMv8.\* implementation:

[![TTE bits][img9]][img9]

And here's how it works on chips with APRR (the orange boxes are register numbers):

[![APRR TTE bits][img10]][img10]

Two notes on these:

- This still isn't the whole picture - there will be more detail further down this post, but that's not gonna fit into a nice graph anymore.
- If you're confused by the bits coming in from the top right, those are the "Hierarchical Permission Disable" bits (HPD). Basically a page table can already have bits set that say it can never map anything as writeable or so, and then the write bit is stripped out of any entry mapped under it.

### Mitigations gone rogue

Remember earlier where I mentioned some people's speculation that Apple has repurposed the UXN bit, and said that was an interesting way to put it? Time to revisit that. Let's look at PPL page tables again:

[![PPL page tables unpriv][img4]][img4]

With knowledge of how APRR works, notice anything off? Anything about `__PPLDATA_CONST`?

Yep, that permission is not remapped (or remapped onto itself, if you will), which means it's actually mapped as `--x` in EL0! This constitutes a vulnerability that lets you brute-force the kASLR slide by simply installing a mach exception handler and repeatedly jumping to locations within the kernel's address range. If you get an exception of type 1, it's unmapped/inaccessible memory, but if you get an exception of type 2, you hit `__PPLDATA_CONST`. (Note that you can't leak data from that page though - you might assume you could, because the exception message contains the faulting instruction. However, that is obtained via `copyin`, which refuses to operate on kernel addresses.) PoC is available [here](https://github.com/Siguza/APRR/blob/master/yolo.c) and is still a 0day at the time of writing.

Now there is _a lot_ of irony in this:

- Not only did random researchers think the UXN bit got repurposed, but so do Apple engineers apparently!
- This is a vulnerability so fundamental that it is trivial to exploit, takes virtually no time, and is reachable from even the most heavily sandboxed contexts.
- It affects _nothing but_ the latest chip generation. A11 and earlier are safe, it only exists on A12/A12X. Or, to quote [Ian Beer](https://twitter.com/i41nbeer) on the matter:

  > So what can you do to protect yourself?  
  > Use an older device\!  
  > _\[is Britishly outraged\]_

- There isn't even a reason to put `__PPLDATA_CONST` under APRR! What are you gonna do, make it _more_ readonly than it already is?
- This is the _peak_ of mitigation madness. We literally have one mitigation breaking another.
- Apple hardware team appears to be really competent, ehh but the software team...

And this isn't even the end of the story, but I'll leave the rest as an exercise to the reader.

### Pentesting APRR

Aside from the info leak that presented itself so openly, let's go back to try and see what protects APRR against a motivated attacker. In the case of JIT, things are pretty simple:

```
0x188347298      002298f2       movk x0, 0xc110
0x18834729c      e0ffbff2       movk x0, 0xffff, lsl 16
0x1883472a0      e001c0f2       movk x0, 0xf, lsl 32
0x1883472a4      0000e0f2       movk x0, 0, lsl 48
0x1883472a8      000040f9       ldr x0, [x0]
0x1883472ac      e0f21cd5       msr s3_4_c15_c2_7, x0
0x1883472b0      df3f03d5       isb
0x1883472b4      012298f2       movk x1, 0xc110
0x1883472b8      e1ffbff2       movk x1, 0xffff, lsl 16
0x1883472bc      e101c0f2       movk x1, 0xf, lsl 32
0x1883472c0      0100e0f2       movk x1, 0, lsl 48
0x1883472c4      280040f9       ldr x8, [x1]
0x1883472c8      e9f23cd5       mrs x9, s3_4_c15_c2_7
0x1883472cc      1f0109eb       cmp x8, x9
0x1883472d0      c1020054       b.ne 0x188347328
```

After the write to the system register, the commpage address is re-constructed and the value re-loaded, and checked against the value currently in the register. This prevents us from ROP'ing into the middle of the memcpy gadget and changing the register to an arbitrary value. So APRR itself is protected, but in the face of a calling primitive, the memcpy function will still happily put some shellcode in the JIT region for you, no change to the system register needed. And once you _have_ code in the JIT region, the entire model falls apart, as you now _can_ freely change the system register.

As for the kernel side, things are more complex there. I'll omit the code for brevity, but a lot more cases have to be considered. The PPL entry gadget also has ROP protection, and the exit gadget is on a page that is only executable in privileged mode, so that doesn't need it. In addition, interrupts as well as panics have to be dealt with in a safe way.  
Panics are handled by having a per-CPU struct in `__PPLDATA`, which contains a flag saying whether we are currently in PPL or not. That flag gets set by the PPL entry tramp and cleared by the exit routing, and `panic` simply calls out to the latter if the flag is set, before continuing down its path.  
Interrupts take a similar, albeit more nuanced approach. For a start, `__PPLTRAMP` has them disabled, but sets `daifset` back to its original value before actually jumping into `__PPLTEXT`. Now rather than checking the per-CPU data struct, the exception vectors for EL1 simply check the APRR register itself, and if it matches the privileged value, go through the PPL exit tramp. If it doesn't though, they still check whether it matches the unprivileged value, and if not, spin. This means that even if you somehow get control of the register, you can't reasonably set it to any value other than the existing two anyway, since the next exception you take will kill you.

So again APRR itself is safe, but what about PPL? Can we pull the same tricks as with JIT? For the most part, PPL seems to carefully sanitise the input you give it. But then at random, for example when it came to the trust cache, they didn't bother with that and put all their faith in PAC instead, only to be monumentally let down. Taking a look at the iOS 13 beta kernels though, this appears fixed.  
Apart from that, it might be noteworthy that, same as with JIT, any single crack will tear the entire model down. If `__PPLDATA` or any single page table can be remapped as non-PPL, or can be written to by other means, via peripherals or the dark arts, then that can immediately be used to extend this capability to the rest of PPL-protected memory. But eh, it's probably fine, right? ;)

### Digging deeper

What XNU does with APRR is... alright I guess, but _when_ we get such an undocumented blackbox feature, it would be outright irresponsible to not go and drive it up to its limits, right?

Again, getting shellcode execution in EL1 is left as an exercise to the reader (be that in skill or patience), but once you do have that, there's a good bunch of things to test:

- When were these registers actually introduced?
- What do they reset to?
- What are their maximal and minimal values? Can you just set `APRR0_EL1` to `0x7777777777777777` and access kernel memory from userland?
- Is the 0x8 bit settable in any field? Does it have a function?
- How does HPD affect KTRR?
- What about PAN (SMAP) and WXN?
- Are the permissions accurately reflected by the `AT` instruction?
- Can you create otherwise unobtainable permissions, such as write-only?

To answer all of that, I wrote a good bunch of shellcode that will run a number of different tests and dump the results into memory. The code is available [here](https://github.com/Siguza/APRR) and raw results [here](https://github.com/Siguza/APRR/tree/master/results).

In summary:

- Registers `6` and `7` appeared on the A11, but the core APRR registers `0` and `1` are present back on the A10 already. (Apple seems to have been planning this for quite a while!)
- Unlike virtually any other register, registers `0` and `1` reset to their _maximum_ values, which are `0x4545010167670101`/`0x4455445566666677` respectively.
- Every bit can be set to zero, but bits that are zero at reset can never be set to one. This also means the `0x8` bit is never settable.
- TTE and HPD bits are processed before anything else. This yields what I call the "input value".
- The input value is then copied to a "working value", to which APRR, PAN and WXN are applied. Each of these modifies the working value, but makes decisions based on the _input value_ rather than the working value.
- The `at` instructions _do_ accurately reflect the effective permissions.
- It _is_ possible to create write-only memory and such.

Amidst all my test results, something stood out though: weird things happen when you turn on both PAN and WXN. Let's diff `0xffffffffffffffff-0xffffffffffffffff-PAN-WXN.txt` and `0xfff0fff0fff0fff0-0xfff0fff0fff0fff0-PAN-WXN.txt`, for example:

[![diff][img11]][img11]

It's the first line that's off here. APRR would dictate that the permissions should be none, yet EL1 can read and write. It appears that, if all of the following are true:

- PAN is enabled
- WXN is enabled
- The access is privileged
- WXN applies
- PAN does not apply

Then the APRR register is not consulted. In addition, for the `at` instruction it seems to be enough to have both PAN and WXN enabled to break everything:

[![diff][img12]][img12]

For what it's worth, XNU runs with PAN on and WXN off - but still! How does something like that happen?! Is there some Verilog code passage now where it says `=` when it should say `&=`? Did I say Apple's hardware team was really competent? I might have to track back a bit on that... but yet again already we've seen one mitigation break another.

### Conclusion

APRR is a pretty cool feature, even if parts of it are kinda broke. What I really like about it (besides the fact that it is an efficient and elegant solution to switching privileges) is that it untangles EL1 and EL0 memory permissions, giving you more flexibility than a standard ARMv8 implementation. What I don't like though is that it has clearly been designed as a lockdown feature, allowing you only to take permissions away rather than freely remap them.

It's also evident that Apple is really fond of post-exploit mitigations, or just mitigations in general. And on one hand, getting control over the physical address space is a good bit harder now. But on the other hand, Apple's stacking of mitigations is taking a problematic turn when adding new mitigations actively creates vulnerabilities now.

But at last, we might have gathered enough information to make an educated guess as to what the acronym "APRR" actually stands for. My best guess is "Access Protection ReRouting".  
I hear when Project Zero tries to guess the meaning behind acronyms though, all Apple engineers have to offer is a smug grin, so maybe it's also just "APple Rick Rolling".

For typos, feedback, content questions etc, feel free to [open a ticket](https://github.com/Siguza/APRR/issues), [ping me on Twitter](https://twitter.com/s1guza) or email me (`*@*.net` where `*` = `siguza`).

Till next time, peace out. ;)

### Thanks to

- [windknown](https://twitter.com/windknown) for being the reason I started looking into APRR.
- [qwerty](https://twitter.com/qwertyoruiopz) for being there to bounce ideas off of one another.
- [Sparkey](https://twitter.com/iBSparkes) for testing a bunch of stuff for me on devices I didn't have.

<!-- link references -->

  [img1]: assets/img/1-pages.svg
  [img2]: assets/img/2-tweet.png
  [img3]: assets/img/3-ttes.png
  [img4]: assets/img/4-ttes-unpriv.png
  [img5]: assets/img/5-ttes-priv.png
  [img6]: assets/img/6-oldjit.png
  [img7]: assets/img/7-newjit.png
  [img8]: assets/img/8-mair.png
  [img9]: assets/img/9-tte-bits.png
  [img10]: assets/img/10-aprr-bits.png
  [img11]: assets/img/11-diff1.png
  [img12]: assets/img/12-diff2.png
