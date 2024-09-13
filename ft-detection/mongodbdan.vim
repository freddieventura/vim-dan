au BufRead,BufNewFile *.mongodbdan set filetype=mongodbdan
"au BufRead,BufNewFile *.mongodbdan silent! call dan#Refreshloclist()
