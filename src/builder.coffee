###
Assembot! v0.0.1
###

path= require 'path'
fs= require 'fs'
{puts, print, inspect}= require 'util'
pp= (obj)-> puts inspect obj

project_root= process.cwd()

api=

  build: (info, opts={})->
    puts "ASSEMBOT ACTIVATE!"
    for output, config of info
      config.output_path= output
      config.output = path.resolve(output)
      output_ext= path.extname(output)
      if output_ext is '.js'
        build_js config, opts
      else if output_ext is '.css'
        build_css config, opts
      else
        puts "Output file extension must either be .js or .css!"

  server: (info)->
    @

  jsConverter: (type, converter)->
    etype= ".#{type}"
    js_types.push etype
    js_converters[etype]= converter
    @

  cssConverter: (type, converter)->
    etype= ".#{type}"
    css_types.push etype
    css_converters[etype]= converter
    @



converters=
  js:
    types: []
    handlers: {}
  css:
    types: []
    handlers: {}

js_types= []
css_types= []

js_converters= {}
css_converters= {}

build_js= (info, opts)->
  print " - #{ info.output_path }... "
  src_path= path.resolve info.source
  src_dir= "#{ src_path }#{ path.sep }"
  pkg_list= []
  js_output={}
  walk src_path, (file, fullpath)->
    ext= path.extname file
    if js_types.indexOf(ext) >= 0
      pkg_list.push fullpath 
  build_count= 0
  for fullpath in pkg_list
    file= path.basename(fullpath)
    ext= path.extname(fullpath)
    jspath= fullpath.replace(src_dir, '').replace(ext, '')
    file_info= fullpath:fullpath, filename:file, loadpath:src_path, ext:ext, path:jspath
    get_js file_info, (js)->
      build_count += 1
      js_output[file_info.path]= js
      if build_count == pkg_list.length
        output_content= build_js_package js_output
        outdir= path.dirname info.output
        fs.mkdirSync outdir unless fs.existsSync outdir
        fs.writeFileSync info.output, output_content, 'utf8'
        print "Done!\n"

build_css= (info, opts)->
  print " - #{ info.output_path }... "
  src_path= path.resolve info.source
  src_dir= "#{ src_path }#{ path.sep }"
  pkg_list= []
  css_output={}
  walk src_path, (file, fullpath)->
    ext= path.extname file
    if css_types.indexOf(ext) >= 0
      pkg_list.push fullpath 
  build_count= 0
  for fullpath in pkg_list
    file= path.basename(fullpath)
    ext= path.extname(fullpath)
    csspath= fullpath.replace(src_dir, '').replace(ext, '')
    file_info= fullpath:fullpath, filename:file, loadpath:src_path, ext:ext, path:csspath
    get_css file_info, (js)->
      build_count += 1
      css_output[file_info.path]= js
      if build_count == pkg_list.length
        output_content= build_css_package css_output
        outdir= path.dirname info.output
        fs.mkdirSync outdir unless fs.existsSync outdir
        fs.writeFileSync info.output, output_content, 'utf8'
        print "Done!\n"


build_js_package= (sources, opts={})->
  identifier= opts.ident ? 'require' 
  result = """
    (function(/*! Stitch !*/) {
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

build_css_package= (sources, opts={})->
  results= ""
  for key, content of sources
    results += "/* #{key} */\n"
    results += content
    results += "\n\n"
  results


# Default JS converters
api.jsConverter 'js', (source, opts, converted)->
  converted source

api.jsConverter 'html', (source, opts, converted)->
  output= eco.precompile source
  converted """module.exports=#{JSON.stringify source};"""

try_require= (name)->
  # This may only be needed when using npm link, I'm not sure.
  try
    require name
  catch ex
    require "#{project_root}/node_modules/#{name}"

try
  coffee= try_require 'coffee-script'
  api.jsConverter 'coffee', (source, opts, converted)->
    opts = opts.coffee || {}
    opts.bare= yes
    output= coffee.compile source, opts
    converted output
  api.jsConverter 'litcoffee', (source, opts, converted)->
    opts = opts.coffee || {}
    opts.literate= yes
    opts.bare= yes
    output= coffee.compile source, opts
    converted output
catch ex
  api.jsConverter 'coffee', -> throw "The 'coffee-script' module cannot be found!"
  api.jsConverter 'litcoffee', -> throw "The 'coffee-script' module cannot be found!"

try
  eco= try_require 'eco'
  api.jsConverter 'eco', (source, opts, converted)->
    output= eco.precompile source
    converted output
catch ex
  api.jsConverter 'eco', -> throw "The 'eco' module cannot be found!"

# TODO: Add default converters for: json(?), yaml(?), ejs, handlebars

# Default CSS converters
api.cssConverter 'css', (source, opts, converted)->
  converted source

try
  less= try_require 'less'
  api.jsConverter 'less', (source, opts, converted)->
    output= less.precompile source
    converted output
catch ex
  api.jsConverter 'less', -> throw "The 'less' module cannot be found!"
  # puts "LessCSS disabled"

try
  stylus= try_require 'stylus'
  nib= try_require 'nib'
  ## USE NIB TOO!
  api.cssConverter 'styl', (source, opts, converted)->
    stylus(source)
      .set('filename', opts.filename || 'generated.css')
      .set('paths', [opts.loadpath])
      .use(nib)
      .render (err, css)->
        throw err if err?
        converted css
catch ex
  api.cssConverter 'styl', -> throw "The 'stylus' or 'nib' module cannot be found!"
  # puts "Stylus/Nib disabled"

get_js= (opts, callback)->
  source= fs.readFileSync opts.fullpath, 'utf8'
  converter= js_converters[opts.ext]
  converter String(source), opts, callback

get_css= (opts, callback)->
  source= fs.readFileSync opts.fullpath, 'utf8'
  converter= css_converters[opts.ext]
  converter String(source), opts, callback

walk= (dir, action)->
  file_list= fs.readdirSync dir
  for filename in file_list
    fullpath= [dir, filename].join path.sep
    stat= fs.statSync fullpath
    if stat.isDirectory()
      # Dive into the directory
      walk fullpath, action
    else
      # Call the action
      action filename, fullpath


_extend= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        obj[key]= value
  obj
      
  
_defaults= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        unless obj[key]?
          obj[key]= value
  obj


module.exports= api

module.exports.extend= _extend
module.exports.defaults= _defaults