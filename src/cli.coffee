###
 AssemBot CLI!
###

path= require 'path'
fs= require 'fs'
_= require './util'
builder= require './builder'
server= require './server'
defaults= require './defaults'
optparse = require 'optparse'

module.exports=
  run: ->
    command= 'help'
    project_root= process.cwd()
    options= _.extend {}, defaults.options
    assembot_info= require '../package'

    parser = new optparse.OptionParser [
      ['-b', '--build', 'Run build']
      ['-s', '--serve', 'Run dev server']
      ['-f', '--files', 'Shows the build targets and associated files']
      ['-d', '--debug', 'Shows internal build config data']
      ['-p', '--port [PORT]', "Set dev server port"]
      ['-r', '--root [PATH]', 'Set dev server root path']
      ['-m', '--minify [LEVEL]', 'Force minification 0=none 1=minify 2=mangle']
      ['-c', '--modules', 'Shows the commonjs modules for .js build targets']
      ['-v', '--version', 'Shows version number']
      ['-h', '--help', 'Shows help']
    ]

    parser.banner = 'Usage: assembot [options]';

    parser.on 'build',   (name, value)-> command= name
    parser.on 'help',    (name, value)-> command= name
    parser.on 'debug',   (name, value)-> command= name
    parser.on 'files',   (name, value)-> command= name
    parser.on 'minify',  (name, value)-> options.minify= parseInt value || "1"
    parser.on 'modules', (name, value)-> command= name
    parser.on 'port',    (name, value)-> options.port= value
    parser.on 'serve',   (name, value)-> command= name
    parser.on 'version', (name, value)-> command= name
    parser.on 'root',    (name, value)-> 
      newRoot= path.resolve(value)
      if fs.existsSync newRoot
        options.wwwRoot= newRoot
      else
        _.log "Not a valid path: #{ newRoot }"
    parser.on '*',       (name, value)-> _.puts "Unknown option: #{name}"

    parser.parse process.argv

    nfo= try
      require "#{project_root}#{path.sep}package"
    catch ex
      console.log "No 'package.json' file found, using defaults!"
      empty=
        assembot: _.extend {}, defaults.assembot

    assbot_conf= unless nfo.assembot?
      console.log "No 'assembot' block in your package.json file found, using defaults!"
      _.extend {}, defaults.assembot
    else
      nfo.assembot

    # assbot_conf.package= nfo
    # assbot_conf.assembot= assembot_info
    # assbot_conf.options= options

    if command is 'serve'
      server.serve assbot_conf, options

    else if command is 'build'
      builder.build assbot_conf, options

    else if command is 'files'
      builder.displayTargetTree assbot_conf, options

    else if command is 'modules'
      builder.displayModuleTree assbot_conf, options

    else if command is 'debug'
      builder.prepConfig assbot_conf, options
      _.pp assbot_conf

    else if command is 'version'
      _.puts assembot_info.version

    else
      _.puts """
      ASSEMBOT! Bleep, bloop!
      v#{ assembot_info.version }

      """
      _.puts parser.toString()

