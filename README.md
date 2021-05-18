# hpctools
Bash and bash tools for slurm, munge, and git

Here is a summary of what is in each file:

## .bashrc

In large part, this file contains shortcuts for `bash` that are
designed to make your life easier in the HPC and other environments. 
Most of the shortcuts will give an explanation of how they are 
best used if you just type the name of one, but ... how are you
to know what is in the file? Here is a list of some of the most
commonly used ones, although the reader should keep in mind 
that many others can be discovered by looking in the file, itself.

- addhere : adds the present working directory to the end of the PATH
- back : cd to the previous directory (or further)
- cd : changed to create a stack of directories so that you can backup through places you have been.
- cdd : cds to a directory that might be buried several dirs down.
- cdshow : shows where all you have been before now (in the present session).
- clonedirsto : copies the empty directory structure on one file system to another file system.
- delhere : removes the present working directory from the PATH (if it is present at all).
- e : edit the most recently changed file in this directory.
- findq : find without all the errors cluttering the screen.
- fixperms : removes superfluous execute access from files that are not executable.
- hg : combines history with grep.
- isrunning : checks to see if a program is running
- myscreen : prints a message about the size of the current terminal window
- pyaddhere : adds the present working directory to PYTHONPATH
- pydelhere : removes the present working directory from PYTHONPATH
- reload : reloads the environment
- showpipes : shows open pipes
- showsockets : shows open sockets
- up : cd up a directory (or more)

## git.bash

