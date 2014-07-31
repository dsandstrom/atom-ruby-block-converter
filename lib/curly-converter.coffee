RubyBlockConverter = require './ruby-block-converter'

# FIXME: only does inner loop right
# need to count dos and make sure the right amount of ends

module.exports =
class CurlyConverter extends RubyBlockConverter
  # foundStart = false
  # foundEnd = false
  # initialCursor = null
  # doRange = null
  # endRange = null
  # linesInFile = null
  # collapsed = false
  maxLevels = 3

  # constructor: ->
  #   super
  #   # foundStart = false
  #   # foundEnd   = false
  #   # initialCursor = @editor.getCursorBufferPosition()
  #   # @editor.selectAll()
  #   # linesInFile = @editor.getSelectedBufferRange().getRows().length
  #
  #   # @findAndReplaceDo()
  #   # @findAndReplaceEnd() if foundStart
  #   # @collapseBlock() if foundStart && foundEnd
  #   # if !collapsed && initialCursor != null
  #   #   @editor.setCursorBufferPosition initialCursor
  #   #
  #   # @finalizeTransaction foundStart && foundEnd

  scanForDo: (editor, range) ->
    # scan backwards for first do
    startRange = null
    editor.buffer.backwardsScanInRange /\sdo\b/, range, (obj) ->
      # foundStart = true
      startRange = obj.range
      # afterDo = obj.matchText.replace(/\sdo/, '') ||  ''
      # obj.replace ' {' + afterDo
      obj.stop()
    startRange

  scanForEnd: (editor, range) ->
    # scan for first end
    endRange = null
    editor.buffer.scanInRange /end/, range, (obj) ->
      # foundEnd = true
      endRange = obj.range
      # obj.replace '}'
      # obj.stop()
    endRange

  # notFirstRow: (editor) ->
  #   editor.getCursorBufferPosition().row > 0
  #
  # notLastRow: (editor) ->
  #   editor.getCursorBufferPosition().row + 1 < linesInFile

  findDo: ->
    startRange = null
    # look on current line
    # only looks left because it makes finding the correct
    # end easier with nested blocks
    @editor.setCursorBufferPosition @initialCursor
    @editor.selectToFirstCharacterOfLine()
    range = @editor.getSelectedBufferRange()
    startRange = @scanForDo(@editor, range)
    # interate up lines until do is found or reached max levels
    i = 0
    while startRange == null && i < maxLevels && @notFirstRow(@editor)
      # move up line up
      @editor.moveCursorUp()
      @editor.moveCursorToEndOfLine()
      @editor.selectToFirstCharacterOfLine()
      r = @editor.getSelectedBufferRange()
      startRange = @scanForDo(@editor, r)
      i += 1
    startRange

  findEnd: (startRange) ->
    endRange = null
    # make sure there is no end between the do and cursor
    # move after end of current word
    startingPoint = [startRange.end.row, startRange.end.column]
    @editor.setCursorBufferPosition startingPoint
    @editor.selectToEndOfLine()
    range = @editor.getSelectedBufferRange()
    endRange = @scanForEnd(@editor, range)
    if endRange == null
      # initial cursor range
      i = 0
      while endRange == null && i < maxLevels && @notLastRow(@editor)
        # move down a line
        @editor.moveCursorDown 1
        @editor.moveCursorToEndOfLine()
        @editor.selectToFirstCharacterOfLine()
        r = @editor.getSelectedBufferRange()
        endRange = @scanForEnd(@editor, r)
        i += 1
    # cancel if end found on a line before cursor
    if endRange != null && @initialCursor != null
      if endRange.start.row < @initialCursor.row
        endRange = null
    endRange

  replaceBlock: (startRange, endRange) ->
    @editor.buffer.backwardsScanInRange /end/, endRange, (obj) ->
      match = obj.matchText.match(/([\W])end(.*)/, '')
      if match != null
        beforeEnd = match[1]
        afterEnd = match[2]
      obj.replace (beforeEnd ?= '') + '}' + (afterEnd ?= '')
      obj.stop()
    @editor.buffer.scanInRange /do/, startRange, (obj) ->
      afterDo = obj.matchText.replace(/do/, '') || ''
      obj.replace '{' + afterDo
      obj.stop()

  resetCursor: (collapsed, startRange=null) ->
    if collapsed
      @editor.moveCursorToEndOfLine()
    else
      @editor.setCursorBufferPosition(@initialCursor)

  collapseBlock: (startRange, endRange) ->
    # TODO: maybe make it's own transaction
    # see how many lines between start and end
    lineSeparation = endRange.start.row - startRange.start.row

    if 1 <= lineSeparation and lineSeparation <= 2
      # join lines if it makes sense
      @editor.setCursorBufferPosition startRange.start
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectDown lineSeparation
      @editor.selectToEndOfLine()
      @editor.getSelection().joinLines()
      # @editor.moveCursorToEndOfLine()
      collapsed = true
