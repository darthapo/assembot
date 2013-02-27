// Generated by CoffeeScript 1.5.0

/*
Assembot! v0.0.1
*/


(function() {
  var api, build_css, build_css_package, build_js, build_js_package, coffee, converters, css_converters, css_types, eco, fs, get_css, get_js, inspect, js_converters, js_types, less, nib, path, pp, print, project_root, puts, stylus, try_require, walk, _defaults, _extend, _ref;

  path = require('path');

  fs = require('fs');

  _ref = require('util'), puts = _ref.puts, print = _ref.print, inspect = _ref.inspect;

  pp = function(obj) {
    return puts(inspect(obj));
  };

  project_root = process.cwd();

  api = {
    build: function(info, opts) {
      var config, output, output_ext, _results;
      if (opts == null) {
        opts = {};
      }
      puts("ASSEMBOT ACTIVATE!");
      _results = [];
      for (output in info) {
        config = info[output];
        config.output_path = output;
        config.output = path.resolve(output);
        output_ext = path.extname(output);
        if (output_ext === '.js') {
          _results.push(build_js(config, opts));
        } else if (output_ext === '.css') {
          _results.push(build_css(config, opts));
        } else {
          _results.push(puts("Output file extension must either be .js or .css!"));
        }
      }
      return _results;
    },
    server: function(info) {
      return this;
    },
    jsConverter: function(type, converter) {
      var etype;
      etype = "." + type;
      js_types.push(etype);
      js_converters[etype] = converter;
      return this;
    },
    cssConverter: function(type, converter) {
      var etype;
      etype = "." + type;
      css_types.push(etype);
      css_converters[etype] = converter;
      return this;
    }
  };

  converters = {
    js: {
      types: [],
      handlers: {}
    },
    css: {
      types: [],
      handlers: {}
    }
  };

  js_types = [];

  css_types = [];

  js_converters = {};

  css_converters = {};

  build_js = function(info, opts) {
    var build_count, ext, file, file_info, fullpath, js_output, jspath, pkg_list, src_dir, src_path, _i, _len, _results;
    print(" - " + info.output_path + "... ");
    src_path = path.resolve(info.source);
    src_dir = "" + src_path + path.sep;
    pkg_list = [];
    js_output = {};
    walk(src_path, function(file, fullpath) {
      var ext;
      ext = path.extname(file);
      if (js_types.indexOf(ext) >= 0) {
        return pkg_list.push(fullpath);
      }
    });
    build_count = 0;
    _results = [];
    for (_i = 0, _len = pkg_list.length; _i < _len; _i++) {
      fullpath = pkg_list[_i];
      file = path.basename(fullpath);
      ext = path.extname(fullpath);
      jspath = fullpath.replace(src_dir, '').replace(ext, '');
      file_info = {
        fullpath: fullpath,
        filename: file,
        loadpath: src_path,
        ext: ext,
        path: jspath
      };
      _results.push(get_js(file_info, function(js) {
        var outdir, output_content;
        build_count += 1;
        js_output[file_info.path] = js;
        if (build_count === pkg_list.length) {
          output_content = build_js_package(js_output);
          outdir = path.dirname(info.output);
          if (!fs.existsSync(outdir)) {
            fs.mkdirSync(outdir);
          }
          fs.writeFileSync(info.output, output_content, 'utf8');
          return print("Done!\n");
        }
      }));
    }
    return _results;
  };

  build_css = function(info, opts) {
    var build_count, css_output, csspath, ext, file, file_info, fullpath, pkg_list, src_dir, src_path, _i, _len, _results;
    print(" - " + info.output_path + "... ");
    src_path = path.resolve(info.source);
    src_dir = "" + src_path + path.sep;
    pkg_list = [];
    css_output = {};
    walk(src_path, function(file, fullpath) {
      var ext;
      ext = path.extname(file);
      if (css_types.indexOf(ext) >= 0) {
        return pkg_list.push(fullpath);
      }
    });
    build_count = 0;
    _results = [];
    for (_i = 0, _len = pkg_list.length; _i < _len; _i++) {
      fullpath = pkg_list[_i];
      file = path.basename(fullpath);
      ext = path.extname(fullpath);
      csspath = fullpath.replace(src_dir, '').replace(ext, '');
      file_info = {
        fullpath: fullpath,
        filename: file,
        loadpath: src_path,
        ext: ext,
        path: csspath
      };
      _results.push(get_css(file_info, function(js) {
        var outdir, output_content;
        build_count += 1;
        css_output[file_info.path] = js;
        if (build_count === pkg_list.length) {
          output_content = build_css_package(css_output);
          outdir = path.dirname(info.output);
          if (!fs.existsSync(outdir)) {
            fs.mkdirSync(outdir);
          }
          fs.writeFileSync(info.output, output_content, 'utf8');
          return print("Done!\n");
        }
      }));
    }
    return _results;
  };

  build_js_package = function(sources, opts) {
    var identifier, index, name, result, source, _ref1;
    if (opts == null) {
      opts = {};
    }
    identifier = (_ref1 = opts.ident) != null ? _ref1 : 'require';
    result = "(function(/*! Stitch !*/) {\n  if (!this." + identifier + ") {\n    var modules = {}, cache = {}, require = function(name, root) {\n      var path = expand(root, name), module = cache[path], fn;\n      if (module) {\n        return module.exports;\n      } else if (fn = modules[path] || modules[path = expand(path, './index')]) {\n        module = {id: path, exports: {}};\n        try {\n          cache[path] = module;\n          fn(module.exports, function(name) {\n            return require(name, dirname(path));\n          }, module);\n          return module.exports;\n        } catch (err) {\n          delete cache[path];\n          throw err;\n        }\n      } else {\n        throw 'module \\'' + name + '\\' not found';\n      }\n    }, expand = function(root, name) {\n      var results = [], parts, part;\n      if (/^\\.\\.?(\\/|$)/.test(name)) {\n        parts = [root, name].join('/').split('/');\n      } else {\n        parts = name.split('/');\n      }\n      for (var i = 0, length = parts.length; i < length; i++) {\n        part = parts[i];\n        if (part == '..') {\n          results.pop();\n        } else if (part != '.' && part != '') {\n          results.push(part);\n        }\n      }\n      return results.join('/');\n    }, dirname = function(path) {\n      return path.split('/').slice(0, -1).join('/');\n    };\n    this." + identifier + " = function(name) {\n      return require(name, '');\n    }\n    this." + identifier + ".define = function(bundle) {\n      for (var key in bundle)\n        modules[key] = bundle[key];\n    };\n    this." + identifier + ".modules= function() {\n      var names= [];\n      for( var name in modules)\n        names.push(name);\n      return names;\n    }\n  }\n  return this." + identifier + ".define;\n}).call(this)({";
    index = 0;
    for (name in sources) {
      source = sources[name];
      result += index++ === 0 ? "" : ", ";
      result += JSON.stringify(name);
      result += ": function(exports, require, module) {" + source + "}";
    }
    return result += "});\n";
  };

  build_css_package = function(sources, opts) {
    var content, key, results;
    if (opts == null) {
      opts = {};
    }
    results = "";
    for (key in sources) {
      content = sources[key];
      results += "/* " + key + " */\n";
      results += content;
      results += "\n\n";
    }
    return results;
  };

  api.jsConverter('js', function(source, opts, converted) {
    return converted(source);
  });

  api.jsConverter('html', function(source, opts, converted) {
    var output;
    output = eco.precompile(source);
    return converted("module.exports=" + (JSON.stringify(source)) + ";");
  });

  try_require = function(name) {
    try {
      return require(name);
    } catch (ex) {
      return require("" + project_root + "/node_modules/" + name);
    }
  };

  try {
    coffee = try_require('coffee-script');
    api.jsConverter('coffee', function(source, opts, converted) {
      var output;
      opts = opts.coffee || {};
      opts.bare = true;
      output = coffee.compile(source, opts);
      return converted(output);
    });
    api.jsConverter('litcoffee', function(source, opts, converted) {
      var output;
      opts = opts.coffee || {};
      opts.literate = true;
      opts.bare = true;
      output = coffee.compile(source, opts);
      return converted(output);
    });
  } catch (ex) {
    api.jsConverter('coffee', function() {
      throw "The 'coffee-script' module cannot be found!";
    });
    api.jsConverter('litcoffee', function() {
      throw "The 'coffee-script' module cannot be found!";
    });
  }

  try {
    eco = try_require('eco');
    api.jsConverter('eco', function(source, opts, converted) {
      var output;
      output = eco.precompile(source);
      return converted(output);
    });
  } catch (ex) {
    api.jsConverter('eco', function() {
      throw "The 'eco' module cannot be found!";
    });
  }

  api.cssConverter('css', function(source, opts, converted) {
    return converted(source);
  });

  try {
    less = try_require('less');
    api.jsConverter('less', function(source, opts, converted) {
      var output;
      output = less.precompile(source);
      return converted(output);
    });
  } catch (ex) {
    api.jsConverter('less', function() {
      throw "The 'less' module cannot be found!";
    });
  }

  try {
    stylus = try_require('stylus');
    nib = try_require('nib');
    api.cssConverter('styl', function(source, opts, converted) {
      return stylus(source).set('filename', opts.filename || 'generated.css').set('paths', [opts.loadpath]).use(nib).render(function(err, css) {
        if (err != null) {
          throw err;
        }
        return converted(css);
      });
    });
  } catch (ex) {
    api.cssConverter('styl', function() {
      throw "The 'stylus' or 'nib' module cannot be found!";
    });
  }

  get_js = function(opts, callback) {
    var converter, source;
    source = fs.readFileSync(opts.fullpath, 'utf8');
    converter = js_converters[opts.ext];
    return converter(String(source), opts, callback);
  };

  get_css = function(opts, callback) {
    var converter, source;
    source = fs.readFileSync(opts.fullpath, 'utf8');
    converter = css_converters[opts.ext];
    return converter(String(source), opts, callback);
  };

  walk = function(dir, action) {
    var file_list, filename, fullpath, stat, _i, _len, _results;
    file_list = fs.readdirSync(dir);
    _results = [];
    for (_i = 0, _len = file_list.length; _i < _len; _i++) {
      filename = file_list[_i];
      fullpath = [dir, filename].join(path.sep);
      stat = fs.statSync(fullpath);
      if (stat.isDirectory()) {
        _results.push(walk(fullpath, action));
      } else {
        _results.push(action(filename, fullpath));
      }
    }
    return _results;
  };

  _extend = function(obj) {
    var key, source, value, _i, _len, _ref1;
    _ref1 = Array.prototype.slice.call(arguments, 1);
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      source = _ref1[_i];
      if (source) {
        for (key in source) {
          value = source[key];
          obj[key] = value;
        }
      }
    }
    return obj;
  };

  _defaults = function(obj) {
    var key, source, value, _i, _len, _ref1;
    _ref1 = Array.prototype.slice.call(arguments, 1);
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      source = _ref1[_i];
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

  module.exports = api;

  module.exports.extend = _extend;

  module.exports.defaults = _defaults;

}).call(this);