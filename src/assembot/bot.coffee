_= require './util'
fs= require 'fs'
path= require 'path'
defaults= require './defaults'
log= require('./log')
packager= require './packager'
processor= require './processor'
{echo}= require 'shelljs'
{assembler}= require './assembler'
{resourcelist}= require './resources'

class Bot

  constructor: (@output, @options={})->
    throw new Error "Options must specify source dir!" unless @options.source?
    _.defaults @options, defaults.options # ... overkill?
    @output= path.resolve @output
    @source= path.resolve @options.source
    @target= processor.targetOf(@output)

  build: (callback)->
    resources= resourcelist(@source).forTarget @target
    processor.render resources, @options, (err)=>
      assembler @target, resources, @options, (err, content)=>
        if callback?
          callback err, content
        else
          throw err if err?
          log.info "Saving to", @output
          # TODO: Minify!!!
          content.to @output

  rebuild: @::build


module.exports= {Bot}