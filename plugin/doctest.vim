if !exists("g:doctest_verbose_level")
    let g:doctest_verbose_level = 0
endif
com! -bang -nargs=* -complete=file DocTest :call doctest#cmd('<bang>',<f-args>)
