/* Cycript - The Truly Universal Scripting Language
 * Copyright (C) 2009-2016  Jay Freeman (saurik)
*/

/* GNU Affero General Public License, Version 3 {{{ */
/*
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.

 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.

 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

#define __USE_EXTERN_INLINES

#include <dirent.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <sys/mman.h>
#include <sys/mount.h>
#include <sys/stat.h>

#include <sqlite3.h>

#if CY_JAVA
#if defined(__APPLE__) && !defined(__arm__)
#include <JavaVM/jni.h>
#endif
#endif

#if CY_RUBY
#ifdef __APPLE__
#include <Ruby/ruby.h>
#else
#include <ruby.h>
#endif
#endif

#if CY_PYTHON
#include <Python.h>
#endif

#if CY_OBJECTIVEC && defined(__APPLE__)
#include <objc/runtime.h>
#endif

#ifdef __APPLE__
#include <AddressBook/AddressBook.h>
#include <CoreData/CoreData.h>
#include <CoreLocation/CoreLocation.h>
#include <MapKit/MapKit.h>
#include <Security/Security.h>

#include <dispatch/dispatch.h>

#include <mach/mach.h>
#include <mach/mach_vm.h>
#include <mach/vm_map.h>

#include <mach-o/dyld.h>
#include <mach-o/dyld_images.h>
#include <mach-o/nlist.h>

#if TARGET_OS_IPHONE
#include <UIKit/UIKit.h>
extern "C" UIApplication *UIApp;
#else
#include <AppKit/AppKit.h>
#endif
#endif

#ifdef __ANDROID__
#include <android/log.h>
#endif
