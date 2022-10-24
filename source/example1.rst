Introduction and problem statement
==================================

It is **really hard** to maintain a documentation or laboratory instruction up to date
when all the resources and APIs are constantly changing. Whenever there is 
some breaking change in API used in examples or a link to download some 
binaries is invalidated because maintainer hosts them in different place now, 
the instruction reader, a person new to the subject will obviously be confused and lost.
At this point, supervisor will have to be involved and resolve the problem, often
during precious laboratory time. 

In this small side project I tried to use DevOps tools to aid mentioned issues.

Particular issues that all documentation or instructions face:

* Invalid links
* Code snippets typos
* Code snippets logic errors
* Code snippets being outdated / deprecated because of some library API update

My proposed solution to the issues would be to use Sphinx (or any other 
documenting framework) within CI and supplement it with more general tools, like
RobotTestingFramework.

Advantages of using CI with Sphinx and other DevOps tools:

* Sphinx by default uses reStructuredText - range of usefull features, clean formatting and instructions structure tree
* reStructuredText can be **compiled into HTML and embeded as a static website** (like EAD instructions_)
* Sphinx provides range of usefull features apart from clean formatting like **links validation and code snippets validation**
* Process of building instructions into HTML and then testing their contents can be **automated** in CI (Continous Integration)
* If tests of were performed in CI, they could be done on **daily basis**, which means that automated tests would catch errors before students do (avoiding students confusion when examples or link in instruction that is not working)
* **When a daily test fails it can send a prompt to the maintainer that there is an issue that needs to be fixed**
* This format is easy to modify and extend
* Anything that cannot be done in Sphinx can be done with RobotTestingFramework
* All instructions will have uniform and connected look

**I would say that the biggest takeaway would be effortless testing on a daily 
basis, which would ensure that most of the problems could be identified and 
resolved before actuall laboratory class.**

.. _instructions: https://jug.dpieczynski.pl/lab-ead/Lab%2000%20-%20Wst%C4%99p.html

Hyperlinks testing
==================

Sphinx can check validity of links during build:

..  code-block:: bash
    :caption: Validate external links
    
    $ sphinx-build -E -W -b linkcheck source build

External valid link_ to test in CI (EAD laboratory instruction).

Any invalid link will cause an error during build. Link may become invalid because for 
example package maintainer changed name of the package or binaries that student 
was suppose to download are now hosted in different place.

.. _link: https://jug.dpieczynski.pl/lab-ead/Lab%2002%20-%20SQL,%20RESTful%20API.html

Testing embedded code snippets
==============================

Sphinx actually allows for testing_ code snippets:

.. code-block:: bash
    :caption: Perform code snippets tests

    $ sphinx-build -E -W -b doctest source build/doctest

.. _testing: https://www.sphinx-doc.org/en/master/usage/extensions/doctest.html

Test simple print statement
---------------------------

Bellow snippet is actually executed and output is tested during build:

.. testcode::

    print("Hello")

.. testoutput::
   
    Hello

Test complex code blocks with use of external modules
-----------------------------------------------------

We can embed and **test** more complex code blocks with imported modules without much effort:

.. testsetup:: *
     
    import numpy as np


.. testcode::
   
   def modify_array(arr):
       arr[0] = 4
       return arr
   print(modify_array(np.array([1, 2, 3])))

.. testoutput::

   [4 2 3]

All we need to do is to encapsulate the code snippet in special directive and
we can be sure that the code example we provided works as expected.

Testing APIs
============

This example is suppose to ilustrate a use of Github Actions Secrets to test
access to resources where authorization is necessary and we do not want to
share private credentials in public repository. Code in those examples is **not**
executed during Sphinx build, but in GitHub Actions CI. This example also 
ilustrates how we can supplement Sphinx with other DevOps tools.




Testing with RobotTestingFramework
==================================
