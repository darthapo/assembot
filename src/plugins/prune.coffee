path= require 'path'

module.exports= (assembot)->
  {log}= assembot

  assembot.after 'render', (bot)->
    return if bot.target isnt 'js'
    return unless bot.options.main? and bot.options.prune
    log.info "Scanning resources for internal dependencies..."
    bot.resources.each (res)->
      res.dependencies= []
      if reqs= res.content.match(reqParser)
        log.debug res.path
        libs=[]
        for req in reqs
          if modParser.test(req)
            [src, lib]= modParser.exec(req)
            if lib[0..1] is './'
              rest= lib[2...]
              lib= [path.dirname(res.path), rest].join('/')
            log.debug " -", lib
            res.dependencies.push lib

  assembot.before 'assemble', (bot)->
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
    log.info " -", lib for lib in libs

    if missing.length
      log.info "Missing references:"
      log.info " -", lib for lib in missing

    bot.resources.whitelist libs

reqParser= /(require[\s]*?\([\s]*?['"]?[\.a-zA-Z0-9_\-/]*['"]?[\s]*?\))/g
modParser= /['"]+([\.a-zA-Z0-9_\-/]*)['"]+/
