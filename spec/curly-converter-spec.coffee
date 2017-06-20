describe 'RubyBlockConverter', ->
  [editor, editorView] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    atom.config.set('editor.tabLength', 2)
    atom.config.set('ruby-block-converter.maxLines', 6)

    waitsForPromise ->
      atom.workspace.open('test.rb').then (e) ->
        editor = e
        editorView = atom.views.getView(editor)

    waitsForPromise ->
      atom.packages.activatePackage('language-ruby')

    waitsForPromise ->
      atom.packages.activatePackage('ruby-block-converter')

  describe 'toCurlyBrackets', ->
    it 'does not change an empty file', ->
      atom.commands.dispatch(editorView,
                             'ruby-block-converter:to-curly-brackets')
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when tabs', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n\tputs 'hello'\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when two tabs', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n\t\tputs 'hello'\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when extra spaces', ->
      it 'converts it and removes the extra', ->
        editor.insertText("1.times  do\n  puts 'hello'\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when a variable', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do |bub|\n  puts bub\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { |bub| puts bub }\n"

    describe 'when two variables', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do |bub, tom|\n  puts bub\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { |bub, tom| puts bub }\n"

    describe 'when two variables without a space', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do |bub,tom|\n  puts bub\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { |bub,tom| puts bub }\n"

    describe 'when extra spaces and variable', ->
      it 'converts it and removes the extra', ->
        editor.insertText("1.times do  |bub| \n   puts bub\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { |bub| puts bub }\n"

    describe 'when nested', ->
      it 'converts it to a nested single line block with brackets', ->
        textStart = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\nend\nend\n"
        textEnd = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        editor.insertText(textStart)
        editor.moveUp 3
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe textEnd

    describe 'when more than one line', ->
      it 'converts to brackets only', ->
        startText = "1.times do\n  puts 'hello'\n  puts 'world'\nend\n"
        endText = "1.times {\n  puts 'hello'\n  puts 'world'\n}\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when cursor is on end of end', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when cursor is on line below end', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n\n"
        editor.insertText(startText)
        editor.moveUp 1
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe startText

    describe 'when no new line', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend")
        editor.moveUp 1
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { puts 'hello' }"

    describe 'when cursor right of do', ->
      it 'converts it to a single line block with brackets', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveUp 3
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe "1.times { puts 'hello' }\n"

    describe 'when cursor in the middle of do', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveUp 3
        editor.moveToEndOfLine()
        editor.moveLeft 1
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe startText

    describe 'when cursor is before do', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveUp 3
        editor.moveToEndOfLine()
        editor.moveLeft 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe startText

    describe 'when empty lines before block', ->
      it 'properly indents', ->
        nls = "\n\n\n\n\n\n\n\n  "
        startText = "1.times do#{nls}1.times do\n    puts 'hello'\n  end\nend\n"
        endText   = "1.times do#{nls}1.times { puts 'hello' }\nend\n"
        editor.insertText(startText)
        editor.moveUp 3
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when cursor is after end', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n\n17.times { |banana| puts banana }\n"
        editor.insertText(startText)
        editor.moveUp 2
        # editor.moveToEndOfLine()
        # editor.moveLeft 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe startText

    describe 'when nested in a curly do-end', ->
      it 'converts it to a single line block with brackets', ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        endText = "context \"for tim\" do\n  it \"redirects\" { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveUp 3
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when nested in a curly curly bracket', ->
      it 'converts it to a single line block with brackets', ->
        startText   = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        endText = "context \"for tim\" {\n  it \"redirects\" { expect(response).to redirect }\n}\n"
        editor.insertText(startText)
        editor.moveUp 3
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when trying to convert brackets', ->
      it "doesn't convert it", ->
        startText = "1.times {\n  puts 'hello'\n}\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe startText

      it "doesn't move the cursor", ->
        startText = "1.times {\n  puts 'hello'\n}\n"
        editor.insertText(startText)
        editor.moveUp 2
        editor.moveRight() for n in [0...3]
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getCursorBufferPosition().row).toBe 1
        expect(editor.getCursorBufferPosition().column).toBe 4

    describe 'when converting outer nested block from top', ->
      it 'converts it to a single line block with brackets', ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        endText = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveUp 5
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

      it "doesn't move the cursor", ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        endText = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveUp 5
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getCursorBufferPosition().row).toBe 0
        expect(editor.getCursorBufferPosition().column).toBe 19

    describe 'when converting outer nested block from bottom', ->
      it "doesn't convert it", ->
        startText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        # endText = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveUp 1
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe startText

    describe 'when converting inner nested do from inside', ->
      it "converts it", ->
        startText   = "before do\n  do\n    var = 'cow'\n  end\nend\n"
        endText   = "before do\n { var = 'cow' }\nend\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when converting when do on line alone', ->
      it "converts it", ->
        startText   = "do\n  var = 'cow'\nend\n"
        endText   = "{ var = 'cow' }\n"
        editor.insertText(startText)
        editor.moveUp 1
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when converting outer nested block from top', ->
      it 'converts it to a single line block with brackets', ->
        startText = "context \"for tim\" do\n  it { expect(response).to redirect }\nend\n"
        endText   = "context \"for tim\" { it { expect(response).to redirect } }\n"
        editor.insertText(startText)
        editor.moveUp 3
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

      it "moves the cursor to the end", ->
        startText = "context \"for tim\" do\n  it { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveUp 3
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getCursorBufferPosition().row).toBe 0
        expect(editor.getCursorBufferPosition().column).toBe 57

    describe 'when converting outer nested block from bottom', ->
      it "converts it", ->
        startText = "context \"for tim\" do\n  it { expect(response).to redirect }\nend\n"
        endText = "context \"for tim\" { it { expect(response).to redirect } }\n"
        editor.insertText(startText)
        editor.moveUp 1
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when converting outer nested block both with bars', ->
      it 'converts it to a single line block with brackets', ->
        startText = "it do |bob|\n  it { |sux| expect(response).to redirect }\nend\n"
        endText   = "it { |bob| it { |sux| expect(response).to redirect } }\n"
        editor.insertText(startText)
        editor.moveUp 2
        # editor.moveToEndOfLine()
        editor.moveRight() for n in [0...5]
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe endText

    describe 'when run twice', ->
      it 'converts it to a multi line block with do-end', ->
        firstBlockStartText = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\n  end\nend\n"
        firstBlockEndText   = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        editor.insertText firstBlockStartText
        editor.moveUp 2
        editor.moveToEndOfLine()
        editor.moveLeft 1
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        # run again
        editor.moveToBottom()
        editor.insertText "\n"
        startText = "1.times do\n  puts 'hello'\n  puts 'world'\nend\n"
        endText = "1.times {\n  puts 'hello'\n  puts 'world'\n}\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe firstBlockEndText + "\n" + endText

    describe 'when trying to convert { }', ->
      it "doesn't convert it", ->
        startText = "1.times {\n  puts 'hello'\n}\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe startText

      it "doesn't move the cursor", ->
        startText = "1.times {\n  puts 'hello'\n}\n"
        editor.insertText(startText)
        editor.moveUp 2
        editor.moveRight() for n in [0...3]
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getCursorBufferPosition().row).toBe 1
        expect(editor.getCursorBufferPosition().column).toBe 4

    describe 'when folded text above', ->
      it 'converts it to a single line block with brackets', ->
        textToFold = "1.times do\n  puts 'fold me'\n end\n\n"
        textStart = "1.times do\n\tputs 'hello'\nend\n"
        textEnd = textToFold + "1.times { puts 'hello' }\n"
        editor.insertText textToFold
        editor.insertText textStart
        editor.foldBufferRow 0
        editor.moveUp 2
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        expect(editor.getText()).toBe textEnd

    describe 'when undoing text above', ->
      it 'should revert to original text', ->
        textStart = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(textStart)
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        editor.undo()
        expect(editor.getText()).toBe textStart

      it 'should not have selected text', ->
        textStart = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(textStart)
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-curly-brackets')
        editor.undo()
        expect(editor.getLastSelection().getText()).toBe ''
