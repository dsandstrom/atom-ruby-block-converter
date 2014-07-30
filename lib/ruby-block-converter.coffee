module.exports =
class RubyBlockConverter
  constructor: ->
    @initializeTransaction()

  destroy: ->

  initializeTransaction: ->
    @editor = atom.workspace.getActiveEditor()
    @buffer = @editor.buffer
    @buffer.beginTransaction()

  finalizeTransaction: (foundBlock) ->
    if foundBlock
      @buffer.commitTransaction()
    else
      if @editor != null && @buffer != null
        # console.log 'Did not find valid block'
        @buffer.abortTransaction()
