require 'coffee-script'
_= require '../util'
log= require '../log'
defaults= require '../defaults'
path= require 'path'
{test, cat}= require 'shelljs'
{loadOptions}= require '../index'
# {puts, pp}= _

module.exports= (cli, pkg, init_logging)->

  cli
    .command('init')
    .description('Creates a configuration file, if missing')
    .action ->
      init_logging()
      localOptions= loadOptions(false)

      check_local_options= ->

        if localOptions?
          localOptions= "#{localOptions}.json"
          log.say "Bzrk!\n"
          log.say "   ./#{localOptions} already has AssemBot settings defined!\n"
          cli.prompt "Would you like to continue? (Y/n) ", (answer)->
            if String(answer).toLowerCase().trim().indexOf('n') is 0
              log.say "Bzzt. Canceled."
              process.stdin.destroy()
            else
              log.say "\nAlright, but don't say I didn't warn you!\n"
              choose_your_fate()
        else
          choose_your_fate()


      target_files= 'package.json component.json build.json assembot.json'.split(' ')

      choose_your_fate= ->
        options= []
        for filename in target_files
          if test '-f', path.resolve "./#{ filename }"
            if localOptions is filename
              options.push "#{ filename }* (merge - has AssemBot settings already)"
            else
              options.push "#{ filename } (merge)"
          else
            options.push "#{ filename } (create)"

        options.push "Cancel operation"

        log.say 'Where shall I put the configuration?'

        cli.choose options, (i)->
          if i is 4
            log.say "Bzzt. Canceled."
          else
            log.say 'You chose %d "%s"', (i + 1), options[i]

            init_settings(i)

            log.say ""
            log.say "You were eaten by a grue."
            log.say "Just kidding. Robot humor. Ha. Ha."
            log.say "The operation completed successfully."
            log.say ""
            log.say "Done."

          process.stdin.destroy()


      init_settings= (i)->
        filename= "./#{ target_files[i] }"
        filepath= path.resolve filename
        settings= {}
        log.say ""
        if test('-e', filepath)
          log.say "OK, merging #{ filename }"
          settings= JSON.parse cat(filepath)
        else
          if filename is './package.json'
            settings=
              name: path.basename(process.cwd())
              version: "1.0.0"
              license: ""
              description: ""
              author: ""
          log.say "OK, creating #{ filename }"

        settings.assembot= _.defaults {}, (settings.assembot || {}), defaults

        output= JSON.stringify settings, null, 2

        log.debug "Writing:"
        log.debug output

        output.to filepath


      check_local_options()
