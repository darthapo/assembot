# AssemBot Plugins

A plugin just a script that exports a function. That function will be called with an `assembot` object containing all the helpers and other internals of AssemBot. A simple boilerplate looks like this:

```javascript
module.exports= function(assembot) {
  
}
```

In the [configuration file](https://github.com/darthapo/assembot/blob/master/docs/configuration.md) you configure the list of plugins to load using the key: `assembot.options.plugins`

```json
{
  "assembot": {
    "options": {
      "plugins": [
        "./my-local-plugin",
        "npm-based-plugin"
      ]
    },
    "targets": {
      "public/app.js": {
        "source": "./source",
      },
      "public/app.css": {
        "source": "./source"
      }
    }
  }
}
```

## Implementing Your Plugin

In your plugin, you can add [processors](https://github.com/darthapo/assembot/blob/master/docs/custom-processors.md) or extend the dev server. Most of the time you'll interact/extend AssemBot by subscribing to [lifecyle events](https://github.com/darthapo/assembot/blob/master/docs/lifecycle-events.md)

Some of the [core compontents](https://github.com/darthapo/assembot/tree/master/src/assembot/plugins) of of AssemBot are built via plugins, they're a good place to start learning what's possible.

> [$/assembot/tree/master/src/assembot/plugins](https://github.com/darthapo/assembot/tree/master/src/assembot/plugins)