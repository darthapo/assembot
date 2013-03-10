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


  # OLD API
  


  debug: ->
    _.pp type_db

  addFor: (target, type, converter)->
    target= validType(target)
    type= validType(type)
    type_db[target].types.push type
    type_db[target].handlers[type]= (src,opts,callback)->
      try
        converter(src,opts,callback)
      catch ex
        file= "#{ opts.current_file.path }#{ opts.current_file.ext }"
        ex.name = "Processor Error"
        ex.message= "Processor Error for #{ file }: #{ ex.message }"
        callback ex, null, opts
    @

  validTypeFor: (target, ext)->
    target= validType(target)
    type= validType(ext)
    if type_db[target]? then (type in type_db[target].types) else false

  # Example: 
  #   convertor.buildSourceFor 'js', '/X.coffee', {}, (err, src, info)-> log src
  buildSourceFor: (target, fullpath, info, callback)->
    target= validType(target)
    ext= path.extname(fullpath)
    source= fs.readFileSync fullpath, 'utf8'
    converter= type_db[target].handlers[ext]
    converter @replaceTokens(String(source), info), info, callback
    @

  
addConvertor= (target, type, modules, handler)->
  modules= [modules] unless _.isArray modules
  loading= no
  queue= []
  api.addFor target, type, (origSrc, origOpts, origCallback)->
    queue.push [origSrc, origOpts, origCallback]
    unless loading
      loading= yes
      _.tryRequireAll modules, (err, libs)->
        throw new Error("Module(s) '#{ modules.join "'"}' cannot be loaded! #{err}") if err?
        converter= handler.apply handler, libs
        api.addFor target, type, converter
        converter.apply converter, arglist for arglist in queue
        true
          

addJsConvertor= (type, modules, handler)-> 
  if _.isArray type
    for thisType in type
      addConvertor 'js', thisType, modules, handler
  else
    addConvertor 'js', type, modules, handler
  true

addCssConvertor= (type, modules, handler)-> 
  addConvertor 'css', type, modules, handler

#
# Default Converters: 
#

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
    options = _.defaults {}, (opts.coffee || {}),
      bare: yes
    options.literate= (opts.current_file.ext is '.litcoffee' || no)
    output= coffee.compile source, options
    converted null, output, opts

addJsConvertor '.eco', 'eco', (eco)-> 
  (source, opts, converted)->
    output= eco.precompile source
    converted null, """module.exports= #{output};""", opts

addJsConvertor ['.mustache'], ['coffee-templates'], (coffee_templates)-> 
  (source, opts, converted)->
    output= coffee_templates.compile source
    converted null, """module.exports= #{output};""", opts

addJsConvertor '.ejs', 'ejs', (ejs)->
  (source, opts, converted)->
    output= ejs.compile(source, client:true, compileDebug:false)
    converted null, """module.exports= #{output.toString()};""", opts

addJsConvertor '.dot', 'doT', (dot)->
  (source, opts, converted)->
    options= _.defaults {}, (opts.dot || opts.doT || {}), {}
    output= dot.compile(source, options)
    # _.pp """module.exports= #{ output.toString() }"""
    converted null, """module.exports= #{ output.toString() }""", opts

addJsConvertor ['.md', 'markdown'], 'marked', (marked)->
  (source, opts, converted)->
    options= _.defaults {}, (opts.marked || {}),
      gfm: true
      tables: true
      breaks: false
      pedantic: false
      sanitize: false
      smartLists: true
    output= marked(source, options)
    # _.pp """module.exports= #{ output.toString() }"""
    converted null, """module.exports=#{ JSON.stringify output };""", opts

addJsConvertor '.settee', ['./settee'], (settee)->
  (source, opts, converted)->
    output= """
      if(!this.settee) settee= require('settee');
      module.exports=settee(#{JSON.stringify settee.settee.parse(source)});
    """
    converted null, output, opts


# These require a runtime component.. Use at your own risk.
addJsConvertor '.jade', 'jade', (jade)->
  _.puts "Jade requires a runtime, be sure it's included in your page."
  (source, opts, converted)->
    options= _.defaults {}, (opts.jade || {}),
      client: true
      compileDebug: false
    output= jade.compile(source, options)
    converted null, """module.exports= #{output.toString()};""", opts
addJsConvertor '.hogan', 'hogan.js', (hogan)->
  _.puts "Hogan requires a runtime, be sure it's included in your page."
  (source, opts, converted)->
    options= _.defaults {}, (opts.hogan || {}),
      asString: 1
    output= hogan.compile(source, options)
    converted null, """module.exports= new Hogan.Template(#{output.toString()});""", opts
addJsConvertor '.handlebars', 'handlebars', (handlebars)->
  _.puts "Handlebars requires a runtime, be sure it's included in your page."
  (source, opts, converted)->
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
addCssConvertor '.css', [], -> 
  (source, opts, converted)->
    converted null, source, opts

addCssConvertor '.less', 'less', (less)-> 
  (source, opts, converted)->
    compile_less less, source, (err, css)->
      converted err, null, opts if err?
      converted null, css, opts

addCssConvertor '.styl', ['stylus', 'nib'], (stylus, nib)->
  load_paths= [process.cwd(), path.dirname(__dirname)]
  (source, opts, converted)->
    opts.load_paths= load_paths
    compile_stylus stylus, nib, source, opts, (err, css)->
      if err?
        converted err, null, opts
      else
        converted null, css, opts

# Add other ones too???


## Embedded CSS Support

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

addJsConvertor '.ecss', [], -> 
  (source, opts, converted)->
    converted null, ecss_wrapper(source), opts

addJsConvertor '.eless', 'less', (less)-> 
  (source, opts, converted)->
    compile_less less, source, (err, css)->
      converted err, null, opts if err?
      converted null, ecss_wrapper(css), opts

addJsConvertor '.estyl', ['stylus', 'nib'], (stylus, nib)->
  load_paths= [process.cwd(), path.dirname(__dirname)]
  (source, opts, converted)->
    opts.load_paths= load_paths
    compile_stylus stylus, nib, source, opts, (err, css)->
      if err?
        converted err, null, opts
      else
        converted null, ecss_wrapper(css), opts

# Add other ones too???