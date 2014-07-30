RubyBlockConverter = require './ruby-block-converter'

# FIXME: only does inner loop right
# need to count dos and make sure the right amount of ends

module.exports =
class CurlyConverter extends RubyBlockConverter
  foundStart = false
  foundEnd = false
  initialCursor = null
  doRange = null
  endRange = null
  linesInFile = null
  maxLevels = 3

  constructor: ->
    super
    foundStart = false
    foundEnd   = false
    initialCursor = @editor.getCursorBufferPosition()
    @editor.selectAll()
    linesInFile = @editor.getSelectedBufferRange().getRows().length

    @findAndReplaceDo()
    @findAndReplaceEnd() if foundStart
    @collapseBlock() if foundStart && foundEnd
    @finalizeTransaction foundStart && foundEnd

  scanForDo: (editor, range) ->
    # scan backwards for first do
    editor.buffer.backwardsScanInRange /\sdo\b/, range, (obj) ->
      foundStart = true
      doRange = obj.range
      afterDo = obj.matchText.replace(/\sdo/, '')[0]
      obj.replace ' {' + afterDo ?= ''
      obj.stop()

  scanForEnd: (editor, range) ->
    # scan for first end
    editor.buffer.scanInRange /end/, range, (obj) ->
      foundEnd = true
      endRange = obj.range
      obj.replace '}'
      obj.stop()

  notFirstRow: (editor) ->
    editor.getCursorBufferPosition().row > 0

  notLastRow: (editor) ->
    editor.getCursorBufferPosition().row + 1 < linesInFile

  findAndReplaceDo: ->
    # look on current line
    # only looks left because it makes finding the correct
    # end easier with nested blocks
    @editor.setCursorBufferPosition initialCursor
    @editor.selectToFirstCharacterOfLine()
    range = @editor.getSelectedBufferRange()
    @scanForDo @editor, range
    # interate up lines until do is found or reached max levels
    i = 0
    while !foundStart && i < maxLevels && @notFirstRow(@editor)
      # move up line up
      @editor.moveCursorUp()
      @editor.moveCursorToEndOfLine()
      @editor.selectToFirstCharacterOfLine()
      r = @editor.getSelectedBufferRange()
      @scanForDo @editor, r
      i += 1

  findAndReplaceEnd: ->
    if doRange != null
      # make sure there is no end between the do and cursor
      # move after end of current word
      startingPoint = [doRange.end.row, doRange.end.column]
      @editor.setCursorBufferPosition startingPoint
      @editor.selectToEndOfLine()
      r = @editor.getSelectedBufferRange()
      @scanForEnd @editor, r
      unless foundEnd
        # initial cursor range
        i = 0
        while !foundEnd && i < maxLevels && @notLastRow(@editor)
          # move down a line
          @editor.moveCursorDown 1
          @editor.moveCursorToEndOfLine()
          @editor.selectToFirstCharacterOfLine()
          range = @editor.getSelectedBufferRange()
          @scanForEnd @editor, range
          i += 1
      # cancel if end found on a line before cursor
      if foundEnd && initialCursor != null
        if endRange.start.row < initialCursor.row
          foundEnd = false

  collapseBlock: ->
    # see how many lines between start and end
    lineSeparation = endRange.start.row - doRange.start.row

    if 1 <= lineSeparation <= 2
      # join lines if it makes sense
      @editor.setCursorBufferPosition doRange.start
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectDown lineSeparation
      @editor.selectToEndOfLine()
      @editor.getSelection().joinLines()
      @editor.moveCursorToEndOfLine()
    else if initialCursor != null
      # otherwise put cursor back to original spot
      @editor.setCursorBufferPosition initialCursor
