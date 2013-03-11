# AssemBot Custom Processor

You'll define a custom processor in a plugin. (See [plugins docs](https://github.com/darthapo/assembot/blob/master/docs/plugins.md) to learn more about the mechanics of plugins).

Here's an example of a simple processor that adds support for embedding `.txt` files into your js package:

```coffeescript
module.exports= (assembot)->
  assembot
    .addProcessor('js').ext('.txt')
      .build -> 
        (source, opts, converted)->
          output= """
            module.exports=#{ JSON.stringify source };
          """
          converted null, output, opts
```

Now AssemBot will embed `.txt` files into your js package. Given the file `source/readme.txt`, you can reference it in the assembled package like this:

```coffeescript
contents= require 'readme'
# That's it. Do whatever with contents, it's a String
```

# Advanced Usage

See the [settee-templates plugin](https://github.com/darthapo/assembot/blob/master/src/assembot/plugins/settee-templates.coffee) for a more advanced example. If a [Settee](http://darthapo.github.com/settee.js/) template is used, it will automatically add the runtime compontent to the output.