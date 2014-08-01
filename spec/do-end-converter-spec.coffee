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

  describe 'toDoEnd', ->
    it 'does not change an empty file', ->
      atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { puts 'hello' }\n")
        editor.moveCursorUp 2
        editor.moveCursorRight() for num in [0...11]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"

    describe 'when a variable', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { |bub| puts 'hello' }\n")
        editor.moveCursorUp 2
        editor.moveCursorRight() for num in [0...11]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe "1.times do |bub|\n  puts 'hello'\nend\n"

    describe 'when nested', ->
      it 'converts it to a multi line block with do-end', ->
        textStart = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        textEnd = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\n  end\nend\n"
        editor.insertText textStart
        editor.moveCursorUp 2
        editor.moveCursorToEndOfLine()
        editor.moveCursorLeft 1
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textEnd

    describe 'when more than one line', ->
      it 'converts to brackets only', ->
        startText = "1.times {\n  puts 'hello'\n  puts 'world'\n}\n"
        endText = "1.times do\n  puts 'hello'\n  puts 'world'\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when cursor at end of line', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { puts 'hello' }\n")
        editor.moveCursorUp 2
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"

    describe 'when cursor at one line below }', ->
      it "doesn't convert it", ->
        startText = "1.times { puts 'hello' }\n\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe startText

    describe 'when no new line', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { puts 'hello' }")
        editor.moveCursorUp 2
        editor.moveCursorRight() for num in [0...11]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend"

    describe 'when cursor right of {', ->
      it 'converts it to a multi line block with do-end', ->
        startText = "1.times { puts 'hello' }\n"
        endText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        editor.moveCursorRight() for num in [0...13]
        i = 0
        while i < 9
          editor.moveCursorRight()
          i += 1
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when cursor left of {', ->
      it "doesn't convert it", ->
        startText = "1.times { puts 'hello' }\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        editor.moveCursorRight()for num in [0...8]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe startText

    describe 'when empty lines before block', ->
      it 'properly indents', ->
        nls = "\n\n\n\n\n\n\n\n  "
        startText = "1.times do#{nls}1.times { puts 'hello' }\nend\n"
        endText   = "1.times do#{nls}1.times do\n    puts 'hello'\n  end\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        editor.moveCursorRight() for num in [0...13]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when run twice', ->
      it 'converts it to a multi line block with do-end', ->
        firstBlockStartText = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        firstBlockEndText = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\n  end\nend\n"
        editor.insertText firstBlockStartText
        editor.moveCursorUp 2
        editor.moveCursorToEndOfLine()
        editor.moveCursorLeft 1
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        # run again
        editor.moveCursorToBottom()
        editor.insertText "\n"
        startText = "1.times {\n  puts 'hello'\n  puts 'world'\n}\n"
        endText = "1.times do\n  puts 'hello'\n  puts 'world'\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe firstBlockEndText + "\n" + endText

    describe 'when nested in a do-end', ->
      it 'converts the brackets only', ->
        startText = "context \"for tim\" do\n  it \"redirects\" {\n    expect(response).to redirect\n  }\nend\n"
        endText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 3
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when nested in a curly bracket', ->
      it 'converts the brackets only', ->
        startText = "context \"for tim\" {\n  it \"redirects\" {\n    expect(response).to redirect\n  }\n}\n"
        endText   = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 3
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when trying to convert do-end', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe startText

      it "doesn't move the cursor", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 2
        editor.moveCursorRight() for n in [0...3]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getCursorBufferPosition().row).toBe 1
        expect(editor.getCursorBufferPosition().column).toBe 4

    describe 'when converting outer nested block from top', ->
      it 'converts it to a single line block with brackets', ->
        startText = "context \"for tim\" {\n  it { expect(response).to redirect }\n}\n"
        endText   = "context \"for tim\" do\n  it { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 5
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

      it "doesn't move the cursor", ->
        startText = "context \"for tim\" {\n  it { expect(response).to redirect }\n}\n"
        editor.insertText(startText)
        editor.moveCursorUp 5
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getCursorBufferPosition().row).toBe 0
        expect(editor.getCursorBufferPosition().column).toBe 19

    describe 'when converting outer nested block from bottom', ->
      it "converts it", ->
        startText = "context \"for tim\" {\n  it { expect(response).to redirect }\n}\n"
        endText = "context \"for tim\" do\n  it { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when converting outer nested block', ->
      it 'converts it to a multi line block', ->
        startText = "it { it { expect(response).to redirect } }\n"
        endText   = "it do\n  it { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        editor.moveCursorRight() for n in [0...5]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when converting outer nested block both with bars', ->
      it 'converts it to a single line block with brackets', ->
        startText = "it { |bob| it { |sux| expect(response).to redirect } }\n"
        endText   = "it do |bob|\n  it { |sux| expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveCursorUp 1
        # editor.moveCursorToEndOfLine()
        editor.moveCursorRight() for n in [0...5]
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe endText

    describe 'when nested with ({ }) inside', ->
      it 'converts it to a multi line block with do-end', ->
        textStart = "1.times { |bub|\n  2.times({ |cow| puts bub + cow })\n}\n"
        textEnd = "1.times do |bub|\n  2.times({ |cow| puts bub + cow })\nend\n"
        editor.insertText textStart
        editor.moveCursorUp 3
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textEnd

    describe 'when nested with { } inside', ->
      it "doesn't convert it", ->
        textStart = "it 'does' {\n  expect('soup').to eq { }\n}\n"
        textEnd = "it 'does' do\n  expect('soup').to eq { }\nend\n"
        editor.insertText textStart
        editor.moveCursorUp 2
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        # expect(editor.getText()).toBe textStart
        expect(editor.getText()).toBe textEnd

    describe 'when nested with {} inside', ->
      it 'converts the outside to do-end', ->
        textStart = "it 'does' {\n  expect('soup').to eq {}\n}\n"
        textEnd = "it 'does' do\n  expect('soup').to eq {}\nend\n"
        editor.insertText textStart
        editor.moveCursorUp 2
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textEnd

    describe 'when { :hash => variable }', ->
      it "doesn't convert it", ->
        textStart = "{ :hash => variable }\n"
        editor.insertText textStart
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textStart

    describe 'when { hash: :rocket }', ->
      it "doesn't convert it", ->
        textStart = "{ hash: :rocket }\n"
        editor.insertText textStart
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textStart

    describe 'when { hash: "string" }', ->
      it "doesn't convert it", ->
        textStart = "{ hash: \"string\" }\n"
        editor.insertText textStart
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textStart


    describe "when { :hash => 'string' }", ->
      it "doesn't convert it", ->
        textStart = "{ :hash => 'string' }\n"
        editor.insertText textStart
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textStart

    describe "when { \"hash\" => 'string' }", ->
      it "doesn't convert it", ->
        textStart = "{ \"hash\" => 'string' }\n"
        editor.insertText textStart
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textStart

    describe "when { 'hash' => 'string' }", ->
      it "doesn't convert it", ->
        textStart = "{ \"hash\" => 'string' }\n"
        editor.insertText textStart
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textStart

    describe "when { not a hash }", ->
      it 'converts the outside to do-end', ->
        textStart = "before {\n  { var = 'noop' }\n}\n"
        textEnd = "before {\n  do\n    var = 'noop'\n  end\n}\n"
        editor.insertText textStart
        editor.moveCursorUp 2
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textEnd

    describe "when { @attr }", ->
      it 'converts the outside to do-end', ->
        textStart = "before { @var = 'noop' }\n"
        editor.insertText textStart
        textEnd = "before do\n  @var = 'noop'\nend\n"
        editor.moveCursorUp 1
        editor.moveCursorToEndOfLine()
        atom.workspaceView.trigger 'ruby-block-converter:toDoEnd'
        expect(editor.getText()).toBe textEnd
