au BufRead,BufNewFile *.chmdan set filetype=chmdan
"au BufRead,BufNewFile *.templatedan silent! call dan#Refreshloclist()
