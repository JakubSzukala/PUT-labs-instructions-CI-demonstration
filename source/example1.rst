Introduction and problem statement
==================================

It is **really hard** to maintain a documentation or laboratory instruction up to date
when all the resources and APIs are constantly changing. Whenever there is
some breaking change in API used in examples or a link to download some
binaries is invalidated because maintainer hosts them in different place now,
the instruction reader, a person new to the subject will obviously be confused and lost.
At this point, supervisor will have to be involved and resolve the problem, often
during precious laboratory time.

In this small side project I tried to use DevOps (CI, in cloud documentation
building, testing frameworks) tools to aid common issues
occuring in documentation and laboratory instructions. I tried to provide simple
solution that will be:

* practical
* will provide good results
* not overwhelming to introduce

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
* If tests were performed in CI, they could be done on **daily basis**, which means that automated tests would catch errors before students do (avoiding students confusion when examples or link in instruction is not working)
* **When a daily test fails it can send a prompt to the maintainer that there is an issue that needs to be fixed**
* Maybe, going even further, there could be a badge or status link in laboratory course page that students could use to check if the documentation passed all tests
* Sphinx with reStructuredText is easy to modify and extend
* Anything that cannot be tested in Sphinx can be tested with RobotTestingFramework (or other tools)
* All instructions will have uniform and connected look
* We avoid dreaded "It works on my machine" scenarios

**I would say that the biggest takeaway would be effortless testing on a daily
basis, which would ensure that most of the problems could be identified and
resolved before actuall laboratory class.**

.. _instructions: https://jug.dpieczynski.pl/lab-ead/Lab%2000%20-%20Wst%C4%99p.html

.. image:: _static/cat.png

Testing description
===================

Below I present basic tests examples, structure and rationale behind using
those. Each paragraph contains also a link to the implementation of of described
solution in this repository.

Hyperlinks testing
------------------

What is the problem?
Invalid links are annoying to the end user and delay the work of entire laboratory group.

What is the solution?
Sphinx has built in feature to test validity of the links during the build process.

How to perform this solution?
To perform such tests it is enough to run from command line following command:

.. code-block:: bash
    :caption: Validate external links

    $ sphinx-build -E -W -b linkcheck source build

External valid link_ that will be tested in CI (EAD laboratory instruction).

Any invalid link will cause an error during build. Link may become invalid because for
example package maintainer changed name of the package or binaries that student
was suppose to download are now hosted in different place.

See the CI `job for hyperlinks testing`_ in this repository for details.

.. _link: https://jug.dpieczynski.pl/lab-ead/Lab%2002%20-%20SQL,%20RESTful%20API.html
.. _job for hyperlinks testing: https://github.com/JakubSzukala/PUT-labs-instructions-CI-demonstration/blob/main/.github/workflows/actions.yml#L28-L42

Testing embedded code snippets
------------------------------

What is the problem?
Code snippets are essential for understanding and getting familiar with educational
materials and it is crucial that they have correct syntax, are logically correct
and are up to date with the required API version. Incorrect code snippets introduce
confusion and delay.

What is the solution?
Sphinx can execute embedded Python code blocks / snippets and validate their output.
See documentation_ on how to create such blocks in reStructuredText.

How to perform this solution?
Code blocks execution is performed during Sphinx build process and we can run it
with following command:

.. code-block:: bash
    :caption: Perform code snippets tests

    $ sphinx-build -E -W -b doctest source build/doctest

.. _documentation: https://www.sphinx-doc.org/en/master/usage/extensions/doctest.html

In general, to perform such test we have to create two blocks:

* One with the code we want to present to the reader and execute it during test
* Second block with expected output

See the CI `job for code snippets testing`_ in this repository for details and `source code`_ for this document to see syntax of these blocks.

.. _source code: https://raw.githubusercontent.com/JakubSzukala/PUT-labs-instructions-CI-demonstration/main/source/example1.rst
.. _job for code snippets testing: https://github.com/JakubSzukala/PUT-labs-instructions-CI-demonstration/blob/main/.github/workflows/actions.yml#L44-L61

Test simple print statement
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tested code block:

.. testcode::

    print("Hello")

Expected output, validated during build:

.. testoutput::

    Hello

Test complex code blocks that use external modules
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

We can embed and **test** more complex code blocks with imported modules without much effort:

.. testsetup:: *

    import numpy as np

.. testcode::

   def modify_array(arr):
       arr[0] = 4
       return arr
   print(modify_array(np.array([1, 2, 3])))

Expected output, validated during build:

.. testoutput::

   [4 2 3]

Testing resources with authorization
------------------------------------

What is the problem?
Some resources may require more complex setup and some credentials authorization.
For example, accessing resources via REST API that is protected with API key.
API share point may change, the output may change and this can again lead to
confusion among the students.

What is the solution?
We can test access to resource like REST API with range of tools, with the simplest
being curl. The problem is that when doing that in CI, we do not want to share
our credentials so we have to use GitHub Secrets_. We can think of those like
environment variables that are set for the repository and can be accessed during
CI, but they are encrypted and safe.

How to perform this solution?
We have to add a Secrets_ then in actions.yml file we can write:

.. _Secrets: https://docs.github.com/en/actions/security-guides/encrypted-secrets#using-encrypted-secrets-in-a-workflow

.. code-block:: yaml
   :caption: Curl example with GH Secrets

   env:
       WEATHER_API_KEY: ${{ secrets.WEATHER_API_KEY1 }}
   (...)
   run: |
       curl --fail "https://api.openweathermap.org/data/2.5/weather?lat=44.34&lon=10.99&appid=${WEATHER_API_KEY}"

This will make an API call with API key restored from GitHub secrets.

See the CI `job for testing authorized access`_ for details.

.. _job for testing authorized access: https://github.com/JakubSzukala/PUT-labs-instructions-CI-demonstration/blob/main/.github/workflows/actions.yml#L63-L69

More general and structured test with RobotTestingFramework
-----------------------------------------------------------

What is the problem?
From previous point we can see that not everything may be tested with just Sphinx.
In some occassions we may want to test some very general thing so we need a tool
for that. Obviously, as we discuss docs CI, **we do not want to test too much.**
This is because diminishing returns will cause that we will make more tests and
reward for that will be minimal. So we want a sweet spot, where we maximize ratio
of reward to effort.

What is the solution?
There are many tools, but one I'm familiar with is RobotTestingFramework.

How to perform this solution?
We need to create a tests suite according to docs_. Below we test again
access the key protected API.

.. _docs: https://robotframework.org/

.. code-block:: bash
   :caption: Bash command to run below test and pass arguments to the environment

   robot --variable WEATHER_API_KEY:${WEATHER_API_KEY} -d build/robot robot-tests/api_test.robot

.. code-block:: robotframework
   :caption: RobotTestingFramework example of more general operations

    *** Settings ***
    Library               RequestsLibrary

    *** Test Cases ***
    Quick Get Request With Parameters Test
        ${response}=    GET  https://www.google.com/search  params=query=ciao  expected_status=200

    Test API with robot
        ${response}=    GET  url=https://api.openweathermap.org/data/2.5/weather?lat=44.34&lon=10.99&appid=${WEATHER_API_KEY}  expected_status=200

See the CI `job for testing with robotframework`_ for details.

.. _job for testing with robotframework: https://github.com/JakubSzukala/PUT-labs-instructions-CI-demonstration/blob/main/.github/workflows/actions.yml#L71-L85

Summary
=======

Basically anything that is headless can be tested. Obviously, not anything has to
be, so it is important to make some rational borders.
