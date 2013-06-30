require 'coffee-script'
_= require '../util'
log= require '../log'
defaults= require '../defaults'
path= require 'path'
fgen= require 'fgen'
{spawn}= require('child_process')
{test, cat, cd, mkdir, exec}= require 'shelljs'
{loadOptions}= require '../index'

build_project= (name)->
  projectpath= path.resolve "./#{ name }"
  if test '-e', projectpath
    log.say "#{ name} already exists at this location!"
    return

  console.log "Creating new project:", name

  templatepath= path.resolve path.join(__dirname, '../../', 'template')
  fgen.createGenerator templatepath, (err, generator)->
    throw err if err?

    generator.context=
      name: name
      version: '1.0.0'

    generator.generateAll projectpath, (err)->
      if err?
        log.error err
      else
        cd projectpath
        exec "npm install"
        log.say "Done."


module.exports= (cli, pkg, init_logging)->
  cli
    .command('new')
    .description("Creates a new project") #project directory name
    .action((name)->
      init_logging()
      if process.argv.length < 4
        log.say "I am an advanced Bot, yes. But my telepathic circuits aren't ready yet.\n"
        log.say "Please enter a project name!"
        return
      build_project name
    )
