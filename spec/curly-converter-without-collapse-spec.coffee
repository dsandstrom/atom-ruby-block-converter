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

  describe 'toCurlyBracketsWithoutCollapse', ->
    it 'does not change an empty file', ->
      atom.commands.dispatch(
        editorView,
        'ruby-block-converter:to-curly-brackets-without-collapse'
      )
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts brackets only', ->
        editor.insertText("1.times do\n  puts 'hello'\nend\n")
        editor.moveUp 2
        editor.moveToEndOfLine()
        atom.commands.dispatch(
          editorView,
          'ruby-block-converter:to-curly-brackets-without-collapse'
        )
        expect(editor.getText()).toBe "1.times {\n  puts 'hello'\n}\n"

    describe 'when a variable', ->
      it 'converts brackets only', ->
        editor.insertText("1.times do |bub|\n  puts bub\nend\n")
        editor.moveUp 2
        atom.commands.dispatch(
          editorView,
          'ruby-block-converter:to-curly-brackets-without-collapse'
        )
        expect(editor.getText()).toBe "1.times { |bub|\n  puts bub\n}\n"
