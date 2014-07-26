REGEX_OPEN_CURLY_ONLY = /\s\{\s/
REGEX_OPEN_CURLY_BAR  = /\s\{\s\|.*\|\s/
REGEX_CLOSED_CURLY    = /\s\}$/

module.exports =
class DoEndConverter
  foundStart = false
  foundEnd   = false
  
  constructor: (editor) ->
    @editor = editor
    foundStart = false
    foundEnd   = false
    @replaceOpenCurly()
    @replaceClosedCurly() if foundStart
    
  foundBlock: ->
    foundStart && foundEnd
  
  replaceOpenCurly: ->
    @editor.moveCursorToBeginningOfLine()
    @editor.selectToEndOfLine()

    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_OPEN_CURLY_BAR, range, (obj) ->
      foundStart = true
      # replace scaces and convert bracket
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
    
    # indent end
    @editor.moveCursorToBeginningOfLine()
    @editor.selectToEndOfLine()
    selection = @editor.getSelection()
    selection.autoIndentSelectedRows()
    
    # delete extra space and move cursor to a convenient spot
    @editor.moveCursorUp 1
    @editor.moveCursorToEndOfLine()
    @editor.selectToPreviousWordBoundary()
    selection = @editor.getSelection()
    selection.delete()
