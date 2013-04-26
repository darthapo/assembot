# AssemBot Notes/Todos

- Support SourceMaps!

- Add support for excluding files from build (relative to source root).

- Add dev server proxy plugin. It would let you mount proxies to a uri. Just
  look at the paths and if any are a full URL then turn it into a proxy?
	
		"http": {
			"paths": {
				"/google": "http://www.google.com"
			}
		}


## Ideas

- Add option to disable commonjs asssembly.

- Move to 'debug' for logging? Have two branches? assembot:info:component
  and assembot:debug:componet
	
	Then running assembot debug would set the env 'DEBUG=assembot:*'

	Using -v flag would set the env 'DEBUG=assembot:info:*'

- Add a setting for auto-activating any embedded css. Should it just do
  everything, or selectively?

- Add a "prune.keep" key to keep certain, unrequired by "main," modules.

- What about an easy way to create multiple targets from the same compiled
  source? (for example; one minified, one not) Maybe a "minifyTo" key?

  	"public/app.js": {
			"source": "./source",
			"minify: 1,
			"minifyTo": "public/app.min.js"
  	}

- Multiple source directories?

		"public/app.js": {
			"source": ["./source", "./components"]
		}

	What if we want to prepend a path? Maybe:

		"public/app.js": {
			"source": "./source",
			"mount": {
				"components": "./components",
				"vendor": "./lib"
			}
	  }

	Or?

		"public/app.js": {
			"source": [
				"./source", 
				{ 
					"vendor": "./lib", 
					"elucidata": "~/Projects/OpenSource/elucidata-components" 
				}
			]
		}

- Move from processors overwriting `resource.content` to having a 
  second property: `resource.rendered`. Default processors would 
  just take the content and assign it to rendered.
  
- Add support for including `./components` --  component.io style. More 
  condusive to AssemBot's build system style (already supports/expects 
  common-js modules).

	Loads `component.json`, and includes the files referenced.

	Converts `component-tip` to module path `component/tip`?

	Or `elucidata-type` to `components/type` (all components under the 
	`components/` path, remove vendor prefix)?

	List which components to load in the config block, or just include all 
	locally installed components automatically? If latter, would need to 
	include an exclusion filter.

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
		

## Exploratory

### Packages

What would it take to make a custom package type?

For example a 'assembot-php' plugin:

```coffeescript
module.exports= (assembot, done)-> # (Not sure if done is really needed yet)
	
	assembot.addProcessor('php').ext('php')
		.build -> (content, opts, done)->
			done(null, content, opts) # just pass on through, no rendering required


	# This should work right now, actually
	addPackager 'php', (resources, options, done)->
	  results= ""
	  for res in resources
	    results += "/* #{ res.path } */\n"
	    results += res.content
	    results += "\n\n"
	  done null, results

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


- What if the plugin uses async code?

### Processors

Move the default processors into plugins? 

Especially the ones that require a runtime?!


### Empirical vs Scanning

Instead of scanning and loading every file in the source directory, why not take
the prune plugin and build around it?

You'd specify the source paths (an array), and a main entry point. It would then
scan that file, search for `require`d files, then scan for those files -- repeating
the dendency search for each child file until there are no more files required.

Then you only have to load the content and transpile those files. Everything else
in the source folder(s) would never be opened (or even touched at all).

Would make supporting components even easier,

```coffeescript
assembot:
	targets:
		"public/app.js":
			source: ['./source', './components']
			main: "main"
```

```coffeescript
assembot:
	targets:
		"public/app.js":
			source: ['./source', './components']
			main: ["main", "test"]
```

```coffeescript
assembot:
	targets:
		"public/app.js":
			paths: ['./source', './components']
			source: ["main", "test", "never/required/directly/but/needed/*"]
			autoload: "main" # or true to require first 'source'
```



### Move away from json configuration...

Have an `AssemBot.(js|coffee)` file at the root of the project.

```coffeescript

module.exports= (AssemBot)->
	package_info = require('package')
	
	AssemBot.config package_info
	
	# Multiple calls merge internal hash instead of replacing it.
	AssemBot.config
		defaultOptions: 'here'

	# Supports chaining as well:
	AssemBot
		.config( name:'test ' )
		.config( other: true )

	AssemBot.bundle 'public/app.js',
		source: './source'

	AssemBot.bundle 'public/app.css',
		source: './source'

	AssemBot.plugin 'assembot/lib/plugins/vendorize',
		base: './vendor'

	AssemBot.on 'done', (opts)->
		AssemBot.log "We're done here."

```

The driver would do some thing like this:

```coffeescript
config= require('assembot')

bot= new AssemBotDriver

config.call bot, bot
```

So that you could do this:

```coffeescript

module.exports= (AssemBot)->
	package_info = require('package')
	
	@config package_info
	
	# Multiple calls merge internal hash instead of replacing it.
	@config
		defaultOptions: 'here'

	# Support chaining as well:
	@config( name:'test ' ).config( other: true )

	@bundle 'public/app.js',
		source: './source'
		main: 'main'

	@bundle 'public/app.css',
		source: './source'
		main: 'styles/theme.styl'

	# Dev Server config
	@server
		port: 8080
	@mount '/', path:'./public'
	@mount '/api', proxy:'http://myserver.com/api'


	# An HTML bundle would append all other HTML files in `source` folder
	# to document in `script` template tags.
	@bundle 'public/index.html',
		source: './source'
		main: 'template/boot.html'
		type: 'text/ng-template' #for the script type
		clean: no # to convert path seperators to hyphens, use `yes`

	@plugin 'assembot/lib/plugins/vendorize',
		base: './vendor'

	@on 'done', (opts)->
		AssemBot.log "We're done here."

```

---

```coffeescript
class AssemBotDriver
	VERSION: '0.3'

	config: (hash)->
		@

	plugin: (name, config)->
		@

	bundle: (output, config)->
		@

	server: (config)->
		@

	mount: (path, config)->
		@

	log: ->
		@

	on: (event, callback)->
		@
	
	before: (event, callback)->
		@
	
	after: (event, callback)->
		@
```
