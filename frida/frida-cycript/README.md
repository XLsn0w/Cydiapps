# frida-cycript

This is a fork of [Cycript] [1] in which we replaced its runtime with a brand
new runtime called [Mjølner] [3] powered by [Frida] [4]. This enables
frida-cycript to run on all the platforms and architectures maintained by
[frida-core] [8].

# Motivation

<img src="https://github.com/nowsecure/cycript/raw/master/docs/demo.gif" width="583" />

[Cycript] [1] is an awesome interactive console for exploring and modifying
running applications on iOS, Mac, and Android. It was created by [@saurik] [2]
and essentially consists of four parts:

1. Its readline-based user interface;
2. Compiler that takes cylang as input and produces plain JavaScript as output;
3. A runtime that executes the plain JavaScript on JavaScriptCore, providing a
   set of APIs expected by the compiled scripts, plus some facilities for
   injecting itself into remote processes;
4. A couple of "user-space" modules written in cylang.

We didn't touch any other aspects of Cycript or did so with minimal changes.

We went out of our way to avoid touching the compiler, and also left the user
interface mostly untouched, only adding extra CLI switches for things like
device selection. We did, however, mostly rewrite the Cydia Substrate module
so existing scripts relying on this will get the portability and [performance
boost] [5] offered by Frida's instrumentation core.

We will be maintaining this fork and intend to stay in sync with user interface
and language improvements made upstream.

## FAQ

### What are some advantages of this fork?

WE believe the main advantage is portability, but also think you should consider:

- Ability to attach to sandboxed apps on Mac, without touching /usr or modifying
  the system in any way;
- Instead of crashing the process if you make a mistake and access a bad
  pointer, you will get a JavaScript exception;
- Frida's function hooking is able to hook many functions not supported by
  Cydia Substrate.

### What are some disadvantages?

Our runtime doesn't yet support all the features that upstream's runtime does,
but we are working hard to close this gap. Please file issues if something you
rely on isn't working as expected.

### Is Windows support planned?

Yes. You should already be able to do this by running frida-server on Windows
and connecting to it with Cycript on your UNIX system. (We didn't try this yet
so please tell us if and how it works for you.)

### How does this benefit existing Frida-users building their own tools?

We have improved [frida-compile] [7] to support cylang by integrating the
Cycript compiler. Sources with a .cy extension get compiled transparently, and
this "just works" as long as [our runtime] [3] is also included in the compiled
agent.

## Status

Please see [our test-suite] [6] to get an overview of what we currently support.

## Building

### macOS

Install Meson and Ninja:

    pip3 install meson
    brew install ninja

Clone this repo:

    git clone https://github.com/nowsecure/frida-cycript.git
    cd frida-cycript
    git submodule init
    git submodule update

Generate the build system:

    meson build --buildtype minsize --strip

Build:

    ninja -C build

Run Cycript:

    ./build/src/cycript

Run the test-suite:

    cd test && npm install && npm run test

To build the Node.js bindings:

    meson build --buildtype minsize --strip --default-library static -D enable_engine=false -D enable_console=false
    ninja -C build
    cd bindings/node/cylang/
    npm install

### Windows

Install Meson and Ninja, and clone this repo, similar to above.

To build the Node.js bindings from a MSVS Native Tools Command Prompt for VS 2017:

    meson build --buildtype minsize --strip --default-library static -D enable_engine=false -D enable_console=false -D b_vscrt=mt
    ninja -C build
    cd bindings\node\cylang
    npm install

Then to run the test-suite:

    npm run test

  [1]: http://www.cycript.org/
  [2]: https://twitter.com/saurik
  [3]: https://github.com/nowsecure/mjolner
  [4]: http://www.frida.re/
  [5]: https://gist.github.com/oleavr/bfd9b65865e9f17914f2
  [6]: https://github.com/nowsecure/cycript/blob/master/test/types.js
  [7]: https://github.com/frida/frida-compile
  [8]: https://github.com/frida/frida-core/tree/master/src
