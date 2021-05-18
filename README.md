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

- `addhere` : adds the present working directory to the end of the PATH
- `back` : cd to the previous directory (or further)
- `cd` : changed to create a stack of directories so that you can backup through places you have been.
- `cdd` : cds to a directory that might be buried several dirs down.
- `cdshow` : shows where all you have been before now (in the present session).
- `clonedirsto` : copies the empty directory structure on one file system to another file system.
- `delhere` : removes the present working directory from the PATH (if it is present at all).
- `e` : edit the most recently changed file in this directory.
- `findq` : find without all the errors cluttering the screen.
- `fixperms` : removes superfluous execute access from files that are not executable.
- `hg` : combines history with grep.
- `isrunning` : checks to see if a program is running
- `myscreen` : prints a message about the size of the current terminal window
- `perms` : shows the nested permissions all the way up to `/`.
- `pyaddhere` : adds the present working directory to PYTHONPATH
- `pydelhere` : removes the present working directory from PYTHONPATH
- `reassign` : reassign a sym link, making sure that the things you are working with are links.
- `reload` : reloads the environment
- `showpipes` : shows open pipes
- `showsockets` : shows open sockets
- `up` : cd up a directory (or more)
- `viremote` : use vim to edit a file on another file system.

## git.bash

Let's admit that no one can remember all the git commands, even if you
use git every day. These are simplifications of the most common commands.

- `add` : add a file to the repo.
- `blame` : runs blame, with a nicely formatted report.
- `checkout` : instead of `git checkout`.
- `commit` : commit everything that is staged, open the editor to type the message, and make it so.
- `currentbranch` : just in case you forget?
- `currentcommit` : shows info about the currently checked out commit.
- `discard` : blows away your changed but not committed files. (compare with stash)
- `ffcommit` : commit and push
- `forget` : remove a file from the repo, but not from the file system.
- `gdiff` : like diff, but using git.
- `ghist` : print out a nice graph showing how the branches intertwine and what has been done.
- `gitbranchlrt` : show all the branches in the repo in the reverse order in which they have been last modified.Similar to `ls -lrt`.
- `githome` : cd to the top level directory of this repo.
- `makebarerepo` : convert the current repo to an archival, remote-like repo for use by someone else.
- `prune` : remove a branch from the local repo and the remotes.
- `retag` : change the name of a tag without changing what is tagged.
- `showauthor` : find all the commits by a particular person.
- `showrepo` : show the contents of the repo.
- `stash` : stashes the changed but not committed files for later use.
- `status` : show the mess you have made of things.
- `tag` : give your changes a cool name
- `workflowhelp` : explain a little bit about the order of operations.

