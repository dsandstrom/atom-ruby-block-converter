CurlyConverter = require './curly-converter'
DoEndConverter = require './do-end-converter'

module.exports =

  activate: (state) ->
    atom.workspaceView.command "ruby-block-converter:toCurlyBrackets", =>
      @toCurlyBrackets()
    atom.workspaceView.command "ruby-block-converter:toDoEnd", =>
      @toDoEnd()
    @editor = atom.workspace.getActiveEditor()

  deactivate: ->

  initializeTransaction: ->
    @editor.buffer.beginTransaction()
  
  finalizeTransaction: (foundBlock) ->
    if foundBlock
      @editor.buffer.commitTransaction()
    else
      console.log 'Did not find valid block'
      @editor.buffer.abortTransaction()

  # Converts do-end blocks to curly bracket blocks
  toCurlyBrackets: ->
    # @initializeTransaction()
    @curlyConverter = new CurlyConverter()
    # @editor = atom.workspace.getActiveEditor()
    # @finalizeTransaction @curlyConverter.foundBlock()

  # Converts curly bracket blocks to do-end blocks
  toDoEnd: ->
    # @initializeTransaction()
    @doEndConverter = new DoEndConverter()
    # @finalizeTransaction @doEndConverter.foundBlock()
