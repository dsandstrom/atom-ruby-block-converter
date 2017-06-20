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

  describe 'toDoEnd', ->
    it 'does not change an empty file', ->
      atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { puts 'hello' }\n")
        editor.moveUp 1
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"

    describe 'when no variable and no spaces', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times {puts 'hello'}\n")
        editor.moveUp 1
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"

    describe 'when a variable', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { |bub| puts 'hello' }\n")
        editor.moveUp 2
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do |bub|\n  puts 'hello'\nend\n"

    describe 'when a variable without first space', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times {|bub| puts 'hello' }\n")
        editor.moveUp 2
        editor.moveRight(11)
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do |bub|\n  puts 'hello'\nend\n"

    describe 'when a variable without second space', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { |bub| puts 'hello'}\n")
        editor.moveUp 2
        editor.moveRight(11)
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do |bub|\n  puts 'hello'\nend\n"

    describe 'when a variable without spaces', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times {|bub| puts 'hello'}\n")
        editor.moveUp 2
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do |bub|\n  puts 'hello'\nend\n"

    describe 'when two variables', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { |bub, tom| puts 'hello' }\n")
        editor.moveUp 2
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do |bub, tom|\n  puts 'hello'\nend\n"

    describe 'when two variables without a space', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { |bub,tom| puts 'hello' }\n")
        editor.moveUp 2
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do |bub,tom|\n  puts 'hello'\nend\n"

    describe 'when nested', ->
      it 'converts it to a multi line block with do-end', ->
        textStart = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        textEnd = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\n  end\nend\n"
        editor.insertText textStart
        editor.moveUp 2
        editor.moveToEndOfLine()
        editor.moveLeft 1
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when more than one line', ->
      it 'converts to brackets only', ->
        startText = "1.times {\n  puts 'hello'\n  puts 'world'\n}\n"
        endText = "1.times do\n  puts 'hello'\n  puts 'world'\nend\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

    describe 'when cursor at end of line', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { puts 'hello' }\n")
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend\n"

    describe 'when cursor at one line below }', ->
      it "doesn't convert it", ->
        startText = "1.times { puts 'hello' }\n\n"
        editor.insertText(startText)
        editor.moveUp 1
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe startText

    describe 'when no new line', ->
      it 'converts it to a multi line block with do-end', ->
        editor.insertText("1.times { puts 'hello' }")
        # editor.moveUp 2
        editor.moveToFirstCharacterOfLine()
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe "1.times do\n  puts 'hello'\nend"

    describe 'when cursor right of {', ->
      it 'converts it to a multi line block with do-end', ->
        startText = "1.times { puts 'hello' }\n"
        endText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveUp 1
        editor.moveRight() for num in [0...9]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

    describe 'when cursor left of {', ->
      it "doesn't convert it", ->
        startText = "1.times { puts 'hello' }\n"
        editor.insertText(startText)
        editor.moveUp 1
        editor.moveRight() for num in [0...8]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe startText

    describe 'when empty lines before block', ->
      it 'properly indents', ->
        nls = "\n\n\n\n\n\n\n\n  "
        startText = "1.times do#{nls}1.times { puts 'hello' }\nend\n"
        endText   = "1.times do#{nls}1.times do\n    puts 'hello'\n  end\nend\n"
        editor.insertText(startText)
        editor.moveUp 2
        editor.moveRight() for num in [0...13]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

    describe 'when run twice', ->
      it 'converts it to a multi line block with do-end', ->
        firstBlockStartText = "1.times do |bub|\n  2.times { |cow| puts bub + cow }\nend\n"
        firstBlockEndText = "1.times do |bub|\n  2.times do |cow|\n    puts bub + cow\n  end\nend\n"
        editor.insertText firstBlockStartText
        editor.moveUp 2
        editor.moveToEndOfLine()
        editor.moveLeft 1
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        # run again
        editor.moveToBottom()
        editor.insertText "\n"
        startText = "1.times {\n  puts 'hello'\n  puts 'world'\n}\n"
        endText = "1.times do\n  puts 'hello'\n  puts 'world'\nend\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe firstBlockEndText + "\n" + endText

    describe 'when nested in a do-end', ->
      it 'converts the brackets only', ->
        startText = "context \"for tim\" do\n  it \"redirects\" {\n    expect(response).to redirect\n  }\nend\n"
        endText   = "context \"for tim\" do\n  it \"redirects\" do\n    expect(response).to redirect\n  end\nend\n"
        editor.insertText(startText)
        editor.moveUp 3
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

    describe 'when nested in a curly bracket', ->
      it 'converts the brackets only', ->
        startText = "context \"for tim\" {\n  it \"redirects\" {\n    expect(response).to redirect\n  }\n}\n"
        endText   = "context \"for tim\" {\n  it \"redirects\" do\n    expect(response).to redirect\n  end\n}\n"
        editor.insertText(startText)
        editor.moveUp 3
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

    describe 'when trying to convert do-end', ->
      it "doesn't convert it", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveUp 2
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe startText

      it "doesn't move the cursor", ->
        startText = "1.times do\n  puts 'hello'\nend\n"
        editor.insertText(startText)
        editor.moveUp 2
        editor.moveRight() for n in [0...3]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getCursorBufferPosition().row).toBe 1
        expect(editor.getCursorBufferPosition().column).toBe 4

    describe 'when converting outer nested block from top', ->
      it 'converts it to a single line block with brackets', ->
        startText = "context \"for tim\" {\n  it { expect(response).to redirect }\n}\n"
        endText   = "context \"for tim\" do\n  it { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveUp 5
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

      it "doesn't move the cursor", ->
        startText = "context \"for tim\" {\n  it { expect(response).to redirect }\n}\n"
        editor.insertText(startText)
        editor.moveUp 5
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getCursorBufferPosition().row).toBe 0
        expect(editor.getCursorBufferPosition().column).toBe 19

    describe 'when converting outer nested block', ->
      it 'converts it to a multi line block', ->
        startText = "it { it { expect(response).to redirect } }\n"
        endText   = "it do\n  it { expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveUp 1
        editor.moveRight() for n in [0...5]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

    describe 'when converting outer nested block both with bars', ->
      it 'converts it to a single line block with brackets', ->
        startText = "it { |bob| it { |sux| expect(response).to redirect } }\n"
        endText   = "it do |bob|\n  it { |sux| expect(response).to redirect }\nend\n"
        editor.insertText(startText)
        editor.moveUp 1
        # editor.moveToEndOfLine()
        editor.moveRight() for n in [0...5]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe endText

    describe 'when nested with ({ }) inside', ->
      it 'converts it to a multi line block with do-end', ->
        textStart = "1.times { |bub|\n  2.times({ |cow| puts bub + cow })\n}\n"
        textEnd = "1.times do |bub|\n  2.times({ |cow| puts bub + cow })\nend\n"
        editor.insertText textStart
        editor.moveUp 3
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when nested with { } inside', ->
      it "doesn't convert it", ->
        textStart = "it 'does' {\n  expect('soup').to eq { }\n}\n"
        textEnd = "it 'does' do\n  expect('soup').to eq { }\nend\n"
        editor.insertText textStart
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        # expect(editor.getText()).toBe textStart
        expect(editor.getText()).toBe textEnd

    describe 'when nested with {} inside', ->
      it 'converts the outside to do-end', ->
        textStart = "it 'does' {\n  expect('soup').to eq {}\n}\n"
        textEnd = "it 'does' do\n  expect('soup').to eq {}\nend\n"
        editor.insertText textStart
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when { :hash => variable }', ->
      it "doesn't convert it", ->
        textStart = "{ :hash => variable }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe 'when { hash: :rocket }', ->
      it "doesn't convert it", ->
        textStart = "{ hash: :rocket }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe 'when { hash: "string" }', ->
      it "doesn't convert it", ->
        textStart = "{ hash: \"string\" }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart


    describe "when { :hash => 'string' }", ->
      it "doesn't convert it", ->
        textStart = "{ :hash => 'string' }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe "when { \"hash\" => 'string' }", ->
      it "doesn't convert it", ->
        textStart = "{ \"hash\" => 'string' }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe "when { 'hash' => 'string' }", ->
      it "doesn't convert it", ->
        textStart = "{ 'hash' => 'string' }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe "when deep {\"hash\" => \"string\" }", ->
      it "doesn't convert it", ->
        textStart = "{\"deep\" => {\"hash\" => \"string\" }}\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe "when deep {\"hash\" => \"string\" }", ->
      it "doesn't convert it", ->
        textStart = "{\"deep\" => {\"hash\" => \"string\" } }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe "when deep {\"hash\" => \"string\" } and inside", ->
      it "doesn't convert it", ->
        textStart = "{\"deep\" => {\"hash\" => \"string\" } }\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        editor.moveLeft() for n in [0..4]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe "when deep { 'hash' => 'string' }", ->
      it "doesn't convert it", ->
        textStart = "{ 'deep' => {'hash' => 'string' }}\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textStart

    describe "when { not a hash }", ->
      it 'converts the outside to do-end', ->
        textStart = "while false { var = 'noop' }\n"
        textEnd = "while false do\n  var = 'noop'\nend\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when { @attr }", ->
      it 'converts the outside to do-end', ->
        textStart = "before { @var = 'noop' }\n"
        textEnd = "before do\n  @var = 'noop'\nend\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when variable inside {}", ->
      it 'converts the outside to do-end', ->
        textStart = "let(:jon) { noop }\n"
        textEnd = "let(:jon) do\n  noop\nend\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when FactoryGirl.create inside {}", ->
      it 'converts the outside to do-end', ->
        textStart = "let(:jon) { FactoryUnicorn.doit }\n"
        textEnd = "let(:jon) do\n  FactoryUnicorn.doit\nend\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when FactoryUnicorn.doit inside {}", ->
      it 'converts the outside to do-end', ->
        textStart = "let(:jon) { FactoryUnicorn.doit }\n"
        textEnd = "let(:jon) do\n  FactoryUnicorn.doit\nend\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when let(:var) { { hsh: 'horse' } }", ->
      it 'converts the outside to do-end', ->
        textStart = "let(:var) { { hsh: 'horse' } }\n"
        textEnd = "let(:var) do\n  { hsh: 'horse' }\nend\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when string interpolation', ->
      it 'converts the outside to do-end', ->
        textStart = 'within "#var_#{var.id}" { should behave }\n'
        textEnd = 'within "#var_#{var.id}" do\n  should behave\nend\n'
        editor.insertText textStart
        editor.moveUp 1
        # editor.moveRight() for n in [0...17]
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when folded text above', ->
      it 'converts it to a multi line block with do-end', ->
        textToFold = "1.times do\n  puts 'fold me'\n end\n\n"
        textStart = "1.times { puts 'hello' }\n"
        textEnd = textToFold + "1.times do\n  puts 'hello'\nend\n"
        editor.insertText textToFold
        editor.insertText textStart
        editor.foldBufferRow 0
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when `qr.invoke` inside {}", ->
      it 'converts it do-end', ->
        textStart = "expect { qr.invoke }.to change(Monkey, :count)\n"
        textEnd = "expect do\n  qr.invoke\nend.to change(Monkey, :count)\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when `q.invoke` inside {}", ->
      it 'converts it do-end', ->
        textStart = "expect { q.invoke }.to change(Monkey, :count)\n"
        textEnd = "expect do\n  q.invoke\nend.to change(Monkey, :count)\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when `q.invoke` inside {}", ->
      it 'converts it do-end', ->
        textStart = "expect { q.invoke }.to change(Monkey, :count)\n"
        textEnd = "expect do\n  q.invoke\nend.to change(Monkey, :count)\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe "when `Task['monkey:make'].invoke` inside {}", ->
      it 'converts it do-end', ->
        textStart = "expect { Task['monkey:make'].invoke }.to change(Monkey, :count)\n"
        textEnd = "expect do\n  Task['monkey:make'].invoke\nend.to change(Monkey, :count)\n"
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when `Rake::Task["monkey:make"].invoke` inside {}', ->
      it 'converts it do-end', ->
        textStart = 'expect { Rake::Task["monkey:make"].invoke }.to change(Monkey, :count)\n'
        textEnd = 'expect do\n  Rake::Task["monkey:make"].invoke\nend.to change(Monkey, :count)\n'
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when method inside {}', ->
      it 'converts it do-end', ->
        textStart = 'expect { prepare(count) }\n'
        textEnd = 'expect do\n  prepare(count)\nend\n'
        editor.insertText textStart
        editor.moveUp 1
        editor.moveToEndOfLine()
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        expect(editor.getText()).toBe textEnd

    describe 'when undoing text above', ->
      it 'should revert to original text', ->
        textStart = "1.times { puts 'hello' }\n"
        editor.insertText(textStart)
        editor.moveUp 1
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        editor.undo()
        expect(editor.getText()).toBe textStart

      it 'should not of have selected text', ->
        textStart = "1.times { puts 'hello' }\n"
        editor.insertText(textStart)
        editor.moveUp 1
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView, 'ruby-block-converter:to-do-end')
        editor.undo()
        expect(editor.getLastSelection().getText()).toBe ''
