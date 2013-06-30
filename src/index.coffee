require 'coffee-script'
log= require('./log')
defaults= require './defaults'
_= require './util'
path= require 'path'
packager= require './packager'
plugins= require './plugins'
processor= require './processor'
project_root= process.cwd()
{resourcelist}= require './resources'
{assembler}= require './assembler'
{Bot}= require './bot'

loadedFrom= null
loadedOptions= null

loadFirstLocalPackage= (names...)->
  return loadedOptions if loadedOptions?
  for name in names
    try
      data= require "#{ project_root }#{ path.sep }#{ name }"
      if data.assembot?
        loadedFrom= name
        log.debug "Loaded config from", name
        loadedOptions= data.assembot
        return data.assembot
      else
        throw new Error "No Assembot block"
    catch ex
      log.trace "No '#{ name }' file found!"
  loadedFrom= 'defaults'
  loadedOptions= defaults

loadTargets= (options)->
  nfo= options ? loadFirstLocalPackage 'package.json', 'component.json', 'build.json', 'assembot'
  options= nfo.options ? defaults.options
  src_targets= nfo.targets ? defaults.targets
  targets= {}
  for tgt, opts of src_targets
    tgt_opts= _.defaults {}, opts, options, defaults.options
    targets[tgt]= tgt_opts
  targets

loadOptions= (returnDefaults)->
  nfo= loadFirstLocalPackage 'package.json', 'component.json', 'build.json', 'assembot'
  if returnDefaults is false
    if nfo is defaults
      return null
    else
      loadedFrom
  else
    nfo.options ? defaults.options
  
assembot= (target, options={})->
  plugins.init(
    options
    './plugins/header'
    './plugins/minify'
    './plugins/prune'
    './plugins/settee-templates'
  )
  new Bot target, options
  
module.exports= {
  assembot
  defaults
  assembler
  resourcelist
  loadTargets
  packager
  processor
  loadedFrom
  loadOptions
  loadFirstLocalPackage
  _
}