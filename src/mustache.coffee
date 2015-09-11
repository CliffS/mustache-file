###
# mustache-file.js - wrapper around mustache
###

fs = require 'fs'
mustache = require 'mustache'
Path = require 'path'
Async = require 'async'

partialRE = /{{>\s*([\w-]+)\s*}}/g

class Mustache
  constructor: (options) ->
    @extension = options.extension ? 'mustache'
    @path      = options.path      ? '.'

  parts: {}

  readFile: (filename, callback) ->
    paths = if Array.isArray @path then @path.slice 0 else [ @path ]
    fullPath = undefined
    findFirst = (callback) =>
      path = paths.shift()
      return callback new Error "File not found" unless path?
      file = Path.join path, "#{filename}.#{@extension}"
      fs.access file, fs.R_OK, (err) ->
        fullPath = file unless err
        do callback
    Async.doUntil findFirst, =>
      fullPath?
    , (err) =>
      return callback err if err
      fs.readFile fullPath, encoding: 'utf-8', (err, data) =>
        return callback err if err
        partials = data.match partialRE
        partials ?= []
        Async.each partials, (partial, cb) =>
          partial = partial.replace partialRE, '$1'
          @readFile partial, (err, part)  =>
            return cb err if err
            @parts[partial] = part
            cb undefined
        , (err) ->
          callback err, data

  render: (file, context, callback) ->
    @parts = {}
    @readFile file, (err, template) =>
      callback err if err
      callback undefined, mustache.render template, context, @parts

module.exports = Mustache

