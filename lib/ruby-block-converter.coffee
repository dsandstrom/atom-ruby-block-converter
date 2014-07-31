module.exports =
class RubyBlockConverter
  constructor: ->
    @editor = atom.workspace.getActiveEditor()
    @buffer = @editor.buffer

    @initialCursor = @editor.getCursorBufferPosition()
    @editor.selectAll()
    @linesInFile = @editor.getSelectedBufferRange().getRows().length
    @editor.setCursorBufferPosition @initialCursor

  destroy: ->
    @editor = null
    @buffer = null
    @initialCursor = null
    @linesInFile = null

  performTransaction: (startRange, endRange) ->
    if startRange != null and endRange != null
      @buffer.beginTransaction()
      @replaceBlock(startRange, endRange)
      @collapseBlock(startRange, endRange)
      @resetCursor(startRange)
      @buffer.commitTransaction()
    else if @initialCursor != null
      @editor.setCursorBufferPosition @initialCursor

  notFirstRow: (editor) ->
    editor.getCursorBufferPosition().row > 0

  notLastRow: (editor) ->
    editor.getCursorBufferPosition().row + 1 < @linesInFile
