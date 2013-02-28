

exports.config=
  source: './source'
  ident: 'require'
  autoStart: no
  minify: 0 # 0=none, 1=minify, 2=mangle
  sourceMap: no # still a work in progress
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

