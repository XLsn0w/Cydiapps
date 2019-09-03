{
  "targets": [
    {
      "target_name": "cytest_binding",
      "sources": [
        "addon.cpp",
      ],
      "include_dirs": [
        "../src",
      ],
      "target_conditions": [
        ["OS=='win'", {
          "library_dirs": [
            "../build/src",
          ],
          "libraries": [
            "-llibcycript.a",
          ],
        }, {
          "cflags!": [
            "-fno-exceptions",
          ],
          "cflags_cc!": [
            "-fno-exceptions",
          ],
          "library_dirs": [
            "../../build/src",
          ],
          "libraries": [
            "-lcycript",
          ],
        }],
        ["OS=='mac'", {
          "xcode_settings": {
            'GCC_ENABLE_CPP_EXCEPTIONS': 'YES',
            "OTHER_CFLAGS": [
              "-std=c++11",
              "-stdlib=libc++",
              "-mmacosx-version-min=10.9",
            ],
            "OTHER_LDFLAGS": [
              "-Wl,-macosx_version_min,10.9",
              "-Wl,-dead_strip",
              "-Wl,-exported_symbols_list,binding.symbols",
            ],
          },
        }],
        ["OS=='linux'", {
          "cflags": [
            "-std=c++11",
            "-ffunction-sections",
            "-fdata-sections",
          ],
          "ldflags": [
            "-Wl,--gc-sections",
            "-Wl,--version-script",
            "-Wl,../binding.version",
          ],
        }],
      ],
    },
  ],
}
