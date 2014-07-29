RubyBlockConverter = require './ruby-block-converter'

# FIXME: only does inner loop right
# need to count dos and make sure the right amount of ends

REGEX_DO = /\sdo\b/
REGEX_END = /end\b/

module.exports =
class CurlyConverter extends RubyBlockConverter
  foundStart = false
  foundEnd = false
  foundStartOnCurrent = false
  foundStartOnNext = false
  foundStartOnSecond = false
  foundEndOnCurrent = false
  foundEndOnNext = false
  foundEndOnSecond = false
  initialCursor = null
  endOfWordCursor = null
  doRange = null
  endRange = null
  maxLevels = 3

  constructor: ->
    super
    foundStart = false
    foundEnd   = false
    foundStartOnCurrent = false
    foundStartOnNext = false
    foundStartOnSecond = false
    foundEndOnCurrent = false
    foundEndOnNext = false
    foundEndOnSecond = false
    # move cursor incase in the middle of end
    initialCursor = @editor.getCursorBufferPosition()
    # console.log @editor.getCursor().isInsideWord()
    # cursor = @editor.getCursor()
    # startOfCurrentWord = cursor.getBeginningOfCurrentWordBufferPosition()
    # startOfNextWord = cursor.getBeginningOfNextWordBufferPosition()
    # endOfCurrentWord = cursor.getBeginningOfNextWordBufferPosition()
    # console.log initialCursor
    # console.log startOfCurrentWord
    # console.log endOfCurrentWord
    # move to end of word if not at the first character and not after the last
    # if startOfCurrentWord.row == startOfNextWord.row == initialCursor.row
    #   if startOfCurrentWord.column < initialCursor.column
    #     # console.log 'move cursor to end'
    #     @editor.moveCursorToEndOfWord()
    endOfWordCursor = @editor.getCursorBufferPosition()

    @findAndReplaceDo()
    @findAndReplaceEnd() if foundStart
    @collapseBlock() if foundStart && foundEnd
    @editor.setCursorBufferPosition initialCursor
    @finalizeTransaction foundStart && foundEnd

  scanForDo: (editor, range) ->
    editor.buffer.backwardsScanInRange REGEX_DO, range, (obj) ->
      foundStart = true
      doRange = obj.range
      afterDo = obj.matchText.replace(/\sdo/, '')[0]
      obj.replace ' {' + afterDo ?= ''
      obj.stop()

  scanForEnd: (editor, range) ->
    editor.buffer.scanInRange /end/, range, (obj) ->
      # console.log 'found end'
      foundEnd = true
      endRange = obj.range
      # afterDo = obj.matchText.replace(/\sdo/, '')[0]
      # obj.replace ' {' + afterDo ?= ''
      obj.replace '}'
      obj.stop()

  findAndReplaceDo: ->
    currentLineRange = null
    nextLineRange = null
    # look on current line
    # only looks left because it makes finding the correct
    # end easier with nested blocks
    # @editor.moveCursorToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    range = @editor.getSelectedBufferRange()
    @scanForDo @editor, range
    foundStartOnCurrent = foundStart
    # interate up lines until do is found or reached max levels
    i = 0
    while !foundStart && i < maxLevels
      # move up line up
      @editor.moveCursorUp()
      @editor.moveCursorToEndOfLine()
      @editor.selectToFirstCharacterOfLine()
      r = @editor.getSelectedBufferRange()
      @scanForDo @editor, r
      if i == 0
        foundStartOnNext = foundStart
      if i == 1
        foundStartOnSecond = foundStart
      i += 1

  findAndReplaceEnd: ->
    if endOfWordCursor != null && doRange != null
      # make sure there is no end between the do and cursor
      # move after end of current word
      startingPoint = [doRange.end.row, doRange.end.column]
      endingPoint = [endOfWordCursor.row, endOfWordCursor.column]
      @scanForEnd @editor, [startingPoint, endingPoint]
      if foundEnd
        # found end too early
        foundEnd = false
      else
        # initial cursor range
        @editor.setCursorBufferPosition endOfWordCursor
        @editor.selectToEndOfLine()
        range = @editor.getSelectedBufferRange()
        @scanForEnd @editor, range
        foundEndOnCurrent = foundEnd
      i = 0
      while !foundEnd && i < maxLevels
        # move down a line
        @editor.moveCursorDown 1
        @editor.moveCursorToEndOfLine()
        @editor.selectToFirstCharacterOfLine()
        range = @editor.getSelectedBufferRange()
        @scanForEnd @editor, range
        if i == 0
          foundEndOnNext = foundEnd
        if i == 1
          foundEndOnSecond = foundEnd
        i += 1

  collapseBlock: ->
    @editor.setCursorBufferPosition initialCursor
    # move cursor to the do, then collapse
    if foundStartOnNext && foundEndOnNext
      @editor.moveCursorUp()
      @joinBlockLines @editor
    else if foundStartOnCurrent && foundEndOnSecond
      @joinBlockLines @editor
    else if foundStartOnSecond && foundEndOnCurrent
      @editor.moveCursorUp 2
      @joinBlockLines @editor

  joinBlockLines: (editor) ->
    editor.moveCursorToFirstCharacterOfLine()
    editor.selectDown 2
    editor.selectToEndOfLine()
    editor.getSelection().joinLines()
    editor.moveCursorToEndOfLine()
