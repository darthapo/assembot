###
 AssemBot CLI!
###

path= require 'path'
assbot= require './builder'

default_conf=
  "public/app.js":
    source: './source'
    ident: 'public'
  "public/theme.css":
    source: './source'

default_opts=
  coffee:
    bare: yes


# TODO: Look for -s to run server, or -w to watch for file changes

module.exports=
  run: ->
    here= process.cwd()
    nfo= try
      require "#{here}#{path.sep}package"
    catch ex
      console.log "No 'package.json' file found, using defaults!"
      empty=
        assembot: default_conf

    assbot_conf= unless nfo.assembot?
      console.log "No 'assembot' block in your package.json file found, using defaults!"
      default_conf
    else
      nfo.assembot
      
    assbot.build assbot_conf
      