doctest.vim
===========

**So, Test Vim with DocTests**

::

    " >>> let a = 3
    " >>> echo a-2
    " 1

    " >>> echom AN_UNDEFINED_VARIABLE
    " E121

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

**Command**

``:DocTest [file]``

Test file's vim docs.
if file is empty, then test current file,
if '!' is added , then verbose level set to 1.

To catch error , use it's error number like ``E100``.

**Option**

``g:doctest_verbose_level``

default is 0.
set it to 1 to see more info.

**API**

``doctest#start([input_file, [out_putfile, [verbose_level]]])``

Returns the test result, you can use in your scripts



**Test vim file**

.. code:: vim

    if expand('<sfile>:p') == expand('%:p') "{{{
        call doctest#start()
    endif "}}}

then use ``:so %`` to test.
