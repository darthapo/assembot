express= require 'express'
fs= require 'fs'
path= require 'path'
builder= require './builder'
_= require './util'
{puts, print, inspect}= require './util'

getConfigFor= (path, info)->
  for output, config of info
    unless config.text is 'meta'
      return config if config.output.path is path

exports.serve= (config, opts={})->
  # try
  #   builder.build config, opts
  # catch ex
  #   _.log "build error"
  #   _.log ex
  puts "Setting up dev server..."
  targets= builder.buildTargets(config, yes)
  app= express()
  port= config.port || opts.port || 8080
  project_root= process.cwd()
  root= path.resolve (config.wwwRoot || "#{ project_root }/public")
  puts "  root: #{root}"
  puts "  port: #{port}"

  app.get '/*', (req, res)->
    uri= req.params[0] || 'index.html'
    localpath= path.join(root, uri)
    if targets.indexOf(localpath) >= 0
      conf = getConfigFor localpath, config
      builder.buildTarget conf, (err, content)->
        if err?
          res.send 500, String(err)
        else
          res.send 200, content
    else
      if fs.existsSync localpath
        res.sendfile localpath
      else
        res.send 404, "Not Found"

  # app.use express.static(root)
  app.use express.errorHandler(
    dumpExceptions: true
    showStack: true
  )

  app.listen(port)
  puts " Ready! Visit http://127.0.0.1:#{ port }"
  