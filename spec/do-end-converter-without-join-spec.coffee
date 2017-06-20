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

  describe 'toDoEndWithoutJoin', ->
    it 'does not change an empty file', ->
      atom.commands.dispatch(editorView,
                             'ruby-block-converter:to-do-end-without-join')
      expect(editor.getText()).toBe ''

    describe 'when no variable', ->
      it 'converts to do-end only', ->
        editor.insertText("1.times { puts 'hello' }\n")
        editor.moveUp 1
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-do-end-without-join')
        expect(editor.getText()).toBe "1.times do puts 'hello' end\n"

    describe 'when a variable', ->
      it 'converts to do-end only', ->
        editor.insertText("1.times { |bub| puts 'hello' }\n")
        editor.moveUp 2
        editor.moveRight() for num in [0...11]
        atom.commands.dispatch(editorView,
                               'ruby-block-converter:to-do-end-without-join')
        expect(editor.getText()).toBe "1.times do |bub| puts 'hello' end\n"
