RubyBlockConverter = require './ruby-block-converter'

module.exports =
class DoEndConverter extends RubyBlockConverter
  # TODO: make maxLevels a package option
  maxLevels = 3

  # constructor: ->
  #   super

  scanForOpen: (editor, range) ->
    startRange = null
    editor.buffer.backwardsScanInRange /\s\{(\s|$)/, range, (obj) ->
      startRange = obj.range
      obj.stop()
    startRange

  scanForClosed: (editor, range) ->
    endRange = null
    editor.buffer.scanInRange /(^|\s)\}(\W|$)/, range, (obj) ->
      endRange = obj.range
      obj.stop()
    endRange

  findOpenCurly: ->
    startRange = null
    # select to the left
    @editor.setCursorBufferPosition @initialCursor
    @editor.selectToFirstCharacterOfLine()
    r = @editor.getSelectedBufferRange()
    # scan for open
    startRange = @scanForOpen(@editor, r)
    # go up lines until one { is found
    i = 0
    while startRange == null and i < maxLevels and @notFirstRow(@editor)
      @editor.moveCursorUp 1
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectToEndOfLine()
      r = @editor.getSelectedBufferRange()
      startRange = @scanForOpen(@editor, r)
      i += 1
    # console.log "found start: #{startRange != null}"
    startRange

  findClosedCurly: (startRange) ->
    endRange = null
    # make sure there is no } between the { and cursor
    # move after end of current word
    startingPoint = [startRange.end.row, startRange.end.column]
    @editor.setCursorBufferPosition startingPoint
    @editor.selectToEndOfLine()
    range = @editor.getSelectedBufferRange()
    endRange = @scanForClosed(@editor, range)
    i = 0
    while endRange == null and i < maxLevels and @notLastRow(@editor)
      # move down a line
      @editor.moveCursorDown 1
      @editor.moveCursorToEndOfLine()
      # @editor.selectToFirstCharacterOfLine()
      @editor.selectToBeginningOfLine()
      r = @editor.getSelectedBufferRange()
      endRange = @scanForClosed(@editor, r)
      i += 1
    # cancel if end found on a line before cursor
    # needed?
    # console.log "found end: #{endRange != null}"
    if endRange != null and @initialCursor != null
      if endRange.start.row < @initialCursor.row
        endRange = null
    # console.log "found end: #{endRange != null}"
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

  resetCursor: (unCollapsed, startRange) ->
    if unCollapsed
      @editor.setCursorBufferPosition startRange.end
      @editor.moveCursorDown 1
      @editor.moveCursorToEndOfLine()
    else
      @editor.setCursorBufferPosition(@initialCursor)

  unCollapseBlock: (startRange, endRange) ->
    # TODO: maybe make it's own transaction
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
        @buffer.scanInRange /do\s\|.*\|/, newStartRange, (obj) ->
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
      selection = @editor.getSelection()
      selection.autoIndentSelectedRows()
    unCollapsed
