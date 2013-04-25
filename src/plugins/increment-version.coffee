###
assembot:
  options:
    autoincrement:
      enabled: yes
      target: './package.json'
      segment: 'build' # or major, minor, patch
      when: 'after:write' 
###

semver= require 'semver'
path= require 'path'

module.exports= (assembot, ident)->
  ident "Increment Version"

  {log}= assembot

  assembot.on 'done', (options)->
    return unless options.autoincrement?
    return if options.autoincrement.enabled is false
    
    filepath= path.resolve path.join(process.cwd(), options.autoincrement.target)
    pinfo= require filepath
    pinfo.version= semver.inc(pinfo.version, options.autoincrement.segment) 
                                            # major, minor, patch, or build
    log.info "Incrementing build version to", pinfo.version
    output= JSON.stringify pinfo, null, 2
    # outpath= path.resolve __dirname, '..', "package.json"
    output.to filepath
