path= require 'path'
fs= require 'fs'
_= require './util'
project_root= process.cwd()

assembot_package= require '../package'
project_package= try
    require "#{project_root}#{path.sep}package"
  catch ex
    {}

type_db=
  ".js":
    types: []
    handlers: {}
  ".css":
    types: []
    handlers: {}

# Must be a file extension
validType= (target)->
  if target[0] is '.'
    target
  else
    ".#{ target }"

# The public API
module.exports= api=

  debug: ->
    _.pp type_db

  addFor: (target, type, converter)->
    target= validType(target)
    type= validType(type)
    type_db[target].types.push type
    type_db[target].handlers[type]= converter
    @

  validTypeFor: (target, ext)->
    target= validType(target)
    type= validType(ext)
    if type_db[target]? then type_db[target].types.indexOf(type) >= 0 else false

  # Example: 
  #   convertor.buildSourceFor 'js', '/X.coffee', {}, (err, src, info)-> log src
  buildSourceFor: (target, fullpath, info, callback)->
    target= validType(target)
    ext= path.extname(fullpath)
    source= fs.readFileSync fullpath, 'utf8'
    converter= type_db[target].handlers[ext]
    converter @replaceTokens(String(source), info), info, callback
    @

  tokenParser: /(\{%\-([ a-zA-Z0-9\._]*)\-%\})/g

  replaceTokens: (string, info)->
    if info.replaceTokens and @tokenParser.test(string)
      string.replace @tokenParser, (match, token, value, loc, src)->
        data= info
        parts= value.split('.')
        first_part= parts.shift().trim()
        switch first_part
          when 'package' then data= project_package
          when 'assembot' then data= assembot_package
          when 'NOW' then data= new Date()
          else
            data= info[first_part]
        for part in parts
          key= part.trim()
          data= data[key]
        String(data)
    else
      string
  

#
# Default Converters: 
#

addConvertor= (target, type, modules, handler)->
  modules= [modules] unless _.isArray modules
  args= []
  if modules.length > 0
    api.addFor target, type, (source,opts,callback)-> 
      for module in modules
        _.tryRequire module, (err, lib)->
          if err?
            # Could not load requirement
            file= "#{ opts.current_file.path }#{ opts.current_file.ext }"
            _.pp err
            throw "Cannot transpile #{file}: Module(s) '#{ modules.join "'"}' cannot be loaded! #{err}"
          args.push lib
          if args.length >= modules.length
            converter= handler.apply handler, args
            subHandler= (s,o,c)->
              try
                converter(s,o,c)
              catch ex
                file= "#{ o.current_file.path }#{ o.current_file.ext }"
                c new Error("Transpiler error for #{ file }: #{ ex.message }"), null, o
            api.addFor target, type, subHandler
            subHandler source, opts, callback
  else
    converter= handler.apply handler, args
    api.addFor target, type, (s,o,c)->
      try
        converter(s,o,c)
      catch ex
        file= "#{ o.current_file.path }#{ o.current_file.ext }"
        c new Error("Transpiler error for #{ file }: #{ ex.message }"), null, o

  true

addJsConvertor= (type, modules, handler)-> 
  if _.isArray type
    # _.pp type
    for thisType in type
      # _.puts "SPLITTING OUT"
      # _.pp thisType
      addConvertor 'js', thisType, modules, handler
  else
    addConvertor 'js', type, modules, handler
  true

addCssConvertor= (type, modules, handler)-> 
  addConvertor 'css', type, modules, handler


# Default JS converters
addJsConvertor '.js', [], -> 
  (source, opts, converted)->
    converted null, source, opts

addJsConvertor '.html', [], -> 
  (source, opts, converted)->
    converted null, """module.exports=#{JSON.stringify source};""", opts

addJsConvertor '.json', [], -> 
  (source, opts, converted)->
    data= JSON.parse source
    converted null, """module.exports=#{JSON.stringify data};""", opts

addJsConvertor ['.coffee', '.litcoffee'], 'coffee-script', (coffee)-> 
  (source, opts, converted)->
    options = _.defaults (opts.coffee || {}),
      bare: yes
    options.literate= (opts.current_file.ext is '.litcoffee' || no)
    # _.pp options
    output= coffee.compile source, options
    converted null, output, opts

addJsConvertor '.eco', 'eco', (eco)-> 
  (source, opts, converted)->
    output= eco.precompile source
    converted null, output, opts

addJsConvertor '.ejs', 'ejs', (ejs)->
  (source, opts, converted)->
    output= ejs.compile(source, client:true, compileDebug:false)
    converted null, """module.exports= #{output.toString()};""", opts

addJsConvertor '.handlebars', 'handlebars', (handlebars)->
  (source, opts, converted)->
    options= _.defaults (opts.handlebars || {}),
      simple: false
      commonjs: true
    output= handlebars.precompile(source, options)
    converted null, """module.exports= #{output.toString()};""", opts

addJsConvertor '.jade', 'jade', (jade)->
  (source, opts, converted)->
    options= _.defaults (opts.jade || {}),
      client: true
      compileDebug: false
    output= jade.compile(source, options)
    converted null, """module.exports= #{output.toString()};""", opts

addJsConvertor '.hogan', 'hogan.js', (hogan)->
  (source, opts, converted)->
    options= _.defaults (opts.hogan || {}),
      asString: 1
    output= hogan.compile(source, options)
    converted null, """module.exports= new Hogan.Template(#{output.toString()});""", opts

addJsConvertor '.dot', 'doT', (dot)->
  (source, opts, converted)->
    options= _.defaults (opts.dot || opts.doT || {}), {}
    output= dot.compile(source, options)
    # _.pp """module.exports= #{ output.toString() }"""
    converted null, """module.exports= #{ output.toString() }""", opts

addJsConvertor ['.md', 'markdown'], 'marked', (marked)->
  (source, opts, converted)->
    options= _.defaults (opts.dot || opts.doT || {}),
      gfm: true
      tables: true
      breaks: false
      pedantic: false
      sanitize: false
      smartLists: true
    output= marked(source, options)
    # _.pp """module.exports= #{ output.toString() }"""
    converted null, """module.exports= #{ JSON.stringify output }""", opts

# TODO: Add default converters for: yaml(?), others?

# Default CSS converters
addCssConvertor '.css', [], -> 
  (source, opts, converted)->
    converted null, source, opts

addCssConvertor '.less', 'less', (less)-> 
  (source, opts, converted)->
    less.render source, (err, css)->
      converted err, null, opts if err?
      converted null, css, opts

addCssConvertor '.styl', ['stylus', 'nib'], (stylus, nib)->
  load_paths= [process.cwd(), path.dirname(__dirname)]
  (source, opts, converted)->
    stylus(source)
      .set('filename', opts.current_file.filename || 'generated.css')
      .set('paths', load_paths)
      .use(nib())
      .render (err, css)->
        if err?
          converted err, null, opts
        else
          converted null, css, opts

# Add other ones too???