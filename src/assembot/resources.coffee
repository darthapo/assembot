path= require 'path'
fs= require 'fs'
_= require './util'
processor= require './processor'
log= require('./log')
{ls, cat, test}= require 'shelljs'
{EventEmitter}= require 'events'

class Resource
  # File path should be relative to the source root, not including the source dirname
  constructor: (@filepath, @content)->
    log.debug " -", @filepath
    @disable= no
    @ext= path.extname(@filepath)
    @type= @ext[1...]
    @target= processor.targetOf(@filepath) # returns 'js', 'css', 'unknown'
    @path= @filepath.replace @ext, ''

class ResourceList

  @fromPath: (sourcePath)->
    log.debug "Resources loaded from", sourcePath
    reslist= new ResourceList
    sourcePath= path.resolve sourcePath
    fileset= ls '-R', sourcePath
    for filename in fileset
      filepath= path.join sourcePath, filename
      continue unless test('-f', filepath)
      contents= cat(filepath)
      res= new Resource filename, contents
      reslist.add res
    reslist

  constructor: ()->
    @tree= {}
    @length= 0

  each: (callback)->
    i=0
    callback resource, i++ for key, resource of @tree
    @

  forTarget: (target)->
    resource for key, resource of @tree when resource.target is target

  eachForTarget: (target, callback)->
    i=0
    for key, resource of @tree
      callback resource, i++ if resource.target is target
    @

  add: (resource)->
    if @tree[resource.path]?
      log.info "Warning: redefining module '#{ resource.path }'"
    @tree[resource.path]= resource
    @length += 1
    @

resourcelist= (filepath)->
  ResourceList.fromPath filepath

module.exports= {Resource, ResourceList, resourcelist}