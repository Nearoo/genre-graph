# Import packages
createError = require('http-errors')
express = require('express')
path = require('path')
cookieParser = require('cookie-parser')
morgan = require('morgan')
sassMiddleware = require('node-sass-middleware')
url = require('url')
fs = require('fs')
webpack = require('webpack')
http = require('http')
debug = require('debug')('genre-graph:server')

# Add coffeescript support
require('coffeescript/register')

# Configs...
srcPath = path.join(__dirname, 'src')
indexRouter = require('./routes/index')
webpackConfig = require('./webpack.config')
sassConfig =
  src: path.join(srcPath, 'style')
  dest: path.join(__dirname, 'public', 'css')
  indentedSyntax: true
  sourceMap: false
  debug: false
  maxAge: 0
  outputStyle: 'compressed'
  prefix: '/css'

app = express()
app.use morgan('dev', {
  stream: process.stdout
})

# Setup pug
app.set 'views', path.join(srcPath, 'pug')
app.set 'view engine', 'pug'

# Setup webpack for coffee
webpack require('./webpack.config')
    .watch ignored: /node_modules/, (err, stats) =>
        if stats.hasErrors()
            console.error "Webpack compilation error:", stats.compilation.errors
        else
            console.log "Webpack: built", stats.hash

# Add more middlewares (?)
app.use express.json()
app.use express.urlencoded(extended: false)
app.use cookieParser()

# Add sass middleware
app.use sassMiddleware sassConfig
# Setup public/ as static directory
app.use express.static(path.join(__dirname, 'public'))
# Setup /css as another static handle as css/ is prepended to resources requested in css files
app.use '/css', express.static path.join(__dirname, 'public')

# Setup route to index
app.use '/', indexRouter

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