project('frida-cycript', 'c', 'cpp',
  version: '2.0.5',
  default_options: ['cpp_std=c++11'],
)

host_os_family = host_machine.system()
host_os = host_os_family
host_arch = host_machine.cpu_family()

c_languages = ['c']
cpp_languages = ['cpp']
if host_os_family == 'darwin'
  c_languages += 'objc'
  cpp_languages += 'objcpp'

  add_languages('objc', 'objcpp')
endif
languages = c_languages + cpp_languages

cc = meson.get_compiler('c')
cpp = meson.get_compiler('cpp')

target_conditionals_prefix = '#include <TargetConditionals.h>'

is_macos_src = target_conditionals_prefix + '''
#if !TARGET_OS_OSX
# error Not macOS
#endif
'''
if cc.compiles(is_macos_src, name: 'compiling for macOS')
  host_os = 'macos'
endif

is_ios_src = target_conditionals_prefix + '''
#if !TARGET_OS_IOS
# error Not iOS
#endif
'''
if cc.compiles(is_ios_src, name: 'compiling for iOS')
  host_os = 'ios'
endif

if cc.has_header('android/api-level.h')
  host_os = 'android'
endif

if host_os == 'macos'
  add_global_arguments('-mmacosx-version-min=10.9', language: languages)
  add_global_link_arguments('-mmacosx-version-min=10.9', language: languages)
endif

compiler_id = cc.get_id()

if compiler_id == 'gcc'
  add_global_arguments('-static-libgcc', language: languages)
  add_global_link_arguments('-static-libgcc', language: languages)

  add_global_arguments('-static-libstdc++', language: cpp_languages)
  add_global_link_arguments('-static-libstdc++', language: cpp_languages)
endif
if compiler_id == 'clang'
  add_global_arguments('-stdlib=libc++', language: cpp_languages)
  add_global_link_arguments('-stdlib=libc++', language: cpp_languages)
endif

optimization_compile_args = []
optimization_link_args = []
buildtype = get_option('buildtype')
if buildtype == 'release' or buildtype == 'minsize'
  if host_os_family == 'darwin'
    optimization_link_args += '-Wl,-dead_strip'
  endif
  if host_os_family == 'linux'
    optimization_compile_args += [
      '-ffunction-sections',
      '-fdata-sections',
    ]
    optimization_link_args += '-Wl,--gc-sections'
  endif
endif
add_global_arguments(optimization_compile_args, language: languages)
add_global_link_arguments(optimization_link_args, language: languages)

python3 = import('python').find_installation()

if build_machine.system() == 'windows'
  flex = find_program(files('ext/toolchain/usr/bin/flex.exe'))
else
  flex = find_program('flex')
endif
bison = find_program(files('ext/toolchain/usr/bin/bison.py'))

cdata = configuration_data()

host_os_id = '1'
cdata.set_quoted('CY_SYSTEM', host_os_id)

enable_objc = true
cdata.set10('CY_OBJECTIVEC', enable_objc)

enable_java = true
cdata.set10('CY_JAVA', enable_java)

enable_ruby = true
cdata.set10('CY_RUBY', enable_ruby)

if get_option('enable_engine')
  cdata.set('CY_EXECUTE', 1)
endif

thread_dep = dependency('threads')

extra_libs = []
analyze_extra_includes = []

if get_option('enable_engine')
  npm = find_program('npm')

  if not cc.has_header('sqlite3.h')
    error('sqlite3 is required when engine is enabled')
  endif
  extra_libs += ['-lsqlite3']

  python = get_option('with-python')
  if python != 'no'
    enable_python = true

    result = run_command(python, '-c',
      'from distutils import sysconfig; import sys; sys.stdout.write(sysconfig.get_python_inc())')
    if result.returncode() != 0
      error('Unable to detect Python include directory: ' + result.stdout() + result.stderr())
    endif
    python_incdir = result.stdout()

    analyze_extra_includes += '-I' + python_incdir
  else
    enable_python = false
  endif

  if build_machine.system() == 'darwin'
    result = run_command('scripts/detect-xcode-clang-libdir')
    clang_libdir = result.stdout().strip()
    clang_dep = cc.find_library('clang', dirs: clang_libdir)
  else
    clang_libdir = ''
    clang_dep = cc.find_library('clang')
  endif
else
  enable_python = false
endif
cdata.set10('CY_PYTHON', enable_python)

if get_option('enable_console')
  readline = subproject('readline')
  readline_dep = readline.get_variable('readline_static_dep')

  if cc.has_function('cur_term', args: ['-ltermcap'])
    termcap_libs = ['-ltermcap']
  elif cc.has_function('cur_term', args: ['-lncurses'])
    termcap_libs = ['-lncurses']
  else
    error('termcap or ncurses is required')
  endif
endif

configure_file(output: 'config.h',
  configuration: cdata)

if compiler_id == 'msvc'
  add_project_arguments('/FI', join_paths(meson.current_build_dir(), 'config.h'), language: languages)
else
  add_project_arguments('-include', 'config.h', language: languages)
endif

if compiler_id == 'msvc'
  warning_suppression_flags = [
    '/wd4005',
    '/wd4244',
    '/wd4291',
    '/wd4715',
  ]
  add_project_arguments(warning_suppression_flags, language: languages)
elif compiler_id == 'gcc' or compiler_id == 'clang'
  add_project_arguments('-fvisibility=hidden', language: languages)

  candidate_c_flags = [
    ## XXX: this one is used to support GNU Objective-C struct objc_method
    '-Wno-deprecated-declarations',
    '-Wno-dangling-else',
    '-Wno-empty-body',
    '-Wno-parentheses',
    '-Wno-tautological-undefined-compare',
    '-Wno-unneeded-internal-declaration',
    '-Wno-inconsistent-missing-override',
  ]
  extra_c_args = []
  foreach flag : candidate_c_flags
    if cc.has_argument(flag)
      extra_c_args += [flag]
    endif
  endforeach
  add_project_arguments(extra_c_args, language: languages)

  candidate_cpp_flags = [
    '-Wno-non-virtual-dtor',
    '-Wno-overloaded-virtual',
  ]
  extra_cpp_args = []
  foreach flag : candidate_cpp_flags
    if cpp.has_argument(flag)
      extra_cpp_args += [flag]
    endif
  endforeach
  add_project_arguments(extra_cpp_args, language: cpp_languages)
endif

subdir('src')
