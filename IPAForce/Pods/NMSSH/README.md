# NMSSH [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

NMSSH is a clean, easy-to-use, unit tested framework for iOS and OSX that wraps libssh2.

## Questions & Issues

If you encounter an issue or have any questions about implementing NMSSH, please post them in [the issue tracker](https://github.com/NMSSH/NMSSH/issues) – we do not offer free support via email.

## Installation

### CocoaPods

    pod 'NMSSH'

### Carthage

    github "NMSSH/NMSSH"

### Build from source

Consult the Wiki for detailed information about how to:

* [Build for OSX](https://github.com/NMSSH/NMSSH/wiki/Build-and-use-in-your-OSX-project) or
* [Build for iOS](https://github.com/NMSSH/NMSSH/wiki/Build-and-use-in-your-iOS-project).

### Include it in your project

Add `#import <NMSSH/NMSSH.h>` to your source file.

### OpenSSL and Libssh2 binaries

NMSSH includes a precompiled version of Libssh2 and OpenSSL compiled with [this script](https://github.com/Frugghi/iSSH2). You can easily recompile the libraries and replace the binaries.

## What does it look like?

```objc
NMSSHSession *session = [NMSSHSession connectToHost:@"127.0.0.1:22"
                                       withUsername:@"user"];

if (session.isConnected) {
    [session authenticateByPassword:@"pass"];

    if (session.isAuthorized) {
        NSLog(@"Authentication succeeded");
    }
}
    
NSError *error = nil;
NSString *response = [session.channel execute:@"ls -l /var/www/" error:&error];
NSLog(@"List of my sites: %@", response);
    
BOOL success = [session.channel uploadFile:@"~/index.html" to:@"/var/www/9muses.se/"];

[session disconnect];
```

## API Documentation

API documentation for NMSSH is available at [http://cocoadocs.org/docsets/NMSSH/](http://cocoadocs.org/docsets/NMSSH/).

## Guidelines for contributions

* Follow the [code conventions](https://github.com/Lejdborg/cocoa-conventions/).
* Fork NMSSH and create a feature branch. Develop your feature.
* Open a pull request.

**Note:** Make sure that you have _documented your code_ and that you _follow the code conventions_ before opening a pull request.

## NMSSH is used in

* [iTerm2](https://github.com/gnachman/iTerm2)
* [DogeWallet](https://github.com/SlayterDev/DogeWallet)

## Developed by

### Core team

* [Christoffer Lejdborg (@Lejdborg)](https://github.com/Lejdborg) (creator)
* [Tommaso Madonia (@Frugghi)](https://github.com/Frugghi)

### Contributors

* [Sebastian Hunkeler (@lightforce)](https://github.com/lightforce)
* [Endika Gutiérrez (@endSly)](https://github.com/endSly)
* [Clemens Gruber (@clemensg)](https://github.com/clemensg)
* [@gnachman](https://github.com/gnachman)
* [@Shirk](https://github.com/Shirk)
* [@touta](https://github.com/touta)

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
