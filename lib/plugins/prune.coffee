module.exports= (assembot)->
  {log}= assembot

  assembot.after 'render', (bot)->
    return if bot.target isnt 'js'
    # Build deps
    for res in bot.resources
      log.info " - ", res.path
    
  assembot.before 'write', (bot)->
    return if bot.target isnt 'js'
    # prune deps not ref'd
    log.info "PRUNE DEPS"
