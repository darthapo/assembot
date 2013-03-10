util= require 'util'
fs= require 'fs'
{exec}= require 'shelljs'
path= require 'path'
# {spawn, exec}= require 'child_process'

pp= (obj)-> 
  util.puts util.inspect obj

extend= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        obj[key]= value
  obj

# Merge deeper objects? 
defaults= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        unless obj[key]?
          obj[key]= value
        else if type(obj[key]) is 'object'
          obj[key]= defaults {}, obj[key], value
  obj

type= do ->
  toStr= Object::toString
  elemParser= /\[object HTML(.*)\]/
  classToType= {}
  for name in "Boolean Number String Function Array Date RegExp Undefined Null NodeList".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()
  (obj) ->
    strType= toStr.call(obj)
    if found= classToType[strType]
      found
    else if found= strType.match(elemParser)
      found[1].toLowerCase()
    else
      "object"

validateOptionsCallback= (options, callback)->
  if typeof options is 'function'
    [{}, options]
  else
    [options, callback]

tryRequireResolve= (name, callback)->
  try
    path= require.resolve name
    callback null, path
  catch ex
    localResolve name, callback


tryRequire= (name, callback)->
  return callback(null, {}) if name is null or name is ''
  return callback(null, loaded_libs[name]) if loaded_libs[name]? 
  try
    lib= require name
    loaded_libs[name]= lib
    callback null, lib
  catch ex
    localRequire name, callback

tryRequireAll= (names, callback)->
  return callback(null, []) if names.length is 0
  libs=[]
  libnames= names.slice()
  nextLib= libnames.shift()
  loader= (err, lib)->
    return callback err, null if err?
    libs.push lib
    return callback null, libs if libnames.length is 0
    nextLib= libnames.shift()
    tryRequire nextLib, loader
  tryRequire nextLib, loader

loaded_libs= {}
loading_now= {}

isAlreadyLoaded= (name, callback)->
  if loaded_libs[name]?
    callback(null, loaded_libs[name]) 
    return true
  if loading_now[name]?
    loading_now[name].push callback
    true
  else
    loading_now[name]= []
    loading_now[name].push callback
    false

localResolve= (name, callback)->
  cmd= "#{process.execPath} -p -e \"require.resolve('#{ name }')\""
  result= exec(cmd, silent:yes)
  libpath= result.output.trim()
  if result.code != 0 or libpath is ''
    callback new Error("Could not load '#{name}' module. (no local path)")
  else
    callback null, libpath

localRequire= (name, callback)->
  return false if isAlreadyLoaded(name, callback)
  if name[..1] is './'
    libpath= path.resolve(name)
    try
      lib= require libpath
      loaded_libs[name]= lib
      cb null, lib for cb in loading_now[name]
    catch ex
      cb ex, null for cb in loading_now[name]
    delete loading_now[name]
  else
    localResolve name, (err, libpath)->
      return (cb err, null for cb in loading_now[name]) if err?
      try
        lib= require libpath
        loaded_libs[name]= lib
        cb null, lib for cb in loading_now[name]
      catch ex
        cb ex, null for cb in loading_now[name]
      delete loading_now[name]
  true


module.exports= {
  pp
  extend
  defaults
  type
  validateOptionsCallback
  tryRequire
  tryRequireAll
  tryRequireResolve
  localRequire
}

extend module.exports, util

