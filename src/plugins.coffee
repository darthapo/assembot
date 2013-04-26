log= require './log'
notify= require './notify'
shelljs= require 'shelljs'
{Bot}= require './bot'
{addPackager}= require './packager'
{ResourceList, Resource}= require './resources'
{extend, defaults, type, tryRequire, tryRequireAll, tryRequireResolve}= _= require './util'
{targetOf, validTarget, render, transpile, replaceTokens, addProcessor, Processor, ProcessorManager}= processor= require './processor'
{before, after}= Bot
loadPlugin= load
# Build plugin_context
context= {
  before
  after
  log
  extend
  defaults
  processor
  addProcessor
  addPackager
  type
  tryRequire
  tryRequireAll
  tryRequireResolve
  loadPlugin # ?????
  shelljs
  Bot
  Resource
  ResourceList
  Processor
  ProcessorManager
}
context.on= Bot.on

initialized= no
_registry= {}
lastLibName= null

init= (options, preload...)->
  return false if initialized
  # options.callback.call(context, context) if options.callback?
  # Assemble a list of all the plugins to load and load 'em
  if options.plugins? and type(options.plugins) is 'array'
    preload= preload.concat options.plugins
  # These would be from the build config
  load plugin for plugin in preload
  options.callback.call(context, context) if options.callback?
  initialized= yes
  false # or true if any loaded

ident= (name, vocal=true)->
  if vocal
    log.info " =D-- #{name}"
  else
    log.debug " =D-- #{name}"
  lastLibName= name

load= (name)->
  # Load an individual plugin
  tryRequire name, (err, lib)->
    # Should they fail quitely?
    return log.error "Failure to load plugin #{ name }", err if err?
    
    lib.call(context, context, ident)
    unless lastLibName is null
      _registry[lastLibName]= lib
      lastLibName= null
    notify.emit 'plugin:loaded', name, lib


module.exports= {init, load, context}