module.exports =
class RubyBlockConverter
  maxLevels: 6
  startCount: 0
  endCount: 0

  constructor: ->
    @editor = atom.workspace.getActiveEditor()
    @buffer = @editor.buffer
    @initialCursor = @editor.getCursorBufferPosition()
    @linesInFile = @editor.getLineCount()

  destroy: ->

  foundMatchingEnd: ->
    # there is one more end than start (the first start is not counted)
    @endCount - @startCount == 1

  performTransaction: (startRange, endRange, shouldCollapse=true) ->
    if startRange != null and endRange != null
      @buffer.beginTransaction()
      @replaceBlock(startRange, endRange)
      if shouldCollapse
        collapsed = @collapseBlock(startRange, endRange)
      else
        collapsed = false
      @resetCursor(collapsed, startRange)
      @buffer.commitTransaction()
    else if @initialCursor != null
      @editor.setCursorBufferPosition @initialCursor

  notFirstRow: (editor) ->
    editor.getCursorBufferPosition().row > 0

  notLastRow: (editor) ->
    editor.getCursorBufferPosition().row + 1 < @linesInFile
