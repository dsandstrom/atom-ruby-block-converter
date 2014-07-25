REGEX_DO_ONLY      = /\sdo$/
REGEX_DO_BAR       = /\sdo\s\|/
REGEX_OPEN_CURLY   = /\s\{\s/
REGEX_CLOSED_CURLY = /\s\}$/

module.exports =

  activate: (state) ->
    atom.workspaceView.command "ruby-block-converter:toCurlyBrackets", =>
      @toCurlyBrackets()
    atom.workspaceView.command "ruby-block-converter:toDoEnd", =>
      @toDoEnd()

  deactivate: ->

  toCurlyBrackets: ->
    @editor = atom.workspace.getActiveEditor()
    @buffer = @editor.buffer
    @buffer.beginTransaction()
    @replaceDo()
    @replaceEnd()
    @buffer.commitTransaction()

  toDoEnd: ->
    @editor = atom.workspace.getActiveEditor()
    @buffer = @editor.buffer
    @buffer.beginTransaction()
    @replaceOpenCurly()
    @replaceClosedCurly()
    @buffer.commitTransaction()

  replaceOpenCurly: ->
    @editor.moveCursorToBeginningOfLine()
    @editor.selectToEndOfLine()
    
    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_OPEN_CURLY, range, (obj) ->
      console.log 'found open curly'
      obj.replace " do\n"
      obj.stop()
  
  replaceClosedCurly: ->
    @editor.moveCursorToBeginningOfLine()
    @editor.selectToEndOfLine()
    selection = @editor.getSelection()
    selection.autoIndentSelectedRows()
    
    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_CLOSED_CURLY, range, (obj) ->
      console.log 'found closed curly'
      obj.replace " \nend"
      obj.stop()
    
    # delete extra space and move cursor to a convenient spot
    @editor.moveCursorToBeginningOfLine()
    @editor.moveCursorUp 1
    @editor.moveCursorToEndOfLine()
    @editor.selectToPreviousWordBoundary()
    selection = @editor.getSelection()
    selection.delete()

  replaceDo: ->
    # find do
    @editor.moveCursorUp()
    @editor.moveCursorToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    
    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_DO_ONLY, range, (obj) ->
      console.log 'found do only'
      obj.replace " {"
      obj.stop()
    @editor.buffer.scanInRange REGEX_DO_BAR, range, (obj) ->
      console.log 'found do bar'
      obj.replace " { |"
      obj.stop()
  
  replaceEnd: ->
    # find end
    @editor.moveCursorDown 2
    @editor.moveCursorToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    range = @editor.getSelectedBufferRange()
    regexEnd = /^end$/
    @editor.buffer.scanInRange regexEnd, range, (obj) ->
      obj.replace ''
      obj.stop()
    @editor.deleteLine()
    @editor.moveCursorUp 1
    @editor.moveCursorToFirstCharacterOfLine()
    @editor.selectToEndOfLine()
    selection = @editor.getSelection()
    selectedLine = selection.getText()
    @editor.deleteLine()
    @editor.moveCursorUp 1
    @editor.moveCursorToEndOfLine()
    selection = @editor.getSelection()
    selection.insertText ' ' + selectedLine + ' }'
