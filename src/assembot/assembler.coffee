_= require './util'
path= require 'path'
defaults= require './defaults'
packager= require './packager'
# {EventEmitter}= require 'events'

class Assembler #extends EventEmitter

  constructor: (@target)->

  package: (resources, options, callback)->
    [options, callback]= _.validateOptionsCallback options, callback
    if _.type(resources) isnt 'array'
      resources= resources.forTarget @target
    switch @target
      when 'js' then packager.js resources, options, callback
      when 'css' then packager.css resources, options, callback
      else callback new Error("Unknown package target '#{@target}'")
    @


assembler= (target, resources, options, callback)->
  asm= new Assembler target
  asm.package resources, options, callback

module.exports= {Assembler, assembler}
