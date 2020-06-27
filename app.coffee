###
  Copyright (c) 2020 Silas Gyger

  Contains snippets from:
  * [Spotify Accounts Authentication Examples](https://github.com/spotify/web-api-auth-examples/)

###


# Import packages
createError = require('http-errors')
express = require('express')
path = require('path')
cookieParser = require('cookie-parser')
morgan = require('morgan')
stylus = require('stylus')
url = require('url')
fs = require('fs')
webpack = require('webpack')
http = require('http')
debug = require('debug')('genre-graph:server')


spotifyRouter = require('./routes/spotifyAuth')
indexRouter = require('./routes/index')

# Add coffeescript support
require('coffeescript/register')

# Configs...
inPath = path.join(__dirname, 'src')
outPath = path.join(__dirname, 'public')


webpackConfig = require('./webpack.config')

stylusConfig =
  src: path.join(inPath, 'style')
  dest: path.join(outPath, 'css')
  linenos: true
  sourcemap: true
  debug: true

app = express()
app.use morgan('dev', {
  stream: process.stdout
})

app.locals.pretty = true

# Setup pug
app.set 'views', path.join(inPath, 'pug')
app.set 'view engine', 'pug'


# Setup webpack for coffee
webpack require('./webpack.config')
    .watch ignored: /node_modules/, (err, stats) =>
        if stats.hasErrors()
            console.error "Webpack compilation error:", stats.compilation.errors
        else
            console.log "Webpack: built", stats.hash


# Setup /css as another static handle as css/ is prepended to resources requested in css files
app.use '/css', express.static path.join(__dirname, 'public')
app.use stylus.middleware stylusConfig

# Allows access to req.cookies
app.use cookieParser()

# Setup ./public as static directory
app.use express.static(path.join(__dirname, 'public'))

# Setup route to index
app.use '/', indexRouter

# Setup rout for spotify login
app.use '/', spotifyRouter

# Handle 404
app.use (req, res, next) ->
  next createError(404)
  return

# Handle 500
app.use (err, req, res, next) ->
  # set locals, only providing error in development
  res.locals.message = err.message
  res.locals.error = if req.app.get('env') == 'development' then err else {}
  # render the error page
  res.status err.status or 500
  res.render 'error'
  console.error err.stack
  return


############
# Server
server = http.createServer app

server.on 'error', (error) =>
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

server.on 'listening', =>
  addr = server.address()
  bind = if typeof addr == 'string' then 'pipe ' + addr else 'port ' + addr.port
  console.log 'Listening on ' + bind

server.listen process.env.PORT ? 3000