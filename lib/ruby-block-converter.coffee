REGEX_DO_ONLY      = /\sdo$/
REGEX_DO_BAR       = /\sdo\s\|/
REGEX_OPEN_CURLY_ONLY   = /\s\{\s/
REGEX_OPEN_CURLY_BAR   = /\s\{\s\|.*\|\s/
REGEX_CLOSED_CURLY = /\s\}$/

foundStart = false
foundEnd   = false

module.exports =

  activate: (state) ->
    atom.workspaceView.command "ruby-block-converter:toCurlyBrackets", =>
      @toCurlyBrackets()
    atom.workspaceView.command "ruby-block-converter:toDoEnd", =>
      @toDoEnd()

  deactivate: ->

  toCurlyBrackets: ->
    @editor = atom.workspace.getActiveEditor()
    
    foundStart = false
    foundEnd   = false

    @editor.buffer.beginTransaction()
    @replaceDo()
    @replaceEnd() if foundStart
    @finishTransaction()

  toDoEnd: ->
    @editor = atom.workspace.getActiveEditor()
    
    foundStart = false
    foundEnd   = false
    
    @editor.buffer.beginTransaction()
    @replaceOpenCurly()
    @replaceClosedCurly() if foundStart
    @finishTransaction()

  replaceOpenCurly: ->
    @editor.moveCursorToBeginningOfLine()
    @editor.selectToEndOfLine()
    foundOpenCurlyBar = false
    
    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_OPEN_CURLY_BAR, range, (obj) ->
      # console.log 'found open curly'
      foundStart = true
      barText = obj.matchText
      barText = barText.replace /\s/g, ''
      barText = barText.replace /\{/, ''
      obj.replace " do #{barText}\n"
      obj.stop()
  
    unless foundStart
      @editor.buffer.scanInRange REGEX_OPEN_CURLY_ONLY, range, (obj) ->
        # console.log 'found open curly'
        foundStart = true
        obj.replace " do\n"
        obj.stop()
  
  replaceClosedCurly: ->
    @editor.moveCursorToBeginningOfLine()
    @editor.selectToEndOfLine()
    selection = @editor.getSelection()
    selection.autoIndentSelectedRows()
    
    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_CLOSED_CURLY, range, (obj) ->
      # console.log 'found closed curly'
      foundEnd = true
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
      # console.log 'found do only'
      foundStart = true
      obj.replace " {"
      obj.stop()
    
    unless foundStart
      @editor.buffer.scanInRange REGEX_DO_BAR, range, (obj) ->
        # console.log 'found do bar'
        foundStart = true
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
      foundEnd = true
      obj.replace ''
      obj.stop()
    if foundEnd
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
  
  finishTransaction: ->
    if foundStart && foundEnd
      @editor.buffer.commitTransaction()
    else
      console.log 'Did not find valid block'
      @editor.buffer.abortTransaction()
