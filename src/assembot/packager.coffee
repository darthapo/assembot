
css_package= (resources, options, callback)->
  results= ""
  resources.eachForTarget 'css', (res)->
    results += "/* #{ res.path } */\n"
    results += res.content
    results += "\n\n"
  callback null, results

exports.css= css_package

ecss_wrapper= (css)->
  """
  var node = null, css = #{ JSON.stringify css };
  module.exports= {
    content: css,
    isActive: function(){ return node != null; },
    activate: function(to){
      if(node != null) return; // Already added to DOM!
      to= to || document.getElementsByTagName('HEAD')[0] || document.body || document; // In the HEAD or BODY tags
      node= document.createElement('style');
      node.innerHTML= css;
      to.appendChild(node);
      return this;
    },
    deactivate: function() {
      if(node != null) {
        node.parentNode.removeChild(node);
        node = null;
      }
      return this;
    }
  };
  """

exports.embedded_css= ecss_wrapper

js_package= (resources, options, callback)->
  identifier= options.ident ? 'require' 
  autoStart= options.autoStart ? false
  result = """
    (function(/*! Stitched by Assembot !*/) {
      /* 
        The commonjs code below was based on @sstephenson's stitch.
        https://github.com/sstephenson/stitch
      */
      if (!this.#{identifier}) {
        var modules = {}, cache = {}, moduleList= function(startingWith) {
          var names= [], startingWith= startingWith || '';
          for( var name in modules ) {
            if(name.indexOf(startingWith) === 0) names.push(name);
          }
          return names;
        }, require = function(name, root) {
          var path = expand(root, name), module = cache[path], fn;
          if (module) {
            return module.exports;
          } else if (fn = modules[path] || modules[path = expand(path, './index')]) {
            module = {id: path, exports: {}};
            try {
              cache[path] = module;
              var localRequire= function(name) {
                return require(name, dirname(path));
              }
              localRequire.modules= moduleList;
              fn(module.exports, localRequire, module);
              return module.exports;
            } catch (err) {
              delete cache[path];
              throw err;
            }
          } else {
            throw 'module \\'' + name + '\\' not found';
          }
        }, expand = function(root, name) {
          var results = [], parts, part;
          if (/^\\.\\.?(\\/|$)/.test(name)) {
            parts = [root, name].join('/').split('/');
          } else {
            parts = name.split('/');
          }
          for (var i = 0, length = parts.length; i < length; i++) {
            part = parts[i];
            if (part == '..') {
              results.pop();
            } else if (part != '.' && part != '') {
              results.push(part);
            }
          }
          return results.join('/');
        }, dirname = function(path) {
          return path.split('/').slice(0, -1).join('/');
        };
        this.#{identifier} = function(name) {
          return require(name, '');
        }
        this.#{identifier}.define = function(bundle) {
          for (var key in bundle)
            modules[key] = bundle[key];
        };
        this.#{identifier}.modules= moduleList;
      }
      return this.#{identifier}.define;
    }).call(this)({\n
  """
  resources.eachForTarget 'js', (res, i)->
    result += if i is 0 then "" else ",\n"
    result += JSON.stringify res.path
    result += ": function(exports, require, module) {\n#{ res.content }\n}"
  result += """
    });\n
  """
  result += "#{identifier}('#{autoStart}');\n" if autoStart

  callback null, result

exports.js= js_package
