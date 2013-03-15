path= require 'path'

plugin= (assembot)->

  {Resource, tryRequireResolve, log, shelljs}= assembot
  {cat,test}= shelljs

  settee_was_used= no
  runtime_path= null

  # Get the runtime path
  tryRequireResolve 'settee-templates', (err, libpath)->
    runtime_path= if err?
      log.debug "Could not detect path of settee-templates."
      # log.debug err
      null
    else
      path.resolve( libpath, '../../../settee.runtime.js' )
    log.debug "Path of settee-templates is"
    log.debug runtime_path

  # Add transpiler support
  assembot
    .addProcessor('js').ext('.settee')
      .requires('settee-templates')
      .build (settee)-> 
        (source, opts, converted)->
          settee_was_used= yes
          output= """
            settee= require('runtime/settee');
            module.exports=settee(#{ settee.precompile(source) });
          """
          converted null, output, opts
  
  # Reset the tracking when rendering
  assembot.before 'render', (bot)->
    settee_was_used= no

  # Auto embed runtime compontent
  assembot.after 'render', (bot)->
    if settee_was_used
      if test('-f', runtime_path)
        bot.resources.add new Resource 'runtime/settee.js', cat(runtime_path)
      else
        throw new Error "Cannot embed Settee runtime! Not found at #{ runtime_path }"


module.exports= plugin