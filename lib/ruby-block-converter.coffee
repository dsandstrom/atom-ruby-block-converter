module.exports =
class RubyBlockConverter
  constructor: ->
    @initializeTransaction()

  destroy: ->

  initializeTransaction: ->
    @editor = atom.workspace.getActiveEditor()
    @buffer = @editor.buffer
    @buffer.beginTransaction()

    @initialCursor = @editor.getCursorBufferPosition()
    @editor.selectAll()
    @linesInFile = @editor.getSelectedBufferRange().getRows().length
    @editor.setCursorBufferPosition @initialCursor

  finalizeTransaction: (foundBlock) ->
    if foundBlock
      @buffer.commitTransaction()
    else
      if @editor != null && @buffer != null
        # console.log 'Did not find valid block'
        try
          @buffer.abortTransaction()
        catch error
          throw error

  notFirstRow: (editor) ->
    editor.getCursorBufferPosition().row > 0

  notLastRow: (editor) ->
    editor.getCursorBufferPosition().row + 1 < @linesInFile
