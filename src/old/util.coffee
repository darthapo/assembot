util= require 'util'
fs= require 'fs'
path= require 'path'
spawn= require('child_process').spawn
exec= require('child_process').exec

exports.pp= (obj)-> util.puts util.inspect obj

exports.extend= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        obj[key]= value
  obj
      
exports.defaults= (obj)->
  for source in Array::slice.call(arguments, 1)
    if source
      for key,value of source
        unless obj[key]?
          obj[key]= value
  obj

exports.walkTree= walk=(dir, callback, files_only=yes)->
  file_list= fs.readdirSync dir
  for filename in file_list
    fullpath= [dir, filename].join path.sep
    stat= fs.statSync fullpath
    if stat.isDirectory()
      # Keep on walkin...
      callback filename, fullpath, true unless files_only
      walk fullpath, callback
    else
      # Call back...
      callback filename, fullpath, false
  file_list

exports.tryRequire= (name, callback)->
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

exports.tryRequireAll= (names, callback)->
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
        exports.tryRequire nextLib, loader

  exports.tryRequire nextLib, loader

_= exports

loaded_libs= {}
loading_now= {}

localRequire= (name, callback)->
  if loaded_libs[name]?
    callback(null, loaded_libs[name]) 
    return
  if loading_now[name]?
    loading_now[name].push callback
    return
  else
    loading_now[name]= []
    loading_now[name].push callback

  cmd= "#{process.execPath} -p -e \"require.resolve('#{ name }')\""
  child= exec cmd, (stdin, stdout, stderr)->
    libpath= stdout.trim()
    if libpath is ''
      err= new Error("Could not load '#{name}' module. (no local path)")
      for cb in loading_now[name]
        cb err, null
      delete loading_now[name]
    try
      lib= require libpath
      loaded_libs[name]= lib
      for cb in loading_now[name]
        cb null, lib
      delete loading_now[name]
    catch ex
      for cb in loading_now[name]
        cb ex, null
      delete loading_now[name]
  true

exports.extend exports, util