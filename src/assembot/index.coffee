###

Stages:

  - Content tree generation
  - Preprocess (unshift user added preprocessors)
  - Process (transpile)
  - Postprocess (?)
  - Assemble (build into commonjs library or single css file)
  - Minify


###

defaults= require './defaults'
_= require './util'
{Assembler}= require './assembler'
{Bot}= require './bot'
{Resource, ResourceList}= require './resources'
# TODO Add
#  packager
#  processor


### Usage:
  bot= assembot('./source')
  bot.build minify:yes, -> console.log 'done' ###
assembot= (source, options={})->
  new Bot source, options

  

module.exports={assembot, defaults, _, Assembler, Resource, ResourceList, Bot}