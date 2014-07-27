module.exports =
class RubyBlockConverter
  constructor: ->
    @initializeTransaction()

  initializeTransaction: ->
    @editor = atom.workspace.getActiveEditor()
    @editor.buffer.beginTransaction()

  finalizeTransaction: (foundBlock) ->
    if foundBlock
      @editor.buffer.commitTransaction()
    else
      console.log 'Did not find valid block'
      @editor.buffer.abortTransaction()
