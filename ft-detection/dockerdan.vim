au BufRead,BufNewFile *.dockerdan set filetype=dockerdan
"au BufRead,BufNewFile *.dockerdan silent! call dan#Refreshloclist()
