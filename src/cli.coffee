###
 AssemBot CLI!
###

path= require 'path'
_= require './util'
assbot= require './builder'
defaults= require './defaults'

# TODO: Look for -s to run server, or -w to watch for file changes

module.exports=
  run: ->
    project_root= process.cwd()
    options= {} # TODO: grab options from cmdline
    options= _.defaults options, defaults.options
    assembot_info= require '../package'

    nfo= try
      require "#{project_root}#{path.sep}package"
    catch ex
      console.log "No 'package.json' file found, using defaults!"
      empty=
        assembot: defaults.assembot

    assbot_conf= unless nfo.assembot?
      console.log "No 'assembot' block in your package.json file found, using defaults!"
      defaults.assembot
    else
      nfo.assembot
    # _.defaults assbot_conf, defaults.config
    assbot_conf.package= nfo
    assbot_conf.assembot= assembot_info
    # console.log assbot_conf
    assbot.build assbot_conf, options
      