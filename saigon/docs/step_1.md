# How to find the driver's kext:

In iOS, drivers(kexts) are included within the kernelcache. Follow the steps to get the kext for your driver.

## Step (1) Get the ipsw file for your device/iOS:
-Go to https://ipsw.me/

-Search for your device (e.g. iPhone 6)

-Choose the iOS version (e.g. iOS 10.2.1 (14D27))

-Download the file

## Step (2) Get the kernel cache and decrypt it:
-Change the extenstion of the downloaded file to .zip (.ipsw -> .zip)

-Extract the .zip file then find the "kernelcache" file inside (e.g. kernelcache.release.n61)

-Now, get `lzssdec` from [here](https://gist.github.com/matteyeux/193290d17bee4698fb9dc819732580b3)

-Compile `lzssdec` by opening the Terminal and type the following:

`g++ lzssdec.cpp -o lzssdec`

-Also, run:

`hexdump -C path_to_your_kernel_cache | head` (e.g. `hexdump -C /Users/cheesecakeufo/kernelcache.release.n61 | head`)

Notice the offset (`000001b0`):
```
00000000  30 83 bc a5 d4 16 04 49  4d 34 50 16 04 6b 72 6e  |0......IM4P..krn|
00000010  6c 16 1c 4b 65 72 6e 65  6c 43 61 63 68 65 42 75  |l..KernelCacheBu|
00000020  69 6c 64 65 72 2d 31 31  36 32 2e 33 30 2e 31 04  |ilder-1162.30.1.|
00000030  83 bc a5 a5 63 6f 6d 70  6c 7a 73 73 6e 2f c2 86  |....complzssn/..|
00000040  01 74 c0 00 00 bc 34 25  00 00 00 01 00 00 00 00  |.t....4%........|
00000050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
*
000001b0  00 00 00 00 ff cf fa ed  fe 0c 00 00 01 d5 00 f6  |................|
000001c0  f0 02 f6 f0 14 f6 f0 38  0e 9a f3 f1 20 f6 f1 00  |.......8.... ...|
000001d0  19 ff f1 f5 f0 5f 9f 5f  54 45 58 54 09 02 1c 03  |....._._TEXT....|
```
`000001b0` -> `00 00 00 00 ff cf fa ed  fe` -> `000001b4` -> `0x1b4`

-Use `0x1b4` to decrypt the kernel with  `lzssdec`:

`lzssdec -o 0x1b4 < path_to_your_kernel > path_to_your_kernel.dec`

Now that we have the decrypted kernel, we can use `joker` to get the list of kexts available.

## Step (3) Use joker to list and extract the kexts:

-Download `joker` by Jonathan Levin from [here](http://newosxbook.com/tools/joker.html)

-Extract the .tar file then open Terminal

-Run the following:

`./joker.universal -k path_to_your_kernel.dec > kexts_list` (note: make sure it's lower -k)

-Open the new `kexts_list` and you will find a long list of available kexts.

-Find the kext you're looking for (e.g. AppleAVEH7 or VXE380)

-The matching find will be a line like this:

`0xfffffff006166140: H264 Video Encoder (com.apple.driver.AppleAVEH7)`

-Use the full name of the driver to extract it with `joker`:

`./joker.universal -K com.apple.driver.AppleAVEH7 path_to_your_kernel.dec` (note: make sure it's upper -K)

## Step (4) Reverse Engineering the kext:

Once you extract a kext, `joker` will try to symbolicate some of the addresses in the kext to make your life easier.

-You can find the kext and the symbolicated file in `/tmp`:

Cmd + Shift + G in Finder then type `/tmp/`

-You'll see two files starting with your driver's name (e.g. `com.apple.xxxx`)

-Copy the files to a desired directory

-Rename the file (not ending with extenstion .kext) to kext_companion

-Open your .kext in IDA Pro(Preferred)/Hopper

