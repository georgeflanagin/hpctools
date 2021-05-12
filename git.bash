[ -z $PS1 ] && return
###
# This file of git macros is provided by University of Richmond.
# The commands work on our machines --- they may not work on yours.
#
#  If you would like to add the pile, we will try to incorporate your
#  changes.
###
#  George Flanagin
#  Computer Scientist
#  Puryear Hall, Office G28
#  28 Westhampton Way
#  University of Richmond
#  Richmond, VA 23173
#  +1.804.287.6392
#  gflanagi@richmond.edu
###
#  15 September 2014: gkf  (added documentation and disclaimers)
#  16 September 2014: gkf  (added the workflowhelp function)
#  26 September 2014: gkf  (detect the current shell)
#   2 January   2015: gkf  (aliased rm, cp, mv for safety)
#   5 January   2015: gkf  (added symbols for project names. Added "perms" function)
#   6 January   2015: gkf  (added makedocs and newproject to the mix)
#   9 January   2015: gkf  Added step counter during startup.
#  28 March     2015: gkf  Saved a version for Steve Zinski.
#  29 April     2015: gkf  Universalization.
#  14 April     2021: gkf  Added items for HPC.
###

# Strap on some safety belts.
alias rm="rm -i "
alias cp="cp -i "
alias mv="mv -i "

echo "Step $(( step++ )): " ' Testing version of the shell.'

if [ $ZSH_NAME ]; then
  echo 'This file does not work correctly with zsh'
  return
elif [ $PS3 ]; then
  echo 'This file does not work correctly with ksh'
  return
elif [ -z $BASH ]; then
  echo "I cannot tell what shell you are running, but it is not bash."
  return
fi

shopt -s cdspell > /dev/null

function extrafiles
{
    git ls-files --others --exclude-standard
}

function blame
{
    if [ -z $1 ]; then
        echo 'Usage: blame filename'
    else
        git blame --root --show-stats --date short "$1" 2>&1 | sed 's/(Cahuna Canoe//' 
    fi
}

function stash
{
    if [ -z $1 ]; then
        git stash
    else
        git stash "$1"
    fi
}

function discard
{
    git reset --hard HEAD
}

function gdiff
{
    if [ -z $1 ]; then
        echo 'diffing checked-in files with current files.'
        git diff --patience 
    elif [ -z $2 ]; then
        echo "diffing $1 with current checked in files on this branch."
        git diff --patience "$1" 
    else
        echo "diffing $1 with $2"
        git diff --patience "$1" "$2" 
    fi
}


function currentcommit
{
    git rev-parse --short HEAD
}

function currentbranch
{
    git rev-parse --abbrev-ref HEAD
}

function cdshow
{
  dirs -v -l
}

function up
{
  levels=${1:-1}
  while [ $levels -gt 0 ]; do
    cd ..
    levels=$(( --levels ))
  done
}

function back
{
  levels=${1:-1}
  while [ $levels -gt 0 ]; do
    popd 2>&1 > /dev/null
    levels=$(( --levels ))
  done
}

function cd
{
  if [ -z $1 ]; then
    command pushd ~ >/dev/null
  else
    command pushd "$1" 2>&1 >/dev/null
  fi
}

###
# First, let's see if this machine has everything we need
# on it.  If it does not, we bail out after telling the user
# the first thing that is missing.
###
echo "Step $(( step++ )): "'Looking for helper programs.'

less=`which less`
if [ -z "$less" ]; then
  less="more"
fi

echo " "

###
# git completion ... for expert users.
###
echo "Step $(( step++ )): "'Checking for git auto-completion.'

if [ -f ~/.git-completion.bash ]; then
  source ~/.git-completion.bash
fi

###
# Figure out what editor they are using.
###
echo "Step $(( step++ )): "'Setting $EDITOR if not already set.'

if [ -z $EDITOR ]; then
  export EDITOR=`which vim`
fi

#The universal help symbol, but you can change it!
echo "Step $(( step++ )): "'Setting help to be -?'

help="-?"

#Directory Colors
export LS_COLORS='di=0;32'

echo "Step $(( step++ )): "'Defining a few colors.'
#Colors
export           RED="\[\033[0;31m\]"
export     LIGHT_RED="\[\033[1;31m\]"
export        ORANGE="\[\033[1;43m\]"
export        YELLOW="\[\033[0;33m\]"
export  LIGHT_YELLOW="\[\033[1;33m\]"
export          BLUE="\[\033[0;34m\]"
export    LIGHT_BLUE="\[\033[1;34m\]"
export         GREEN="\[\033[0;32m\]"
export   LIGHT_GREEN="\[\033[1;32m\]"
export          CYAN="\[\033[0;36m\]"
export    LIGHT_CYAN="\[\033[1;36m\]"
export        PURPLE="\[\033[0;35m\]"
export  LIGHT_PURPLE="\[\033[1;35m\]"
export         WHITE="\[\033[1;37m\]"
export    LIGHT_GRAY="\[\033[0;37m\]"
export         BLACK="\[\033[0;30m\]"
export          GRAY="\[\033[1;30m\]"
export      NO_COLOR="\[\e[0m\]"
export       REVERSE="\[\e[7m\]"

#### Change this to suit yourself.
export PROMPT_COLOR=$ORANGE

# Read the name of this machine into a variable. Note: this works even
# on AIX.
export HOSTNAME="$REVERSE`hostname -s | cut -f1 -d"-"`$NO_COLOR"

###
# Let's build the git part of our prompt.
###
function prompt_git
{
  local status output flags
  status="$(git status 2>/dev/null)"
  [[ $? != 0 ]] && return;
  output="$(echo "$status" | awk '/# Initial commit/ {print "(init)"}')"
  [[ "$output" ]] || output="$(echo "$status" | awk '/# On branch/ {print $4}')"
  [[ "$output" ]] || output="$(git branch | perl -ne '/^\* (.*)/ && print $1')"
  flags="$(
    echo "$status" | awk 'BEGIN {r=""}
      /Changes not staged for commit:/  {r=r"!"}
      /Untracked files:/                {r=r"?"}
      /Changes to be committed:/        {r=r"+"}
      END {print r}'
  )"
  if [[ "$flags" ]]; then
    output="$output$WHITE$flags$PROMPT_COLOR"
  fi
  echo "[$output]"
}

###
# This is the other part of the prompt. It should look something like this:
#  [branch][host(user)////dir]:
###
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG
function prompter
{
  if [[ $? -eq 126 || $? -eq 127 ]]; then
    cd $previous_command
  fi

  export checkedout_branch=$(git symbolic-ref HEAD 2>/dev/null | awk -F/ '{print $NF}' 2>/dev/null)
  export colwidth=$(tput cols)
  export pwdtext=`pwd`
  export pwdlen=${#pwdtext}
  export promptsize=$((${#HOSTNAME} + ${#USER} + ${#pwdtext}))
  if [ $((pwdlen + 20)) -gt $((colwidth / 2)) ]; then
    pwdtext=${pwdtext:0:7}"..."
    export promptsize=$((${#HOSTNAME} + ${#USER} + ${#pwdtext}))
  fi

  export howfardown=$(echo `pwd` | sed 's/[^/]//g')

  if [ $((promptsize * 5)) -gt $((colwidth))  ]; then
    PS1="$PROMPT_COLOR\n$(prompt_git)$PROMPT_COLOR[$HOSTNAME($USER):$howfardown\W]:\e[m "
  else
    PS1="$PROMPT_COLOR\n$(prompt_git)$PROMPT_COLOR[$HOSTNAME($USER):\w]:\e[m "
  fi
}

# this statement associates the above function with something to do when
# you press the return key.
PROMPT_COMMAND="prompter"

echo "Step $(( step++ )): "'Fancy prompt is now set.'

###
# Three self-help functions.
###

function iforgotgit
{
  echo " "
  echo "OH NO! Well, here is what I have for you, and they are kinda presented"
  echo " in the likely order that you typically do things."
  echo " "
  echo "gitsetup  ::: ... ONLY if you are new to git on this machine ..."
  echo " "
  echo "init      ::: ... ONLY if you are starting a new project ..."
  echo "gitignore ::: .. if you want git to forget a few common files ..."
  echo " "
  echo "  .. but you probably want to start here .. "
  echo " "
  echo "pull      ::: copy a repo into a directory where you will do work."
  echo "branch    ::: create a new branch and switch to it."
  echo "checkout  ::: choose an existing branch where you will do the work."
  echo " "
  echo "  .. get your bearings .."
  echo " "
  echo "ghist     ::: show me the summary of the repo."
  echo "githome   ::: show me the top level directory of this repo."
  echo "gitgohome ::: change to the top level directory of this repo."
  echo "findcommit :: find a commit of interest."
  echo "showauthor :: find the commits made by a particular person."
  echo "githogs   ::: show the files in this repo, big ones at the bottom."
  echo " "
  echo "  .. do your work .. "
  echo " "
  echo "add       ::: tell git to track changes to a file."
  echo "forget    ::: tell git to forget about tracking a file without deleting it."
  echo "commit    ::: put your changes into your working copy of the repo, including"
  echo "              any files you have added but need to commit for the first time."
  echo "bugfix    ::: simple commit and a comment if this is all you are doing."
  echo "tag       ::: give your changes a cool name."
  echo " "
  echo "  .. and now you are finished, so you may need to  .. "
  echo " "
  echo "squish    ::: attempt to reduce the disc footprint of your repo."
  echo "push      ::: send the changes in your current branch back to the origin."
  echo "merge     ::: merge your branch's changes with the master."
  echo " "
  echo "  .. unless ..  "
  echo " "
  echo "giveup    ::: please don't do this."
  echo " "
  echo " --- following any command with $help will give you more info."
}

function explaintheprompt
{
  echo " "
  echo "You are probably looking at something like this:"
  echo " "
  echo "[BRANCH][HOST(USER):/p/w/d]: "
  echo " "
  echo "You may see some symbols after the BRANCH and before the ']'. Here"
  echo "is what they mean:"
  echo " "
  echo "+  means you have made changes that are staged and ready."
  echo "?  means you have files that are not in the repo, and not listed"
  echo "   in the .gitignore file"
  echo "!  means that you have changes that are not in the commit."
  echo " "
  echo "If the prompt becomes too long, it will self shorten to something "
  echo "more like [BRANCH][HOST(USER):///lastdir]: To see the whole thing,"
  echo "make your screen wider and press the return key."
  echo " "
}

function workflowhelp
{
  if [ -z "$1" ]; then
    iforgotgit | less
    return
  fi

  case "$1" in
    add)
      cat - <<EOD
**add** tells git to make the given file(s) a part of the project. It does not
commit them, just puts them on the list of things to track. The filename
can be a wildcard like "*.js" or a long path name. Symbolic links are
tracked as the /link/ not the file that the link points to.
EOD
    ;;

    checkout)
    cat - <<EOD
**checkout** switches to the branch whose name you provide. Don't worry, git
will not let you checkout a new branch if you have as-yet uncommitted changes.
EOD
    ;;


    clean)
    cat - <<EOD
**clean** will take you through all the files in the directory that git
doesn't think are a part of the project, and ask you one at a time if
you really want to delete them.
EOD
    ;;


    dropbranch)
    cat - <<EOD
**dropbranch** gets rid of the named branch, and all the history of
revisions you made to it.
EOD
    ;;


    findcommit)
    cat - <<EOD
**findcommit** ... do you ever remember just a tiny bit about some long ago
commit that you made? Just type 'findcommit "tiny fragment of text"' and
this command will show you the commits that match.
EOD
    ;;


    forget)
    cat - <<EOD
**forget** tells git to remove a file from the project, but not from the
disc storage. To delete the file, use "git rm" or "clean".
EOD
    ;;

    ghist)
    cat - <<EOD
**ghist** shows you a one line summary of each commit. By default, the
commit history is shown in reverse chronological order. If you want
to see the newest at the bottom, type "ghist -r".
EOD
    ;;

    githome)
    cat - <<EOD
**githome** prints the name of the top-most directory of the project.
Many times, we just forget where were are ....
EOD
    ;;

    gitgohome)
    cat - <<EOD
**gitgohome** will change the working directory to the top-level directory
of the project.
EOD
    ;;

    makebranch)
    cat - <<EOD
**makebranch** will make a branch with the given name. It will start with
whatever the current code is, create the branch, and do a checkout.
EOD
    ;;

    init)
    cat - <<EOD
**init** is used to start the project. The command is non-destructive, meaning
that you run no risk of wiping out your work by accident.
EOD
    ;;

    makebarerepo)
    cat - <<EOD
**makebarerepo** creates a repo with no working directory. Usually, a
bare repo is one that is published on a server for the purpose of cloning
into a local, and working copy.
EOD
    ;;

    commit)
    cat - <<EOD
**commit** will take all your pending changes, and all your newly
added files, and put it all in the repo. It fires up your editor,
allows you to type in a commit message.
EOD
    ;;

    findauthor)
    cat - <<EOD
**findauthor** looks through the commit history and pulls out the
changes made by someone whose name (or part of the name) you specify.
The command does support regex, so if you are looking for commits
by George Flanagin, and cannot remember how to spell his last name,
you can type in ...

  findauthor flan[ai]g[ai]n

EOD
    ;;

    tag)
    cat - <<EOD
**tag** simply provides a meaningful-to-you name for the current
commit. git tags all the commits, but the names it provides are
less memorable.
EOD
    ;;

    merge)
    cat - <<EOD
**merge** will combine your current branch with the master, and
then checkout the master.
EOD
    ;;

    push)
    cat - <<EOD
**push** will send your currently committed changes to the remote
repo that you have identified as the origin.
EOD
    ;;

    pull)
    cat - <<EOD
**pull** will bring over the current version of a remote repo. A
pull is not the same thing as a clone .... a clone gets everything.
EOD
    ;;

    origin)
    cat - <<EOD
**origin** is followed by a local directory name or a remote
URL that is available by ssh or git. Examples:

origin /dir/on/this/machine
origin user@host:/dir/elsewhere

If you just type "origin", the place from where you cloned/pulled
your repo is shown on the screen, along with their current states
relative to your work. For example:

* remote origin
  Fetch URL: /mnt/remoterepos/common.yak.git
  Push  URL: /mnt/remoterepos/common.yak.git
  HEAD branch: master
  Remote branches:
    master  tracked
    windows tracked
  Local refs configured for 'git push':
    master  pushes to master  (fast-forwardable)
    windows pushes to windows (up to date)
EOD
    ;;

    gitignore)
    cat - <<EOD
**gitignore** will create a .gitignore file for you, and fill it with
the usual suspects: *.bak, *.log, etc. If the file already exists,
gitignore will bring it up in the editor.
EOD
    ;;

    *)
    echo "Sorry, no help available for $1"
    ;;

  esac
  return
}

echo "Step $(( step++ )): "'Help functions are sourced.'

###
# And now some functions to make your life easier.
###


# Add a file to a project
function add
{
  if [ -z $1 ]; then
    echo "Usage: add file-name-to-add-to-the-repo"
    return
  fi

  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git add -f "$1"
}

# Change branches.
function checkout
{
  if [ -z $1 ]; then
    echo "Usage: checkout branchname"
    return
  fi

  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git checkout "$1"
}

function clean
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git clean -i
}

function dropbranch
{
  if [ -z $1 ]; then
    echo 'You must tell me the name of the branch you want to drop'
    return
  fi

  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git branch -d "$1" 2> /tmp/dropbranch
  if [ -s /tmp/dropbranch ]; then
    cat /tmp/dropbranch | grep "not found"
  fi
}

function findcommit
{
  if [ -z $1 ]; then
    echo "Usage: findcommit text-you-are-looking-for"
    return
  fi
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git log --pretty=format:"%h %ad | %s%d [%an]" --graph --date=short | grep "$1"
}

function forget
{
  if [ -z $1 ]; then
    echo "Usage: forget file-name"
    echo "  this command does not delete file, just stops the tracking."
    return
  fi
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git rm --cached "$1"
}

# unfortunately, there is already a "history" built-in.
function ghist
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  if [ "$1" == "-r" ]; then
    order="--reverse"
  else
    order="--graph"
  fi

  git log $order --pretty=format:"%h %ad | %s%d [%an]" --date=short
}

function gitgohome
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  cd "$(git rev-parse --show-toplevel)"
}

function githogs
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git rev-list --all --objects | \
    sed -n $(git rev-list --objects --all | \
    cut -f1 -d' ' | \
    git cat-file --batch-check | \
    grep blob | \
    sort -n -k 3 | \
    tail -n40 | \
    while read hash type size; do
         echo -n "-e s/$hash/$size/p ";
    done) | \
    sort -n -k1
}

function githome
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  echo $(git rev-parse --show-toplevel)
}

function init
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  if [ -d '.git' ]; then
    echo "This directory is already under management by git."
    return
  fi
  git init
}

# Create a branch
function makebranch
{
  if [ -z $1 ]; then
    echo 'You must tell me the name of your branch. Example: branch XYZ'
    return
  fi

  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git branch "$1"
  git checkout "$1"
}

function showauthor
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  if [ -z $1 ]; then
    echo 'Usage: showauthor {[partial]-name-of-committer}'
    echo " Shows the timestamps of all this author's commits."
  else
    git log --all | sed ':r;$!{N;br};s/\nDate://g' | grep ^Author: | grep $1 | tac
  fi
}

function squish
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git gc --prune=now
}


function prune
{
    if [ -z $1 ]; then
        echo "Usage: prune {branch-name}"
        echo " removes branch from local and remote repo[s]."
        return
    fi
    git branch -D "$1"
    git push origin --delete "$1"
}

# Summary of your current status.
function status
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git status
}

# Commit your changes
function commit
{
    # The cc_dir is where the dinghy process will look for change
    # controls to put in Box.
    cc_dir=/sw/canoe/var/data/changecontrols

    # Save the old value of EDITOR . It is usually just 'vim'.
    oldeditor=$EDITOR

    # Find out the name of the top directory for this repo, and go there.
    top_dir=`git rev-parse --show-toplevel`
    pushd $top_dir >/dev/null    

    # Find out if we are in the recipe repo.
    if [[ $top_dir == $local ]]; then
        # Oh, we are. Just commit with reference to the change control.
        git commit -a -m 'See change control for this commit ID'
        commit_id=`git rev-parse --short HEAD`

        # Rename any pdf files in the directory to include the commit ID.
        # As an example, if we have "Suspend.HR.feeds.pdf", it will become
        # something like "Suspend.HR.feeds.790bb15.pdf" Then we move it
        # to the place where the dinghy is looking for them.
        rename .pdf ".$commit_id.pdf" *.pdf
        mv -f *pdf "$cc_dir"

    else
        # we want to open vim in insert mode to just start typing our
        # commit message.
        export EDITOR="/usr/bin/vim -c 'startinsert' "
        git commit -a

    fi    

    # Set the value back to what it was.
    export EDITOR=$oldeditor

    # Generate the changelog /after the commit/. The CHANGELOG.txt file is 
    # always in the .gitignore file.
    git log $order --pretty=format:"%h %ad | %s%d [%an]" --date=short > CHANGELOG.txt

    # Return ourselves to where we started.
    popd > /dev/null
}

function makechangelog
{
  pushd "$(git rev-parse --show-toplevel)" >/dev/null
  git log $order --pretty=format:"%h %ad | %s%d [%an]" --date=short > CHANGELOG.txt
  popd > /dev/null
}

# We need everyone's names to show up in the commit history.
function gitsetup
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  read -p "Your name (for the purposes of git commits): " firstname lastname
  git config --global user.name "$firstname.$lastname"

  read -p "Your email address (for commits)           : " email
  git config --global user.email "$email"

  if [ -z "$EDITOR" ]; then
    git config --global core.editor "vim"
  else
    git config --global core.editor "$EDITOR"
  fi

  git config --global color.ui true
  echo "OK, thanks, $firstname. You are set up to use git"
  echo "and your email is $email. If you need"
  echo "to change this information, just rerun this command."
}

# Create a typical .gitignore file.
function gitignore
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  ignorefile="`githome`/.gitignore"
  echo $ignorefile
  if [ -f "$ignorefile" ]; then
    echo 'This project already has a .gitignore file.'
  else
    echo "OK. I'm building you a .gitignore file."
    touch "$ignorefile"
    echo '.gitignore' >>"$ignorefile"
    echo 'CHANGELOG.txt' >> "$ignorefile"
    echo '*.o' >>"$ignorefile"
    echo '*.a' >>"$ignorefile"
    echo '*converted-to.*' >>"$ignorefile"
    echo '*.bak' >>"$ignorefile"
    echo '*.tar' >>"$ignorefile"
    echo "*.gz" >>"$ignorefile"
    echo '*.aux' >>"$ignorefile"
    echo '*.bcf' >>"$ignorefile"
    echo '*.lof' >>"$ignorefile"
    echo '*.log' >>"$ignorefile"
    echo '*.out' >>"$ignorefile"
    echo '*.pdf' >>"$ignorefile"
    echo '*.run.xml' >>"$ignorefile"
    echo '*.synctex.gz' >>"$ignorefile"
    echo '*.thm' >>"$ignorefile"
    echo '*.toc' >>"$ignorefile"
  fi
  read -p "Do you want to edit the .gitignore file (y/n)? " yesorno
  if [ "$yesorno" == "y" ]; then
    $EDITOR $ignorefile
  fi
  echo "We are done."
  chmod 644 $ignorefile
}

function giveup
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  echo "This is not permitted. Please call the Help Desk. Operators are standing by."
}

function tag
{
  if [ -z $1 ]; then
    echo "Usage: tag nameoftag  (name may not contain spaces)"
    return
  fi

  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  git tag "$1"
}

#push current branch (or specified branch) to remote repo "origin"
function push
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  branch={$1:-master}
  git push origin "$branch"
  git push origin "$branch" --tags

}

#pull current branch (or specified branch) from remote repo "origin"
function pull
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  local status branch
  if [ -z "$1" ]; then
    status="$(git status 2>/dev/null)"
    branch="$(echo "$status" | awk '/# On branch/ {print $4}')"
    echo "pulling from origin/$branch"
    git pull origin $branch
  else
    echo "pulling from origin/$1"
    git pull origin $1
  fi
  gitignore
}

function bugfix
{
  if [ -z $1 ]; then
    echo "You must tell something about your fix."
    echo " Example:   bugfix 'I really fixed it this time.'"
    return
  fi

  if [ "$1" == $help ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  reason="$1"
  git commit -a --message="`date +%F` Bug Fix: '$reason'"
}

function origin
{
  if [ -z $1 ]; then
    git remote show origin
    return
  fi
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  origin=${2:-'origin'}
  git remote add "$origin" "$1"
}

function makebarerepo
{
  if [ -z $1 ]; then
    echo 'Usage: makebarerepo /dir/with/repo'
    return
  fi

  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  if [ ! -d "$1" ]; then
    echo "$1 does not seem to be a directory"
    return
  fi

  # go to the directory
  pushd "$1" > /dev/null

  if [ ! -d .git ]; then
    echo "This directory does not appear to be managed by git"
    return
  fi

  # copy the files out of the .git dir and into the current, visible directory.
  mv .git .. && rm -fr *
  mv ../.git .
  mv .git/* .

  # and blow away the .git directory
  rmdir .git

  # turn on the "bare" attribute
  git config --bool core.bare true

  # and rename it.
  cd ..
  mv "$1" "$1".git
  popd > /dev/null
}

function reassign
{
  if [ "$1" == "$help" ]; then
    workflowhelp ${FUNCNAME[0]}
    return
  fi

  if [ -z $1 ]; then
   read -p "Give the name of the link: " linkname
  fi
  if [ -z $2 ]; then
   read -p "Give the name of the new target: " target
  fi

  # Make sure the thing we are removing is a sym link.
  if [ ! -L $1 ]; then
   echo "Sorry. $1 is not a symbolic link"

  # attempt to create the file if it does not exist.
  else
   if [ ! -e $2 ]; then
     touch $2
     # mention the fact that we had to create it.
     echo "Created empty file named $2"
   fi

   # make sure the target is present.
   if [ ! -e $2 ]; then
     echo "Unable to find or create $2."
   else
     # nuke the link
     rm -f $1
     # link
     ln -s $2 $1
     # confirm by showing.
     ls -l $1
   fi
  fi
}

function retag
{
    if [ -z $1 ]; then
        echo "Usage: retag {tagname} [commit]"
        echo " If the commit is not supplied, the tag is applied to whatever"
        echo " is currently checked out. NOTE: the tag is /always/ created,"
        echo " even if it has never existed before."
        return
    fi 

    if [ -z "$2" ]; then 
        git tag -fa "$1" 
    else
        git tag -fa "$1" "$2"
    fi
    git push origin master --tags
}

function showrepo
{
    if [ "$1" == "-?" ]; then
        echo "Syntax: showrepo [branch-name]"
        echo "  The default branch-name is whatever is checked out."
        return
    fi

    gitgohome

    if [ -z $1 ]; then
        git ls-tree --full-tree -r --name-only HEAD | sort | xargs ls -l
    else
        git ls-tree --full-tree -r --name-only "$1" | sort | xargs ls -l
    fi

    back
}

function showremote
{
    if [ -z $1 ]; then
        git remote show 
    else
        git remote show "$1"
    fi
}

function viremote
{
  if [ -z $1 ]; then
    echo 'Usage: works just like vi, but lets you edit a file on a remote host but with your own .vimrc.'
    return
  fi

  numinnerparams=$(($#-1))

  for last; do true; done
  pushd /tmp > /dev/null 2>&1
  localcopy=${last##*/}
  scp "$last" " $localcopy "
  if [[ $numinnerparams -eq 0 ]]; then
    vi "$localcopy"
  else
    newparams=${@:1:$numinnerparams}
    vi "$newparams" "$localcopy"
  fi
  scp "$localcopy" "$last"
  popd > /dev/null 2>&1
}

function ffcommit
{
    if [ -z $1 ]; then
        branch=master
    else
        branch="$1"
    fi
    git fetch origin $branch
    commit
    git pull origin $branch
    git push origin $branch
}

function gitbranchlrt
{
  for k in `git branch | sed s/^..//`; do 
    echo -e `git log -1 --pretty=format:"%Cgreen%ci %Cblue%cr%Creset" $k --`\\t"$k"; 
  done | sort
}

function perms
{
  if [ -z $1 ]; then
    echo 'Usage: perms {/sufficiently/qualified/directory/or/file/name}'
    return
  fi

  problem="$1"
  if [ "$problem" == "." ]; then
    problem=`pwd`
  fi
  if [ -f "$problem" ]; then
    problem=`readlink -f $problem`
  elif [ -d "$problem" ]; then
    echo ' '
  else
    echo "Cannot make sense of $problem"
    return
  fi

  touch /tmp/x
  rm -f /tmp/x

  tabs 10

  echo "Access permissions for $problem"
  echo "===================================================="
  echo " "

  while true ; do
    if [ -f "$problem" ]; then
      ls -l "$problem" | awk '{print $1"\t"$3"\t"$4"\t"$9}' >> /tmp/x
    else
      ls -ld "$problem" | awk '{print $1"\t"$3"\t"$4"\t"$9}' >> /tmp/x
    fi
    [[ "$problem" != "/" ]] || break
    problem="$( dirname "$problem" )"
  done
  sed '1!G;h;$!d' < /tmp/x
  rm -f /tmp/x
}

# declare -F | sort | awk '{print $3}'

echo " .... . . . . "
echo "You've got git workflow!"
echo " "
echo "Type 'workflowhelp' at the prompt to find out more."
echo " "
export PROMPT_COLOR=$PURPLE
