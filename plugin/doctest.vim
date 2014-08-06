if !exists("g:doctest_verbose_level")
    let g:doctest_verbose_level = 0
endif
com! -bang -nargs=* DocTest :call doctest#cmd('<bang>',<f-args>)
