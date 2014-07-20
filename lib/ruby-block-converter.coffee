RubyBlockConverterView = require './ruby-block-converter-view'

module.exports =
  rubyBlockConverterView: null

  activate: (state) ->
    # @rubyBlockConverterView = new RubyBlockConverterView(state.rubyBlockConverterViewState)
    atom.workspaceView.command "ruby-block-converter:toCurly", => @toCurly()

  deactivate: ->
    # @rubyBlockConverterView.destroy()

  serialize: ->
    # rubyBlockConverterViewState: @rubyBlockConverterView.serialize()
    
  toCurly: ->
    editor = atom.workspace.activePaneItem
    @findDo editor
    
  findDo: (editor) ->
    editor.moveCursorUp()
    editor.moveCursorToEndOfLine()
    editor.selectToFirstCharacterOfLine()
    # selected = editor.getSelectedText()
    # selected.scan(/\sdo\s/, @doToBrace(editor))
    range = editor.getSelectedBufferRange()
    range.scan(/\sdo\s/, @doToBrace(editor))
  
  doToBrace: (editor) ->
    console.log 'found: do'
