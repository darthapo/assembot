{assembot, _, loadTargets, loadOptions}= require '../index'
log= require '../log'
notify= require '../notify'

module.exports= (cli, pkg)->

  cli
    .option('-t, --target <filepath>', 'build specified target only')
    .command('build')
    .description('Builds target package(s)')
    .action ->
      # log.info ''
      log.info "Building..."

      options= loadOptions()
      all_targets= loadTargets()
      targets= []

      if cli.target?
        if opts= all_targets[cli.target]
          log.info " only #{ cli.target }:"
          bot= assembot cli.target, opts
          bot.build().then ->
            notify.emit 'done', options
            log.info "Done"
        else
          log.say "Target '#{ cli.target }' not found."

      else
        targets.push {target, opts} for target, opts of all_targets

        buildIt= ->
          if targets.length is 0
            notify.emit 'done', options # TODO: FIX ME!
            log.info "Done"
          else
            {target, opts}= targets.shift()
            log.debug "Target:", target
            log.debug "Configuration:"
            log.debug opts
            bot= assembot target, opts
            bot.build().then buildIt

        buildIt()
