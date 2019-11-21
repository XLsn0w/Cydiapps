/* Cydia - iPhone UIKit Front-End for Debian APT
 * Copyright (C) 2008-2015  Jay Freeman (saurik)
*/

/* GNU General Public License, Version 3 {{{ */
/*
 * Cydia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation, either version 3 of the License,
 * or (at your option) any later version.
 *
 * Cydia is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Cydia.  If not, see <http://www.gnu.org/licenses/>.
**/
/* }}} */

// XXX: wtf/FastMalloc.h... wtf?
#define USE_SYSTEM_MALLOC 1

/* #include Directives {{{ */
#include "CyteKit/UCPlatform.h"
#include "CyteKit/Localize.h"

#include <unicode/ustring.h>
#include <unicode/utrans.h>

#include <objc/objc.h>
#include <objc/runtime.h>

#include <CoreGraphics/CoreGraphics.h>
#include <Foundation/Foundation.h>

#if 0
#define DEPLOYMENT_TARGET_MACOSX 1
#define CF_BUILDING_CF 1
#include <CoreFoundation/CFInternal.h>
#endif

#include <CoreFoundation/CFUniChar.h>

#include <SystemConfiguration/SystemConfiguration.h>

#include <UIKit/UIKit.h>
#include "iPhonePrivate.h"

#include <QuartzCore/CALayer.h>

#include <WebCore/WebCoreThread.h>

#include <algorithm>
#include <fstream>
#include <iomanip>
#include <set>
#include <sstream>
#include <string>

#include "fdstream.hpp"

#undef ABS

#include "apt.h"
#include <apt-pkg/acquire.h>
#include <apt-pkg/acquire-item.h>
#include <apt-pkg/algorithms.h>
#include <apt-pkg/cachefile.h>
#include <apt-pkg/clean.h>
#include <apt-pkg/configuration.h>
#include <apt-pkg/debindexfile.h>
#include <apt-pkg/debmetaindex.h>
#include <apt-pkg/error.h>
#include <apt-pkg/init.h>
#include <apt-pkg/mmap.h>
#include <apt-pkg/pkgrecords.h>
#include <apt-pkg/sha1.h>
#include <apt-pkg/sourcelist.h>
#include <apt-pkg/sptr.h>
#include <apt-pkg/strutl.h>
#include <apt-pkg/tagfile.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <sys/sysctl.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <sys/reboot.h>

#include <dirent.h>
#include <fcntl.h>
#include <notify.h>
#include <dlfcn.h>

extern "C" {
#include <mach-o/nlist.h>
}

#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <errno.h>

#include <Cytore.hpp>
#include "Sources.h"

#include "Substrate.hpp"
#include "Menes/Menes.h"

#include "CyteKit/CyteKit.h"
#include "CyteKit/RegEx.hpp"

#include "Cydia/MIMEAddress.h"
#include "Cydia/LoadingViewController.h"
#include "Cydia/ProgressEvent.h"
/* }}} */

/* Profiler {{{ */
struct timeval _ltv;
bool _itv;

#define _timestamp ({ \
    struct timeval tv; \
    gettimeofday(&tv, NULL); \
    tv.tv_sec * 1000000 + tv.tv_usec; \
})

typedef std::vector<class ProfileTime *> TimeList;
TimeList times_;

class ProfileTime {
  private:
    const char *name_;
    uint64_t total_;
    uint64_t count_;

  public:
    ProfileTime(const char *name) :
        name_(name),
        total_(0)
    {
        times_.push_back(this);
    }

    void AddTime(uint64_t time) {
        total_ += time;
        ++count_;
    }

    void Print() {
        if (total_ != 0)
            std::cerr << std::setw(7) << count_ << ", " << std::setw(8) << total_ << " : " << name_ << std::endl;
        total_ = 0;
        count_ = 0;
    }
};

class ProfileTimer {
  private:
    ProfileTime &time_;
    uint64_t start_;

  public:
    ProfileTimer(ProfileTime &time) :
        time_(time),
        start_(_timestamp)
    {
    }

    ~ProfileTimer() {
        time_.AddTime(_timestamp - start_);
    }
};

void PrintTimes() {
    for (TimeList::const_iterator i(times_.begin()); i != times_.end(); ++i)
        (*i)->Print();
    std::cerr << "========" << std::endl;
}

#define _profile(name) { \
    static ProfileTime name(#name); \
    ProfileTimer _ ## name(name);

#define _end }
/* }}} */

extern NSString *Cydia_;

#define lprintf(args...) fprintf(stderr, args)

#define ForRelease 1
#define TraceLogging (1 && !ForRelease)
#define HistogramInsertionSort (0 && !ForRelease)
#define ProfileTimes (0 && !ForRelease)
#define ForSaurik (0 && !ForRelease)
#define LogBrowser (0 && !ForRelease)
#define TrackResize (0 && !ForRelease)
#define ManualRefresh (1 && !ForRelease)
#define ShowInternals (0 && !ForRelease)
#define AlwaysReload (0 && !ForRelease)

#if !TraceLogging
#undef _trace
#define _trace(args...)
#endif

#if !ProfileTimes
#undef _profile
#define _profile(name) {
#undef _end
#define _end }
#define PrintTimes() do {} while (false)
#endif

// Hash Functions/Structures {{{
extern "C" uint32_t hashlittle(const void *key, size_t length, uint32_t initval = 0);

union SplitHash {
    uint32_t u32;
    uint16_t u16[2];
};
// }}}

static NSString *Colon_;
NSString *Elision_;
static NSString *Error_;
static NSString *Warning_;

static NSString *Cache_;
#define Cache(file) \
    [NSString stringWithFormat:@"%@/%s", Cache_, file]

static void (*$SBSSetInterceptsMenuButtonForever)(bool);
static NSData *(*$SBSCopyIconImagePNGDataForDisplayIdentifier)(NSString *);

static CFStringRef (*$MGCopyAnswer)(CFStringRef);

static NSString *UniqueIdentifier(UIDevice *device = nil) {
    if (kCFCoreFoundationVersionNumber < 800) // iOS 7.x
        return [device ?: [UIDevice currentDevice] uniqueIdentifier];
    else
        return [(id)$MGCopyAnswer(CFSTR("UniqueDeviceID")) autorelease];
}

static const NSUInteger UIViewAutoresizingFlexibleBoth(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);

static _finline NSString *CydiaURL(NSString *path) {
    char page[26];
    page[0] = 'h'; page[1] = 't'; page[2] = 't'; page[3] = 'p'; page[4] = 's';
    page[5] = ':'; page[6] = '/'; page[7] = '/'; page[8] = 'c'; page[9] = 'y';
    page[10] = 'd'; page[11] = 'i'; page[12] = 'a'; page[13] = '.'; page[14] = 's';
    page[15] = 'a'; page[16] = 'u'; page[17] = 'r'; page[18] = 'i'; page[19] = 'k';
    page[20] = '.'; page[21] = 'c'; page[22] = 'o'; page[23] = 'm'; page[24] = '/';
    page[25] = '\0';
    return [[NSString stringWithUTF8String:page] stringByAppendingString:path];
}

static NSString *ShellEscape(NSString *value) {
    return [NSString stringWithFormat:@"'%@'", [value stringByReplacingOccurrencesOfString:@"'" withString:@"'\\''"]];
}

static _finline void UpdateExternalStatus(uint64_t newStatus) {
    int notify_token;
    if (notify_register_check("com.saurik.Cydia.status", &notify_token) == NOTIFY_STATUS_OK) {
        notify_set_state(notify_token, newStatus);
        notify_cancel(notify_token);
    }
    notify_post("com.saurik.Cydia.status");
}

/* NSForcedOrderingSearch doesn't work on the iPhone */
static const NSStringCompareOptions MatchCompareOptions_ = NSLiteralSearch | NSCaseInsensitiveSearch;
static const NSStringCompareOptions LaxCompareOptions_ = NSNumericSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch | NSCaseInsensitiveSearch;
static const CFStringCompareFlags LaxCompareFlags_ = kCFCompareNumerically | kCFCompareWidthInsensitive | kCFCompareForcedOrdering;

/* Insertion Sort {{{ */

template <typename Type_>
size_t CFBSearch_(const Type_ &element, const void *list, size_t count, CFComparisonResult (*comparator)(Type_, Type_, void *), void *context) {
    const char *ptr = (const char *)list;
    while (0 < count) {
        size_t half = count / 2;
        const char *probe = ptr + sizeof(Type_) * half;
        CFComparisonResult cr = comparator(element, * (const Type_ *) probe, context);
        if (0 == cr) return (probe - (const char *)list) / sizeof(Type_);
        ptr = (cr < 0) ? ptr : probe + sizeof(Type_);
        count = (cr < 0) ? half : (half + (count & 1) - 1);
    }
    return (ptr - (const char *)list) / sizeof(Type_);
}

template <typename Type_>
void CYArrayInsertionSortValues(Type_ *values, size_t length, CFComparisonResult (*comparator)(Type_, Type_, void *), void *context) {
    if (length == 0)
        return;

#if HistogramInsertionSort > 0
    uint32_t total(0), *offsets(new uint32_t[length]);
#endif

    for (size_t index(1); index != length; ++index) {
        Type_ value(values[index]);
#if 0
        size_t correct(CFBSearch_(value, values, index, comparator, context));
#else
        size_t correct(index);
        while (comparator(value, values[correct - 1], context) == kCFCompareLessThan) {
#if HistogramInsertionSort > 1
            NSLog(@"%@ < %@", value, values[correct - 1]);
#endif
            if (--correct == 0)
                break;
            if (index - correct >= 8) {
                correct = CFBSearch_(value, values, correct, comparator, context);
                break;
            }
        }
#endif
        if (correct != index) {
            size_t offset(index - correct);
#if HistogramInsertionSort
            total += offset;
            ++offsets[offset];
            if (offset > 10)
                NSLog(@"Heavy Insertion Displacement: %u = %@", offset, value);
#endif
            memmove(values + correct + 1, values + correct, sizeof(const void *) * offset);
            values[correct] = value;
        }
    }

#if HistogramInsertionSort > 0
    for (size_t index(0); index != range.length; ++index)
        if (offsets[index] != 0)
            NSLog(@"Insertion Displacement [%u]: %u", index, offsets[index]);
    NSLog(@"Average Insertion Displacement: %f", double(total) / range.length);
    delete [] offsets;
#endif
}

/* }}} */

/* Cydia NSString Additions {{{ */
@interface NSString (Cydia)
- (NSComparisonResult) compareByPath:(NSString *)other;
- (NSString *) stringByAddingPercentEscapesIncludingReserved;
@end

@implementation NSString (Cydia)

- (NSComparisonResult) compareByPath:(NSString *)other {
    NSString *prefix = [self commonPrefixWithString:other options:0];
    size_t length = [prefix length];

    NSRange lrange = NSMakeRange(length, [self length] - length);
    NSRange rrange = NSMakeRange(length, [other length] - length);

    lrange = [self rangeOfString:@"/" options:0 range:lrange];
    rrange = [other rangeOfString:@"/" options:0 range:rrange];

    NSComparisonResult value;

    if (lrange.location == NSNotFound && rrange.location == NSNotFound)
        value = NSOrderedSame;
    else if (lrange.location == NSNotFound)
        value = NSOrderedAscending;
    else if (rrange.location == NSNotFound)
        value = NSOrderedDescending;
    else
        value = NSOrderedSame;

    NSString *lpath = lrange.location == NSNotFound ? [self substringFromIndex:length] :
        [self substringWithRange:NSMakeRange(length, lrange.location - length)];
    NSString *rpath = rrange.location == NSNotFound ? [other substringFromIndex:length] :
        [other substringWithRange:NSMakeRange(length, rrange.location - length)];

    NSComparisonResult result = [lpath compare:rpath];
    return result == NSOrderedSame ? value : result;
}

- (NSString *) stringByAddingPercentEscapesIncludingReserved {
    return [(id)CFURLCreateStringByAddingPercentEscapes(
        kCFAllocatorDefault,
        (CFStringRef) self,
        NULL,
        CFSTR(";/?:@&=+$,"),
        kCFStringEncodingUTF8
    ) autorelease];
}

@end
/* }}} */

/* C++ NSString Wrapper Cache {{{ */
static _finline CFStringRef CYStringCreate(const char *data, size_t size) {
    return size == 0 ? NULL :
        CFStringCreateWithBytesNoCopy(kCFAllocatorDefault, reinterpret_cast<const uint8_t *>(data), size, kCFStringEncodingUTF8, NO, kCFAllocatorNull) ?:
        CFStringCreateWithBytesNoCopy(kCFAllocatorDefault, reinterpret_cast<const uint8_t *>(data), size, kCFStringEncodingISOLatin1, NO, kCFAllocatorNull);
}

static _finline CFStringRef CYStringCreate(const std::string &data) {
    return CYStringCreate(data.data(), data.size());
}

static _finline CFStringRef CYStringCreate(const char *data) {
    return CYStringCreate(data, strlen(data));
}

class CYString {
  private:
    char *data_;
    size_t size_;
    CFStringRef cache_;

    _finline void clear_() {
        if (cache_ != NULL) {
            CFRelease(cache_);
            cache_ = NULL;
        }
    }

  public:
    _finline bool empty() const {
        return size_ == 0;
    }

    _finline size_t size() const {
        return size_;
    }

    _finline char *data() const {
        return data_;
    }

    _finline void clear() {
        size_ = 0;
        clear_();
    }

    _finline CYString() :
        data_(0),
        size_(0),
        cache_(NULL)
    {
    }

    _finline ~CYString() {
        clear_();
    }

    void operator =(const CYString &rhs) {
        data_ = rhs.data_;
        size_ = rhs.size_;

        if (rhs.cache_ == nil)
            cache_ = NULL;
        else
            cache_ = reinterpret_cast<CFStringRef>(CFRetain(rhs.cache_));
    }

    void copy(CYPool *pool) {
        char *temp(pool->malloc<char>(size_ + 1));
        memcpy(temp, data_, size_);
        temp[size_] = '\0';
        data_ = temp;
    }

    void set(CYPool *pool, const char *data, size_t size) {
        if (size == 0)
            clear();
        else {
            clear_();

            data_ = const_cast<char *>(data);
            size_ = size;

            if (pool != NULL)
                copy(pool);
        }
    }

    _finline void set(CYPool *pool, const char *data) {
        set(pool, data, data == NULL ? 0 : strlen(data));
    }

    _finline void set(CYPool *pool, const std::string &rhs) {
        set(pool, rhs.data(), rhs.size());
    }

    bool operator ==(const CYString &rhs) const {
        return size_ == rhs.size_ && memcmp(data_, rhs.data_, size_) == 0;
    }

    _finline operator CFStringRef() {
        if (cache_ == NULL)
            cache_ = CYStringCreate(data_, size_);
        return cache_;
    }

    _finline operator id() {
        return (NSString *) static_cast<CFStringRef>(*this);
    }

    _finline operator const char *() {
        return reinterpret_cast<const char *>(data_);
    }
};
/* }}} */
/* C++ NSString Algorithm Adapters {{{ */
extern "C" {
    CF_EXPORT CFHashCode CFStringHashNSString(CFStringRef str);
}

struct NSStringMapHash :
    std::unary_function<NSString *, size_t>
{
    _finline size_t operator ()(NSString *value) const {
        return CFStringHashNSString((CFStringRef) value);
    }
};

struct NSStringMapLess :
    std::binary_function<NSString *, NSString *, bool>
{
    _finline bool operator ()(NSString *lhs, NSString *rhs) const {
        return [lhs compare:rhs] == NSOrderedAscending;
    }
};

struct NSStringMapEqual :
    std::binary_function<NSString *, NSString *, bool>
{
    _finline bool operator ()(NSString *lhs, NSString *rhs) const {
        return CFStringCompare((CFStringRef) lhs, (CFStringRef) rhs, 0) == kCFCompareEqualTo;
        //CFEqual((CFTypeRef) lhs, (CFTypeRef) rhs);
        //[lhs isEqualToString:rhs];
    }
};
/* }}} */

/* CoreGraphics Primitives {{{ */
class CYColor {
  private:
    CGColorRef color_;

    static CGColorRef Create_(CGColorSpaceRef space, float red, float green, float blue, float alpha) {
        CGFloat color[] = {red, green, blue, alpha};
        return CGColorCreate(space, color);
    }

  public:
    CYColor() :
        color_(NULL)
    {
    }

    CYColor(CGColorSpaceRef space, float red, float green, float blue, float alpha) :
        color_(Create_(space, red, green, blue, alpha))
    {
        Set(space, red, green, blue, alpha);
    }

    void Clear() {
        if (color_ != NULL)
            CGColorRelease(color_);
    }

    ~CYColor() {
        Clear();
    }

    void Set(CGColorSpaceRef space, float red, float green, float blue, float alpha) {
        Clear();
        color_ = Create_(space, red, green, blue, alpha);
    }

    operator CGColorRef() {
        return color_;
    }
};
/* }}} */

/* Random Global Variables {{{ */
static int PulseInterval_ = 500000;

static const NSString *UI_;

static int Finish_;
static bool RestartSubstrate_;
static NSArray *Finishes_;

#define SpringBoard_ "/System/Library/LaunchDaemons/com.apple.SpringBoard.plist"
#define NotifyConfig_ "/etc/notify.conf"

static bool Queuing_;

static CYColor Blue_;
static CYColor Blueish_;
static CYColor Black_;
static CYColor Folder_;
static CYColor Off_;
static CYColor White_;
static CYColor Gray_;
static CYColor Green_;
static CYColor Purple_;
static CYColor Purplish_;

static UIColor *InstallingColor_;
static UIColor *RemovingColor_;

static NSString *App_;

static BOOL Advanced_;
static BOOL Ignored_;

static _H<UIFont> Font12_;
static _H<UIFont> Font12Bold_;
static _H<UIFont> Font14_;
static _H<UIFont> Font18_;
static _H<UIFont> Font18Bold_;
static _H<UIFont> Font22Bold_;

static _H<NSString> UniqueID_;

static _H<NSLocale> CollationLocale_;
static _H<NSArray> CollationThumbs_;
static std::vector<NSInteger> CollationOffset_;
static _H<NSArray> CollationTitles_;
static _H<NSArray> CollationStarts_;
static UTransliterator *CollationTransl_;
//static Function<NSString *, NSString *> CollationModify_;

typedef std::basic_string<UChar> ustring;
static ustring CollationString_;

#define CUC const ustring &str(*reinterpret_cast<const ustring *>(rep))
#define UC ustring &str(*reinterpret_cast<ustring *>(rep))
static struct UReplaceableCallbacks CollationUCalls_ = {
    .length = [](const UReplaceable *rep) -> int32_t { CUC;
        return str.size();
    },

    .charAt = [](const UReplaceable *rep, int32_t offset) -> UChar { CUC;
        //fprintf(stderr, "charAt(%d) : %d\n", offset, str.size());
        if (offset >= str.size())
            return 0xffff;
        return str[offset];
    },

    .char32At = [](const UReplaceable *rep, int32_t offset) -> UChar32 { CUC;
        //fprintf(stderr, "char32At(%d) : %d\n", offset, str.size());
        if (offset >= str.size())
            return 0xffff;
        UChar32 c;
        U16_GET(str.data(), 0, offset, str.size(), c);
        return c;
    },

    .replace = [](UReplaceable *rep, int32_t start, int32_t limit, const UChar *text, int32_t length) -> void { UC;
        //fprintf(stderr, "replace(%d, %d, %d) : %d\n", start, limit, length, str.size());
        str.replace(start, limit - start, text, length);
    },

    .extract = [](UReplaceable *rep, int32_t start, int32_t limit, UChar *dst) -> void { UC;
        //fprintf(stderr, "extract(%d, %d) : %d\n", start, limit, str.size());
        str.copy(dst, limit - start, start);
    },

    .copy = [](UReplaceable *rep, int32_t start, int32_t limit, int32_t dest) -> void { UC;
        //fprintf(stderr, "copy(%d, %d, %d) : %d\n", start, limit, dest, str.size());
        str.replace(dest, 0, str, start, limit - start);
    },
};

static CFLocaleRef Locale_;
static NSArray *Languages_;
static CGColorSpaceRef space_;

#define CacheState_ "/var/mobile/Library/Caches/com.saurik.Cydia/CacheState.plist"
#define SavedState_ "/var/mobile/Library/Caches/com.saurik.Cydia/SavedState.plist"

static NSDictionary *SectionMap_;
static _H<NSDate> Backgrounded_;
static _transient NSMutableDictionary *Values_;
static _transient NSMutableDictionary *Sections_;
_H<NSMutableDictionary> Sources_;
static _transient NSNumber *Version_;
static time_t now_;

static _H<NSMutableDictionary> SessionData_;
static _H<NSMutableSet> BridgedHosts_;
static _H<NSMutableSet> InsecureHosts_;

static NSString *kCydiaProgressEventTypeError = @"Error";
static NSString *kCydiaProgressEventTypeInformation = @"Information";
static NSString *kCydiaProgressEventTypeStatus = @"Status";
static NSString *kCydiaProgressEventTypeWarning = @"Warning";
/* }}} */

/* Display Helpers {{{ */
static _finline const char *StripVersion_(const char *version) {
    const char *colon(strchr(version, ':'));
    return colon == NULL ? version : colon + 1;
}

NSString *LocalizeSection(NSString *section) {
    static RegEx title_r("(.*?) \\((.*)\\)");
    if (title_r(section)) {
        NSString *parent(title_r[1]);
        NSString *child(title_r[2]);

        return [NSString stringWithFormat:UCLocalize("PARENTHETICAL"),
            LocalizeSection(parent),
            LocalizeSection(child)
        ];
    }

    return [[NSBundle mainBundle] localizedStringForKey:section value:nil table:@"Sections"];
}

NSString *Simplify(NSString *title) {
    const char *data = [title UTF8String];
    size_t size = [title lengthOfBytesUsingEncoding:NSUTF8StringEncoding];

    static RegEx square_r("\\[(.*)\\]");
    if (square_r(data, size))
        return Simplify(square_r[1]);

    static RegEx paren_r("\\((.*)\\)");
    if (paren_r(data, size))
        return Simplify(paren_r[1]);

    static RegEx title_r("(.*?) \\((.*)\\)");
    if (title_r(data, size))
        return Simplify(title_r[1]);

    return title;
}
/* }}} */

bool isSectionVisible(NSString *section) {
    NSDictionary *metadata([Sections_ objectForKey:(section ?: @"")]);
    NSNumber *hidden(metadata == nil ? nil : [metadata objectForKey:@"Hidden"]);
    return hidden == nil || ![hidden boolValue];
}

static NSString *VerifySource(NSString *href) {
    static RegEx href_r("(http(s?)://|file:///)[^# ]*");
    if (!href_r(href)) {
        [[[[UIAlertView alloc]
            initWithTitle:[NSString stringWithFormat:Colon_, Error_, UCLocalize("INVALID_URL")]
            message:UCLocalize("INVALID_URL_EX")
            delegate:nil
            cancelButtonTitle:UCLocalize("OK")
            otherButtonTitles:nil
        ] autorelease] show];

        return nil;
    }

    if (![href hasSuffix:@"/"])
        href = [href stringByAppendingString:@"/"];
    return href;
}

@class Cydia;

/* Delegate Prototypes {{{ */
@class Package;
@class Source;
@class CydiaProgressEvent;

@protocol DatabaseDelegate
- (void) repairWithSelector:(SEL)selector;
- (void) setConfigurationData:(NSString *)data;
- (void) addProgressEventOnMainThread:(CydiaProgressEvent *)event forTask:(NSString *)task;
@end

@class CYPackageController;

@protocol SourceDelegate
- (void) setFetch:(NSNumber *)fetch;
@end

@protocol FetchDelegate
- (bool) isSourceCancelled;
- (void) startSourceFetch:(NSString *)uri;
- (void) stopSourceFetch:(NSString *)uri;
@end

@protocol CydiaDelegate
- (void) returnToCydia;
- (void) saveState;
- (void) retainNetworkActivityIndicator;
- (void) releaseNetworkActivityIndicator;
- (void) clearPackage:(Package *)package;
- (void) installPackage:(Package *)package;
- (void) installPackages:(NSArray *)packages;
- (void) removePackage:(Package *)package;
- (void) beginUpdate;
- (BOOL) updating;
- (bool) requestUpdate;
- (void) distUpgrade;
- (void) loadData;
- (void) updateData;
- (void) _saveConfig;
- (void) syncData;
- (void) addSource:(NSDictionary *)source;
- (BOOL) addTrivialSource:(NSString *)href;
- (UIProgressHUD *) addProgressHUD;
- (void) removeProgressHUD:(UIProgressHUD *)hud;
- (void) showActionSheet:(UIActionSheet *)sheet fromItem:(UIBarButtonItem *)item;
- (void) reloadDataWithInvocation:(NSInvocation *)invocation;
@end
/* }}} */

/* CancelStatus {{{ */
class CancelStatus :
    public pkgAcquireStatus
{
  private:
    bool cancelled_;

  public:
    CancelStatus() :
        cancelled_(false)
    {
    }

    virtual bool MediaChange(std::string media, std::string drive) {
        return false;
    }

    virtual void IMSHit(pkgAcquire::ItemDesc &desc) {
        Done(desc);
    }

    virtual bool Pulse_(pkgAcquire *Owner) = 0;

    virtual bool Pulse(pkgAcquire *Owner) {
        if (pkgAcquireStatus::Pulse(Owner) && Pulse_(Owner))
            return true;
        else {
            cancelled_ = true;
            return false;
        }
    }

    _finline bool WasCancelled() const {
        return cancelled_;
    }
};
/* }}} */
/* DelegateStatus {{{ */
class CydiaStatus :
    public CancelStatus
{
  private:
    _transient NSObject<ProgressDelegate> *delegate_;

  public:
    CydiaStatus() :
        delegate_(nil)
    {
    }

    void setDelegate(NSObject<ProgressDelegate> *delegate) {
        delegate_ = delegate;
    }

    virtual void Fetch(pkgAcquire::ItemDesc &desc) {
        NSString *name([NSString stringWithUTF8String:desc.ShortDesc.c_str()]);
        CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:[NSString stringWithFormat:UCLocalize("DOWNLOADING_"), name] ofType:kCydiaProgressEventTypeStatus forItemDesc:desc]);
        [delegate_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];
    }

    virtual void Done(pkgAcquire::ItemDesc &desc) {
        NSString *name([NSString stringWithUTF8String:desc.ShortDesc.c_str()]);
        CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:[NSString stringWithFormat:Colon_, UCLocalize("DONE"), name] ofType:kCydiaProgressEventTypeStatus forItemDesc:desc]);
        [delegate_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];
    }

    virtual void Fail(pkgAcquire::ItemDesc &desc) {
        if (
            desc.Owner->Status == pkgAcquire::Item::StatIdle ||
            desc.Owner->Status == pkgAcquire::Item::StatDone
        )
            return;

        std::string &error(desc.Owner->ErrorText);
        if (error.empty())
            return;

        CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:[NSString stringWithUTF8String:error.c_str()] ofType:kCydiaProgressEventTypeError forItemDesc:desc]);
        [delegate_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];
    }

    virtual bool Pulse_(pkgAcquire *Owner) {
        double percent(
            double(CurrentBytes + CurrentItems) /
            double(TotalBytes + TotalItems)
        );

        [delegate_ performSelectorOnMainThread:@selector(setProgressStatus:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithDouble:percent], @"Percent",

            [NSNumber numberWithDouble:CurrentBytes], @"Current",
            [NSNumber numberWithDouble:TotalBytes], @"Total",
            [NSNumber numberWithDouble:CurrentCPS], @"Speed",
        nil] waitUntilDone:YES];

        return ![delegate_ isProgressCancelled];
    }

    virtual void Start() {
        pkgAcquireStatus::Start();
        [delegate_ performSelectorOnMainThread:@selector(setProgressCancellable:) withObject:[NSNumber numberWithBool:YES] waitUntilDone:YES];
    }

    virtual void Stop() {
        pkgAcquireStatus::Stop();
        [delegate_ performSelectorOnMainThread:@selector(setProgressCancellable:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:YES];
        [delegate_ performSelectorOnMainThread:@selector(setProgressStatus:) withObject:nil waitUntilDone:YES];
    }
};
/* }}} */
/* Database Interface {{{ */
typedef std::map< unsigned long, _H<Source> > SourceMap;

@interface Database : NSObject {
    NSZone *zone_;
    CYPool pool_;

    unsigned era_;
    _H<NSDate> delock_;

    pkgCacheFile cache_;
    pkgDepCache::Policy *policy_;
    pkgRecords *records_;
    pkgProblemResolver *resolver_;
    pkgAcquire *fetcher_;
    FileFd *lock_;
    SPtr<pkgPackageManager> manager_;
    pkgSourceList *list_;

    SourceMap sourceMap_;
    _H<NSMutableArray> sourceList_;

    _H<NSArray> packages_;

    _transient NSObject<DatabaseDelegate> *delegate_;
    _transient NSObject<ProgressDelegate> *progress_;

    CydiaStatus status_;

    int cydiafd_;
    int statusfd_;
    FILE *input_;

    std::map<const char *, _H<NSString> > sections_;
}

+ (Database *) sharedInstance;
- (unsigned) era;
- (bool) hasPackages;

- (void) _readCydia:(NSNumber *)fd;
- (void) _readStatus:(NSNumber *)fd;
- (void) _readOutput:(NSNumber *)fd;

- (FILE *) input;

- (Package *) packageWithName:(NSString *)name;

- (pkgCacheFile &) cache;
- (pkgDepCache::Policy *) policy;
- (pkgRecords *) records;
- (pkgProblemResolver *) resolver;
- (pkgAcquire &) fetcher;
- (pkgSourceList &) list;
- (NSArray *) packages;
- (NSArray *) sources;
- (Source *) sourceWithKey:(NSString *)key;
- (void) reloadDataWithInvocation:(NSInvocation *)invocation;

- (void) configure;
- (bool) prepare;
- (void) perform;
- (bool) upgrade;
- (void) update;

- (void) updateWithStatus:(CancelStatus &)status;

- (void) setDelegate:(NSObject<DatabaseDelegate> *)delegate;

- (void) setProgressDelegate:(NSObject<ProgressDelegate> *)delegate;
- (NSObject<ProgressDelegate> *) progressDelegate;

- (Source *) getSource:(pkgCache::PkgFileIterator)file;
- (void) setFetch:(bool)fetch forURI:(const char *)uri;
- (void) resetFetch;

- (NSString *) mappedSectionForPointer:(const char *)pointer;

@end
/* }}} */
/* SourceStatus {{{ */
class SourceStatus :
    public CancelStatus
{
  private:
    _transient NSObject<FetchDelegate> *delegate_;
    _transient Database *database_;
    std::set<std::string> fetches_;

  public:
    SourceStatus(NSObject<FetchDelegate> *delegate, Database *database) :
        delegate_(delegate),
        database_(database)
    {
    }

    void Set(bool fetch, const std::string &uri) {
        if (fetch) {
            if (!fetches_.insert(uri).second)
                return;
        } else {
            if (fetches_.erase(uri) == 0)
                return;
        }

        //printf("Set(%s, %s)\n", fetch ? "true" : "false", uri.c_str());

        auto slash(uri.rfind('/'));
        if (slash != std::string::npos)
            [database_ setFetch:fetch forURI:uri.substr(0, slash).c_str()];
    }

    _finline void Set(bool fetch, pkgAcquire::Item *item) {
        /*unsigned long ID(fetch ? 1 : 0);
        if (item->ID == ID)
            return;
        item->ID = ID;*/
        Set(fetch, item->DescURI());
    }

    void Log(const char *tag, pkgAcquire::Item *item) {
        //printf("%s(%s) S:%u Q:%u\n", tag, item->DescURI().c_str(), item->Status, item->QueueCounter);
    }

    virtual void Fetch(pkgAcquire::ItemDesc &desc) {
        Log("Fetch", desc.Owner);
        Set(true, desc.Owner);
    }

    virtual void Done(pkgAcquire::ItemDesc &desc) {
        Log("Done", desc.Owner);
        Set(false, desc.Owner);
    }

    virtual void Fail(pkgAcquire::ItemDesc &desc) {
        Log("Fail", desc.Owner);
        Set(false, desc.Owner);
    }

    virtual bool Pulse_(pkgAcquire *Owner) {
        std::set<std::string> fetches;
        for (pkgAcquire::ItemCIterator item(Owner->ItemsBegin()); item != Owner->ItemsEnd(); ++item) {
            bool fetch;
            if ((*item)->QueueCounter == 0)
                fetch = false;
            else switch ((*item)->Status) {
                case pkgAcquire::Item::StatFetching:
                    fetches.insert((*item)->DescURI());
                    fetch = true;
                break;

                default:
                    fetch = false;
                break;
            }

            Log(fetch ? "Pulse<true>" : "Pulse<false>", *item);
            Set(fetch, *item);
        }

        std::vector<std::string> stops;
        std::set_difference(fetches_.begin(), fetches_.end(), fetches.begin(), fetches.end(), std::back_insert_iterator<std::vector<std::string>>(stops));
        for (std::vector<std::string>::const_iterator stop(stops.begin()); stop != stops.end(); ++stop) {
            //printf("Stop(%s)\n", stop->c_str());
            Set(false, *stop);
        }

        return ![delegate_ isSourceCancelled];
    }

    virtual void Stop() {
        pkgAcquireStatus::Stop();
        [database_ resetFetch];
    }
};
/* }}} */
/* ProgressEvent Implementation {{{ */
@implementation CydiaProgressEvent

+ (CydiaProgressEvent *) eventWithMessage:(NSString *)message ofType:(NSString *)type {
    return [[[CydiaProgressEvent alloc] initWithMessage:message ofType:type] autorelease];
}

+ (CydiaProgressEvent *) eventWithMessage:(NSString *)message ofType:(NSString *)type forPackage:(NSString *)package {
    CydiaProgressEvent *event([self eventWithMessage:message ofType:type]);
    [event setPackage:package];
    return event;
}

+ (CydiaProgressEvent *) eventWithMessage:(NSString *)message ofType:(NSString *)type forItemDesc:(pkgAcquire::ItemDesc &)desc {
    CydiaProgressEvent *event([self eventWithMessage:message ofType:type]);

    NSString *description([NSString stringWithUTF8String:desc.Description.c_str()]);
    NSArray *fields([description componentsSeparatedByString:@" "]);
    [event setItem:fields];

    if ([fields count] > 3) {
        [event setPackage:[fields objectAtIndex:2]];
        [event setVersion:[fields objectAtIndex:3]];
    }

    [event setURL:[NSString stringWithUTF8String:desc.URI.c_str()]];

    return event;
}

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"item",
        @"message",
        @"package",
        @"type",
        @"url",
        @"version",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (id) initWithMessage:(NSString *)message ofType:(NSString *)type {
    if ((self = [super init]) != nil) {
        message_ = message;
        type_ = type;
    } return self;
}

- (NSString *) message {
    return message_;
}

- (NSString *) type {
    return type_;
}

- (NSArray *) item {
    return (id) item_ ?: [NSNull null];
}

- (void) setItem:(NSArray *)item {
    item_ = item;
}

- (NSString *) package {
    return (id) package_ ?: [NSNull null];
}

- (void) setPackage:(NSString *)package {
    package_ = package;
}

- (NSString *) url {
    return (id) url_ ?: [NSNull null];
}

- (void) setURL:(NSString *)url {
    url_ = url;
}

- (void) setVersion:(NSString *)version {
    version_ = version;
}

- (NSString *) version {
    return (id) version_ ?: [NSNull null];
}

- (NSString *) compound:(NSString *)value {
    if (value != nil) {
        NSString *mode(nil); {
            NSString *type([self type]);
            if ([type isEqualToString:kCydiaProgressEventTypeError])
                mode = UCLocalize("ERROR");
            else if ([type isEqualToString:kCydiaProgressEventTypeWarning])
                mode = UCLocalize("WARNING");
        }

        if (mode != nil)
            value = [NSString stringWithFormat:UCLocalize("COLON_DELIMITED"), mode, value];
    }

    return value;
}

- (NSString *) compoundMessage {
    return [self compound:[self message]];
}

- (NSString *) compoundTitle {
    NSString *title;

    if (package_ == nil)
        title = nil;
    else if (Package *package = [[Database sharedInstance] packageWithName:package_])
        title = [package name];
    else
        title = package_;

    return [self compound:title];
}

@end
/* }}} */

// Cytore Definitions {{{
struct PackageValue :
    Cytore::Block
{
    Cytore::Offset<PackageValue> next_;

    uint32_t index_ : 23;
    uint32_t subscribed_ : 1;
    uint32_t : 8;

    int32_t first_;
    int32_t last_;

    uint16_t vhash_;
    uint16_t nhash_;

    char version_[8];
    char name_[];
} _packed;

struct MetaValue :
    Cytore::Block
{
    uint32_t active_;
    Cytore::Offset<PackageValue> packages_[1 << 16];
} _packed;

static Cytore::File<MetaValue> MetaFile_;
// }}}
// Cytore Helper Functions {{{
static PackageValue *PackageFind(const char *name, size_t length, bool *fail = NULL) {
    SplitHash nhash = { hashlittle(name, length) };

    PackageValue *metadata;

    Cytore::Offset<PackageValue> *offset(&MetaFile_->packages_[nhash.u16[0]]);
    for (;; offset = &metadata->next_) { if (offset->IsNull()) {
        *offset = MetaFile_.New<PackageValue>(length + 1);
        metadata = &MetaFile_.Get(*offset);

        if (metadata == NULL) {
            if (fail != NULL)
                *fail = true;

            metadata = new PackageValue();
            memset(metadata, 0, sizeof(*metadata));
        }

        memcpy(metadata->name_, name, length);
        metadata->name_[length] = '\0';
        metadata->nhash_ = nhash.u16[1];
    } else {
        metadata = &MetaFile_.Get(*offset);
        if (metadata->nhash_ != nhash.u16[1])
            continue;
        if (strncmp(metadata->name_, name, length) != 0)
            continue;
        if (metadata->name_[length] != '\0')
            continue;
    } break; }

    return metadata;
}

static void PackageImport(const void *key, const void *value, void *context) {
    bool &fail(*reinterpret_cast<bool *>(context));

    char buffer[1024];
    if (!CFStringGetCString((CFStringRef) key, buffer, sizeof(buffer), kCFStringEncodingUTF8)) {
        NSLog(@"failed to import package %@", key);
        return;
    }

    PackageValue *metadata(PackageFind(buffer, strlen(buffer), &fail));
    NSDictionary *package((NSDictionary *) value);

    if (NSNumber *subscribed = [package objectForKey:@"IsSubscribed"])
        if ([subscribed boolValue] && !metadata->subscribed_)
            metadata->subscribed_ = true;

    if (NSDate *date = [package objectForKey:@"FirstSeen"]) {
        time_t time([date timeIntervalSince1970]);
        if (metadata->first_ > time || metadata->first_ == 0)
            metadata->first_ = time;
    }

    NSDate *date([package objectForKey:@"LastSeen"]);
    NSString *version([package objectForKey:@"LastVersion"]);

    if (date != nil && version != nil) {
        time_t time([date timeIntervalSince1970]);
        if (metadata->last_ < time || metadata->last_ == 0)
            if (CFStringGetCString((CFStringRef) version, buffer, sizeof(buffer), kCFStringEncodingUTF8)) {
                size_t length(strlen(buffer));
                uint16_t vhash(hashlittle(buffer, length));

                size_t capped(std::min<size_t>(8, length));
                char *latest(buffer + length - capped);

                strncpy(metadata->version_, latest, sizeof(metadata->version_));
                metadata->vhash_ = vhash;

                metadata->last_ = time;
            }
    }
}
// }}}

static NSDate *GetStatusDate() {
    return [[[NSFileManager defaultManager] attributesOfItemAtPath:@"/var/lib/dpkg/status" error:NULL] fileModificationDate];
}

static void SaveConfig(NSObject *lock) {
    @synchronized (lock) {
        _trace();
        MetaFile_.Sync();
        _trace();
    }

    CFPreferencesSetMultiple((CFDictionaryRef) [NSDictionary dictionaryWithObjectsAndKeys:
        Values_, @"CydiaValues",
        Sections_, @"CydiaSections",
        (id) Sources_, @"CydiaSources",
        Version_, @"CydiaVersion",
    nil], NULL, CFSTR("com.saurik.Cydia"), kCFPreferencesCurrentUser, kCFPreferencesCurrentHost);

    if (!CFPreferencesAppSynchronize(CFSTR("com.saurik.Cydia")))
        NSLog(@"CFPreferencesAppSynchronize(com.saurik.Cydia) == false");

    CydiaWriteSources();
}

/* Source Class {{{ */
@interface Source : NSObject {
    unsigned era_;
    Database *database_;
    metaIndex *index_;

    CYString depiction_;
    CYString description_;
    CYString label_;
    CYString origin_;
    CYString support_;

    CYString uri_;
    CYString distribution_;
    CYString type_;
    CYString base_;
    CYString version_;

    _H<NSString> host_;
    _H<NSString> authority_;

    CYString defaultIcon_;

    _H<NSMutableDictionary> record_;
    BOOL trusted_;

    std::set<std::string> fetches_;
    std::set<std::string> files_;
    _transient NSObject<SourceDelegate> *delegate_;
}

- (Source *) initWithMetaIndex:(metaIndex *)index forDatabase:(Database *)database inPool:(CYPool *)pool;

- (NSComparisonResult) compareByName:(Source *)source;

- (NSString *) depictionForPackage:(NSString *)package;
- (NSString *) supportForPackage:(NSString *)package;

- (metaIndex *) metaIndex;
- (NSDictionary *) record;
- (BOOL) trusted;

- (NSString *) rooturi;
- (NSString *) distribution;
- (NSString *) type;

- (NSString *) key;
- (NSString *) host;

- (NSString *) name;
- (NSString *) shortDescription;
- (NSString *) label;
- (NSString *) origin;
- (NSString *) version;

- (NSString *) defaultIcon;
- (NSURL *) iconURL;

- (void) setFetch:(bool)fetch forURI:(const char *)uri;
- (void) resetFetch;

@end

@implementation Source

+ (NSString *) webScriptNameForSelector:(SEL)selector {
    if (false);
    else if (selector == @selector(addSection:))
        return @"addSection";
    else if (selector == @selector(getField:))
        return @"getField";
    else if (selector == @selector(removeSection:))
        return @"removeSection";
    else if (selector == @selector(remove))
        return @"remove";
    else
        return nil;
}

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector {
    return [self webScriptNameForSelector:selector] == nil;
}

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"baseuri",
        @"distribution",
        @"host",
        @"key",
        @"iconuri",
        @"label",
        @"name",
        @"origin",
        @"rooturi",
        @"sections",
        @"shortDescription",
        @"trusted",
        @"type",
        @"version",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (metaIndex *) metaIndex {
    return index_;
}

- (void) setMetaIndex:(metaIndex *)index inPool:(CYPool *)pool {
    trusted_ = index->IsTrusted();

    uri_.set(pool, index->GetURI());
    distribution_.set(pool, index->GetDist());
    type_.set(pool, index->GetType());

    debReleaseIndex *dindex(dynamic_cast<debReleaseIndex *>(index));
    if (dindex != NULL) {
        std::string file(dindex->MetaIndexURI(""));
        base_.set(pool, file);

        pkgAcquire acquire;
        _profile(Source$setMetaIndex$GetIndexes)
        dindex->GetIndexes(&acquire, true);
        _end
        _profile(Source$setMetaIndex$DescURI)
        for (pkgAcquire::ItemIterator item(acquire.ItemsBegin()); item != acquire.ItemsEnd(); item++) {
            std::string file((*item)->DescURI());
            auto slash(file.rfind('/'));
            if (slash == std::string::npos)
                continue;
            files_.insert(file.substr(0, slash));
        }
        _end

        FileFd fd;
        if (!fd.Open(dindex->MetaIndexFile("Release"), FileFd::ReadOnly))
            _error->Discard();
        else {
            pkgTagFile tags(&fd);

            pkgTagSection section;
            tags.Step(section);

            struct {
                const char *name_;
                CYString *value_;
            } names[] = {
                {"default-icon", &defaultIcon_},
                {"depiction", &depiction_},
                {"description", &description_},
                {"label", &label_},
                {"origin", &origin_},
                {"support", &support_},
                {"version", &version_},
            };

            for (size_t i(0); i != sizeof(names) / sizeof(names[0]); ++i) {
                const char *start, *end;

                if (section.Find(names[i].name_, start, end)) {
                    CYString &value(*names[i].value_);
                    value.set(pool, start, end - start);
                }
            }
        }
    }

    record_ = [Sources_ objectForKey:[self key]];

    NSURL *url([NSURL URLWithString:uri_]);

    host_ = [url host];
    if (host_ != nil)
        host_ = [host_ lowercaseString];

    if (host_ != nil)
        authority_ = host_;
    else
        authority_ = [url path];
}

- (Source *) initWithMetaIndex:(metaIndex *)index forDatabase:(Database *)database inPool:(CYPool *)pool {
    if ((self = [super init]) != nil) {
        era_ = [database era];
        database_ = database;
        index_ = index;

        _profile(Source$initWithMetaIndex$setMetaIndex)
        [self setMetaIndex:index inPool:pool];
        _end
    } return self;
}

- (NSString *) getField:(NSString *)name {
@synchronized (database_) {
    if ([database_ era] != era_ || index_ == NULL)
        return nil;

    debReleaseIndex *dindex(dynamic_cast<debReleaseIndex *>(index_));
    if (dindex == NULL)
        return nil;

    FileFd fd;
    if (!fd.Open(dindex->MetaIndexFile("Release"), FileFd::ReadOnly)) {
         _error->Discard();
         return nil;
    }

    pkgTagFile tags(&fd);

    pkgTagSection section;
    tags.Step(section);

    const char *start, *end;
    if (!section.Find([name UTF8String], start, end))
        return (NSString *) [NSNull null];

    return [NSString stringWithString:[(NSString *) CYStringCreate(start, end - start) autorelease]];
} }

- (NSComparisonResult) compareByName:(Source *)source {
    NSString *lhs = [self name];
    NSString *rhs = [source name];

    if ([lhs length] != 0 && [rhs length] != 0) {
        unichar lhc = [lhs characterAtIndex:0];
        unichar rhc = [rhs characterAtIndex:0];

        if (isalpha(lhc) && !isalpha(rhc))
            return NSOrderedAscending;
        else if (!isalpha(lhc) && isalpha(rhc))
            return NSOrderedDescending;
    }

    return [lhs compare:rhs options:LaxCompareOptions_];
}

- (NSString *) depictionForPackage:(NSString *)package {
    return depiction_.empty() ? nil : [static_cast<id>(depiction_) stringByReplacingOccurrencesOfString:@"*" withString:package];
}

- (NSString *) supportForPackage:(NSString *)package {
    return support_.empty() ? nil : [static_cast<id>(support_) stringByReplacingOccurrencesOfString:@"*" withString:package];
}

- (NSArray *) sections {
    return record_ == nil ? (id) [NSNull null] : [record_ objectForKey:@"Sections"] ?: [NSArray array];
}

- (void) _addSection:(NSString *)section {
    if (record_ == nil)
        return;
    else if (NSMutableArray *sections = [record_ objectForKey:@"Sections"]) {
        if (![sections containsObject:section])
            [sections addObject:section];
    } else
        [record_ setObject:[NSMutableArray arrayWithObject:section] forKey:@"Sections"];
}

- (bool) addSection:(NSString *)section {
    if (record_ == nil)
        return false;

    [self performSelectorOnMainThread:@selector(_addSection:) withObject:section waitUntilDone:NO];
    return true;
}

- (void) _removeSection:(NSString *)section {
    if (record_ == nil)
        return;

    if (NSMutableArray *sections = [record_ objectForKey:@"Sections"])
        if ([sections containsObject:section])
            [sections removeObject:section];
}

- (bool) removeSection:(NSString *)section {
    if (record_ == nil)
        return false;

    [self performSelectorOnMainThread:@selector(_removeSection:) withObject:section waitUntilDone:NO];
    return true;
}

- (void) _remove {
    [Sources_ removeObjectForKey:[self key]];
}

- (bool) remove {
    bool value(record_ != nil);
    [self performSelectorOnMainThread:@selector(_remove) withObject:nil waitUntilDone:NO];
    return value;
}

- (NSDictionary *) record {
    return record_;
}

- (BOOL) trusted {
    return trusted_;
}

- (NSString *) rooturi {
    return uri_;
}

- (NSString *) distribution {
    return distribution_;
}

- (NSString *) type {
    return type_;
}

- (NSString *) baseuri {
    return base_.empty() ? nil : (id) base_;
}

- (NSString *) iconuri {
    if (NSString *base = [self baseuri])
        return [base stringByAppendingString:@"CydiaIcon.png"];

    return nil;
}

- (NSURL *) iconURL {
    if (NSString *uri = [self iconuri])
        return [NSURL URLWithString:uri];
    return nil;
}

- (NSString *) key {
    return [NSString stringWithFormat:@"%@:%@:%@", (NSString *) type_, (NSString *) uri_, (NSString *) distribution_];
}

- (NSString *) host {
    return host_;
}

- (NSString *) name {
    return origin_.empty() ? (id) authority_ : origin_;
}

- (NSString *) shortDescription {
    return description_;
}

- (NSString *) label {
    return label_.empty() ? (id) authority_ : label_;
}

- (NSString *) origin {
    return origin_;
}

- (NSString *) version {
    return version_;
}

- (NSString *) defaultIcon {
    return defaultIcon_;
}

- (void) setDelegate:(NSObject<SourceDelegate> *)delegate {
    delegate_ = delegate;
}

- (bool) fetch {
    return !fetches_.empty();
}

- (void) setFetch:(bool)fetch forURI:(const char *)uri {
    if (!fetch) {
        if (fetches_.erase(uri) == 0)
            return;
    } else if (files_.find(uri) == files_.end())
        return;
    else if (!fetches_.insert(uri).second)
        return;

    [delegate_ performSelectorOnMainThread:@selector(setFetch:) withObject:[NSNumber numberWithBool:[self fetch]] waitUntilDone:NO];
}

- (void) resetFetch {
    fetches_.clear();
    [delegate_ performSelectorOnMainThread:@selector(setFetch:) withObject:[NSNumber numberWithBool:NO] waitUntilDone:NO];
}

@end
/* }}} */
/* CydiaOperation Class {{{ */
@interface CydiaOperation : NSObject {
    _H<NSString> operator_;
    _H<NSString> value_;
}

- (NSString *) operator;
- (NSString *) value;

@end

@implementation CydiaOperation

- (id) initWithOperator:(const char *)_operator value:(const char *)value {
    if ((self = [super init]) != nil) {
        operator_ = [NSString stringWithUTF8String:_operator];
        value_ = [NSString stringWithUTF8String:value];
    } return self;
}

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"operator",
        @"value",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (NSString *) operator {
    return operator_;
}

- (NSString *) value {
    return value_;
}

@end
/* }}} */
/* CydiaClause Class {{{ */
@interface CydiaClause : NSObject {
    _H<NSString> package_;
    _H<CydiaOperation> version_;
}

- (NSString *) package;
- (CydiaOperation *) version;

@end

@implementation CydiaClause

- (id) initWithIterator:(pkgCache::DepIterator &)dep {
    if ((self = [super init]) != nil) {
        package_ = [NSString stringWithUTF8String:dep.TargetPkg().Name()];

        if (const char *version = dep.TargetVer())
            version_ = [[[CydiaOperation alloc] initWithOperator:dep.CompType() value:version] autorelease];
        else
            version_ = (id) [NSNull null];
    } return self;
}

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"package",
        @"version",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (NSString *) package {
    return package_;
}

- (CydiaOperation *) version {
    return version_;
}

@end
/* }}} */
/* CydiaRelation Class {{{ */
@interface CydiaRelation : NSObject {
    _H<NSString> relationship_;
    _H<NSMutableArray> clauses_;
}

- (NSString *) relationship;
- (NSArray *) clauses;

@end

@implementation CydiaRelation

- (id) initWithIterator:(pkgCache::DepIterator &)dep {
    if ((self = [super init]) != nil) {
        relationship_ = [NSString stringWithUTF8String:dep.DepType()];
        clauses_ = [NSMutableArray arrayWithCapacity:8];

        pkgCache::DepIterator start;
        pkgCache::DepIterator end;
        dep.GlobOr(start, end); // ++dep

        _forever {
            [clauses_ addObject:[[[CydiaClause alloc] initWithIterator:start] autorelease]];

            // yes, seriously. (wtf?)
            if (start == end)
                break;
            ++start;
        }
    } return self;
}

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"clauses",
        @"relationship",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (NSString *) relationship {
    return relationship_;
}

- (NSArray *) clauses {
    return clauses_;
}

- (void) addClause:(CydiaClause *)clause {
    [clauses_ addObject:clause];
}

@end
/* }}} */
/* Package Class {{{ */
struct ParsedPackage {
    CYString md5sum_;
    CYString tagline_;

    CYString architecture_;
    CYString icon_;

    CYString depiction_;
    CYString homepage_;
    CYString author_;

    CYString support_;
};

@interface Package : NSObject {
    uint32_t era_ : 25;
    @public uint32_t role_ : 3;
    uint32_t essential_ : 1;
    uint32_t obsolete_ : 1;
    uint32_t ignored_ : 1;
    uint32_t pooled_ : 1;

    CYPool *pool_;

    uint32_t rank_;

    _transient Database *database_;

    pkgCache::VerIterator version_;
    pkgCache::PkgIterator iterator_;
    pkgCache::VerFileIterator file_;

    CYString id_;
    CYString name_;
    CYString transform_;

    CYString latest_;
    CYString installed_;
    time_t upgraded_;

    const char *section_;
    _transient NSString *section$_;

    _H<Source> source_;

    PackageValue *metadata_;
    ParsedPackage *parsed_;

    _H<NSMutableArray> tags_;
}

- (Package *) initWithVersion:(pkgCache::VerIterator)version withZone:(NSZone *)zone inPool:(CYPool *)pool database:(Database *)database;
+ (Package *) newPackageWithIterator:(pkgCache::PkgIterator)iterator withZone:(NSZone *)zone inPool:(CYPool *)pool database:(Database *)database;

+ (Package *) packageWithIterator:(pkgCache::PkgIterator)iterator withZone:(NSZone *)zone inPool:(CYPool *)pool database:(Database *)database;

- (pkgCache::PkgIterator) iterator;
- (void) parse;

- (NSString *) section;
- (NSString *) simpleSection;

- (NSString *) longSection;
- (NSString *) shortSection;

- (NSString *) uri;

- (MIMEAddress *) maintainer;
- (size_t) size;
- (NSString *) longDescription;
- (NSString *) shortDescription;
- (unichar) index;

- (PackageValue *) metadata;
- (time_t) seen;

- (bool) subscribed;
- (bool) setSubscribed:(bool)subscribed;

- (BOOL) ignored;

- (NSString *) latest;
- (NSString *) installed;
- (BOOL) uninstalled;

- (BOOL) upgradableAndEssential:(BOOL)essential;
- (BOOL) essential;
- (BOOL) broken;
- (BOOL) unfiltered;
- (BOOL) visible;

- (BOOL) half;
- (BOOL) halfConfigured;
- (BOOL) halfInstalled;
- (BOOL) hasMode;
- (NSString *) mode;

- (NSString *) id;
- (NSString *) name;
- (UIImage *) icon;
- (NSString *) homepage;
- (NSString *) depiction;
- (MIMEAddress *) author;

- (NSString *) support;

- (NSArray *) files;
- (NSArray *) warnings;
- (NSArray *) applications;

- (Source *) source;

- (uint32_t) rank;
- (BOOL) matches:(NSArray *)query;

- (BOOL) hasTag:(NSString *)tag;
- (NSString *) primaryPurpose;
- (NSArray *) purposes;
- (bool) isCommercial;

- (void) setIndex:(size_t)index;

- (CYString &) cyname;

- (uint32_t) compareBySection:(NSArray *)sections;

- (void) install;
- (void) remove;

@end

uint32_t PackageChangesRadix(Package *self, void *) {
    union {
        uint32_t key;

        struct {
            uint32_t timestamp : 30;
            uint32_t ignored : 1;
            uint32_t upgradable : 1;
        } bits;
    } value;

    bool upgradable([self upgradableAndEssential:YES]);
    value.bits.upgradable = upgradable ? 1 : 0;

    if (upgradable) {
        value.bits.timestamp = 0;
        value.bits.ignored = [self ignored] ? 0 : 1;
        value.bits.upgradable = 1;
    } else {
        value.bits.timestamp = [self seen] >> 2;
        value.bits.ignored = 0;
        value.bits.upgradable = 0;
    }

    return _not(uint32_t) - value.key;
}

CYString &(*PackageName)(Package *self, SEL sel);

uint32_t PackagePrefixRadix(Package *self, void *context) {
    size_t offset(reinterpret_cast<size_t>(context));
    CYString &name(PackageName(self, @selector(cyname)));

    size_t size(name.size());
    if (size == 0)
        return 0;
    char *text(name.data());

    size_t zeros;
    if (!isdigit(text[0]))
        zeros = 0;
    else {
        size_t digits(1);
        while (size != digits && isdigit(text[digits]))
            if (++digits == 4)
                break;
        zeros = 4 - digits;
    }

    uint8_t data[4];

    if (offset == 0 && zeros != 0) {
        memset(data, '0', zeros);
        memcpy(data + zeros, text, 4 - zeros);
    } else {
        /* XXX: there's some danger here if you request a non-zero offset < 4 and it gets zero padded */
        if (size <= offset - zeros)
            return 0;

        text += offset - zeros;
        size -= offset - zeros;

        if (size >= 4)
            memcpy(data, text, 4);
        else {
            memcpy(data, text, size);
            memset(data + size, 0, 4 - size);
        }

        for (size_t i(0); i != 4; ++i)
            if (isalpha(data[i]))
                data[i] |= 0x20;
    }

    if (offset == 0)
        if (data[0] == '@')
            data[0] = 0x7f;
        else
            data[0] = (data[0] & 0x1f) | "\x80\x00\xc0\x40"[data[0] >> 6];

    /* XXX: ntohl may be more honest */
    return OSSwapInt32(*reinterpret_cast<uint32_t *>(data));
}

CFComparisonResult StringNameCompare(CFStringRef lhn, CFStringRef rhn, size_t length) {
    _profile(PackageNameCompare)
        if (lhn == NULL)
            return rhn == NULL ? kCFCompareEqualTo : kCFCompareLessThan;
        else if (rhn == NULL)
            return kCFCompareGreaterThan;

        CFIndex length(CFStringGetLength(lhn));

        _profile(PackageNameCompare$NumbersLast)
            if (length != 0 && CFStringGetLength(rhn) != 0) {
                UniChar lhc(CFStringGetCharacterAtIndex(lhn, 0));
                UniChar rhc(CFStringGetCharacterAtIndex(rhn, 0));
                bool lha(CFUniCharIsMemberOf(lhc, kCFUniCharLetterCharacterSet));
                if (lha != CFUniCharIsMemberOf(rhc, kCFUniCharLetterCharacterSet))
                    return lha ? kCFCompareLessThan : kCFCompareGreaterThan;
            }
        _end

        _profile(PackageNameCompare$Compare)
            return CFStringCompareWithOptionsAndLocale(lhn, rhn, CFRangeMake(0, length), LaxCompareFlags_, (CFLocaleRef) (id) CollationLocale_);
        _end
    _end
}

_finline CFComparisonResult StringNameCompare(NSString *lhn, NSString*rhn, size_t length) {
    return StringNameCompare((CFStringRef) lhn, (CFStringRef) rhn, length);
}

CFComparisonResult PackageNameCompare(Package *lhs, Package *rhs, void *arg) {
    CYString &lhn(PackageName(lhs, @selector(cyname)));
    NSString *rhn(PackageName(rhs, @selector(cyname)));
    return StringNameCompare(lhn, rhn, lhn.size());
}

CFComparisonResult PackageNameCompare_(Package **lhs, Package **rhs, void *arg) {
    return PackageNameCompare(*lhs, *rhs, arg);
}

struct PackageNameOrdering :
    std::binary_function<Package *, Package *, bool>
{
    _finline bool operator ()(Package *lhs, Package *rhs) const {
        return PackageNameCompare(lhs, rhs, NULL) == kCFCompareLessThan;
    }
};

@implementation Package

- (NSString *) description {
    return [NSString stringWithFormat:@"<Package:%@>", static_cast<NSString *>(name_)];
}

- (void) dealloc {
    if (!pooled_)
        delete pool_;
    if (parsed_ != NULL)
        delete parsed_;
    [super dealloc];
}

+ (NSString *) webScriptNameForSelector:(SEL)selector {
    if (false);
    else if (selector == @selector(clear))
        return @"clear";
    else if (selector == @selector(getField:))
        return @"getField";
    else if (selector == @selector(getRecord))
        return @"getRecord";
    else if (selector == @selector(hasTag:))
        return @"hasTag";
    else if (selector == @selector(install))
        return @"install";
    else if (selector == @selector(remove))
        return @"remove";
    else
        return nil;
}

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector {
    return [self webScriptNameForSelector:selector] == nil;
}

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"applications",
        @"architecture",
        @"author",
        @"depiction",
        @"essential",
        @"homepage",
        @"icon",
        @"id",
        @"installed",
        @"latest",
        @"longDescription",
        @"longSection",
        @"maintainer",
        @"md5sum",
        @"mode",
        @"name",
        @"purposes",
        @"relations",
        @"section",
        @"selection",
        @"shortDescription",
        @"shortSection",
        @"simpleSection",
        @"size",
        @"source",
        @"state",
        @"support",
        @"tags",
        @"upgraded",
        @"warnings",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (NSArray *) relations {
@synchronized (database_) {
    NSMutableArray *relations([NSMutableArray arrayWithCapacity:16]);
    for (pkgCache::DepIterator dep(version_.DependsList()); !dep.end(); ++dep)
        [relations addObject:[[[CydiaRelation alloc] initWithIterator:dep] autorelease]];
    return relations;
} }

- (NSString *) architecture {
    [self parse];
@synchronized (database_) {
    return parsed_->architecture_.empty() ? [NSNull null] : (id) parsed_->architecture_;
} }

- (NSString *) getField:(NSString *)name {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return nil;

    pkgRecords::Parser &parser([database_ records]->Lookup(file_));

    const char *start, *end;
    if (!parser.Find([name UTF8String], start, end))
        return (NSString *) [NSNull null];

    return [NSString stringWithString:[(NSString *) CYStringCreate(start, end - start) autorelease]];
} }

- (NSString *) getRecord {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return nil;

    pkgRecords::Parser &parser([database_ records]->Lookup(file_));

    const char *start, *end;
    parser.GetRec(start, end);

    return [NSString stringWithString:[(NSString *) CYStringCreate(start, end - start) autorelease]];
} }

- (void) parse {
    if (parsed_ != NULL)
        return;
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return;

    ParsedPackage *parsed(new ParsedPackage);
    parsed_ = parsed;

    _profile(Package$parse)
        pkgRecords::Parser *parser;

        _profile(Package$parse$Lookup)
            parser = &[database_ records]->Lookup(file_);
        _end

        CYString bugs;
        CYString website;

        _profile(Package$parse$Find)
            struct {
                const char *name_;
                CYString *value_;
            } names[] = {
                {"architecture", &parsed->architecture_},
                {"icon", &parsed->icon_},
                {"depiction", &parsed->depiction_},
                {"homepage", &parsed->homepage_},
                {"website", &website},
                {"bugs", &bugs},
                {"support", &parsed->support_},
                {"author", &parsed->author_},
                {"md5sum", &parsed->md5sum_},
            };

            for (size_t i(0); i != sizeof(names) / sizeof(names[0]); ++i) {
                const char *start, *end;

                if (parser->Find(names[i].name_, start, end)) {
                    CYString &value(*names[i].value_);
                    _profile(Package$parse$Value)
                        value.set(pool_, start, end - start);
                    _end
                }
            }
        _end

        _profile(Package$parse$Tagline)
            parsed->tagline_.set(pool_, parser->ShortDesc());
        _end

        _profile(Package$parse$Retain)
            if (parsed->homepage_.empty())
                parsed->homepage_ = website;
            if (parsed->homepage_ == parsed->depiction_)
                parsed->homepage_.clear();
            if (parsed->support_.empty())
                parsed->support_ = bugs;
        _end
    _end
} }

- (Package *) initWithVersion:(pkgCache::VerIterator)version withZone:(NSZone *)zone inPool:(CYPool *)pool database:(Database *)database {
    if ((self = [super init]) != nil) {
    _profile(Package$initWithVersion)
        if (pool == NULL)
            pool_ = new CYPool();
        else {
            pool_ = pool;
            pooled_ = true;
        }

        database_ = database;
        era_ = [database era];

        version_ = version;

        pkgCache::PkgIterator iterator(version_.ParentPkg());
        iterator_ = iterator;

        _profile(Package$initWithVersion$Version)
            file_ = version_.FileList();
        _end

        _profile(Package$initWithVersion$Cache)
            name_.set(NULL, version_.Display());

            latest_.set(NULL, StripVersion_(version_.VerStr()));

            pkgCache::VerIterator current(iterator.CurrentVer());
            if (!current.end())
                installed_.set(NULL, StripVersion_(current.VerStr()));
        _end

        _profile(Package$initWithVersion$Transliterate) do {
            if (CollationTransl_ == NULL)
                break;
            if (name_.empty())
                break;

            _profile(Package$initWithVersion$Transliterate$utf8)
            const uint8_t *data(reinterpret_cast<const uint8_t *>(name_.data()));
            for (size_t i(0), e(name_.size()); i != e; ++i)
                if (data[i] >= 0x80)
                    goto extended;
            break; extended:;
            _end

            UErrorCode code(U_ZERO_ERROR);
            int32_t length;

            _profile(Package$initWithVersion$Transliterate$u_strFromUTF8WithSub)
            CollationString_.resize(name_.size());
            u_strFromUTF8WithSub(&CollationString_[0], CollationString_.size(), &length, name_.data(), name_.size(), 0xfffd, NULL, &code);
            if (!U_SUCCESS(code))
                break;
            CollationString_.resize(length);
            _end

            _profile(Package$initWithVersion$Transliterate$utrans_trans)
            length = CollationString_.size();
            utrans_trans(CollationTransl_, reinterpret_cast<UReplaceable *>(&CollationString_), &CollationUCalls_, 0, &length, &code);
            if (!U_SUCCESS(code))
                break;
            _assert(CollationString_.size() == length);
            _end

            _profile(Package$initWithVersion$Transliterate$u_strToUTF8WithSub$preflight)
            u_strToUTF8WithSub(NULL, 0, &length, CollationString_.data(), CollationString_.size(), 0xfffd, NULL, &code);
            if (code == U_BUFFER_OVERFLOW_ERROR)
                code = U_ZERO_ERROR;
            else if (!U_SUCCESS(code))
                break;
            _end

            char *transform;
            _profile(Package$initWithVersion$Transliterate$apr_palloc)
            transform = pool_->malloc<char>(length);
            _end
            _profile(Package$initWithVersion$Transliterate$u_strToUTF8WithSub$transform)
            u_strToUTF8WithSub(transform, length, NULL, CollationString_.data(), CollationString_.size(), 0xfffd, NULL, &code);
            if (!U_SUCCESS(code))
                break;
            _end

            transform_.set(NULL, transform, length);
        } while (false); _end

        _profile(Package$initWithVersion$Tags)
#ifdef __arm64__
            pkgCache::TagIterator tag(version_.TagList());
#else
            pkgCache::TagIterator tag(iterator.TagList());
#endif
            if (!tag.end()) {
                tags_ = [NSMutableArray arrayWithCapacity:8];

                goto tag; for (; !tag.end(); ++tag) tag: {
                    const char *name(tag.Name());
                    NSString *string((NSString *) CYStringCreate(name));
                    if (string == nil)
                        continue;

                    [tags_ addObject:[string autorelease]];

                    if (role_ == 0 && strncmp(name, "role::", 6) == 0 /*&& strcmp(name, "role::leaper") != 0*/) {
                        if (strcmp(name + 6, "enduser") == 0)
                            role_ = 1;
                        else if (strcmp(name + 6, "hacker") == 0)
                            role_ = 2;
                        else if (strcmp(name + 6, "developer") == 0)
                            role_ = 3;
                        else if (strcmp(name + 6, "cydia") == 0)
                            role_ = 7;
                        else
                            role_ = 4;
                    }

                    if (strncmp(name, "cydia::", 7) == 0) {
                        if (strcmp(name + 7, "essential") == 0)
                            essential_ = true;
                        else if (strcmp(name + 7, "obsolete") == 0)
                            obsolete_ = true;
                    }
                }
            }
        _end

        _profile(Package$initWithVersion$Metadata)
            const char *mixed(iterator.Name());
            size_t size(strlen(mixed));
            static const size_t prefix(sizeof("/var/lib/dpkg/info/") - 1);
            char lower[prefix + size + 5 + 1];

            for (size_t i(0); i != size; ++i)
                lower[prefix + i] = mixed[i] | 0x20;

            if (!installed_.empty()) {
                memcpy(lower, "/var/lib/dpkg/info/", prefix);
                memcpy(lower + prefix + size, ".list", 6);
                struct stat info;
                if (stat(lower, &info) != -1)
                    upgraded_ = info.st_birthtime;
            }

            PackageValue *metadata(PackageFind(lower + prefix, size));
            metadata_ = metadata;

            id_.set(NULL, metadata->name_, size);

            const char *latest(version_.VerStr());
            size_t length(strlen(latest));

            uint16_t vhash(hashlittle(latest, length));

            size_t capped(std::min<size_t>(8, length));
            latest = latest + length - capped;

            if (metadata->first_ == 0)
                metadata->first_ = now_;

            if (metadata->vhash_ != vhash || strncmp(metadata->version_, latest, sizeof(metadata->version_)) != 0) {
                strncpy(metadata->version_, latest, sizeof(metadata->version_));
                metadata->vhash_ = vhash;
                metadata->last_ = now_;
            } else if (metadata->last_ == 0)
                metadata->last_ = metadata->first_;
        _end

        _profile(Package$initWithVersion$Section)
            section_ = version_.Section();
        _end

        _profile(Package$initWithVersion$Flags)
            essential_ |= ((iterator->Flags & pkgCache::Flag::Essential) == 0 ? NO : YES);
            ignored_ = iterator->SelectedState == pkgCache::State::Hold;
        _end
    _end } return self;
}

+ (Package *) newPackageWithIterator:(pkgCache::PkgIterator)iterator withZone:(NSZone *)zone inPool:(CYPool *)pool database:(Database *)database {
    pkgCache::VerIterator version;

    _profile(Package$packageWithIterator$GetCandidateVer)
        version = [database policy]->GetCandidateVer(iterator);
    _end

    if (version.end())
        return nil;

    Package *package;

    _profile(Package$packageWithIterator$Allocate)
        package = [Package allocWithZone:zone];
    _end

    _profile(Package$packageWithIterator$Initialize)
        package = [package
            initWithVersion:version
            withZone:zone
            inPool:pool
            database:database
        ];
    _end

    return package;
}

// XXX: just in case a Cydia extension is using this (I bet this is unlikely, though, due to CYPool?)
+ (Package *) packageWithIterator:(pkgCache::PkgIterator)iterator withZone:(NSZone *)zone inPool:(CYPool *)pool database:(Database *)database {
    return [[self newPackageWithIterator:iterator withZone:zone inPool:pool database:database] autorelease];
}

- (pkgCache::PkgIterator) iterator {
    return iterator_;
}

- (NSArray *) downgrades {
    NSMutableArray *versions([NSMutableArray arrayWithCapacity:4]);

    for (auto version(iterator_.VersionList()); !version.end(); ++version) {
        if (version == version_)
            continue;
        Package *package([[[Package allocWithZone:NULL] initWithVersion:version withZone:NULL inPool:NULL database:database_] autorelease]);
        if ([package source] == nil)
            continue;
        [versions addObject:package];
    }

    return versions;
}

- (NSString *) section {
    if (section$_ == nil) {
        if (section_ == NULL)
            return nil;

        _profile(Package$section$mappedSectionForPointer)
            section$_ = [database_ mappedSectionForPointer:section_];
        _end
    } return section$_;
}

- (NSString *) simpleSection {
    if (NSString *section = [self section])
        return Simplify(section);
    else
        return nil;
}

- (NSString *) longSection {
    if (NSString *section = [self section])
        return LocalizeSection(section);
    else
        return nil;
}

- (NSString *) shortSection {
    return [[NSBundle mainBundle] localizedStringForKey:[self simpleSection] value:nil table:@"Sections"];
}

- (NSString *) uri {
    return nil;
#if 0
    pkgIndexFile *index;
    pkgCache::PkgFileIterator file(file_.File());
    if (![database_ list].FindIndex(file, index))
        return nil;
    return [NSString stringWithUTF8String:iterator_->Path];
    //return [NSString stringWithUTF8String:file.Site()];
    //return [NSString stringWithUTF8String:index->ArchiveURI(file.FileName()).c_str()];
#endif
}

- (MIMEAddress *) maintainer {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return nil;

    pkgRecords::Parser *parser = &[database_ records]->Lookup(file_);
    const std::string &maintainer(parser->Maintainer());
    return maintainer.empty() ? nil : [MIMEAddress addressWithString:[NSString stringWithUTF8String:maintainer.c_str()]];
} }

- (NSString *) md5sum {
    return parsed_ == NULL ? nil : (id) parsed_->md5sum_;
}

- (size_t) size {
@synchronized (database_) {
    if ([database_ era] != era_ || version_.end())
        return 0;

    return version_->InstalledSize;
} }

- (NSString *) longDescription {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return nil;

    pkgRecords::Parser *parser = &[database_ records]->Lookup(file_);
    NSString *description([NSString stringWithUTF8String:parser->LongDesc().c_str()]);

    NSArray *lines = [description componentsSeparatedByString:@"\n"];
    NSMutableArray *trimmed = [NSMutableArray arrayWithCapacity:([lines count] - 1)];
    if ([lines count] < 2)
        return nil;

    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    for (size_t i(1), e([lines count]); i != e; ++i) {
        NSString *trim = [[lines objectAtIndex:i] stringByTrimmingCharactersInSet:whitespace];
        [trimmed addObject:trim];
    }

    return [trimmed componentsJoinedByString:@"\n"];
} }

- (NSString *) shortDescription {
    if (parsed_ != NULL)
        return static_cast<NSString *>(parsed_->tagline_);

@synchronized (database_) {
    pkgRecords::Parser &parser([database_ records]->Lookup(file_));
    std::string value(parser.ShortDesc());
    if (value.empty())
        return nil;
    if (value.size() > 200)
        value.resize(200);
    return [(id) CYStringCreate(value) autorelease];
} }

- (unichar) index {
    _profile(Package$index)
        CFStringRef name((CFStringRef) [self name]);
        if (CFStringGetLength(name) == 0)
            return '#';
        UniChar character(CFStringGetCharacterAtIndex(name, 0));
        if (!CFUniCharIsMemberOf(character, kCFUniCharLetterCharacterSet))
            return '#';
        return toupper(character);
    _end
}

- (PackageValue *) metadata {
    return metadata_;
}

- (time_t) seen {
    PackageValue *metadata([self metadata]);
    return metadata->subscribed_ ? metadata->last_ : metadata->first_;
}

- (bool) subscribed {
    return [self metadata]->subscribed_;
}

- (bool) setSubscribed:(bool)subscribed {
    PackageValue *metadata([self metadata]);
    if (metadata->subscribed_ == subscribed)
        return false;
    metadata->subscribed_ = subscribed;
    return true;
}

- (BOOL) ignored {
    return ignored_;
}

- (NSString *) latest {
    return latest_;
}

- (NSString *) installed {
    return installed_;
}

- (BOOL) uninstalled {
    return installed_.empty();
}

- (BOOL) upgradableAndEssential:(BOOL)essential {
    _profile(Package$upgradableAndEssential)
        pkgCache::VerIterator current(iterator_.CurrentVer());
        if (current.end())
            return essential && essential_;
        else
            return version_ != current;
    _end
}

- (BOOL) essential {
    return essential_;
}

- (BOOL) broken {
    return [database_ cache][iterator_].InstBroken();
}

- (BOOL) unfiltered {
    _profile(Package$unfiltered$obsolete)
        if (_unlikely(obsolete_))
            return false;
    _end

    _profile(Package$unfiltered$role)
        if (_unlikely(role_ > 3))
            return false;
    _end

    return true;
}

- (BOOL) visible {
    if (![self unfiltered])
        return false;

    NSString *section;

    _profile(Package$visible$section)
        section = [self section];
    _end

    _profile(Package$visible$isSectionVisible)
        if (!isSectionVisible(section))
            return false;
    _end

    return true;
}

- (BOOL) half {
    unsigned char current(iterator_->CurrentState);
    return current == pkgCache::State::HalfConfigured || current == pkgCache::State::HalfInstalled;
}

- (BOOL) halfConfigured {
    return iterator_->CurrentState == pkgCache::State::HalfConfigured;
}

- (BOOL) halfInstalled {
    return iterator_->CurrentState == pkgCache::State::HalfInstalled;
}

- (BOOL) hasMode {
@synchronized (database_) {
    if ([database_ era] != era_ || iterator_.end())
        return NO;

    pkgDepCache::StateCache &state([database_ cache][iterator_]);
    return state.Mode != pkgDepCache::ModeKeep;
} }

- (NSString *) mode {
@synchronized (database_) {
    if ([database_ era] != era_ || iterator_.end())
        return nil;

    pkgDepCache::StateCache &state([database_ cache][iterator_]);

    switch (state.Mode) {
        case pkgDepCache::ModeDelete:
            if ((state.iFlags & pkgDepCache::Purge) != 0)
                return @"PURGE";
            else
                return @"REMOVE";
        case pkgDepCache::ModeKeep:
            if ((state.iFlags & pkgDepCache::ReInstall) != 0)
                return @"REINSTALL";
            /*else if ((state.iFlags & pkgDepCache::AutoKept) != 0)
                return nil;*/
            else
                return nil;
        case pkgDepCache::ModeInstall:
            /*if ((state.iFlags & pkgDepCache::ReInstall) != 0)
                return @"REINSTALL";
            else*/ switch (state.Status) {
                case -1:
                    return @"DOWNGRADE";
                case 0:
                    return @"INSTALL";
                case 1:
                    return @"UPGRADE";
                case 2:
                    return @"NEW_INSTALL";
                _nodefault
            }
        _nodefault
    }
} }

- (NSString *) id {
    return id_;
}

- (NSString *) name {
    return name_.empty() ? id_ : name_;
}

- (UIImage *) icon {
    NSString *section = [self simpleSection];

    UIImage *icon(nil);
    if (parsed_ != NULL)
        if (NSString *href = parsed_->icon_)
            if ([href hasPrefix:@"file:///"])
                icon = [UIImage imageAtPath:[[href substringFromIndex:7] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (icon == nil) if (section != nil)
        icon = [UIImage imageAtPath:[NSString stringWithFormat:@"%@/Sections/%@.png", App_, [section stringByReplacingOccurrencesOfString:@" " withString:@"_"]]];
    if (icon == nil) if (Source *source = [self source]) if (NSString *dicon = [source defaultIcon])
        if ([dicon hasPrefix:@"file:///"])
            icon = [UIImage imageAtPath:[[dicon substringFromIndex:7] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (icon == nil)
        icon = [UIImage imageNamed:@"unknown.png"];
    return icon;
}

- (NSString *) homepage {
    return parsed_ == NULL ? nil : static_cast<NSString *>(parsed_->homepage_);
}

- (NSString *) depiction {
    return parsed_ != NULL && !parsed_->depiction_.empty() ? parsed_->depiction_ : [[self source] depictionForPackage:id_];
}

- (MIMEAddress *) author {
    return parsed_ == NULL || parsed_->author_.empty() ? nil : [MIMEAddress addressWithString:parsed_->author_];
}

- (NSString *) support {
    return parsed_ != NULL && !parsed_->support_.empty() ? parsed_->support_ : [[self source] supportForPackage:id_];
}

- (NSArray *) files {
    NSString *path = [NSString stringWithFormat:@"/var/lib/dpkg/info/%@.list", static_cast<NSString *>(id_)];
    NSMutableArray *files = [NSMutableArray arrayWithCapacity:128];

    std::ifstream fin;
    fin.open([path UTF8String]);
    if (!fin.is_open())
        return nil;

    std::string line;
    while (std::getline(fin, line))
        [files addObject:[NSString stringWithUTF8String:line.c_str()]];

    return files;
}

- (NSString *) state {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return nil;

    switch (iterator_->CurrentState) {
        case pkgCache::State::NotInstalled:
            return @"NotInstalled";
        case pkgCache::State::UnPacked:
            return @"UnPacked";
        case pkgCache::State::HalfConfigured:
            return @"HalfConfigured";
        case pkgCache::State::HalfInstalled:
            return @"HalfInstalled";
        case pkgCache::State::ConfigFiles:
            return @"ConfigFiles";
        case pkgCache::State::Installed:
            return @"Installed";
        case pkgCache::State::TriggersAwaited:
            return @"TriggersAwaited";
        case pkgCache::State::TriggersPending:
            return @"TriggersPending";
    }

    return (NSString *) [NSNull null];
} }

- (NSString *) selection {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return nil;

    switch (iterator_->SelectedState) {
        case pkgCache::State::Unknown:
            return @"Unknown";
        case pkgCache::State::Install:
            return @"Install";
        case pkgCache::State::Hold:
            return @"Hold";
        case pkgCache::State::DeInstall:
            return @"DeInstall";
        case pkgCache::State::Purge:
            return @"Purge";
    }

    return (NSString *) [NSNull null];
} }

- (NSArray *) warnings {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return nil;

    NSMutableArray *warnings([NSMutableArray arrayWithCapacity:4]);
    const char *name(iterator_.Name());

    size_t length(strlen(name));
    if (length < 2) invalid:
        [warnings addObject:UCLocalize("ILLEGAL_PACKAGE_IDENTIFIER")];
    else for (size_t i(0); i != length; ++i)
        if (
            /* XXX: technically this is not allowed */
            (name[i] < 'A' || name[i] > 'Z') &&
            (name[i] < 'a' || name[i] > 'z') &&
            (name[i] < '0' || name[i] > '9') &&
            (i == 0 || name[i] != '+' && name[i] != '-' && name[i] != '.')
        ) goto invalid;

    if (strcmp(name, "cydia") != 0) {
        bool cydia = false;
        bool user = false;
        bool _private = false;
        bool stash = false;
        bool dbstash = false;
        bool dsstore = false;

        bool repository = [[self section] isEqualToString:@"Repositories"];

        if (NSArray *files = [self files])
            for (NSString *file in files)
                if (!cydia && [file isEqualToString:@"/Applications/Cydia.app"])
                    cydia = true;
                else if (!user && [file isEqualToString:@"/User"])
                    user = true;
                else if (!_private && [file isEqualToString:@"/private"])
                    _private = true;
                else if (!stash && [file isEqualToString:@"/var/stash"])
                    stash = true;
                else if (!dbstash && [file isEqualToString:@"/var/db/stash"])
                    dbstash = true;
                else if (!dsstore && [file hasSuffix:@"/.DS_Store"])
                    dsstore = true;

        /* XXX: this is not sensitive enough. only some folders are valid. */
        if (cydia && !repository)
            [warnings addObject:[NSString stringWithFormat:UCLocalize("FILES_INSTALLED_TO"), @"Cydia.app"]];
        if (user)
            [warnings addObject:[NSString stringWithFormat:UCLocalize("FILES_INSTALLED_TO"), @"/User"]];
        if (_private)
            [warnings addObject:[NSString stringWithFormat:UCLocalize("FILES_INSTALLED_TO"), @"/private"]];
        if (stash)
            [warnings addObject:[NSString stringWithFormat:UCLocalize("FILES_INSTALLED_TO"), @"/var/stash"]];
        if (dbstash)
            [warnings addObject:[NSString stringWithFormat:UCLocalize("FILES_INSTALLED_TO"), @"/var/db/stash"]];
        if (dsstore)
            [warnings addObject:[NSString stringWithFormat:UCLocalize("FILES_INSTALLED_TO"), @".DS_Store"]];
    }

    return [warnings count] == 0 ? nil : warnings;
} }

- (NSArray *) applications {
    NSString *me([[NSBundle mainBundle] bundleIdentifier]);

    NSMutableArray *applications([NSMutableArray arrayWithCapacity:2]);

    static RegEx application_r("/Applications/(.*)\\.app/Info.plist");
    if (NSArray *files = [self files])
        for (NSString *file in files)
            if (application_r(file)) {
                NSDictionary *info([NSDictionary dictionaryWithContentsOfFile:file]);
                if (info == nil)
                    continue;
                NSString *id([info objectForKey:@"CFBundleIdentifier"]);
                if (id == nil || [id isEqualToString:me])
                    continue;

                NSString *display([info objectForKey:@"CFBundleDisplayName"]);
                if (display == nil)
                    display = application_r[1];

                NSString *bundle([file stringByDeletingLastPathComponent]);
                NSString *icon([info objectForKey:@"CFBundleIconFile"]);
                // XXX: maybe this should check if this is really a string, not just for length
                if (icon == nil || ![icon respondsToSelector:@selector(length)] || [icon length] == 0)
                    icon = @"icon.png";
                NSURL *url([NSURL fileURLWithPath:[bundle stringByAppendingPathComponent:icon]]);

                NSMutableArray *application([NSMutableArray arrayWithCapacity:2]);
                [applications addObject:application];

                [application addObject:id];
                [application addObject:display];
                [application addObject:url];
            }

    return [applications count] == 0 ? nil : applications;
}

- (Source *) source {
    if (source_ == nil) {
        @synchronized (database_) {
            if ([database_ era] != era_ || file_.end())
                source_ = (Source *) [NSNull null];
            else
                source_ = [database_ getSource:file_.File()] ?: (Source *) [NSNull null];
        }
    }

    return source_ == (Source *) [NSNull null] ? nil : source_;
}

- (time_t) upgraded {
    return upgraded_;
}

- (uint32_t) recent {
    return std::numeric_limits<uint32_t>::max() - upgraded_;
}

- (uint32_t) rank {
    return rank_;
}

- (BOOL) matches:(NSArray *)query {
    if (query == nil || [query count] == 0)
        return NO;

    rank_ = 0;

    NSString *string;
    NSRange range;
    NSUInteger length;

    string = [self name];
    length = [string length];

    if (length != 0)
    for (NSString *term in query) {
        range = [string rangeOfString:term options:MatchCompareOptions_];
        if (range.location != NSNotFound)
            rank_ -= 6 * 1000000 / length;
    }

    if (rank_ == 0) {
        string = [self id];
        length = [string length];

        if (length != 0)
        for (NSString *term in query) {
            range = [string rangeOfString:term options:MatchCompareOptions_];
            if (range.location != NSNotFound)
                rank_ -= 6 * 1000000 / length;
        }
    }

    string = [self shortDescription];
    length = [string length];
    NSUInteger stop(std::min<NSUInteger>(length, 200));

    if (length != 0)
    for (NSString *term in query) {
        range = [string rangeOfString:term options:MatchCompareOptions_ range:NSMakeRange(0, stop)];
        if (range.location != NSNotFound)
            rank_ -= 2 * 100000;
    }

    return rank_ != 0;
}

- (NSArray *) tags {
    return tags_;
}

- (BOOL) hasTag:(NSString *)tag {
    return tags_ == nil ? NO : [tags_ containsObject:tag];
}

- (NSString *) primaryPurpose {
    for (NSString *tag in (NSArray *) tags_)
        if ([tag hasPrefix:@"purpose::"])
            return [tag substringFromIndex:9];
    return nil;
}

- (NSArray *) purposes {
    NSMutableArray *purposes([NSMutableArray arrayWithCapacity:2]);
    for (NSString *tag in (NSArray *) tags_)
        if ([tag hasPrefix:@"purpose::"])
            [purposes addObject:[tag substringFromIndex:9]];
    return [purposes count] == 0 ? nil : purposes;
}

- (bool) isCommercial {
    return [self hasTag:@"cydia::commercial"];
}

- (void) setIndex:(size_t)index {
    if (metadata_->index_ != index + 1)
        metadata_->index_ = index + 1;
}

- (CYString &) cyname {
    return !transform_.empty() ? transform_ : !name_.empty() ? name_ : id_;
}

- (uint32_t) compareBySection:(NSArray *)sections {
    NSString *section([self section]);
    for (size_t i(0), e([sections count]); i != e; ++i) {
        if ([section isEqualToString:[[sections objectAtIndex:i] name]])
            return i;
    }

    return _not(uint32_t);
}

- (void) clear {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return;

    pkgProblemResolver *resolver = [database_ resolver];
    resolver->Clear(iterator_);

    pkgCacheFile &cache([database_ cache]);
    cache->SetReInstall(iterator_, false);
    cache->MarkKeep(iterator_, false);
} }

- (void) install {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return;

    pkgProblemResolver *resolver = [database_ resolver];
    resolver->Clear(iterator_);
    resolver->Protect(iterator_);

    pkgCacheFile &cache([database_ cache]);
    cache->SetCandidateVersion(version_);
    cache->SetReInstall(iterator_, false);
    cache->MarkInstall(iterator_, false);

    pkgDepCache::StateCache &state((*cache)[iterator_]);
    if (!state.Install())
        cache->SetReInstall(iterator_, true);
} }

- (void) remove {
@synchronized (database_) {
    if ([database_ era] != era_ || file_.end())
        return;

    pkgProblemResolver *resolver = [database_ resolver];
    resolver->Clear(iterator_);
    resolver->Remove(iterator_);
    resolver->Protect(iterator_);

    pkgCacheFile &cache([database_ cache]);
    cache->SetReInstall(iterator_, false);
    cache->MarkDelete(iterator_, true);
} }

@end
/* }}} */
/* Section Class {{{ */
@interface Section : NSObject {
    _H<NSString> name_;
    size_t row_;
    size_t count_;
    _H<NSString> localized_;
}

- (NSComparisonResult) compareByLocalized:(Section *)section;
- (Section *) initWithName:(NSString *)name localized:(NSString *)localized;
- (Section *) initWithName:(NSString *)name localize:(BOOL)localize;
- (Section *) initWithName:(NSString *)name row:(size_t)row localize:(BOOL)localize;

- (NSString *) name;
- (void) setName:(NSString *)name;

- (size_t) row;
- (size_t) count;

- (void) addToRow;
- (void) addToCount;

- (void) setCount:(size_t)count;
- (NSString *) localized;

@end

@implementation Section

- (NSComparisonResult) compareByLocalized:(Section *)section {
    NSString *lhs(localized_);
    NSString *rhs([section localized]);

    /*if ([lhs length] != 0 && [rhs length] != 0) {
        unichar lhc = [lhs characterAtIndex:0];
        unichar rhc = [rhs characterAtIndex:0];

        if (isalpha(lhc) && !isalpha(rhc))
            return NSOrderedAscending;
        else if (!isalpha(lhc) && isalpha(rhc))
            return NSOrderedDescending;
    }*/

    return [lhs compare:rhs options:LaxCompareOptions_];
}

- (Section *) initWithName:(NSString *)name localized:(NSString *)localized {
    if ((self = [self initWithName:name localize:NO]) != nil) {
        if (localized != nil)
            localized_ = localized;
    } return self;
}

- (Section *) initWithName:(NSString *)name localize:(BOOL)localize {
    return [self initWithName:name row:0 localize:localize];
}

- (Section *) initWithName:(NSString *)name row:(size_t)row localize:(BOOL)localize {
    if ((self = [super init]) != nil) {
        name_ = name;
        row_ = row;
        if (localize)
            localized_ = LocalizeSection(name_);
    } return self;
}

- (NSString *) name {
    return name_;
}

- (void) setName:(NSString *)name {
    name_ = name;
}

- (size_t) row {
    return row_;
}

- (size_t) count {
    return count_;
}

- (void) addToRow {
    ++row_;
}

- (void) addToCount {
    ++count_;
}

- (void) setCount:(size_t)count {
    count_ = count;
}

- (NSString *) localized {
    return localized_;
}

@end
/* }}} */

class CydiaLogCleaner :
    public pkgArchiveCleaner
{
  protected:
    virtual void Erase(const char *File, std::string Pkg, std::string Ver, struct stat &St) {
        unlink(File);
    }
};

/* Database Implementation {{{ */
@implementation Database

+ (Database *) sharedInstance {
    static _H<Database> instance;
    if (instance == nil)
        instance = [[[Database alloc] init] autorelease];
    return instance;
}

- (unsigned) era {
    return era_;
}

- (void) releasePackages {
    packages_ = nil;
}

- (bool) hasPackages {
    return [packages_ count] != 0;
}

- (void) dealloc {
    // XXX: actually implement this thing
    _assert(false);
    [self releasePackages];
    NSRecycleZone(zone_);
    [super dealloc];
}

- (void) _readCydia:(NSNumber *)fd {
    boost::fdistream is([fd intValue]);
    std::string line;

    static RegEx finish_r("finish:([^:]*)");

    while (std::getline(is, line)) {
        NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

        const char *data(line.c_str());
        size_t size = line.size();
        lprintf("C:%s\n", data);

        if (finish_r(data, size)) {
            NSString *finish = finish_r[1];
            int index = [Finishes_ indexOfObject:finish];
            if (index != INT_MAX && index > Finish_)
                Finish_ = index;
        }

        [pool release];
    }

    _assume(false);
}

- (void) _readStatus:(NSNumber *)fd {
    boost::fdistream is([fd intValue]);
    std::string line;

    static RegEx conffile_r("status: [^ ]* : conffile-prompt : (.*?) *");
    static RegEx pmstatus_r("([^:]*):([^:]*):([^:]*):(.*)");

    while (std::getline(is, line)) {
        NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

        const char *data(line.c_str());
        size_t size(line.size());
        lprintf("S:%s\n", data);

        if (conffile_r(data, size)) {
            // status: /fail : conffile-prompt : '/fail' '/fail.dpkg-new' 1 1
            [delegate_ performSelectorOnMainThread:@selector(setConfigurationData:) withObject:conffile_r[1] waitUntilDone:YES];
        } else if (strncmp(data, "status: ", 8) == 0) {
            // status: <package>: {unpacked,half-configured,installed}
            CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:[NSString stringWithUTF8String:(data + 8)] ofType:kCydiaProgressEventTypeStatus]);
            [progress_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];
        } else if (strncmp(data, "processing: ", 12) == 0) {
            // processing: configure: config-test
            CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:[NSString stringWithUTF8String:(data + 12)] ofType:kCydiaProgressEventTypeStatus]);
            [progress_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];
        } else if (pmstatus_r(data, size)) {
            std::string type([pmstatus_r[1] UTF8String]);

            NSString *package = pmstatus_r[2];
            if ([package isEqualToString:@"dpkg-exec"])
                package = nil;

            float percent([pmstatus_r[3] floatValue]);
            [progress_ performSelectorOnMainThread:@selector(setProgressPercent:) withObject:[NSNumber numberWithFloat:(percent / 100)] waitUntilDone:YES];

            NSString *string = pmstatus_r[4];

            if (type == "pmerror") {
                CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:string ofType:kCydiaProgressEventTypeError forPackage:package]);
                [progress_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];
            } else if (type == "pmstatus") {
                CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:string ofType:kCydiaProgressEventTypeStatus forPackage:package]);
                [progress_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];
            } else if (type == "pmconffile")
                [delegate_ performSelectorOnMainThread:@selector(setConfigurationData:) withObject:string waitUntilDone:YES];
            else
                lprintf("E:unknown pmstatus\n");
        } else
            lprintf("E:unknown status\n");

        [pool release];
    }

    _assume(false);
}

- (void) _readOutput:(NSNumber *)fd {
    boost::fdistream is([fd intValue]);
    std::string line;

    while (std::getline(is, line)) {
        NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

        lprintf("O:%s\n", line.c_str());

        CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:[NSString stringWithUTF8String:line.c_str()] ofType:kCydiaProgressEventTypeInformation]);
        [progress_ performSelectorOnMainThread:@selector(addProgressEvent:) withObject:event waitUntilDone:YES];

        [pool release];
    }

    _assume(false);
}

- (FILE *) input {
    return input_;
}

- (Package *) packageWithName:(NSString *)name {
    if (name == nil)
        return nil;
@synchronized (self) {
    if (static_cast<pkgDepCache *>(cache_) == NULL)
        return nil;
    pkgCache::PkgIterator iterator(cache_->FindPkg([name UTF8String]
#ifdef __arm64__
        , "any"
#endif
    ));
    return iterator.end() ? nil : [[Package newPackageWithIterator:iterator withZone:NULL inPool:NULL database:self] autorelease];
} }

- (id) init {
    if ((self = [super init]) != nil) {
        policy_ = NULL;
        records_ = NULL;
        resolver_ = NULL;
        fetcher_ = NULL;
        lock_ = NULL;

        zone_ = NSCreateZone(1024 * 1024, 256 * 1024, NO);

        sourceList_ = [NSMutableArray arrayWithCapacity:16];

        int fds[2];

        _assert(pipe(fds) != -1);
        cydiafd_ = fds[1];

        _config->Set("APT::Keep-Fds::", cydiafd_);
        setenv("CYDIA", [[[[NSNumber numberWithInt:cydiafd_] stringValue] stringByAppendingString:@" 1"] UTF8String], _not(int));

        [NSThread
            detachNewThreadSelector:@selector(_readCydia:)
            toTarget:self
            withObject:[NSNumber numberWithInt:fds[0]]
        ];

        _assert(pipe(fds) != -1);
        statusfd_ = fds[1];

        [NSThread
            detachNewThreadSelector:@selector(_readStatus:)
            toTarget:self
            withObject:[NSNumber numberWithInt:fds[0]]
        ];

        _assert(pipe(fds) != -1);
        _assert(dup2(fds[0], 0) != -1);
        _assert(close(fds[0]) != -1);

        input_ = fdopen(fds[1], "a");

        _assert(pipe(fds) != -1);
        _assert(dup2(fds[1], 1) != -1);
        _assert(close(fds[1]) != -1);

        [NSThread
            detachNewThreadSelector:@selector(_readOutput:)
            toTarget:self
            withObject:[NSNumber numberWithInt:fds[0]]
        ];
    } return self;
}

- (pkgCacheFile &) cache {
    return cache_;
}

- (pkgDepCache::Policy *) policy {
    return policy_;
}

- (pkgRecords *) records {
    return records_;
}

- (pkgProblemResolver *) resolver {
    return resolver_;
}

- (pkgAcquire &) fetcher {
    return *fetcher_;
}

- (pkgSourceList &) list {
    return *list_;
}

- (NSArray *) packages {
    return packages_;
}

- (NSArray *) sources {
    return sourceList_;
}

- (Source *) sourceWithKey:(NSString *)key {
    for (Source *source in [self sources]) {
        if ([[source key] isEqualToString:key])
            return source;
    } return nil;
}

- (bool) popErrorWithTitle:(NSString *)title {
    bool fatal(false);

    while (!_error->empty()) {
        std::string error;
        bool warning(!_error->PopMessage(error));
        if (!warning)
            fatal = true;

        for (;;) {
            size_t size(error.size());
            if (size == 0 || error[size - 1] != '\n')
                break;
            error.resize(size - 1);
        }

        lprintf("%c:[%s]\n", warning ? 'W' : 'E', error.c_str());

        static RegEx no_pubkey("GPG error:.* NO_PUBKEY .*");
        if (warning && no_pubkey(error.c_str()))
            continue;

        [delegate_ addProgressEventOnMainThread:[CydiaProgressEvent eventWithMessage:[NSString stringWithUTF8String:error.c_str()] ofType:(warning ? kCydiaProgressEventTypeWarning : kCydiaProgressEventTypeError)] forTask:title];
    }

    return fatal;
}

- (bool) popErrorWithTitle:(NSString *)title forOperation:(bool)success {
    return [self popErrorWithTitle:title] || !success;
}

- (bool) popErrorWithTitle:(NSString *)title forReadList:(pkgSourceList &)list {
    if ([self popErrorWithTitle:title forOperation:list.ReadMainList()])
        return true;
    return false;

    list.Reset();

    bool error(false);

    if (access("/etc/apt/sources.list", F_OK) == 0)
        error |= [self popErrorWithTitle:title forOperation:list.ReadAppend("/etc/apt/sources.list")];

    std::string base("/etc/apt/sources.list.d");
    if (DIR *sources = opendir(base.c_str())) {
        while (dirent *source = readdir(sources))
            if (source->d_name[0] != '.' && source->d_namlen > 5 && strcmp(source->d_name + source->d_namlen - 5, ".list") == 0 && strcmp(source->d_name, "cydia.list") != 0)
                error |= [self popErrorWithTitle:title forOperation:list.ReadAppend((base + "/" + source->d_name).c_str())];
        closedir(sources);
    }

    error |= [self popErrorWithTitle:title forOperation:list.ReadAppend(SOURCES_LIST)];

    return error;
}

- (void) reloadDataWithInvocation:(NSInvocation *)invocation {
@synchronized (self) {
    ++era_;

    [self releasePackages];

    sourceMap_.clear();
    [sourceList_ removeAllObjects];

    _error->Discard();

    delete list_;
    list_ = NULL;
    manager_ = NULL;
    delete lock_;
    lock_ = NULL;
    delete fetcher_;
    fetcher_ = NULL;
    delete resolver_;
    resolver_ = NULL;
    delete records_;
    records_ = NULL;
    delete policy_;
    policy_ = NULL;

    cache_.Close();

    pool_.~CYPool();
    new (&pool_) CYPool();

    NSRecycleZone(zone_);
    zone_ = NSCreateZone(1024 * 1024, 256 * 1024, NO);

    int chk(creat("/tmp/cydia.chk", 0644));
    if (chk != -1)
        close(chk);

    if (invocation != nil)
        [invocation invoke];

    NSString *title(UCLocalize("DATABASE"));

    list_ = new pkgSourceList();
    _profile(reloadDataWithInvocation$ReadMainList)
    if ([self popErrorWithTitle:title forReadList:*list_])
        return;
    _end

    _profile(reloadDataWithInvocation$Source$initWithMetaIndex)
    for (pkgSourceList::const_iterator source = list_->begin(); source != list_->end(); ++source) {
        Source *object([[[Source alloc] initWithMetaIndex:*source forDatabase:self inPool:&pool_] autorelease]);
        [sourceList_ addObject:object];
    }
    _end

    _trace();
    OpProgress progress;
    bool opened;
  open:
    delock_ = GetStatusDate();
    _profile(reloadDataWithInvocation$pkgCacheFile)
        opened = cache_.Open(progress, false);
    _end
    if (!opened) {
        // XXX: this block should probably be merged with popError: in some way
        while (!_error->empty()) {
            std::string error;
            bool warning(!_error->PopMessage(error));

            lprintf("cache_.Open():[%s]\n", error.c_str());

            [delegate_ addProgressEventOnMainThread:[CydiaProgressEvent eventWithMessage:[NSString stringWithUTF8String:error.c_str()] ofType:(warning ? kCydiaProgressEventTypeWarning : kCydiaProgressEventTypeError)] forTask:title];

            SEL repair(NULL);
            if (false);
            else if (error == "dpkg was interrupted, you must manually run 'dpkg --configure -a' to correct the problem. ")
                repair = @selector(configure);
            //else if (error == "The package lists or status file could not be parsed or opened.")
            //    repair = @selector(update);
            // else if (error == "Could not get lock /var/lib/dpkg/lock - open (35 Resource temporarily unavailable)")
            // else if (error == "Could not open lock file /var/lib/dpkg/lock - open (13 Permission denied)")
            // else if (error == "Malformed Status line")
            // else if (error == "The list of sources could not be read.")

            if (repair != NULL) {
                _error->Discard();
                [delegate_ repairWithSelector:repair];
                goto open;
            }
        }

        return;
    } else if ([self popErrorWithTitle:title forOperation:true])
        return;
    _trace();

    unlink("/tmp/cydia.chk");

    now_ = [[NSDate date] timeIntervalSince1970];

    policy_ = new pkgDepCache::Policy();
    records_ = new pkgRecords(cache_);
    resolver_ = new pkgProblemResolver(cache_);
    fetcher_ = new pkgAcquire(&status_);
    lock_ = NULL;

    if (cache_->DelCount() != 0 || cache_->InstCount() != 0) {
        [delegate_ addProgressEventOnMainThread:[CydiaProgressEvent eventWithMessage:UCLocalize("COUNTS_NONZERO_EX") ofType:kCydiaProgressEventTypeError] forTask:title];
        return;
    }

    _profile(reloadDataWithInvocation$pkgApplyStatus)
    if ([self popErrorWithTitle:title forOperation:pkgApplyStatus(cache_)])
        return;
    _end

    if (cache_->BrokenCount() != 0) {
        _profile(pkgApplyStatus$pkgFixBroken)
        if ([self popErrorWithTitle:title forOperation:pkgFixBroken(cache_)])
            return;
        _end

        if (cache_->BrokenCount() != 0) {
            [delegate_ addProgressEventOnMainThread:[CydiaProgressEvent eventWithMessage:UCLocalize("STILL_BROKEN_EX") ofType:kCydiaProgressEventTypeError] forTask:title];
            return;
        }

        _profile(pkgApplyStatus$pkgMinimizeUpgrade)
        if ([self popErrorWithTitle:title forOperation:pkgMinimizeUpgrade(cache_)])
            return;
        _end
    }

    for (Source *object in (id) sourceList_) {
        metaIndex *source([object metaIndex]);
        std::vector<pkgIndexFile *> *indices = source->GetIndexFiles();
        for (std::vector<pkgIndexFile *>::const_iterator index = indices->begin(); index != indices->end(); ++index)
            // XXX: this could be more intelligent
            if (dynamic_cast<debPackagesIndex *>(*index) != NULL) {
                pkgCache::PkgFileIterator cached((*index)->FindInCache(cache_));
                if (!cached.end())
                    sourceMap_[cached->ID] = object;
            }
    }

    {
        size_t capacity(MetaFile_->active_);
        if (capacity == 0)
            capacity = 128*1024;
        else
            capacity += 1024;

        std::vector<Package *> packages;
        packages.reserve(capacity);
        size_t lost(0);

        size_t last(0);
        _profile(reloadDataWithInvocation$packageWithIterator)
        for (pkgCache::PkgIterator iterator = cache_->PkgBegin(); !iterator.end(); ++iterator)
            if (Package *package = [Package newPackageWithIterator:iterator withZone:zone_ inPool:&pool_ database:self]) {
                if (unsigned index = package.metadata->index_) {
                    --index;
                    if (packages.size() == index) {
                        packages.push_back(package);
                    } else if (packages.size() <= index) {
                        packages.resize(index + 1, nil);
                        packages[index] = package;
                        continue;
                    } else {
                        std::swap(package, packages[index]);
                        if (package != nil) {
                            if (package.metadata->index_ == index + 1)
                                ++lost;
                            goto lost;
                        }
                        if (last != index)
                            continue;
                    }
                } else {
                    ++lost;
                    lost: if (last == packages.size())
                        packages.push_back(package);
                    else
                        packages[last] = package;
                    ++last;
                }

                for (; last != packages.size(); ++last)
                    if (packages[last] == nil)
                        break;
            }
        _end

        for (size_t next(last + 1); last != packages.size(); ++last, ++next) {
            while (true) {
                if (next == packages.size())
                    goto done;
                if (packages[next] != nil)
                    break;
                ++next;
            }

            std::swap(packages[last], packages[next]);
        } done:;

        packages.resize(last);

        if (lost > 128) {
            NSLog(@"lost = %zu", lost);

            _profile(reloadDataWithInvocation$radix$8)
            CYRadixSortUsingFunction(packages.data(), packages.size(), reinterpret_cast<MenesRadixSortFunction>(&PackagePrefixRadix), reinterpret_cast<void *>(8));
            _end

            _profile(reloadDataWithInvocation$radix$4)
            CYRadixSortUsingFunction(packages.data(), packages.size(), reinterpret_cast<MenesRadixSortFunction>(&PackagePrefixRadix), reinterpret_cast<void *>(4));
            _end

            _profile(reloadDataWithInvocation$radix$0)
            CYRadixSortUsingFunction(packages.data(), packages.size(), reinterpret_cast<MenesRadixSortFunction>(&PackagePrefixRadix), reinterpret_cast<void *>(0));
            _end
        }

        _profile(reloadDataWithInvocation$insertion)
        CYArrayInsertionSortValues(packages.data(), packages.size(), &PackageNameCompare, NULL);
        _end

        packages_ = [[[NSArray alloc] initWithObjects:packages.data() count:packages.size()] autorelease];

        /*_profile(reloadDataWithInvocation$CFQSortArray)
        CFQSortArray(&packages.front(), packages.size(), sizeof(packages.front()), reinterpret_cast<CFComparatorFunction>(&PackageNameCompare_), NULL);
        _end*/

        /*_profile(reloadDataWithInvocation$stdsort)
        std::sort(packages.begin(), packages.end(), PackageNameOrdering());
        _end*/

        /*_profile(reloadDataWithInvocation$CFArraySortValues)
        CFArraySortValues((CFMutableArrayRef) packages_, CFRangeMake(0, [packages_ count]), reinterpret_cast<CFComparatorFunction>(&PackageNameCompare), NULL);
        _end*/

        /*_profile(reloadDataWithInvocation$sortUsingFunction)
        [packages_ sortUsingFunction:reinterpret_cast<NSComparisonResult (*)(id, id, void *)>(&PackageNameCompare) context:NULL];
        _end*/

        MetaFile_->active_ = packages.size();
        for (size_t index(0), count(packages.size()); index != count; ++index) {
            auto package(packages[index]);
            [package setIndex:index];
            [package release];
        }
    }
} }

- (void) clear {
@synchronized (self) {
    delete resolver_;
    resolver_ = new pkgProblemResolver(cache_);

    for (pkgCache::PkgIterator iterator(cache_->PkgBegin()); !iterator.end(); ++iterator)
        if (!cache_[iterator].Keep())
            cache_->MarkKeep(iterator, false);
        else if ((cache_[iterator].iFlags & pkgDepCache::ReInstall) != 0)
            cache_->SetReInstall(iterator, false);
} }

- (void) configure {
    NSString *dpkg = [NSString stringWithFormat:@"/usr/libexec/cydo --configure -a --status-fd %u", statusfd_];
    _trace();
    system([dpkg UTF8String]);
    _trace();
}

- (bool) clean {
@synchronized (self) {
    // XXX: I don't remember this condition
    if (lock_ != NULL)
        return false;

    FileFd Lock;
    Lock.Fd(GetLock(_config->FindDir("Dir::Cache::Archives") + "lock"));

    NSString *title(UCLocalize("CLEAN_ARCHIVES"));

    if ([self popErrorWithTitle:title])
        return false;

    pkgAcquire fetcher;
    fetcher.Clean(_config->FindDir("Dir::Cache::Archives"));

    CydiaLogCleaner cleaner;
    if ([self popErrorWithTitle:title forOperation:cleaner.Go(_config->FindDir("Dir::Cache::Archives") + "partial/", cache_)])
        return false;

    return true;
} }

- (bool) prepare {
    fetcher_->Shutdown();

    pkgRecords records(cache_);

    lock_ = new FileFd();
    lock_->Fd(GetLock(_config->FindDir("Dir::Cache::Archives") + "lock"));

    NSString *title(UCLocalize("PREPARE_ARCHIVES"));

    if ([self popErrorWithTitle:title])
        return false;

    pkgSourceList list;
    if ([self popErrorWithTitle:title forReadList:list])
        return false;

    manager_ = (_system->CreatePM(cache_));
    if ([self popErrorWithTitle:title forOperation:manager_->GetArchives(fetcher_, &list, &records)])
        return false;

    return true;
}

- (void) perform {
    bool substrate(RestartSubstrate_);
    RestartSubstrate_ = false;

    NSString *title(UCLocalize("PERFORM_SELECTIONS"));

    NSMutableArray *before = [NSMutableArray arrayWithCapacity:16]; {
        pkgSourceList list;
        if ([self popErrorWithTitle:title forReadList:list])
            return;
        for (pkgSourceList::const_iterator source = list.begin(); source != list.end(); ++source)
            [before addObject:[NSString stringWithUTF8String:(*source)->GetURI().c_str()]];
    }

    [delegate_ performSelectorOnMainThread:@selector(retainNetworkActivityIndicator) withObject:nil waitUntilDone:YES];

    if (fetcher_->Run(PulseInterval_) != pkgAcquire::Continue) {
        _trace();
        [self popErrorWithTitle:title];
        return;
    }

    bool failed = false;
    for (pkgAcquire::ItemIterator item = fetcher_->ItemsBegin(); item != fetcher_->ItemsEnd(); item++) {
        if ((*item)->Status == pkgAcquire::Item::StatDone && (*item)->Complete)
            continue;
        if ((*item)->Status == pkgAcquire::Item::StatIdle)
            continue;

        std::string uri = (*item)->DescURI();
        std::string error = (*item)->ErrorText;

        lprintf("pAf:%s:%s\n", uri.c_str(), error.c_str());
        failed = true;

        CydiaProgressEvent *event([CydiaProgressEvent eventWithMessage:[NSString stringWithUTF8String:error.c_str()] ofType:kCydiaProgressEventTypeError]);
        [delegate_ addProgressEventOnMainThread:event forTask:title];
    }

    [delegate_ performSelectorOnMainThread:@selector(releaseNetworkActivityIndicator) withObject:nil waitUntilDone:YES];

    if (failed) {
        _trace();
        return;
    }

    if (substrate)
        RestartSubstrate_ = true;

    if (![delock_ isEqual:GetStatusDate()]) {
        [delegate_ addProgressEventOnMainThread:[CydiaProgressEvent eventWithMessage:UCLocalize("DPKG_LOCKED") ofType:kCydiaProgressEventTypeError] forTask:title];
        return;
    }

    delock_ = nil;

    pkgPackageManager::OrderResult result(manager_->DoInstall(statusfd_));

    NSString *oextended(@"/var/lib/apt/extended_states");
    NSString *nextended(Cache("extended_states"));

    struct stat info;
    if (stat([nextended UTF8String], &info) != -1 && (info.st_mode & S_IFMT) == S_IFREG)
        system([[NSString stringWithFormat:@"/usr/libexec/cydia/cydo /bin/cp --remove-destination %@ %@", ShellEscape(nextended), ShellEscape(oextended)] UTF8String]);

    unlink([nextended UTF8String]);
    symlink([oextended UTF8String], [nextended UTF8String]);

    if ([self popErrorWithTitle:title])
        return;

    if (result == pkgPackageManager::Failed) {
        _trace();
        return;
    }

    if (result != pkgPackageManager::Completed) {
        _trace();
        return;
    }

    NSMutableArray *after = [NSMutableArray arrayWithCapacity:16]; {
        pkgSourceList list;
        if ([self popErrorWithTitle:title forReadList:list])
            return;
        for (pkgSourceList::const_iterator source = list.begin(); source != list.end(); ++source)
            [after addObject:[NSString stringWithUTF8String:(*source)->GetURI().c_str()]];
    }

    if (![before isEqualToArray:after])
        [self update];
}

- (bool) delocked {
    return ![delock_ isEqual:GetStatusDate()];
}

- (bool) upgrade {
    NSString *title(UCLocalize("UPGRADE"));
    if ([self popErrorWithTitle:title forOperation:pkgDistUpgrade(cache_)])
        return false;
    return true;
}

- (void) update {
    [self updateWithStatus:status_];
}

- (void) updateWithStatus:(CancelStatus &)status {
    NSString *title(UCLocalize("REFRESHING_DATA"));

    pkgSourceList list;
    if ([self popErrorWithTitle:title forReadList:list])
        return;

    FileFd lock;
    lock.Fd(GetLock(_config->FindDir("Dir::State::Lists") + "lock"));
    if ([self popErrorWithTitle:title])
        return;

    [delegate_ performSelectorOnMainThread:@selector(retainNetworkActivityIndicator) withObject:nil waitUntilDone:YES];

    bool success(ListUpdate(status, list, PulseInterval_));
    if (status.WasCancelled())
        _error->Discard();
    else {
        [self popErrorWithTitle:title forOperation:success];

        [[NSDictionary dictionaryWithObjectsAndKeys:
            [NSDate date], @"LastUpdate",
        nil] writeToFile:@ CacheState_ atomically:YES];
    }

    [delegate_ performSelectorOnMainThread:@selector(releaseNetworkActivityIndicator) withObject:nil waitUntilDone:YES];
}

- (void) setDelegate:(NSObject<DatabaseDelegate> *)delegate {
    delegate_ = delegate;
}

- (void) setProgressDelegate:(NSObject<ProgressDelegate> *)delegate {
    progress_ = delegate;
    status_.setDelegate(delegate);
}

- (NSObject<ProgressDelegate> *) progressDelegate {
    return progress_;
}

- (Source *) getSource:(pkgCache::PkgFileIterator)file {
    SourceMap::const_iterator i(sourceMap_.find(file->ID));
    return i == sourceMap_.end() ? nil : i->second;
}

- (void) setFetch:(bool)fetch forURI:(const char *)uri {
    for (Source *source in (id) sourceList_)
        [source setFetch:fetch forURI:uri];
}

- (void) resetFetch {
    for (Source *source in (id) sourceList_)
        [source resetFetch];
}

- (NSString *) mappedSectionForPointer:(const char *)section {
    _H<NSString> *mapped;

    _profile(Database$mappedSectionForPointer$Cache)
        mapped = &sections_[section];
    _end

    if (*mapped == NULL) {
        size_t length(strlen(section));
        char spaced[length + 1];

        _profile(Database$mappedSectionForPointer$Replace)
            for (size_t index(0); index != length; ++index)
                spaced[index] = section[index] == '_' ? ' ' : section[index];
            spaced[length] = '\0';
        _end

        NSString *string;

        _profile(Database$mappedSectionForPointer$stringWithUTF8String)
            string = [NSString stringWithUTF8String:spaced];
        _end

        _profile(Database$mappedSectionForPointer$Map)
            string = [SectionMap_ objectForKey:string] ?: string;
        _end

        *mapped = string;
    } return *mapped;
}

@end
/* }}} */

@interface CydiaObject : CyteObject {
    _transient id delegate_;
}

@end

@interface CydiaWebViewController : CyteWebViewController {
    _H<CydiaObject> cydia_;
}

+ (NSURLRequest *) requestWithHeaders:(NSURLRequest *)request;
+ (void) didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame withCydia:(CydiaObject *)cydia;
- (void) setDelegate:(id)delegate;

@end

/* Web Scripting {{{ */
@implementation CydiaObject

- (void) setDelegate:(id)delegate {
    delegate_ = delegate;
}

- (NSArray *) attributeKeys {
    return [[NSArray arrayWithObjects:
        @"cells",
        @"device",
        @"mcc",
        @"mnc",
        @"operator",
        @"role",
        @"version",
    nil] arrayByAddingObjectsFromArray:[super attributeKeys]];
}

- (NSString *) version {
    return Cydia_;
}

- (NSString *) device {
    return UniqueIdentifier();
}

- (NSArray *) cells {
    auto *$_CTServerConnectionCreate(reinterpret_cast<id (*)(void *, void *, void *)>(dlsym(RTLD_DEFAULT, "_CTServerConnectionCreate")));
    if ($_CTServerConnectionCreate == NULL)
        return nil;

    struct CTResult { int flag; int error; };
    auto *$_CTServerConnectionCellMonitorCopyCellInfo(reinterpret_cast<CTResult (*)(CFTypeRef, void *, CFArrayRef *)>(dlsym(RTLD_DEFAULT, "_CTServerConnectionCellMonitorCopyCellInfo")));
    if ($_CTServerConnectionCellMonitorCopyCellInfo == NULL)
        return nil;

    _H<const void> connection($_CTServerConnectionCreate(NULL, NULL, NULL), true);
    if (connection == nil)
        return nil;

    int count(0);
    CFArrayRef cells(NULL);
    auto result($_CTServerConnectionCellMonitorCopyCellInfo(connection, &count, &cells));
    if (result.flag != 0)
        return nil;

    return [(NSArray *) cells autorelease];
}

- (NSString *) mcc {
    if (CFStringRef (*$CTSIMSupportCopyMobileSubscriberCountryCode)(CFAllocatorRef) = reinterpret_cast<CFStringRef (*)(CFAllocatorRef)>(dlsym(RTLD_DEFAULT, "CTSIMSupportCopyMobileSubscriberCountryCode")))
        return [(NSString *) (*$CTSIMSupportCopyMobileSubscriberCountryCode)(kCFAllocatorDefault) autorelease];
    return nil;
}

- (NSString *) mnc {
    if (CFStringRef (*$CTSIMSupportCopyMobileSubscriberNetworkCode)(CFAllocatorRef) = reinterpret_cast<CFStringRef (*)(CFAllocatorRef)>(dlsym(RTLD_DEFAULT, "CTSIMSupportCopyMobileSubscriberNetworkCode")))
        return [(NSString *) (*$CTSIMSupportCopyMobileSubscriberNetworkCode)(kCFAllocatorDefault) autorelease];
    return nil;
}

- (NSString *) operator {
    if (CFStringRef (*$CTRegistrationCopyOperatorName)(CFAllocatorRef) = reinterpret_cast<CFStringRef (*)(CFAllocatorRef)>(dlsym(RTLD_DEFAULT, "CTRegistrationCopyOperatorName")))
        return [(NSString *) (*$CTRegistrationCopyOperatorName)(kCFAllocatorDefault) autorelease];
    return nil;
}

- (NSString *) role {
    return (id) [NSNull null];
}

+ (NSString *) webScriptNameForSelector:(SEL)selector {
    if (false);
    else if (selector == @selector(addBridgedHost:))
        return @"addBridgedHost";
    else if (selector == @selector(addInsecureHost:))
        return @"addInsecureHost";
    else if (selector == @selector(addSource:::))
        return @"addSource";
    else if (selector == @selector(addTrivialSource:))
        return @"addTrivialSource";
    else if (selector == @selector(du:))
        return @"du";
    else if (selector == @selector(getAllSources))
        return @"getAllSources";
    else if (selector == @selector(getApplicationInfo:value:))
        return @"getApplicationInfoValue";
    else if (selector == @selector(getDisplayIdentifiers))
        return @"getDisplayIdentifiers";
    else if (selector == @selector(getLocalizedNameForDisplayIdentifier:))
        return @"getLocalizedNameForDisplayIdentifier";
    else if (selector == @selector(getInstalledPackages))
        return @"getInstalledPackages";
    else if (selector == @selector(getPackageById:))
        return @"getPackageById";
    else if (selector == @selector(getMetadataKeys))
        return @"getMetadataKeys";
    else if (selector == @selector(getMetadataValue:))
        return @"getMetadataValue";
    else if (selector == @selector(getSessionValue:))
        return @"getSessionValue";
    else if (selector == @selector(installPackages:))
        return @"installPackages";
    else if (selector == @selector(refreshSources))
        return @"refreshSources";
    else if (selector == @selector(saveConfig))
        return @"saveConfig";
    else if (selector == @selector(setMetadataValue::))
        return @"setMetadataValue";
    else if (selector == @selector(setSessionValue::))
        return @"setSessionValue";
    else if (selector == @selector(substitutePackageNames:))
        return @"substitutePackageNames";
    else if (selector == @selector(setToken:))
        return @"setToken";
    else
        return nil;
}

+ (BOOL) isSelectorExcludedFromWebScript:(SEL)selector {
    return [self webScriptNameForSelector:selector] == nil;
}

- (NSDictionary *) getApplicationInfo:(NSString *)display value:(NSString *)key {
    char path[1024];
    if (SBBundlePathForDisplayIdentifier(SBSSpringBoardServerPort(), [display UTF8String], path) != 0)
        return (id) [NSNull null];
    NSDictionary *info([NSDictionary dictionaryWithContentsOfFile:[[NSString stringWithUTF8String:path] stringByAppendingString:@"/Info.plist"]]);
    if (info == nil)
        return (id) [NSNull null];
    return [info objectForKey:key];
}

- (NSArray *) getDisplayIdentifiers {
    return SBSCopyApplicationDisplayIdentifiers(false, false);
}

- (NSString *) getLocalizedNameForDisplayIdentifier:(NSString *)identifier {
    return [SBSCopyLocalizedApplicationNameForDisplayIdentifier(identifier) autorelease] ?: (id) [NSNull null];
}

- (NSNumber *) getKernelNumber:(NSString *)name {
    const char *string([name UTF8String]);

    size_t size;
    if (sysctlbyname(string, NULL, &size, NULL, 0) == -1)
        return (id) [NSNull null];

    if (size != sizeof(int))
        return (id) [NSNull null];

    int value;
    if (sysctlbyname(string, &value, &size, NULL, 0) == -1)
        return (id) [NSNull null];

    return [NSNumber numberWithInt:value];
}

- (NSArray *) getMetadataKeys {
@synchronized (Values_) {
    return [Values_ allKeys];
} }

- (id) getMetadataValue:(NSString *)key {
@synchronized (Values_) {
    return [Values_ objectForKey:key];
} }

- (void) setMetadataValue:(NSString *)key :(NSString *)value {
@synchronized (Values_) {
    if (value == nil || value == (id) [WebUndefined undefined] || value == (id) [NSNull null])
        [Values_ removeObjectForKey:key];
    else
        [Values_ setObject:value forKey:key];
} }

- (id) getSessionValue:(NSString *)key {
@synchronized (SessionData_) {
    return [SessionData_ objectForKey:key];
} }

- (void) setSessionValue:(NSString *)key :(NSString *)value {
@synchronized (SessionData_) {
    if (value == (id) [WebUndefined undefined])
        [SessionData_ removeObjectForKey:key];
    else
        [SessionData_ setObject:value forKey:key];
} }

- (void) addBridgedHost:(NSString *)host {
@synchronized (BridgedHosts_) {
    [BridgedHosts_ addObject:host];
} }

- (void) addInsecureHost:(NSString *)host {
@synchronized (InsecureHosts_) {
    [InsecureHosts_ addObject:host];
} }

- (void) addSource:(NSString *)href :(NSString *)distribution :(WebScriptObject *)sections {
    NSMutableArray *array([NSMutableArray arrayWithCapacity:[sections count]]);

    for (NSString *section in sections)
        [array addObject:section];

    [delegate_ performSelectorOnMainThread:@selector(addSource:) withObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
        @"deb", @"Type",
        href, @"URI",
        distribution, @"Distribution",
        array, @"Sections",
    nil] waitUntilDone:NO];
}

- (BOOL) addTrivialSource:(NSString *)href {
    href = VerifySource(href);
    if (href == nil)
        return NO;
    [delegate_ performSelectorOnMainThread:@selector(addTrivialSource:) withObject:href waitUntilDone:NO];
    return YES;
}

- (void) refreshSources {
    [delegate_ performSelectorOnMainThread:@selector(syncData) withObject:nil waitUntilDone:NO];
}

- (void) saveConfig {
    [delegate_ performSelectorOnMainThread:@selector(_saveConfig) withObject:nil waitUntilDone:NO];
}

- (NSArray *) getAllSources {
    return [[Database sharedInstance] sources];
}

- (NSArray *) getInstalledPackages {
    Database *database([Database sharedInstance]);
@synchronized (database) {
    NSArray *packages([database packages]);
    NSMutableArray *installed([NSMutableArray arrayWithCapacity:1024]);
    for (Package *package in packages)
        if (![package uninstalled])
            [installed addObject:package];
    return installed;
} }

- (Package *) getPackageById:(NSString *)id {
    if (Package *package = [[Database sharedInstance] packageWithName:id]) {
        [package parse];
        return package;
    } else
        return (Package *) [NSNull null];
}

- (NSNumber *) du:(NSString *)path {
    NSNumber *value(nil);

    FILE *du(popen([[NSString stringWithFormat:@"/usr/libexec/cydia/cydo /usr/libexec/cydia/du -ks %@", ShellEscape(path)] UTF8String], "r"));
    if (du != NULL) {
        char line[1024];
        while (fgets(line, sizeof(line), du) != NULL) {
            size_t length(strlen(line));
            while (length != 0 && line[length - 1] == '\n')
                line[--length] = '\0';
            if (char *tab = strchr(line, '\t')) {
                *tab = '\0';
                value = [NSNumber numberWithUnsignedLong:strtoul(line, NULL, 0)];
            }
        }
        pclose(du);
    }

    return value;
}

- (void) installPackages:(NSArray *)packages {
    [delegate_ performSelectorOnMainThread:@selector(installPackages:) withObject:packages waitUntilDone:NO];
}

- (NSString *) substitutePackageNames:(NSString *)message {
    auto database([Database sharedInstance]);

    // XXX: this check is less racy than you'd expect, but this entire concept is a little awkward
    if (![database hasPackages])
        return message;

    NSMutableArray *words([[[message componentsSeparatedByString:@" "] mutableCopy] autorelease]);
    for (size_t i(0), e([words count]); i != e; ++i) {
        NSString *word([words objectAtIndex:i]);
        if (Package *package = [database packageWithName:word])
            [words replaceObjectAtIndex:i withObject:[package name]];
    }

    return [words componentsJoinedByString:@" "];
}

- (void) setToken:(NSString *)token {
    // XXX: the website expects this :/
}

@end
/* }}} */

@interface NSURL (CydiaSecure)
@end

@implementation NSURL (CydiaSecure)

- (bool) isCydiaSecure {
    if ([[[self scheme] lowercaseString] isEqualToString:@"https"])
        return true;

    @synchronized (InsecureHosts_) {
        if ([InsecureHosts_ containsObject:[self host]])
            return true;
    }

    return false;
}

@end

/* Cydia Browser Controller {{{ */
@implementation CydiaWebViewController

- (NSURL *) navigationURL {
    if (NSURLRequest *request = self.request)
        return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://url/%@", [[request URL] absoluteString]]];
    else
        return nil;
}

- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame {
    [super webView:view didClearWindowObject:window forFrame:frame];
    [CydiaWebViewController didClearWindowObject:window forFrame:frame withCydia:cydia_];
}

+ (void) didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame withCydia:(CydiaObject *)cydia {
    WebDataSource *source([frame dataSource]);
    NSURLResponse *response([source response]);
    NSURL *url([response URL]);
    NSString *scheme([[url scheme] lowercaseString]);

    bool bridged(false);

    @synchronized (BridgedHosts_) {
        if ([scheme isEqualToString:@"file"])
            bridged = true;
        else if ([scheme isEqualToString:@"https"])
            if ([BridgedHosts_ containsObject:[url host]])
                bridged = true;
    }

    if (bridged)
        [window setValue:cydia forKey:@"cydia"];
}

- (void) _setupMail:(MFMailComposeViewController *)controller {
    [controller addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/cydia.log"] mimeType:@"text/plain" fileName:@"cydia.log"];

    system("/usr/bin/dpkg -l >/tmp/dpkgl.log");
    [controller addAttachmentData:[NSData dataWithContentsOfFile:@"/tmp/dpkgl.log"] mimeType:@"text/plain" fileName:@"dpkgl.log"];
}

- (NSURLRequest *) webView:(WebView *)view resource:(id)resource willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source {
    return [CydiaWebViewController requestWithHeaders:[super webView:view resource:resource willSendRequest:request redirectResponse:response fromDataSource:source]];
}

- (NSURLRequest *) webThreadWebView:(WebView *)view resource:(id)resource willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)source {
    return [CydiaWebViewController requestWithHeaders:[super webThreadWebView:view resource:resource willSendRequest:request redirectResponse:response fromDataSource:source]];
}

+ (NSURLRequest *) requestWithHeaders:(NSURLRequest *)request {
    NSMutableURLRequest *copy([[request mutableCopy] autorelease]);

    NSURL *url([copy URL]);
    NSString *href([url absoluteString]);
    NSString *host([url host]);

    if ([href hasPrefix:@"https://cydia.saurik.com/TSS/"]) {
        if (NSString *agent = [copy valueForHTTPHeaderField:@"X-User-Agent"]) {
            [copy setValue:agent forHTTPHeaderField:@"User-Agent"];
            [copy setValue:nil forHTTPHeaderField:@"X-User-Agent"];
        }

        [copy setValue:nil forHTTPHeaderField:@"Referer"];
        [copy setValue:nil forHTTPHeaderField:@"Origin"];

        [copy setURL:[NSURL URLWithString:[@"http://gs.apple.com/TSS/" stringByAppendingString:[href substringFromIndex:29]]]];
        return copy;
    }

    if ([copy valueForHTTPHeaderField:@"X-Cydia-Cf"] == nil)
        [copy setValue:[NSString stringWithFormat:@"%.2f", kCFCoreFoundationVersionNumber] forHTTPHeaderField:@"X-Cydia-Cf"];
    if (Machine_ != NULL && [copy valueForHTTPHeaderField:@"X-Machine"] == nil)
        [copy setValue:[NSString stringWithUTF8String:Machine_] forHTTPHeaderField:@"X-Machine"];

    bool bridged; @synchronized (BridgedHosts_) {
        bridged = [BridgedHosts_ containsObject:host];
    }

    if ([url isCydiaSecure] && bridged && UniqueID_ != nil && [copy valueForHTTPHeaderField:@"X-Cydia-Id"] == nil)
        [copy setValue:UniqueID_ forHTTPHeaderField:@"X-Cydia-Id"];

    return copy;
}

- (void) setDelegate:(id)delegate {
    [super setDelegate:delegate];
    [cydia_ setDelegate:delegate];
}

- (id) init {
    if ((self = [super initWithWidth:0 ofClass:[CydiaWebViewController class]]) != nil) {
        cydia_ = [[[CydiaObject alloc] initWithDelegate:self.indirect] autorelease];
    } return self;
}

@end

@interface AppCacheController : CydiaWebViewController {
}

@end

@implementation AppCacheController

- (void) didReceiveMemoryWarning {
    // XXX: this doesn't work
}

- (bool) retainsNetworkActivityIndicator {
    return false;
}

@end
/* }}} */

/* Confirmation Controller {{{ */
bool DepSubstrate(const pkgCache::VerIterator &iterator) {
    if (!iterator.end())
        for (pkgCache::DepIterator dep(iterator.DependsList()); !dep.end(); ++dep) {
            if (dep->Type != pkgCache::Dep::Depends && dep->Type != pkgCache::Dep::PreDepends)
                continue;
            pkgCache::PkgIterator package(dep.TargetPkg());
            if (package.end())
                continue;
            if (strcmp(package.Name(), "mobilesubstrate") == 0)
                return true;
        }

    return false;
}

@protocol ConfirmationControllerDelegate
- (void) cancelAndClear:(bool)clear;
- (void) confirmWithNavigationController:(UINavigationController *)navigation;
- (void) queue;
@end

@interface ConfirmationController : CydiaWebViewController {
    _transient Database *database_;

    _H<UIAlertView> essential_;

    _H<NSDictionary> changes_;
    _H<NSMutableArray> issues_;
    _H<NSDictionary> sizes_;

    BOOL substrate_;
}

- (id) initWithDatabase:(Database *)database;

@end

@implementation ConfirmationController

- (void) complete {
    if (substrate_)
        RestartSubstrate_ = true;
    [self.delegate confirmWithNavigationController:[self navigationController]];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button {
    NSString *context([alert context]);

    if ([context isEqualToString:@"remove"]) {
        if (button == [alert cancelButtonIndex])
            [self _doContinue];
        else if (button == [alert firstOtherButtonIndex]) {
            [self performSelector:@selector(complete) withObject:nil afterDelay:0];
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else if ([context isEqualToString:@"unable"]) {
        [self dismissModalViewControllerAnimated:YES];
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else {
        [super alertView:alert clickedButtonAtIndex:button];
    }
}

- (void) _doContinue {
    [self.delegate cancelAndClear:NO];
    [self dismissModalViewControllerAnimated:YES];
}

- (id) invokeDefaultMethodWithArguments:(NSArray *)args {
    [self performSelectorOnMainThread:@selector(_doContinue) withObject:nil waitUntilDone:NO];
    return nil;
}

- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame {
    [super webView:view didClearWindowObject:window forFrame:frame];

    [window setValue:[[NSDictionary dictionaryWithObjectsAndKeys:
        (id) changes_, @"changes",
        (id) issues_, @"issues",
        (id) sizes_, @"sizes",
        self, @"queue",
    nil] Cydia$webScriptObjectInContext:window] forKey:@"cydiaConfirm"];
}

- (id) initWithDatabase:(Database *)database {
    if ((self = [super init]) != nil) {
        database_ = database;

        NSMutableArray *installs([NSMutableArray arrayWithCapacity:16]);
        NSMutableArray *reinstalls([NSMutableArray arrayWithCapacity:16]);
        NSMutableArray *upgrades([NSMutableArray arrayWithCapacity:16]);
        NSMutableArray *downgrades([NSMutableArray arrayWithCapacity:16]);
        NSMutableArray *removes([NSMutableArray arrayWithCapacity:16]);

        bool remove(false);

        pkgCacheFile &cache([database_ cache]);
        NSArray *packages([database_ packages]);
        pkgDepCache::Policy *policy([database_ policy]);

        issues_ = [NSMutableArray arrayWithCapacity:4];

        for (Package *package in packages) {
            pkgCache::PkgIterator iterator([package iterator]);
            NSString *name([package id]);

            if ([package broken]) {
                NSMutableArray *reasons([NSMutableArray arrayWithCapacity:4]);

                [issues_ addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    name, @"package",
                    reasons, @"reasons",
                nil]];

                pkgCache::VerIterator ver(cache[iterator].InstVerIter(cache));
                if (ver.end())
                    continue;

                for (pkgCache::DepIterator dep(ver.DependsList()); !dep.end(); ) {
                    pkgCache::DepIterator start;
                    pkgCache::DepIterator end;
                    dep.GlobOr(start, end); // ++dep

                    if (!cache->IsImportantDep(end))
                        continue;
                    if ((cache[end] & pkgDepCache::DepGInstall) != 0)
                        continue;

                    NSMutableArray *clauses([NSMutableArray arrayWithCapacity:4]);

                    [reasons addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                        [NSString stringWithUTF8String:start.DepType()], @"relationship",
                        clauses, @"clauses",
                    nil]];

                    _forever {
                        NSString *reason, *installed((NSString *) [WebUndefined undefined]);

                        pkgCache::PkgIterator target(start.TargetPkg());
                        if (target->ProvidesList != 0)
                            reason = @"missing";
                        else {
                            pkgCache::VerIterator ver(cache[target].InstVerIter(cache));
                            if (!ver.end()) {
                                reason = @"installed";
                                installed = [NSString stringWithUTF8String:ver.VerStr()];
                            } else if (!cache[target].CandidateVerIter(cache).end())
                                reason = @"uninstalled";
                            else if (target->ProvidesList == 0)
                                reason = @"uninstallable";
                            else
                                reason = @"virtual";
                        }

                        NSDictionary *version(start.TargetVer() == 0 ? (NSDictionary *) [NSNull null] : [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithUTF8String:start.CompType()], @"operator",
                            [NSString stringWithUTF8String:start.TargetVer()], @"value",
                        nil]);

                        [clauses addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSString stringWithUTF8String:start.TargetPkg().Name()], @"package",
                            version, @"version",
                            reason, @"reason",
                            installed, @"installed",
                        nil]];

                        // yes, seriously. (wtf?)
                        if (start == end)
                            break;
                        ++start;
                    }
                }
            }

            pkgDepCache::StateCache &state(cache[iterator]);

            static RegEx special_r("(firmware|gsc\\..*|cy\\+.*)");

            if (state.NewInstall())
                [installs addObject:name];
            // XXX: else if (state.Install())
            else if (!state.Delete() && (state.iFlags & pkgDepCache::ReInstall) == pkgDepCache::ReInstall)
                [reinstalls addObject:name];
            // XXX: move before previous if
            else if (state.Upgrade())
                [upgrades addObject:name];
            else if (state.Downgrade())
                [downgrades addObject:name];
            else if (!state.Delete())
                // XXX: _assert(state.Keep());
                continue;
            else if (special_r(name))
                [issues_ addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNull null], @"package",
                    [NSArray arrayWithObjects:
                        [NSDictionary dictionaryWithObjectsAndKeys:
                            @"Conflicts", @"relationship",
                            [NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:
                                    name, @"package",
                                    [NSNull null], @"version",
                                    @"installed", @"reason",
                                nil],
                            nil], @"clauses",
                        nil],
                    nil], @"reasons",
                nil]];
            else {
                if ([package essential])
                    remove = true;
                [removes addObject:name];
            }

            substrate_ |= DepSubstrate(policy->GetCandidateVer(iterator));
            substrate_ |= DepSubstrate(iterator.CurrentVer());
        }

        if (!remove)
            essential_ = nil;
        else if (Advanced_) {
            NSString *parenthetical(UCLocalize("PARENTHETICAL"));

            essential_ = [[[UIAlertView alloc]
                initWithTitle:UCLocalize("REMOVING_ESSENTIALS")
                message:UCLocalize("REMOVING_ESSENTIALS_EX")
                delegate:self
                cancelButtonTitle:[NSString stringWithFormat:parenthetical, UCLocalize("CANCEL_OPERATION"), UCLocalize("SAFE")]
                otherButtonTitles:
                    [NSString stringWithFormat:parenthetical, UCLocalize("FORCE_REMOVAL"), UCLocalize("UNSAFE")],
                nil
            ] autorelease];

            [essential_ setContext:@"remove"];
            [essential_ setNumberOfRows:2];
        } else {
            essential_ = [[[UIAlertView alloc]
                initWithTitle:UCLocalize("UNABLE_TO_COMPLY")
                message:UCLocalize("UNABLE_TO_COMPLY_EX")
                delegate:self
                cancelButtonTitle:UCLocalize("OKAY")
                otherButtonTitles:nil
            ] autorelease];

            [essential_ setContext:@"unable"];
        }

        changes_ = [NSDictionary dictionaryWithObjectsAndKeys:
            installs, @"installs",
            reinstalls, @"reinstalls",
            upgrades, @"upgrades",
            downgrades, @"downgrades",
            removes, @"removes",
        nil];

        sizes_ = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInteger:[database_ fetcher].FetchNeeded()], @"downloading",
            [NSNumber numberWithInteger:[database_ fetcher].PartialPresent()], @"resuming",
        nil];

        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/confirm/", UI_]]];
    } return self;
}

- (UIBarButtonItem *) leftButton {
    return [[[UIBarButtonItem alloc]
        initWithTitle:UCLocalize("CANCEL")
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(cancelButtonClicked)
    ] autorelease];
}

#if !AlwaysReload
- (void) applyRightButton {
    if ([issues_ count] == 0 && ![self isLoading])
        [[self navigationItem] setRightBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("CONFIRM")
            style:UIBarButtonItemStyleDone
            target:self
            action:@selector(confirmButtonClicked)
        ] autorelease]];
    else
        [[self navigationItem] setRightBarButtonItem:nil];
}
#endif

- (void) cancelButtonClicked {
    [self.delegate cancelAndClear:YES];
    [self dismissModalViewControllerAnimated:YES];
}

#if !AlwaysReload
- (void) confirmButtonClicked {
    if (essential_ != nil)
        [essential_ show];
    else
        [self complete];
}
#endif

@end
/* }}} */

/* Progress Data {{{ */
@interface CydiaProgressData : NSObject {
    _transient id delegate_;

    bool running_;
    float percent_;

    float current_;
    float total_;
    float speed_;

    _H<NSMutableArray> events_;
    _H<NSString> title_;

    _H<NSString> status_;
    _H<NSString> finish_;
}

@end

@implementation CydiaProgressData

+ (NSArray *) _attributeKeys {
    return [NSArray arrayWithObjects:
        @"current",
        @"events",
        @"finish",
        @"percent",
        @"running",
        @"speed",
        @"title",
        @"total",
    nil];
}

- (NSArray *) attributeKeys {
    return [[self class] _attributeKeys];
}

+ (BOOL) isKeyExcludedFromWebScript:(const char *)name {
    return ![[self _attributeKeys] containsObject:[NSString stringWithUTF8String:name]] && [super isKeyExcludedFromWebScript:name];
}

- (id) init {
    if ((self = [super init]) != nil) {
        events_ = [NSMutableArray arrayWithCapacity:32];
    } return self;
}

- (id) delegate {
    return delegate_;
}

- (void) setDelegate:(id)delegate {
    delegate_ = delegate;
}

- (void) setPercent:(float)value {
    percent_ = value;
}

- (NSNumber *) percent {
    return [NSNumber numberWithFloat:percent_];
}

- (void) setCurrent:(float)value {
    current_ = value;
}

- (NSNumber *) current {
    return [NSNumber numberWithFloat:current_];
}

- (void) setTotal:(float)value {
    total_ = value;
}

- (NSNumber *) total {
    return [NSNumber numberWithFloat:total_];
}

- (void) setSpeed:(float)value {
    speed_ = value;
}

- (NSNumber *) speed {
    return [NSNumber numberWithFloat:speed_];
}

- (NSArray *) events {
    return events_;
}

- (void) removeAllEvents {
    [events_ removeAllObjects];
}

- (void) addEvent:(CydiaProgressEvent *)event {
    [events_ addObject:event];
}

- (void) setTitle:(NSString *)text {
    title_ = text;
}

- (NSString *) title {
    return title_;
}

- (void) setFinish:(NSString *)text {
    finish_ = text;
}

- (NSString *) finish {
    return (id) finish_ ?: [NSNull null];
}

- (void) setRunning:(bool)running {
    running_ = running;
}

- (NSNumber *) running {
    return running_ ? (NSNumber *) kCFBooleanTrue : (NSNumber *) kCFBooleanFalse;
}

@end
/* }}} */
/* Progress Controller {{{ */
@interface ProgressController : CydiaWebViewController <
    ProgressDelegate
> {
    _transient Database *database_;
    _H<CydiaProgressData, 1> progress_;
    unsigned cancel_;
}

- (id) initWithDatabase:(Database *)database delegate:(id)delegate;

- (void) invoke:(NSInvocation *)invocation withTitle:(NSString *)title;

- (void) setTitle:(NSString *)title;
- (void) setCancellable:(bool)cancellable;

@end

@implementation ProgressController

- (void) dealloc {
    [database_ setProgressDelegate:nil];
    [super dealloc];
}

- (UIBarButtonItem *) leftButton {
    return cancel_ == 1 ? [[[UIBarButtonItem alloc]
        initWithTitle:UCLocalize("CANCEL")
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(cancel)
    ] autorelease] : nil;
}

- (void) updateCancel {
    [super applyLeftButton];
}

- (id) initWithDatabase:(Database *)database delegate:(id)delegate {
    if ((self = [super init]) != nil) {
        database_ = database;
        self.delegate = delegate;

        [database_ setProgressDelegate:self];

        progress_ = [[[CydiaProgressData alloc] init] autorelease];
        [progress_ setDelegate:self];

        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/progress/", UI_]]];

        [self setPageColor:[UIColor blackColor]];

        [[self navigationItem] setHidesBackButton:YES];

        [self updateCancel];
    } return self;
}

- (void) webView:(WebView *)view didClearWindowObject:(WebScriptObject *)window forFrame:(WebFrame *)frame {
    [super webView:view didClearWindowObject:window forFrame:frame];
    [window setValue:progress_ forKey:@"cydiaProgress"];
}

- (void) updateProgress {
    [self dispatchEvent:@"CydiaProgressUpdate"];
}

- (void) viewWillAppear:(BOOL)animated {
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlack];
    [super viewWillAppear:animated];
}

- (void) close {
    UpdateExternalStatus(0);

    if (Finish_ > 1)
        [self.delegate saveState];

    switch (Finish_) {
        case 0:
            [self.delegate returnToCydia];
        break;

        case 1:
            [self.delegate terminateWithSuccess];
            /*if ([self.delegate respondsToSelector:@selector(suspendWithAnimation:)])
                [self.delegate suspendWithAnimation:YES];
            else
                [self.delegate suspend];*/
        break;

        case 2:
            _trace();
            goto reload;

        case 3:
            _trace();
            goto reload;

        reload: {
            UIProgressHUD *hud([self.delegate addProgressHUD]);
            [hud setText:UCLocalize("LOADING")];
            [self.delegate performSelector:@selector(reloadSpringBoard) withObject:nil afterDelay:0.5];
            return;
        }

        case 4:
            _trace();
            if (void (*SBReboot)(mach_port_t) = reinterpret_cast<void (*)(mach_port_t)>(dlsym(RTLD_DEFAULT, "SBReboot")))
                SBReboot(SBSSpringBoardServerPort());
            else
                reboot2(RB_AUTOBOOT);
        break;
    }

    [super close];
}

- (void) setTitle:(NSString *)title {
    [progress_ setTitle:title];
    [self updateProgress];
}

- (UIBarButtonItem *) rightButton {
    return [[progress_ running] boolValue] ? [super rightButton] : [[[UIBarButtonItem alloc]
        initWithTitle:UCLocalize("CLOSE")
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(close)
    ] autorelease];
}

- (void) invoke:(NSInvocation *)invocation withTitle:(NSString *)title {
    UpdateExternalStatus(1);

    [progress_ setRunning:true];
    [self setTitle:title];
    // implicit updateProgress

    SHA1SumValue notifyconf; {
        FileFd file;
        if (!file.Open(NotifyConfig_, FileFd::ReadOnly))
            _error->Discard();
        else {
            MMap mmap(file, MMap::ReadOnly);
            SHA1Summation sha1;
            sha1.Add(reinterpret_cast<uint8_t *>(mmap.Data()), mmap.Size());
            notifyconf = sha1.Result();
        }
    }

    SHA1SumValue springlist; {
        FileFd file;
        if (!file.Open(SpringBoard_, FileFd::ReadOnly))
            _error->Discard();
        else {
            MMap mmap(file, MMap::ReadOnly);
            SHA1Summation sha1;
            sha1.Add(reinterpret_cast<uint8_t *>(mmap.Data()), mmap.Size());
            springlist = sha1.Result();
        }
    }

    if (invocation != nil) {
        [invocation yieldToSelector:@selector(invoke)];
        [self setTitle:@"COMPLETE"];
    }

    if (Finish_ < 4) {
        FileFd file;
        if (!file.Open(NotifyConfig_, FileFd::ReadOnly))
            _error->Discard();
        else {
            MMap mmap(file, MMap::ReadOnly);
            SHA1Summation sha1;
            sha1.Add(reinterpret_cast<uint8_t *>(mmap.Data()), mmap.Size());
            if (!(notifyconf == sha1.Result()))
                Finish_ = 4;
        }
    }

    if (Finish_ < 3) {
        FileFd file;
        if (!file.Open(SpringBoard_, FileFd::ReadOnly))
            _error->Discard();
        else {
            MMap mmap(file, MMap::ReadOnly);
            SHA1Summation sha1;
            sha1.Add(reinterpret_cast<uint8_t *>(mmap.Data()), mmap.Size());
            if (!(springlist == sha1.Result()))
                Finish_ = 3;
        }
    }

    if (Finish_ < 2) {
        if (RestartSubstrate_)
            Finish_ = 2;
    }

    RestartSubstrate_ = false;

    switch (Finish_) {
        case 0: [progress_ setFinish:UCLocalize("RETURN_TO_CYDIA")]; break; /* XXX: Maybe UCLocalize("DONE")? */
        case 1: [progress_ setFinish:UCLocalize("CLOSE_CYDIA")]; break;
        case 2: [progress_ setFinish:UCLocalize("RESTART_SPRINGBOARD")]; break;
        case 3: [progress_ setFinish:UCLocalize("RELOAD_SPRINGBOARD")]; break;
        case 4: [progress_ setFinish:UCLocalize("REBOOT_DEVICE")]; break;
    }

    UpdateExternalStatus(Finish_ == 0 ? 0 : 2);

    [progress_ setRunning:false];
    [self updateProgress];

    [self applyRightButton];
}

- (void) addProgressEvent:(CydiaProgressEvent *)event {
    [progress_ addEvent:event];
    [self updateProgress];
}

- (bool) isProgressCancelled {
    return cancel_ == 2;
}

- (void) cancel {
    cancel_ = 2;
    [self updateCancel];
}

- (void) setCancellable:(bool)cancellable {
    unsigned cancel(cancel_);

    if (!cancellable)
        cancel_ = 0;
    else if (cancel_ == 0)
        cancel_ = 1;

    if (cancel != cancel_)
        [self updateCancel];
}

- (void) setProgressCancellable:(NSNumber *)cancellable {
    [self setCancellable:[cancellable boolValue]];
}

- (void) setProgressPercent:(NSNumber *)percent {
    [progress_ setPercent:[percent floatValue]];
    [self updateProgress];
}

- (void) setProgressStatus:(NSDictionary *)status {
    if (status == nil) {
        [progress_ setCurrent:0];
        [progress_ setTotal:0];
        [progress_ setSpeed:0];
    } else {
        [progress_ setPercent:[[status objectForKey:@"Percent"] floatValue]];

        [progress_ setCurrent:[[status objectForKey:@"Current"] floatValue]];
        [progress_ setTotal:[[status objectForKey:@"Total"] floatValue]];
        [progress_ setSpeed:[[status objectForKey:@"Speed"] floatValue]];
    }

    [self updateProgress];
}

@end
/* }}} */

/* Package Cell {{{ */
@interface PackageCell : CyteTableViewCell <
    CyteTableViewCellDelegate
> {
    _H<UIImage> icon_;
    _H<NSString> name_;
    _H<NSString> description_;
    bool commercial_;
    _H<NSString> source_;
    _H<UIImage> badge_;
    _H<UIImage> placard_;
    bool summarized_;
}

- (PackageCell *) init;
- (void) setPackage:(Package *)package asSummary:(bool)summary;

- (void) drawContentRect:(CGRect)rect;

@end

@implementation PackageCell

- (PackageCell *) init {
    CGRect frame(CGRectMake(0, 0, 320, 74));
    if ((self = [super initWithFrame:frame reuseIdentifier:@"Package"]) != nil) {
        [self.content setOpaque:YES];
    } return self;
}

- (NSString *) accessibilityLabel {
    return name_;
}

- (void) setPackage:(Package *)package asSummary:(bool)summary {
    summarized_ = summary;

    icon_ = nil;
    name_ = nil;
    description_ = nil;
    source_ = nil;
    badge_ = nil;
    placard_ = nil;

    if (package == nil)
        [self.content setBackgroundColor:[UIColor whiteColor]];
    else {
        [package parse];

        Source *source = [package source];

        icon_ = [package icon];

        if (NSString *name = [package name])
            name_ = [NSString stringWithString:name];

        if (NSString *description = [package shortDescription])
            description_ = [NSString stringWithString:description];

        commercial_ = [package isCommercial];

        NSString *label = nil;
        bool trusted = false;

        if (source != nil) {
            label = [source label];
            trusted = [source trusted];
        } else if ([[package id] isEqualToString:@"firmware"])
            label = UCLocalize("APPLE");
        else
            label = [NSString stringWithFormat:UCLocalize("SLASH_DELIMITED"), UCLocalize("UNKNOWN"), UCLocalize("LOCAL")];

        NSString *from(label);

        NSString *section = [package simpleSection];
        if (section != nil && ![section isEqualToString:label]) {
            section = [[NSBundle mainBundle] localizedStringForKey:section value:nil table:@"Sections"];
            from = [NSString stringWithFormat:UCLocalize("PARENTHETICAL"), from, section];
        }

        source_ = [NSString stringWithFormat:UCLocalize("FROM"), from];

        if (NSString *purpose = [package primaryPurpose])
            badge_ = [UIImage imageAtPath:[NSString stringWithFormat:@"%@/Purposes/%@.png", App_, purpose]];

        UIColor *color;
        NSString *placard;

        if (NSString *mode = [package mode]) {
            if ([mode isEqualToString:@"REMOVE"] || [mode isEqualToString:@"PURGE"]) {
                color = RemovingColor_;
                placard = @"removing";
            } else {
                color = InstallingColor_;
                placard = @"installing";
            }
        } else {
            color = [UIColor whiteColor];

            if ([package installed] != nil)
                placard = @"installed";
            else
                placard = nil;
        }

        [self.content setBackgroundColor:color];

        if (placard != nil)
            placard_ = [UIImage imageAtPath:[NSString stringWithFormat:@"%@/%@.png", App_, placard]];
    }

    [self setNeedsDisplay];
    [self.content setNeedsDisplay];
}

- (void) drawSummaryContentRect:(CGRect)rect {
    bool highlighted(self.highlighted);
    float width([self bounds].size.width);

    if (icon_ != nil) {
        CGRect rect;
        rect.size = [(UIImage *) icon_ size];

        while (rect.size.width > 16 || rect.size.height > 16) {
            rect.size.width /= 2;
            rect.size.height /= 2;
        }

        rect.origin.x = 19 - rect.size.width / 2;
        rect.origin.y = 19 - rect.size.height / 2;

        [icon_ drawInRect:Retina(rect)];
    }

    if (badge_ != nil) {
        CGRect rect;
        rect.size = [(UIImage *) badge_ size];

        rect.size.width /= 4;
        rect.size.height /= 4;

        rect.origin.x = 25 - rect.size.width / 2;
        rect.origin.y = 25 - rect.size.height / 2;

        [badge_ drawInRect:Retina(rect)];
    }

    if (highlighted && kCFCoreFoundationVersionNumber < 800)
        UISetColor(White_);

    if (!highlighted)
        UISetColor(commercial_ ? Purple_ : Black_);
    [name_ drawAtPoint:CGPointMake(36, 8) forWidth:(width - (placard_ == nil ? 68 : 94)) withFont:Font18Bold_ lineBreakMode:NSLineBreakByTruncatingTail];

    if (placard_ != nil)
        [placard_ drawAtPoint:CGPointMake(width - 52, 11)];
}

- (void) drawNormalContentRect:(CGRect)rect {
    bool highlighted(self.highlighted);
    float width([self bounds].size.width);

    if (icon_ != nil) {
        CGRect rect;
        rect.size = [(UIImage *) icon_ size];

        while (rect.size.width > 32 || rect.size.height > 32) {
            rect.size.width /= 2;
            rect.size.height /= 2;
        }

        rect.origin.x = 25 - rect.size.width / 2;
        rect.origin.y = 25 - rect.size.height / 2;

        [icon_ drawInRect:Retina(rect)];
    }

    if (badge_ != nil) {
        CGRect rect;
        rect.size = [(UIImage *) badge_ size];

        rect.size.width /= 2;
        rect.size.height /= 2;

        rect.origin.x = 36 - rect.size.width / 2;
        rect.origin.y = 36 - rect.size.height / 2;

        [badge_ drawInRect:Retina(rect)];
    }

    if (highlighted && kCFCoreFoundationVersionNumber < 800)
        UISetColor(White_);

    if (!highlighted)
        UISetColor(commercial_ ? Purple_ : Black_);
    [name_ drawAtPoint:CGPointMake(48, 8) forWidth:(width - (placard_ == nil ? 80 : 106)) withFont:Font18Bold_ lineBreakMode:NSLineBreakByTruncatingTail];
    [source_ drawAtPoint:CGPointMake(58, 29) forWidth:(width - 95) withFont:Font12_ lineBreakMode:NSLineBreakByTruncatingTail];

    if (!highlighted)
        UISetColor(commercial_ ? Purplish_ : Gray_);
    [description_ drawAtPoint:CGPointMake(12, 46) forWidth:(width - 46) withFont:Font14_ lineBreakMode:NSLineBreakByTruncatingTail];

    if (placard_ != nil)
        [placard_ drawAtPoint:CGPointMake(width - 52, 9)];
}

- (void) drawContentRect:(CGRect)rect {
    if (summarized_)
        [self drawSummaryContentRect:rect];
    else
        [self drawNormalContentRect:rect];
}

@end
/* }}} */
/* Section Cell {{{ */
@interface SectionCell : CyteTableViewCell <
    CyteTableViewCellDelegate
> {
    _H<NSString> basic_;
    _H<NSString> section_;
    _H<NSString> name_;
    _H<NSString> count_;
    _H<UIImage> icon_;
    _H<UISwitch> switch_;
    BOOL editing_;
}

- (void) setSection:(Section *)section editing:(BOOL)editing;

@end

@implementation SectionCell

- (id) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) != nil) {
        icon_ = [UIImage imageNamed:@"folder.png"];
        // XXX: this initial frame is wrong, but is fixed later
        switch_ = [[[UISwitch alloc] initWithFrame:CGRectMake(218, 9, 60, 25)] autorelease];
        [switch_ addTarget:self action:@selector(onSwitch:) forEvents:UIControlEventValueChanged];

        [self.content setBackgroundColor:[UIColor whiteColor]];
    } return self;
}

- (void) onSwitch:(id)sender {
    NSMutableDictionary *metadata([Sections_ objectForKey:basic_]);
    if (metadata == nil) {
        metadata = [NSMutableDictionary dictionaryWithCapacity:2];
        [Sections_ setObject:metadata forKey:basic_];
    }

    [metadata setObject:[NSNumber numberWithBool:([switch_ isOn] == NO)] forKey:@"Hidden"];
}

- (void) setSection:(Section *)section editing:(BOOL)editing {
    if (editing != editing_) {
        if (editing_)
            [switch_ removeFromSuperview];
        else
            [self addSubview:switch_];
        editing_ = editing;
    }

    basic_ = nil;
    section_ = nil;
    name_ = nil;
    count_ = nil;

    if (section == nil) {
        name_ = UCLocalize("ALL_PACKAGES");
        count_ = nil;
    } else {
        basic_ = [section name];
        section_ = [section localized];

        name_  = section_ == nil || [section_ length] == 0 ? UCLocalize("NO_SECTION") : (NSString *) section_;
        count_ = [NSString stringWithFormat:@"%zd", [section count]];

        if (editing_)
            [switch_ setOn:(isSectionVisible(basic_) ? 1 : 0) animated:NO];
    }

    [self setAccessoryType:editing ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator];
    [self setSelectionStyle:editing ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue];

    [self.content setNeedsDisplay];
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];

    CGRect rect([switch_ frame]);
    [switch_ setFrame:CGRectMake(frame.size.width - rect.size.width - 9, 9, rect.size.width, rect.size.height)];
}

- (NSString *) accessibilityLabel {
    return name_;
}

- (void) drawContentRect:(CGRect)rect {
    bool highlighted(self.highlighted && !editing_);

    [icon_ drawInRect:CGRectMake(7, 7, 32, 32)];

    if (highlighted && kCFCoreFoundationVersionNumber < 800)
        UISetColor(White_);

    float width(rect.size.width);
    if (editing_)
        width -= 9 + [switch_ frame].size.width;

    if (!highlighted)
        UISetColor(Black_);
    [name_ drawAtPoint:CGPointMake(48, 12) forWidth:(width - 58) withFont:Font18_ lineBreakMode:NSLineBreakByTruncatingTail];

    CGSize size = [count_ sizeWithFont:Font14_];

    UISetColor(Folder_);
    if (count_ != nil)
        [count_ drawAtPoint:CGPointMake(Retina(10 + (30 - size.width) / 2), 18) withFont:Font12Bold_];
}

@end
/* }}} */

/* File Table {{{ */
@interface FileTable : CyteListController <
    UITableViewDataSource,
    UITableViewDelegate
> {
    _transient Database *database_;
    _H<Package> package_;
    _H<NSString> name_;
    _H<NSMutableArray> files_;
}

- (id) initWithDatabase:(Database *)database forPackage:(NSString *)name;

@end

@implementation FileTable

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return files_ == nil ? 0 : [files_ count];
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 24.0f;
}*/

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];
        [cell setFont:[UIFont systemFontOfSize:16]];
    }
    [cell setText:[files_ objectAtIndex:indexPath.row]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}

- (NSURL *) navigationURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@/files", [package_ id]]];
}

- (CGFloat) rowHeight {
    return 24;
}

- (void) releaseSubviews {
    package_ = nil;
    files_ = nil;

    [super releaseSubviews];
}

- (id) initWithDatabase:(Database *)database forPackage:(NSString *)name {
    if ((self = [super initWithTitle:UCLocalize("INSTALLED_FILES")]) != nil) {
        database_ = database;
        name_ = name;
    } return self;
}

- (bool) shouldYield {
    return false;
}

- (void) _reloadData {
    files_ = nil;

    package_ = [database_ packageWithName:name_];
    if (package_ != nil) {
        files_ = [NSMutableArray arrayWithCapacity:32];

        if (NSArray *files = [package_ files])
            [files_ addObjectsFromArray:files];

        if ([files_ count] != 0) {
            if ([[files_ objectAtIndex:0] isEqualToString:@"/."])
                [files_ removeObjectAtIndex:0];
            [files_ sortUsingSelector:@selector(compareByPath:)];

            NSMutableArray *stack = [NSMutableArray arrayWithCapacity:8];
            [stack addObject:@"/"];

            for (int i(0), e([files_ count]); i != e; ++i) {
                NSString *file = [files_ objectAtIndex:i];
                while (![file hasPrefix:[stack lastObject]])
                    [stack removeLastObject];
                NSString *directory = [stack lastObject];
                [stack addObject:[file stringByAppendingString:@"/"]];
                [files_ replaceObjectAtIndex:i withObject:[NSString stringWithFormat:@"%*s%@",
                    int(([stack count] - 2) * 3), "",
                    [file substringFromIndex:[directory length]]
                ]];
            }
        }
    }

    [super _reloadData];
}

@end
/* }}} */
/* Package Controller {{{ */
@interface CYPackageController : CydiaWebViewController <
    UIActionSheetDelegate
> {
    _transient Database *database_;
    _H<Package> package_;
    _H<NSString> name_;
    bool commercial_;
    std::vector<std::pair<_H<NSString>, _H<NSString>>> buttons_;
    _H<UIActionSheet> sheet_;
    _H<UIBarButtonItem> button_;
    _H<NSArray> versions_;
}

- (id) initWithDatabase:(Database *)database forPackage:(NSString *)name withReferrer:(NSString *)referrer;

@end

@implementation CYPackageController

- (NSURL *) navigationURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@", (id) name_]];
}

- (void) _clickButtonWithPackage:(Package *)package {
    [self.delegate installPackage:package];
}

- (void) _clickButtonWithName:(NSString *)name {
    if ([name isEqualToString:@"CLEAR"])
        return [self.delegate clearPackage:package_];
    else if ([name isEqualToString:@"REMOVE"])
        return [self.delegate removePackage:package_];
    else if ([name isEqualToString:@"DOWNGRADE"]) {
        sheet_ = [[[UIActionSheet alloc]
            initWithTitle:nil
            delegate:self
            cancelButtonTitle:nil
            destructiveButtonTitle:nil
            otherButtonTitles:nil
        ] autorelease];

        for (Package *version in (id) versions_)
            [sheet_ addButtonWithTitle:[version latest]];
        [sheet_ setContext:@"version"];

        [self.delegate showActionSheet:sheet_ fromItem:[[self navigationItem] rightBarButtonItem]];
        return;
    }

    else if ([name isEqualToString:@"INSTALL"]);
    else if ([name isEqualToString:@"REINSTALL"]);
    else if ([name isEqualToString:@"UPGRADE"]);
    else _assert(false);

    [self.delegate installPackage:package_];
}

- (void) actionSheet:(UIActionSheet *)sheet clickedButtonAtIndex:(NSInteger)button {
    NSString *context([sheet context]);
    if (sheet_ == sheet)
        sheet_ = nil;

    if ([context isEqualToString:@"modify"]) {
        if (button != [sheet cancelButtonIndex]) {
            if (IsWildcat_)
                [self performSelector:@selector(_clickButtonWithName:) withObject:buttons_[button].first afterDelay:0];
            else
                [self _clickButtonWithName:buttons_[button].first];
        }

        [sheet dismissWithClickedButtonIndex:button animated:YES];
    } else if ([context isEqualToString:@"version"]) {
        if (button != [sheet cancelButtonIndex]) {
            Package *version([versions_ objectAtIndex:button]);
            if (IsWildcat_)
                [self performSelector:@selector(_clickButtonWithPackage:) withObject:version afterDelay:0];
            else
                [self _clickButtonWithPackage:version];
        }

        [sheet dismissWithClickedButtonIndex:button animated:YES];
    }
}

- (bool) _allowJavaScriptPanel {
    return commercial_;
}

#if !AlwaysReload
- (void) _customButtonClicked {
    if (commercial_ && self.isLoading && [package_ uninstalled])
        return [self reloadURLWithCache:NO];

    size_t count(buttons_.size());
    if (count == 0)
        return;

    if (count == 1)
        [self _clickButtonWithName:buttons_[0].first];
    else {
        NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:count];
        for (const auto &button : buttons_)
            [buttons addObject:button.second];

        sheet_ = [[[UIActionSheet alloc]
            initWithTitle:nil
            delegate:self
            cancelButtonTitle:nil
            destructiveButtonTitle:nil
            otherButtonTitles:nil
        ] autorelease];

        for (NSString *button in buttons)
            [sheet_ addButtonWithTitle:button];
        [sheet_ setContext:@"modify"];

        [self.delegate showActionSheet:sheet_ fromItem:[[self navigationItem] rightBarButtonItem]];
    }
}

- (void) applyLoadingTitle {
    // Don't show "Loading" as the title. Ever.
}

- (UIBarButtonItem *) rightButton {
    return button_;
}
#endif

- (void) setPageColor:(UIColor *)color {
    return [super setPageColor:nil];
}

- (id) initWithDatabase:(Database *)database forPackage:(NSString *)name withReferrer:(NSString *)referrer {
    if ((self = [super init]) != nil) {
        database_ = database;
        name_ = name == nil ? @"" : [NSString stringWithString:name];
        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/package/%@", UI_, (id) name_]] withReferrer:referrer];
    } return self;
}

- (void) reloadData {
    [super reloadData];

    [sheet_ dismissWithClickedButtonIndex:[sheet_ cancelButtonIndex] animated:YES];
    sheet_ = nil;

    package_ = [database_ packageWithName:name_];
    versions_ = [package_ downgrades];

    buttons_.clear();

    if (package_ != nil) {
        [(Package *) package_ parse];

        commercial_ = [package_ isCommercial];

        if ([package_ mode] != nil)
            buttons_.push_back(std::make_pair(@"CLEAR", UCLocalize("CLEAR")));
        if ([package_ source] == nil);
        else if ([package_ upgradableAndEssential:NO])
            buttons_.push_back(std::make_pair(@"UPGRADE", UCLocalize("UPGRADE")));
        else if ([package_ uninstalled])
            buttons_.push_back(std::make_pair(@"INSTALL", UCLocalize("INSTALL")));
        else
            buttons_.push_back(std::make_pair(@"REINSTALL", UCLocalize("REINSTALL")));
        if (![package_ uninstalled])
            buttons_.push_back(std::make_pair(@"REMOVE", UCLocalize("REMOVE")));
        if ([versions_ count] != 0)
            buttons_.push_back(std::make_pair(@"DOWNGRADE", UCLocalize("DOWNGRADE")));
    }

    NSString *title;
    switch (buttons_.size()) {
        case 0: title = nil; break;
        case 1: title = buttons_[0].second; break;
        default: title = UCLocalize("MODIFY"); break;
    }

    button_ = [[[UIBarButtonItem alloc]
        initWithTitle:title
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(customButtonClicked)
    ] autorelease];
}

- (bool) isLoading {
    return commercial_ ? [super isLoading] : false;
}

@end
/* }}} */

/* Package List Controller {{{ */
@interface PackageListController : CyteListController <
    UITableViewDataSource,
    UITableViewDelegate
> {
    _transient Database *database_;
    unsigned era_;
    _H<NSArray> packages_;
    _H<NSArray> sections_;

    _H<NSArray> thumbs_;
    std::vector<NSInteger> offset_;

    unsigned reloading_;
}

- (id) initWithDatabase:(Database *)database title:(NSString *)title;

- (NSArray *) sectionsForPackages:(NSMutableArray *)packages;

@end

@implementation PackageListController

- (NSURL *) referrerURL {
    return [self navigationURL];
}

- (bool) isSummarized {
    return false;
}

- (bool) showsSections {
    return true;
}

- (void) didSelectPackage:(Package *)package {
    CYPackageController *view([[[CYPackageController alloc] initWithDatabase:database_ forPackage:[package id] withReferrer:[[self referrerURL] absoluteString]] autorelease]);
    [view setDelegate:self.delegate];
    [[self navigationController] pushViewController:view animated:YES];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)list {
    NSInteger count([sections_ count]);
    return count == 0 ? 1 : count;
}

- (NSString *) tableView:(UITableView *)list titleForHeaderInSection:(NSInteger)section {
    if ([sections_ count] == 0 || [[sections_ objectAtIndex:section] count] == 0)
        return nil;
    return [[sections_ objectAtIndex:section] name];
}

- (NSInteger) tableView:(UITableView *)list numberOfRowsInSection:(NSInteger)section {
    if ([sections_ count] == 0)
        return 0;
    return [[sections_ objectAtIndex:section] count];
}

- (Package *) packageAtIndexPath:(NSIndexPath *)path {
@synchronized (database_) {
    if ([database_ era] != era_)
        return nil;

    Section *section([sections_ objectAtIndex:[path section]]);
    NSInteger row([path row]);
    Package *package([packages_ objectAtIndex:([section row] + row)]);
    return [[package retain] autorelease];
} }

- (UITableViewCell *) tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)path {
    PackageCell *cell((PackageCell *) [table dequeueReusableCellWithIdentifier:@"Package"]);
    if (cell == nil)
        cell = [[[PackageCell alloc] init] autorelease];

    Package *package([database_ packageWithName:[[self packageAtIndexPath:path] id]]);
    [cell setPackage:package asSummary:[self isSummarized]];
    return cell;
}

- (void) tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)path {
    Package *package([self packageAtIndexPath:path]);
    package = [database_ packageWithName:[package id]];
    [self didSelectPackage:package];
}

- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView {
    return thumbs_;
}

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return offset_[index];
}

- (CGFloat) rowHeight {
    return [self isSummarized] ? 38 : 73;
}

- (id) initWithDatabase:(Database *)database title:(NSString *)title {
    if ((self = [super initWithTitle:title]) != nil) {
        database_ = database;
    } return self;
}

- (void) releaseSubviews {
    packages_ = nil;
    sections_ = nil;

    thumbs_ = nil;
    offset_.clear();

    [super releaseSubviews];
}

- (bool) shouldBlock {
    return false;
}

- (NSMutableArray *) _reloadPackages {
@synchronized (database_) {
    era_ = [database_ era];
    NSArray *packages([database_ packages]);

    return [NSMutableArray arrayWithArray:packages];
} }

- (void) _reloadData {
    if (reloading_ != 0) {
        reloading_ = 2;
        return;
    }

    NSMutableArray *packages;

  reload:
    if ([self shouldYield]) {
        do {
            UIProgressHUD *hud;

            if (![self shouldBlock])
                hud = nil;
            else {
                hud = [self.delegate addProgressHUD];
                [hud setText:UCLocalize("LOADING")];
            }

            reloading_ = 1;
            packages = [self yieldToSelector:@selector(_reloadPackages)];

            if (hud != nil)
                [self.delegate removeProgressHUD:hud];
        } while (reloading_ == 2);
    } else {
        packages = [self _reloadPackages];
    }

@synchronized (database_) {
    if (era_ != [database_ era])
        goto reload;
    reloading_ = 0;

    thumbs_ = nil;
    offset_.clear();

    packages_ = packages;

    if ([self showsSections])
        sections_ = [self sectionsForPackages:packages];
    else {
        Section *section([[[Section alloc] initWithName:nil row:0 localize:NO] autorelease]);
        [section setCount:[packages_ count]];
        sections_ = [NSArray arrayWithObject:section];
    }

    [super _reloadData];
}

    PrintTimes();
}

- (NSArray *) sectionsForPackages:(NSMutableArray *)packages {
    Section *prefix([[[Section alloc] initWithName:nil row:0 localize:NO] autorelease]);
    size_t end([packages count]);

    NSMutableArray *sections([NSMutableArray arrayWithCapacity:16]);
    Section *section(prefix);

    thumbs_ = CollationThumbs_;
    offset_ = CollationOffset_;

    size_t offset(0);
    size_t offsets([CollationStarts_ count]);

    NSString *start([CollationStarts_ objectAtIndex:offset]);
    size_t length([start length]);

    for (size_t index(0); index != end; ++index) {
        if (start != nil) {
            Package *package([packages objectAtIndex:index]);
            NSString *name(PackageName(package, @selector(cyname)));

            //while ([start compare:name options:NSNumericSearch range:NSMakeRange(0, length) locale:CollationLocale_] != NSOrderedDescending) {
            while (StringNameCompare(start, name, length) != kCFCompareGreaterThan) {
                NSString *title([CollationTitles_ objectAtIndex:offset]);
                section = [[[Section alloc] initWithName:title row:index localize:NO] autorelease];
                [sections addObject:section];

                start = ++offset == offsets ? nil : [CollationStarts_ objectAtIndex:offset];
                if (start == nil)
                    break;
                length = [start length];
            }
        }

        [section addToCount];
    }

    for (; offset != offsets; ++offset) {
        NSString *title([CollationTitles_ objectAtIndex:offset]);
        Section *section([[[Section alloc] initWithName:title row:end localize:NO] autorelease]);
        [sections addObject:section];
    }

    if ([prefix count] != 0) {
        Section *suffix([sections lastObject]);
        [prefix setName:[suffix name]];
        [suffix setName:nil];
        [sections insertObject:prefix atIndex:(offsets - 1)];
    }

    return sections;
}

@end
/* }}} */
/* Filtered Package List Controller {{{ */
typedef Function<bool, Package *> PackageFilter;
typedef Function<void, NSMutableArray *> PackageSorter;
@interface FilteredPackageListController : PackageListController {
    PackageFilter filter_;
    PackageSorter sorter_;
}

- (id) initWithDatabase:(Database *)database title:(NSString *)title filter:(PackageFilter)filter;

- (void) setFilter:(PackageFilter)filter;
- (void) setSorter:(PackageSorter)sorter;

@end

@implementation FilteredPackageListController

- (void) setFilter:(PackageFilter)filter {
@synchronized (self) {
    filter_ = filter;
} }

- (void) setSorter:(PackageSorter)sorter {
@synchronized (self) {
    sorter_ = sorter;
} }

- (NSMutableArray *) _reloadPackages {
@synchronized (database_) {
    era_ = [database_ era];

    NSArray *packages([database_ packages]);
    NSMutableArray *filtered([NSMutableArray arrayWithCapacity:[packages count]]);

    PackageFilter filter;
    PackageSorter sorter;

    @synchronized (self) {
        filter = filter_;
        sorter = sorter_;
    }

    _profile(PackageTable$reloadData$Filter)
        for (Package *package in packages)
            if (filter(package))
                [filtered addObject:package];
    _end

    if (sorter)
        sorter(filtered);
    return filtered;
} }

- (id) initWithDatabase:(Database *)database title:(NSString *)title filter:(PackageFilter)filter {
    if ((self = [super initWithDatabase:database title:title]) != nil) {
        [self setFilter:filter];
    } return self;
}

@end
/* }}} */

/* Home Controller {{{ */
@interface HomeController : CydiaWebViewController {
    CFRunLoopRef runloop_;
    SCNetworkReachabilityRef reachability_;
}

@end

@implementation HomeController

static void HomeControllerReachabilityCallback(SCNetworkReachabilityRef reachability, SCNetworkReachabilityFlags flags, void *info) {
    [(HomeController *) info dispatchEvent:@"CydiaReachabilityCallback"];
}

- (id) init {
    if ((self = [super init]) != nil) {
        [self setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/home/", UI_]]];
        [self reloadData];

        reachability_ = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, "cydia.saurik.com");
        if (reachability_ != NULL) {
            SCNetworkReachabilityContext context = {0, self, NULL, NULL, NULL};
            SCNetworkReachabilitySetCallback(reachability_, HomeControllerReachabilityCallback, &context);

            CFRunLoopRef runloop(CFRunLoopGetCurrent());
            if (SCNetworkReachabilityScheduleWithRunLoop(reachability_, runloop, kCFRunLoopDefaultMode))
                runloop_ = runloop;
        }
    } return self;
}

- (void) dealloc {
    if (reachability_ != NULL && runloop_ != NULL)
        SCNetworkReachabilityUnscheduleFromRunLoop(reachability_, runloop_, kCFRunLoopDefaultMode);
    [super dealloc];
}

- (NSURL *) navigationURL {
    return [NSURL URLWithString:@"cydia://home"];
}

- (void) aboutButtonClicked {
    UIAlertView *alert([[[UIAlertView alloc] init] autorelease]);

    [alert setTitle:UCLocalize("ABOUT_CYDIA")];
    [alert addButtonWithTitle:UCLocalize("CLOSE")];
    [alert setCancelButtonIndex:0];

    [alert setMessage:
        @"Copyright \u00a9 2008-2015\n"
        "SaurikIT, LLC\n"
        "\n"
        "Jay Freeman (saurik)\n"
        "saurik@saurik.com\n"
        "http://www.saurik.com/"
    ];

    [alert show];
}

- (UIBarButtonItem *) leftButton {
    return [[[UIBarButtonItem alloc]
        initWithTitle:UCLocalize("ABOUT")
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(aboutButtonClicked)
    ] autorelease];
}

@end
/* }}} */

/* Cydia Tab Bar Controller {{{ */
@interface CydiaTabBarController : CyteTabBarController <
    UITabBarControllerDelegate,
    FetchDelegate
> {
    _transient Database *database_;

    _H<UIActivityIndicatorView> indicator_;

    bool updating_;
    // XXX: ok, "updatedelegate_"?...
    _transient NSObject<CydiaDelegate> *updatedelegate_;
}

- (void) beginUpdate;
- (BOOL) updating;

@end

@implementation CydiaTabBarController

- (id) initWithDatabase:(Database *)database {
    if ((self = [super init]) != nil) {
        database_ = database;
        [self setDelegate:self];

        indicator_ = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteTiny] autorelease];
        [indicator_ setOrigin:CGPointMake(kCFCoreFoundationVersionNumber >= 800 ? 2 : 4, 2)];

        [[self view] setAutoresizingMask:UIViewAutoresizingFlexibleBoth];
    } return self;
}

- (void) beginUpdate {
    if (updating_)
        return;

    UIViewController *controller([[self viewControllers] objectAtIndex:1]);
    UITabBarItem *item([controller tabBarItem]);

    [item setBadgeValue:@""];
    UIView *badge(MSHookIvar<UIView *>([item view], "_badge"));

    [indicator_ startAnimating];
    [badge addSubview:indicator_];

    [updatedelegate_ retainNetworkActivityIndicator];
    updating_ = true;

    [NSThread
        detachNewThreadSelector:@selector(performUpdate)
        toTarget:self
        withObject:nil
    ];
}

- (void) performUpdate {
    NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

    SourceStatus status(self, database_);
    [database_ updateWithStatus:status];

    [self
        performSelectorOnMainThread:@selector(completeUpdate)
        withObject:nil
        waitUntilDone:NO
    ];

    [pool release];
}

- (void) stopUpdateWithSelector:(SEL)selector {
    updating_ = false;
    [updatedelegate_ releaseNetworkActivityIndicator];

    UIViewController *controller([[self viewControllers] objectAtIndex:1]);
    [[controller tabBarItem] setBadgeValue:nil];

    [indicator_ removeFromSuperview];
    [indicator_ stopAnimating];

    [updatedelegate_ performSelector:selector withObject:nil afterDelay:0];
}

- (void) completeUpdate {
    if (!updating_)
        return;
    [self stopUpdateWithSelector:@selector(reloadData)];
}

- (void) cancelUpdate {
    [self stopUpdateWithSelector:@selector(updateDataAndLoad)];
}

- (void) cancelPressed {
    [self cancelUpdate];
}

- (BOOL) updating {
    return updating_;
}

- (bool) isSourceCancelled {
    return !updating_;
}

- (void) startSourceFetch:(NSString *)uri {
}

- (void) stopSourceFetch:(NSString *)uri {
}

- (void) setUpdateDelegate:(id)delegate {
    updatedelegate_ = delegate;
}

@end
/* }}} */

/* Cydia:// Protocol {{{ */
@interface CydiaURLProtocol : CyteURLProtocol {
}

@end

@implementation CydiaURLProtocol

+ (NSString *) scheme {
    return @"cydia";
}

- (bool) loadForPath:(NSString *)path ofRequest:(NSURLRequest *)request {
    NSRange slash([path rangeOfString:@"/"]);

    NSString *command;
    if (slash.location == NSNotFound) {
        command = path;
        path = nil;
    } else {
        command = [path substringToIndex:slash.location];
        path = [path substringFromIndex:(slash.location + 1)];
    }

    Database *database([Database sharedInstance]);

    if (false);
    else if ([command isEqualToString:@"application-icon"]) {
        if (path == nil)
            goto fail;
        path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        UIImage *icon(nil);

        if (icon == nil && $SBSCopyIconImagePNGDataForDisplayIdentifier != NULL) {
            NSData *data([$SBSCopyIconImagePNGDataForDisplayIdentifier(path) autorelease]);
            icon = [UIImage imageWithData:data];
        }

        if (icon == nil)
            if (NSString *file = SBSCopyIconImagePathForDisplayIdentifier(path))
                icon = [UIImage imageAtPath:file];

        if (icon == nil)
            icon = [UIImage imageNamed:@"unknown.png"];

        [self _returnPNGWithImage:icon forRequest:request];
    } else if ([command isEqualToString:@"package-icon"]) {
        if (path == nil)
            goto fail;
        path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        Package *package([database packageWithName:path]);
        if (package == nil)
            goto fail;
        [package parse];
        UIImage *icon([package icon]);
        [self _returnPNGWithImage:icon forRequest:request];
    } else if ([command isEqualToString:@"uikit-image"]) {
        if (path == nil)
            goto fail;
        path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        UIImage *icon(_UIImageWithName(path));
        [self _returnPNGWithImage:icon forRequest:request];
    } else if ([command isEqualToString:@"section-icon"]) {
        if (path == nil)
            goto fail;
        path = [path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        UIImage *icon([UIImage imageAtPath:[NSString stringWithFormat:@"%@/Sections/%@.png", App_, [path stringByReplacingOccurrencesOfString:@" " withString:@"_"]]]);
        if (icon == nil)
            icon = [UIImage imageNamed:@"unknown.png"];
        [self _returnPNGWithImage:icon forRequest:request];
    } else fail: {
        return [super loadForPath:path ofRequest:request];
    }

    return true;
}

@end
/* }}} */

/* Section Controller {{{ */
@interface SectionController : FilteredPackageListController {
    _H<NSString> key_;
    _H<NSString> section_;
}

- (id) initWithDatabase:(Database *)database source:(Source *)source section:(NSString *)section;

@end

@implementation SectionController

- (NSURL *) referrerURL {
    NSString *name(section_);
    name = name ?: @"*";
    NSString *key(key_);
    key = key ?: @"*";
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/sections/%@/%@", UI_, [key stringByAddingPercentEscapesIncludingReserved], [name stringByAddingPercentEscapesIncludingReserved]]];
}

- (NSURL *) navigationURL {
    NSString *name(section_);
    name = name ?: @"*";
    NSString *key(key_);
    key = key ?: @"*";
    return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://sections/%@/%@", [key stringByAddingPercentEscapesIncludingReserved], [name stringByAddingPercentEscapesIncludingReserved]]];
}

- (id) initWithDatabase:(Database *)database source:(Source *)source section:(NSString *)section {
    NSString *title;
    if (section == nil)
        title = UCLocalize("ALL_PACKAGES");
    else if (![section isEqual:@""])
        title = [[NSBundle mainBundle] localizedStringForKey:Simplify(section) value:nil table:@"Sections"];
    else
        title = UCLocalize("NO_SECTION");

    if ((self = [super initWithDatabase:database title:title]) != nil) {
        key_ = [source key];
        section_ = section;
    } return self;
}

- (void) reloadData {
    Source *source([database_ sourceWithKey:key_]);
    _H<NSString> name(section_);

    [self setFilter:[=](Package *package) {
        NSString *section([package section]);

        return (
            name == nil ||
            section == nil && [name length] == 0 ||
            [name isEqualToString:section]
        ) && (
            source == nil ||
            [package source] == source
        ) && [package visible];
    }];

    [super reloadData];
}

@end
/* }}} */
/* Sections Controller {{{ */
@interface SectionsController : CyteViewController <
    UITableViewDataSource,
    UITableViewDelegate
> {
    _transient Database *database_;
    _H<NSString> key_;
    _H<NSMutableArray> sections_;
    _H<NSMutableArray> filtered_;
    _H<UITableView, 2> list_;
}

- (id) initWithDatabase:(Database *)database source:(Source *)source;
- (void) editButtonClicked;

@end

@implementation SectionsController

- (NSURL *) navigationURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://sources/%@", [key_ stringByAddingPercentEscapesIncludingReserved]]];
}

- (Source *) source {
    if (key_ == nil)
        return nil;
    return [database_ sourceWithKey:key_];
}

- (void) updateNavigationItem {
    [[self navigationItem] setTitle:[self isEditing] ? UCLocalize("SECTION_VISIBILITY") : UCLocalize("SECTIONS")];
    if ([sections_ count] == 0) {
        [[self navigationItem] setRightBarButtonItem:nil];
    } else {
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc]
            initWithBarButtonSystemItem:([self isEditing] ? UIBarButtonSystemItemDone : UIBarButtonSystemItemEdit)
            target:self
            action:@selector(editButtonClicked)
        ] animated:([[self navigationItem] rightBarButtonItem] != nil)];
    }
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];

    if (editing)
        [list_ reloadData];
    else
        [self.delegate updateData];

    [self updateNavigationItem];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [list_ deselectRowAtIndexPath:[list_ indexPathForSelectedRow] animated:animated];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setEditing:NO];
}

- (Section *) sectionAtIndexPath:(NSIndexPath *)indexPath {
    Section *section = nil;
    int index = [indexPath row];
    if (![self isEditing]) {
        index -= 1;
        if (index >= 0)
            section = [filtered_ objectAtIndex:index];
    } else {
        section = [sections_ objectAtIndex:index];
    }
    return section;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isEditing])
        return [sections_ count];
    else
        return [filtered_ count] + 1;
}

/*- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}*/

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"SectionCell";

    SectionCell *cell = (SectionCell *)[tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
        cell = [[[SectionCell alloc] initWithFrame:CGRectZero reuseIdentifier:reuseIdentifier] autorelease];

    [cell setSection:[self sectionAtIndexPath:indexPath] editing:[self isEditing]];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isEditing])
        return;

    Section *section = [self sectionAtIndexPath:indexPath];

    SectionController *controller = [[[SectionController alloc]
        initWithDatabase:database_
        source:[self source]
        section:[section name]
    ] autorelease];
    [controller setDelegate:self.delegate];

    [[self navigationController] pushViewController:controller animated:YES];
}

- (void) loadView {
    list_ = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
    [list_ setAutoresizingMask:UIViewAutoresizingFlexibleBoth];
    [list_ setRowHeight:46];
    [(UITableView *) list_ setDataSource:self];
    [list_ setDelegate:self];
    [self setView:list_];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    [[self navigationItem] setTitle:UCLocalize("SECTIONS")];
}

- (void) releaseSubviews {
    list_ = nil;

    sections_ = nil;
    filtered_ = nil;

    [super releaseSubviews];
}

- (id) initWithDatabase:(Database *)database source:(Source *)source {
    if ((self = [super init]) != nil) {
        database_ = database;
        key_ = [source key];
    } return self;
}

- (void) reloadData {
    [super reloadData];

    NSArray *packages = [database_ packages];

    sections_ = [NSMutableArray arrayWithCapacity:16];
    filtered_ = [NSMutableArray arrayWithCapacity:16];

    NSMutableDictionary *sections([NSMutableDictionary dictionaryWithCapacity:32]);

    Source *source([self source]);

    _trace();
    for (Package *package in packages) {
        if (source != nil && [package source] != source)
            continue;

        NSString *name([package section]);
        NSString *key(name == nil ? @"" : name);

        Section *section;

        _profile(SectionsView$reloadData$Section)
            section = [sections objectForKey:key];
            if (section == nil) {
                _profile(SectionsView$reloadData$Section$Allocate)
                    section = [[[Section alloc] initWithName:key localize:YES] autorelease];
                    [sections setObject:section forKey:key];
                _end
            }
        _end

        [section addToCount];

        _profile(SectionsView$reloadData$Filter)
            if (![package visible])
                continue;
        _end

        [section addToRow];
    }
    _trace();

    [sections_ addObjectsFromArray:[sections allValues]];

    [sections_ sortUsingSelector:@selector(compareByLocalized:)];

    for (Section *section in (id) sections_) {
        size_t count([section row]);
        if (count == 0)
            continue;

        section = [[[Section alloc] initWithName:[section name] localized:[section localized]] autorelease];
        [section setCount:count];
        [filtered_ addObject:section];
    }

    [self updateNavigationItem];
    [list_ reloadData];
    _trace();
}

- (void) editButtonClicked {
    [self setEditing:![self isEditing] animated:YES];
}

@end
/* }}} */

/* Changes Controller {{{ */
@interface ChangesController : FilteredPackageListController {
    unsigned upgrades_;
}

- (id) initWithDatabase:(Database *)database;

@end

@implementation ChangesController

- (NSURL *) referrerURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/changes/", UI_]];
}

- (NSURL *) navigationURL {
    return [NSURL URLWithString:@"cydia://changes"];
}

- (Package *) packageAtIndexPath:(NSIndexPath *)path {
@synchronized (database_) {
    if ([database_ era] != era_)
        return nil;

    NSUInteger sectionIndex([path section]);
    if (sectionIndex >= [sections_ count])
        return nil;
    Section *section([sections_ objectAtIndex:sectionIndex]);
    NSInteger row([path row]);
    return [[[packages_ objectAtIndex:([section row] + row)] retain] autorelease];
} }

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button {
    NSString *context([alert context]);

    if ([context isEqualToString:@"norefresh"])
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void) setLeftBarButtonItem {
    if ([self.delegate updating])
        [[self navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("CANCEL")
            style:UIBarButtonItemStyleDone
            target:self
            action:@selector(cancelButtonClicked)
        ] autorelease] animated:YES];
    else
        [[self navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("REFRESH")
            style:UIBarButtonItemStylePlain
            target:self
            action:@selector(refreshButtonClicked)
        ] autorelease] animated:YES];
}

- (void) refreshButtonClicked {
    if ([self.delegate requestUpdate])
        [self setLeftBarButtonItem];
}

- (void) cancelButtonClicked {
    [self.delegate cancelUpdate];
}

- (void) upgradeButtonClicked {
    [self.delegate distUpgrade];
    [[self navigationItem] setRightBarButtonItem:nil animated:YES];
}

- (bool) shouldYield {
    return true;
}

- (bool) shouldBlock {
    return true;
}

- (void) useFilter {
@synchronized (self) {
    [self setFilter:[](Package *package) {
        return [package upgradableAndEssential:YES] || [package visible];
    }];

    [self setSorter:[](NSMutableArray *packages) {
        [packages radixSortUsingFunction:reinterpret_cast<MenesRadixSortFunction>(&PackageChangesRadix) withContext:NULL];
    }];
} }

- (id) initWithDatabase:(Database *)database {
    if ((self = [super initWithDatabase:database title:UCLocalize("CHANGES")]) != nil) {
        [self useFilter];
    } return self;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setLeftBarButtonItem];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setLeftBarButtonItem];
}

- (void) reloadData {
    [self setLeftBarButtonItem];
    [super reloadData];
}

- (NSArray *) sectionsForPackages:(NSMutableArray *)packages {
    NSMutableArray *sections([NSMutableArray arrayWithCapacity:16]);

    Section *upgradable = [[[Section alloc] initWithName:UCLocalize("AVAILABLE_UPGRADES") localize:NO] autorelease];
    Section *ignored = nil;
    Section *section = nil;
    time_t last = 0;

    upgrades_ = 0;
    bool unseens = false;

    CFDateFormatterRef formatter(CFDateFormatterCreate(NULL, Locale_, kCFDateFormatterMediumStyle, kCFDateFormatterMediumStyle));

    for (size_t offset = 0, count = [packages count]; offset != count; ++offset) {
        Package *package = [packages objectAtIndex:offset];

        BOOL uae = [package upgradableAndEssential:YES];

        if (!uae) {
            unseens = true;
            time_t seen([package seen]);

            if (section == nil || last != seen) {
                last = seen;

                NSString *name;
                name = (NSString *) CFDateFormatterCreateStringWithDate(NULL, formatter, (CFDateRef) [NSDate dateWithTimeIntervalSince1970:seen]);
                [name autorelease];

                _profile(ChangesController$reloadData$Allocate)
                    name = [NSString stringWithFormat:UCLocalize("NEW_AT"), name];
                    section = [[[Section alloc] initWithName:name row:offset localize:NO] autorelease];
                    [sections addObject:section];
                _end
            }

            [section addToCount];
        } else if ([package ignored]) {
            if (ignored == nil) {
                ignored = [[[Section alloc] initWithName:UCLocalize("IGNORED_UPGRADES") row:offset localize:NO] autorelease];
            }
            [ignored addToCount];
        } else {
            ++upgrades_;
            [upgradable addToCount];
        }
    }
    _trace();

    CFRelease(formatter);

    if (unseens) {
        Section *last = [sections lastObject];
        size_t count = [last count];
        [packages removeObjectsInRange:NSMakeRange([packages count] - count, count)];
        [sections removeLastObject];
    }

    if ([ignored count] != 0)
        [sections insertObject:ignored atIndex:0];
    if (upgrades_ != 0)
        [sections insertObject:upgradable atIndex:0];

    [[self navigationItem] setRightBarButtonItem:(upgrades_ == 0 ? nil : [[[UIBarButtonItem alloc]
        initWithTitle:[NSString stringWithFormat:UCLocalize("PARENTHETICAL"), UCLocalize("UPGRADE"), [NSString stringWithFormat:@"%u", upgrades_]]
        style:UIBarButtonItemStylePlain
        target:self
        action:@selector(upgradeButtonClicked)
    ] autorelease]) animated:YES];

    return sections;
}

@end
/* }}} */
/* Search Controller {{{ */
@interface SearchController : FilteredPackageListController <
    UISearchBarDelegate
> {
    _H<UISearchBar, 1> search_;
    BOOL searchloaded_;
    bool summary_;
}

- (id) initWithDatabase:(Database *)database query:(NSString *)query;
- (void) reloadData;

@end

@implementation SearchController

- (NSURL *) referrerURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/search?q=%@", UI_, [([search_ text] ?: @"") stringByAddingPercentEscapesIncludingReserved]]];
}

- (NSURL *) navigationURL {
    if ([search_ text] == nil || [[search_ text] isEqualToString:@""])
        return [NSURL URLWithString:@"cydia://search"];
    else
        return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://search/%@", [[search_ text] stringByAddingPercentEscapesIncludingReserved]]];
}

- (NSArray *) termsForQuery:(NSString *)query {
    NSMutableArray *terms([NSMutableArray arrayWithCapacity:2]);
    for (NSString *component in [query componentsSeparatedByString:@" "])
        if ([component length] != 0)
            [terms addObject:component];

    return terms;
}

- (void) useSearch {
    _H<NSArray> query([self termsForQuery:[search_ text]]);
    summary_ = false;

@synchronized (self) {
    [self setFilter:[=](Package *package) {
        if (![package unfiltered])
            return false;
        if (![package matches:query])
            return false;
        return true;
    }];

    [self setSorter:[](NSMutableArray *packages) {
        [packages radixSortUsingSelector:@selector(rank)];
    }];
}

    [self clearData];
    [self reloadData];
}

- (void) usePrefix:(NSString *)prefix {
    _H<NSString> query(prefix);
    summary_ = true;

@synchronized (self) {
    [self setFilter:[=](Package *package) {
        if ([query length] == 0)
            return false;
        if (![package unfiltered])
            return false;
        if ([[package name] compare:query options:MatchCompareOptions_ range:NSMakeRange(0, [query length])] != NSOrderedSame)
            return false;
        return true;
    }];

    [self setSorter:nullptr];
}

    [self reloadData];
}

- (void) searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self clearData];
    [self usePrefix:[search_ text]];
}

- (void) searchBarButtonClicked:(UISearchBar *)searchBar {
    [search_ resignFirstResponder];
    [self useSearch];
}

- (void) searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [search_ setText:@""];
    [self searchBarButtonClicked:searchBar];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchBarButtonClicked:searchBar];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)text {
    [self usePrefix:text];
}

- (bool) shouldYield {
    return YES;
}

- (bool) shouldBlock {
    return !summary_;
}

- (bool) isSummarized {
    return summary_;
}

- (bool) showsSections {
    return false;
}

- (id) initWithDatabase:(Database *)database query:(NSString *)query {
    if ((self = [super initWithDatabase:database title:UCLocalize("SEARCH")])) {
        search_ = [[[UISearchBar alloc] init] autorelease];
        [search_ setPlaceholder:UCLocalize("SEARCH_EX")];
        [search_ setDelegate:self];

        UITextField *textField;
        if ([search_ respondsToSelector:@selector(searchField)])
            textField = [search_ searchField];
        else
            textField = MSHookIvar<UITextField *>(search_, "_searchField");

        [textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
        [textField setEnablesReturnKeyAutomatically:NO];
        [[self navigationItem] setTitleView:textField];

        if (query != nil)
            [search_ setText:query];
        [self useSearch];
    } return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (!searchloaded_) {
        searchloaded_ = YES;
        [search_ setFrame:CGRectMake(0, 0, [[self view] bounds].size.width, 44.0f)];
        [search_ layoutSubviews];
    }

    if ([self isSummarized])
        [search_ becomeFirstResponder];
}

- (void) reloadData {
    [self resetCursor];
    [super reloadData];
}

- (void) didSelectPackage:(Package *)package {
    [search_ resignFirstResponder];
    [super didSelectPackage:package];
}

@end
/* }}} */
/* Package Settings Controller {{{ */
@interface PackageSettingsController : CyteViewController <
    UITableViewDataSource,
    UITableViewDelegate
> {
    _transient Database *database_;
    _H<NSString> name_;
    _H<Package> package_;
    _H<UITableView, 2> table_;
    _H<UISwitch> subscribedSwitch_;
    _H<UISwitch> ignoredSwitch_;
    _H<UITableViewCell> subscribedCell_;
    _H<UITableViewCell> ignoredCell_;
}

- (id) initWithDatabase:(Database *)database package:(NSString *)package;

@end

@implementation PackageSettingsController

- (NSURL *) navigationURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"cydia://package/%@/settings", (id) name_]];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    if (package_ == nil)
        return 0;

    if ([package_ installed] == nil)
        return 1;
    else
        return 2;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (package_ == nil)
        return 0;

    // both sections contain just one item right now.
    return 1;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 0)
        return UCLocalize("SHOW_ALL_CHANGES_EX");
    else
        return UCLocalize("IGNORE_UPGRADES_EX");
}

- (void) onSubscribed:(id)control {
    bool value([control isOn]);
    if (package_ == nil)
        return;
    if ([package_ setSubscribed:value])
        [self.delegate updateData];
}

- (void) _updateIgnored {
    const char *package([name_ UTF8String]);
    bool on([ignoredSwitch_ isOn]);

    FILE *dpkg(popen("/usr/libexec/cydia/cydo --set-selections", "w"));
    fwrite(package, strlen(package), 1, dpkg);

    if (on)
        fwrite(" hold\n", 6, 1, dpkg);
    else
        fwrite(" install\n", 9, 1, dpkg);

    pclose(dpkg);
}

- (void) onIgnored:(id)control {
    NSInvocation *invocation([NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(_updateIgnored)]]);
    [invocation setTarget:self];
    [invocation setSelector:@selector(_updateIgnored)];

    [self.delegate reloadDataWithInvocation:invocation];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (package_ == nil)
        return nil;

    switch ([indexPath section]) {
        case 0: return subscribedCell_;
        case 1: return ignoredCell_;

        _nodefault
    }

    return nil;
}

- (void) loadView {
    UIView *view([[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease]);
    [view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self setView:view];

    table_ = [[[UITableView alloc] initWithFrame:[[self view] bounds] style:UITableViewStyleGrouped] autorelease];
    [table_ setAutoresizingMask:UIViewAutoresizingFlexibleBoth];
    [(UITableView *) table_ setDataSource:self];
    [table_ setDelegate:self];
    [view addSubview:table_];

    subscribedSwitch_ = [[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 20)] autorelease];
    [subscribedSwitch_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [subscribedSwitch_ addTarget:self action:@selector(onSubscribed:) forEvents:UIControlEventValueChanged];

    ignoredSwitch_ = [[[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 50, 20)] autorelease];
    [ignoredSwitch_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [ignoredSwitch_ addTarget:self action:@selector(onIgnored:) forEvents:UIControlEventValueChanged];

    subscribedCell_ = [[[UITableViewCell alloc] init] autorelease];
    [subscribedCell_ setText:UCLocalize("SHOW_ALL_CHANGES")];
    [subscribedCell_ setAccessoryView:subscribedSwitch_];
    [subscribedCell_ setSelectionStyle:UITableViewCellSelectionStyleNone];

    ignoredCell_ = [[[UITableViewCell alloc] init] autorelease];
    [ignoredCell_ setText:UCLocalize("IGNORE_UPGRADES")];
    [ignoredCell_ setAccessoryView:ignoredSwitch_];
    [ignoredCell_ setSelectionStyle:UITableViewCellSelectionStyleNone];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    [[self navigationItem] setTitle:UCLocalize("SETTINGS")];
}

- (void) releaseSubviews {
    ignoredCell_ = nil;
    subscribedCell_ = nil;
    table_ = nil;
    ignoredSwitch_ = nil;
    subscribedSwitch_ = nil;

    [super releaseSubviews];
}

- (id) initWithDatabase:(Database *)database package:(NSString *)package {
    if ((self = [super init]) != nil) {
        database_ = database;
        name_ = package;
    } return self;
}

- (void) reloadData {
    [super reloadData];

    package_ = [database_ packageWithName:name_];

    if (package_ != nil) {
        [subscribedSwitch_ setOn:([package_ subscribed] ? 1 : 0) animated:NO];
        [ignoredSwitch_ setOn:([package_ ignored] ? 1 : 0) animated:NO];
    } // XXX: what now, G?

    [table_ reloadData];
}

@end
/* }}} */

/* Installed Controller {{{ */
@interface InstalledController : FilteredPackageListController {
    bool sectioned_;
}

- (id) initWithDatabase:(Database *)database;
- (void) queueStatusDidChange;

@end

@implementation InstalledController

- (NSURL *) referrerURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/#!/installed/", UI_]];
}

- (NSURL *) navigationURL {
    return [NSURL URLWithString:@"cydia://installed"];
}

- (void) useRecent {
    sectioned_ = false;

@synchronized (self) {
    [self setFilter:[](Package *package) {
        return ![package uninstalled] && package->role_ < 7;
    }];

    [self setSorter:[](NSMutableArray *packages) {
        [packages radixSortUsingSelector:@selector(recent)];
    }];
} }

- (void) useFilter:(UISegmentedControl *)segmented {
    NSInteger selected([segmented selectedSegmentIndex]);
    if (selected == 2)
        return [self useRecent];
    bool simple(selected == 0);
    sectioned_ = true;

@synchronized (self) {
    [self setFilter:[=](Package *package) {
        return ![package uninstalled] && package->role_ <= (simple ? 1 : 3);
    }];

    [self setSorter:nullptr];
} }

- (NSArray *) sectionsForPackages:(NSMutableArray *)packages {
    if (sectioned_)
        return [super sectionsForPackages:packages];

    CFDateFormatterRef formatter(CFDateFormatterCreate(NULL, Locale_, kCFDateFormatterLongStyle, kCFDateFormatterNoStyle));

    NSMutableArray *sections([NSMutableArray arrayWithCapacity:16]);
    Section *section(nil);
    time_t last(0);

    for (size_t offset(0), count([packages count]); offset != count; ++offset) {
        Package *package([packages objectAtIndex:offset]);

        time_t upgraded([package upgraded]);
        if (upgraded < 1168364520)
            upgraded = 0;
        else
            upgraded -= upgraded % (60 * 60 * 24);

        if (section == nil || upgraded != last) {
            last = upgraded;

            NSString *name;
            if (upgraded == 0)
                continue; // XXX: name = UCLocalize("...");
            else {
                name = (NSString *) CFDateFormatterCreateStringWithDate(NULL, formatter, (CFDateRef) [NSDate dateWithTimeIntervalSince1970:upgraded]);
                [name autorelease];
            }

            section = [[[Section alloc] initWithName:name row:offset localize:NO] autorelease];
            [sections addObject:section];
        }

        [section addToCount];
    }

    CFRelease(formatter);
    return sections;
}

- (id) initWithDatabase:(Database *)database {
    if ((self = [super initWithDatabase:database title:UCLocalize("INSTALLED")]) != nil) {
        UISegmentedControl *segmented([[[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:UCLocalize("USER"), UCLocalize("EXPERT"), UCLocalize("RECENT"), nil]] autorelease]);
        [segmented setSelectedSegmentIndex:0];
        [segmented setSegmentedControlStyle:UISegmentedControlStyleBar];
        [[self navigationItem] setTitleView:segmented];

        [segmented addTarget:self action:@selector(modeChanged:) forEvents:UIControlEventValueChanged];
        [self useFilter:segmented];

        [self queueStatusDidChange];
    } return self;
}

#if !AlwaysReload
- (void) queueButtonClicked {
    [self.delegate queue];
}
#endif

- (void) queueStatusDidChange {
#if !AlwaysReload
    if (Queuing_) {
        [[self navigationItem] setRightBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("QUEUE")
            style:UIBarButtonItemStyleDone
            target:self
            action:@selector(queueButtonClicked)
        ] autorelease]];
    } else {
        [[self navigationItem] setRightBarButtonItem:nil];
    }
#endif
}

- (void) modeChanged:(UISegmentedControl *)segmented {
    [self useFilter:segmented];
    [self reloadData];
}

@end
/* }}} */

/* Source Cell {{{ */
@interface SourceCell : CyteTableViewCell <
    CyteTableViewCellDelegate,
    SourceDelegate
> {
    _H<Source, 1> source_;
    _H<NSURL> url_;
    _H<UIImage> icon_;
    _H<NSString> origin_;
    _H<NSString> label_;
    _H<UIActivityIndicatorView> indicator_;
}

- (void) setSource:(Source *)source;
- (void) setFetch:(NSNumber *)fetch;

@end

@implementation SourceCell

- (void) _setImage:(NSArray *)data {
    if ([url_ isEqual:[data objectAtIndex:0]]) {
        icon_ = [data objectAtIndex:1];
        [self.content setNeedsDisplay];
    }
}

- (void) _setSource:(NSURL *) url {
    NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

    if (NSData *data = [NSURLConnection
        sendSynchronousRequest:[NSURLRequest
            requestWithURL:url
            cachePolicy:NSURLRequestUseProtocolCachePolicy
            timeoutInterval:10
        ]

        returningResponse:NULL
        error:NULL
    ])
        if (UIImage *image = [UIImage imageWithData:data])
            [self performSelectorOnMainThread:@selector(_setImage:) withObject:[NSArray arrayWithObjects:url, image, nil] waitUntilDone:NO];

    [pool release];
}

- (void) setSource:(Source *)source {
    source_ = source;
    [source_ setDelegate:self];

    [self setFetch:[NSNumber numberWithBool:[source_ fetch]]];

    icon_ = [UIImage imageNamed:@"unknown.png"];

    origin_ = [source name];
    label_ = [source rooturi];

    [self.content setNeedsDisplay];

    url_ = [source iconURL];
    [NSThread detachNewThreadSelector:@selector(_setSource:) toTarget:self withObject:url_];
}

- (void) setAllSource {
    source_ = nil;
    [indicator_ stopAnimating];

    icon_ = [UIImage imageNamed:@"folder.png"];
    origin_ = UCLocalize("ALL_SOURCES");
    label_ = UCLocalize("ALL_SOURCES_EX");
    [self.content setNeedsDisplay];
}

- (SourceCell *) initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) != nil) {
        [self.content setBackgroundColor:[UIColor whiteColor]];
        [self.content setOpaque:YES];

        indicator_ = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGraySmall] autorelease];
        [indicator_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];// | UIViewAutoresizingFlexibleBottomMargin];
        [[self contentView] addSubview:indicator_];

        [[self.content layer] setContentsGravity:kCAGravityTopLeft];
    } return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];

    UIView *content([self contentView]);
    CGRect bounds([content bounds]);

    CGRect frame([indicator_ frame]);
    frame.origin.x = bounds.size.width - frame.size.width;
    frame.origin.y = Retina((bounds.size.height - frame.size.height) / 2);

    if (kCFCoreFoundationVersionNumber < 800)
        frame.origin.x -= 8;
    [indicator_ setFrame:frame];
}

- (NSString *) accessibilityLabel {
    return origin_;
}

- (void) drawContentRect:(CGRect)rect {
    bool highlighted(self.highlighted);
    float width(rect.size.width);

    if (icon_ != nil) {
        CGRect rect;
        rect.size = [(UIImage *) icon_ size];

        while (rect.size.width > 32 || rect.size.height > 32) {
            rect.size.width /= 2;
            rect.size.height /= 2;
        }

        rect.origin.x = 26 - rect.size.width / 2;
        rect.origin.y = 26 - rect.size.height / 2;

        [icon_ drawInRect:Retina(rect)];
    }

    if (highlighted && kCFCoreFoundationVersionNumber < 800)
        UISetColor(White_);

    if (!highlighted)
        UISetColor(Black_);
    [origin_ drawAtPoint:CGPointMake(52, 8) forWidth:(width - 49) withFont:Font18Bold_ lineBreakMode:NSLineBreakByTruncatingTail];

    if (!highlighted)
        UISetColor(Gray_);
    [label_ drawAtPoint:CGPointMake(52, 29) forWidth:(width - 49) withFont:Font12_ lineBreakMode:NSLineBreakByTruncatingTail];
}

- (void) setFetch:(NSNumber *)fetch {
    if ([fetch boolValue])
        [indicator_ startAnimating];
    else
        [indicator_ stopAnimating];
}

@end
/* }}} */
/* Sources Controller {{{ */
@interface SourcesController : CyteViewController <
    UITableViewDataSource,
    UITableViewDelegate
> {
    _transient Database *database_;
    unsigned era_;

    _H<UITableView, 2> list_;
    _H<NSMutableArray> sources_;
    int offset_;

    _H<NSString> href_;
    _H<UIProgressHUD> hud_;
    _H<NSError> error_;

    NSURLConnection *trivial_bz2_;
    NSURLConnection *trivial_gz_;

    BOOL cydia_;
}

- (id) initWithDatabase:(Database *)database;
- (void) updateButtonsForEditingStatusAnimated:(BOOL)animated;

@end

@implementation SourcesController

- (void) _releaseConnection:(NSURLConnection *)connection {
    if (connection != nil) {
        [connection cancel];
        //[connection setDelegate:nil];
        [connection release];
    }
}

- (void) dealloc {
    [self _releaseConnection:trivial_gz_];
    [self _releaseConnection:trivial_bz2_];

    [super dealloc];
}

- (NSURL *) navigationURL {
    return [NSURL URLWithString:@"cydia://sources"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [list_ deselectRowAtIndexPath:[list_ indexPathForSelectedRow] animated:animated];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return UCLocalize("INDIVIDUAL_SOURCES");
    return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: return 1;
        case 1: return [sources_ count];
        default: return 0;
    }
}

- (Source *) sourceAtIndexPath:(NSIndexPath *)indexPath {
@synchronized (database_) {
    if ([database_ era] != era_)
        return nil;
    if ([indexPath section] != 1)
        return nil;
    NSUInteger index([indexPath row]);
    if (index >= [sources_ count])
        return nil;
    return [sources_ objectAtIndex:index];
} }

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"SourceCell";

    SourceCell *cell = (SourceCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) cell = [[[SourceCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];

    Source *source([self sourceAtIndexPath:indexPath]);
    if (source == nil)
        [cell setAllSource];
    else
        [cell setSource:source];

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SectionsController *controller([[[SectionsController alloc]
        initWithDatabase:database_
        source:[self sourceAtIndexPath:indexPath]
    ] autorelease]);

    [controller setDelegate:self.delegate];
    [[self navigationController] pushViewController:controller animated:YES];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] != 1)
        return false;
    Source *source = [self sourceAtIndexPath:indexPath];
    return [source record] != nil;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    _assert([indexPath section] == 1);
    if (editingStyle ==  UITableViewCellEditingStyleDelete) {
        Source *source = [self sourceAtIndexPath:indexPath];
        if (source == nil) return;

        [Sources_ removeObjectForKey:[source key]];

        [self.delegate syncData];
    }
}

- (void) tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    [self updateButtonsForEditingStatusAnimated:YES];
}

- (void) complete {
    [self.delegate addTrivialSource:href_];
    href_ = nil;

    [self.delegate syncData];
}

- (NSString *) getWarning {
    NSString *href(href_);
    NSRange colon([href rangeOfString:@"://"]);
    if (colon.location != NSNotFound)
        href = [href substringFromIndex:(colon.location + 3)];
    href = [href stringByAddingPercentEscapes];
    href = [CydiaURL(@"api/repotag/") stringByAppendingString:href];

    NSURL *url([NSURL URLWithString:href]);

    NSStringEncoding encoding;
    NSError *error(nil);

    if (NSString *warning = [NSString stringWithContentsOfURL:url usedEncoding:&encoding error:&error])
        return [warning length] == 0 ? nil : warning;
    return nil;
}

- (void) _endConnection:(NSURLConnection *)connection {
    // XXX: the memory management in this method is horribly awkward

    NSURLConnection **field = NULL;
    if (connection == trivial_bz2_)
        field = &trivial_bz2_;
    else if (connection == trivial_gz_)
        field = &trivial_gz_;
    _assert(field != NULL);
    [connection release];
    *field = nil;

    if (
        trivial_bz2_ == nil &&
        trivial_gz_ == nil
    ) {
        NSString *warning(cydia_ ? [self yieldToSelector:@selector(getWarning)] : nil);

        [self.delegate releaseNetworkActivityIndicator];

        [self.delegate removeProgressHUD:hud_];
        hud_ = nil;

        if (cydia_) {
            if (warning != nil) {
                UIAlertView *alert = [[[UIAlertView alloc]
                    initWithTitle:UCLocalize("SOURCE_WARNING")
                    message:warning
                    delegate:self
                    cancelButtonTitle:UCLocalize("CANCEL")
                    otherButtonTitles:
                        UCLocalize("ADD_ANYWAY"),
                    nil
                ] autorelease];

                [alert setContext:@"warning"];
                [alert setNumberOfRows:1];
                [alert show];

                // XXX: there used to be this great mechanism called yieldToPopup... who deleted it?
                error_ = nil;
                return;
            }

            [self complete];
        } else if (error_ != nil) {
            UIAlertView *alert = [[[UIAlertView alloc]
                initWithTitle:UCLocalize("VERIFICATION_ERROR")
                message:[error_ localizedDescription]
                delegate:self
                cancelButtonTitle:UCLocalize("OK")
                otherButtonTitles:nil
            ] autorelease];

            [alert setContext:@"urlerror"];
            [alert show];

            href_ = nil;
        } else {
            UIAlertView *alert = [[[UIAlertView alloc]
                initWithTitle:UCLocalize("NOT_REPOSITORY")
                message:UCLocalize("NOT_REPOSITORY_EX")
                delegate:self
                cancelButtonTitle:UCLocalize("OK")
                otherButtonTitles:nil
            ] autorelease];

            [alert setContext:@"trivial"];
            [alert show];

            href_ = nil;
        }

        error_ = nil;
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    switch ([response statusCode]) {
        case 200:
            cydia_ = YES;
    }
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    lprintf("connection:\"%s\" didFailWithError:\"%s\"\n", [href_ UTF8String], [[error localizedDescription] UTF8String]);
    error_ = error;
    [self _endConnection:connection];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    [self _endConnection:connection];
}

- (NSURLConnection *) _requestHRef:(NSString *)href method:(NSString *)method {
    NSURL *url([NSURL URLWithString:href]);

    NSMutableURLRequest *request = [NSMutableURLRequest
        requestWithURL:url
        cachePolicy:NSURLRequestUseProtocolCachePolicy
        timeoutInterval:10
    ];

    [request setHTTPMethod:method];

    if (Machine_ != NULL)
        [request setValue:[NSString stringWithUTF8String:Machine_] forHTTPHeaderField:@"X-Machine"];

    if (UniqueID_ != nil)
        [request setValue:UniqueID_ forHTTPHeaderField:@"X-Unique-ID"];

    if ([url isCydiaSecure]) {
        if (UniqueID_ != nil)
            [request setValue:UniqueID_ forHTTPHeaderField:@"X-Cydia-Id"];
    }

    return [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button {
    NSString *context([alert context]);

    if ([context isEqualToString:@"source"]) {
        switch (button) {
            case 1: {
                NSString *href = [[alert textField] text];
                href = VerifySource(href);
                if (href == nil)
                    break;
                href_ = href;

                trivial_bz2_ = [[self _requestHRef:[href_ stringByAppendingString:@"Packages.bz2"] method:@"HEAD"] retain];
                trivial_gz_ = [[self _requestHRef:[href_ stringByAppendingString:@"Packages.gz"] method:@"HEAD"] retain];

                cydia_ = false;

                // XXX: this is stupid
                hud_ = [self.delegate addProgressHUD];
                [hud_ setText:UCLocalize("VERIFYING_URL")];
                [self.delegate retainNetworkActivityIndicator];
            } break;

            case 0:
            break;

            _nodefault
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else if ([context isEqualToString:@"trivial"])
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    else if ([context isEqualToString:@"urlerror"])
        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    else if ([context isEqualToString:@"warning"]) {
        switch (button) {
            case 1:
                [self performSelector:@selector(complete) withObject:nil afterDelay:0];
            break;

            case 0:
            break;

            _nodefault
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (void) updateButtonsForEditingStatusAnimated:(BOOL)animated {
    BOOL editing([list_ isEditing]);

    if (editing)
        [[self navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("ADD")
            style:UIBarButtonItemStylePlain
            target:self
            action:@selector(addButtonClicked)
        ] autorelease] animated:animated];
    else if ([self.delegate updating])
        [[self navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("CANCEL")
            style:UIBarButtonItemStyleDone
            target:self
            action:@selector(cancelButtonClicked)
        ] autorelease] animated:animated];
    else
        [[self navigationItem] setLeftBarButtonItem:[[[UIBarButtonItem alloc]
            initWithTitle:UCLocalize("REFRESH")
            style:UIBarButtonItemStylePlain
            target:self
            action:@selector(refreshButtonClicked)
        ] autorelease] animated:animated];

    [[self navigationItem] setRightBarButtonItem:[[[UIBarButtonItem alloc]
        initWithTitle:(editing ? UCLocalize("DONE") : UCLocalize("EDIT"))
        style:(editing ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain)
        target:self
        action:@selector(editButtonClicked)
    ] autorelease] animated:animated];
}

- (void) loadView {
    list_ = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain] autorelease];
    [list_ setAutoresizingMask:UIViewAutoresizingFlexibleBoth];
    [list_ setRowHeight:53];
    [(UITableView *) list_ setDataSource:self];
    [list_ setDelegate:self];
    [self setView:list_];
}

- (void) viewDidLoad {
    [super viewDidLoad];

    [[self navigationItem] setTitle:UCLocalize("SOURCES")];
    [self updateButtonsForEditingStatusAnimated:NO];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [list_ setEditing:NO];
    [self updateButtonsForEditingStatusAnimated:NO];
}

- (void) releaseSubviews {
    list_ = nil;

    sources_ = nil;

    [super releaseSubviews];
}

- (id) initWithDatabase:(Database *)database {
    if ((self = [super init]) != nil) {
        database_ = database;
    } return self;
}

- (void) reloadData {
    [super reloadData];
    [self updateButtonsForEditingStatusAnimated:YES];

@synchronized (database_) {
    era_ = [database_ era];

    sources_ = [NSMutableArray arrayWithCapacity:16];
    [sources_ addObjectsFromArray:[database_ sources]];
    _trace();
    [sources_ sortUsingSelector:@selector(compareByName:)];
    _trace();

    int count([sources_ count]);
    offset_ = 0;
    for (int i = 0; i != count; i++) {
        if ([[sources_ objectAtIndex:i] record] == nil)
            break;
        offset_++;
    }

    [list_ reloadData];
} }

- (void) showAddSourcePrompt {
    UIAlertView *alert = [[[UIAlertView alloc]
        initWithTitle:UCLocalize("ENTER_APT_URL")
        message:nil
        delegate:self
        cancelButtonTitle:UCLocalize("CANCEL")
        otherButtonTitles:
            UCLocalize("ADD_SOURCE"),
        nil
    ] autorelease];

    [alert setContext:@"source"];

    [alert setNumberOfRows:1];
    [alert addTextFieldWithValue:@"http://" label:@""];

    NSObject<UITextInputTraits> *traits = [[alert textField] textInputTraits];
    [traits setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [traits setAutocorrectionType:UITextAutocorrectionTypeNo];
    [traits setKeyboardType:UIKeyboardTypeURL];
    // XXX: UIReturnKeyDone
    [traits setReturnKeyType:UIReturnKeyNext];

    [alert show];
}

- (void) addButtonClicked {
    [self showAddSourcePrompt];
}

- (void) refreshButtonClicked {
    if ([self.delegate requestUpdate])
        [self updateButtonsForEditingStatusAnimated:YES];
}

- (void) cancelButtonClicked {
    [self.delegate cancelUpdate];
}

- (void) editButtonClicked {
    [list_ setEditing:![list_ isEditing] animated:YES];
    [self updateButtonsForEditingStatusAnimated:YES];
}

@end
/* }}} */

/* Stash Controller {{{ */
@interface StashController : CyteViewController {
    _H<UIActivityIndicatorView> spinner_;
    _H<UILabel> status_;
    _H<UILabel> caption_;
}

@end

@implementation StashController

- (void) loadView {
    UIView *view([[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease]);
    [view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
    [self setView:view];

    [view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];

    spinner_ = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge] autorelease];
    CGRect spinrect = [spinner_ frame];
    spinrect.origin.x = Retina([[self view] frame].size.width / 2 - spinrect.size.width / 2);
    spinrect.origin.y = [[self view] frame].size.height - 80.0f;
    [spinner_ setFrame:spinrect];
    [spinner_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    [view addSubview:spinner_];
    [spinner_ startAnimating];

    CGRect captrect;
    captrect.size.width = [[self view] frame].size.width;
    captrect.size.height = 40.0f;
    captrect.origin.x = 0;
    captrect.origin.y = Retina([[self view] frame].size.height / 2 - captrect.size.height * 2);
    caption_ = [[[UILabel alloc] initWithFrame:captrect] autorelease];
    [caption_ setText:UCLocalize("PREPARING_FILESYSTEM")];
    [caption_ setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [caption_ setFont:[UIFont boldSystemFontOfSize:28.0f]];
    [caption_ setTextColor:[UIColor whiteColor]];
    [caption_ setBackgroundColor:[UIColor clearColor]];
    [caption_ setShadowColor:[UIColor blackColor]];
    [caption_ setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:caption_];

    CGRect statusrect;
    statusrect.size.width = [[self view] frame].size.width;
    statusrect.size.height = 30.0f;
    statusrect.origin.x = 0;
    statusrect.origin.y = Retina([[self view] frame].size.height / 2 - statusrect.size.height);
    status_ = [[[UILabel alloc] initWithFrame:statusrect] autorelease];
    [status_ setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [status_ setText:UCLocalize("EXIT_WHEN_COMPLETE")];
    [status_ setFont:[UIFont systemFontOfSize:16.0f]];
    [status_ setTextColor:[UIColor whiteColor]];
    [status_ setBackgroundColor:[UIColor clearColor]];
    [status_ setShadowColor:[UIColor blackColor]];
    [status_ setTextAlignment:NSTextAlignmentCenter];
    [view addSubview:status_];
}

- (void) releaseSubviews {
    spinner_ = nil;
    status_ = nil;
    caption_ = nil;

    [super releaseSubviews];
}

@end
/* }}} */

@interface Cydia : CyteApplication <
    ConfirmationControllerDelegate,
    DatabaseDelegate,
    CydiaDelegate
> {
    _H<CyteWindow> window_;
    _H<CydiaTabBarController> tabbar_;
    _H<CyteTabBarController> emulated_;
    _H<AppCacheController> appcache_;

    _H<NSMutableArray> essential_;
    _H<NSMutableArray> broken_;

    Database *database_;

    _H<NSURL> starturl_;

    unsigned locked_;

    _H<StashController> stash_;

    bool loaded_;
}

- (void) loadData;

@end

@implementation Cydia

- (void) lockSuspend {
    if (locked_++ == 0) {
        if ($SBSSetInterceptsMenuButtonForever != NULL)
            (*$SBSSetInterceptsMenuButtonForever)(true);

        [self setIdleTimerDisabled:YES];
    }
}

- (void) unlockSuspend {
    if (--locked_ == 0) {
        [self setIdleTimerDisabled:NO];

        if ($SBSSetInterceptsMenuButtonForever != NULL)
            (*$SBSSetInterceptsMenuButtonForever)(false);
    }
}

- (void) beginUpdate {
    [tabbar_ beginUpdate];
}

- (void) cancelUpdate {
    [tabbar_ cancelUpdate];
}

- (bool) requestUpdate {
    if (CyteIsReachable("cydia.saurik.com")) {
        [self beginUpdate];
        return true;
    } else {
        UIAlertView *alert = [[[UIAlertView alloc]
            initWithTitle:[NSString stringWithFormat:Colon_, Error_, UCLocalize("REFRESH")]
            message:@"Host Unreachable" // XXX: Localize
            delegate:self
            cancelButtonTitle:UCLocalize("OK")
            otherButtonTitles:nil
        ] autorelease];

        [alert setContext:@"norefresh"];
        [alert show];

        return false;
    }
}

- (BOOL) updating {
    return [tabbar_ updating];
}

- (void) _loaded {
    if ([broken_ count] != 0) {
        int count = [broken_ count];

        UIAlertView *alert = [[[UIAlertView alloc]
            initWithTitle:(count == 1 ? UCLocalize("HALFINSTALLED_PACKAGE") : [NSString stringWithFormat:UCLocalize("HALFINSTALLED_PACKAGES"), count])
            message:UCLocalize("HALFINSTALLED_PACKAGE_EX")
            delegate:self
            cancelButtonTitle:[NSString stringWithFormat:UCLocalize("PARENTHETICAL"), UCLocalize("FORCIBLY_CLEAR"), UCLocalize("UNSAFE")]
            otherButtonTitles:
                UCLocalize("TEMPORARY_IGNORE"),
            nil
        ] autorelease];

        [alert setContext:@"fixhalf"];
        [alert setNumberOfRows:2];
        [alert show];
    } else if (!Ignored_ && [essential_ count] != 0) {
        int count = [essential_ count];

        UIAlertView *alert = [[[UIAlertView alloc]
            initWithTitle:(count == 1 ? UCLocalize("ESSENTIAL_UPGRADE") : [NSString stringWithFormat:UCLocalize("ESSENTIAL_UPGRADES"), count])
            message:UCLocalize("ESSENTIAL_UPGRADE_EX")
            delegate:self
            cancelButtonTitle:UCLocalize("TEMPORARY_IGNORE")
            otherButtonTitles:
                UCLocalize("UPGRADE_ESSENTIAL"),
                UCLocalize("COMPLETE_UPGRADE"),
            nil
        ] autorelease];

        [alert setContext:@"upgrade"];
        [alert show];
    }
}

- (void) returnToCydia {
    [self _loaded];
}

- (void) reloadSpringBoard {
    if (kCFCoreFoundationVersionNumber >= 700) // XXX: iOS 6.x
        system("/usr/libexec/cydia/cydo /bin/launchctl stop com.apple.backboardd");
    else
        system("/usr/libexec/cydia/cydo /bin/launchctl stop com.apple.SpringBoard");
    sleep(15);
    system("/usr/bin/killall backboardd SpringBoard");
}

- (void) _saveConfig {
    SaveConfig(database_);
}

// Navigation controller for the queuing badge.
- (UINavigationController *) queueNavigationController {
    NSArray *controllers = [tabbar_ viewControllers];
    return [controllers objectAtIndex:3];
}

- (void) _updateData {
    [self _saveConfig];
    [window_ unloadData];

    UINavigationController *navigation = [self queueNavigationController];

    id queuedelegate = nil;
    if ([[navigation viewControllers] count] > 0)
        queuedelegate = [[navigation viewControllers] objectAtIndex:0];

    [queuedelegate queueStatusDidChange];
    [[navigation tabBarItem] setBadgeValue:(Queuing_ ? UCLocalize("Q_D") : nil)];
}

- (void) _refreshIfPossible {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    NSDate *update([[NSDictionary dictionaryWithContentsOfFile:@ CacheState_] objectForKey:@"LastUpdate"]);

    bool recently = false;
    if (update != nil) {
        NSTimeInterval interval([update timeIntervalSinceNow]);
        if (interval > -(15*60))
            recently = true;
    }

    // Don't automatic refresh if:
    //  - We already refreshed recently.
    //  - We already auto-refreshed this launch.
    //  - Auto-refresh is disabled.
    //  - Cydia's server is not reachable
    if (recently || loaded_ || ManualRefresh || !CyteIsReachable("cydia.saurik.com")) {
        // If we are cancelling, we need to make sure it knows it's already loaded.
        loaded_ = true;

        [self performSelectorOnMainThread:@selector(_loaded) withObject:nil waitUntilDone:NO];
    } else {
        // We are going to load, so remember that.
        loaded_ = true;

        [tabbar_ performSelectorOnMainThread:@selector(beginUpdate) withObject:nil waitUntilDone:NO];
    }

    [pool release];
}

- (void) refreshIfPossible {
    [NSThread detachNewThreadSelector:@selector(_refreshIfPossible) toTarget:self withObject:nil];
}

- (void) reloadDataWithInvocation:(NSInvocation *)invocation {
_profile(reloadDataWithInvocation)
@synchronized (self) {
    UIProgressHUD *hud(loaded_ ? [self addProgressHUD] : nil);
    if (hud != nil)
        [hud setText:UCLocalize("RELOADING_DATA")];

    [database_ yieldToSelector:@selector(reloadDataWithInvocation:) withObject:invocation];

    size_t changes(0);

    [essential_ removeAllObjects];
    [broken_ removeAllObjects];

    _profile(reloadDataWithInvocation$Essential)
    NSArray *packages([database_ packages]);
    for (Package *package in packages) {
        if ([package half])
            [broken_ addObject:package];
        if ([package upgradableAndEssential:YES] && ![package ignored]) {
            if ([package essential] && [package installed] != nil)
                [essential_ addObject:package];
            ++changes;
        }
    }
    _end

    UITabBarItem *changesItem = [[[tabbar_ viewControllers] objectAtIndex:2] tabBarItem];
    if (changes != 0) {
        _trace();
        NSString *badge([[NSNumber numberWithInt:changes] stringValue]);
        [changesItem setBadgeValue:badge];
        [changesItem setAnimatedBadge:([essential_ count] > 0)];
        [self setApplicationIconBadgeNumber:changes];
    } else {
        _trace();
        [changesItem setBadgeValue:nil];
        [changesItem setAnimatedBadge:NO];
        [self setApplicationIconBadgeNumber:0];
    }

    Queuing_ = false;
    [self _updateData];

    if (hud != nil)
        [self removeProgressHUD:hud];
}
_end

    PrintTimes();
}

- (void) updateData {
    [self _updateData];
}

- (void) updateDataAndLoad {
    [self _updateData];
    if ([database_ progressDelegate] == nil)
        [self _loaded];
}

- (void) update_ {
    [database_ update];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (void) disemulate {
    if (emulated_ == nil)
        return;

    [window_ setRootViewController:tabbar_];
    emulated_ = nil;

    [window_ setUserInteractionEnabled:YES];
}

- (void) presentModalViewController:(UIViewController *)controller force:(BOOL)force {
    UINavigationController *navigation([[[UINavigationController alloc] initWithRootViewController:controller] autorelease]);

    UIViewController *parent;
    if (emulated_ == nil)
        parent = tabbar_;
    else if (!force)
        parent = emulated_;
    else {
        [self disemulate];
        parent = tabbar_;
    }

    if (IsWildcat_)
        [navigation setModalPresentationStyle:UIModalPresentationFormSheet];
    [parent presentModalViewController:navigation animated:YES];
}

- (ProgressController *) invokeNewProgress:(NSInvocation *)invocation forController:(UINavigationController *)navigation withTitle:(NSString *)title {
    ProgressController *progress([[[ProgressController alloc] initWithDatabase:database_ delegate:self] autorelease]);

    if (navigation != nil)
        [navigation pushViewController:progress animated:YES];
    else
        [self presentModalViewController:progress force:YES];

    [progress invoke:invocation withTitle:title];
    return progress;
}

- (void) detachNewProgressSelector:(SEL)selector toTarget:(id)target forController:(UINavigationController *)navigation title:(NSString *)title {
    [self invokeNewProgress:[NSInvocation invocationWithSelector:selector forTarget:target] forController:navigation withTitle:title];
}

- (void) repairWithInvocation:(NSInvocation *)invocation {
    _trace();
    [self invokeNewProgress:invocation forController:nil withTitle:@"REPAIRING"];
    _trace();
}

- (void) repairWithSelector:(SEL)selector {
    [self performSelectorOnMainThread:@selector(repairWithInvocation:) withObject:[NSInvocation invocationWithSelector:selector forTarget:database_] waitUntilDone:YES];
}

- (void) reloadData {
    [self reloadDataWithInvocation:nil];
    if ([database_ progressDelegate] == nil)
        [self _loaded];
}

- (void) syncData {
    [self _saveConfig];
    [self detachNewProgressSelector:@selector(update_) toTarget:self forController:nil title:@"UPDATING_SOURCES"];
}

- (void) addSource:(NSDictionary *) source {
    CydiaAddSource(source);
}

- (void) addSource:(NSString *)href withDistribution:(NSString *)distribution andSections:(NSArray *)sections {
    CydiaAddSource(href, distribution, sections);
}

// XXX: this method should not return anything
- (BOOL) addTrivialSource:(NSString *)href {
    CydiaAddSource(href, @"./");
    return YES;
}

- (void) resolve {
    pkgProblemResolver *resolver = [database_ resolver];

    resolver->InstallProtect();
    if (!resolver->Resolve(true))
        _error->Discard();
}

- (bool) perform {
    // XXX: this is a really crappy way of doing this.
    // like, seriously: this state machine is still broken, and cancelling this here doesn't really /fix/ that.
    // for one, the user can still /start/ a reloading data event while they have a queue, which is stupid
    // for two, this just means there is a race condition between the refresh completing and the confirmation controller appearing.
    if ([tabbar_ updating])
        [tabbar_ cancelUpdate];

    if (![database_ prepare])
        return false;

    ConfirmationController *page([[[ConfirmationController alloc] initWithDatabase:database_] autorelease]);
    [page setDelegate:self];
    UINavigationController *confirm_([[[UINavigationController alloc] initWithRootViewController:page] autorelease]);

    if (IsWildcat_)
        [confirm_ setModalPresentationStyle:UIModalPresentationFormSheet];
    [tabbar_ presentModalViewController:confirm_ animated:YES];

    return true;
}

- (void) queue {
    @synchronized (self) {
        [self perform];
    }
}

- (void) clearPackage:(Package *)package {
    @synchronized (self) {
        [package clear];
        [self resolve];
        [self perform];
    }
}

- (void) installPackages:(NSArray *)packages {
    @synchronized (self) {
        for (Package *package in packages)
            [package install];
        [self resolve];
        [self perform];
    }
}

- (void) installPackage:(Package *)package {
    @synchronized (self) {
        [package install];
        [self resolve];
        [self perform];
    }
}

- (void) removePackage:(Package *)package {
    @synchronized (self) {
        [package remove];
        [self resolve];
        [self perform];
    }
}

- (void) distUpgrade {
    @synchronized (self) {
        if (![database_ upgrade])
            return;
        [self perform];
    }
}

- (void) _uicache {
    _trace();
    system("/usr/bin/uicache");
    _trace();
}

- (void) uicache {
    UIProgressHUD *hud([self addProgressHUD]);
    [hud setText:UCLocalize("LOADING")];
    [self yieldToSelector:@selector(_uicache)];
    [self removeProgressHUD:hud];
}

- (void) perform_ {
    [database_ perform];
    [self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    [self performSelectorOnMainThread:@selector(uicache) withObject:nil waitUntilDone:YES];
}

- (void) confirmWithNavigationController:(UINavigationController *)navigation {
    Queuing_ = false;
    [self lockSuspend];
    [self detachNewProgressSelector:@selector(perform_) toTarget:self forController:navigation title:@"RUNNING"];
    [self unlockSuspend];
}

- (void) cancelAndClear:(bool)clear {
    @synchronized (self) {
        if (clear) {
            [database_ clear];
            Queuing_ = false;
        } else {
            Queuing_ = true;
        }

        [self _updateData];
    }
}

- (void) alertView:(UIAlertView *)alert clickedButtonAtIndex:(NSInteger)button {
    NSString *context([alert context]);

    if ([context isEqualToString:@"conffile"]) {
        FILE *input = [database_ input];
        if (button == [alert cancelButtonIndex])
            fprintf(input, "N\n");
        else if (button == [alert firstOtherButtonIndex])
            fprintf(input, "Y\n");
        fflush(input);

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else if ([context isEqualToString:@"fixhalf"]) {
        if (button == [alert cancelButtonIndex]) {
            @synchronized (self) {
                for (Package *broken in (id) broken_) {
                    [broken remove];
                    NSString *id(ShellEscape([broken id]));
                    system([[NSString stringWithFormat:@"/usr/libexec/cydia/cydo /bin/rm -f"
                        " /var/lib/dpkg/info/%@.prerm"
                        " /var/lib/dpkg/info/%@.postrm"
                        " /var/lib/dpkg/info/%@.preinst"
                        " /var/lib/dpkg/info/%@.postinst"
                        " /var/lib/dpkg/info/%@.extrainst_"
                    "", id, id, id, id, id] UTF8String]);
                }

                [self resolve];
                [self perform];
            }
        } else if (button == [alert firstOtherButtonIndex]) {
            [broken_ removeAllObjects];
            [self _loaded];
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    } else if ([context isEqualToString:@"upgrade"]) {
        if (button == [alert firstOtherButtonIndex]) {
            @synchronized (self) {
                for (Package *essential in (id) essential_)
                    [essential install];

                [self resolve];
                [self perform];
            }
        } else if (button == [alert firstOtherButtonIndex] + 1) {
            [self distUpgrade];
        } else if (button == [alert cancelButtonIndex]) {
            Ignored_ = YES;
        }

        [alert dismissWithClickedButtonIndex:-1 animated:YES];
    }
}

- (void) system:(NSString *)command {
    NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

    _trace();
    system([command UTF8String]);
    _trace();

    [pool release];
}

- (void) applicationWillSuspend {
    [database_ clean];
    [super applicationWillSuspend];
}

- (BOOL) isSafeToSuspend {
    if (locked_ != 0) {
#if !ForRelease
        NSLog(@"isSafeToSuspend: locked_ != 0");
#endif
        return false;
    }

    if ([tabbar_ modalViewController] != nil)
        return false;

    // Use external process status API internally.
    // This is probably a really bad idea.
    // XXX: what is the point of this? does this solve anything at all?
    uint64_t status = 0;
    int notify_token;
    if (notify_register_check("com.saurik.Cydia.status", &notify_token) == NOTIFY_STATUS_OK) {
        notify_get_state(notify_token, &status);
        notify_cancel(notify_token);
    }

    if (status != 0) {
#if !ForRelease
        NSLog(@"isSafeToSuspend: status != 0");
#endif
        return false;
    }

#if !ForRelease
    NSLog(@"isSafeToSuspend: -> true");
#endif
    return true;
}

- (void) suspendReturningToLastApp:(BOOL)returning {
    if ([self isSafeToSuspend])
        [super suspendReturningToLastApp:returning];
}

- (void) suspend {
    if ([self isSafeToSuspend])
        [super suspend];
}

- (void) applicationSuspend {
    if ([self isSafeToSuspend])
        [super applicationSuspend];
}

- (void) applicationSuspend:(GSEventRef)event {
    if ([self isSafeToSuspend])
        [super applicationSuspend:event];
}

- (void) _animateSuspension:(BOOL)arg0 duration:(double)arg1 startTime:(double)arg2 scale:(float)arg3 {
    if ([self isSafeToSuspend])
        [super _animateSuspension:arg0 duration:arg1 startTime:arg2 scale:arg3];
}

- (void) _setSuspended:(BOOL)value {
    if ([self isSafeToSuspend])
        [super _setSuspended:value];
}

- (UIProgressHUD *) addProgressHUD {
    UIProgressHUD *hud([[[UIProgressHUD alloc] init] autorelease]);
    [hud setAutoresizingMask:UIViewAutoresizingFlexibleBoth];

    [window_ setUserInteractionEnabled:NO];

    UIViewController *target(tabbar_);
    if (UIViewController *modal = [target modalViewController])
        target = modal;

    [hud showInView:[target view]];

    [self lockSuspend];
    return hud;
}

- (void) removeProgressHUD:(UIProgressHUD *)hud {
    [self unlockSuspend];
    [hud hide];
    [hud removeFromSuperview];
    [window_ setUserInteractionEnabled:YES];
}

- (CyteViewController *) pageForPackage:(NSString *)name withReferrer:(NSString *)referrer {
    return [[[CYPackageController alloc] initWithDatabase:database_ forPackage:name withReferrer:referrer] autorelease];
}

- (CyteViewController *) pageForURL:(NSURL *)url forExternal:(BOOL)external withReferrer:(NSString *)referrer {
    NSString *scheme([[url scheme] lowercaseString]);
    if ([[url absoluteString] length] <= [scheme length] + 3)
        return nil;
    NSString *path([[url absoluteString] substringFromIndex:[scheme length] + 3]);
    NSArray *components([path componentsSeparatedByString:@"/"]);

    if ([scheme isEqualToString:@"apptapp"] && [components count] > 0 && [[components objectAtIndex:0] isEqualToString:@"package"]) {
        CyteViewController *controller([self pageForPackage:[components objectAtIndex:1] withReferrer:referrer]);
        if (controller != nil)
            [controller setDelegate:self];
        return controller;
    }

    if ([components count] < 1 || ![scheme isEqualToString:@"cydia"])
        return nil;

    NSString *base([components objectAtIndex:0]);

    CyteViewController *controller = nil;

    if ([base isEqualToString:@"url"]) {
        // This kind of URL can contain slashes in the argument, so we can't parse them below.
        NSString *destination = [[url absoluteString] substringFromIndex:([scheme length] + [@"://" length] + [base length] + [@"/" length])];
        controller = [[[CydiaWebViewController alloc] initWithURL:[NSURL URLWithString:destination]] autorelease];
    } else if (!external && [components count] == 1) {
        if ([base isEqualToString:@"sources"]) {
            controller = [[[SourcesController alloc] initWithDatabase:database_] autorelease];
        }

        if ([base isEqualToString:@"home"]) {
            controller = [[[HomeController alloc] init] autorelease];
        }

        if ([base isEqualToString:@"sections"]) {
            controller = [[[SectionsController alloc] initWithDatabase:database_ source:nil] autorelease];
        }

        if ([base isEqualToString:@"search"]) {
            controller = [[[SearchController alloc] initWithDatabase:database_ query:nil] autorelease];
        }

        if ([base isEqualToString:@"changes"]) {
            controller = [[[ChangesController alloc] initWithDatabase:database_] autorelease];
        }

        if ([base isEqualToString:@"installed"]) {
            controller = [[[InstalledController alloc] initWithDatabase:database_] autorelease];
        }
    } else if ([components count] == 2) {
        NSString *argument = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if ([base isEqualToString:@"package"]) {
            controller = [self pageForPackage:argument withReferrer:referrer];
        }

        if (!external && [base isEqualToString:@"search"]) {
            controller = [[[SearchController alloc] initWithDatabase:database_ query:argument] autorelease];
        }

        if (!external && [base isEqualToString:@"sections"]) {
            if ([argument isEqualToString:@"all"] || [argument isEqualToString:@"*"])
                argument = nil;
            controller = [[[SectionController alloc] initWithDatabase:database_ source:nil section:argument] autorelease];
        }

        if ([base isEqualToString:@"sources"]) {
            if ([argument isEqualToString:@"add"]) {
                controller = [[[SourcesController alloc] initWithDatabase:database_] autorelease];
                [(SourcesController *)controller showAddSourcePrompt];
            } else {
                Source *source([database_ sourceWithKey:argument]);
                controller = [[[SectionsController alloc] initWithDatabase:database_ source:source] autorelease];
            }
        }

        if (!external && [base isEqualToString:@"launch"]) {
            [self launchApplicationWithIdentifier:argument suspended:NO];
            return nil;
        }
    } else if (!external && [components count] == 3) {
        NSString *arg1 = [[components objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSString *arg2 = [[components objectAtIndex:2] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

        if ([base isEqualToString:@"package"]) {
            if ([arg2 isEqualToString:@"settings"]) {
                controller = [[[PackageSettingsController alloc] initWithDatabase:database_ package:arg1] autorelease];
            } else if ([arg2 isEqualToString:@"files"]) {
                controller = [[[FileTable alloc] initWithDatabase:database_ forPackage:arg1] autorelease];
            }
        }

        if ([base isEqualToString:@"sections"]) {
            Source *source([arg1 isEqualToString:@"*"] ? nil : [database_ sourceWithKey:arg1]);
            NSString *section([arg2 isEqualToString:@"*"] ? nil : arg2);
            controller = [[[SectionController alloc] initWithDatabase:database_ source:source section:section] autorelease];
        }
    }

    [controller setDelegate:self];
    return controller;
}

- (BOOL) openCydiaURL:(NSURL *)url forExternal:(BOOL)external {
    CyteViewController *page([self pageForURL:url forExternal:external withReferrer:nil]);

    if (page != nil)
        [tabbar_ setUnselectedViewController:page];

    return page != nil;
}

- (void) applicationOpenURL:(NSURL *)url {
    [super applicationOpenURL:url];

    if (!loaded_)
        starturl_ = url;
    else
        [self openCydiaURL:url forExternal:YES];
}

- (void) applicationWillResignActive:(UIApplication *)application {
    // Stop refreshing if you get a phone call or lock the device.
    if ([tabbar_ updating])
        [tabbar_ cancelUpdate];

    if ([[self superclass] instancesRespondToSelector:@selector(applicationWillResignActive:)])
        [super applicationWillResignActive:application];
}

- (void) saveState {
    [[NSDictionary dictionaryWithObjectsAndKeys:
        @"InterfaceState", [tabbar_ navigationURLCollection],
        @"LastClosed", [NSDate date],
        @"InterfaceIndex", [NSNumber numberWithInt:[tabbar_ selectedIndex]],
    nil] writeToFile:@ SavedState_ atomically:YES];

    [self _saveConfig];
}

- (void) applicationWillTerminate:(UIApplication *)application {
    [self saveState];
}

- (void) applicationDidEnterBackground:(UIApplication *)application {
    if (kCFCoreFoundationVersionNumber < 1000 && [self isSafeToSuspend])
        return [self terminateWithSuccess];
    Backgrounded_ = [NSDate date];
    [self saveState];
}

- (void) applicationWillEnterForeground:(UIApplication *)application {
    if (Backgrounded_ == nil)
        return;

    NSTimeInterval interval([Backgrounded_ timeIntervalSinceNow]);

    if (interval <= -(30*60)) {
        [tabbar_ setSelectedIndex:0];
        [[[tabbar_ viewControllers] objectAtIndex:0] popToRootViewControllerAnimated:NO];
    }

    if (interval <= -(15*60)) {
        if (CyteIsReachable("cydia.saurik.com")) {
            [tabbar_ beginUpdate];
            [appcache_ reloadURLWithCache:YES];
        }
    }

    if ([database_ delocked])
        [self reloadData];
}

- (void) setConfigurationData:(NSString *)data {
    static RegEx conffile_r("'(.*)' '(.*)' ([01]) ([01])");

    if (!conffile_r(data)) {
        lprintf("E:invalid conffile\n");
        return;
    }

    NSString *ofile = conffile_r[1];
    //NSString *nfile = conffile_r[2];

    UIAlertView *alert = [[[UIAlertView alloc]
        initWithTitle:UCLocalize("CONFIGURATION_UPGRADE")
        message:[NSString stringWithFormat:@"%@\n\n%@", UCLocalize("CONFIGURATION_UPGRADE_EX"), ofile]
        delegate:self
        cancelButtonTitle:UCLocalize("KEEP_OLD_COPY")
        otherButtonTitles:
            UCLocalize("ACCEPT_NEW_COPY"),
            // XXX: UCLocalize("SEE_WHAT_CHANGED"),
        nil
    ] autorelease];

    [alert setContext:@"conffile"];
    [alert setNumberOfRows:2];
    [alert show];
}

- (void) addStashController {
    [self lockSuspend];
    stash_ = [[[StashController alloc] init] autorelease];
    [window_ addSubview:[stash_ view]];
}

- (void) removeStashController {
    [[stash_ view] removeFromSuperview];
    stash_ = nil;
    [self unlockSuspend];
}

- (void) stash {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    UpdateExternalStatus(1);
    [self yieldToSelector:@selector(system:) withObject:@"/usr/libexec/cydia/cydo /usr/libexec/cydia/free.sh"];
    UpdateExternalStatus(0);

    [self removeStashController];
    [self reloadSpringBoard];
}

- (void) applicationDidFinishLaunching:(id)unused {
    [super applicationDidFinishLaunching:unused];
    [CyteWebViewController _initialize];

    [BridgedHosts_ addObject:[[NSURL URLWithString:CydiaURL(@"")] host]];

    [NSURLProtocol registerClass:[CydiaURLProtocol class]];

    // this would disallow http{,s} URLs from accessing this data
    //[WebView registerURLSchemeAsLocal:@"cydia"];

    Font12_ = [UIFont systemFontOfSize:12];
    Font12Bold_ = [UIFont boldSystemFontOfSize:12];
    Font14_ = [UIFont systemFontOfSize:14];
    Font18_ = [UIFont systemFontOfSize:18];
    Font18Bold_ = [UIFont boldSystemFontOfSize:18];
    Font22Bold_ = [UIFont boldSystemFontOfSize:22];

    essential_ = [NSMutableArray arrayWithCapacity:4];
    broken_ = [NSMutableArray arrayWithCapacity:4];

    // XXX: I really need this thing... like, seriously... I'm sorry
    appcache_ = [[[AppCacheController alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/appcache/", UI_]]] autorelease];
    [appcache_ reloadData];

    window_ = [[[CyteWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [window_ orderFront:self];
    [window_ makeKey:self];
    [window_ setHidden:NO];

    if (access("/.cydia_no_stash", F_OK) == 0);
    else {

    if (false) stash: {
        [self addStashController];
        // XXX: this would be much cleaner as a yieldToSelector:
        // that way the removeStashController could happen right here inline
        // we also could no longer require the useless stash_ field anymore
        [self performSelector:@selector(stash) withObject:nil afterDelay:0];
        return;
    }

    struct stat root;
    int error(stat("/", &root));
    _assert(error != -1);

    #define Stash_(path) do { \
        struct stat folder; \
        int error(lstat((path), &folder)); \
        if (error != -1 && ( \
            folder.st_dev == root.st_dev && \
            S_ISDIR(folder.st_mode) \
        ) || error == -1 && ( \
            errno == ENOENT || \
            errno == ENOTDIR \
        )) goto stash; \
    } while (false)

    Stash_("/Applications");
    Stash_("/Library/Ringtones");
    Stash_("/Library/Wallpaper");
    //Stash_("/usr/bin");
    Stash_("/usr/include");
    Stash_("/usr/share");
    //Stash_("/var/lib");

    }

    database_ = [Database sharedInstance];
    [database_ setDelegate:self];

    [window_ setUserInteractionEnabled:NO];

    tabbar_ = [[[CydiaTabBarController alloc] initWithDatabase:database_] autorelease];

    [tabbar_ addViewControllers:nil,
        @"Cydia", @"home.png", @"home7.png", @"home7s.png",
        UCLocalize("SOURCES"), @"install.png", @"install7.png", @"install7s.png",
        UCLocalize("CHANGES"), @"changes.png", @"changes7.png", @"changes7s.png",
        UCLocalize("INSTALLED"), @"manage.png", @"manage7.png", @"manage7s.png",
        UCLocalize("SEARCH"), @"search.png", @"search7.png", @"search7s.png",
    nil];

    [tabbar_ setUpdateDelegate:self];

    CydiaLoadingViewController *loading([[[CydiaLoadingViewController alloc] init] autorelease]);
    UINavigationController *navigation([[[UINavigationController alloc] init] autorelease]);
    [navigation setViewControllers:[NSArray arrayWithObject:loading]];

    emulated_ = [[[CyteTabBarController alloc] init] autorelease];
    [emulated_ setViewControllers:[NSArray arrayWithObject:navigation]];
    [emulated_ setSelectedIndex:0];

    if ([emulated_ respondsToSelector:@selector(concealTabBarSelection)])
        [emulated_ concealTabBarSelection];

    [window_ setRootViewController:emulated_];

    [self performSelector:@selector(loadData) withObject:nil afterDelay:0];
_trace();
}

- (NSArray *) defaultStartPages {
    NSMutableArray *standard = [NSMutableArray array];
    [standard addObject:[NSArray arrayWithObject:@"cydia://home"]];
    [standard addObject:[NSArray arrayWithObject:@"cydia://sources"]];
    [standard addObject:[NSArray arrayWithObject:@"cydia://changes"]];
    [standard addObject:[NSArray arrayWithObject:@"cydia://installed"]];
    [standard addObject:[NSArray arrayWithObject:@"cydia://search"]];
    return standard;
}

- (void) loadData {
_trace();
    if ([emulated_ modalViewController] != nil)
        [emulated_ dismissModalViewControllerAnimated:YES];
    [window_ setUserInteractionEnabled:NO];

    [self reloadDataWithInvocation:nil];
    [self refreshIfPossible];
    [self disemulate];

    NSDictionary *state([NSDictionary dictionaryWithContentsOfFile:@ SavedState_]);

    int savedIndex = [[state objectForKey:@"InterfaceIndex"] intValue];
    NSArray *saved = [[[state objectForKey:@"InterfaceState"] mutableCopy] autorelease];
    int standardIndex = 0;
    NSArray *standard = [self defaultStartPages];

    BOOL valid = YES;

    if (saved == nil)
        valid = NO;

    NSDate *closed = [state objectForKey:@"LastClosed"];
    if (valid && closed != nil) {
        NSTimeInterval interval([closed timeIntervalSinceNow]);
        if (interval <= -(30*60))
            valid = NO;
    }

    if (valid && [saved count] != [standard count])
        valid = NO;

    if (valid) {
        for (unsigned int i = 0; i < [standard count]; i++) {
            NSArray *std = [standard objectAtIndex:i], *sav = [saved objectAtIndex:i];
            // XXX: The "hasPrefix" sanity check here could be, in theory, fooled,
            //      but it's good enough for now.
            if ([sav count] == 0 || ![[sav objectAtIndex:0] hasPrefix:[std objectAtIndex:0]]) {
                valid = NO;
                break;
            }
        }
    }

    NSArray *items = nil;
    if (valid) {
        [tabbar_ setSelectedIndex:savedIndex];
        items = saved;
    } else {
        [tabbar_ setSelectedIndex:standardIndex];
        items = standard;
    }

    for (unsigned int tab = 0; tab < [[tabbar_ viewControllers] count]; tab++) {
        NSArray *stack = [items objectAtIndex:tab];
        UINavigationController *navigation = [[tabbar_ viewControllers] objectAtIndex:tab];
        NSMutableArray *current = [NSMutableArray array];

        for (unsigned int nav = 0; nav < [stack count]; nav++) {
            NSString *addr = [stack objectAtIndex:nav];
            NSURL *url = [NSURL URLWithString:addr];
            CyteViewController *page = [self pageForURL:url forExternal:NO withReferrer:nil];
            if (page != nil)
                [current addObject:page];
        }

        [navigation setViewControllers:current];
    }

    // (Try to) show the startup URL.
    if (starturl_ != nil) {
        [self openCydiaURL:starturl_ forExternal:YES];
        starturl_ = nil;
    }
}

- (void) showActionSheet:(UIActionSheet *)sheet fromItem:(UIBarButtonItem *)item {
    if (!IsWildcat_) {
       [sheet addButtonWithTitle:UCLocalize("CANCEL")];
       [sheet setCancelButtonIndex:[sheet numberOfButtons] - 1];
    }

    if (item != nil && IsWildcat_) {
        [sheet showFromBarButtonItem:item animated:YES];
    } else {
        [sheet showInView:window_];
    }
}

- (void) addProgressEvent:(CydiaProgressEvent *)event forTask:(NSString *)task {
    id<ProgressDelegate> progress([database_ progressDelegate] ?: [self invokeNewProgress:nil forController:nil withTitle:task]);
    [progress setTitle:task];
    [progress addProgressEvent:event];
}

- (void) addProgressEventForTask:(NSArray *)data {
    CydiaProgressEvent *event([data objectAtIndex:0]);
    NSString *task([data count] < 2 ? nil : [data objectAtIndex:1]);
    [self addProgressEvent:event forTask:task];
}

- (void) addProgressEventOnMainThread:(CydiaProgressEvent *)event forTask:(NSString *)task {
    [self performSelectorOnMainThread:@selector(addProgressEventForTask:) withObject:[NSArray arrayWithObjects:event, task, nil] waitUntilDone:YES];
}

@end

/*IMP alloc_;
id Alloc_(id self, SEL selector) {
    id object = alloc_(self, selector);
    lprintf("[%s]A-%p\n", self->isa->name, object);
    return object;
}*/

/*IMP dealloc_;
id Dealloc_(id self, SEL selector) {
    id object = dealloc_(self, selector);
    lprintf("[%s]D-%p\n", self->isa->name, object);
    return object;
}*/

static NSMutableDictionary *AutoreleaseDeepMutableCopyOfDictionary(CFTypeRef type) {
    if (type == NULL)
        return nil;
    if (CFGetTypeID(type) != CFDictionaryGetTypeID())
        return nil;
    CFTypeRef copy(CFPropertyListCreateDeepCopy(kCFAllocatorDefault, type, kCFPropertyListMutableContainers));
    CFRelease(type);
    return [(NSMutableDictionary *) copy autorelease];
}

int main_store(int, char *argv[]);

int main(int argc, char *argv[]) {
#ifdef __arm64__
    const char *argv0(argv[0]);
    if (const char *slash = strrchr(argv0, '/'))
        argv0 = slash + 1;
    if (false);
    else if (!strcmp(argv0, "store"))
        return main_store(argc, argv);
#endif

    int fd(open("/tmp/cydia.log", O_WRONLY | O_APPEND | O_CREAT, 0644));
    dup2(fd, 2);
    close(fd);

    NSAutoreleasePool *pool([[NSAutoreleasePool alloc] init]);

    _trace();

    CyteInitialize([NSString stringWithFormat:@"Cydia/%@", Cydia_]);
    UpdateExternalStatus(0);

    SessionData_ = [NSMutableDictionary dictionaryWithCapacity:4];
    BridgedHosts_ = [NSMutableSet setWithCapacity:4];
    InsecureHosts_ = [NSMutableSet setWithCapacity:4];

    UI_ = CydiaURL([NSString stringWithFormat:@"ui/ios~%@/1.1", IsWildcat_ ? @"ipad" : @"iphone"]);
    PackageName = reinterpret_cast<CYString &(*)(Package *, SEL)>(method_getImplementation(class_getInstanceMethod([Package class], @selector(cyname))));

    /* Set Locale {{{ */
    Locale_ = CFLocaleCopyCurrent();
    Languages_ = [NSLocale preferredLanguages];

    std::string languages;
    const char *translation(NULL);

    // XXX: this isn't really a language, but this is compatible with older Cydia builds
    if (Locale_ != NULL)
        if (const char *language = [(NSString *) CFLocaleGetIdentifier(Locale_) UTF8String]) {
            RegEx pattern("([a-z][a-z])(?:-[A-Za-z]*)?(_[A-Z][A-Z])?");
            if (pattern(language)) {
                translation = strdup([pattern->*@"%1$@%2$@" UTF8String]);
                languages += translation;
                languages += ",";
            }
        }

    if (Languages_ != nil)
        for (NSString *locale : Languages_) {
            auto components([NSLocale componentsFromLocaleIdentifier:locale]);
            NSString *language([components objectForKey:(id)kCFLocaleLanguageCode]);
            if (NSString *script = [components objectForKey:(id)kCFLocaleScriptCode])
                language = [NSString stringWithFormat:@"%@-%@", language, script];
            languages += [language UTF8String];
            languages += ",";
        }

    languages += "en";
    NSLog(@"Setting Language: [%s] %s", translation, languages.c_str());
    /* }}} */
    /* Index Collation {{{ */
    if (Class $UILocalizedIndexedCollation = objc_getClass("UILocalizedIndexedCollation")) { @try {
        NSBundle *bundle([NSBundle bundleForClass:$UILocalizedIndexedCollation]);
        NSString *path([bundle pathForResource:@"UITableViewLocalizedSectionIndex" ofType:@"plist"]);
        //path = @"/System/Library/Frameworks/UIKit.framework/.lproj/UITableViewLocalizedSectionIndex.plist";
        NSDictionary *dictionary([NSDictionary dictionaryWithContentsOfFile:path]);
        _H<UILocalizedIndexedCollation> collation([[[$UILocalizedIndexedCollation alloc] initWithDictionary:dictionary] autorelease]);

        CollationLocale_ = MSHookIvar<NSLocale *>(collation, "_locale");

        if (kCFCoreFoundationVersionNumber >= 800 && [[CollationLocale_ localeIdentifier] isEqualToString:@"zh@collation=stroke"]) {
            CollationThumbs_ = [NSArray arrayWithObjects:@"1",@"•",@"4",@"•",@"7",@"•",@"10",@"•",@"13",@"•",@"16",@"•",@"19",@"A",@"•",@"E",@"•",@"I",@"•",@"M",@"•",@"R",@"•",@"V",@"•",@"Z",@"#",nil];
            for (NSInteger offset : (NSInteger[]) {0,1,3,4,6,7,9,10,12,13,15,16,18,25,26,29,30,33,34,37,38,42,43,46,47,50,51})
                CollationOffset_.push_back(offset);
            CollationTitles_ = [NSArray arrayWithObjects:@"1 畫",@"2 畫",@"3 畫",@"4 畫",@"5 畫",@"6 畫",@"7 畫",@"8 畫",@"9 畫",@"10 畫",@"11 畫",@"12 畫",@"13 畫",@"14 畫",@"15 畫",@"16 畫",@"17 畫",@"18 畫",@"19 畫",@"20 畫",@"21 畫",@"22 畫",@"23 畫",@"24 畫",@"25 畫以上",@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
            CollationStarts_ = [NSArray arrayWithObjects:@"一",@"丁",@"丈",@"不",@"且",@"丞",@"串",@"並",@"亭",@"乘",@"乾",@"傀",@"亂",@"僎",@"僵",@"儐",@"償",@"叢",@"儳",@"嚴",@"儷",@"儻",@"囌",@"囑",@"廳",@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"ʒ",nil];
        } else {

        CollationThumbs_ = [collation sectionIndexTitles];
        for (size_t index(0), end([CollationThumbs_ count]); index != end; ++index)
            CollationOffset_.push_back([collation sectionForSectionIndexTitleAtIndex:index]);

        CollationTitles_ = [collation sectionTitles];
        CollationStarts_ = MSHookIvar<NSArray *>(collation, "_sectionStartStrings");

        NSString *&transform(MSHookIvar<NSString *>(collation, "_transform"));
        if (&transform != NULL && transform != nil) {
            /*if ([collation respondsToSelector:@selector(transformedCollationStringForString:)])
                CollationModify_ = [=](NSString *value) { return [collation transformedCollationStringForString:value]; };*/
            const UChar *uid(reinterpret_cast<const UChar *>([transform cStringUsingEncoding:NSUnicodeStringEncoding]));
            UErrorCode code(U_ZERO_ERROR);
            CollationTransl_ = utrans_openU(uid, -1, UTRANS_FORWARD, NULL, 0, NULL, &code);
            if (!U_SUCCESS(code))
                NSLog(@"%s", u_errorName(code));
        }

        }
    } @catch (NSException *e) {
        NSLog(@"%@", e);
        goto hard;
    } } else hard: {
        CollationLocale_ = [[[NSLocale alloc] initWithLocaleIdentifier:@"en@collation=dictionary"] autorelease];

        CollationThumbs_ = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
        for (NSInteger offset(0); offset != 28; ++offset)
            CollationOffset_.push_back(offset);

        CollationTitles_ = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z",@"#",nil];
        CollationStarts_ = [NSArray arrayWithObjects:@"a",@"b",@"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",@"p",@"q",@"r",@"s",@"t",@"u",@"v",@"w",@"x",@"y",@"z",@"ʒ",nil];
    }
    /* }}} */

    App_ = [[NSBundle mainBundle] bundlePath];
    Advanced_ = YES;

    Cache_ = [[NSString stringWithFormat:@"%@/Library/Caches/com.saurik.Cydia", @"/var/mobile"] retain];
    mkdir([Cache_ UTF8String], 0755);

    /*Method alloc = class_getClassMethod([NSObject class], @selector(alloc));
    alloc_ = alloc->method_imp;
    alloc->method_imp = (IMP) &Alloc_;*/

    /*Method dealloc = class_getClassMethod([NSObject class], @selector(dealloc));
    dealloc_ = dealloc->method_imp;
    dealloc->method_imp = (IMP) &Dealloc_;*/

    void *gestalt(dlopen("/usr/lib/libMobileGestalt.dylib", RTLD_GLOBAL | RTLD_LAZY));
    $MGCopyAnswer = reinterpret_cast<CFStringRef (*)(CFStringRef)>(dlsym(gestalt, "MGCopyAnswer"));
    UniqueID_ = UniqueIdentifier([UIDevice currentDevice]);

    /* System Information {{{ */
    size_t size;

    int maxproc;
    size = sizeof(maxproc);
    if (sysctlbyname("kern.maxproc", &maxproc, &size, NULL, 0) == -1)
        perror("sysctlbyname(\"kern.maxproc\", ?)");
    else if (maxproc < 64) {
        maxproc = 64;
        if (sysctlbyname("kern.maxproc", NULL, NULL, &maxproc, sizeof(maxproc)) == -1)
            perror("sysctlbyname(\"kern.maxproc\", #)");
    }
    /* }}} */
    /* Load Database {{{ */
    SectionMap_ = [[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Sections" ofType:@"plist"]] autorelease];

    _trace();
    mkdir("/var/mobile/Library/Cydia", 0755);
    MetaFile_.Open("/var/mobile/Library/Cydia/metadata.cb0");
    _trace();

    Values_ = AutoreleaseDeepMutableCopyOfDictionary(CFPreferencesCopyAppValue(CFSTR("CydiaValues"), CFSTR("com.saurik.Cydia")));
    Sections_ = AutoreleaseDeepMutableCopyOfDictionary(CFPreferencesCopyAppValue(CFSTR("CydiaSections"), CFSTR("com.saurik.Cydia")));
    Sources_ = AutoreleaseDeepMutableCopyOfDictionary(CFPreferencesCopyAppValue(CFSTR("CydiaSources"), CFSTR("com.saurik.Cydia")));
    Version_ = [(NSNumber *) CFPreferencesCopyAppValue(CFSTR("CydiaVersion"), CFSTR("com.saurik.Cydia")) autorelease];

    _trace();
    NSDictionary *metadata([[[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/lib/cydia/metadata.plist"] autorelease]);

    if (Values_ == nil)
        Values_ = [metadata objectForKey:@"Values"];
    if (Values_ == nil)
        Values_ = [[[NSMutableDictionary alloc] initWithCapacity:4] autorelease];

    if (Sections_ == nil)
        Sections_ = [metadata objectForKey:@"Sections"];
    if (Sections_ == nil)
        Sections_ = [[[NSMutableDictionary alloc] initWithCapacity:32] autorelease];

    if (Sources_ == nil)
        Sources_ = [metadata objectForKey:@"Sources"];
    if (Sources_ == nil)
        Sources_ = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];

    // XXX: this wrong, but in a way that doesn't matter :/
    if (Version_ == nil)
        Version_ = [metadata objectForKey:@"Version"];
    if (Version_ == nil)
        Version_ = [NSNumber numberWithUnsignedInt:0];

    if (NSDictionary *packages = [metadata objectForKey:@"Packages"]) {
        bool fail(false);
        CFDictionaryApplyFunction((CFDictionaryRef) packages, &PackageImport, &fail);
        _trace();
        if (fail)
            NSLog(@"unable to import package preferences... from 2010? oh well :/");
    }

    if ([Version_ unsignedIntValue] == 0) {
        CydiaAddSource(@"http://apt.thebigboss.org/repofiles/cydia/", @"stable", [NSMutableArray arrayWithObject:@"main"]);
        CydiaAddSource(@"http://apt.modmyi.com/", @"stable", [NSMutableArray arrayWithObject:@"main"]);
        CydiaAddSource(@"http://cydia.zodttd.com/repo/cydia/", @"stable", [NSMutableArray arrayWithObject:@"main"]);
        CydiaAddSource(@"http://repo666.ultrasn0w.com/", @"./");

        Version_ = [NSNumber numberWithUnsignedInt:1];

        if (NSMutableDictionary *cache = [NSMutableDictionary dictionaryWithContentsOfFile:@ CacheState_]) {
            [cache removeObjectForKey:@"LastUpdate"];
            [cache writeToFile:@ CacheState_ atomically:YES];
        }
    }

    _H<NSMutableArray> broken([NSMutableArray array]);
    for (NSString *key in (id) Sources_)
        if ([key rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"# "]].location != NSNotFound || ![([[Sources_ objectForKey:key] objectForKey:@"URI"] ?: @"/") hasSuffix:@"/"])
            [broken addObject:key];
    if ([broken count] != 0)
        for (NSString *key in (id) broken)
            [Sources_ removeObjectForKey:key];
    broken = nil;

    SaveConfig(nil);
    system("/usr/libexec/cydia/cydo /bin/rm -f /var/lib/cydia/metadata.plist");
    /* }}} */

    Finishes_ = [NSArray arrayWithObjects:@"return", @"reopen", @"restart", @"reload", @"reboot", nil];

    if (kCFCoreFoundationVersionNumber > 1000)
        system("/usr/libexec/cydia/cydo /usr/libexec/cydia/setnsfpn /var/lib");

    int version([[NSString stringWithContentsOfFile:@"/var/lib/cydia/firmware.ver"] intValue]);

    if (access("/User", F_OK) != 0 || version != 6) {
        _trace();
        system("/usr/libexec/cydia/cydo /usr/libexec/cydia/firmware.sh");
        _trace();
    }

    if (access("/tmp/cydia.chk", F_OK) == 0) {
        if (unlink([Cache("pkgcache.bin") UTF8String]) == -1)
            _assert(errno == ENOENT);
        if (unlink([Cache("srcpkgcache.bin") UTF8String]) == -1)
            _assert(errno == ENOENT);
    }

    system("/usr/libexec/cydia/cydo /bin/ln -sf /var/mobile/Library/Caches/com.saurik.Cydia/sources.list /etc/apt/sources.list.d/cydia.list");

    /* APT Initialization {{{ */
    _assert(pkgInitConfig(*_config));
    _assert(pkgInitSystem(*_config, _system));

    _config->Set("Acquire::AllowInsecureRepositories", true);
    _config->Set("Acquire::Check-Valid-Until", false);
    _config->Set("Dir::Bin::Methods::store", "/Applications/Cydia.app/store");

    _config->Set("pkgCacheGen::ForceEssential", "");

    if (translation != NULL)
        _config->Set("APT::Acquire::Translation", translation);
    _config->Set("Acquire::Languages", languages);

    // XXX: this timeout might be important :(
    //_config->Set("Acquire::http::Timeout", 15);

    int64_t usermem(0);
    size = sizeof(usermem);
    if (sysctlbyname("hw.usermem", &usermem, &size, NULL, 0) == -1)
        usermem = 0;
    _config->Set("Acquire::http::MaxParallel", usermem >= 384 * 1024 * 1024 ? 16 : 3);

    mkdir([Cache("archives") UTF8String], 0755);
    mkdir([Cache("archives/partial") UTF8String], 0755);
    _config->Set("Dir::Cache", [Cache_ UTF8String]);

    symlink("/var/lib/apt/extended_states", [Cache("extended_states") UTF8String]);
    _config->Set("Dir::State", [Cache_ UTF8String]);

    mkdir([Cache("lists") UTF8String], 0755);
    mkdir([Cache("lists/partial") UTF8String], 0755);
    mkdir([Cache("periodic") UTF8String], 0755);
    _config->Set("Dir::State::Lists", [Cache("lists") UTF8String]);

    std::string logs("/var/mobile/Library/Logs/Cydia");
    mkdir(logs.c_str(), 0755);
    _config->Set("Dir::Log", logs);

    _config->Set("Dir::Bin::dpkg", "/usr/libexec/cydia/cydo");
    /* }}} */
    /* Color Choices {{{ */
    space_ = CGColorSpaceCreateDeviceRGB();

    Blue_.Set(space_, 0.2, 0.2, 1.0, 1.0);
    Blueish_.Set(space_, 0x19/255.f, 0x32/255.f, 0x50/255.f, 1.0);
    Black_.Set(space_, 0.0, 0.0, 0.0, 1.0);
    Folder_.Set(space_, 0x8e/255.f, 0x8e/255.f, 0x93/255.f, 1.0);
    Off_.Set(space_, 0.9, 0.9, 0.9, 1.0);
    White_.Set(space_, 1.0, 1.0, 1.0, 1.0);
    Gray_.Set(space_, 0.4, 0.4, 0.4, 1.0);
    Green_.Set(space_, 0.0, 0.5, 0.0, 1.0);
    Purple_.Set(space_, 0.0, 0.0, 0.7, 1.0);
    Purplish_.Set(space_, 0.4, 0.4, 0.8, 1.0);

    InstallingColor_ = [UIColor colorWithRed:0.88f green:1.00f blue:0.88f alpha:1.00f];
    RemovingColor_ = [UIColor colorWithRed:1.00f green:0.88f blue:0.88f alpha:1.00f];
    /* }}}*/
    /* UIKit Configuration {{{ */
    // XXX: I have a feeling this was important
    //UIKeyboardDisableAutomaticAppearance();
    /* }}} */

    $SBSSetInterceptsMenuButtonForever = reinterpret_cast<void (*)(bool)>(dlsym(RTLD_DEFAULT, "SBSSetInterceptsMenuButtonForever"));
    $SBSCopyIconImagePNGDataForDisplayIdentifier = reinterpret_cast<NSData *(*)(NSString *)>(dlsym(RTLD_DEFAULT, "SBSCopyIconImagePNGDataForDisplayIdentifier"));

    const char *symbol(kCFCoreFoundationVersionNumber >= 800 ? "MGGetBoolAnswer" : "GSSystemHasCapability");
    BOOL (*GSSystemHasCapability)(CFStringRef) = reinterpret_cast<BOOL (*)(CFStringRef)>(dlsym(RTLD_DEFAULT, symbol));
    bool fast = GSSystemHasCapability != NULL && GSSystemHasCapability(CFSTR("armv7"));

    PulseInterval_ = fast ? 50000 : 500000;

    Colon_ = UCLocalize("COLON_DELIMITED");
    Elision_ = UCLocalize("ELISION");
    Error_ = UCLocalize("ERROR");
    Warning_ = UCLocalize("WARNING");

    _trace();
    int value(UIApplicationMain(argc, argv, @"Cydia", @"Cydia"));

    CGColorSpaceRelease(space_);
    CFRelease(Locale_);

    [pool release];
    return value;
}
