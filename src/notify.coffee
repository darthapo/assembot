log= require './log'
{EventEmitter}= require 'events'


class Notify 
  constructor: -> 
    @vent= new EventEmitter

  on: (event, listener)-> 
    @vent.on event, listener
  emit: (args...)-> 
    @vent.emit(args...)

  createBot: (bot)-> 
    @vent.emit 'create:bot', bot

  beforeBuild: (bot)-> 
    @vent.emit 'before:build', bot

  beforeScan: (bot)-> 
    @vent.emit 'before:scan', bot
  afterScan: (bot)-> 
    @vent.emit 'after:scan', bot
    @vent.emit 'scan', bot

  beforeRender: (bot)-> 
    @vent.emit 'before:render', bot

  beforeRenderItem: (resource)-> 
    @vent.emit 'before:renderItem', resource
  afterRenderItem: (resource)-> 
    @vent.emit 'after:renderItem', resource
    @vent.emit 'renderItem', resource

  afterRender: (bot)-> 
    @vent.emit 'after:render', bot
    @vent.emit 'render', bot

  beforeAssemble: (bot)-> 
    @vent.emit 'before:assemble', bot
  afterAssemble: (bot)-> 
    @vent.emit 'after:assemble', bot
    @vent.emit 'assemble', bot

  afterBuild: (bot)-> 
    @vent.emit 'after:build', bot
    @vent.emit 'build', bot

  beforeWrite: (bot)-> 
    @vent.emit 'before:write', bot
  afterWrite: (bot)-> 
    @vent.emit 'after:write', bot
    @vent.emit 'write', bot

  createServer: (server, opts)-> 
    @vent.emit 'create:server', server, opts
  startServer: (server, opts)-> 
    @vent.emit 'start:server', server, opts


notifications= new Notify

module.exports= notifications


# log.debug "NOTIFICATIONS"

# notifications.on 'created', (bot)-> log.debug "> CREATED bot" #, bot

# notifications.on 'before:build', (args...)-> log.debug 'EVENT: before:build'#, args
# notifications.on 'before:scan', (args...)-> log.debug 'EVENT: before:scan'#, args
# notifications.on 'after:scan', (args...)-> log.debug 'EVENT: after:scan'#, args
# notifications.on 'before:render', (args...)-> log.debug 'EVENT: before:render'#, args
# notifications.on 'before:renderItem', (args...)-> log.debug 'EVENT: before:renderItem'#, args
# notifications.on 'after:renderItem', (args...)-> log.debug 'EVENT: after:renderItem'#, args
# notifications.on 'after:render', (args...)-> log.debug 'EVENT: after:render'#, args
# notifications.on 'before:assemble', (args...)-> log.debug 'EVENT: before:assemble'#, args
# notifications.on 'after:assemble', (args...)-> log.debug 'EVENT: after:assemble'#, args
# notifications.on 'after:build', (args...)-> log.debug 'EVENT: after:build'#, args
# notifications.on 'before:write', (args...)-> log.debug 'EVENT: before:write'#, args
# notifications.on 'after:write', (args...)-> log.debug 'EVENT: after:write'#, args

