_= require './util'

exports.config=
  source: './source'
  ident: 'require'
  autoStart: no
  minify: 0 # 0=none, 1=minify, 2=mangle
  sourceMap: no # still a work in progress
  header: "/* Assembled by AssemBot {%- assembot.version -%} */"
  replaceTokens: yes


exports.options=
  port: 8080
  wwwRoot: './public'
  #TODO: Make this work:
  http:
    "/": "./public"
    "/components": "./components"


exports.assembot=
  "public/app.js": _.extend {}, exports.config
  "public/theme.css": _.extend {}, exports.config

