
createError = require('http-errors')
express = require('express')
path = require('path')
cookieParser = require('cookie-parser')
logger = require('morgan')
sassMiddleware = require('node-sass-middleware')
coffee = require('coffeescript')
url = require('url')
fs = require('fs')
webpack = require('webpack')


indexRouter = require('./routes/index')
app = express()

# view engine setup
app.set 'views', path.join(__dirname, 'views')
app.set 'view engine', 'pug'

# webpack setup
webp = webpack {
    entry: 
        app: './app/entry.coffee'
    output:
        path: path.join(__dirname, 'public', 'js')
        filename: '[name].bundle.js'
    module: 
        rules: [
            {
                test: /\.coffee$/,
                loader: 'coffee-loader',
            }
        ]
    }

webpWatch = webp.watch {
        aggregateTimeout: 100,
        poll: 100,
        ignored: /node_modules/,
        infoVverbosity: 'verbose',
    },(err, stats) =>
    if stats.hasErrors()
        console.error "Webpack compilation error:", stats.compilation.errors
    else
        console.log "Webpack: built", stats.hash

app.use logger('dev')
app.use express.json()
app.use express.urlencoded(extended: false)
app.use cookieParser()

app.use sassMiddleware(
  src: path.join(__dirname, 'app', 'style')
  dest: path.join(__dirname, 'public', 'css')
  indentedSyntax: true
  sourceMap: true
  debug: true,
  prefix: '/css')

app.use express.static(path.join(__dirname, 'public'))
app.use '/', indexRouter

# catch 404 and forward to error handler
app.use (req, res, next) ->
  next createError(404)
  return

# error handler
app.use (err, req, res, next) ->
  # set locals, only providing error in development
  res.locals.message = err.message
  res.locals.error = if req.app.get('env') == 'development' then err else {}
  # render the error page
  res.status err.status or 500
  res.render 'error'
  return



module.exports = app