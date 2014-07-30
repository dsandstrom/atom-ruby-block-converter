RubyBlockConverter = require './ruby-block-converter'

module.exports =
class DoEndConverter extends RubyBlockConverter
  foundStart = false
  foundEnd   = false
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
    initialCursor = @editor.getCursorBufferPosition()
    @editor.selectAll()
    linesInFile = @editor.getSelectedBufferRange().getRows().length
    @findAndReplaceOpenCurly()
    @findAndReplaceClosedCurly() if foundStart
    @unCollapseBlock() if foundStart && foundEnd
    if unCollapsed
      @editor.setCursorBufferPosition startRange.end
      @editor.moveCursorDown 1
      @editor.moveCursorToEndOfLine()
    else
      @editor.setCursorBufferPosition initialCursor
    @finalizeTransaction foundStart && foundEnd

  scanForOpen: (editor, range) ->
    editor.buffer.scanInRange /\s\{(\s|$)/, range, (obj) ->
      foundStart = true
      startRange = obj.range
      afterOpen = obj.matchText.replace(/\s{/, '') || ''
      obj.replace ' do' + afterOpen
      obj.stop()

  scanForClosed: (editor, range) ->
    editor.buffer.scanInRange /(^|\s)\}(\W|$)/, range, (obj) ->
      foundEnd = true
      endRange = obj.range
      beforeClosed = obj.matchText.replace(/}/, '') || ''
      obj.replace beforeClosed + 'end'
      obj.stop()

  notFirstRow: (editor) ->
    editor.getCursorBufferPosition().row > 0

  notLastRow: (editor) ->
    editor.getCursorBufferPosition().row + 1 < linesInFile

  findAndReplaceOpenCurly: ->
    # select to the left
    @editor.setCursorBufferPosition initialCursor
    @editor.selectToFirstCharacterOfLine()
    r = @editor.getSelectedBufferRange()
    # scan for open
    @scanForOpen @editor, r
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
      @editor.setCursorBufferPosition startingPoint
      @editor.selectToEndOfLine()
      range = @editor.getSelectedBufferRange()
      @scanForClosed @editor, range
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
    # TODO: maybe make it's own transaction
    foundDoBar = false
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
            unCollapsed = true

      # indent new block based on original line
      @editor.setCursorBufferPosition startRange.start
      @editor.moveCursorDown 1
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectDown 1
      @editor.selectToEndOfLine()
      selection = @editor.getSelection()
      selection.autoIndentSelectedRows()
