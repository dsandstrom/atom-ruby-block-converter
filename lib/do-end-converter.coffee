RubyBlockConverter = require './ruby-block-converter'

REGEX_OPEN_CURLY_ONLY = /\s\{\s/
REGEX_OPEN_CURLY_BAR  = /\s\{\s\|.*\|\s/
REGEX_CLOSED_CURLY    = /\s\}$/

module.exports =
class DoEndConverter extends RubyBlockConverter
  foundStart = false
  foundEnd   = false
  # foundStartOnCurrent = false
  startRange = null
  endRange = null
  initialCursor = null
  unCollapsed = false
  linesInFile = null
  maxLevels = 3

  constructor: ->
    super
    foundStart = false
    foundEnd   = false
    # foundStartOnCurrent = false
    initialCursor = @editor.getCursorBufferPosition()
    @editor.selectAll()
    linesInFile = @editor.getSelectedBufferRange().getRows().length
    console.log linesInFile
    @findAndReplaceOpenCurly()
    @findAndReplaceClosedCurly() if foundStart
    # console.log 'foundStart :' + foundStart
    # console.log 'foundEnd :' + foundEnd
    @unCollapseBlock() if foundStart && foundEnd
    if unCollapsed
      @editor.setCursorBufferPosition startRange.end
      @editor.moveCursorDown 1
      @editor.moveCursorToEndOfLine()
    else
      @editor.setCursorBufferPosition initialCursor
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

  notFirstRow: (editor) ->
    editor.getCursorBufferPosition().row > 0

  notLastRow: (editor) ->
    console.log editor.getCursorBufferPosition().row + 1
    editor.getCursorBufferPosition().row + 1 < linesInFile

  findAndReplaceOpenCurly: ->
    # select to the left
    @editor.setCursorBufferPosition initialCursor
    @editor.selectToFirstCharacterOfLine()
    r = @editor.getSelectedBufferRange()
    # scan for open
    @scanForOpen @editor, r
    # console.log foundStart
    # foundStartOnCurrent = foundStart
    # go up lines until one { is found
    i = 0
    while !foundStart && i < maxLevels && @notFirstRow(@editor)
      @editor.moveCursorUp 1
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectToEndOfLine()
      r = @editor.getSelectedBufferRange()
      @scanForOpen @editor, r
      i += 1


  findAndReplaceClosedCurly: ->
    if startRange != null
      # make sure there is no } between the { and cursor
      # move after end of current word
      startingPoint = [startRange.end.row, startRange.end.column]
      # endingPoint = [initialCursor.row, initialCursor.column]
      @editor.setCursorBufferPosition startingPoint
      @editor.selectToEndOfLine()
      range = @editor.getSelectedBufferRange()
      @scanForClosed @editor, range
      # unless foundEnd
      #   # initial cursor range
      #   @editor.setCursorBufferPosition initialCursor
      #   @editor.selectToEndOfLine()
      #   range = @editor.getSelectedBufferRange()
      #   @scanForClosed @editor, range
      i = 0
      while !foundEnd && i < maxLevels && @notLastRow(@editor)
        # move down a line
        @editor.moveCursorDown 1
        @editor.moveCursorToEndOfLine()
        @editor.selectToFirstCharacterOfLine()
        range = @editor.getSelectedBufferRange()
        @scanForClosed @editor, range
        i += 1
      # cancel if end found on a line before cursor
      if foundEnd && initialCursor != null
        if endRange.start.row < initialCursor.row
          foundEnd = false

  unCollapseBlock: ->
    # console.log 'unCollapse'
    foundDoBar = false
    # unCollapsedDo = false
    unCollapsedEnd = false
    @editor.setSelectedBufferRange endRange
    @editor.selectToEndOfWord()
    newEndRange = @editor.getSelectedBufferRange()
    # only do same line
    if startRange.start.row == endRange.start.row
      # add new line in front of new end
      @editor.buffer.scanInRange /\send/, newEndRange, (obj) ->
        obj.replace "\nend"
        unCollapsedEnd = true
      if unCollapsedEnd
        # range needs to get bigger
        @editor.setCursorBufferPosition startRange.start
        @editor.selectToEndOfLine()
        newStartRange = @editor.getSelectedBufferRange()
        # and new line after bars
        @editor.buffer.scanInRange /do\s\|.*\|/, newStartRange, (obj) ->
          text = obj.matchText
          obj.replace "#{text}\n"
          foundDoBar = true
          unCollapsedDo = true
        unless foundDoBar
          # and new line after do$
          @editor.buffer.scanInRange /do/, newStartRange, (obj) ->
            obj.replace "do\n"
            # unCollapsedDo = true
            unCollapsed = true

      # indent new block
      @editor.setCursorBufferPosition initialCursor
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectDown 2
      @editor.selectToEndOfLine()
      selection = @editor.getSelection()
      selection.autoIndentSelectedRows()
