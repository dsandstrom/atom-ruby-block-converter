{View} = require 'atom'

module.exports =
class RubyBlockConverterView extends View
  @content: ->
    @div class: 'ruby-block-converter overlay from-top'
    # @div class: 'ruby-block-converter overlay from-top', =>
    #   @div "The RubyBlockConverter package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "ruby-block-converter:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "RubyBlockConverterView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
