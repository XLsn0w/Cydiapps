const binding = require('bindings')('cylang_binding');

module.exports = {
  compile: compile
};

function compile(source, options) {
  options = options || {};

  const strict = ('strict' in options) ? options.strict : false;
  const pretty = ('pretty' in options) ? options.pretty : false;

  return binding.compile(source, strict, pretty);
}
