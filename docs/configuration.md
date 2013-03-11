# AssemBot Configuration

If you have a `/.source` folder, and want it compiled down to two files, `public/app.js` and `public/app.css`, then you don't have to do anything at all. Just run:

    assembot build

If you want something other than that -- what?! -- then you'll need to configure AssemBot in one of the following files: `package.json`, `component.json`, `build.json`, or `assembot.json`. It'll look in that order too.

You can have AssemBot create a default configuration for you by running:

    assembot init

Then just follow the on screen instructions.

## Example

At its simplest, your configuration can look like this:

```json
{
  "assembot": {
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

Here's what AssemBot defaults to, if you don't override any of it:

```json
{
  "assembot": {
    "options": {
      "header": "/* Assembled by AssemBot {%- assembot.version -%} */",
      "addHeader": true,
      "minify": 0,
      "ident": "require",
      "autoLoad": null,
      "replaceTokens": true,
      "plugins": [],
      "coffee": {
        "bare": true
      },
      "http": {
        "port": 8080,
        "paths": {
          "/": "./public",
          "/components": "./components"
        }
      }
    },
    "targets": {
      "public/app.js": {
        "source": "./source"
      },
      "public/app.css": {
        "source": "./source"
      }
    }
  }
}
```

