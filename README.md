# Ruby Block Converter
###### An Atom Package - [Atom.io](https://atom.io/packages/ruby-block-converter) : [Github](https://github.com/dsandstrom/atom-ruby-block-converter) : [![Build Status](https://travis-ci.org/dsandstrom/atom-ruby-block-converter.svg?branch=master)](https://travis-ci.org/dsandstrom/atom-ruby-block-converter)

Convert Ruby blocks between single line and multi line formats. Or between curly brackets and do-end statements.

![Screenshot](https://github.com/dsandstrom/atom-ruby-block-converter/raw/master/screen-1.gif) ![Screenshot](https://github.com/dsandstrom/atom-ruby-block-converter/raw/master/screen-2.gif)

### Instructions
###### *{ } => do-end*

Place the cursor in between the brackets and hit the shortcut.
Default: `ctrl-{`, without collapse: `alt-{`

###### *do-end => { }*

Place the cursor in between the do-end and hit the shortcut.
Default: `ctrl-}`, without join: `alt-}`

### Features
* Hashes and string interpolation are ignored
* RSpec blocks are honored.
* There are separate commands if you don't want the block to collapse or join

### How It Works
* It looks for the first starting block on the current line, then up. Upon success, it looks right, then down for a matching } or end.
* When there is a block with only one line of code: the curly converter will join the block onto one line; the do-end converter will separate the three lines and then auto-tab.
* Right now, it will only try up or down 6 lines, but this will probably become an optional value.

### Commands
```coffee
'ruby-block-converter:toCurlyBrackets'
'ruby-block-converter:toCurlyBracketsWithoutCollapse'
'ruby-block-converter:toDoEnd'
'ruby-block-converter:toDoEndWithoutJoin'
```

### Thanks
Inspired by the Sublime Text [Ruby Block Converter](https://github.com/irohiroki/RubyBlockConverter) by [irohiroki](https://github.com/irohiroki).
