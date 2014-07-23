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
    # editor.moveCursorUp()
    # editor.moveCursorToEndOfLine()
    # editor.selectToFirstCharacterOfLine()
    # # selected = editor.getSelectedText()
    # # selected.scan(/\sdo\s/, @doToBrace(editor))
    # range = editor.getSelectedBufferRange()
    # # # range.scan(/\sdo\s/, @doToBrace(editor))
    # regexDo = /\sdo$/
    # editor.buffer.scanInRange regexDo, range, (obj) ->
    #   obj.replace " { "
    # editor.moveCursorDown()
    # editor.moveCursorToFirstCharacterOfLine()
    # editor.deleteToBeginningOfLine()
    # editor.backspace()
    editor.moveCursorDown()
    editor.moveCursorToEndOfLine()
    editor.selectToFirstCharacterOfLine()
    range = editor.getSelectedBufferRange()
    regexEnd = /^end$/
    editor.buffer.scanInRange regexEnd, range, (obj) ->
      # obj.replace " }"
      console.log obj.matchText
      
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
