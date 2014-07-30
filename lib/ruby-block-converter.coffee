module.exports =
class RubyBlockConverter
  constructor: ->
    @initializeTransaction()

  destroy: ->

  initializeTransaction: ->
    @editor = atom.workspace.getActiveEditor()
    @editor.buffer.beginTransaction()

  finalizeTransaction: (foundBlock) ->
    if foundBlock
      @editor.buffer.commitTransaction()
    else
      if @editor != null && @editor.buffer != null
        # console.log 'Did not find valid block'
        @editor.buffer.abortTransaction()
