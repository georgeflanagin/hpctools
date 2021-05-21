# hpctools: Shell scripts to support High Performance Computing

Bash tools for slurm, munge, and git. The tools cover the tedium of
installation and removal of these software packages.

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
- `fixperms` : removes superfluous execute access from files that are not executable, and sets the gid bit so that new files are created associated with the group of the directory.
- `hg` : combines history with grep.
- `installslurm` : installs SLURM! (and munge, too)
- `isrunning` : checks to see if a program is running
- `myscreen` : prints a message about the size of the current terminal window
- `perms` : shows the nested permissions all the way up to `/`.
- `pyaddhere` : adds the present working directory to PYTHONPATH
- `pydelhere` : removes the present working directory from PYTHONPATH
- `reassign` : reassign a sym link, making sure that the things you are working with are links.
- `reload` : reloads the environment
- `showpipes` : shows open pipes
- `showsockets` : shows open sockets
- `uninstallslurm` : removes SLURM and munge.
- `up` : cd up a directory (or more)
- `viremote` : use vim to edit a file on another file system.

## git.bash

Let's admit that no one can remember all the git commands, even if you
use git every day. These are simplifications of the most common commands.

### the prompt

The biggest advantage of the `git.bash` file is its use of the very 
informative prompt. It looks like this:

`[master][pistol(george):///anagrammatic]: `

- `master` : the name of the git branch you are on. If you are not in a dir managed by
git, nothing will be there.
- `pistol` : the hostname of the current server (minus all that domain stuff).
- `george` : the name of the user.
- `///` : how many directory levels down you are, in this case, 3.
- `anagramatic` : the name of present working directory.

Additionally, you might see some decorators that appear after the branch name.
They can all be present at once, so let's suppose the prompt looks like this:

`[master+!?][pistol(george):///anagrammatic]: `

- `+` : new files have been staged to be added to the repo on the next commit.
- `!` : a file already in the repo has been changed, but not committed.
- `?` : there is a file in the directory that is not a part of the project, and not specifically mentioned in the `.gitignore` file.

### the git shortcuts

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

## SLURM (and munge)

### installslurm.bash

```
Usage:
    installslurm [-i] [-c] [-v] [-s] {head | compute}

    This script will do its best to install and upgrade the
    slurm/munge environment on this node of the cluster. At
    the very least, you must specify whether this is to be
    compute node or the head node.

    If you type > ./installslurm.bash compute

    you will get a no-questions asked, installation from the
    standard packages, skipping the checks at the end.

    -i => interactive. The script will ask you whether you
        want to continue after each step.
    -c => perform sanity checks at the end.
    -s => from source; download the latest tarball, and recompile
        everything. Otherwise, we get packages from the repos,
        and start from that point.
    -v => verbose. Engage in haemorrhagic logorrhoea.
```

### installutils.bash

These are functions to support the [un]install operations with SLURM and munge.

- `confirm` -- confirms the next step for interactive, step-by-step installs
- `find_installer` -- locates the correct program to do the install, and names it `$dnf`.
- `v_echo` -- wrapper around echoes that are done only when verbose mode is engaged.
- `no_bash` -- returns true if this is not a bash shell.
- `no_sudo` -- returns true if this user does not have sudo.

The file also creates lists of packages that are required to support slurm and munge.

### slurm.bash

A file with a few, possibly "handy" shortcuts for the most common slurm 
operations. 

`nodes` : The nodes command allows you to get information about the
nodes in the cluster. The syntax is:

    `nodes {what-you-want-to-know-about}`

The options are:

```
    free    -- show the idle nodes available for assignment.
    avail   -- same as free
    info    -- a more nicely formatted output from <sinfo>
    queues  -- a more nicely formatted output from <squeue>
```

`submit` : The submit command allows you to submit slurm jobs in
batch mode (the usual way of doing things). You can provide
the name of your job with or without the ".slurm" on the end
of the file name. You can also submit multiple jobs at the
same time. Here are some examples:

```
    submit myjob.slurm -- tells slurm to run myjob.slurm
    submit myjob  -- tells slurm to run myjob.slurm
    submit myjob* -- tells slurm to run any slurm jobs whose
        names start with "myjob"
```

Assuming something has been submitted, you will see your running
jobs summarized at the end of the command.

`slurm` : 

```
Usage:
    slurm {check|install|start|stop|restart|config}

        check     -- checks that the parts are all present.
        install   -- performs a basic install.
        start     -- starts the slurmd.
        stop      -- stops the slurmd.
        restart   -- stops, and then starts.
        config    -- shows the config info for this node.
```

### uninstallslurm.bash

```
Usage:
    uninstallslurm [-c] [-i] [-s] [-u] [-v] {head | compute}

    This script will do its best to uninstall slurm, munge, and
    the maria database, generally because it failed to install
    correctly.

    If you type > ./uninstallslurm.bash compute

    you will get a no-questions asked, removal of the
    standard packages, skipping the checks at the end.

    -c => check to see that things are really gone at the end.
    -i => interactive. The script will ask you whether you
        want to continue after each step.
    -s => will remove the source code, too.
    -u => will remove the slurm/munge users, too.
    -v => verbose. Engage in haemorrhagic logorrhoea.
```


## AMBER 

This is a work in progress.

## amber.bash
