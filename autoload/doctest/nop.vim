" doctest#nop

fun! s:SID() "{{{
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun "}}}
fun! doctest#nop#SID() "{{{
    return s:SID()
endfun "}}}

