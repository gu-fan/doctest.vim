doctest.vim
===========

    Besides TDD & BDD , What about DDD (Doc Driven Dev) :)

    -- doctest.vim

:version: 0.95

So, Let's start a doctest::
    
    " A simple one
    " >>> let a = 3
    " >>> let b = 3
    " >>> echo a+b
    " 6

    " Catching error.
    " (NOTE:use ErrorNumber like 'E100')
    " >>> echom an_undefined_variable
    " E121
    
    " Multi row output
    " >>> echo "3\n3"
    " 3
    " 3

    " Define a function!
    " >>> fun! TestNum(i)
    " >>>   return printf("%06d",a:i)
    " >>> endfun
    " >>> echo TestNum(3000)
    " 003000

    " s:vars and s:fn()
    " >>> let s:k = 5
    " >>> fun! s:test(i)
    " >>>   return printf("%07d",a:i+s:k)
    " >>> endfun
    " >>> echo s:test(3000)
    " 0003005

    " Timing something
    " (NOTE: no s:fn function in timer)
    " >>> fun! Work()
    " >>>   let a = 342349.3429*123499.34239/3438923.43
    " >>> endfun
    " >>> call doctest#timer("Work", [], 10000)
    " [TIMER]

With ``:DocTest``,  result would be::

    Try::line 9        PASS!
    Try::line 16       PASS!
    Try::line 20       PASS!
    Try::line 25       PASS!
    Try::line 32       PASS!
    [TIMER] line 41    
    [TIMER] 0.0637 seconds for exec Work 10000 times. 
     
    Total: 5 tests.
    Passed:5 tests.

    Total Time: 0.0658 seconds 
     

Test Passed, Great! :) 

**Command**

``:DocTest[!] [input_file] [output_file]``

DocTest with file.

If file is empty or '%', test current file ,
If '!' is added, verbose level is 1.

**Option**

``g:doctest_verbose_level``

Default is 0.
Set it to 1 to see more info.

**API**

``doctest#start([input_file, [output_file, [verbose_level]]])``

Returns a object with test result 

``doctest#timer(func_name, [[func_arg_list, [exe_time]]])``

Execute func_name with func_arg_list by exe_time.


**Test vim file**

In your file, add following code.

.. code:: vim

    if expand('<sfile>:p') == expand('%:p') "{{{
        call doctest#start()
    endif "}}}

Use ``:so %`` to test.

