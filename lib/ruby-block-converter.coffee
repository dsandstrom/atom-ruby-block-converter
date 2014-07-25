RubyBlockConverterView = require './ruby-block-converter-view'

module.exports =
  rubyBlockConverterView: null

  activate: (state) ->
    # @rubyBlockConverterView = new RubyBlockConverterView state.rubyBlockConverterViewState, @
    atom.workspaceView.command "ruby-block-converter:toCurly", => @toCurly()

  deactivate: ->
    @rubyBlockConverterView.destroy()

  # serialize: ->
  #   # rubyBlockConverterViewState: @rubyBlockConverterView.serialize()
    
  toCurly: ->
    editor = atom.workspace.getActiveEditor()
    buffer = editor.buffer
    buffer.beginTransaction()
    @replaceDo editor
    @replaceEnd editor
    buffer.commitTransaction()
  
  replaceDo: (editor) ->
    # find do
    editor.moveCursorUp()
    editor.moveCursorToEndOfLine()
    editor.selectToFirstCharacterOfLine()
    # selected = editor.getSelectedText()
    # selected.scan(/\sdo\s/, @doToBrace(editor))
    range = editor.getSelectedBufferRange()
    # # range.scan(/\sdo\s/, @doToBrace(editor))
    regexDoOnly = /\sdo$/
    regexDoBar = /\sdo\s\|/
    editor.buffer.scanInRange regexDoOnly, range, (obj) ->
      console.log 'found do only'
      obj.replace " {"
      obj.stop()
    editor.buffer.scanInRange regexDoBar, range, (obj) ->
      console.log 'found do bar'
      obj.replace " { |"
      obj.stop()
  
  replaceEnd: (editor) ->
    # find end
    editor.moveCursorDown 2
    editor.moveCursorToEndOfLine()
    editor.selectToFirstCharacterOfLine()
    range = editor.getSelectedBufferRange()
    regexEnd = /^end$/
    editor.buffer.scanInRange regexEnd, range, (obj) ->
      obj.replace ''
      obj.stop()
    editor.deleteLine()
    editor.moveCursorUp 1
    editor.moveCursorToFirstCharacterOfLine()
    editor.selectToEndOfLine()
    selection = editor.getSelection()
    selectedLine = selection.getText()
    # console.log selectedDo
    editor.deleteLine()
    editor.moveCursorUp 1
    editor.moveCursorToEndOfLine()
    selection = editor.getSelection()
    selection.insertText ' ' + selectedLine + ' }'
