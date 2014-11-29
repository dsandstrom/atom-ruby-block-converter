fs = require 'fs-plus'
path = require 'path'
temp = require 'temp'
{Workspace} = require 'atom'

describe 'RubyBlockConverter', ->
  [editor, buffer] = []

  beforeEach ->
    directory = temp.mkdirSync()
    atom.project.setPaths(directory)
    atom.workspace = new Workspace
    atom.workspaceView = atom.views.getView(atom.workspace).__spacePenView
    filePath = path.join(directory, 'example.rb')
    atom.config.set('editor.tabLength', 2)
    atom.config.set('ruby-block-converter.maxLines', 6)

    waitsForPromise ->
      atom.workspace.open(filePath).then (e) ->
        editor = e
        buffer = editor.getBuffer()
        editor.setTabLength(2)

    waitsForPromise ->
      atom.packages.activatePackage('language-ruby')

    waitsForPromise ->
      atom.packages.activatePackage('ruby-block-converter')

  describe 'toDoEndWithoutJoin', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:to-do-end-without-join'
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts to do-end only', ->
        editor.insertText("1.times { puts 'hello' }\n")
        editor.moveUp 1
        editor.moveRight() for num in [0...11]
        atom.workspaceView.trigger 'ruby-block-converter:to-do-end-without-join'
        expect(editor.getText()).toBe "1.times do puts 'hello' end\n"

    describe 'when a variable', ->
      it 'converts to do-end only', ->
        editor.insertText("1.times { |bub| puts 'hello' }\n")
        editor.moveUp 2
        editor.moveRight() for num in [0...11]
        atom.workspaceView.trigger 'ruby-block-converter:to-do-end-without-join'
        expect(editor.getText()).toBe "1.times do |bub| puts 'hello' end\n"
