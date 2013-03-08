# AssemBot Notes

Add support for components (bower)

```
{
	"assembot": {
		"options": {

		},
		"package": {
			"./source": {
				js: "./public/app.js",
				css: "./public/theme.css",
				components: [
					"jquery",
					"backbone"
				]
			}
		}
	}
}
```

Goes through and loads "./components/{COMPONENT}/component.json" and adds the
main.js (or main.css for css packages) to "components/{COMPONENT}" is output
package.

```
{
	"assembot": {
		"options": {

		},
		"targets": {
			"public/app.js": {
				"source": ["./source", "./components"],
				"exclude": "./source/test/**"
			}
		}
	}
}
```

## Todos

- Terminology
	- Change all the `config` and `info` strewn about into `target`.

