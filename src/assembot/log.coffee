log_level= 1

level= (lvl)->
  log_level= lvl if lvl?
  log_level

info= ->
  return if log_level < 1
  console.log.apply console, arguments

debug= ->
  return if log_level < 2
  console.log.apply console, arguments

error= ->
  newError= new Error
  if newError.stack?
    lines= newError.stack.split "\n"
    console.log "Error", lines[2].trim()
  console.log.apply console, arguments

module.exports= {level, info, debug, error}