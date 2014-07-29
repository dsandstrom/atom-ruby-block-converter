fs = require 'fs-plus'
path = require 'path'
temp = require 'temp'
{WorkspaceView} = require 'atom'

# FIXME: doesn't work when no newline at the end

describe 'RubyBlockConverter', ->
  [editor, buffer] = []

  beforeEach ->
    directory = temp.mkdirSync()
    atom.project.setPath(directory)
    atom.workspaceView = new WorkspaceView()
    atom.workspace = atom.workspaceView.model
    filePath = path.join(directory, 'example.rb')
    # console.log filePath
    # fs.writeFileSync(filePath, '')
    # fs.writeFileSync(path.join(directory, 'sample.rb'), 'Some text.\n')
    # atom.config.set('editor.softTabs', true)
    atom.config.set('editor.tabLength', 2)

    waitsForPromise ->
      atom.workspace.open(filePath).then (e) ->
        editor = e
        buffer = editor.getBuffer()
        editor.setTabLength(2)
        # editor.setSoftTabs true

    waitsForPromise ->
      atom.packages.activatePackage('language-ruby')

    waitsForPromise ->
      atom.packages.activatePackage('ruby-block-converter')

  describe 'toCurlyBrackets', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when tabs', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n\t\tputs 'hello'\nend\n")
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when a variable', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do |bub|\n  puts bub\nend\n")
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe "1.times { |bub| puts bub }\n"

    describe 'when nested', ->
      it 'converts it to a nested single line block with brackets', ->
        textStart = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\nend\nend\n"
        textEnd = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        editor.insertText(textStart)
        editor.moveCursorUp 3
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe textEnd

  describe 'toDoEnd', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { puts 'hello' }\n")
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"

    describe 'when a variable', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { |bub| puts 'hello' }\n")
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe "1.times do |bub|\n  puts 'hello'\nend\n"

    describe 'when nested', ->
      it 'converts it to a multi line block with do-end', ->
        textStart = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        textEnd = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\n  end\nend\n"
        editor.insertText textStart
        editor.moveCursorUp 2
        editor.moveCursorRight 12
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textEnd
