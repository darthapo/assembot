_= require './util'
fs= require 'fs'
log= require './log'
path= require 'path'
express= require 'express'
notify= require './notify'
{test}= require 'shelljs'
{assembot, loadOptions}= require './index'

project_root= process.cwd()

build_middleware= (bots, config)->
  {paths}= config
  bot_by_path= {}
  bot_by_path[bot.output]= bot for bot in bots

  bot_for= (url)->
    for uri, filepath in paths
      localpath= path.resolve path.join(filepath, url)
      if bot= bot_by_path[localpath]
        return bot
    return false

  (req, res, next)->
    url= req.url?[1..] # strip the leading /
    if bot= bot_for url
      log.info "Rebuilding:", bot.target
      bot.build (content)-> 
        contentType= switch bot.target
          when 'js' then 'application/javascript'
          when 'css' then 'text/css'
          else 'text/html'
        res.set 'Content-Type', contentType
        res.send 200, content
    else
      next()


exports.start= (bots, options)->
  log.debug "Configuration"
  conf= options.http
  app= express()

  log.debug conf
  # log.debug bots
  log.info "Serving", bots.length, "packages..."

  notify.createServer app, options

  app.use express.errorHandler( dumpExceptions:yes, showStack:yes )
  app.use express.logger()
  app.use build_middleware(bots, conf)

  log.info "Mounting paths:"
  for uri, filepath of conf.paths
    log.info "  #{ uri } -> #{ filepath }"
    app.use uri, express.static(filepath)

  notify.startServer app, options

  app.listen(conf.port)
  log.info " Ready! Visit http://127.0.0.1:#{ conf.port }"

