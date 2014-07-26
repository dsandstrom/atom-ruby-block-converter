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
    console.log filePath
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
    
    it 'converts it to a single line block with brackets', ->
      editor.insertText("1.times do\n  puts 'hello'\nend\n")
      editor.moveCursorUp 2
      atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
      expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

  describe 'toDoEnd', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
      expect(editor.getText()).toBe ''
    
    it 'converts it to a multi line block with do-end', ->
      editor.insertText("1.times { puts 'hello' }\n")
      editor.moveCursorUp 2
      atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
      expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"
