.. _Reproducibility-Framework:

Reproducibility Framework (RF)
##############################

Analysis data usually involves the use of many software packages and in-house software. For each analysis step, there are many software tool options available, each with its proper capabilities, restrictions, and assumptions on input and output data.

The pipeline development, e.g. the application of Bioinformatics, involves a lot of experimentation with different tools and parameters, considering how well each is suited to the big picture and the practical implications of its use, organizing data analysis can be challenging.

In this tutorial, a set of methods and code examples are used to train the user on how to install and experiment extensively, keeping the healthy reproducible and organized in an intuitive way to organize computational analyzes using a directory structure constructed according to 3 simple principles.

  1. Use of a directory structure to represent dependencies between analysis steps.

  2. Separation of user-generated data from program-generated data.

  3. Use of driver scripts.

These 3 principles are desirable to help keep analysis organized, reproducible, and easier to understand.

The data analysis is structured in a way that emphasizes reproducibility, organization, and clarity. Being simple and intuitive, adding and modifying analysis steps can be done easily with little extra effort.

.. note::
  This framework supports containers, docker and :ref:`singularity <singularity_container>`.

How to set up the framework on the system run Steps 1 and 2.

**Step 1** : Install the Reproducibility Framework (rf) on Rockfish

Follow the preprint to install the ``rf`` on Linux. Make sure do you have a python 3.6 (preferably 3.6.2 or later) installed.

Then, run ``rf --help`` and ``rf run --help`` to verify the installation.

.. code-block:: console

  $ pip3 install git+git://github.com/apuapaquola/rf.git --upgrade --user
  $ rf --help
  $ rf run --help

**Step 2** : Install the tree command for non-root users

To support the framework functionalities, it is necessary to install the tree command on GNU/Linux or macOS (brew install tree). If you do not have permission to install it on the system (root), you must install the tree command as a non-root user.

.. code-block:: console

  $ curl -OL https://raw.githubusercontent.com/ricardojacomini/rf/master/scripts/install_tree_non_root.sh
  $ rm install_tree_non_root.sh (optional)
  $ rf status
  $ rf status -p

Consider the following directory structure:

.. code-block:: console

  1.  $ tree
      ├── nodeA
      │   ├── _h         (human-generated data)
      │   ├── _m         (machine-generated data)
      │   └── nodeB
      │       ├── _h
      │       ├── _m
      │       └── nodeC
      │           ├── _h


**Principle 1** Each node has two special subdirectories: ``_h`` and ``_m`` with well-defined purposes. The documentation, codes, and other human-generated data that describe this analysis step are put in the _h directory. For this reason, it is called _h the "human" directory. Likewise, the _m directory store the computation results of this analysis step. For this reason, it is called _m the "machine" directory.

**Principle 2** In the "human" directory is required a file named run. It is a script that is supposed to be performed without arguments. It is responsible to call the necessary programs that will do the computation in the analysis step and generate the contents/results on _m, "machine" directory.

**Principle 3** A directory structure is an intuitive way to represent data dependencies. Let's consider you are at any _m directory looking at output files, and you examine how these results were generated. A pwd command will display the full path to that directory, which has a sequence of names of analysis steps involved in the generation of these files.

The separation of computer-generated data from human-generated data is also helpful. It is a way to make sure that users may not edit output files. It is also useful to know which files are program-generated and know which files are OK to delete, given they can be computed again.

Running driver scripts without arguments is a way to make sure computation doesn't depend on manually specified parameters, which are easy to be forgotten.


Version control
***************

The division of human-generated data ( ``_h`` ) from machine-generated data ( ``_m`` ) makes it easy to use version control systems for an analysis tree.

In the current implementation, it is used git for _h  and git-annex for _m.

The ``rf`` command provides a wrapper for some operations that involve more than one call to git or git-annex. Users can collaborate and share analyses trees in a similar they can do with code.

The version control is not covered in this tutorial, see the `Preprint`_ for more details.

.. _Preprint: http://biorxiv.org/content/early/2015/12/09/033654

Tutorials
**********

**Tutorial 1.1** : Runs driver scripts to generate the _m directories (results/contents)

Let's create a directory structure called repro to put this Reproducibility Framework (``rf``) into practice.

Let’s create a simple run file to learn how ``rf`` works. Then, change the permissions on the run file to make it executable (row # 5). Once it has been assigned, the run file is ready to be executed using the ``rf`` command (``row # 8``).

.. note::
  Since ``rf`` was designed to work collaboratively and have version control, it is necessary to create a new Git repository local (row # 9).

.. code-block:: console

  1.  $ mkdir tutorials/repro/_h -p
  2.  $ cd tutorials/repro/
  3.  $ echo "date > date.txt" > _h/run
  4.  $ rf status
  5.    .  no run script
  6.  $ chmod +x _h/run
  7.  $ rf status
  8.    .   ready to run
  9.  $ git init .
  10. $ rf run .          # use: ( nohup rf run . & ) to 11. run the rf immune to hangups
  12. $ rf status
  13.   .           done
  14. $ ls _m/*
  15.   _m/date.txt  _m/nohup.out  _m/SUCCESS

**Tutorial 1.2** : Runs driver scripts to generate the _m directories (results/contents) via containers

.. code-block:: console

  1.  $ mkdir -p bedtools/_h
  2.  $ cd bedtools/

Let's fire up our text editor (vim/nano/emacs) and type in our bedtools1 script as follows:

.. code-block:: console

  1.  $ vi _h/run
  2.
  3.  #!/bin/bash
  4.  set -o errexit -euo pipefail
  5.
  6.  bedtools genomecov -i ../_h/exons.bed -g ../_h/genome.txt -bg > out.tsv
  7.
  8.  $ chmod +x _h/run

If you return a level (repro directory) and check the execution status of this pipeline (``rf status``), you can see that step 1 (repro) is done, and step 2 (``bedtools``) is ready to run. It is important to mind will be run the ``bedtoots`` via container (singularity).

.. note::
  It is important to note our purpose here is to use a container to isolate programs and not develop or share scripts within the container images. Keep it as simple as possible, and all scripts will be performed via the ``rf`` command, as will be shown below.

.. code-block:: console

  1.  $ cd ..
  2.  $ rf status
  3.    .                      done      (step 1 of the pipeline)
  4.    └── bedtools   ready to run      (step 2 of the pipeline)