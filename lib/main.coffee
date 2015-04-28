{CompositeDisposable} = require 'atom'
CurlyConverter = require './curly-converter'
DoEndConverter = require './do-end-converter'

module.exports =
  subscriptions:  null
  curlyConverter: null
  doEndConverter: null

  config:
    maxLines:
      type: 'integer'
      default: 6
      description:
        'The maximum amount of lines to go up or down to look for a match.'

  activate: (state) ->
    @subscriptions = new CompositeDisposable

    @subscriptions.add atom.commands.add 'atom-workspace',
      "ruby-block-converter:to-curly-brackets": =>
        @toCurlyBrackets()
      "ruby-block-converter:to-do-end": =>
        @toDoEnd()
      "ruby-block-converter:to-curly-brackets-without-collapse": =>
        @toCurlyBracketsWithoutCollapse()
      "ruby-block-converter:to-do-end-without-join": =>
        @toDoEndWithoutJoin()

  deactivate: ->
    @curlyConverter?.destroy()
    @curlyConverter = null
    @doEndConverter?.destroy()
    @doEndConverter = null
    @subscriptions.dispose()

  # Converts do-end blocks to curly bracket blocks
  toCurlyBrackets: ->
    @convertToCurly(true)

  # Converts do-end blocks to curly bracket blocks without collapsing block
  toCurlyBracketsWithoutCollapse: ->
    @convertToCurly(false)

  # Converts curly bracket blocks to do-end blocks
  toDoEnd: ->
    @convertToDoEnd(true)

  # Converts curly bracket blocks to do-end blocks without joining lines
  toDoEndWithoutJoin: ->
    @convertToDoEnd(false)

  convertToDoEnd: (join=true) ->
    @doEndConverter = new DoEndConverter()
    startRange = @doEndConverter.findOpenCurly()
    if startRange
      endRange = @doEndConverter.findClosedCurly(startRange)
    @doEndConverter.performTransaction(startRange, endRange, join)

  convertToCurly: (collapse=true) ->
    @curlyConverter = new CurlyConverter()
    startRange = @curlyConverter.findDo()
    if startRange
      endRange = @curlyConverter.findEnd(startRange)
    @curlyConverter.performTransaction(startRange, endRange, collapse)
