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
      # Dive into the directory 
      callback filename, fullpath, true unless files_only
      walk fullpath, callback
    else
      # Call the callback
      callback filename, fullpath, false
  file_list

# This may only be needed when using Assembot with npm link, I'm not sure.
exports.tryRequire= (name, callback)->
  # _.log "tryRequire('#{ name }')"
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
    
# exports.tryRequireLocalFirst= (name, callback)->
#   localRequire name, (err, lib)->
#     if err?
#       try
#         lib= require name
#         callback null, lib
#       catch ex
#         callback ex, null
#     else
#       callback null, lib

_= exports

loaded_libs= {}
loading_now= {}

localRequire= (name, callback)->
  if loaded_libs[name]?
    # _.puts "RMOTE LIB CACHE FOR: #{name}"
    callback(null, loaded_libs[name]) 
    return
  # _.puts "Local require #{name}"
  if loading_now[name]?
    # _.puts "Adding to load queue (#{name})"
    loading_now[name].push callback
    return
  else
    loading_now[name]= []
    loading_now[name].push callback

  # _.puts "LOADING REMOTE LIB (#{name})"

  cmd= "#{process.execPath} -p -e \"require.resolve('#{ name }')\""
  # _.log cmd
  child= exec cmd, (stdin, stdout, stderr)->
    # if stderr isnt ''
    #   _.log "STDERR OUTPUT!"
    #   _.pp stderr      
    libpath= stdout.trim()
    if libpath is ''
      err= new Error("Could not load '#{name}' module. (no local path)")
      for cb in loading_now[name]
        # _.log " >> error callback (#{name})"
        cb err, null
      delete loading_now[name]
      # callback(new Error("Could not load '#{name}' module. (no local path)"), null) 
    try
      # _.log "Loading: #{libpath}"
      lib= require libpath
      loaded_libs[name]= lib
      for cb in loading_now[name]
        # _.log " >> callback (#{name})"
        # _.pp cb.toString()
        cb null, lib
      delete loading_now[name]

    catch ex
      # _.log "Exception!"
      for cb in loading_now[name]
        # _.log " >> error callback (#{name})"
        cb ex, null
      delete loading_now[name]
      # callback ex, null
  true

exports.extend exports, util