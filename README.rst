doctest.vim
===========

:version: 0.9

Let's start a doctest.

::
    
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

With ``:DocTest``,  result would be::

    Try::line 9        PASS!
    Try::line 15       PASS!
    Try::line 19       PASS!
    Try::line 25       PASS!
 
    Total: 4 tests.
    Passed:4 tests.
 
    Takes: 0.0037 seconds 

So Test Passed , Great! :) 

**Command**

``:DocTest[!] [input_file] [output_file]``

Test file's vim docs.

If file is empty or '%', test current file,
If '!' is added , verbose level is 1.


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
