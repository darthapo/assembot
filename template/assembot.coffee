
console.log "{{ name }}"

isDebug= String(process.argv[2]) is 'serve'

onLoad= (assembot)->
  console.log "Startup! (debug:#{isDebug})"

module.exports=
  assembot:
    options:
      callback: onLoad
      header: "/* {{ name }} v{%- package.version -%} */"
      plugins: [ 
        "assembot/lib/plugins/increment-version" 
        "assembot/lib/plugins/server-latency"
        "assembot/lib/plugins/vendorize"
      ]
      autoincrement:
        enable: yes
        target: 'package.json'
        segment: 'build' # or major, minor, patch
        when: 'after:write' 
      http:
        log: no
        latency:
          enable: no
          max: 1000
          rules:
            ".(jpg|png|jpeg)": 100

    targets:
      "public/app.js":
        source: "./source"
        ident: "require"
        main: "main"
        autoload: true
        debug: isDebug
        prune: true
        minify: (if isDebug then 0 else 2)
        vendorize:
          before: []
          after: []

      "public/app.css":
        enable: no
        source: "./source"
        debug: isDebug
