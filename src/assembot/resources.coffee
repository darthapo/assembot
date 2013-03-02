path= require 'path'
fs= require 'fs'
_= require './util'
{EventEmitter} = require 'events'
processor= require './processor'


class Resource
  constructor: (@filepath, @content)->
    @disable= no
    @ext= path.extname(@filepath)
    @type= @ext[1...]
    @target= processor.targetOf(@filepath) # returns 'js', 'css', 'unknown'
    @path= @filepath.replace @ext, ''

  @fromFile: (filename, callback)-> 
    fs.readFile filepath, (err, contents)->
      res= new Resource filename, contents.toString() unless err?
      callback(err, res)

###
  Callback: (err, resources, resourceList)->
###
class ResourceList extends EventEmitter

  constructor: (@source, @didLoadCallback)->
    @source= path.resolve @source
    @tree= null
    @errors= null
    @length= 0
    @ready= no
    @_loadCount= 0
    @scan(@didLoadCallback) if @didLoadCallback?

  each: (callback)->
    i=0
    callback resource, i++ for key, resource of @tree
    @

  eachForTarget: (target, callback)->
    i=0
    for key, resource of @tree
      callback resource, i++ if resource.target is target
    @

  scan: (callback)->
    @didLoadCallback= callback if callback?
    @ready= no
    @tree= {}
    @errors= []
    @length= 0
    @_loadCount= 0
    _.walk @source, @_addFileset
    @

  rescan: @::scan

  _addFileset: (err, files)=>
    if err?
      @didLoadCallback err, null
      @emit 'error', err
      return
    @length= 0
    files.forEach (filepath)=>
      if processor.validTarget filepath
        @length++
        callback= @fileDidLoad
        fs.readFile filepath, (err, contents)->
          callback err, filepath, contents.toString()
    @

  fileDidLoad: (err, filepath, contents)=>
    @_loadCount += 1
    if err?
      @errors.push err 
    else
      res= new Resource @getSourcePathFor(filepath), contents
      @tree[res.path]= res
    if @_loadCount == @length
      @ready= yes
      error= null
      if @errors.length > 0
        error = new Error "ResourceList: Load Errors"
        error.errors= @errors
        @emit 'error', error
      @emit 'load', errors:error, tree:@tree, list:this
      @emit 'ready'
      @didLoadCallback(error, @tree, this) if @didLoadCallback?
  @

  getSourcePathFor: (fullpath)->
    fullpath.replace "#{ @source }/", ''


  @scan: (source, callback)->
    new ResourceList source, callback


module.exports= {Resource, ResourceList}