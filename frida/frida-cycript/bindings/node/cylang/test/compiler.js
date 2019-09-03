const cylang = require('..');
const should = require('should');

describe('Compiler', function () {
  it('should compile Cylang to JavaScript', function () {
    cylang.compile('extern "C" int puts(char const*)').should.equal('puts=int.functionWith(char.constant().pointerTo())(dlsym(RTLD_DEFAULT,"puts"))');
  });

  it('should throw on syntax error', function () {
    (function () {
      cylang.compile('function) {}')
    }).should.throw(/^syntax error, unexpected \)/);
  });

  it('should support strict mode', function () {
    (function () {
      cylang.compile('f()', { strict: true })
    }).should.throw(/^warning, automatic semi-colon insertion required/);
  });

  it('should support prettified output', function () {
    const code = `(function (name) {
      console.log("Hello: " + name);
    })`;
    const compactOutput = cylang.compile(code, { pretty: false });
    const prettyOutput = cylang.compile(code, { pretty: true });
    prettyOutput.should.not.equal(compactOutput);
  });
});
