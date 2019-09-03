/* Cydia Substrate - Powerful Code Insertion Platform
 * Copyright (C) 2008-2015  Jay Freeman (saurik)
 * Copyright (C)      2016  NowSecure <oleavr@nowsecure.com>
*/

(function(exports) {

var images = {};
var slice = Array.prototype.slice;

exports.getImageByName = function(name) {
    var image = (typedef void *)(Module.findBaseAddress(name));
    if (image === null)
        return null;
    images[image] = name;
    return image;
};

exports.findSymbol = function(image, name) {
    var imageName = images[image];
    if (imageName === undefined)
        return null;
    if (name[0] === '_')
        name = name.substr(1);
    return (typedef void *)(Module.findExportByName(imageName, name));
};

exports.hookFunction = function(func, hook, old) {
    var type = typeid(func);

    if (!(old == null || typeof old === "undefined")) {
        *old = function() { return func.apply(null, arguments); };
    }

    Interceptor.replace(func.valueOf(), type(hook));
};

exports.hookMessage = function(isa, sel, imp, old) {
    var method = sel.method(isa);
    var type = sel.type(isa);

    if (!(old == null || typeof old === "undefined")) {
        var oldImpl = type(method.implementation);
        *old = function() { return oldImpl.apply(null, [this, sel].concat(slice.call(arguments))); };
    }

    method.implementation = type(function(self, sel) { return imp.apply(self, slice.call(arguments, 2)); });
};

})(exports);
