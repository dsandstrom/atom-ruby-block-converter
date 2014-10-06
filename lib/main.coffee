CurlyConverter = require './curly-converter'
DoEndConverter = require './do-end-converter'

module.exports =
  config:
    maxLines:
      type: 'integer'
      default: 6
      description: 'The maximum amount of lines to go up or down to look for a match.'

  curlyConverter: null
  doEndConverter: null

  activate: (state) ->
    atom.workspaceView.command "ruby-block-converter:to-curly-brackets", =>
      @toCurlyBrackets()
    atom.workspaceView.command "ruby-block-converter:to-do-end", =>
      @toDoEnd()
    atom.workspaceView.command "ruby-block-converter:to-curly-brackets-without-collapse", =>
      @toCurlyBracketsWithoutCollapse()
    atom.workspaceView.command "ruby-block-converter:to-do-end-without-join", =>
      @toDoEndWithoutJoin()
    @editor = atom.workspace.getActiveEditor()

  deactivate: ->
    @curlyConverter?.destroy()
    @curlyConverter = null
    @doEndConverter?.destroy()
    @doEndConverter = null

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
    if startRange != null
      endRange = @doEndConverter.findClosedCurly(startRange)
    @doEndConverter.performTransaction(startRange, endRange, join)

  convertToCurly: (collapse=true) ->
    @curlyConverter = new CurlyConverter()
    startRange = @curlyConverter.findDo()
    if startRange != null
      endRange = @curlyConverter.findEnd(startRange)
    @curlyConverter.performTransaction(startRange, endRange, collapse)
