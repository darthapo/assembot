path= require 'path'
fs= require 'fs'
_= require './util'
project_root= process.cwd()

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
        # console.log "MATCHED:", value
        data= info
        for part in value.split('.')
          key= part.trim()
          data= data[key]
        String(data)
    else
      string
  

#
# Default Converters: 
#

addConvertor= (target, type, modules, handler)->
  try
    modules= [modules] unless _.isArray modules
    args=[]
    for module in modules
      args.push _.tryRequireLocalFirst module
    converter= handler.apply handler, args
    api.addFor target, type, converter
  catch ex
    # Could not load requirement
    api.addFor target, type, -> throw "Module(s) '#{ modules.join "'"}' cannot be found!"

addJsConvertor= (type, modules, handler)->
  addConvertor 'js', type, modules, handler
addCssConvertor= (type, modules, handler)->
  addConvertor 'css', type, modules, handler


# Default JS converters
addJsConvertor '.js', [], -> 
  (source, opts, converted)->
    converted null, source, opts

addJsConvertor '.html', [], -> 
  (source, opts, converted)->
    converted null, """module.exports=#{JSON.stringify source};""", opts

addJsConvertor '.coffee', 'coffee-script', (coffee)-> 
  (source, opts, converted)->
    opts = opts.coffee || {}
    opts.bare ?= yes
    output= coffee.compile source, opts
    converted null, output, opts

addJsConvertor '.litcoffee', 'coffee-script', (coffee)-> 
  (source, opts, converted)->
    opts = opts.coffee || {}
    opts.bare ?= yes
    opts.literate ?= yes
    output= coffee.compile source, opts
    converted null, output, opts

addJsConvertor '.eco', 'eco', (eco)-> 
  (source, opts, converted)->
    output= eco.precompile source
    converted null, output, opts

addJsConvertor '.json', [], -> 
  (source, opts, converted)->
    data= JSON.parse source
    converted null, """module.exports= #{JSON.stringify data};""", opts

# TODO: Add default converters for: yaml(?), ejs, handlebars, jade, others?

# Default CSS converters
addCssConvertor '.css', [], -> 
  (source, opts, converted)->
    converted null, source, opts

addCssConvertor '.less', 'less', (less)-> 
  (source, opts, converted)->
    output= less.precompile source
    converted null, output, opts

addCssConvertor '.styl', ['stylus', 'nib'], (stylus, nib)-> 
  (source, opts, converted)->
    stylus(source)
      .set('filename', opts.filename || 'generated.css')
      .set('paths', [opts.loadpath])
      .use(nib)
      .render (err, css)->
        if err?
          converted err, null, opts
        else
          converted null, css, opts

# Add other ones too???