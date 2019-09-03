// MIT - Copyright NowSecure 2016 - oleavr@nowsecure.com
const mjolner = require('mjolner');

const RTLD_GLOBAL = 0x8;
const RTLD_LAZY = 0x1;

const _dlopen = new NativeFunction(Module.getExportByName(null, 'dlopen'), 'pointer', ['pointer', 'int']);

let handlerInstalled = false;
const modules = {};

mjolner.register();

function onEvalRequest(message) {
  if (ObjC.available)
    ObjC.schedule(ObjC.mainQueue, performRequest);
  else
    performRequest();

  function performRequest() {
    ensureHandlerInstalled();

    let result;
    try {
      const rawResult = (1, eval)(message.payload);
      global._ = rawResult;
      if (rawResult !== undefined)
        result = mjolner.toCYON(rawResult);
      else
        result = null;
    } catch (e) {
      result = 'throw new ' + e.name + '("' + e.message + '")';
    }
    send(['eval:result', result]);
  }

  recv('eval', onEvalRequest);
}
recv('eval', onEvalRequest);

function ensureHandlerInstalled() {
  if (handlerInstalled)
    return;
  handlerInstalled = true;

  Script.setGlobalAccessHandler({
    enumerate() {
      return [];
    },
    get(property) {
      let result = mjolner.lookup(property);
      if (result !== null)
        return result;

      result = request('lookup', property);
      if (result !== null)
        return mjolner.add(property, result);
    }
  });
}

Object.defineProperty(global, 'cy$complete', {
  enumerable: false,
  writable: false,
  value(prefix) {
    return request('complete', prefix).concat(mjolner.complete(prefix));
  }
});

global.require = function (name) {
  const requester = (this && this !== global) ? this : null;
  return requireModule(name, requester);
};

global.require.resolve = function (name) {
  const requester = (this && this !== global.require) ? this : null;
  return resolveModule(name, requester).path;
};

function requireModule(name, requester) {
  if (Process.platform === 'darwin' && name.indexOf('/') === -1) {
    if (!dlopen(`/System/Library/Frameworks/${name}.framework/${name}`, RTLD_GLOBAL | RTLD_LAZY).isNull())
      return;
    else if (!dlopen(`/System/Library/PrivateFrameworks/${name}.framework/${name}`, RTLD_GLOBAL | RTLD_LAZY).isNull())
      return;
  }

  const details = resolveModule(name, requester);
  const path = details.path;
  let module = modules[path];
  if (module === undefined) {
    let spec = details.module;
    if (spec === null) {
      spec = request('require:read', path);
      if (spec === null)
        throw new Error(`Cannot find module '${name}'`);
    }

    const {dirname, code} = spec;
    if (code !== undefined) {
      const exp = {};
      const instance = {
        id: path,
        exports: exp,
        parent: requester,
        children: [],
        dirname: dirname,
        filename: path,
        loaded: false,
      };
      const load = (1, eval)(code);
      load(exp, global.require.bind(instance), instance, path, dirname);
      instance.loaded = true;
      module = {
        value: instance.exports,
        instance: instance
      };
    } else {
      const data = JSON.parse(spec.data);
      module = {
        value: data,
        instance: null
      };
    }

    modules[path] = module;
  }

  if (requester !== null) {
    const instance = module.instance;
    if (instance !== null) {
      const children = requester.children;
      if (children.indexOf(instance) === -1)
        children.push(instance);
    }
  }

  return module.value;
}

function resolveModule(name, requester) {
  const details = request('require:resolve', {
    name: name,
    from: (requester !== null) ? requester.dirname : null
  });
  if (details === null)
    throw new Error(`Cannot find module '${name}'`);
  return details;
}

function request(type, param) {
  const result = [null];
  const operation = recv(type + ':reply', message => {
    result[0] = message.payload;
  });
  send([type, param]);
  operation.wait();
  return result[0];
}

function dlopen(library, mode) {
  const path = Memory.allocUtf8String(library);
  return _dlopen(path, mode);
}
