path= require 'path'

resolve_path= (libpath, from)->
  if libpath[0] is '.'
    moduledir= path.dirname(from)
    if moduledir is '.' or moduledir is ''
      moduledir= ""
    else
      moduledir= "/#{ moduledir }"
    path.resolve("#{moduledir}/#{libpath}")[1..]
  else
    libpath

module.exports= (assembot, ident)->
  # ident "Prune"

  {log}= assembot

  assembot.after 'scan', (bot)->
    return if bot.target isnt 'js'
    return unless bot.options.main? and bot.options.prune
    log.info "Building dependency list..."
    bot.resources.each (res)->
      res.dependencies= []
      if reqs= res.content.match(requireParser)
        log.debug res.path
        libs=[]
        for req in reqs
          if modParser.test(req)
            [src, lib]= modParser.exec(req)
            lib= resolve_path lib, res.path
            log.debug " -", lib
            res.dependencies.push lib

  assembot.before 'render', (bot)->
    return if bot.target isnt 'js'
    return unless bot.options.main? and bot.options.prune
    log.info "Building whitelist of modules to include..."
    libs= []
    missing= []

    add_libs= (name)->
      unless name in libs
        res= bot.resources.get(name)
        unless res?
          name= "#{ name }/index"
          res= bot.resources.get(name) 
        if res?
          libs.push name
          for dep in res.dependencies
            add_libs(dep)
        else
          missing.push name

    add_libs bot.options.main
    libs.sort()
    log.info " -", lib for lib in libs

    if missing.length
      log.info "Missing references:"
      log.info " -", lib for lib in missing

    bot.resources.whitelist libs

reqParser= /(require[\s]*?\([\s]*?['"]?[\.a-zA-Z0-9_\-/]*['"]?[\s]*?\))/g
modParser= /['"]+([\.a-zA-Z0-9_\-/]*)['"]+/

# Should match javascript and coffee sources
requireParser= /(require[\s\(]+['"]?[\.a-zA-Z0-9_\-\/]*['"]?[\s\)]+)/g
