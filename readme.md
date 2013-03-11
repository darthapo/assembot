# AssemBot

## What does it do?

AssemBot is a simple asset assembler for use in developing JS web apps. It's designed for my own preferred way of development, so YMMV.

It's rather like stitch, but not exactly. It can compile an entire directory into a single, commonjs moduled, javascript file. It can also create a single .css file from all the styles in a single directory, recursively. It will also transpile where appropriate (CoffeeScript, eco, less, stylus, etc).

If you don't like the default conventions, you can configure it in your `package.json` file. You can also extend AssemBot with plugins to add processor, or packages types. See the [docs](https://github.com/darthapo/assembot/tree/master/docs) for more.

## Installation

    npm install -g assembot

You don't **have** to install it globally, but it comes with a pre-configured binfile to make it quick to use on projects. (It defaults to compiling `./source` into `public/app.js` and `public/app.css`)

## Usage

At it's simplest:

    cd my_project
    assembot build

If you want to configure it via package.json, just add an `assembot` section to your package and run `assembot`.

```json
{
  ... Other node/npm stuff ...
  "assembot": {
    "targets": {
      "output/my_file.js": {
        "source": "./source"
        "minify": 1
      }
    }
  }
}
```

If you've not installed it globally, then you'll need to add it as a dependency to your project, then:

    npm install assembot --save
    ./node_modules/.bin/assembot --build

AssemBot can give you a head start by creating a assembot configuration block for you:

    assembot init


## Transpiler Support

AssemBot initially enables support for transpiling `.coffee`, `.litcoffee`, `.eco`, `.dot`, `.ejs`, `.less`, and `.styl` files. When using stylus, it will attempt to enable Nib by default as well.

There's a start on some others as well. Plus, you can always [add your own](https://github.com/darthapo/assembot/blob/master/docs/custom-processors.md).

## Token Replacement

In your sources files you can reference data defined in your `package.json` file by using a special token syntax: `{%- package.author -%}`

AssemBot will attempt to replace all tokens in your sources files. To disable this behavior, set `replaceTokens` to `false`.

## Embedded CSS

It also supports compiling CSS into the JS package. Use `.ecss` (or `.estyl` or `.eless`) file extension. Generates a module you can use like this:

```coffeescript
require('my/view/styles').activate()
# EmbeddCSS API:
#  .activate()   - Appends a generated <style> tag to HEAD, BODY, or document
#  .deactivate() - Removes the generated <style> tag
#  .isActive()   - Boolean 
```

## Dev Server

AssemBot comes with a dev server, to use it:

    assembot serve

## Default Configuration

Following are the default AssemBot configuration values, when creating your own configuration, you don't need to specify all on these -- only those you wish to override:

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


## Roadmap

- v0.3+ = Make it better. Look into SourceMap support.
