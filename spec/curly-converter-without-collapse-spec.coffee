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

  describe 'toCurlyBracketsWithoutCollapse', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:to-curly-brackets-without-collapse'
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts brackets only', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:to-curly-brackets-without-collapse'
        expect(editor.getText()).toBe "1.times {\n  puts 'hello'\n}\n"

    describe 'when a variable', ->
      it 'converts brackets only', ->
        editor.insertText("1.times do |bub|\n  puts bub\nend\n")
        editor.moveUp 2
        atom.workspaceView.trigger 'ruby-block-converter:to-curly-brackets-without-collapse'
        expect(editor.getText()).toBe "1.times { |bub|\n  puts bub\n}\n"
