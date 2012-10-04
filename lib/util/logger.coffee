color = require('ansi-color').set
growl = require 'growl'
require 'date-utils'

class Logger

  isDebug: false
  isStartup: true

  setDebug: (@isDebug = true) ->
  setConfig: (config) -> @config = config.growl
  startupDone: (@isStartup = false) =>

  log: (logLevel, message, color, growlTitle = null) ->
    if growlTitle?
      imageUrl = switch logLevel
        when 'success' then "#{__dirname}/assets/success.png"
        when 'error' then "#{__dirname}/assets/failed.png"
        when 'fatal' then "#{__dirname}/assets/failed.png"
        else ''

      growl message, {title: growlTitle, image: imageUrl}

    message = @wrap(message, color)

    if logLevel is 'error' or logLevel is 'warn' or logLevel is 'fatal'
      console.error message
    else
      console.log message

  wrap: (message, textColor) -> color("#{new Date().toFormat('HH24:MI:SS')} - #{message}", textColor)

  blue:  (message) => console.log color(message, "blue+bold")
  green: (message) => console.log color(message, "green+bold")
  red:   (message) => console.log color(message, "red+bold")

  error: (message) => @log 'error', message, 'red+bold', 'Error'
  warn:  (message) => @log 'warn',  message, 'yellow'
  info:  (message) => @log 'info',  message, 'black'
  fatal: (message) => @log 'fatal', "FATAL: #{message}", 'red+bold+underline', "Fatal Error"
  debug: (message) => @log 'debug', "#{message}", 'blue' if @isDebug

  success: (message, options) =>
    s = @config.onSuccess
    title = if @isStartup and not @config.onStartup
      null
    else if options.isJavascript and s.javascript or
      options.isCSS and s.css or
      options.isTemplate and s.template or
      options.isCopy and s.copy
        "Success"
    else
      null

    @log 'success', message, 'green+bold', title

module.exports = new Logger
