RubyBlockConverter = require './ruby-block-converter'

REGEX_DO = /\sdo\b/
# REGEX_DO_ONLY = /\sdo$/
# REGEX_DO_BAR  = /\sdo\s\|/
REGEX_END     = /end$/

module.exports =
class CurlyConverter extends RubyBlockConverter
  foundStart = false
  foundStartOnCurrent = false
  foundStartOnNext = false
  foundEnd   = false
  max_levels = 3

  constructor: ->
    super
    foundStart = false
    foundStartOnCurrent = false
    foundStartOnNext = false
    foundEnd   = false
    @findAndReplaceDo()
    # @findAndReplaceEnd() if foundStart
    @finalizeTransaction foundStart #&& foundEnd

  findAndReplaceDo: ->
    currentLineRange = null
    nextLineRange = null
    # look on current line
    @editor.moveCursorToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    currentLineRange = @editor.getSelectedBufferRange()
    @scanForDo @editor, currentLineRange
    foundStartOnCurrent = foundStart
    i = 0
    while !foundStart && i < max_levels && i += 1
      # move one line up
      @editor.moveCursorUp()
      @editor.moveCursorToEndOfLine()
      @editor.selectToFirstCharacterOfLine()
      nextLineRange = @editor.getSelectedBufferRange()
      @scanForDo @editor, nextLineRange
      foundStartOnNext = foundStart

  scanForDo: (editor, range) ->
    editor.buffer.backwardsScanInRange REGEX_DO, range, (obj) ->
      foundStart = true
      afterDo = obj.matchText.replace(/\sdo/, '')[0]
      obj.replace ' {' + afterDo ?= ''
      obj.stop()

  findAndReplaceEnd: ->
    # find end
    # console.log 'help'
    @editor.moveCursorDown 2
    @editor.moveCursorToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_END, range, (obj) ->
      # console.log 'found end'
      foundEnd = true
      obj.replace ''
      obj.stop()
    if foundEnd
      @editor.deleteLine()
      @editor.moveCursorUp 1
      @editor.moveCursorToFirstCharacterOfLine()
      @editor.selectToEndOfLine()
      selection = @editor.getSelection()
      selectedLine = selection.getText()
      @editor.deleteLine()
      @editor.moveCursorUp 1
      @editor.moveCursorToEndOfLine()
      selection = @editor.getSelection()
      selection.insertText ' ' + selectedLine + ' }'
