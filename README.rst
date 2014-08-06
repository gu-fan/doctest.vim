doctest.vim
===========

Let's start a DocTest

::

    " >>> let a = 3
    " >>> echo a-2
    " 1

    " To catch error , use it's error number like 'E100'.
    " >>> echom AN_UNDEFINED_VARIABLE
    " E121
    
    " multi row out put is ok
    " >>> echo "3\n3"
    " 3
    " 3

With ``:DocTest``,  result would be::

    Try::line 8        PASS!
    Try::line 12       PASS!
    Try::line 15       PASS!

    Total: 0 tests.
    Passed:3 tests.

    Takes: 0.0077 seconds

So it's Passed , Great! :) 

**Command**

``:DocTest[!] [file]``

Test file's vim docs.
if file is empty, then test current file,
if '!' is added , then verbose level set to 1.


**Option**

``g:doctest_verbose_level``

default is 0.
set it to 1 to see more info.

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
