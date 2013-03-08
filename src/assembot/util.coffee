util= require 'util'
fs= require 'fs'
path= require 'path'
{spawn, exec}= require 'child_process'

pp= (obj)-> 
  util.puts util.inspect obj

extend= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        obj[key]= value
  obj
      
defaults= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        unless obj[key]?
          obj[key]= value
  obj

type= do ->
  toStr= Object::toString
  elemParser= /\[object HTML(.*)\]/
  classToType= {}
  for name in "Boolean Number String Function Array Date RegExp Undefined Null NodeList".split(" ")
    classToType["[object " + name + "]"] = name.toLowerCase()
  (obj) ->
    strType = toStr.call(obj)
    if found= classToType[strType]
      found
    else if found= strType.match(elemParser)
      found[1].toLowerCase()
    else
      "object"

# walk= (dir, done)->
#   results= []
#   fs.readdir dir, (err, list)->
#     return done(err) if err?
#     pending = list.length
#     return done(null, results) unless pending
#     list.forEach (file)->
#       filepath = "#{ dir }#{ path.sep }#{ file }"
#       fs.stat filepath, (err, stat)->
#         if stat.isDirectory()
#           walk filepath, (err, res)->
#             results= results.concat(res)
#             done(null, results) if (!--pending)
#         else
#           results.push(filepath)
#           done(null, results) if (!--pending)
#     null

# walkSync= (dir, callback, files_only=yes)->
#   file_list= fs.readdirSync dir
#   for filename in file_list
#     fullpath= [dir, filename].join path.sep
#     stat= fs.statSync fullpath
#     if stat.isDirectory()
#       callback fullpath, filename, true unless files_only
#       walkSync fullpath, callback
#     else
#       callback fullpath, filename, false
#   file_list

validateOptionsCallback= (options, callback)->
  if typeof options is 'function'
    [{}, options]
  else
    [options, callback]

tryRequire= (name, callback)->
  if name is null or name is ''
    callback null, {} 
    return
  if loaded_libs[name]? 
    callback null, loaded_libs[name]
    return
  try
    lib= require name
    loaded_libs[name]= lib
    callback null, lib
  catch ex
    localRequire name, callback

tryRequireAll= (names, callback)->
  if names.length is 0
    callback(null, [])
    return
  libs=[]
  libnames= names.slice()
  nextLib= libnames.shift()
  loader= (err, lib)->
    if err?
      callback err, null
    else
      libs.push lib
      if libnames.length is 0
        callback null, libs
      else
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

localRequire= (name, callback)->
  return false if isAlreadyLoaded(name, callback)
  cmd= "#{process.execPath} -p -e \"require.resolve('#{ name }')\""
  child= exec cmd, (stdin, stdout, stderr)->
    libpath= stdout.trim()
    if libpath is ''
      err= new Error("Could not load '#{name}' module. (no local path)")
      for cb in loading_now[name]
        cb err, null
    else
      try
        lib= require libpath
        loaded_libs[name]= lib
        for cb in loading_now[name]
          cb null, lib
      catch ex
        for cb in loading_now[name]
          cb ex, null
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
  localRequire
}

extend module.exports, util

