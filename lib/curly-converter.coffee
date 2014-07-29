RubyBlockConverter = require './ruby-block-converter'

REGEX_DO = /\sdo\b/
# REGEX_DO_ONLY = /\sdo$/
# REGEX_DO_BAR  = /\sdo\s\|/
REGEX_END     = /end\b/

module.exports =
class CurlyConverter extends RubyBlockConverter
  foundStart = false
  foundStartOnCurrent = false
  # foundStartOnNext = false
  foundEnd = false
  initialCursor = null
  endOfWordCursor = null
  doRange = null
  endRange = null
  maxLevels = 3

  constructor: ->
    super
    foundStart = false
    foundStartOnCurrent = false
    # foundStartOnNext = false
    foundEnd   = false
    # move cursor incase in the middle of end
    initialCursor = @editor.getCursorBufferPosition()
    # console.log @editor.getCursor().isInsideWord()
    cursor = @editor.getCursor()
    startOfCurrentWord = cursor.getBeginningOfCurrentWordBufferPosition()
    # endOfCurrentWord = cursor.getBeginningOfNextWordBufferPosition()
    console.log initialCursor
    console.log startOfCurrentWord
    console.log cursor.isInsideWord()
    # console.log endOfCurrentWord
    # move to end of word if not at the first character and not after the last
    if startOfCurrentWord.row == initialCursor.row
      if startOfCurrentWord.column < initialCursor.column
        console.log 'move cursor to end'
        @editor.moveCursorToEndOfWord()
    endOfWordCursor = @editor.getCursorBufferPosition()
    @findAndReplaceDo()
    @findAndReplaceEnd() if foundStart
    @finalizeTransaction foundStart && foundEnd

  scanForDo: (editor, range) ->
    editor.buffer.backwardsScanInRange REGEX_DO, range, (obj) ->
      foundStart = true
      doRange = range
      afterDo = obj.matchText.replace(/\sdo/, '')[0]
      obj.replace ' {' + afterDo ?= ''
      obj.stop()

  scanForEnd: (editor, range) ->
    editor.buffer.scanInRange /end/, range, (obj) ->
      # console.log 'found end'
      foundEnd = true
      endRange = range
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
      # foundStartOnNext = foundStart
      i += 1

  findAndReplaceEnd: ->
    # find end
    # console.log 'help'
    # @editor.moveCursorDown 2
    # @editor.moveCursorToEndOfLine()
    # @editor.selectToFirstCharacterOfLine()
    # make sure there is no end between the do and cursor
    startingPoint = [doRange.start.row, doRange.start.column]
    # console.log startingPoint
    # move to after end of current word
    endingPoint = [endOfWordCursor.row, endOfWordCursor.column]
    # console.log endingPoint
    # range = new Range startingPoint, endingPoint
    @scanForEnd @editor, [startingPoint, endingPoint]
    foundEndBeforeCursor = foundEnd
    if foundEndBeforeCursor
      foundEnd = false
    else
      # initial cursor range
      if endOfWordCursor != null
        @editor.setCursorBufferPosition endOfWordCursor
        @editor.selectToEndOfLine()
        range = @editor.getSelectedBufferRange()
        @scanForEnd @editor, range
      i = 0
      while !foundEnd && i < maxLevels
        # move down a line
        @editor.moveCursorDown 1
        @editor.moveCursorToEndOfLine()
        @editor.selectToFirstCharacterOfLine()
        range = @editor.getSelectedBufferRange()
        @scanForEnd @editor, range
        i += 1
    # if foundEnd
    #   @editor.deleteLine()
    #   @editor.moveCursorUp 1
    #   @editor.moveCursorToFirstCharacterOfLine()
    #   @editor.selectToEndOfLine()
    #   selection = @editor.getSelection()
    #   selectedLine = selection.getText()
    #   @editor.deleteLine()
    #   @editor.moveCursorUp 1
    #   @editor.moveCursorToEndOfLine()
    #   selection = @editor.getSelection()
    #   selection.insertText ' ' + selectedLine + ' }'
