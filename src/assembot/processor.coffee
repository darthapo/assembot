path= require 'path'
_= require './util'

targetOf= (filepath)->
  # Based on ext
  # TEMP
  ext= path.extname filepath
  switch ext
    when '.js' then 'js'
    when '.coffee' then 'js'
    when '.css' then 'css'
    when '.styl' then 'css'
    else 'unknown'

validTarget= (filepath)->
  targetOf(filepath) isnt 'unknown'

render= (resource, options, done)->
  # preprocess resource.content (replaceTokens)
  # transpile
  # callback

transpile= (resource, options, done)->
  # get transpiler for resource.type
  # update resource.content with transpiled result
  # callback

replaceTokens= (string, context)->

addProcessor= (type, ext, modules, handler)->

module.exports= {targetOf, validTarget, render, transpile, replaceTokens, addProcessor}
