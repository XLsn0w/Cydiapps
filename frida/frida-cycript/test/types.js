const cycript = require('bindings')('cytest_binding');
const should = require('should');

describe('Types', function () {
  before(function () {
    cycript.attach(null, null, null);
    // cycript.attach('f4c5ba319e6df557eeb1f3736904585801a2dfe7', null, 'YouTube');
  });

  it('should support primitive types', function () {
    cycript.execute('char').should.equal('(typedef char)');
    cycript.execute('char.pointerTo()').should.equal('(typedef char *)');
    cycript.execute('char.constant()').should.equal('(typedef char const)');
    cycript.execute('char.constant().pointerTo()').should.equal('(typedef char const*)');
  });

  it('should support `new` semantics', function () {
    cycript.execute('int(5)').should.equal('5');
    cycript.execute('new int(5)').should.equal('&5');
    cycript.execute('*_').should.equal('5');
  });

  it('should support pretty-printing function pointers', function () {
    cycript.execute('dlopen').should.equal('(extern "C" void *dlopen(char const*, int))');
    cycript.execute('typeid(dlopen)').should.equal('(typedef void *(char const*, int))');
    cycript.execute('dlsym').should.equal('(extern "C" void *dlsym(void *, char *))');
  });

  it('should support pointer casting', function () {
    cycript.execute('(typedef void*)(1)').should.equal('(typedef void*)(0x1)');
    cycript.execute('(typedef void*)("0x1234")').should.equal('(typedef void*)(0x1234)');
  });

  it('should support declaring functions', function () {
    cycript.execute('extern "C" int puts(const char *s)').should.equal('(extern "C" int puts(char const*))');
    cycript.execute('puts("Hello")').should.equal('10');
  });

  it('should source types from the database', function () {
    cycript.execute('fopen').should.equal('(extern "C" struct __sFILE *fopen(char const*, char const*))');
    cycript.execute('malloc(7)').should.match(/^\(typedef void\*\)\(0x[0-9a-f]+\)$/);
    should(cycript.execute('free(_)')).equal(null);
    cycript.execute('free()').should.equal('throw new Error("insufficient number of arguments to ffi function")');
    cycript.execute('free(1, 2)').should.equal('throw new Error("exorbitant number of arguments to ffi function")');
    cycript.execute('dlopen("/does/not/exist", RTLD_NOLOAD)').should.equal('null');
    cycript.execute('(struct CGSize)').should.equal('(typedef struct {\n    double width;\n    double height;\n})');

    /*
     * TODO: handle varargs:
     * cycript.execute('open').should.equal('(extern "C" int open(char const*, int, ...))');
     */
  });

  it('should support structs', function () {
    cycript.execute('infoPtr = new Dl_info').should.equal('&{dli_fname:null,dli_fbase:null,dli_sname:null,dli_saddr:null}');
    cycript.execute('info = *infoPtr;').should.equal('{dli_fname:null,dli_fbase:null,dli_sname:null,dli_saddr:null}');
    cycript.execute('infoPtr->dli_fbase = 0x4000;').should.equal('16384');
    cycript.execute('infoPtr->dli_fbase').should.equal('(typedef void*)(0x4000)');
    cycript.execute('infoPtr').should.equal('&{dli_fname:null,dli_fbase:(typedef void*)(0x4000),dli_sname:null,dli_saddr:null}');
    cycript.execute('info').should.equal('{dli_fname:null,dli_fbase:(typedef void*)(0x4000),dli_sname:null,dli_saddr:null}');
    cycript.execute('name = (typedef char *)("Hello")').should.equal('&"Hello"');
    cycript.execute('infoPtr->dli_fname = name').should.equal('&"Hello"');
    cycript.execute('infoPtr->dli_fname').should.equal('&"Hello"');
    cycript.execute('infoPtr').should.equal('&{dli_fname:&"Hello",dli_fbase:(typedef void*)(0x4000),dli_sname:null,dli_saddr:null}');
  });

  it('should support arrays', function () {
    cycript.execute('elements = (typedef int[3])([13, 37, 42])').should.equal('[13,37,42]');
    cycript.execute('elements instanceof Array').should.equal('true');
    cycript.execute('p = (typedef int *)(elements)').should.equal('&13');
    cycript.execute('elements[0] = -12').should.equal('-12');
    cycript.execute('elements').should.equal('[-12,37,42]');
  });

  it('should support C strings', function () {
    cycript.execute('s = (typedef char *)("Olé")').should.equal('&"Ol\\xc3\\xa9"');
    cycript.execute('s instanceof String').should.equal('true');
    cycript.execute('*s').should.equal('"O"');
    cycript.execute('s[0]').should.equal('"O"');
    cycript.execute('s[1]').should.equal('"l"');
    cycript.execute('s[2]').should.equal('"\\xc3"');
    cycript.execute('s[3]').should.equal('"\\xa9"');
    cycript.execute('s[4]').should.equal('"\\0"');
    cycript.execute('s.length').should.equal('4');
    cycript.execute('s.indexOf("l")').should.equal('1');
    cycript.execute('s[1] = "n"').should.equal('"n"');
    cycript.execute('s').should.equal('&"On\\xc3\\xa9"');
  });

  it('should support completion of database types', function () {
    cycript.execute('global.cy$complete("mem")').should.containEql('memcpy');
  });

  it('should support Objective-C types', function () {
    cycript.execute('Class').should.equal('(typedef Class)');
  });

  it('should support Objective-C literals', function () {
    cycript.execute('@"hello"').should.equal('@"hello"');
    cycript.execute('@[1,2,3]').should.equal('@[1,2,3]');
    cycript.execute('@{"name":"Joe","age":42}').should.equal('@{"name":"Joe","age":42}');
  });

  it('should keep Objective-C objects alive until GCed', function () {
    cycript.execute('arr = @[1,2,3]').should.equal('@[1,2,3]');
    cycript.execute('arr').should.equal('@[1,2,3]');
  });

  it('should support NSString objects seamlessly', function () {
    cycript.execute('s = @"Hey"').should.equal('@"Hey"');
    cycript.execute('s instanceof String').should.equal('true');
    cycript.execute('"length" in s').should.equal('true');
    cycript.execute('s.length').should.equal('3');
    cycript.execute('"-1" in s').should.equal('false');
    cycript.execute('"0" in s').should.equal('true');
    cycript.execute('"1" in s').should.equal('true');
    cycript.execute('"2" in s').should.equal('true');
    cycript.execute('"3" in s').should.equal('false');
    cycript.execute('s[-1] === undefined').should.equal('true');
    cycript.execute('s[0]').should.equal('@"H"');
    cycript.execute('s[1]').should.equal('@"e"');
    cycript.execute('s[2]').should.equal('@"y"');
    cycript.execute('s[3] === undefined').should.equal('true');
  });

  it('should support NSArray objects seamlessly', function () {
    cycript.execute('arr = @["foo","bar"]').should.equal('@["foo","bar"]');
    cycript.execute('arr instanceof Array').should.equal('true');
    cycript.execute('"length" in arr').should.equal('true');
    cycript.execute('arr.length').should.equal('2');
    cycript.execute('"-1" in arr').should.equal('false');
    cycript.execute('"0" in arr').should.equal('true');
    cycript.execute('"1" in arr').should.equal('true');
    cycript.execute('"2" in arr').should.equal('false');
    cycript.execute('arr[-1] === undefined').should.equal('true');
    cycript.execute('arr[0]').should.equal('@"foo"');
    cycript.execute('arr[1]').should.equal('@"bar"');
    cycript.execute('arr[2] === undefined').should.equal('true');
  });

  it('should support NSDictionary objects seamlessly', function () {
    cycript.execute('dict = @{"name":"Joe","age":42}').should.equal('@{"name":"Joe","age":42}');
    cycript.execute('dict instanceof Object').should.equal('true');
    cycript.execute('dict instanceof Array').should.equal('false');
    cycript.execute('"badger" in dict').should.equal('false');
    cycript.execute('"name" in dict').should.equal('true');
    cycript.execute('"age" in dict').should.equal('true');
    cycript.execute('dict["badger"] === undefined').should.equal('true');
    cycript.execute('dict["name"]').should.equal('@"Joe"');
    cycript.execute('dict["age"]').should.equal('@42');
    cycript.execute('dict.hasOwnProperty("cy$complete")').should.equal('true');
    cycript.execute('dict.cy$complete("name")').should.equal('["name"]');
  });

  it('should support calling a selector', function () {
    cycript.execute('capitalize = @selector(capitalizedString)');
    cycript.execute('capitalize.call(@"hello")').should.equal('@"Hello"');
  });

  it('should support Objective-C completion', function () {
    cycript.execute('global.cy$complete("NSArray")').should.containEql('NSArray');
    cycript.execute('global.cy$complete("NSCopy")').should.containEql('NSCopying');
    cycript.execute('Object.getOwnPropertyNames(object_getClass(NSString).prototype)').should.equal('["cy$complete"]');
    cycript.execute('object_getClass(NSString).prototype.cy$complete("uses")').should.equal('["usesScreenFonts","usesFontLeading"]');
  });

  it('should support symbol lookups', function () {
    cycript.execute(`
      @import com.saurik.substrate.MS

      image = MS.getImageByName("/usr/lib/system/libsystem_malloc.dylib")
    `).should.match(/\(typedef void\*\)\(0x[0-9a-f]+\)/);
    cycript.execute('MS.findSymbol(image, "_malloc")').should.match(/\(typedef void\*\)\(0x[0-9a-f]+\)/);
  });

  it('should support hooking functions', function () {
    cycript.execute(`
      @import com.saurik.substrate.MS

      var oldf = {};
      var log = [];
      MS.hookFunction(fopen, function (path, mode) {
        var file = (*oldf)(path, mode);
        log.push([path.toString(), mode.toString()]);
        return file;
      }, oldf);
    `);
    cycript.execute(`
      fopen("/etc/hosts", "r");
      fopen("/etc/passwd", "r");
      log;
    `).should.equal('[["/etc/hosts","r"],["/etc/passwd","r"]]');
  });

  it('should support swizzling methods', function () {
    cycript.execute(`
      @import com.saurik.substrate.MS

      var oldm = {};
      MS.hookMessage(NSObject, @selector(description), function () {
        return oldm->call(this) + ' (of doom)';
      }, oldm);
      [new NSObject init];
    `).should.match(/#"<NSObject: 0x[0-9a-f]+> \(of doom\)"/);
  });
});
