# VIM-DAN

```

                                                                               
            88                                      88                         
            ""                                      88                         
                                                    88                         
8b       d8 88 88,dPYba,,adPYba,            ,adPPYb,88 ,adPPYYba, 8b,dPPYba,   
`8b     d8' 88 88P'   "88"    "8a aaaaaaaa a8"    `Y88 ""     `Y8 88P'   `"8a  
 `8b   d8'  88 88      88      88 """""""" 8b       88 ,adPPPPP88 88       88  
  `8b,d8'   88 88      88      88          "8a,   ,d88 88,    ,88 88       88  
    "8"     88 88      88      88           `"8bbdP"Y8 `"8bbdP"Y8 88       88  
 
```

## Introduction

**DAN** stands for **Documents and Notes** , it is an updated collection of ready to view plain text Documentation of the most famous Languages, Frameworks, Programs etc... , with links browseable using vim (or any other `ctags` compatible program)

- Documentation ready for **offline** usage.
- Syntax highlighted, for easy read.
- Lightweight (parsed on plain-text) , so snappy to use.
- Jump from topic to topic by using the Documentation Index tags. Pressing `Ctrl + ]` , just as `vim-help` documentation work.
- Recall what you have learned by highlighting lines. Press `Ctrl + P` to leave a mark at the end of each line `(X)`, press `<F5>` to update and view all the highlighted lines in your current document in a Location List in a new tab.


## Visual desmonstration

<a href="https://asciinema.org/a/oL956IhemufusT8nQC4j8yY9t" target="_blank"><img src="https://asciinema.org/a/oL956IhemufusT8nQC4j8yY9t.svg" /></a>

## Installation for users

Say you want to download the Mozilla MDN Web Docs for Javascript, (assuming you are in a Debian based machine)

```
# Install dependencies
sudo apt install universal-ctags vim -y
git clone https://github.com/freddieventura/vim-dan
cd vim-dan

# Create your installation file , set your own installation path
vim ./vimdan_config

VIMDAN_DIR="${HOME}/mydocus/vim-dan"
VIM_RTP_DIR="${HOME}/.vim"

# List all the frameworks available
./vim-dan.sh

# Pick one of the list, for instance we will be picking the Mozila MDN web docs for Javascript
./vim-dan.sh mdnjs -i

# Access the documentation
vim local_path/vim-dan/mdnjs/main.mdnjsdan
```

<a href="https://asciinema.org/a/L3xY4GkGxvQ4YfBwSsyQkxAzv" target="_blank"><img src="https://asciinema.org/a/oL956IhemufusT8nQC4j8yY9t.svg" /></a>

## Updating your local documents


If long time has passed and the documentation has updated regarding to new features of the framework, as long as we have updated the Index, you can update yours localy.
Notes :
- It will attempt to keep all your highlighted lines `(X)` , it normally does.
- It will move your previous Index file to `main.<docu>dan-bk` in case you need to revert to it

```
git pull origin main
./vim-dan.sh <docu_name> -u
```

## Advanced usage


If you see that the Index available in this repository is outdated, you can try Indexing and parsing your own. The `indexing_rules`, `arranging_rules` and `parsing_rules` are available.

```
./vim-dan.sh <docu_name> -x
./vim-dan.sh <docu_name> -a
./vim-dan.sh <docu_name> -p
```

Note:

- As you are indexing the documentation from its source it will create a directory `/vim-dan/docu_name/downloaded/`
- It will index the whole website which will take long (hours or in some cases days).
- This directory may take up more than 30 GB of space, and it will make a backup of it when arranging its files.
- Mind the Internet resources also for the server, you will be creating a traffic that should be avoided.

## Collaborating with vim-dan

If you want to collaborate with `vim-dan`, you may explore at adding new frameworks, update the existing ones, suggest new features, you should at first visualize how it works.

Notes:
- It is a personal project created and maintained , at the moment, solely by me.
- When it was first created, I didn't have any reference on any similar proyect, also being my developer experience limited, the codebase may be improveable in many ways.
- Regardless of the above, it covers a necesity users have, and it works. It is scalable, proceeding to explain the rules for creating your own parser for a framework.


## Creating your own documentation , basics



### Preparing vim-dan boilerplate

In order to parse a new documentation, just copy the template that I have included, it is based on my last `google-cloud` indexing, arranging and parsing rules. And it should work in new environments pretty much without much modifications.

```
cp ./frameworks/template-tofollow.sh ./frameworks/yourdocu.sh
```

You also want to copy the following files adapting them to your documentation


```
cp ./ft-detection/template.vim ./ft-detection/yourdocu.vim
sed -i "s|template|yourdocu|" ./ft-detection/yourdocu.vim

```
Copy the template `ctags` ruleset 

```
cp ./ctags-rules/template.ctags ./ctags-rules/yourdocu.ctags
sed -i "s|template|yourdocu|" ./ctags-rules/yourdocu.ctags
## note as a limitation from ctags if youdocu name 
## has any non-alphanumeric character on it
## delete that non-alphanum character leaving it like

# example of google-clouddan.ctags
--langdef=googleclouddantags
--langmap=googleclouddantags:.google-clouddan
--kinddef-googleclouddantags=t,topic,topics
--regex-googleclouddantags=/^#\s(.*)\s#(\s\(X\)){0,1}$/\1/t/
## note the language defition string and the subsequents , there is where you need to delete that
```

Copy the template `syntax-rules`

```
cp ./syntax-rules/templatedan.vim ./syntax-rules/yourdocudan.vim
```

### Adding indexing,arranging,parsing rules

The main magic happens on the file  `./frameworks/yourdocu.sh`

In order to make a good plain-text index of an online documentation, you may find many hurdles, such as including files that have different html structure, others may give not relevant information for the purposes of the topic, such as pages showing business partners, pricing and other things that may find on those websites.
There are no golden set of rules, at the moment the current documentations aim to provide extensive information as long as the resulting file doesnt exceed `300MB`.
Aiming to index reference to API's that is the main objective, but also tutorials on how to get initiated, even there may be blog posts with relevant information.
As said, if the topic is complex, you may want to include more info such as tutorials, if it si too obvious dont include them. If the resulting file is few MB's then include more things.
If you feel you need to include a lot of things, and the resulting documentation is huge (exceding 300MB), we can split it in different documents (will explain on Creating your own documentation Advanced)


#### indexing_rules

Here are the wget command to download all the `.html` files.
You can customize and add parameters accordingly. Try to select with complex ruleset of `man wget` `Recursive Acccept/Reject Options` to cherry pick the files to download.
The more you refine your indexing_rules the less you need to specify on your arranging_rules.
My experience is, don't bother too much with this ruleset, just make a full index of the whole website if needed, avoiding to download files that are 100% not going to be used at all such as

```
    `## Recursive Accept/Reject Options` \
      --reject-regex '.*?hel=.*|.*?hl=.*' \
      --reject '*.pdf,*.woff,*.woff2,*.ttf,*.png,*.webp,*.mp4,*.ico,*.svg,*.js,*json,*.css,*.xml,*.txt' \
```

Do a proper index once, then select what you want on `arranging_rules`

#### arranging_rules

This correspond to the file modifications that are going to be done on the downloaded files in order to select the files that you want.

Add rules on the lines of the comments `## --> ADD RULES HERE`

You have got some examples of arranging_rules in

`./scripts/helpers`
```
arranging_snippets() {
```

Check them or check other frameworks rules.
Note , keep the subroutine `DEESTRUCTURING THE DIRECTORY TREE` , and the `RENAME LONE INDEX.HTM` they work seamless with the template `parsing_rules`



#### parsing_rules


This is the algorithm that creates the single file with all the documentation.
Don't bother modifying it as it will break the functionalities of the previous stuff.
Just modify on the lines that have `## --> MODIFY THIS` appended on them

You want to research on the target `.html` pages, the selector for the tags you want to parse.
We are parsing a title
```
    f1() { pup -i 0 --pre 'h1.devsite-page-title' | pandoc -f html -t plain | sed ':a;N;$!ba;s/\n/ /g';}  ## --> MODIFY THIS
```

And a content

```
    f1() { pup -i 0 --pre 'article div.devsite-article-body' | pandoc -f html -t plain --wrap=none;} ## --> MODIFY THIS
```

The previous algorithm will work multi-rule in the following way.
You can specify more than one rule, and upon finding a non-empty tag, that will be the one parsed.

For instance if in your index some pages have got the conent in one tag, and some other in other tag, you can specify them like this example taken from `zaproxy.sh`.

```
    f1() { pup -i 0 --pre 'div.guide-content' | pandoc -f html -t plain ;}
    f2() { pup -i 0 --pre 'body' | pandoc -f html -t plain ;}

    content_parsing_array=(f1 f2)
```

Finally , we are able to clean the resulting file from repeated patterns of Strings that we haven't been able to filter previously.

May the resulting file include some footer that gets parsed for every document you can add  a `sed` command at the end.
Example of `zaproxy.sh`

```
    ## Retrieving content of the files and cleaning it
    sed -e '/^\[\]$/d' \
        -e 's/\[\]//g' \
        -e '/^-   $/d' \
        -e '/^ZAP$/d' \
        -e '/^Download$/d' \
        -e '/^-   Blog$/d' \
        -e '/^-   Videos$/d' \
        -e '/^-   Documentation$/d' \
        -e '/^-   Community$/d' \
        -e '/^-   Support$/d' \
        -e '/^-   Statistics/d' \
        -e '/^-   \[Search icon\]$/d' \
        -e '/\[The Crash Override Open Source Fellowship\]/d' \
        "${content_dump}" >> "${MAIN_TOUPDATE}"    
```


With all the steps above you should have been able to parse your first documentation.


#### Appendix: adapting the syntax-rules

With the first file of the documentation you have got, you can see the patterns of repeated words that are explicative in the documentation , keywords such as `Arguments`, `Instance properties` `Examples` `Constructor` etc...
If you know about `vim-patterns` and `vim-highlight` and `vim-syntax` you can do so.

By doing

```
cat main.${yourdocu}dan | grep -o -E '^\w+' | sort | uniq -c | sort -nr
```

You can see a bunch of words that appear in a line, and the number of ocurrences.
Then you can create a custom syntax-rules file

```
cp ./syntax-rules/template.vim ./syntax-rules/yourdocu.vim
```

And change the lines

```
syn match danValues "^Values\%(\s(X)\)\{,1}$" contains=danX
hi def link danValues TabLine
```

Add more words.
The document explain it a bit better

## Creating your own documentation advanced

If you want more customization for been more accurate you can modify the following.
Further customizaton involves from:

- Changing parsing_rules()
- Adding new tags on ctags-rules 
- Altering the linking-rules


This takes a lot of fiddeling, trial and error. Until I have found a comfortable template I was changing a lot these things, it will give you way more freedom to perform some things at the cost of non-escalability as this is coding for certain frameworks only. I will put some examples below so you can check different approaches I have used.

### Changing parsing_rules()

In some documentations that the nesting depth of each document in the downloaded folder is not too long, the Index could be done easier.
Check `frameworks/mdnjs.sh` for that, although as I said, the current  template prepare the files with `arraging_rules` nicely to perform a nice Index no matter the nesting depth of each .html document.

### Adding new tags on ctags-rules and altering the linking-rules

Some documentations come form a single file, or really few files, and you want to be adding links to different parts of it (Methods, Classes etc...) , you can still perform that by checking on some regularities , finding out the regexps , see for instance `./ctags-rules/nodejsdan.ctags` 

This comes with an increase of complexity in the linking-rules too , as you wont be making your index, but will be relying as well on regularities on the text, yet other regexes which vim has to understand as link_from. `./linking-rules/nodejsdan.vim`



## Future additions

- CDP Create https://developer.chrome.com/docs/devtools/
- mongodb
- google-developer
- win-pwsh ,(expand to all windows , make a windows wide Index)
- react-native , need to use JS browser (probably need to index with puppetteer) , in order to get the examples by architecture , on the html tags <textarea> which at the moment are missing


## Current Issues

### win-pwsh
- Pending pages like https://learn.microsoft.com/en-us/powershell/module/nettcpip

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



## Ideas

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

    - Create an ebook (`.epub`, `.pdf` etc...) parser, which will recognise the lines highlighted by the reader and the notes taken.


