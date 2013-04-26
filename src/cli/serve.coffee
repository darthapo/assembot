require 'coffee-script'
log= require '../log'
server= require '../server'
defaults= require '../defaults'
{assembot, _, loadTargets, loadOptions}= require '../index'

module.exports= (cli, pkg, init_logging)->
  cli
    .option('-p, --port <n>', 'server port', parseInt)
    .command('serve')
    .description('Starts dev server')
    .action ->
      init_logging()
      
      bot_list= for target, options of loadTargets()
        assembot target, options

      options= _.defaults loadOptions(), http:{ port:cli.port }, defaults.options

      server.start bot_list, options
