util= require 'util'
fs= require 'fs'
path= require 'path'

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
exports.tryRequire= (name)->
  try
    require name
  catch ex
    require "#{ process.cwd() }/node_modules/#{name}"

exports.tryRequireLocalFirst= (name)->
  try
    require "#{ process.cwd() }/node_modules/#{name}"
  catch ex
    require name
    

exports.extend exports, util