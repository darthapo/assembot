module.exports=

  options:
    
    header: "/* Assembled by AssemBot {%- assembot.version -%} */"
    sourceMap: no
    minify: 0 # 0=none, 1=minify, 2=mangle
    ident: 'require'
    autoLoad: null
    replaceTokens: yes

    coffee:
      bare: yes # precedence: 0

    http:
      port: 8080
      paths:
        '/': './public'
        '/components': './components'

  targets:
    "public/app.js":
      source: './source'
      coffee:
        bare: no # precedence: 1 (commandline gets precedence: 2)
    "public/app.css":
      source: './source'
