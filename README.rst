doctest.vim
===========

:version: 0.9

So, Let's start a doctest::
    
    " A simple one
    " >>> let a = 3
    " >>> let b = 3
    " >>> echo a+b
    " 6

    " Catching error, use ErrorNumber like 'E100'.
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

    " Even Script-vars s:

    " >>> let s:k = 5
    " >>> fun! s:test(i)
    " >>>   return printf("%07d",a:i+s:k)
    " >>> endfun
    " >>> echo s:test(3000)
    " 0003005

With ``:DocTest``,  result would be::

    Try::line 11       PASS!
    Try::line 17       PASS!
    Try::line 21       PASS!
    Try::line 26       PASS!
    Try::line 34       PASS!
 
    Total: 5 tests.
    Passed:5 tests.
 
    Takes: 0.0037 seconds 

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


**Test vim file**

In your file, add following code.

.. code:: vim

    if expand('<sfile>:p') == expand('%:p') "{{{
        call doctest#start()
    endif "}}}

Use ``:so %`` to test.

