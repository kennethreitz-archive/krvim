" Vimball Archiver by Charles E. Campbell, Jr., Ph.D.
UseVimball
finish
plugin/pluginkillerPlugin.vim	[[[1
20
" pluginkillerPlugin.vim: interface for pluginkiller
" Author: Charles E. Campbell,Jr.
" Date:   Dec 20, 2007
" GetLatestVimScripts: :AutoInstall: 1489 1 pluginkiller.vim
" ---------------------------------------------------------------------
"  Vim-Compatable Test: {{{1
if &cp || exists("g:loaded_pluginkillerPlugin")
 finish
endif
let g:loaded_pluginkillerPlugin= "v4c"

" ---------------------------------------------------------------------
"  Public Interface: {{{1
exe "com! -nargs=0 PK           call pluginkiller#PluginKiller(1)"
exe "com! -nargs=0 PluginKiller call pluginkiller#PluginKiller(1)"
exe "com! -nargs=0 PKnfm        call pluginkiller#PluginKiller(0)"

" ---------------------------------------------------------------------
"  Modelines: {{{1
"  vim: fdm=marker
autoload/pluginkiller.vim	[[[1
515
" pluginkiller.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Apr 15, 2010
"   Version: 4c	ASTRO-ONLY
" ---------------------------------------------------------------------
"  Load Once: {{{1
if &cp || exists("g:loaded_pluginkiller")
 finish
endif
let g:loaded_pluginkiller= "v4c"
if !has("clientserver")
 echoerr "(pluginkiller) your vim needs +clientserver for the pluginkiller to work"
 finish
endif
let s:keepcpo      = &cpo
set cpo&vim

" ---------------------------------------------------------------------
"  Sanity Checks: {{{1
if &cp
 finish
endif
if v:version < 700
 echohl WarningMsg
 echo "***warning*** this version of pluginkiller needs vim 7.0"
 echohl Normal
 finish
endif
if !has("clientserver")
 echohl Error | echo "unfortunately your vim doesn't support clientserver!" | echohl None
 finish
endif
"DechoRemOn

" ---------------------------------------------------------------------
" PluginKiller Messages: {{{1
let s:PluginKillerReset= 0
let s:PluginKillerGood = 1
let s:PluginKillerBad  = 2
let s:PluginKillerBack = 3

" =====================================================================
"  Public Interface: {{{1
com! -nargs=0 PKr call s:BinSrch(s:PluginKillerReset)
com! -nargs=0 PKg call s:BinSrch(s:PluginKillerGood)
com! -nargs=0 PKb call s:BinSrch(s:PluginKillerBad)
com! -nargs=0 PKB call s:BinSrch(s:PluginKillerBack)
com! -nargs=0 PKo call s:PKRemoteOff()

" =====================================================================
"  Functions: {{{1

" ---------------------------------------------------------------------
" pluginkiller#PluginKiller: called by :PK to initialize the pluginkiller {{{2
fun! pluginkiller#PluginKiller(nofuncmap)
"  call Dfunc("pluginkiller#PluginKiller(nofuncmap=".a:nofuncmap.")")

  let s:pkfile= expand("$HOME")."/pluginkiller"
"  call Decho("s:pkfile<".s:pkfile.">")

  " get start/stop if s:pkfile exists already
  if filereadable(s:pkfile)
   if serverlist() !~ '\<PLUGINKILLER\>'
"	call Decho("can't find remote PLUGINKILLER; removing s:pkfile<".s:pkfile.">")
	let response= confirm("Is it ok to delete ".s:pkfile."?","&yes\n&no",1)
	if response == 1
	 call delete(s:pkfile)
	else
	 echo "PluginKiller aborted"
"     call Dret("pluginkiller#PluginKiller")
	 return
	endif
   else
"    call Decho("get the start/stop from the remote PLUGINKILLER")
    call s:PKGetStartStop()
   endif
  endif

  " set up the PLUGINKILER server
  if serverlist() !~ '\<PLUGINKILLER\>'
"   call Decho("set up the PLUGINKILLER server")
   call system('gvim --servername PLUGINKILLER '.s:pkfile)
   while serverlist() !~ '\<PLUGINKILLER\>'
	sleep 25m
   endwhile
   call remote_send("PLUGINKILLER",":call pluginkiller#RemoteSync()\<cr>","serverid")
   call remote_send("PLUGINKILLER",":echo \" \"\<cr>")
   let reply= remote_read(serverid)
   call remote_send("PLUGINKILLER",":au VimLeave pluginkiller call pluginkiller#RemoteEnd('".s:pkfile."')\<cr>")
  endif

  " The following title settings shouldn't hurt, they're just to let you know that the pluginkiller is active.
  if !exists("s:oldtitle")
   let s:oldtitle= &titlestring
  endif
  set title titlestring=Plugin\ Killer\ Active

  " record user's current settings
  call s:PKRecordSettings()
  
  " set up troublesome pluginkiller setting list
  call s:PKInitSettings()

  if !exists("g:pluginkiller_nofuncmap") && a:nofuncmap == 1
"   call Decho("set up ctrl-f1, ctrl-f2 maps")
   ino <c-f1>	<c-o>:call <SID>BinSrch(1)<cr>
   ino <c-f2>	<c-o>:call <SID>BinSrch(2)<cr>
   nno <c-f1>	:call <SID>BinSrch(1)<cr>
   nno <c-f2>	:call <SID>BinSrch(2)<cr>
  endif

"  call Dret("pluginkiller#PluginKiller")
endfun

" ---------------------------------------------------------------------
" pluginkiller#RemoteSendStartStop: used by the remote PLUGINKILLER gvim to reply with start/stop {{{2
fun! pluginkiller#RemoteSendStartStop()
  let client= expand("<client>")
"  call Dfunc("pluginkiller#RemoteSendStartStop() client<".client.">")
  call server2client(client,"let s:pkstart=".g:pkstart."|let s:pkstop=".g:pkstop)
"  call Dret("pluginkiller#RemoteSendStartStop : pkstart=".g:pkstart." pkstop=".g:pkstop)
endfun

" ---------------------------------------------------------------------
" pluginkiller#RemoteSync: {{{2
fun! pluginkiller#RemoteSync()
  let client= expand("<client>")
"  call Dfunc("pluginkiller#RemoteSync()")
  call server2client(client,"ready")
"  call Dret("pluginkiller#RemoteSync")
endfun

" ---------------------------------------------------------------------
" pluginkiller#RemoteSettings: called by remote PLUGINKILLER so that it, at least, {{{2
"                              has acceptable options.
fun! pluginkiller#RemoteSettings()
"  call Dfunc("pluginkiller#RemoteSettings()")

  set ai&vim     cwh&vim    hidden&vim more&vim   sj&vim     ss&vim     sw&vim    
  set cin&vim    cf&vim     hls&vim    magic&vim  spell&vim  sb&vim     sr&vim    
  set ci&vim     ea&vim     ic&vim     pi&vim     report&vim spr&vim    tw&vim    
  set acd&vim    ead&vim    im&vim     pvh&vim    siso&vim   sol&vim    top&vim   
  set cb&vim     gd&vim     js&vim     remap&vim  so&vim     swb&vim    ws&vim    
  set ch&vim     go&vim     ls&vim     scr&vim    ei&vim
  set ma noswf fo=l nowrap nonu

"  call Dret("pluginkiller#RemoteSettings")
endfun

" ---------------------------------------------------------------------
" s:BinSrch: {{{2
fun! s:BinSrch(msg)
"  call Dfunc("s:BinSrch(msg=".a:msg."<".["reset","good","bad","back"][a:msg].">)")
"  call Decho("s:pkstart= setting#".s:pkstart."<".s:pklist[s:pkstart].">")
"  call Decho("s:pkstop = setting#".s:pkstop."<".s:pklist[s:pkstop].">")
"  call Decho("s:pkhist".string(s:pkhist))

  " restore user settings
  call s:PKRestoreSettings()

  if exists("s:pkinit") && a:msg == s:PluginKillerGood && s:pkstart == 0 && s:pkstop == (s:pkqty - 1)
   call s:PKMesg("Congratuations -- looks like your plugin already handles all pluginkiller's settings!")
"   call Dret("s:BinSrch")
   return
  endif

  if a:msg == s:PluginKillerReset
   " use all troublesome pluginkiller settings
   let s:pkstart = 0
   let s:pkstop  = s:pkqty - 1
   let s:pkhist  = []
   let s:pkinit  = 1

  elseif a:msg == s:PluginKillerGood
   let histlen   = len(s:pkhist)
   if histlen > 0
    let prvhist   = s:pkhist[histlen-1]
	let s:pkstart = (prvhist[0] + prvhist[1])/2 + 1
    let s:pkstop  = prvhist[1]
   else
	let s:pkstop  = s:pkqty - 1
	let s:pkstart = s:pkstop/2 + 1
	let s:pkhist  = []
   endif
   call add(s:pkhist,[s:pkstart,s:pkstop])
   let s:pkstop  = (s:pkstart + s:pkstop)/2 

"   let s:pkhist  = s:pkhist + [s:pkstart,s:pkstop]
"   let   pkstart = s:pkstop + 1
"   let s:pkstop  = s:pkstop + (s:pkstop - s:pkstart)
"   let s:pkstart = pkstart
"   let s:pkstop  = (s:pkstart + s:pkstop)/2 

  elseif a:msg == s:PluginKillerBad
   call add(s:pkhist,[s:pkstart,s:pkstop])
   if exists("s:pkinit")
    unlet s:pkinit
   endif
   let s:pkstart = s:pkstart
   let s:pkstop  = (s:pkstart + s:pkstop)/2 

  elseif a:msg == s:PluginKillerBack
   let histlen   = len(s:pkhist)
   if histlen > 1
    let prvhist   = s:pkhist[histlen-2]
    let s:pkstart = prvhist[0]
    let s:pkstop  = prvhist[1]
	call remove(s:pkhist,histlen-2)
    let s:pkstop  = (s:pkstart + s:pkstop)/2 
   else
	let s:pkstart = 0
	let s:pkstop  = s:pkqty - 1
	let s:pkhist  = []
	let s:pkinit  = 1
   endif
  endif

  if s:pkstart >= s:pkstop
"   call Decho("[s:pkstart=".s:pkstart."] == [s:pkstop=".s:pkstop."]")
   call s:PKSendSettings(s:pkstart,s:pkstart)
   call s:PKMesg(s:pklist[s:pkstart].": ".s:pkmesg[s:pkstart])
   let s:pkstart= 0
   let s:pkstop = s:pkqty - 1
   let s:pkhist = []
   let s:pkinit = 1
  else
   call s:PKSendSettings(s:pkstart,s:pkstop)
  endif

"  call Decho("s:pkhist".string(s:pkhist))
"  call Dret("s:BinSrch")
endfun

" ---------------------------------------------------------------------
" s:PKSendSettings: send settings s:pklist[a:pkstart..a:pkstop] to PLUGINKILLER {{{2
fun! s:PKSendSettings(pkstart,pkstop)
"  call Dfunc("s:PKSendSettings(pkstart=".a:pkstart." pkstop=".a:pkstop.")")
"  call Decho("trying start setting#".a:pkstart."<".s:pklist[a:pkstart].">")
"  call Decho("trying stop  setting#".a:pkstop."<".s:pklist[a:pkstop].">")

  call remote_send("PLUGINKILLER",":call pluginkiller#RemoteSettings()\<cr>")
  call remote_send("PLUGINKILLER",":sil! keepj %d\<cr>")
  call remote_send("PLUGINKILLER","Go\" --------------------------\<esc>")
  call remote_send("PLUGINKILLER","Go\" Plugin Killer Test Options: #".(a:pkstart+0)."<".s:pklist[a:pkstart]."> - #".(a:pkstop+0)."<".s:pklist[a:pkstop].">\<esc>")
  call remote_send("PLUGINKILLER","Go\" --------------------------\<esc>")
  let i   = a:pkstart
"  call Decho("sending settings ".a:pkstart."...".a:pkstop." (".s:pklist[a:pkstart]."...".s:pklist[a:pkstop].")")
  while i <= a:pkstop
   call remote_send("PLUGINKILLER","Go".s:pklist[i]."\<esc>")
   let i= i + 1
  endwhile
  call remote_send("PLUGINKILLER","1Gdd")
  call remote_send("PLUGINKILLER",":setl nomod noma ft=vim\<cr>")
  call remote_send("PLUGINKILLER",":w!\<cr>")
  call remote_send("PLUGINKILLER",":syn on\<cr>")
  call remote_send("PLUGINKILLER",":let g:pkstart=".s:pkstart."|let g:pkstop=".s:pkstop."\<cr>")
  call remote_send("PLUGINKILLER",":echo \" \"\<cr>")
  call remote_send("PLUGINKILLER",":call pluginkiller#RemoteSync()\<cr>","serverid")
  call remote_send("PLUGINKILLER",":echo \" \"\<cr>")
  let reply= remote_read(serverid)
"  call Decho("exe sil! keepj so ".s:pkfile.")")
  exe "sil! keepj so ".s:pkfile

"  call Dret("s:PKSendSettings")
endfun

" ---------------------------------------------------------------------
" s:PKGetStartStop: gets the remote PLUGINKILLER's pkstart and pkstop {{{2
fun! s:PKGetStartStop()
"  call Dfunc("s:PKGetStartStop() s:pkfile<".s:pkfile.">")
  if exists("s:reply")
   unlet s:reply
  endif
  call remote_send("PLUGINKILLER",":call pluginkiller#RemoteSendStartStop()\<cr>","serverid")
  let reply= remote_read(serverid)
"  call Decho("reply<".reply.">")
  exe reply
"  call Dret("s:PKGetStartStop : s:pkstart=".s:pkstart." s:pkstop=".s:pkstop)
endfun

" ---------------------------------------------------------------------
" s:PKRecordSettings: record user's original settings {{{2
fun! s:PKRecordSettings()
"  call Dfunc("s:PKRecordSettings()")
   " save initial settings
"  call Decho("saving initial option settings")
  let s:PluginKiller_keep_ai     = &ai
  let s:PluginKiller_keep_cin    = &cin
  let s:PluginKiller_keep_ci     = &ci
  if exists("&acd")
   let s:PluginKiller_keep_acd   = &acd
  endif
  let s:PluginKiller_keep_cb     = &cb
  let s:PluginKiller_keep_ch     = &ch
  let s:PluginKiller_keep_cwh    = &cwh
  let s:PluginKiller_keep_cf     = &cf
  let s:PluginKiller_keep_ea     = &ea
  let s:PluginKiller_keep_ead    = &ead
  let s:PluginKiller_keep_fo     = &fo
  let s:PluginKiller_keep_gd     = &gd
  let s:PluginKiller_keep_go     = &go
  let s:PluginKiller_keep_hidden = &hidden
  let s:PluginKiller_keep_hls    = &hls
  let s:PluginKiller_keep_ic     = &ic
  let s:PluginKiller_keep_im     = &im
  let s:PluginKiller_keep_js     = &js
  let s:PluginKiller_keep_ls     = &ls
  let s:PluginKiller_keep_more   = &more
  let s:PluginKiller_keep_magic  = &magic
  let s:PluginKiller_keep_num    = &number
  let s:PluginKiller_keep_pi     = &pi
  let s:PluginKiller_keep_pvh    = &pvh
  let s:PluginKiller_keep_remap  = &remap
  let s:PluginKiller_keep_scr    = &scr
  let s:PluginKiller_keep_sj     = &sj
  let s:PluginKiller_keep_spell  = &spell
  let s:PluginKiller_keep_report = &report
  let s:PluginKiller_keep_siso   = &siso
  let s:PluginKiller_keep_smd    = &smd
  let s:PluginKiller_keep_siso   = &siso
  let s:PluginKiller_keep_so     = &so
  let s:PluginKiller_keep_ss     = &ss
  let s:PluginKiller_keep_sb     = &sb
  let s:PluginKiller_keep_spr    = &spr
  let s:PluginKiller_keep_sol    = &sol
  let s:PluginKiller_keep_swb    = &swb
  let s:PluginKiller_keep_sw     = &sw
  let s:PluginKiller_keep_sr     = &sr
  let s:PluginKiller_keep_tw     = &tw
  let s:PluginKiller_keep_top    = &top
  let s:PluginKiller_keep_ws     = &ws
"  call Dret("s:PKRecordSettings")
endfun

" ---------------------------------------------------------------------
" s:PKRestoreSettings: restore original user's settings {{{2
fun! s:PKRestoreSettings()
"  call Dfunc("s:PKRestoreSettings()")

"  call Decho("restoring initial option settings")
  let &ai     = s:PluginKiller_keep_ai
  let &cin    = s:PluginKiller_keep_cin
  let &ci     = s:PluginKiller_keep_ci
  if exists("&acd")
   let &acd   = s:PluginKiller_keep_acd
  endif
  let &cb     = s:PluginKiller_keep_cb
  let &ch     = s:PluginKiller_keep_ch
  let &cwh    = s:PluginKiller_keep_cwh
  let &cf     = s:PluginKiller_keep_cf
  let &ea     = s:PluginKiller_keep_ea
  let &ead    = s:PluginKiller_keep_ead
  let &fo     = s:PluginKiller_keep_fo
  let &gd     = s:PluginKiller_keep_gd
  let &go     = s:PluginKiller_keep_go
  let &hidden = s:PluginKiller_keep_hidden
  let &hls    = s:PluginKiller_keep_hls
  let &ic     = s:PluginKiller_keep_ic
  let &im     = s:PluginKiller_keep_im
  let &js     = s:PluginKiller_keep_js
  let &ls     = s:PluginKiller_keep_ls
  let &more   = s:PluginKiller_keep_more
  let &magic  = s:PluginKiller_keep_magic
  let &number = s:PluginKiller_keep_num
  let &pi     = s:PluginKiller_keep_pi
  let &pvh    = s:PluginKiller_keep_pvh
  let &remap  = s:PluginKiller_keep_remap
  let &scr    = s:PluginKiller_keep_scr
  let &sj     = s:PluginKiller_keep_sj
  let &spell  = s:PluginKiller_keep_spell
  let &report = s:PluginKiller_keep_report
  let &siso   = s:PluginKiller_keep_siso
  let &smd    = s:PluginKiller_keep_smd
  let &siso   = s:PluginKiller_keep_siso
  let &so     = s:PluginKiller_keep_so
  let &ss     = s:PluginKiller_keep_ss
  let &sb     = s:PluginKiller_keep_sb
  let &spr    = s:PluginKiller_keep_spr
  let &sol    = s:PluginKiller_keep_sol
  let &swb    = s:PluginKiller_keep_swb
  let &sw     = s:PluginKiller_keep_sw
  let &sr     = s:PluginKiller_keep_sr
  let &tw     = s:PluginKiller_keep_tw
  let &top    = s:PluginKiller_keep_top
  let &ws     = s:PluginKiller_keep_ws
"  call Dret("s:PKRestoreSettings")
endfun

" ---------------------------------------------------------------------
" s:PKInitSettings: set up the s:pklist and s:pkmesg lists {{{2
fun! s:PKInitSettings()
"  call Dfunc("s:PKInitSettings()")

  let s:pklist= []
  let s:pkmesg= []
  let s:pkhist= []
  let s:pkqty = 0
  let s:pkinit= 1
  if exists("&acd")
   let s:pkqty= s:pkqty+1 | call add(s:pklist,"set acd") | call add(s:pkmesg,"changes working directory when you open a file, switch buffers, delete buffer, open/close window")
  endif
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ai")                  | call add(s:pkmesg,"when inserting lines, you probably don't want ai (autoindent)")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set cin")                 | call add(s:pkmesg,"when inserting lines, you probably don't want cin (c-program indenting)")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ci")                  | call add(s:pkmesg,"when inserting lines, you probably don't want ci (copy indenting structure)")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set cb=autoselect")       | call add(s:pkmesg,"don't want to have clipboard changed when using, say norm! vy")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ch=1")                | call add(s:pkmesg,"try to avoid |hit-enter| prompts anyway")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set cwh=1")               | call add(s:pkmesg,"if you're using it, maybe you want to see it >1 line?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set cf")                  | call add(s:pkmesg,"you don't want confirm dialogs when changing things while in a plugin")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ea")                  | call add(s:pkmesg,"windows are automatically being made the same size")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ead=ver")             | call add(s:pkmesg,"don't want plugins unexpectedly changing window sizes")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ed")                  | call add(s:pkmesg,"makes 'g' and 'c' flags toggle each time flag is given")
  if &fen
   let s:pkqty= s:pkqty+1 | call add(s:pklist,"set nofen")              | call add(s:pkmesg,"your plugin doesn't like folds disabled")
  else
   let s:pkqty= s:pkqty+1 | call add(s:pklist,"set fen")                | call add(s:pkmesg,"your plugin doesn't like folds enabled")
  endif
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set fo=tcroqwan2vblmMB1") | call add(s:pkmesg,"if this is your problem, suggest your plugin uses fo=tcq")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set gd")                  | call add(s:pkmesg,"all substitutions have \"g\" flag appended (yuck)")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set go+=a")               | call add(s:pkmesg,"another visual-selection messes with clipboard")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set hidden")              | call add(s:pkmesg,"does your plugin leave [Scratch] buffers behind?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set hls")                 | call add(s:pkmesg,"don't want to change @/")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ic")                  | call add(s:pkmesg,"ignores case -- does your plugin still work?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set im")                  | call add(s:pkmesg,"insertmode is now vim's default mode")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set js")                  | call add(s:pkmesg,"does joining with two spaces clobber something?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ls=0")                | call add(s:pkmesg,"does your plugin use the status line?  This'll do it in...")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set more")                | call add(s:pkmesg,"yep, listings pauses will help plugins a lot - not!")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set nomagic")             | call add(s:pkmesg,"there goes all your nifty regexps with magic")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set pi")                  | call add(s:pkmesg,"always preserves indent...")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set pvh=1")               | call add(s:pkmesg,"previewheight of 1 makes it \"go away\".  Does your plugin want a preview window?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set noremap")             | call add(s:pkmesg,"always prevents mapping recursion (ie. your map can't call upon other maps)")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set number")              | call add(s:pkmesg,"responsible for printing the line numbers to the left of the text")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set scr=3")               | call add(s:pkmesg,"made ctrl-u and ctrl-d do only three lines.  Got any maps using these?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set sj=4")                | call add(s:pkmesg,"guess you don't like jumpy displays")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set spell")               | call add(s:pkmesg,"do you really want spellchecking?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set nosol")               | call add(s:pkmesg,"various commands move cursor to first non-blank of line")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set report=0")            | call add(s:pkmesg,"is your plugin real noisy now?  this one reports all changes.")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set siso=5")              | call add(s:pkmesg,"the sidescrolloff option is causing you problems")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set smd")                 | call add(s:pkmesg,"show extra messages when in insert, replace, visual modes.")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set siso=30")             | call add(s:pkmesg,"min qty screen columns to left")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set so=100")              | call add(s:pkmesg,"scrolloff - keeps &so lines above&below cursor")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ss=10")               | call add(s:pkmesg,"min qty columns to scroll horizontally")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set sb")                  | call add(s:pkmesg,"split windows below    -- does your new window open ok?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set spr")                 | call add(s:pkmesg,"split windows to right -- does your new window open ok?")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set sol")                 | call add(s:pkmesg,"a number of motion commands move cursor to first non-blank of line")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set swb=split")           | call add(s:pkmesg,"split current window before loading a buffer")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set sw=2")                | call add(s:pkmesg,"qty spaces to use for each indent")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set sr")                  | call add(s:pkmesg,"round indent to multiple of 'sw'")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set tw=50")               | call add(s:pkmesg,"medium size textwidth selected")
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set top")                 | call add(s:pkmesg,"make ~ behave like an operator")
  if &wrap
   let s:pkqty= s:pkqty+1 | call add(s:pklist,"set wrap")               | call add(s:pkmesg,"problem with wrap off?")
  else
   let s:pkqty= s:pkqty+1 | call add(s:pklist,"set nowrap")             | call add(s:pkmesg,"problem with wrap on?")
  endif
  let s:pkqty= s:pkqty+1 | call add(s:pklist,"set nows")                | call add(s:pkmesg,"no wrapscan (ie. searches don't wrap around the end-of-file)")
  if &ve == ""
   let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ve=all")             | call add(s:pkmesg,"problem with virtual edit on?")
  else
   let s:pkqty= s:pkqty+1 | call add(s:pklist,"set ve=")                | call add(s:pkmesg,"problem with virtual edit off?")
  endif
"  call Decho("s:pkqty=".s:pkqty)

  if !exists("s:pkstart") || !exists("s:pkstop")
   " initialize setting-interval to cover all settings
"   call Decho("initialize start/stop")
   let s:pkstart = 0
   let s:pkstop  = s:pkqty - 1
  endif

   " initialize settings
  call s:PKSendSettings(s:pkstart,s:pkstop)

"  call Dret("s:PKInitSettings : s:pkqty=".s:pkqty." s:pkstart=".s:pkstart." s:pkstop=".s:pkstop)
endfun

" ---------------------------------------------------------------------
" s:PKMesg: makes a string appear on the remote PLUGINKILLER {{{2
fun! s:PKMesg(mesg)
"  call Dfunc("s:PKMesg(mesg<".a:mesg.">)")
  call remote_send("PLUGINKILLER",":setl nomod noma\<cr>")
  call remote_send("PLUGINKILLER",":echo '".substitute(a:mesg,"'","''","g")."'\<cr>")
"  call Dret("s:PKMesg")
endfun

" ---------------------------------------------------------------------
" s:PKRemoteOff: tell the remote PLUGINKILLER to terminate {{{2
fun! s:PKRemoteOff()
"  call Dfunc("s:PKRemoteOff()")
  if serverlist() !~ '\<PLUGINKILLER\>'
"   call Decho("telling PLUGINKILLER to quit")
   call remote_send("PLUGINKILLER",":q!\<cr>")
  endif
  if filereadable(s:pkfile)
"   call Decho("deleting pkfile<".s:pkfile.">")
   call delete(s:pkfile)
  endif
"  call Dret("s:PKRemoteOff")
endfun

" ---------------------------------------------------------------------
" pluginkiller#RemoteEnd: called by the remote PLUGINKILLER when a VimLeave event occurs {{{2
fun! pluginkiller#RemoteEnd(pkfile)
"  call Dfunc("pluginkiller#RemoteEnd(pkfile<".a:pkfile.">)")
  if filereadable(a:pkfile)
"   call Decho("deleting pkfile<".a:pkfile.">")
   call delete(a:pkfile)
  endif
"  call Dret("pluginkiller#RemoteEnd")
endfun

" ---------------------------------------------------------------------
"  Restore: {{{1
let &cpo= s:keepcpo
unlet s:keepcpo
" vim: ts=4 fdm=marker
doc/pluginkiller.txt	[[[1
209
*pluginkiller.txt*	Plugin Killer				Apr 15, 2010

Author:  Charles E. Campbell, Jr.  <NdrOchip@ScampbellPfamily.AbizM>
	  (remove NOSPAM from Campbell's email first)
Copyright: (c) 2006-2010 by Charles E. Campbell, Jr.	*pluginkiller-copyright*
           The VIM LICENSE applies to pluginkiller.vim
           (see |copyright|) except use "pluginkiller instead of "Vim"
	   No warranty, express or implied.  Use At-Your-Own-Risk.

==============================================================================
1. Contents				*pluginkiller* *pluginkiller-contents*
>
	   Purpose: to help plugin writers find options that interfere
	   with their plugin's operation before their users do.
<
	1. Contents..............................: |pluginkiller-contents|
	2. Pluginkiller Manual...................: |pluginkiller-manual|
	3. Pluginkiller Usage....................: |pluginkiller-usage|
	4. Installing the PluginKiller...........: |pluginkiller-install|
	5. History...............................: |pluginkiller-history|

==============================================================================
2. Pluginkiller Manual					*pluginkiller-manual*

							*pluginkiller-PK*
	:PK	This command loads the pluginkiller's settings into the
		window under test -- ie. initializes your plugin with the
		pluginkiller's "nasty" vim option settings.  It will also
		start up the PLUGINKILLER server as required.
							*pluginkiller-PKnfm*
	:PKnfm	This command is like :PK except that no function maps are
		produced
		(ie. no ctrl-f1 or ctrl-f2 maps, see |pluginkiller-funcmap|)
							*pluginkiller-PKr*
	:PKr	Resets the pluginkiller so that all of its problematic
		settings are enabled.
							*pluginkiller-PKg*
	:PKg	Used in the pluginkiller.vim window; you use this command
		to indicate to the pluginkiller that the current settings
		yielded good/expected/nominal behavior.
							*pluginkiller-PKb*
	:PKb	Used in the pluginkiller.vim window; you use this command
		to indicate to the pluginkiller that the current settings
		yielded bad behavior.

							*pluginkiller-PKB*
	:PKB	The pluginkiller backs up to the previous set of options.

							*pluginkiller-funcmap*
							*pluginkiller-fm*
	<c-f1>	same as :PKg (makes normal mode and insert mode maps)
	<c-f2>	same as :PKb (makes normal mode and insert mode maps)
		Also see |g:pluginkiller_nofuncmap|

							*pluginkiller-nofuncmap*
	g:pluginkiller_nofuncmap	If this variable exists, then no
		function maps will be made (ie. no ctrl-f1 or ctrl-f2 maps)

==============================================================================
3. Pluginkiller Usage					*pluginkiller-usage*

	The PluginKiller helps Vim plugin writers determine which options that
	their users might set that will cause problems with their plugin before
	their users do!

	To do this, the PluginKiller utilizes two instantiations of vim.  The
	first vim is your working vim; in it you normally startup and exercise
	your plugin.  The second one (see Step 1 below) is the pluginkiller
	server; it keeps a copy of the current potential trouble-making
	options.

	Whenever your plugin works satisfactorily with the currently active
	trouble-makers shown in the PluginKiller gvim, type :PKg (for
	PluginKiller-good) (or <ctrl-f1> if function maps are available).
	This tells the PluginKiller server about the nice set of options it
	selected, and it responds with a new set.

	On the other hand, whenever your plugin isn't performing up to your
	exacting specifications, type :PKb (for PluginKiller-bad) (or
	<ctrl-f2> if function maps are available).  This command tells the
	PluginKiller server about the trouble it caused, and the PluginKiller
	responds with a smaller set of potential troublemakers.

	You'll need to repeat trying out your plugin and typing :PKg or :PKb
	until the PluginKiller has found the culprit option.  Its OK to quit
	the first vim where you're exercising your plugin; if you do, use :PK
	to resume working with the PluginKiller server -- whether you need to
	quit and resume depends on how your plugin operates -- :PK just
	reloads the current settings that the PluginKiller wants to have tried
	out.

						*pluginkiller-steps*
	Step 1: Bring up vim with a test file where you can exercise your
		plugin with the pluginkiller.  Type >
		 vim some_test_file
		 (do whatever you need to do, if anything, to load your new plugin)
		 :PK
<		The :PK command sets up the pluginkiller server window; it will
		show >
			" Plugin Killer Testing Options: start
<		at the top of the screen in the server, followed by a number
		of options that often cause problems with plugins.

	Step 2: In the vim holding the test file (NOT the pluginkiller
		server):

			UNTIL a message pops up about what option your plugin
			      is having a problem with:

			      Exercise/run your plugin

			      IF your plugin worked, type >
				:PKg
<			      Otherwise, type >
				:PKb
<
		Note that you may have to type >
			ctrl-o :PKg
<		-or-  >
			ctrl-o :PKb
<		to get the commands to work if you seem to be stuck in insert
		mode.

		The :PKg (for good plugin behavior) and the :PKb (for bad
		plugin behavior) commands implement a binary search technique
		to determine which option is giving your plugin trouble.  If,
		as may sadly be the case, more than one such option is giving
		your plugin fits, you may have to run through this process
		several times.

		What I usually do is create two functions that look something
		like this: >

			fun! s:SaveUserSettings()
			  let b:keep_optionname= &optionname
			  ...
			  setlocal [no]optionname
			endfun
			fun! s:RestoreUserSettings()
			  let &l:optionname= b:keep_optionname
			endfun
<
		At the top of any function in my plugin that's being called, I
		call the s:SaveUserSettings() function.  This function saves
		the user's current settings that caused my plugin difficulties
		and then sets them to something that doesn't.  Before any
		return and the end of the function I call
		s:RestoreUserFunctions(), which, of course, restores the
		user's settings.

		The l:optionname is the local version of the option, and the
		setlocal means I only change the local option to support my
		plugin.

==============================================================================
4. Installing the PluginKiller				*pluginkiller-install*

	First, you really _don't_ want to install the pluginkiller in your
	normal .vim/plugin directory.

	1. You will need vimball v18 or later; you can get it from

		http://mysite.verizon.net/astronaut/vim/index.html#VimFuncs
		as "Vimball Archiver", or from
		http://vim.sourceforge.net/scripts/script.php?script_id=1502

	   Be sure to remove all vestiges of any earlier vimball versions
	   such as comes with vim 7.0: typically, that means, as superuser: >

	   	cd /usr/local/share/vim/vim70
		/bin/rm plugin/vimball*.vim
		/bin/rm autoload/vimball*.vim
		/bin/rm doc/pi_vimball.txt
<
	2. vim pluginkiller.vba.gz
	   :so %
	   :q

	   This will create >
	   	PluginKiller/
		     |- pluginkiller.vim
		     \- pluginkiller
		doc/
		     \- pluginkiller.txt
<
	The directions under |pluginkiller-steps| give detailed information on
	how to use the pluginkiller.

	2. Enable the help: >
	   	:helptags ~/.vim/doc
<

==============================================================================
5. PluginKiller History					*pluginkiller-history*

	v4  Apr 15, 2010 * Complete re-write, and new :PKB command
			   Now uses lists.  The remote PLUGINKILLER
			   window now holds only the settings under
			   test, and is separate from the pluginkiller.vim
			   plugin itself.
	v3  Oct 10, 2007 * added more options for pluginkiller checkout:
	                   acd, insertmode, num, spell
	v2  May 01, 2006 * the acd option is not always defined
	    Oct 19, 2006 * :PK will initialize the PLUGINKILLER
	                   server automatically, as required.
   	v1  Mar 08, 2006 * initial release


vim: ts=8
