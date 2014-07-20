{WorkspaceView} = require 'atom'
RubyBlockConverter = require '../lib/ruby-block-converter'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RubyBlockConverter", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('ruby-block-converter')

  describe "when the ruby-block-converter:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.ruby-block-converter')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'ruby-block-converter:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.ruby-block-converter')).toExist()
        atom.workspaceView.trigger 'ruby-block-converter:toggle'
        expect(atom.workspaceView.find('.ruby-block-converter')).not.toExist()
