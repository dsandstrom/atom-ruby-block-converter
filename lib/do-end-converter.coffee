RubyBlockConverter = require './ruby-block-converter'

module.exports =
class DoEndConverter extends RubyBlockConverter

  openRegex : ->
    segments = []
    blockStart = "[^\\#]\\{\\s*"
    # rspec blocks
    segments.push("[\\:]\\w+\\)\\s+\\{")
    # no string hashes
    segments.push("#{blockStart}[\\\"\\']\\w[\\\"\\']\\s+\\=[^>]")
    # no strings that start/end with :
    segments.push(
      "#{blockStart}[^:\\\"\\'\|]\\w*([^:]|::\\w*)[\\s\\.\\\"\\'\\[\\(]"
    )
    # bar variables
    segments.push("#{blockStart}\\|")
    # new line
    segments.push("#{blockStart}\\n")
    # end of line
    segments.push("#{blockStart}$")
    openRegex = new RegExp(segments.join("|"))

  scanForOpen: (editor, range, cursorPoint=null) ->
    startRange = null
    # scan for first {
    editor.buffer.scanInRange @openRegex(), range, (obj) ->
      if cursorPoint != null
        # don't allow unless block starts before cursor
        sameRow = obj.range.start.row == cursorPoint.row
        # fudge factor for extra space after { in regex
        leftOfCursor = obj.range.start.column + 1 < cursorPoint.column
        if sameRow and leftOfCursor
          startRange = obj.range
          obj.stop()
      else
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
      that.startCount++
    matchRanges

  findOpenCurly: ->
    startRange = null
    # select to the left
    @editor.setCursorBufferPosition @initialCursor
    @editor.moveToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    range = @editor.getSelectedBufferRange()
    # scan for open
    startRange = @scanForOpen(@editor, range, @initialCursor)
    # go up lines until { is found
    i = 0
    while startRange == null and i < @maxLines and @notFirstRow(@editor)
      @editor.moveUp 1
      @editor.moveToFirstCharacterOfLine()
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
    while !@foundMatchingEnd() && endRange == null and i < @maxLines and @notLastRow(@editor)
      # move down a line
      @editor.moveDown 1
      @editor.moveToEndOfLine()
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

  resetCursor: (collapsed, startRange=null) ->
    if collapsed and startRange
      @editor.setCursorBufferPosition startRange.end
      @editor.moveDown 1
      @editor.moveToEndOfLine()
    else if @initialCursor != null
      @editor.setCursorBufferPosition @initialCursor

  collapseBlock: (startRange, endRange) ->
    foundDoBar = false
    joined = false
    joinedEnd = false
    @editor.setSelectedBufferRange endRange
    @editor.selectToEndOfWord()
    newEndRange = @editor.getSelectedBufferRange()
    # only do same line
    if startRange.start.row == endRange.start.row
      # add new line in front of new end
      @buffer.scanInRange /\s?end/, newEndRange, (obj) ->
        obj.replace "\nend"
        joinedEnd = true
      if joinedEnd
        # range needs to get bigger
        @editor.setCursorBufferPosition startRange.start
        @editor.selectToEndOfLine()
        newStartRange = @editor.getSelectedBufferRange()
        # and new line after bars
        @buffer.scanInRange /do\s*\|[\w\,\s]+\|/, newStartRange, (obj) ->
          text = obj.matchText
          text = text.replace(/do\|/, 'do |')
          obj.replace "#{text}\n"
          foundDoBar = true
          joined = true
        unless foundDoBar
          # and new line after do$
          @buffer.scanInRange /do/, newStartRange, (obj) ->
            obj.replace "do\n"
            joined = true
    if joined
      # indent new block based on original line
      @editor.setCursorBufferPosition startRange.start
      @editor.moveDown 1
      @editor.moveToFirstCharacterOfLine()
      @editor.selectDown 1
      @editor.selectToEndOfLine()
      @editor.getLastSelection().autoIndentSelectedRows()
    joined
