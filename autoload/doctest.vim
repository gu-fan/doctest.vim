"=============================================
"    File: doctest.vim
"  Author: Rykka <rykka#foxmail.com>
"  Update: 2014-08-07
"=============================================
let s:cpo_save = &cpo
set cpo-=C
let s:test =123123
" Example " {{{3
"
" >>> echo 5+1
" 6
"
" will return:
" Try:
"   1+1
" Expected:
"   2
" ok
"
" ----------
"
" >>> echo 1+1*1.5
" 2.5
"
" will return:
" Try:
"   1+1
" Expected:
"   3
" Got:
"   2
" Failed
"
" ----------
"
" >>> echom AN_UNDEFINED_VARIABLE
" E121
"
" Try:
"   echo AN_UNDEFINED_VARIABLE
" PASS!
"
" ----------
"
" >>> echo 1+1=3
" 2
" E15
"
" Try:
"   echo 1+1=3
" Expected:
"   2
"   E15
"
" ----------
"
" >>> let a = 3
" >>> let b = 4
" >>> echo a+b
" 7
"
" Try:
" let a = 3
" let b = 4
" echo a+b
" PASS!
"

let s:test = 1

" >>> echo s:test
" 1

fun! s:test()
    return 1
endfun

" >>> echo s:test()
" 1

" DocTest {{{1
fun! s:auto_mkdir(path) "{{{
    if !isdirectory(fnamemodify(a:path,':h'))
        call mkdir(fnamemodify(a:path,':h'),'p')
    endif
endfun "}}}
fun! s:is_cmd_line(line) "{{{
    return a:line =~ '^\s*"\s>>>\s'
endfun "}}}
fun! s:is_expc_line(line) "{{{
    return a:line =~ '^\s*"\s*\S'
endfun "}}}
fun! s:is_end_line(line) "{{{
    return a:line =~ '\s*"\s*$' || a:line !~'^\s*"'
endfun "}}}
fun! s:get_plain_cmd(cmd_line) "{{{
    let cmd_line = "    ". matchstr(a:cmd_line, '^\s*"\s>>>\s\zs.*')
    " change s: func to <SNR>_XXX
    " change s: var to g:_SNR.XXX
    
    let n = g:_SNR.N
    let cmd_line = substitute(cmd_line, '\(^\|\W\)\zss:\ze\(\w\+(\)\@=','<SNR>'.n.'_', 'g')
    " XXX: '\_s' here not work, use '$\|\s' works
    let cmd_line = substitute(cmd_line, '\(^\|\W\)\zss:\ze\w\+\(\W\|$\)\@=','g:_SNR.'.n.'.', 'g')
    return cmd_line
endfun "}}}

fun! s:get_plain_expc(expc_line) "{{{
    return "    ". matchstr(a:expc_line, '^\s*"\s\zs.*')
endfun "}}}

fun! doctest#cmd(bang,...) "{{{
    " Use for cmd with <bang>
    let input_file = a:0 ? a:1 : ""
    let output_file =  a:0 > 1 ? a:2 : ""
    let verbose = a:bang =='!' ? 1 : g:doctest_verbose_level
    call doctest#start(input_file,output_file,verbose)
endfun "}}}

let s:tempfile = tempname()
let s:tempdir = fnamemodify(s:tempfile, ':p:h')
let g:_SNR= {}
fun! doctest#nop()
endfun
fun! s:sub_nop(line) "{{{
    return substitute(a:line, 'doctest#start', 'doctest#nop','g')
endfun "}}}
fun! s:hook_var(lines) "{{{
    let lines = map(a:lines,'s:sub_nop(v:val)')
    let hook = ["fun! s:SID()",
        \"return matchstr(expand('<sfile>'), '<SNR>\\zs\\d\\+\\ze_SID$')",
        \"endfun",
        \"let g:_SNR.N = s:SID()",
        \"let g:_SNR[s:SID()] = s:",
        \]
    return extend(lines, hook)
endfun "}}}
fun! doctest#start(...) "{{{
    " Test with the document.
    "
    " @params:
    " a:1 input file or current buffer, empty for current buffer
    " a:2 output file or message , empty for messgae
    " a:3 verbose level (0,1)
    "
    " Exception will only needs it's ErrorNumber if it's vim exception
    " Exception will show when verbose level is 2
    "
    "

    " Init "{{{3

    let input_file = a:0 ? expand(a:1) : ''
    let input_file = input_file=='' ?  expand('%') : expand(input_file)
    let output_file =  a:0 > 1 ? expand(a:2) : ""
    let verbose = a:0> 2 ? a:3 : g:doctest_verbose_level
    let lines = readfile(input_file) 
    
    " if ft is vim , source it to get 's:' vars and fns
    " Dont's source myself or run doctest#start
    if input_file == 'doctest.vim'
        let g:_SNR.N = s:SID()
        let g:_SNR[s:SID()] = s:
    elseif input_file =~ '\.vim$\|\.vimrc$' 
        let lines = s:hook_var(lines)
        let fname = fnamemodify(input_file, ':t')
        let tmp_f = s:tempdir .'/'. fname
        call writefile(lines, tmp_f)
        exe "noa so ".tmp_f
    else
        let n = doctest#nop#SID()
        let g:_SNR.N = n
        let g:_SNR[n] = {}
    endif

    let eof = len(lines)
    let [b_bgn, b_end] = [0, 0]
    let test_blocks = []
    let test_results = []
    let test_logs = []
    let in_block = 0
    let in_cmd = 0

    " Get the test block "{{{3
    " [[CMDS1, EXPECTS1,startrow],[CMDS2,EXPECTS2,startrow],...]
    " CMDS and EXPECTS are a list with multi lines
    let e_cmds =  []
    let e_expects = []
    for i in range(eof)
        let line = lines[i]
        if !in_block
            if s:is_cmd_line(line)
                let in_block = 1
                let in_cmd = 1
                call add(e_cmds, line)
                let startrow = i+1
            endif
        elseif in_block
            if s:is_cmd_line(line)
                if in_cmd
                    call add(e_cmds, line)
                else
                    " Not in cmd block, save
                    call add(test_blocks, [e_cmds, e_expects,startrow])
                    " start a new test_block
                    let in_cmd = 1
                    let e_cmds =  [line]
                    let e_expects = []
                endif
            elseif s:is_end_line(line)
                let in_cmd = 0
                let in_block = 0
                call add(test_blocks, [e_cmds, e_expects, startrow])
                let e_cmds =  []
                let e_expects = []
            else
                call add(e_expects, line)
                let in_cmd = 0
            endif
        endif
    endfor

    let o_t = s:time()

    " Executing each Test Block and Redir the result "{{{3
    for [cmds, expects,startrow] in test_blocks
        let cmds = map(cmds, 's:get_plain_cmd(v:val)')
        let expects = map(expects, 's:get_plain_expc(v:val)')

        let result_str = ""
        let exception = ""
        let throwpoint = ""
        call writefile(cmds, s:tempfile)
        redir => result_str
        try
            sil exe 'so '.s:tempfile
        catch
            " To handle Exception easier
            let exception =  v:exception
            let e_num = matchstr(exception, '^Vim\%((\a\+)\)\=:\zsE\d\+\ze:')
            if e_num =~ 'E\d\+'
                " vim ErrorNumber
                sil echo e_num
            else
                sil echo exception
            endif
            let throwpoint =  v:throwpoint
        endtry
        redir END

        " format results
        let results = map(split(result_str,'\n'),'"    ".v:val')

        call add(test_results, {
                    \'cmds':cmds,
                    \'expects': expects,
                    \'results':results,
                    \'exception': exception,
                    \'throwpoint': throwpoint,
                    \'startrow': printf("%-6d",startrow)
                    \})
    endfor
    let e_t = s:time()

    " Validate "{{{3
    for item in test_results
        if item.expects == ['    [TIMER]']
            let item.status = 10
            let item.results[0] = substitute(item.results[0], '^\s*','','')
            continue
        endif
        if len(item.expects) == len(item.results)
            let item.status = 1
            for i in range(len(item.expects))
                if item.expects[i] == item.results[i]
                    continue
                else
                    let item.status = 0
                    break
                endif
            endfor
        else
            let item.status = 0
        endif
    endfor

    " Show Test Log "{{{3
    let output = []
    let failed = 0
    let passed = 0

    for item in test_results
        if item.status == 1
            if verbose == 1
                let o = ["Try::line ".item.startrow."   PASS!"]
                call extend(o, item.cmds)
                call add(o, "Expected:")
                call extend(o, item.expects)
                if item.exception =~ '\S'
                    call add(o, "Exception:")
                    call extend(o, [item.exception,item.throwpoint])
                endif
                call add(o, " ")
                call extend(output, o)
            elseif verbose == 0
                let o = ["Try::line ".item.startrow."   PASS!"]
                call extend(output, o)
            endif
            let passed += 1
        elseif item.status == 0
            if verbose == 1
                let o = ["Try::line ".item.startrow."   Fail!"]
                call extend(o, item.cmds)
                call add(o, "Expected:")
                call extend(o, item.expects)
                call add(o, "Got:")
                call extend(o, item.results)
                if item.exception =~ '\S'
                    call add(o, "Exception:")
                    call extend(o, [item.exception,item.throwpoint])
                endif
                call add(o, " ")
                call extend(output, o)
            elseif verbose == 0
                let o = ["Try::line ".item.startrow."   Fail!"]
                call add(o, "Got:")
                call extend(o, item.results)
                call extend(output, o)
            endif
            let failed += 1
        elseif item.status == 10
                let o = ["[TIMER] line ".item.startrow]
                if verbose == 1
                    call extend(o, item.cmds)
                endif
                call extend(o, item.results)
                call extend(output, o)
        endif
    endfor
    let total = failed + passed

    let time = printf("%.4f",(e_t-o_t))
    call add(output, " ")
    call add(output, "Total: ".total." tests.")
    call add(output, "Passed:".passed." tests.")
    if failed > 0
        call add(output, "Failed:".failed." tests.")
    endif
    call add(output, " ")
    call add(output, "Total Time: " . time . " seconds ")
    " Output to file or message "{{{3
    if output_file != ''
        call s:auto_mkdir(output_file)
        call writefile(output, output_file)
    else
        for out in output
            if out =~ '^\(\[TIMER\]\|Try:\|Expected:\|Got:\|Exception:\|PASS!\)'
                if out !~ 'Fail!$'
                    echohl PreProc
                    echo out
                    echohl Normal
                else
                    echohl Type
                    echo out
                    echohl Normal
                endif
            elseif out =~ '^Fail!$\|^Failed:'
                echohl ErrorMsg
                echo out
                echohl Normal
            elseif out =~ '^Total:\|^Passed:'
                echohl Title
                echo out
                echohl Normal
            else
                echo out
            endif
        endfor
    endif

    return {'results':test_results,'passed':passed,'failed':failed,'output':output,'total':total}
    "}}}3

endfun "}}}

" UnitTest {{{1

function! s:time() "{{{
    if has("reltime")
        return str2float(reltimestr(reltime()))
    else
        return localtime()
    endif
endfunction "}}}
function! doctest#timer(func,...) "{{{
    if !exists("*".a:func)
        echom "[TIMER] ".a:func." does not exists. stopped"
        return
    endif
    let farg = a:0 ? a:1 : []
    let num  = a:0>1 ? a:2 : 100

    let o_t = s:time()

    for i in range(num)
        sil! let rtn = call(a:func,farg)
    endfor
    let e_t = s:time()
    let time = printf("%.4f",(e_t-o_t))
    echom "[TIMER] " . time . " seconds for exec" a:func num "times. "

    return rtn
endfunction "}}}
let s:tempname = tempname()
fun! doctest#log(msg) "{{{

    let log =  "Time:". strftime("%Y-%m-%d %H:%M")
    " write time to log.
    let file = s:tempname
    if filereadable(file)
        let lines = readfile(file)
    else
        let lines = []
    endif
    call add(lines, log)
    if type(a:msg) == type([])
        call extend(lines, a:msg)
    else
        call add(lines, a:msg)
    endif
    call writefile(lines, file)
endfun "}}}
fun! doctest#view_log() "{{{
    exe 'sp ' s:tempname
endfun "}}}

fun! doctest#assert(val1, val2) "{{{
    if a:val1 == a:val2
        echo '1'
    else
        echo '0 $' a:val1
        echo '  >' a:val2
    endif
endfun "}}}

fun! doctest#func_args(func,arg_list) "{{{
    call s:test_func(a:func,a:arg_list)
endfun "}}}
fun! s:test_func(func,arg_list) "{{{
    echo "Func:" a:func
    for arg in a:arg_list
        echo "Arg:" arg
        if type(arg) == type([])
            echon "\t>" call(a:func, arg)
        else
            echon "\t>" call(a:func, [arg])
        endif
        unlet arg
    endfor
endfun "}}}

function! doctest#compare(func1,func2,num,...) "{{{
    if a:0==1
        echom doctest#timer(a:func1,a:1,a:num)
        echom doctest#timer(a:func2,a:1,a:num)
    elseif a:0==2
        echom doctest#timer(a:func1,a:1,a:num)
        echom doctest#timer(a:func2,a:2,a:num)
    else
        echom doctest#timer(a:func1,[],a:num)
        echom doctest#timer(a:func2,[],a:num)
    endif
    echom doctest#timer("doctest#stub0",[],a:num)
endfunction "}}}
function! doctest#stub0() "{{{
endfunction "}}}

fun! doctest#echo(l) "{{{
    if type(a:l) == type({})
        for [key,val] in items(a:l)
            echohl Question | echo key.':' | echohl Normal | echon  val
            unlet val
        endfor
    elseif type(a:l) == type([])
        for item in a:l
            echo item
            unlet item
        endfor
    else
        echo a:l
    endif
endfun "}}}

fun! doctest#show_obj() "{{{
    echo b:riv_flist[line('.')]
    if exists("b:riv_obj")
        echo b:riv_obj[line('.')]
    endif
endfun "}}}


fun! s:SID() "{{{
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun "}}}
fun! doctest#SID() "{{{
    return '<SNR>'.s:SID().'_'
endfun "}}}

function! doctest#stub1() "{{{
endfunction "}}}
function! doctest#stub2() "{{{
endfunction "}}}


" Testing "{{{1
if expand('<sfile>:p') == expand('%:p') "{{{
    call doctest#start()
endif "}}}

let &cpo = s:cpo_save
unlet s:cpo_save
