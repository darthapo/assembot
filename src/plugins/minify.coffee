uglify= try  
  require "uglify-js"
catch ex
  null

do_minify= (flag, output_content, log)->
  if uglify?
    log.debug "Minify..."
    try
      settings= fromString: true, mangle:false
      switch flag
        when 1, 'minify', 'min'
          uglify.minify( output_content, settings )
        when 2, 'mangle', 'munge', 'compress'
          settings.mangle= true
          uglify.minify( output_content, settings )
        else
          code:output_content, map:null
    catch ex
      log.info "Error in minify, skipping..."
      log.error ex
      code:output_content, map:null
  else
    log.info "Can't minify (install uglify-js)..."
    code:output_content, map:null

module.exports= (assembot, ident)->
  ident "Minify", no

  {log}= assembot

  assembot.after 'build', (bot)->
    return if bot.target isnt 'js'
    if bot.options.minify? and bot.options.minify isnt false and bot.options.minify > 0
      bot.content = do_minify( bot.options.minify, bot.content, log ).code