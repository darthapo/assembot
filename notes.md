# AssemBot Notes/Todos

- Add support for loading plugins from `assembot` block.
- Add support for excluding files from build (relative to source root).
- Add support for lifecyle events (good for plugin integration). All lifecycle
  events would send the current `bot` instance as the first parameter. It should
  emit a before/after event for each of these:
  
  	- scan
  	- renderItem
  	- render
  	- assemble
  	- write (or callback)

	Add listeners to `Assembot` class itself:

		AssemBot.on 'before:renderItem', (bot, resource)->
			# Do something with resource here...

Example:

```json
{
	"assembot": {
		"options": {
			"plugins": ["./my-local-plugin", "plugin-from-npm"]
		},
		"targets": {
			"public/app.js": {
				"source": "./source",
				"exclude": "test/*"
			}
		}
	}
}
```

## Ideas

- Move from processors overwriting `resource.content` to having a 
  second property: `resource.rendered`. Default processors would 
  just take the content and assign it to rendered.
  
- Add support for including `./components` --  component.io style. More condusive
	to AssemBot's build system style (already supports/expects common-js
	modules).

	Loads `component.json`, and includes the files referenced.

	Converts `component-tip` to module path `component/tip`?

	Or `elucidata-type` to `components/type` (all components under the `components/` 
	path, remove vendor prefix)?

	List which components to load in the config block, or just include all locally
	installed components automatically? If latter, would need to include an 
	exclusion filter.

		{
			"assembot": {
				"options": {
					"plugins": ["./my-local-plugin", "plugin-from-npm"],
					"components": {
						"path": "./components",
						"exclude": "component-tip"
					}
				},
				"targets": {
					"public/app.js": {
						"source": "./source",
						"exclude": "test/*"
					}
				}
			}
		}
		
- Add hooks for plugins and processors to add to the resource list.

	For example, if a template engine had a runtime, it could automatically add it
	to the resource list for compilation to it's available without the need for an
	external script tag.

	Maybe add method to the `Processor` class like: `.runtime(modulePath, contentsOrPath)`?

		addProcessor('js').ext('.settee')
			.requires('settee-templates')
			.runtime('engines/settee', CONTENT_OR_FILEPATH)
			.build -> 
				# the rest...
	
	Or, use lifecycle events:

		settee_was_used= no

		addProcessor('js').ext('.settee')
			.requires('settee-templates')
			.build -> 
				settee_was_used= yes
				# the rest...
	
		AssemBot.on 'after:render', (bot)->
			if settee_was_used
				bot.resources.push new Resource 'runtime/settee.js', cat('settee.runtime.js')



## Exploratory

### Packages

What would it take to make a custom package type?

For example a 'assembot-php' plugin:

```coffeescript
module.exports= (assembot, done)-> # (Not sure if done is really needed yet)
	
	assembot.addProcessor('php').ext('php')
		.build -> (content, opts, done)->
			done(null, content, opts) # just pass on through, no rendering required


	assembot.addPackager('php') # new code needed for this...
		.build (resources, options)->
			result= ""
			result += res.content for res in resources
			result

```

Your build.json:

		{
			"assembot": {
				"targets": {
					"app-in-a-page.php": {
						"source": "./source"
					}
				}
			}
		}

### Minifier

Make the minifier use the plugin system?

```coffeescript
assembot.on 'before:write', (bot)->
	bot.content= results
```

- What if the plugin uses async code?

### Processors

Move the default processors into plugins? 

Especially the ones that require a runtime?!