{View} = require 'atom'

module.exports =
class RubyBlockConverterView extends View
  @content: ->
    @div class: 'ruby-block-converter overlay from-top', =>
      @div "The RubyBlockConverter package is Alive! It's ALIVE!", class: "message"

  initialize: ->
    # atom.workspaceView.command "ruby-block-converter:toggle", => @toggle()
    atom.workspaceView.command "ruby-block-converter:toCurly", => @toCurly()
    
  toCurly: ->
    # editor = atom.workspace.activePaneItem()
    editor = atom.workspace.getActiveEditor()
    @findDo editor
    
  findDo: (editor) ->
    editor.transact ->
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
      # selection = editor.getSelection()
      # selectedDo = selection.getText()
      # editor.deleteLine()
      # editor.moveCursorDown()
      # editor.moveCursorToFirstCharacterOfLine()
      # editor.deleteToBeginningOfLine()
      # editor.backspace()
      
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
    
  doToBrace: (editor) ->
    console.log 'found: do'
    
  # # Returns an object that can be retrieved when package is activated
  # serialize: ->

  # Tear down any state and detach
  # destroy: ->
  #   @detach()

  # toggle: ->
  #   console.log "RubyBlockConverterView was toggled!"
  #   if @hasParent()
  #     @detach()
  #   else
  #     atom.workspaceView.append(this)
