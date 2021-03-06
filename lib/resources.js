// Generated by CoffeeScript 1.6.1
(function() {
  var EventEmitter, Resource, ResourceList, cat, fs, log, ls, path, processor, resourcelist, test, _, _ref,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  path = require('path');

  fs = require('fs');

  _ = require('./util');

  processor = require('./processor');

  log = require('./log');

  _ref = require('shelljs'), ls = _ref.ls, cat = _ref.cat, test = _ref.test;

  EventEmitter = require('events').EventEmitter;

  Resource = (function() {

    function Resource(filepath, content, extra) {
      this.filepath = filepath;
      this.content = content;
      this.extra = extra != null ? extra : {};
      log.debug(" -", this.filepath);
      this.ext = path.extname(this.filepath);
      this.type = this.ext.slice(1);
      this.target = processor.targetOf(this.filepath);
      this.path = this.filepath.replace(this.ext, '');
    }

    return Resource;

  })();

  ResourceList = (function() {

    ResourceList.fromPath = function(sourcePath) {
      var contents, filename, filepath, fileset, res, reslist, _i, _len;
      log.debug("Resources loaded from", sourcePath);
      reslist = new ResourceList;
      sourcePath = path.resolve(sourcePath);
      fileset = ls('-R', sourcePath);
      for (_i = 0, _len = fileset.length; _i < _len; _i++) {
        filename = fileset[_i];
        filepath = path.join(sourcePath, filename);
        if (!test('-f', filepath)) {
          continue;
        }
        contents = cat(filepath);
        res = new Resource(filename, contents, {
          sourcePath: sourcePath
        });
        reslist.add(res);
      }
      return reslist;
    };

    function ResourceList() {
      this.list = [];
      this.pathsByTarget = {};
      this.length = 0;
    }

    ResourceList.prototype.each = function(callback) {
      var i, resource, _i, _len, _ref1;
      _ref1 = this.list;
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        resource = _ref1[i];
        callback(resource, i);
      }
      return this;
    };

    ResourceList.prototype.forTarget = function(target) {
      var resource, _i, _len, _ref1, _results;
      _ref1 = this.list;
      _results = [];
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        resource = _ref1[_i];
        if (resource.target === target) {
          _results.push(resource);
        }
      }
      return _results;
    };

    ResourceList.prototype.eachForTarget = function(target, callback) {
      var i, resource, _i, _len, _ref1;
      _ref1 = this.forTarget(target);
      for (i = _i = 0, _len = _ref1.length; _i < _len; i = ++_i) {
        resource = _ref1[i];
        callback(resources, i);
      }
      return this;
    };

    ResourceList.prototype.add = function(resource, safely) {
      var paths, _base, _name, _ref1;
      paths = ((_base = this.pathsByTarget)[_name = resource.target] || (_base[_name] = []));
      if (_ref1 = resource.path, __indexOf.call(paths, _ref1) >= 0) {
        if (!safely) {
          throw new Error("Duplicate resource path!");
        }
      } else {
        this.list.push(resource);
        paths.push(resource.path);
        this.length += 1;
      }
      return this;
    };

    ResourceList.prototype.push = ResourceList.prototype.add;

    ResourceList.prototype.get = function(targetPath) {
      var res, _i, _len, _ref1;
      _ref1 = this.list;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        res = _ref1[_i];
        if (res.path === targetPath) {
          return res;
        }
      }
      return null;
    };

    ResourceList.prototype.blacklist = function(pathlist) {
      var list, res, _i, _len, _ref1;
      list = this.list.slice();
      this.list = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        res = list[_i];
        if (_ref1 = res.path, __indexOf.call(pathlist, _ref1) < 0) {
          this.list.push(res);
        }
      }
      this.length = this.list.length;
      return this;
    };

    ResourceList.prototype.whitelist = function(pathlist) {
      var list, res, _i, _len, _ref1;
      list = this.list.slice();
      this.list = [];
      for (_i = 0, _len = list.length; _i < _len; _i++) {
        res = list[_i];
        if (_ref1 = res.path, __indexOf.call(pathlist, _ref1) >= 0) {
          this.list.push(res);
        }
      }
      this.length = this.list.length;
      return this;
    };

    ResourceList.prototype.treeForTarget = function(target) {
      var resource, tree, _i, _len, _ref1;
      tree = {};
      _ref1 = this.forTarget(target);
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        resource = _ref1[_i];
        tree[resource.path] = resource;
      }
      return tree;
    };

    return ResourceList;

  })();

  resourcelist = function(filepath) {
    if (filepath != null) {
      return ResourceList.fromPath(filepath);
    } else {
      return new ResourceList;
    }
  };

  module.exports = {
    Resource: Resource,
    ResourceList: ResourceList,
    resourcelist: resourcelist
  };

}).call(this);
