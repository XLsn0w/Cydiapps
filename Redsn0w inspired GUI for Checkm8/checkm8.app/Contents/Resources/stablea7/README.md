# StableA7

Downgrades any A7 iOS device to 10.3.3 using checkm8

## Notes

- This is a **beta version** which means that things could/probably will be broken.

## Usage

Simply run this command in Terminal:

`bash <(curl -s https://gitlab.com/snippets/1907816/raw)`

## Feedback

If you have any issues with the script or just want to tell me that it works, you can fill out [a quick form](https://forms.gle/qcYgpNjCouehFksc7).

You can also contact me on Twitter ([@ConsoleLogLuke](https://twitter.com/ConsoleLogLuke)) if you'd prefer that.

## Credit

I couldn't have made this alone, these amazing people contributed indirectly:

- [@mosk_i](https://twitter.com/mosk_i) who has way more knowledge on downgrades than I do, I used his guide and script as a reference for this

- [@axi0mX](https://twitter.com/axi0mX) who discovered and released the checkm8 exploit that this script takes advantage of

- [@s0uthwes](https://twitter.com/s0uthwes) who maintains his own fork of futurerestore, tsschecker, and igetnonce

- [@tihmstar](https://twitter.com/tihmstar) who originally created futurerestore, tsschecker, and igetnonce

- [@LinusHenze](https://twitter.com/LinusHenze) who forked ipwndfu to remove signature checks

- [@alitek12](https://twitter.com/alitek123) who created the OTA build manifests

Huge thanks to these people and the many others who contributed in one way or another.

## Support

### Devices

- iPhone6,1 (iPhone 5S)

- iPhone6,2 (iPhone 5S)

- iPad4,1 (iPad Air - Wi-Fi; currently broken)

- iPad4,2 (iPad Air - Cellular; currently broken)

- iPad4,4 (iPad Mini 2 - Wi-Fi)

- iPad4,5 (iPad Mini 2 - Cellular)

### macOS

- macOS 10.13 High Sierra (currently broken)

- macOS 10.14 Mojave

- macOS 10.15 Catalina

A Hackintosh on these macOS versions will also work but a VM will not.

## Known Issues

- macOS 10.13 High Sierra support is broken

- The script is sometimes downloaded as a .txt file

- ~~ipwndfu sometimes doesn't work at all~~

- Python sometimes crashes when running ipwndfu

- Homebrew sometimes fails to install dependencies

- iPad Air support is broken
