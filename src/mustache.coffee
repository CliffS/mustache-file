###
# mustache-file.js - wrapper around mustache
#
# For fully documented souce code, please see the coffeescript
# source on gGithub.
#
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
      # Have we run out of paths?
      return callback new Error "File not found: #{filename}" unless path?
      file = Path.join path, "#{filename}.#{@extension}"
      fs.access file, fs.R_OK, (err) ->
        fullPath = file unless err
        callback undefined  # Success
    # Try to find the file, one path at a time, in order
    Async.doUntil findFirst, ->
      # Keep going until fullPath is set then stop, guaranteeing the 1st match
      fullPath?
    , (err) =>
      return callback err if err
      # Read the file
      fs.readFile fullPath, encoding: 'utf-8', (err, data) =>
        return callback err if err
        # Find any partials
        partials = data.match partialRE
        # or pass an empty array
        partials ?= []
        # Deal with all the partials in parallel
        Async.each partials, (partial, cb) =>
          # and strip out the filename
          partial = partial.replace partialRE, '$1'
          # Call readFile recursively to find partials within partials
          @readFile partial, (err, part)  =>
            return cb err if err
            # Save partials off in the instance
            @parts[partial] = part
            cb undefined
        , (err) ->
          # All partials done, pass back the template
          callback err, data

  render: (file, context, callback) ->
    @parts = {}
    @readFile file, (err, template) =>
      return callback err if err
      try
        result = mustache.render template, context, @parts
      catch err
        return callback err
      callback undefined, result

module.exports = Mustache

