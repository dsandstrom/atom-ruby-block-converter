RubyBlockConverter = require './ruby-block-converter'

REGEX_OPEN_CURLY_ONLY = /\s\{\s/
REGEX_OPEN_CURLY_BAR  = /\s\{\s\|.*\|\s/
REGEX_CLOSED_CURLY    = /\s\}$/

module.exports =
class DoEndConverter extends RubyBlockConverter
  foundStart = false
  foundEnd   = false
  foundStartOnCurrent = false
  startRange = null
  endRange = null
  initialCursor = null
  maxLevels = 3

  constructor: ->
    super
    foundStart = false
    foundEnd   = false
    foundStartOnCurrent = false
    initialCursor = @editor.getCursorBufferPosition()

    @findAndReplaceOpenCurly()
    @findAndReplaceClosedCurly() if foundStart
    @unCollapseBlock() if foundStart && foundEnd
    # @editor.setCursorBufferPosition initialCursor
    @finalizeTransaction foundStart && foundEnd

  scanForOpen: (editor, range) ->
    editor.buffer.scanInRange /\s\{\s/, range, (obj) ->
      foundStart = true
      startRange = obj.range
      obj.replace ' do '
      obj.stop()
    unless foundStart
      editor.buffer.scanInRange /\s\{$/, range, (obj) ->
        foundStart = true
        startRange = obj.range
        obj.replace ' do'
        obj.stop()

  scanForClosed: (editor, range) ->
    editor.buffer.scanInRange /\s\}$/, range, (obj) ->
      foundEnd = true
      endRange = obj.range
      obj.replace ' end'
      obj.stop()
    unless foundEnd
      editor.buffer.scanInRange /\s\}\W/, range, (obj) ->
        foundEnd = true
        endRange = obj.range
        obj.replace ' end '
        obj.stop()
    unless foundEnd
      editor.buffer.scanInRange /^\}/, range, (obj) ->
        foundEnd = true
        endRange = obj.range
        obj.replace 'end'
        obj.stop()

  findAndReplaceOpenCurly: ->
    # select to the left
    @editor.selectToFirstCharacterOfLine()
    r = @editor.getSelectedBufferRange()
    # scan for open
    @scanForOpen @editor, r
    foundStartOnCurrent = foundStart
    # go up lines until one { is found
    i = 0
    while !foundStart && i < maxLevels
      @editor.moveCursorUp 1
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectToEndOfLine()
      r = @editor.getSelectedBufferRange()
      @scanForOpen @editor, r
      i += 1

  findAndReplaceClosedCurly: ->
    if initialCursor != null && startRange != null
      # make sure there is no } between the { and cursor
      # move after end of current word
      startingPoint = [startRange.end.row, startRange.end.row]
      endingPoint = [initialCursor.row, initialCursor.column]
      @scanForClosed @editor, [startingPoint, endingPoint]
      if foundEnd
        # found end too early
        foundEnd = false
      else
        # initial cursor range
        @editor.setCursorBufferPosition initialCursor
        @editor.selectToEndOfLine()
        range = @editor.getSelectedBufferRange()
        @scanForClosed @editor, range
        foundEndOnCurrent = foundEnd
      i = 0
      while !foundEnd && i < maxLevels
        # move down a line
        @editor.moveCursorDown 1
        @editor.moveCursorToEndOfLine()
        @editor.selectToFirstCharacterOfLine()
        range = @editor.getSelectedBufferRange()
        @scanForClosed @editor, range
        # if i == 0
        #   foundEndOnNext = foundEnd
        # if i == 1
        #   foundEndOnSecond = foundEnd
        i += 1

  unCollapseBlock: ->
    @editor.setCursorBufferPosition initialCursor
    console.log startRange.start.row
    console.log endRange.start.row
    newEndRangeStart = [endRange.start.row, endRange.start.columns - 1]
    newEndRangeEnd = [endRange.end.row, endRange.end.columns + 1]
    newEndRange = [newEndRangeStart, newEndRangeEnd]
    @editor.setSelectedBufferRange endRange
    @editor.selectToEndOfWord()
    range = @editor.getSelectedBufferRange()
    if startRange.start.row == endRange.start.row
      @editor.buffer.scanInRange /\send/, range, (obj) ->
        console.log 'test'
        obj.replace "\nend"
      @editor.buffer.scanInRange /do/, startRange, (obj) ->
        obj.replace "do\n"
      @editor.setCursorBufferPosition initialCursor
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectDown 2
      @editor.selectToEndOfLine()
      selection = @editor.getSelection()
      selection.autoIndentSelectedRows()
    # move cursor to the do, then collapse
    # if foundStartOnNext && foundEndOnNext
    #   @editor.moveCursorUp()
    #   @joinBlockLines @editor
    # else if foundStartOnCurrent && foundEndOnSecond
    #   @joinBlockLines @editor
    # else if foundStartOnSecond && foundEndOnCurrent
    #   @editor.moveCursorUp 2
    #   @joinBlockLines @editor


  # joinBlockLines: (editor) ->
  #   editor.moveCursorToFirstCharacterOfLine()
  #   editor.selectDown 2
  #   editor.selectToEndOfLine()
  #   editor.getSelection().joinLines()
  #   editor.moveCursorToEndOfLine()
