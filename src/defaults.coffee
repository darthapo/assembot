module.exports=

  options:
    
    header: "/* Assembled by AssemBot {%- assembot.version -%} */"
    addHeader: true
    # sourceMap: no # NOT SUPPORT YET
    minify: 0 # 0=none, 1=minify, 2=mangle
    ident: 'require'
    autoload: no
    main: null
    prune: no
    replaceTokens: yes
    
    plugins: []

    coffee:
      bare: yes # precedence: 0

    http:
      port: 8080
      log: yes
      paths:
        '/': './public'
        '/components': './components'

  targets:
    "public/app.js":
      source: './source'
    "public/app.css":
      source: './source'
