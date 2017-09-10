#!/usr/bin/env coffee

# Mustache = require '../lib/mustache'
Mustache = require './mustache'

main = ->
  args = process.argv[2..]
  [template, context] = process.argv[2..]
  unless template
    syntax()
    process.exit 1
  mustache = new Mustache
  mustache.render template, context
  .then (output) ->
    console.log output
  .catch (err) ->
    console.error err



syntax = ->
  console.log """
    mustache [options] template.mustache [ context.json ]
      options:
        -o | --output: Output path for the rendered text
  """



module.exports = main

main()
