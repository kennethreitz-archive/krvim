" Twitter with Vim
" Language: Vim Script
" Maintainer: Travis Jeffery <eatsleepgolf@gmail.com>
" Maintainer: Po Shan Cheah <morton@mortonfox.com>
" Created: 14 January 2008
" Last Change: March 27, 2008
" GetLatestVimScripts: 2124 1 [:AutoInstall:] vimtwitter.vim 
" ==============================================================

" Get proxy setting from vimtwitter_proxy in .vimrc or _vimrc.
" Format is proxysite:proxyport
if exists('vimtwitter_proxy')
    let s:proxy = "-x " . vimtwitter_proxy
else
    let s:proxy = ""
endif

" Get Twitter login info from vimtwitter_login in .vimrc or _vimrc.
" Format is username:password
if exists('vimtwitter_login')
    let s:login = "-u " . vimtwitter_login
else
    echoerr "Vimtwitter login not set. Please set vimtwitter_login in .vimrc to USER:PASS."
    finish
endif

" Load this module only once.
if exists('loaded_vimtwitter')
    finish
endif
let loaded_vimtwitter = 1

" The extended character limit is 246. Twitter will display a tweet longer than
" 140 characters in truncated form with a link to the full tweet. If that is
" undesirable, set s:char_limit to 140.
let s:char_limit = 246

let s:twupdate = "http://twitter.com/statuses/update.xml?source=vim"

function! s:post_twitter(mesg)
    let mesg = a:mesg

    " Remove trailing newline. You see that when you visual-select an entire
    " line. Don't let it count towards the tweet length.
    let mesg = substitute(mesg, '\n$', '', "")

    " Convert internal newlines to spaces.
    let mesg = substitute(mesg, '\n', ' ', "g")

    " Check tweet length. Note that the tweet length should be checked before
    " URL-encoding the special characters because URL-encoding increases the
    " string length.
    if strlen(mesg) > s:char_limit
	echo "Your tweet has" strlen(mesg) - s:char_limit "too many characters. It was not sent."
    else
	" URL-encode some special characters so they show up verbatim.
	let mesg = substitute(mesg, '%', '%25', "g")
	let mesg = substitute(mesg, '"', '%22', "g")
	let mesg = substitute(mesg, '&', '%26', "g")

	call system("curl ".s:proxy." ".s:login.' -d status="'.mesg.'" '.s:twupdate)
	echo "Your tweet was sent. You used" strlen(mesg) "characters."
    endif
endfunction

function! s:CmdLine_Twitter()
    call inputsave()
    let mesg = input("Your Twitter: ")
    call inputrestore()
    call s:post_twitter(mesg)
endfunction

" Prompt user for tweet.
command! PosttoTwitter :call <SID>CmdLine_Twitter()

" Post current line to Twitter.
command! CPosttoTwitter :call <SID>post_twitter(getline('.'))

" Post entire buffer to Twitter.
command! BPosttoTwitter :call <SID>post_twitter(join(getline(1, "$")))

" Post visual selection to Twitter.
vmap T y:call <SID>post_twitter(@")<cr>

" vim:set tw=0:
