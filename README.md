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


## Processes of creating a DAN Documentation

- Indexing
- Parsing
- Linking
- Styling

### Indexing: Specifying the Indexing Commands

### Parsing
Getting out of those pages a whole meaningfull document, headed by an Index document and followed by single document entries with entries amended so they can be tagged 
First line of each single document will be appended with something like (# mytitle #)
Mind that to do the `${doc_name}dan.ctags` file

### Linking 
Creating the logic in `$HOME/.vim/after/ftplugin/${doc_name}dan.vim` , so the lines of the Index and other places in the Document can take you to the different tags by pressing `Ctrl + ]` 

### Styling 
Setting up the highlight rules for the filetype in vim , that will make viewing the document a pleasant time, enhacing visual memory , according to the patterns of the documentation.
Code syntax highlighting, and header highlight.



## Further ideas on the way

The following are ideas pending to develop within the project:

    - Create an ebook (`.epub`, `.pdf` etc...) parser, which will recognise the lines highlighted by the reader and the notes taken. Store
