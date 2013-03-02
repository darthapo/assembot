_= require './util'
fs= require 'fs'
path= require 'path'
defaults= require './defaults'
{Assembler}= require './assembler'
{ResourceList}= require './resources'

class Bot

  constructor: (@source, @options={})->
    @source= path.resolve @source
    @resources= new ResourceList @source
    @assembler= new Assembler @resources
    _.defaults @options, defaults.options

  get: (key)->
    @options[key]

  set: (keyOrHash, value)->
    if typeof keyOrHash is 'string'
      @options[keyOrHash]=value
    else
      for key, val of keyOrHash
        @options[key]= val
        
  # build: (target, options, callback)->
    # [options, callback]= _.validateOptionsCallback options, callback
  build: (target, callback)->
    @resources.scan (err)=>
      return callback err if err?
      # Process resources...
      @assembler.package target, (err, content)->
        callback err, content

  rebuild: @::build

  # serve: (options, callback)->
  #   [options, callback]= _.validateOptionsCallback options, callback
  #   _.puts "Serving"


module.exports= {Bot}