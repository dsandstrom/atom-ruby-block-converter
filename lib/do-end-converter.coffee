RubyBlockConverter = require './ruby-block-converter'

module.exports =
class DoEndConverter extends RubyBlockConverter
  # openRegex: /(^|\(|\w|\'|\"|\`)\s*\{\s*(\||\w|\'|\"|\`|$)/
  # openRegex: /\{\s*(\||\'\w\'\s*[^=]\}|\"\w\"\s*[^=]\}|\`|\w+\b\s|$)/
  # openRegex: /\{\s*([^:\'\"]\w+\b[^:]|[\'\"]\w+[\'\"]\s[^=]|$)?/
  # openRegex: /\{\s*([^:\'\"]\w+\b[^:]|[\'\"]\w+[\'\"]|[^\'\":]\w+\s[^:]|\||$)/
  openRegex: /\{\s*(\||\'\w+\"\s[^=]|\"\w+\"\s[^=]|\`|\w+\s|@|\w+$|$)/

  scanForOpen: (editor, range) ->
    # scan backwards for first {
    startRange = null
    editor.buffer.backwardsScanInRange @openRegex, range, (obj) ->
      startRange = obj.range
      obj.stop()
    startRange

  scanForClosed: (that, editor, range) ->
    # scan for }, scan for matching {
    matchRanges = []
    editor.buffer.scanInRange /\}/g, range, (obj) ->
      that.endCount++
      matchRanges.push obj.range
    editor.buffer.scanInRange /\{/g, range, (obj) ->
      that.startCount += 1
    matchRanges

  findOpenCurly: ->
    startRange = null
    # select to the left
    @editor.setCursorBufferPosition @initialCursor
    @editor.selectToFirstCharacterOfLine()
    range = @editor.getSelectedBufferRange()
    # scan for open
    startRange = @scanForOpen(@editor, range)
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
    that = this
    endRange = null
    matchRanges = []
    # make sure there is no } between the { and cursor
    # move after end of current word
    startingPoint = [startRange.end.row, startRange.end.column]
    @editor.setCursorBufferPosition startingPoint
    @editor.selectToEndOfLine()
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
