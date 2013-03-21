path= require 'path'
fs= require 'fs'
_= require './util'
processor= require './processor'
log= require('./log')
{ls, cat, test}= require 'shelljs'
{EventEmitter}= require 'events'

class Resource
  # File path should be relative to the source root, not including the source dirname
  constructor: (@filepath, @content, @extra={})->
    log.debug " -", @filepath
    # @disable= no
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
      res= new Resource filename, contents, sourcePath:sourcePath
      reslist.add res
    reslist

  constructor: ()->
    @list= []
    @pathsByTarget={}
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

  add: (resource, safely)->
    paths= (@pathsByTarget[resource.target] ||= [])
    if resource.path in paths
      throw new Error "Duplicate resource path!" unless safely
    else
      @list.push resource
      paths.push resource.path
      @length += 1
    @

  push: @::add

  get: (targetPath)->
    for res in @list
      return res if res.path is targetPath
    null

  blacklist: (pathlist)->
    list= @list.slice()
    @list= []
    for res in list
      @list.push res unless res.path in pathlist
    @length= @list.length
    @

  whitelist: (pathlist)->
    list= @list.slice()
    @list= []
    for res in list
      @list.push res if res.path in pathlist
    @length= @list.length
    @

  treeForTarget: (target)->
    tree={}
    for resource in @forTarget(target)
      tree[resource.path]= resource
    tree


resourcelist= (filepath)->
  ResourceList.fromPath filepath

module.exports= {Resource, ResourceList, resourcelist}