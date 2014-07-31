CurlyConverter = require './curly-converter'
DoEndConverter = require './do-end-converter'

module.exports =
  curlyConverter: null
  doEndConverter: null

  activate: (state) ->
    atom.workspaceView.command "ruby-block-converter:toCurlyBrackets", =>
      @toCurlyBrackets()
    atom.workspaceView.command "ruby-block-converter:toDoEnd", =>
      @toDoEnd()
    @editor = atom.workspace.getActiveEditor()

  deactivate: ->
    @curlyConverter?.destroy()
    @curlyConverter = null
    @doEndConverter?.destroy()
    @doEndConverter = null

  # Converts do-end blocks to curly bracket blocks
  toCurlyBrackets: ->
    @curlyConverter = new CurlyConverter()

  # Converts curly bracket blocks to do-end blocks
  toDoEnd: ->
    @doEndConverter = new DoEndConverter()
    startRange = @doEndConverter.findOpenCurly()
    if startRange != null
      endRange = @doEndConverter.findClosedCurly(startRange)
      if endRange != null
        @doEndConverter.replaceBlock(startRange, endRange)
        unless @doEndConverter.unCollapseBlock(startRange, endRange)
          @doEndConverter.resetCursor()
