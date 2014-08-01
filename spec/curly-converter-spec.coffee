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
    filePath = path.join(directory, 'example.rb')
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

    describe 'when more than one line', ->
      it 'converts to brackets only', ->
        startText = "1.times do\n  puts 'hello'\n  puts 'world'\nend\n"
        endText = "1.times {\n  puts 'hello'\n  puts 'world'\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe endText

    describe 'when cursor is on end of end', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when cursor is on line below end', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe startText

    describe 'when no new line', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend")
        editor.moveCursorUp 1
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe "1.times { puts 'hello' }"

    describe 'when cursor right of do', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveCursorUp 3
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when cursor in the middle of do', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 3
        editor.moveCursorToEndOfLine()
        editor.moveCursorLeft 1
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe startText

    describe 'when cursor is before do', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 3
        editor.moveCursorToEndOfLine()
        editor.moveCursorLeft 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe startText

    describe 'when empty lines before block', ->
      it 'properly indents', ->
        nls = "\n\n\n\n\n\n\n\n  "
        startText = "1.times do#{nls}1.times do\n    puts 'hello'\n  end\nend\n"
        endText   = "1.times do#{nls}1.times { puts 'hello' }\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 3
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe endText

    describe 'when cursor is after end', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n\n17.times { |banana| puts banana }\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        # editor.moveCursorToEndOfLine()
        # editor.moveCursorLeft 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe startText

    describe 'when nested in a curly do-end', ->
      it 'converts it to a single line block with brackets', ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        endText = "context \"for tim\" do\n  it \"redirects\" { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 3
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe endText

    describe 'when nested in a curly curly bracket', ->
      it 'converts it to a single line block with brackets', ->
        startText   = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        endText = "context \"for tim\" {\n  it \"redirects\" { expect(response).to redirect }\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 3
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe endText

    describe 'when trying to convert brackets', ->
      it "doesn't convert it", ->
        startText = "1.times {\n  puts 'hello'\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe startText

      it "doesn't move the cursor", ->
        startText = "1.times {\n  puts 'hello'\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        editor.moveCursorRight() for n in [0...3]
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getCursorBufferPosition().row).toBe 1
        expect(editor.getCursorBufferPosition().column).toBe 4

    describe 'when converting outer nested block from top', ->
      it 'converts it to a single line block with brackets', ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        endText = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 5
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe endText

      it "doesn't move the cursor", ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        endText = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 5
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getCursorBufferPosition().row).toBe 0
        expect(editor.getCursorBufferPosition().column).toBe 19

    describe 'when converting outer nested block from bottom', ->
      it "doesn't convert it", ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        # endText = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe startText

    describe 'when converting inner nested do from inside', ->
      it "converts it", ->
        startText   = "before do\n  do\n    var = 'cow'\n  end\nend\n"
        endText   = "before do\n  { var = 'cow' }\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe endText

    describe 'when converting when do on line alone', ->
      it "converts it", ->
        startText   = "do\n  var = 'cow'\nend\n"
        endText   = "{ var = 'cow' }\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        atom.workspaceView.trigger 'ruby-block-converter:toCurlyBrackets'
        expect(editor.getText()).toBe endText
