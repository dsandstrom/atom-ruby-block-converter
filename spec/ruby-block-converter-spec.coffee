fs = require 'fs-plus'
path = require 'path'
temp = require 'temp'
{WorkspaceView} = require 'atom'

describe 'RubyBlockConverter', ->
  [editor, buffer] = []

  beforeEach ->
    directory = temp.mkdirSync()
    atom.project.setPath(directory)
    atom.workspaceView = new WorkspaceView()
    atom.workspace = atom.workspaceView.model
    filePath = path.join(directory, 'ruby-block-converter.rb')
    # fs.writeFileSync(filePath, '')
    # fs.writeFileSync(path.join(directory, 'sample.rb'), 'Some text.\n')
    # atom.config.set('editor.softTabs', true)
    # atom.config.set('editor.tabLength', 2)

    waitsForPromise ->
      atom.workspace.open(filePath).then (e) ->
        editor = e
        buffer = editor.getBuffer()
        # editor.setTabLength(2)

    waitsForPromise ->
      atom.packages.activatePackage('ruby-block-converter')

  describe 'toCurlyBrackets', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
      expect(editor.getText()).toBe ''
    
    it 'does not change spaces at the end of a line', ->
      editor.insertText("1.times do\n  puts 'hello'\nend\n")
      # editor.save
      editor.moveCursorUp 2
      atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
      expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

  describe 'toDoEnd', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
      expect(editor.getText()).toBe ''
    
    it 'does not change spaces at the end of a line', ->
      editor.insertText("1.times { puts 'hello' }\n")
      # editor.save
      editor.moveCursorUp 2
      atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
      expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"
