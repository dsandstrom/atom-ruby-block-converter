# Ruby Block Converter
###### An Atom Package - [Atom.io](https://atom.io/packages/ruby-block-converter) : [Github](https://github.com/dsandstrom/atom-ruby-block-converter) : [![Build Status](https://travis-ci.org/dsandstrom/atom-ruby-block-converter.svg?branch=master)](https://travis-ci.org/dsandstrom/atom-ruby-block-converter)

Convert Ruby blocks between single line and multi line formats.
Or between curly brackets and do-end statements.

![Screenshot](https://github.com/dsandstrom/atom-ruby-block-converter/raw/master/screen-1.gif) ![Screenshot](https://github.com/dsandstrom/atom-ruby-block-converter/raw/master/screen-2.gif)

#### Instructions
> *{ } --> do-end*

Place the cursor in between the brackets
and hit the shortcut. Default: `ctrl-{`

> *do-end --> { }*

Place the cursor in between the do-end
and hit the shortcut Default: `ctrl-}`

#### Notes
In Beta, doesn't handle outer nested blocks well.

#### Commands
```coffee
'ruby-block-converter:toCurlyBrackets'
'ruby-block-converter:toDoEnd'
```
