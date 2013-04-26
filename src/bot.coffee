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
    @content= ""
    @returnContent= null
    @userCallbackForCompletion= null
    notify.createBot @

  config: (options={})->
    @options= _.defaults options, @options, defaults.options # ... overkill?
    @output= path.resolve @options.output
    @source= if typeof @options.source is 'string'
      path.resolve @options.source
    else
      null
    @target= processor.targetOf(@output)
    @

  # Send a callback to get the generated content instead of saving it to
  # the target file
  build: (callback)->
    if @options.enable is no
      log.debug @output, 'is disabled'
      @built= yes
      callback(@content) if callback?
      return @
    else
      log.debug @output, 'is being built'
    
    if log.level() > 0
      _.print "Building #{@options.output}"
      # log.info "Building", @output

    @returnContent= callback ? null
    notify.beforeBuild @

    notify.beforeScan @
    @resources= resourcelist(@source)
    notify.afterScan @

    notify.beforeRender @
    processor.render @resources.forTarget(@target), @options, @didRender
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
    assembler @target, @resources.forTarget(@target), @options, @didAssemble

  didAssemble: (err, @content)=>
    throw err if err?
    notify.afterAssemble @

    @writeContent()

  writeContent: ->
    notify.afterBuild @
    notify.beforeWrite @

    if @returnContent?
      log.debug "Returning content to callback", path.relative(process.cwd(), @output)
      @returnContent(@content)
      @userCallbackForCompletion?()
    else
      log.debug "Writing", path.relative(process.cwd(), @output)
      @content.to @output
      notify.afterWrite @
      @built= yes
      @userCallbackForCompletion?()

  rebuild: @::build

  flush: ->
    delete @resources
    delete @content
    @built= no

bot= (output, options)->
  new Bot output, options

module.exports= {Bot, bot}