_= require './util'
path= require 'path'
{EventEmitter}= require 'events'
{ResourceList}= require './resources'
defaults= require './defaults'
packager= require './packager'

class Assembler extends EventEmitter

  constructor: (@resources)->

  package: (type, options, callback)->
    [options, callback]= _.validateOptionsCallback options, callback
    switch type
      when 'js' then packager.js @resources, options, callback
      when 'css' then packager.css @resources, options, callback
      else callback new Error("Unknown package type '#{type}'")
    @



module.exports= {Assembler}
