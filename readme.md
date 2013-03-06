# AssemBot

## What does it do?

AssemBot is a simple asset assembler for use in developing JS web apps. It's designed for my own preferred way of development, so YMMV.

It's rather like stitch, but not exactly. It compiles an entire directory into a single, commonjs moduled, javascript file. It will also create a single .css file from all the styles in a single directory, recursively. It will transpile where appropriate (CoffeeScript, eco, less, stylus).

If you don't like the default conventions, you can configure it in your `package.json` file.

## Installation

    npm install -g assembot

You don't **have** to install it globally, but it comes with a pre-configured binfile to make it quick to use on a project. (It defaults to compiling `./source` into `public/app.js` and `public/theme.css`)

## Usage

At it's simplest:

    cd my_project
    assembot --build

If you want to configure it via package.json, just add an `assembot` section to your package and run `assembot`.

```json
{
  ... Other node/npm stuff ...
  "assembot": {
    "output/my_file.js": {
      "source": "./src"
      "minify": 1
    }
  }
}
```

If you've not installed it globally, then you'll need to add it as a dependency to your project, then:

    npm install
    ./node_modules/.bin/assembot --build


## Transpiler Support

AssemBot will try to enable support for transpiling `.coffee`, `.litcoffee`, `.eco`, `.dot`, `.ejs`, `.less`, `.styl` files and more. It will also assemble `.css`, `.js`, and `.html` files. Any `.html` files become a module that exports the contents of the file as a string. Stylus support will attempt to enable Nib by default as well.

## Token Replacement

In your sources files you can embed data defined in your `package.json` file by using a special token syntax: `{%- package.author -%}`

If you have `replaceTokens` set to `true`, AssemBot will attempt to replace all tokens in your sources files. It is enabled by default.

## Embedded CSS

Supports compiling CSS into the JS package. Use `.ecss` (or `.estyl` or `.eless`) file extension. Generates a method module you can use like this:

```coffeescript
require('my/view/styles').activate()
# Module supports
#  .activate()   - Appends a <style> tag to HEAD, BODY, or document
#  .deactivate() - Removes <styles> tag
#  .isActive()   - Boolean 
```

## Dev Server

AssemBot comes with a dev server, to use it:

    assembot --serve


## Command Line Help

You can get a list of the supported command line options too:

    assembot -h

## Default Configuration

The default AssemBot configuration from ./src/defaults.coffee:


```coffeescript
exports.config=
  source: './source'
  ident: 'require'
  autoStart: no
  minify: 0 # 0=none, 1=minify, 2=mangle
  sourceMap: no # still a work in progress
  header: "/* Assembled by AssemBot {%- assembot.version -%} */"
  replaceTokens: yes
  coffee:
    bare: yes
    literate: no


exports.options=
  port: 8080
  wwwRoot: './public'


exports.assembot=
  "public/app.js": exports.config
  "public/theme.css": exports.config

```


## Roadmap

- v0.1 = Make it work.
- v0.2+ = Make it better.

## Todo

- Have it look in other places than just package.json, say: component.json, build.json, assembot.json, etc.
- Test support for handlebars and other template engines that require a runtime (ugh).