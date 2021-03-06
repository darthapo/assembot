// Generated by CoffeeScript 1.6.1
(function() {
  var defaults, exec, extend, fs, isAlreadyLoaded, loaded_libs, loading_now, localRequire, localResolve, path, pp, tryRequire, tryRequireAll, tryRequireResolve, type, util, validateOptionsCallback, without,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  util = require('util');

  fs = require('fs');

  exec = require('shelljs').exec;

  path = require('path');

  pp = function(obj) {
    return util.puts(util.inspect(obj));
  };

  extend = function(obj) {
    var key, source, value, _i, _len, _ref;
    _ref = Array.prototype.slice.call(arguments, 1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      source = _ref[_i];
      if (source) {
        for (key in source) {
          value = source[key];
          obj[key] = value;
        }
      }
    }
    return obj;
  };

  defaults = function(obj) {
    var key, source, value, _i, _len, _ref;
    _ref = Array.prototype.slice.call(arguments, 1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      source = _ref[_i];
      if (source) {
        for (key in source) {
          value = source[key];
          if (obj[key] == null) {
            obj[key] = value;
          } else if (type(obj[key]) === 'object') {
            obj[key] = defaults({}, obj[key], value);
          }
        }
      }
    }
    return obj;
  };

  type = (function() {
    var classToType, elemParser, name, toStr, _i, _len, _ref;
    toStr = Object.prototype.toString;
    elemParser = /\[object HTML(.*)\]/;
    classToType = {};
    _ref = "Boolean Number String Function Array Date RegExp Undefined Null NodeList".split(" ");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      name = _ref[_i];
      classToType["[object " + name + "]"] = name.toLowerCase();
    }
    return function(obj) {
      var found, strType;
      strType = toStr.call(obj);
      if (found = classToType[strType]) {
        return found;
      } else if (found = strType.match(elemParser)) {
        return found[1].toLowerCase();
      } else {
        return "object";
      }
    };
  })();

  without = function(source, target) {
    var item, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = source.length; _i < _len; _i++) {
      item = source[_i];
      if (__indexOf.call(target, item) < 0) {
        _results.push(item);
      }
    }
    return _results;
  };

  validateOptionsCallback = function(options, callback) {
    if (typeof options === 'function') {
      return [{}, options];
    } else {
      return [options, callback];
    }
  };

  tryRequireResolve = function(name, callback) {
    try {
      path = require.resolve(name);
      return callback(null, path);
    } catch (ex) {
      return localResolve(name, callback);
    }
  };

  tryRequire = function(name, callback) {
    var lib;
    if (name === null || name === '') {
      return callback(null, {});
    }
    if (loaded_libs[name] != null) {
      return callback(null, loaded_libs[name]);
    }
    try {
      lib = require(name);
      loaded_libs[name] = lib;
      return callback(null, lib);
    } catch (ex) {
      return localRequire(name, callback);
    }
  };

  tryRequireAll = function(names, callback) {
    var libnames, libs, loader, nextLib;
    if (names.length === 0) {
      return callback(null, []);
    }
    libs = [];
    libnames = names.slice();
    nextLib = libnames.shift();
    loader = function(err, lib) {
      if (err != null) {
        return callback(err, null);
      }
      libs.push(lib);
      if (libnames.length === 0) {
        return callback(null, libs);
      }
      nextLib = libnames.shift();
      return tryRequire(nextLib, loader);
    };
    return tryRequire(nextLib, loader);
  };

  loaded_libs = {};

  loading_now = {};

  isAlreadyLoaded = function(name, callback) {
    if (loaded_libs[name] != null) {
      callback(null, loaded_libs[name]);
      return true;
    }
    if (loading_now[name] != null) {
      loading_now[name].push(callback);
      return true;
    } else {
      loading_now[name] = [];
      loading_now[name].push(callback);
      return false;
    }
  };

  localResolve = function(name, callback) {
    var cmd, libpath, result;
    cmd = "" + process.execPath + " -p -e \"require.resolve('" + name + "')\"";
    result = exec(cmd, {
      silent: true
    });
    libpath = result.output.trim();
    if (result.code !== 0 || libpath === '') {
      return callback(new Error("Could not load '" + name + "' module. (no local path)"));
    } else {
      return callback(null, libpath);
    }
  };

  localRequire = function(name, callback) {
    var cb, lib, libpath, _i, _j, _len, _len1, _ref, _ref1;
    if (isAlreadyLoaded(name, callback)) {
      return false;
    }
    if (name.slice(0, 2) === './') {
      libpath = path.resolve(name);
      try {
        lib = require(libpath);
        loaded_libs[name] = lib;
        _ref = loading_now[name];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cb = _ref[_i];
          cb(null, lib);
        }
      } catch (ex) {
        _ref1 = loading_now[name];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          cb = _ref1[_j];
          cb(ex, null);
        }
      }
      delete loading_now[name];
    } else {
      localResolve(name, function(err, libpath) {
        var _k, _l, _len2, _len3, _ref2, _ref3;
        if (err != null) {
          return (function() {
            var _k, _len2, _ref2, _results;
            _ref2 = loading_now[name];
            _results = [];
            for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
              cb = _ref2[_k];
              _results.push(cb(err, null));
            }
            return _results;
          })();
        }
        try {
          lib = require(libpath);
          loaded_libs[name] = lib;
          _ref2 = loading_now[name];
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            cb = _ref2[_k];
            cb(null, lib);
          }
        } catch (ex) {
          _ref3 = loading_now[name];
          for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
            cb = _ref3[_l];
            cb(ex, null);
          }
        }
        return delete loading_now[name];
      });
    }
    return true;
  };

  module.exports = {
    pp: pp,
    type: type,
    extend: extend,
    without: without,
    defaults: defaults,
    validateOptionsCallback: validateOptionsCallback,
    tryRequire: tryRequire,
    tryRequireAll: tryRequireAll,
    tryRequireResolve: tryRequireResolve,
    localRequire: localRequire
  };

  extend(module.exports, util);

}).call(this);
