# VIM-DAN

```
__     _____ __  __       ____    _    _   _  
\ \   / /_ _|  \/  |     |  _ \  / \  | \ | | 
 \ \ / / | || |\/| |_____| | | |/ _ \ |  \| | 
  \ V /  | || |  | |_____| |_| / ___ \| |\  | 
   \_/  |___|_|  |_|     |____/_/   \_\_| \_| 
                                              
```

## Introduction

**DAN** stands for **Documents and Notes** and is a way to download different frameworks documentation, into a plain-text file, linked by `ctags` technology, which allow `vim` users to jump through **topics** (such as methods, properties, classes, topic-tutorials) , by using `Ctrl + ]` `Ctrl + O` functionality.

At the same time it allows the user to *highlight* different parts of the document, so it can be easily recalled which lines are important, such as method signatures.

The framework documentation can be periodically updated according to their public repositories, yet those highlighted lines will remain into users local documentation.

The project aims for the simplicity of `vim`'s functionality, aiming to extend the use **plain-text** , **syntax highlight** and **tags** navigation in a similar fashion to [vim-help-files](https://vimhelp.org/) , analogous to the usage of `filetype = help'.


## Actual usage

Note the following usage points:

    - When highlighting a line with "(X)" on a tag, you have to reload the tags for the file (Pressing F5 or running ctags again)



## Dependencies

```
vim
ctags
# For indexing yourself
wget
# For parsing yourself
pandoc
pup
gnu-utils
```

## Frameworks available

By framework it can mean any system that has a concise documentation available online, mostly in `.html` , it can refer from Programming Languages, to actual frameworks, to any other topic with concise documentation.

I have started off with the documentations I most used such as

```
https://developer.mozilla.org/en-US/docs/Web/JavaScript
https://developer.mozilla.org/en-US/docs/Web/API
https://ai-scripting.docsforadobe.dev/
```

But everyone is free to participate in the project, if you like the way it works and you think is helpfull for you and you are missing some documentation that can be useful for you,if you have a little knowledge of the **GNU-Linux** utilities used in the project, do help us extend this tool for further frameworks.

Below you can find a guide on how to start your own **DAN Documentation** for a new framework.
Also any suggestions on how to improve the already existing source are more than welcomed.

## vimrc Additions

To achieve the full potential of this plugin add the following on your .vimrc
```
# VIM-DAN FUNCTIONALITIES on .vimrc
# ----------------------------------
g:xConceal = 0
# ----------------------------------
# eof eof eof eof eof VIM-DAN FUNCTIONALITIES on .vimrc
```

Meaning pressing `Ctrl` + `i` will create a highlight mark '(X)' at the end of the line
While pressing `<F5>` will create a `location-list` that will displays those *highlighted* lines, also refreshing tags. Pressing additinonaly will refresh such a location list
Pressing '<F4>' will conceal (hide) those marks. In the location list Marks are hidden by default.

## Processes of creating a DAN Documentation

- Indexing
- Parsing
- Linking
- Styling

First off copy the template for indexing and parsing and create your doc name
For future compatiblity don't use a ${doc_name} that is already been used on this repository
Also there are some limitations for such as ${doc_name}
    - No dashes on it (Ctags incompatibility)
    - 

```
cp ./framworks/template-to-follow.sh ${doc_name}.sh
```


### Indexing: Specifying the Indexing Commands

### Parsing
Getting out of those pages a whole meaningfull document, headed by an Index document and followed by single document entries with entries amended so they can be tagged 
First line of each single document will be appended with something like (# mytitle #)
Mind that to do the `${doc_name}dan.ctags` file

### Linking 
#### links_from
Creating the logic in `$HOME/.vim/after/ftplugin/${doc_name}dan.vim` , so the lines of the Index and other places in the Document can take you to the different tags by pressing `Ctrl + ]` 

#### links_to
Means to create the ruleset for ctags in order to parse the links_to of each topic/property/signature/function or whatever language feature you want to link on the docs.

```
$ cp ./ctags-rules/aidan.ctags ./ctags-rules/my-language.ctags
(Change all the fields s/aidan/mylanguage/g)
--langdef=mylanguagedantags
--langmap=mylanguagedantags:.my-languagedan
--kinddef-mylanguagedantags=t,topic,topics
--regex-mylanguagedantags=/^#\s(\w*)\s#$/\1/t/
```

Note if the name of your documentation has a dash on it, on ctags definitions on the directives on the left hand side you cannot use dashes, just put it together as 'mylanguagedantags'

### Styling 
Setting up the highlight rules for the filetype in vim , that will make viewing the document a pleasant time, enhacing visual memory , according to the patterns of the documentation.
Code syntax highlighting, and header highlight.


## Limitation on current docus

### apps-script
- Documentation is only for reference items (no tutorials)
- Pending to include api/reference/ items

### Unsolved issues
    - Make that upon installation , the script will set on `./autoload/dan.vim` , `var VIMDAN_DIR` as the one on `./vim-dan.sh`
    - Filenames that contain * are not parsed properly on the Index Parser
        Makeshift solution : batched renamed those files at the end of indexing process , this doesnt have any effect

```
rename -f "s/ /_/g" ${DOCU_PATH}/downloaded/**/*.*
rename "s/\*/asterisk/g" ${DOCU_PATH}/downloaded/**/*.*
```
    - java-specs , linking not working `E426: Tag not found: 1. Introduction` but selecting the tag manualy works
    - tags are not included in the source package of `vim-dan` due to 2 reasons: 1) The actual directory structure of the repository does make it cumbersome implement it. 2) The tags are meant to be updated localy in case you add Highlighting marks ' (X)' on tags , they need to be re-regenerated.

## Further ideas on the way

The following are ideas pending to develop within the project:

    - Create other layer of in-line highlighting , appart of (X) , do (K) for a finer more to stand out note for this:
        - create its mark mapping (K) (twice press Ctrl + p + p ?)
        - create its ctags regex positive lokaround
        - create its syntaxs patterns skips
        - create its own loc-list mechanisms
    - Create an online documentation repository , so it can be easily checked by something like
    Simple to use in a one-liner , 
 ```
curl https://vim-dan.io/nodejs | vim
 ``` 
    It should contain somehow syntax rules, tags and linking rules
    - Analogously to the last documentation parsers `./manpagesdeb` , find a way to categorize the files when parsing , doing an associative array for (Topic => File) , then create an Array that for each element (each Topic) is an object that has the actual attributes of the Topic (such as isAMethod , Parentof, ChildOf etc...) , to the documentation can be automatically generated (both index files and content files)
        (For this point there may have the need of migrating to an actual programming language such as nodejs)
    - Create an improved way to update the documentation when in use of (X) , such as locate the lines that have (X) ocurrence and place it in that new updated file , report the lines that dont have correspondence.
    - unmap insert modes and other modification modes and ways to access them
```
noremap i <Nop>
noremap o <Nop>
noremap r <Nop>
noremap R <Nop>
noremap A <Nop>
```
    - Syntax rules for java- maxforlive and apps-script
    - Bundle this repo as a vim plugin
    - react-native , need to use JS browser (probably need to index with puppetteer) , in order to get the examples by architecture , on the html tags <textarea> which at the moment are missing
    - Add a dependency checker
    - Create an ebook (`.epub`, `.pdf` etc...) parser, which will recognise the lines highlighted by the reader and the notes taken. Store
    - Create a tool that automatically index a website and parses all the relative links within the same host, it dumps all plaintext in a single file with the Directory of links_from at the Index on top of the page and the links_to , working from within any anchor html parsed, on those create a link_from

