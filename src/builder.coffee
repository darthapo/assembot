###
Assembot! v0.0.1
###

path= require 'path'
fs= require 'fs'
{puts, print, inspect}= require 'util'
pp= (obj)-> puts inspect obj
defaults= require './defaults'
_= require './util'
converter= require './converter'
project_root= process.cwd()
uglify= try
  converter.tryRequire("uglify-js")
catch ex
  null



module.exports= api=

  build: (info, opts={})->
    puts "ASSEMBOT ACTIVATE!"
    for output, config of info
      _.extend config, opts
      _.defaults config, defaults.config
      src= config.source
      config.package= info.package
      config.assembot= info.assembot
      config.options= opts
      config.projectRoot= project_root
      if src?
        config.source=
          target: src
          path: path.resolve(src) 
          dir: "#{path.resolve(src)}#{path.sep}"
        config.output=
          target: output
          path: path.resolve(output)
          ext: path.extname(output)
          dir: path.dirname(path.resolve(output))

      # puts "CONFIG"
      # pp config

      if config.output.ext is '.js'
        print " - #{ config.output.target }... Assembling... "
        assemble_files 'js', config, (err, js_tree)->
          output_content= build_js_package js_tree, config
          fs.mkdirSync config.output.dir unless fs.existsSync config.output.dir
          # TODO: Add support for sourcemaps...
          if config.minify
            if uglify?
              print "Minify..."
              output_content= try
                switch config.minify
                  when 1, 'minify', 'min'
                    uglify.minify( output_content, fromString: true, mangle:false ).code
                  when 2, 'mangle', 'munge', 'compress'
                    uglify.minify( output_content, fromString: true, mangle:true ).code
                  else
                    output_content
              catch ex
                print "Error in minify, skipping... "
                output_content
            else
              print "(can't minify, install uglify-js)..."

          # Add header...?
          if config.header
            output_content= "#{converter.replaceTokens(config.header, config)}\n#{output_content}"

          fs.writeFileSync config.output.path, output_content, 'utf8'
          print "Done!\n"
      
      else if config.output.ext is '.css'
        print " - #{ config.output.target }... Assembling... "
        assemble_files 'css', config, (err, css_tree)->
          output_content= build_css_package css_tree, config
          fs.mkdirSync config.output.dir unless fs.existsSync config.output.dir
          if config.header
            output_content= "#{converter.replaceTokens(config.header, config)}\n#{output_content}"
          fs.writeFileSync config.output.path, output_content, 'utf8'
          print "Done!\n"
      
      else if output isnt 'package' and output isnt 'assembot'
        puts "Output file extension must either be .js or .css!"
        pp output
        pp config

  server: (info)->
    @

  # deprecated:
  jsConverter: (type, converter)->
    converter.addFor 'js', type, converter
    @
  cssConverter: (type, converter)->
    converter.addFor 'css', type, converter
    @


assemble_files= (type, info, callback)->
  src_path= info.source.path
  src_dir= "#{ src_path }#{ path.sep }"
  pkg_list= []
  output={}
  _.walkTree src_path, (file, fullpath)->
    ext= path.extname file
    if converter.validTypeFor type, ext
      pkg_list.push fullpath 
  build_count= 0
  for fullpath in pkg_list
    file= path.basename(fullpath)
    ext= path.extname(fullpath)
    libpath= fullpath.replace(src_dir, '').replace(ext, '')
    file_info= fullpath:fullpath, filename:file, loadpath:src_path, ext:ext, path:libpath
    converter.buildSourceFor type, fullpath, info, (err, converted_source)->
      build_count += 1
      output[file_info.path]= converted_source
      if build_count == pkg_list.length
        callback null, output
  pkg_list


build_js_package= (sources, opts={})->
  identifier= (opts.ident or opts.options.ident) ? 'require' 
  autoStart= (opts.autoStart or opts.options.autoStart) ? false
  result = """
    (function(/*! Stitched by Assembot !*/) {
      if (!this.#{identifier}) {
        var modules = {}, cache = {}, require = function(name, root) {
          var path = expand(root, name), module = cache[path], fn;
          if (module) {
            return module.exports;
          } else if (fn = modules[path] || modules[path = expand(path, './index')]) {
            module = {id: path, exports: {}};
            try {
              cache[path] = module;
              fn(module.exports, function(name) {
                return require(name, dirname(path));
              }, module);
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
        this.#{identifier}.modules= function() {
          var names= [];
          for( var name in modules)
            names.push(name);
          return names;
        }
      }
      return this.#{identifier}.define;
    }).call(this)({
  """

  index = 0
  for name, source of sources
    result += if index++ is 0 then "" else ", "
    result += JSON.stringify name
    result += ": function(exports, require, module) {#{source}}"

  result += """
    });\n
  """
  result += "this.#{identifier}('#{autoStart}');\n" if autoStart

  result

build_css_package= (sources, opts={})->
  results= ""
  for key, content of sources
    results += "/* #{key} */\n"
    results += content
    results += "\n\n"
  results

