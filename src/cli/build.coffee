{assembot, _, loadTargets, loadOptions}= require '../index'
log= require '../log'
notify= require '../notify'

module.exports= (cli, pkg, init_logging)->

  cli
    .option('-t, --target <filepath>', 'build specified target only')
    .command('build')
    .description('Builds target package(s)')
    .action ->
      init_logging()
      options= loadOptions()
      all_targets= loadTargets()
      targets= []

      if cli.target?
        target= all_targets[cli.target]
        unless target?
          log.say "Target '#{ cli.target }' not found."
          return
        all_targets= {}
        all_targets[cli.target]= target
      
      targets.push {target, opts} for target, opts of all_targets

      buildIt= ->
        if targets.length is 0
          notify.emit 'done', options
          log.info "Done"
        else
          {target, opts}= targets.shift()
          log.debug "Target:", target
          log.debug "Configuration:"
          log.debug opts
          bot= assembot target, opts
          bot.build().then buildIt

      buildIt()
