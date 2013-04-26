
class Loader
  constructor: (lib)->
    @log= lib.log
    {@cat, @test}= lib.shelljs
    @log.debug "Loader ready"

  read: (src)->
    @log.debug "Trying to read files:", src
    content= ""
    for path in (paths= []).concat.apply(paths, [src])
      # @log.info "PATH:", path, typeof(path)
      if @test('-f', path)
        content += "\n"
        # @log.info " -- including", path
        file_content= @cat path
        # @log.info "FILE_CONTENT", path, file_content
        content += file_content
      else
        @log.debug "Cannot find", path
    content

module.exports= (assembot, ident)->
  ident "Vendorize"

  {log}= assembot
  loader= new Loader(assembot)

  # assembot.after 'build', (bot)->
  assembot.before 'write', (bot)->
    added_content= no
    return unless bot.options.vendorize?.before?.length > 0 or bot.options.vendorize?.after?.length > 0
    log.debug "Injecting vendor code."

    if bot.options.vendorize.before?.length > 0
      log.debug "Vendorizing (before):", bot.options.vendorize.before
      vendor_content=  loader.read(bot.options.vendorize.before)
      bot.content = [vendor_content, bot.content].join "\n"
      added_content= yes

    if bot.options.vendorize.after?.length > 0
      log.debug "Vendorizing (after):", bot.options.vendorize.after
      vendor_content=  loader.read(bot.options.vendorize.after)
      bot.content =  [bot.content, vendor_content].join "\n"
      added_content= yes