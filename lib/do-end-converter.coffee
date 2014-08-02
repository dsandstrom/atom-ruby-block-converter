RubyBlockConverter = require './ruby-block-converter'

module.exports =
class DoEndConverter extends RubyBlockConverter
  # openRegex: /\{\s*(\||\'\w+\"\s[^=]|\"\w+\"\s[^=]|\`|\w+(\s+|\.)|@|\w+$|\{|$)/
  # openRegex: /(^|\w\)|.\w+|\"|\'|\`)\s*\{(\||\'\w+\"\s[^=]|\"\w+\"\s[^=]|\`|\w+(\s+|\.)|@|\w+$|$)/
  # openRegex: /(^|\w\)|.\w+|\"|\'|\`)\s*\{(\||\'\w+\"\s[^=]|\"\w+\"\s[^=]|\`|\w+(\s+|\.)|\@|\w+$|$)/
  # openRegex: /(^|\w\)|.\w+|\"|\'|\`)\s*\{(\||\'\w+\"\s[^=]|\"\w+\"\s[^=]|\`|\w+|@|\w+$|$)/
  # openRegex: /\{\s*(\||\'\w+\"\s[^=]|\"\w+\"\s[^=]|\`|\w+(\s+|\.)|@|\w+$|$)/g
  # openRegex: /\{\s*(\||\'\w+\"\s[^=]|\"\w+\"\s[^=]|\`|\w+(\s+|\.)|@|\w+$|$)/g
  openRegex: /(^|([\"\'\w^]|[\s\.\:]\w+\))\s+)\{\s*([\"\']\w+[\"\']\s+\=[^>]|[^:\"\']\w+[^:][\s\.]|\n|\{|$)/g

  scanForOpen: (editor, range, cursorPoint=null) ->
    # scan backwards for first {
    startRange = null
    # console.log cursorPoint
    editor.buffer.backwardsScanInRange @openRegex, range, (obj) ->
      console.log obj
      # console.log cursorPoint
      if cursorPoint != null
        console.log obj
        console.log cursorPoint
        sameRow = obj.range.start.row == cursorPoint.row
        # fudge factor for regex
        leftOfCursor = obj.range.start.column + 2 < cursorPoint.column
        # console.log sameRow
        # console.log leftOfCursor
        # console.log minPoints == null or obj.range == null or (obj.range.start.row == minPoints.row and obj.range.start.column < minPoints.column)
        if sameRow and leftOfCursor
          # console.log obj
          startRange = obj.range
          obj.stop()
      else
        startRange = obj.range
        obj.stop()
    # console.log startRange
    startRange

  scanForClosed: (that, editor, range) ->
    # scan for }, scan for matching {
    matchRanges = []
    editor.buffer.scanInRange /\}/g, range, (obj) ->
      that.endCount++
      matchRanges.push obj.range
    editor.buffer.scanInRange /\{/g, range, (obj) ->
      that.startCount++
    console.log that.startCount
    console.log that.endCount
    console.log matchRanges
    matchRanges

  findOpenCurly: ->
    startRange = null
    # select to the left
    @editor.setCursorBufferPosition @initialCursor
    # @editor.moveCursorToBeginningOfNextWord()
    # @editor.selectToFirstCharacterOfLine()
    @editor.moveCursorToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    # @editor.selectLine()
    range = @editor.getSelectedBufferRange()
    console.log @editor.getSelection().getText()
    # scan for open
    startRange = @scanForOpen(@editor, range, @initialCursor)
    # go up lines until one { is found
    i = 0
    while startRange == null and i < @maxLevels and @notFirstRow(@editor)
      @editor.moveCursorUp 1
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectToEndOfLine()
      r = @editor.getSelectedBufferRange()
      startRange = @scanForOpen(@editor, r)
      i += 1
    startRange

  findClosedCurly: (startRange) ->
    console.log startRange
    that = this
    endRange = null
    matchRanges = []
    # make sure there is no } between the { and cursor
    # move after end of current word
    # startingPoint = [startRange.end.row, startRange.end.column]
    startingPoint = [startRange.end.row, startRange.end.column]
    @editor.setCursorBufferPosition startingPoint
    @editor.selectToEndOfLine()
    console.log @editor.getSelection().getText()
    range = @editor.getSelectedBufferRange()
    lineMatches = @scanForClosed(that, @editor, range)
    if lineMatches.length > 0
      matchRanges = matchRanges.concat lineMatches
    endRange = matchRanges[@endCount - 1] if @foundMatchingEnd()
    i = 0
    while !@foundMatchingEnd() && endRange == null and i < @maxLevels and @notLastRow(@editor)
      # move down a line
      @editor.moveCursorDown 1
      @editor.moveCursorToEndOfLine()
      # @editor.selectToFirstCharacterOfLine()
      @editor.selectToBeginningOfLine()
      r = @editor.getSelectedBufferRange()
      lineMatches = @scanForClosed(that, @editor, r)
      if lineMatches.length > 0
        matchRanges = matchRanges.concat lineMatches
      endRange = matchRanges[@endCount - 1] if @foundMatchingEnd()
      i += 1
    # cancel if end found on a line before cursor
    if endRange != null and @initialCursor != null
      if endRange.start.row < @initialCursor.row
        endRange = null
    endRange

  replaceBlock: (startRange, endRange) ->
    @editor.buffer.scanInRange /\}/, endRange, (obj) ->
      match = obj.matchText.match(/([^\}])\}(.*)/, '')
      if match != null
        beforeClosed = match[1]
        afterClosed = match[2]
      obj.replace (beforeClosed ?= '') + 'end' + (afterClosed ?= '')
      obj.stop()
    @editor.buffer.scanInRange /\{/, startRange, (obj) ->
      afterOpen = obj.matchText.replace(/\{/, '') || ''
      obj.replace 'do' + afterOpen
      obj.stop()

  resetCursor: (collapsed, startRange) ->
    if collapsed
      @editor.setCursorBufferPosition startRange.end
      @editor.moveCursorDown 1
      @editor.moveCursorToEndOfLine()
    else if @initialCursor != null
      @editor.setCursorBufferPosition @initialCursor

  collapseBlock: (startRange, endRange) ->
    foundDoBar = false
    unCollapsed = false
    unCollapsedEnd = false
    @editor.setSelectedBufferRange endRange
    @editor.selectToEndOfWord()
    newEndRange = @editor.getSelectedBufferRange()
    # only do same line
    if startRange.start.row == endRange.start.row
      # add new line in front of new end
      @buffer.scanInRange /\send/, newEndRange, (obj) ->
        obj.replace "\nend"
        unCollapsedEnd = true
      if unCollapsedEnd
        # range needs to get bigger
        @editor.setCursorBufferPosition startRange.start
        @editor.selectToEndOfLine()
        newStartRange = @editor.getSelectedBufferRange()
        # and new line after bars
        @buffer.scanInRange /do\s\|\w+\|/, newStartRange, (obj) ->
          text = obj.matchText
          obj.replace "#{text}\n"
          foundDoBar = true
          unCollapsed = true
        unless foundDoBar
          # and new line after do$
          @buffer.scanInRange /do/, newStartRange, (obj) ->
            obj.replace "do\n"
            unCollapsed = true
    if unCollapsed
      # indent new block based on original line
      @editor.setCursorBufferPosition startRange.start
      @editor.moveCursorDown 1
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectDown 1
      @editor.selectToEndOfLine()
      @editor.getSelection().autoIndentSelectedRows()
    unCollapsed
