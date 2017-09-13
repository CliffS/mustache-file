#!/usr/bin/env coffee

# Mustache = require '../lib/mustache'
Mustache = require './mustache'
Minimist = require 'minimist'
fs = require 'fs'

main = ->
  args = Minimist process.argv[2..],
    boolean: [
      'help'
      'version'
    ]
    string: 'output'
    alias:
      output: 'o'
      version: 'v'
      help: 'h'
    unknown: (param) ->
      return true unless param[0] is '-'
      console.error "\nError: #{param} is not a valid switch"
      do syntax
  # return console.log args
  do syntax if args.h or args._.length > 2
  do version if args.v
  [template, contextFile] = args._
  do syntax unless template
  if contextFile
    contextFile = contextFile.replace /\.json$/, '.json'
    try
      context = JSON.parse fs.readFileSync contextFile
    catch err
      console.error err.toString()
      process.exit 1
  mustache = new Mustache
  mustache.render template, context
  .then (output) ->
    if args.output
      fs.writeFileSync args.output, output
    else
      console.log output
  .catch (err) ->
    console.error err.toString()



syntax = ->
  console.log """

    mustache [options] template.mustache [ context.json ]
      options:
        -o | --output:  Output path for the rendered text
                        (STDOUT if not specified)
        -v | --version: Print version and exit
        -h | --help:    This help list
  """
  process.exit 1

version = ->
  pack = require '../package.json'
  console.log """
    mustache version #{pack.version}
  """
  process.exit 1



module.exports = main
