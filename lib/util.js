// Generated by CoffeeScript 1.5.0
(function() {
  var fs, path, util, walk;

  util = require('util');

  fs = require('fs');

  path = require('path');

  exports.extend = function(obj) {
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

  exports.defaults = function(obj) {
    var key, source, value, _i, _len, _ref;
    _ref = Array.prototype.slice.call(arguments, 1);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      source = _ref[_i];
      if (source) {
        for (key in source) {
          value = source[key];
          if (obj[key] == null) {
            obj[key] = value;
          }
        }
      }
    }
    return obj;
  };

  exports.walkTree = walk = function(dir, callback, files_only) {
    var file_list, filename, fullpath, stat, _i, _len;
    if (files_only == null) {
      files_only = true;
    }
    file_list = fs.readdirSync(dir);
    for (_i = 0, _len = file_list.length; _i < _len; _i++) {
      filename = file_list[_i];
      fullpath = [dir, filename].join(path.sep);
      stat = fs.statSync(fullpath);
      if (stat.isDirectory()) {
        if (!files_only) {
          callback(filename, fullpath, true);
        }
        walk(fullpath, callback);
      } else {
        callback(filename, fullpath, false);
      }
    }
    return file_list;
  };

  exports.tryRequire = function(name) {
    try {
      return require(name);
    } catch (ex) {
      return require("" + (process.cwd()) + "/node_modules/" + name);
    }
  };

  exports.tryRequireLocalFirst = function(name) {
    try {
      return require("" + (process.cwd()) + "/node_modules/" + name);
    } catch (ex) {
      return require(name);
    }
  };

  exports.extend(exports, util);

}).call(this);