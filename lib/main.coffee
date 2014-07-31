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
    startRange = @curlyConverter.findDo()
    if startRange != null
      endRange = @curlyConverter.findEnd(startRange)
      if endRange != null
        @curlyConverter.replaceBlock(startRange, endRange)
        collapsed = @curlyConverter.collapseBlock(startRange, endRange)
        @curlyConverter.resetCursor(collapsed, startRange)
    # console.log @buffer.currentTransaction
    @curlyConverter.finalizeTransaction(startRange != null and endRange != null)

  # Converts curly bracket blocks to do-end blocks
  toDoEnd: ->
    @doEndConverter = new DoEndConverter()
    startRange = @doEndConverter.findOpenCurly()
    if startRange != null
      endRange = @doEndConverter.findClosedCurly(startRange)
      if endRange != null
        @doEndConverter.replaceBlock(startRange, endRange)
        unCollapsed = @doEndConverter.unCollapseBlock(startRange, endRange)
        @doEndConverter.resetCursor(unCollapsed, startRange)
    @doEndConverter.finalizeTransaction(startRange != null and endRange != null)
