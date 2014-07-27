RubyBlockConverter = require './ruby-block-converter'

REGEX_DO_ONLY = /\sdo$/
REGEX_DO_BAR  = /\sdo\s\|/
REGEX_END     = /end$/

module.exports =
class CurlyConverter extends RubyBlockConverter
  foundStart = false
  foundEnd   = false

  constructor: ->
    super
    foundStart = false
    foundEnd   = false
    @replaceDo()
    @replaceEnd() if foundStart
    @finalizeTransaction foundStart && foundEnd

  replaceDo: ->
    # find do
    # console.log @editor.getText()
    @editor.moveCursorUp()
    @editor.moveCursorToEndOfLine()
    @editor.selectToFirstCharacterOfLine()
    # console.log 'Do text: ' + @editor.getSelection().getText()
    range = @editor.getSelectedBufferRange()
    @editor.buffer.scanInRange REGEX_DO_ONLY, range, (obj) ->
      # console.log 'found do only'
      foundStart = true
      obj.replace " {"
      obj.stop()

    unless foundStart
      @editor.buffer.scanInRange REGEX_DO_BAR, range, (obj) ->
        # console.log 'found do bar'
        foundStart = true
        obj.replace " { |"
        obj.stop()
    # console.log foundStart

  replaceEnd: ->
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
