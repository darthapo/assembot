
log= require('./log')
defaults= require './defaults'
_= require './util'
path= require 'path'
packager= require './packager'
processor= require './processor'
project_root= process.cwd()
{resourcelist}= require './resources'
{assembler}= require './assembler'
{Bot}= require './bot'


loadFirstLocalPackage= (names...)->
  for name in names
    try
      data= require "#{ project_root }#{ path.sep }#{ name }"
      if data.assembot?
        log.debug "Loaded #{ name }.json"
        return data.assembot
      else
        throw new Error "No Assembot block"
    catch ex
      log.debug "No '#{ name }.json' file found!"
  log.debug "No configuration found, using defaults!"
  defaults

loadTargets= ->
  nfo= loadFirstLocalPackage 'package', 'component', 'build', 'assembot'
  options= nfo.options ? defaults.options
  src_targets= nfo.targets ? defaults.targets
  targets= {}
  for tgt, opts of src_targets
    tgt_opts= _.defaults {}, opts, options, defaults.options
    targets[tgt]= tgt_opts
  targets

loadOptions= ->
  nfo= loadFirstLocalPackage 'package', 'component', 'build', 'assembot'
  nfo.options ? defaults.options
  
assembot= (target, options={})->
  new Bot target, options
  
module.exports={assembot, defaults, assembler, resourcelist, loadTargets, packager, processor, loadOptions}