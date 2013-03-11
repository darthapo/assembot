# AssemBot Life Cycle

- build
- scan
- render
- renderItem
- assemble
- write

The each emit a `before:` and `after:` event. So the flow of events in a build looks like this:

- before:build - (bot)
- before:scan - (bot)
- after:scan - (bot)
- before:render - (bot)
- before:renderItem - (resource)
- after:renderItem - (resource)
- after:render - (bot)
- before:assemble - (bot)
- after:assemble - (bot)
- before:write - (bot)
- after:write - (bot)
- after:build - (bot)

There are also a couple of other events you can listen for in your plugin:

- create:bot - (bot)
- create:server - (server, options)
- start:server - (server, options)

The last two, meant for enhancing the build server, send an instance of `server`, which is an [express](http://expressjs.com/) app.

You can listen to events in your [plugin](https://github.com/darthapo/assembot/blob/master/docs/plugins.md):

```coffeescript
module.exports= (assembot)->
  assembot.on 'before:render', (bot)->

  #or
  assembot.before 'render', (bot)->
```