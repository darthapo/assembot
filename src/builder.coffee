path= require 'path'
fs= require 'fs'
defaults= require './defaults'
_= require './util'
converter= require './converter'
project_root= process.cwd()
uglify=  require "uglify-js"

do_minify= (output_content, config)->
  if config.minify
    if uglify?
      _.log "Minify... (#{ config.output.target })"
      try
        settings= fromString: true, mangle:false
        settings.outSourceMap= config.output.sourceMapName if config.sourceMap
        switch config.minify
          when 1, 'minify', 'min'
            uglify.minify( output_content, settings )
          when 2, 'mangle', 'munge', 'compress'
            settings.mangle= true
            uglify.minify( output_content, settings )
          else
            code:output_content, map:null
      catch ex
        _.log "Error in minify, skipping... (#{ config.output.target })"
        code:output_content, map:null
    else
      _.log "Can't minify (install uglify-js) (#{ config.output.target })"
      code:output_content, map:null
  else
    code:output_content, map:null

do_header= (output_content, config)->
  if config.header
    "#{converter.replaceTokens(config.header, config)}\n#{output_content}"
  else
    output_content

outputTargets= (info)->
  targets=[]
  for output, config of info
    ext= path.extname(output)
    targets.push( output ) if ext is '.js' or ext is '.css'
  targets

module.exports= api=

  buildTargets: (config, resolvePaths=no)->
    @prepConfig(config)
    targets= outputTargets(config)
    if resolvePaths
      targetsFP= []
      for target in targets
        targetsFP.push path.resolve(target)
      targetsFP
    else
      targets

  buildPackage: (config, callback)->
    _.log "Assembling... (#{ config.output.target })"
    target= config.type
    try
      assemble_files target, config, (err, src_tree)->
        output_content= if target is '.js' 
          build_js_package src_tree, config
        else
          build_css_package src_tree, config
        minified= do_minify(output_content, config)
        output_content= minified.code
        output_content= do_header(output_content, config)
        callback null, output_content, minified.map
    catch ex
      callback ex, null, null


  prepConfig: (info, opts={})->
    for output, config of info
      _.extend config, opts
      _.defaults config, defaults.config
      config.type= 'meta'
      config.projectRoot= project_root
      src= config.source
      if src? and typeof src is 'string'
        config.source=
          target: src
          path: path.resolve(src) 
          dir: "#{path.resolve(src)}#{path.sep}"
        config.output=
          target: output
          name: path.basename(output)
          path: path.resolve(output)
          ext: path.extname(output)
          dir: path.dirname(path.resolve(output))
          sourceMapName: "#{ path.basename(output) }.map"
          sourceMapPath: "#{ path.resolve(output) }.map"
        config.type= config.output.ext
    # _.pp info
    info

  buildTarget: (config, callback)->
    if config.type is '.js'
      @buildPackage config, (err, output, source_map)->
        throw err if err?
        if callback?
          callback(err, output, source_map)
          return
        fs.mkdirSync config.output.dir unless fs.existsSync config.output.dir
        if source_map? and config.sourceMap
          fs.writeFileSync config.output.sourceMapPath, source_map, 'utf8'
          _.log "SourceMap... (#{ config.output.target })"
          output += "\n//@ sourceMappingURL=#{config.output.sourceMapName}"
          #console.log source_map
        
        fs.writeFileSync config.output.path, output, 'utf8'
        _.log "Wrote: #{ config.output.target }"
    
    else if config.type is '.css'
      @buildPackage config, (err, output)->
        throw err if err?
        if callback?
          callback(err, output)
          return
        fs.mkdirSync config.output.dir unless fs.existsSync config.output.dir
        fs.writeFileSync config.output.path, output, 'utf8'
        _.log "Wrote: #{ config.output.target }"

  build: (info, opts={})->
    _.puts "ASSEMBOT ACTIVATE!"
    @prepConfig info, opts
    for output, config of info
      @buildTarget config

  displayTargetTree: (info, opts={})->
    _.puts "ASSEMBOT ACTIVATE!"
    @prepConfig info, opts
    for output, config of info
      # unless config.type is 'meta'
      _.puts ""
      _.puts output
      src_dir= path.dirname config.source.path
      _.walkTree config.source.path, (file, fullpath)->
        ext= path.extname file
        if converter.validTypeFor config.type, ext
          _.puts "  #{path.relative(src_dir, fullpath)}"
    _.puts ""

  displayModuleTree: (info, opts={})->
    _.puts "ASSEMBOT ACTIVATE!"
    @prepConfig info, opts
    for output, config of info
      # unless config.type is 'meta'
      if config.type is '.js'
        _.puts ""
        _.puts "#{ config.ident }  (in #{output})"
        src_dir= path.dirname config.source.path
        _.walkTree config.source.path, (file, fullpath)->
          ext= path.extname file
          if converter.validTypeFor config.type, ext
            _.puts "  #{path.relative(config.source.path, fullpath).replace(ext, '')}"
    _.puts ""


filelistForType= (type, path, callback)->
  filelist= []
  _.walkTree path, (file, fullpath)->
    ext= path.extname file
    if converter.validTypeFor type, ext
      filelist.push fullpath 
  filelist


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
  # _.pp pkg_list
  for fullpath in pkg_list
    file= path.basename(fullpath)
    ext= path.extname(fullpath)
    libpath= fullpath.replace(src_dir, '').replace(ext, '')
    local_info= _.extend {}, info
    local_info.current_file= fullpath:fullpath, filename:file, loadpath:src_path, ext:ext, path:libpath
    converter.buildSourceFor type, fullpath, local_info, (err, converted_source, opts)->
      throw err if err?
      build_count += 1
      output[opts.current_file.path]= converted_source
      # _.puts " - #{opts.current_file.filename} (#{build_count}/#{pkg_list.length})" # if verbose
      if build_count == pkg_list.length
        callback null, output
  # converter.debug()
  pkg_list


build_js_package= (sources, opts={})->
  identifier= opts.ident ? 'require' 
  autoStart= opts.autoStart ? false
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
    }).call(this)({\n
  """

  index = 0
  for name, source of sources
    result += if index++ is 0 then "" else ",\n"
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

