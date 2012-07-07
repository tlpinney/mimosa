AbstractCompiler = require './compiler'
path = require 'path'
fs = require 'fs'

module.exports = class AbstractSingleFileCompiler extends AbstractCompiler

  constructor: (config, targetConfig) -> super(config, targetConfig)

  compile: (fileAsText, fileName, callback) -> throw new Error "Method compile must be implemented"

  created: (fileName) => @readAndCompile(fileName, false)
  updated: (fileName) => @readAndCompile(fileName)
  removed: (fileName) => @removeTheFile(@findCompiledPath(fileName.replace(@fullConfig.root, '')))

  readAndCompile: (fileName, isUpdate = true) ->
    destinationFile = @findCompiledPath(fileName.replace(@fullConfig.root, ''))
    return @done() unless isUpdate or @fileNeedsCompiling(fileName, destinationFile)
    fs.readFile fileName, (err, text) =>
      return @failed(err) if err
      text = text.toString() unless @keepBuffer?
      @beforeCompile(text, fileName) if @beforeCompile?
      @compile(text, fileName, destinationFile, @_compileComplete)

  _compileComplete: (error, results, destinationFile) =>
    if error
      @failed("Error compiling: #{error}")
    else
      @afterCompile(results, destinationFile) if @afterCompile?
      @write(destinationFile, results)

  findCompiledPath: (fileName) ->
    path.join(@compDir, fileName.substring(0, fileName.lastIndexOf(".")).replace(@srcDir, '') + ".#{@outExtension}")