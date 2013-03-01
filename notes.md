# AssemBot Notes

## Version 0.2 - The Clean Up

```coffeescript
assembot= require 'assembot'

package= assembot 'output.js', source:'./source'

package.build (err, content)->
	# Assembled, possibly minified, content

package.filelist (err, files)->
	# Array of files included in package

package.set name:'value'
```

Plugins for build, server, other?

Have a 'content' object that represents the sourcetree

```
{
	"file.js": "FILE CONTENTS HERE......",
	"dir/file2.coffee": "CONTENT HERE"
}
```

Should it have more meta?

```javascript
{
	"file.coffee", {
		disabled: false, // set to true to skip it from including in package
		target:  "js",
		type: "coffee",
		path: "file", // module path
		source: "/full/path/to/source/file.coffee",
		content: "FILE CONTENTS HERE"
	}
}
```

## Todos

- Terminology
	- Change all the `config` and `info` strewn about into `target`.