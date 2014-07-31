module.exports =
class RubyBlockConverter
  maxLevels: 6

  constructor: ->
    @editor = atom.workspace.getActiveEditor()
    @buffer = @editor.buffer

    @initialCursor = @editor.getCursorBufferPosition()
    @linesInFile = @editor.getLineCount()
    # @editor.setCursorBufferPosition @initialCursor

  destroy: ->
    @editor = null
    @buffer = null
    @initialCursor = null
    @linesInFile = null

  performTransaction: (startRange, endRange) ->
    if startRange != null and endRange != null
      @buffer.beginTransaction()
      @replaceBlock(startRange, endRange)
      collapsed = @collapseBlock(startRange, endRange)
      @resetCursor(collapsed, startRange)
      @buffer.commitTransaction()
    else if @initialCursor != null
      @editor.setCursorBufferPosition @initialCursor

  notFirstRow: (editor) ->
    editor.getCursorBufferPosition().row > 0

  notLastRow: (editor) ->
    editor.getCursorBufferPosition().row + 1 < @linesInFile
