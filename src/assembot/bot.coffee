_= require './util'
fs= require 'fs'
path= require 'path'
defaults= require './defaults'
log= require('./log')
packager= require './packager'
processor= require './processor'
notify= require './notify'
{echo}= require 'shelljs'
{assembler}= require './assembler'
{resourcelist}= require './resources'

class Bot

  @vent: notify

  @on: (event, listener)-> notify.on event, listener
  @before: (event, listener)-> notify.on "before:#{ event }", listener
  @after: (event, listener)-> notify.on "after:#{ event }", listener

  constructor: (output, options={})->
    options.output= output if output?
    @options= {}
    @config(options)
    @built= no
    @returnContent= null
    @userCallbackForCompletion= null
    notify.createBot @

  config: (options={})->
    @options= _.defaults options, @options, defaults.options # ... overkill?
    @output= path.resolve @options.output
    @source= path.resolve @options.source
    @target= processor.targetOf(@output)
    @

  # Send a callback to get the generated content instead of saving it to
  # the target file
  build: (callback)->
    @returnContent= callback ? null
    notify.beforeBuild @

    notify.beforeScan @
    @resources= resourcelist(@source).forTarget @target
    notify.afterScan @

    notify.beforeRender @
    processor.render @resources, @options, @didRender
    @

  # Send a callback to be notified when the build has run to completion.
  then: (callback)->
    @userCallbackForCompletion= callback
    @userCallbackForCompletion?() if @built
    @

  # Callback handlers for build process...

  didRender: (err)=>
    throw err if err?
    notify.afterRender @

    notify.beforeAssemble @
    assembler @target, @resources, @options, @didAssemble

  didAssemble: (err, @content)=>
    throw err if err?
    notify.afterAssemble @

    @writeContent()

  writeContent: ->
    notify.afterBuild @
    notify.beforeWrite @

    if @returnContent?
      log.info "Returning content to callback", @output
      @returnContent(@content)
      @userCallbackForCompletion?()
    else
      log.info "Writing", @output
      @content.to @output
      notify.afterWrite @
      @built= yes
      @userCallbackForCompletion?()

  rebuild: @::build

bot= (output, options)->
  new Bot output, options

module.exports= {Bot, bot}