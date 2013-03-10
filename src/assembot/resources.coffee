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
    @list= []
    @length= 0

  each: (callback)->
    for resource,i in @list
      callback resource, i
    @

  forTarget: (target)->
    resource for resource in @list when resource.target is target

  eachForTarget: (target, callback)->
    callback resources, i for resource, i in @forTarget(target)
    @

  add: (resource)->
    @list.push resource
    @length += 1
    @

  treeForTarget: (target)->
    tree={}
    for resource in @forTarget(target)
      tree[resource.path]= resource
    tree


resourcelist= (filepath)->
  ResourceList.fromPath filepath

module.exports= {Resource, ResourceList, resourcelist}