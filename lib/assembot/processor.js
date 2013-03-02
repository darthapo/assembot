// Generated by CoffeeScript 1.5.0
(function() {
  var addProcessor, path, render, replaceTokens, targetOf, transpile, validTarget, _;

  path = require('path');

  _ = require('./util');

  targetOf = function(filepath) {
    var ext;
    ext = path.extname(filepath);
    switch (ext) {
      case '.js':
        return 'js';
      case '.coffee':
        return 'js';
      case '.css':
        return 'css';
      case '.styl':
        return 'css';
      default:
        return 'unknown';
    }
  };

  validTarget = function(filepath) {
    return targetOf(filepath) !== 'unknown';
  };

  render = function(resource, options, done) {};

  transpile = function(resource, options, done) {};

  replaceTokens = function(string, context) {};

  addProcessor = function(type, ext, modules, handler) {};

  module.exports = {
    targetOf: targetOf,
    validTarget: validTarget,
    render: render,
    transpile: transpile,
    replaceTokens: replaceTokens,
    addProcessor: addProcessor
  };

}).call(this);