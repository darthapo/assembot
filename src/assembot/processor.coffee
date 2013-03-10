_= require './util'
log= require './log'
path= require 'path'
async= require 'async'
notify= require './notify'

project_root= process.cwd()
assembot_package= require '../../package'
project_package= try
    require "#{project_root}#{path.sep}package"
  catch ex
    {}
compontent_package= try
    require "#{project_root}#{path.sep}component"
  catch ex
    {}
build_package= try
    require "#{project_root}#{path.sep}build"
  catch ex
    {}

targetOf= (filepath)->
  ext= path.extname filepath
  manager.targetForExt ext

validTarget= (filepath)->
  targetOf(filepath) isnt 'unknown'

render= (resources, options, done)->
  if resources.length is 0
    log.debug "Rendering 0 resources"
    return done()
  else
    log.debug "Rendering #{ resources[0].target } resources:"
  t= (r,cb)-> 
    notify.beforeRenderItem r
    r.content= replaceTokens(r.content, options) if options.replaceTokens
    transpile r, options, cb
  async.each resources, t, (err, rest)->
    throw err if err?
    done(err)
  true

transpile= (resource, options, done)->
  manager.render resource, options, done

tokenParser= /(\{%\-([ a-zA-Z0-9\._]*)\-%\})/g

replaceTokens= (string, context)->
  if tokenParser.test(string)
    string.replace tokenParser, (match, token, value, loc, src)->
      data= context
      parts= value.split('.')
      first_part= parts.shift().trim()
      switch first_part
        when 'package' then data= project_package
        when 'assembot' then data= assembot_package
        when 'build' then data= build_package
        when 'component' then data= component_package
        when 'NOW' then data= new Date()
        else
          data= context[first_part]
      for part in parts
        key= part.trim()
        data= data[key]
      String(data)
  else
    string

addProcessor= (type)->
  new Processor(type)

module.exports= {targetOf, validTarget, render, transpile, replaceTokens, addProcessor, Processor, ProcessorManager}


class ProcessorManager
  constructor: ->
    @processors= []
    @processorsByType= {}
    @processorsByExt= {}
    @extByType= []

  render: (resource, options, done)->
    proc= @processorFor resource
    proc.render resource, options, done

  processorFor: (res)->
    @processorsByExt[res.ext]

  targetForExt: (ext)->
    @processorsByExt[ext]?.type ? 'unknown'

  register: (processor)->
    @processors.push processor
    @processorsByType[processor.type]= processor
    for ext in processor.extensions
      @processorsByExt[ext]= processor
    @

  @instance: new @

manager= ProcessorManager.instance

class Processor
  constructor: (@type)->
    @extensions= []
    @requiredLibs= []
    @renderQueue=[]
    @warning= null
    @converter= null
    @builder= null

  ext: (exts...)->
    for ext in exts
      if ext[0] is '.'
        @extensions.push ext
      else
        @extensions.push ".#{ ext }"
    @
  
  requires: (reqs...)->
    @requiredLibs= reqs
    @
  
  warn: (msg)->
    @warning= msg
    @

  build: (builder)->
    @builder= if @warning?
      warning= @warning
      (args...)->
        log.info "   NOTE:", warning
        builder(args...)
    else
      builder
    manager.register(@)
    if @requiredLibs.length is 0
      @initialize()
    @

  # Rendering logic:

  initialize: ->
    return if @loading
    @loading= true
    _.tryRequireAll @requiredLibs, (err, libs)=>
      throw err if err?
      @converter= @builder.apply @builder, libs
      for queued in @renderQueue
        @render.apply @, queued
      @renderQueue=[]
      @loading= false
  
  render: (res, opts, done)->
    if @converter?
      log.debug " -", res.path
      o= _.defaults {}, current_file:res, opts
      try
        @converter res.content, o, (err, content)->
          return done err if err?
          res.content= content
          notify.afterRenderItem res
          done err, res
      catch ex
        file= "#{ res.path }#{ res.ext }"
        ex.name = "Processor Error"
        ex.message= "Processor Error for #{ file }: #{ ex.message }"
        log.error ex.message
        done ex, null, opts
    else
      log.trace " |", res.path, "(queued)"
      @renderQueue.push [res, opts, done]
      @initialize()

###
  Default Processors:
###

# JS
addProcessor('js').ext('.js')
  .build -> (source, opts, converted)->
    converted null, source, opts

# HTML
addProcessor('js').ext('.html')
  .build -> (source, opts, converted)->
    converted null, """module.exports=#{JSON.stringify source};""", opts

# JSON
addProcessor('js').ext('.json')
  .build -> (source, opts, converted)->
    data= JSON.parse source
    converted null, """module.exports=#{JSON.stringify data};""", opts

# COFFEESCRIPT
addProcessor('js').ext('.coffee', '.litcoffee')
  .requires('coffee-script')
  .build (coffee)-> (source, opts, converted)->
    options = _.defaults {}, (opts.coffee || {}),
      bare: yes
    options.literate= (opts.current_file.ext is '.litcoffee' || no)
    output= coffee.compile source, options
    converted null, output, opts

# ECO
addProcessor('js').ext('.eco')
  .requires('eco')
  .build (eco)-> (source, opts, converted)->
    output= eco.precompile source
    converted null, """module.exports= #{output};""", opts

# MUSTACHE
addProcessor('js').ext('.mustache')
  .requires('coffee-templates')
  .build (coffeeTmpl)-> (source, opts, converted)->
    output= coffeeTmpl.compile source
    converted null, """module.exports= #{output};""", opts

# EJS
addProcessor('js').ext('.ejs')
  .requires('ejs')
  .build (ejs)-> (source, opts, converted)->
    output= ejs.compile(source, client:true, compileDebug:false)
    converted null, """module.exports= #{output.toString()};""", opts

# DOT
addProcessor('js').ext('.dot')
  .requires('doT')
  .build (dot)-> (source, opts, converted)->
    options= _.defaults {}, (opts.dot || opts.doT || {}), {}
    output= dot.compile(source, options)
    converted null, """module.exports= #{ output.toString() }""", opts

# MARKDOWN
addProcessor('js').ext('.md', '.markdown')
  .requires('marked')
  .build (marked)-> (source, opts, converted)->
    options= _.defaults {}, (opts.marked || {}),
      gfm: true
      tables: true
      breaks: false
      pedantic: false
      sanitize: false
      smartLists: true
    output= marked(source, options)
    converted null, """module.exports=#{ JSON.stringify output };""", opts

# Be aware: These require a runtime component...

# # SETTEE MOVED TO PLUGIN!
# addProcessor('js').ext('.settee')
#   .requires('settee-templates')
#   .warn("Settee requires a runtime, be sure it's included in your page.")
#   .build (settee)-> (source, opts, converted)->
#     output= """
#       if(!this.settee) settee= require('settee');
#       module.exports=settee(#{ settee.precompile(source) });
#     """
#     converted null, output, opts

# JADE
addProcessor('js').ext('.jade')
  .requires('jade')
  .warn("Jade requires a runtime, be sure it's included in your page.")
  .build (jade)-> (source, opts, converted)->
    options= _.defaults {}, (opts.jade || {}),
      client: true
      compileDebug: false
    output= jade.compile(source, options)
    converted null, """module.exports= #{output.toString()};""", opts

# HOGAN
addProcessor('js').ext('.hogan')
  .requires('hogan.js')
  .warn("Hogan requires a runtime, be sure it's included in your page.")
  .build (hogan)-> (source, opts, converted)->
    options= _.defaults {}, (opts.hogan || {}),
      asString: 1
    output= hogan.compile(source, options)
    converted null, """module.exports= new Hogan.Template(#{output.toString()});""", opts

# HANDLEBARS
addProcessor('js').ext('.handlebars')
  .requires('handlebars')
  .warn("Handlebars requires a runtime, be sure it's included in your page.")
  .build (handlebars)-> (source, opts, converted)->
    options= _.defaults {}, (opts.handlebars || {}),
      simple: false
      commonjs: true
    output= handlebars.precompile(source, options)
    converted null, """module.exports= #{output.toString()};""", opts



# TODO: Add default converters for: yaml(?), others?

compile_less= (less, source, callback)->
  less.render source, callback

compile_stylus= (stylus, nib, source, opts, callback)->
  options= _.defaults {}, (opts.stylus || {}),
    filename: opts.current_file.filename || 'generated.css'
    paths: opts.load_paths
  stylus(source)
    .set('filename', opts.current_file.filename || 'generated.css')
    .set('paths', opts.load_paths)
    .set(options)
    .use(nib())
    .render callback

# Default CSS converters
addProcessor('css').ext('.css')
  .build -> (source, opts, converted)->
    converted null, source, opts

addProcessor('css').ext('.less')
  .requires('less')
  .build (less)-> (source, opts, converted)->
    compile_less less, source, (err, css)->
      converted err, null, opts if err?
      converted null, css, opts

addProcessor('css').ext('.styl')
  .requires('stylus', 'nib')
  .build (stylus, nib)->
    load_paths= [process.cwd(), path.dirname(__dirname)]
    (source, opts, converted)->
      opts.load_paths= load_paths
      compile_stylus stylus, nib, source, opts, (err, css)->
        if err?
          converted err, null, opts
        else
          converted null, css, opts


## Embedded CSS Support

#TODO: Should the processor be responsible for the embedded_css wrapper?
packager= require './packager'

addProcessor('js').ext('.ecss')
  .build -> (source, opts, converted)->
    converted null, packager.embedded_css(source), opts

addProcessor('js').ext('.eless')
  .requires('less')
  .build (less)-> (source, opts, converted)->
    compile_less less, source, (err, css)->
      converted err, null, opts if err?
      converted null, packager.embedded_css(css), opts

addProcessor('js').ext('.estyl')
  .requires('stylus', 'nib')
  .build (stylus, nib)->
    load_paths= [process.cwd(), path.dirname(__dirname)]
    (source, opts, converted)->
      opts.load_paths= load_paths
      compile_stylus stylus, nib, source, opts, (err, css)->
        if err?
          converted err, null, opts
        else
          converted null, packager.embedded_css(css), opts

# Add other ones too???