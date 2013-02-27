# AssemBot

## What does it do?

AssemBot is a simple asset assembler for use in developing JS web apps. It's designed for my own preferred way of development, so YMMV.

It's rather like stitch, but not exactly. It compiles an entire directory into a single, commonjs moduled, javascript file. It will also create a single .css file from all the styles in a single directory. It will transpile where appropriate (CoffeeScript, eco, less, stylus).

If you don't like the default conventions, you can configure it in your `package.json` file.

## Installation

    npm install -g assembot

You don't **have** to install it globally, but it comes with a pre-configured binfile to make it quick to use on a project. (It defaults to compiling `./source` into `public/app.js` and `public/theme.css`)

## Usage

At it's simplest:

    cd my_project
    assembot

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
    ./node_modules/.bin/assembot


## Transpiler Support

Assembot will try to enable support for transpiling `.coffee`, `.litcoffee`, `.eco`, `.less`, and `.styl` files. It will also assemble `.css`, `.js`, and `.html` files. Any `.html` files become a module that exports the contents of the file as a string. Stylus support will attempt to enable Nib by default as well.

## Token Replacement

In your sources files you can embed data defined in your `package.json` file by using a special token syntax: `{%- package.author -%}`

If you have `replaceTokens` set to `true`, Assembot will attempt to replace all tokens in your sources files. It is enabled by default.

## Default Configuration

The default AssemBot configuration from ./src/defaults.coffee:


```coffeescript
exports.config=
  source: './source'
  ident: 'require'
  autoStart: no
  minify: 0 # 0=none, 1=minify, 2=mangle
  header: "/* Assembled by Assembot {%- assembot.version -%} */"
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