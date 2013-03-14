# AssemBot Notes/Todos

- Add support for 'pruning' the output. Only include the resources that are
  explicitly `require`d by the code (post-render phase, loop through all 
  the js resources and scan for require(...) calls.) Add a "main" section 
  to the config, and a "prune" option. "autoload" becomes a boolean.

  	"options": {
			"main": "my/modules/main",
			"autoload": true,
			"prune": true
  	}

- Add support for excluding files from build (relative to source root).

- Add support for auto-incrementing package build numbers.

- Add dev server proxy plugin. It would let you mount proxies to a uri. Just
  look at the paths and if any are a full URL then turn it into a proxy?
	
		"http": {
			"paths": {
				"/google": "http://www.google.com"
			}
		}


## Ideas

- Move to 'debug' for logging? Have two branches? assembot:info:component
  and assembot:debug:componet
	
	Then running assembot debug would set the env 'DEBUG=assembot:*'

	Using -v flag would set the env 'DEBUG=assembot:info:*'

- Add a setting for auto-activating any embedded css. Should it just do
  everything, or selectively?

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