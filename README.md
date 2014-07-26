# Ruby Block Converter
### An Atom Package

Convert Ruby blocks from single line format to/from multi line format.
Or from curly brackets to/from do-end statements.

#### Instructions
> *{ } --> do-end*

Place cursor on line and hit the shortcut. Default: `ctrl-shift-]`

> *do-end --> { }*

Place cursor on second line (the one below `do`)
and hit the shortcut Default: `ctrl-shift-[`

#### Notes
In Beta, only supports blocks with text that is only one line.

#### Commands
```coffee
'ruby-block-converter:toCurlyBrackets'
'ruby-block-converter:toDoEnd'
```


<!-- ![A screenshot of your spankin' package](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif) -->

<!-- ### Notes -->

---

#### Todo/Bugs
* Allow to just change styles when text is more than 1 line
* Improve nested blocks
* Requires new line at end of file
