coffee = require('coffeescript/register')
app = require('../app')
debug = require('debug')('genre-graph:server')
http = require('http')

onError = (error) ->
  if error.syscall != 'listen'
    throw error
  bind = if typeof port == 'string' then 'Pipe ' + port else 'Port ' + port
  # handle specific listen errors with friendly messages
  switch error.code
    when 'EACCES'
      console.error bind + ' requires elevated privileges'
      process.exit 1
    when 'EADDRINUSE'
      console.error bind + ' is already in use'
      process.exit 1
    else
      throw error

onListening = ->
  addr = server.address()
  bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port
  debug 'Listening on ' + bind
  console.log 'Listening on ' + bind


server = http.createServer(app)

server.listen process.env.PORT ? 3000
server.on 'error', onError
server.on 'listening', onListening