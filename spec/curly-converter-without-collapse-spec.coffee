fs = require 'fs-plus'
path = require 'path'
temp = require 'temp'
{WorkspaceView} = require 'atom'

# TODO: add tests for folded text above

describe 'RubyBlockConverter', ->
  [editor, buffer] = []

  beforeEach ->
    directory = temp.mkdirSync()
    atom.project.setPath(directory)
    atom.workspaceView = new WorkspaceView()
    atom.workspace = atom.workspaceView.model
    filePath = path.join(directory, 'example.rb')
    atom.config.set('editor.tabLength', 2)

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
      atom.workspaceView.trigger 'ruby-block-converter:toCurlyBracketsWithoutCollapse'
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts brackets only', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveCursorUp 2
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBracketsWithoutCollapse'
        expect(editor.getText()).toBe "1.times {\n  puts 'hello'\n}\n"

    describe 'when a variable', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do |bub|\n  puts bub\nend\n")
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBracketsWithoutCollapse'
        expect(editor.getText()).toBe "1.times { |bub|\n  puts bub\n}\n"
