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

    {
      ... Other node/npm stuff ...
      "assembot": {
        "output/my_file.js": {
          source: "./src"
          minify: 1
        }
      }
    }

If you've not installed it globally, then you'll need to add it as a dependency to your project, then:

    npm install
    ./node_modules/.bin/assembot


## Configuration

The default AssemBot configuration:

    {
      "assembot": {
        "public/app.js": {
          "source": "./source",
          "ident": "require",
          "minify": 0,
          "coffee": {
            "bare": true
          }
        },
        "public/theme.css": {
          "source": "./source"
        }
      }
    }


## Roadmap

- v0.1 = Make it work.
- v0.2+ = Make it better.