
# TODO: Add support for adding a header from file...
module.exports= (assembot, ident)->
  ident "Header", no

  {processor, log}= assembot

  assembot.before 'write', (bot)->
    return unless bot.options.header? and bot.options.addHeader
    switch bot.target
      when 'js', 'css'
        log.debug "Adding header..."
        header= processor.replaceTokens bot.options.header, {}
        log.trace header
        output= "#{header}\n#{bot.content}"
        bot.content = output