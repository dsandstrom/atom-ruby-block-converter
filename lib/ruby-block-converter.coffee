RubyBlockConverterView = require './ruby-block-converter-view'

module.exports =
  rubyBlockConverterView: null

  activate: (state) ->
    @rubyBlockConverterView = new RubyBlockConverterView

  deactivate: ->
    @rubyBlockConverterView.destroy()

  # serialize: ->
  #   # rubyBlockConverterViewState: @rubyBlockConverterView.serialize()
    
  # toCurly: ->
  #   # editor = atom.workspace.activePaneItem()
  #   editor = atom.workspace.getActiveEditor()
  #   @findDo editor
  #
  # findDo: (editor) ->
  #   # editor.moveCursorUp()
  #   # editor.moveCursorToEndOfLine()
  #   # editor.selectToFirstCharacterOfLine()
  #   # # selected = editor.getSelectedText()
  #   # # selected.scan(/\sdo\s/, @doToBrace(editor))
  #   # range = editor.getSelectedBufferRange()
  #   # # # range.scan(/\sdo\s/, @doToBrace(editor))
  #   # regexDo = /\sdo$/
  #   # editor.buffer.scanInRange regexDo, range, (obj) ->
  #   #   obj.replace " { "
  #   # editor.moveCursorDown()
  #   # editor.moveCursorToFirstCharacterOfLine()
  #   # editor.deleteToBeginningOfLine()
  #   # editor.backspace()
  #   editor.moveCursorDown()
  #   editor.moveCursorToEndOfLine()
  #   editor.selectToFirstCharacterOfLine()
  #   range = editor.getSelectedBufferRange()
  #   regexEnd = /^end$/
  #   editor.buffer.scanInRange regexEnd, range, (obj) ->
  #     # obj.replace " }"
  #     console.log obj.matchText
  #
  # doToBrace: (editor) ->
  #   console.log 'found: do'
