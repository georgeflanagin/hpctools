# If this is not an interactive session, bail out.
[ -z $PS1 ] && return

# Source global definitions
if [ -f /etc/bashrc ]; then
    echo "Loading global bash settings."
	. /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
# source /act/etc/profile.d/actbin.sh
# source /opt/etc/profile.d/pi_cparish.bashrc

# >>>>>>>>>>>>>>>>>>>>>
# names and aliases
# >>>>>>>>>>>>>>>>>>>>>

export EDITOR=`which vim`
export me=`whoami`

shopt -s direxpand
shopt -s cdable_vars
shopt -s checkwinsize

export CPUNAME=$(hostname | awk -F. '{print $1}')
export PS1="["$CPUNAME":\w]: "
alias ll="ls -l "
alias vi="vim "
alias rm="rm -i "
alias mv="mv -i "

# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Special case to set "python" for the anaconda env.
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

p=`ls /usr/bin/python3* | tail -1`
anaconda_dir="/opt/app/anaconda3/anaconda3/bin"
if [ -d "$anaconda_dir" ]; then
    echo "Found Anaconda 3 directory"
    p3=`ls -1 "$anaconda_dir"/python3.*[0-9] | tail -1`
    echo "found Python at $p3"
    alias python=$p3
    alias python3="$p"
    echo "adding Anaconda dir to path"
    export PATH="$PATH:$anaconda_dir"
else
    echo "No Anaconda 3 dir here. Using system python"
    alias python="$p"
    alias python3="$p"
fi

# >>>>>>>>>>>>>>>>>
# directory stuff
# >>>>>>>>>>>>>>>>>

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

function mcd ()
{
    mkdir -p "$1"
    cd "$1"
}

function cd
{
    if [ -z $1 ]; then
        command pushd ~ >/dev/null
    else
        command pushd "$1" 2>&1 >/dev/null
    fi
}

function cdd
{
    d_name=$(find . -type d -name "$1" 2>&1 | grep -v Permission | head -1)
    if [ -z $d_name ]; then
        d_name=$(find ~ -type d -name "$1" 2>&1 | grep -v Permission | head -1)
    fi  
    if [ -z $d_name ]; then
        echo "no directory here named $1"
        return
    fi
    cd "$d_name"
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

function clonedirsto()
{
    if [ -z $1 ]; then
        echo "Syntax:"
        echo "   clonedirsto {hostname}"
        echo " copies this directory and all sub-directories to the named host,"
        echo " preserving permissions. ALL FILES ARE IGNORED."
        return
    fi

    opts=" --perms --recursive --verbose --human-readable -f\"+ */\" -f\"- *\" "
    here=$(pwd)
    /usr/bin/rsync $opts $here $1:
}


# >>>>>>>>>>>>>>>>>>>>>>>>>
# sockets, pipes, tunnels
# >>>>>>>>>>>>>>>>>>>>>>>>>

showsockets()
{
    ss -t | grep -v 127.0.0.1
}

showpipes()
{
    lsof | head -1
    lsof | grep FIFO | grep -v grep | grep -v lsof
}

tunnel()
{
    if [ -z $4 ]; then
        echo "Usage: tunnel localport target targetport tunnelhost"
        return
    fi

    ssh -f -N -L "$1:$2:$3 $4"
}


# >>>>>>>>>>>>>>>>>>
# file stuff
# >>>>>>>>>>>>>>>>>>

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

xmlfix()
{
    sed -i 's/></>\n</g' "$1"   
}

function owner ()
{
    chown -R $1 *
    chgrp -R $1 *
}

function fixperms()
{
    chmod g+s $(pwd)
    chmod -R go-rwx *
    chmod -R -x+X *
}

hogs()
{
    d=${1:-$(pwd)}
    find $d -size +100M -exec ls -l {} \;
}

function cloc
{
    d=${1:-$(pwd)}
    pushd "$d" >/dev/null 2>&1
    echo "counting $d"
    /sw/canoe/bin/cloc `git ls-tree --full-tree --name-only -r HEAD`
    popd > /dev/null 2>&1
}

function findq
{
  find $@ 2>/dev/null | grep -v denied
}

# >>>>>>>>>>>>>>>>>>>>>>>>>>
# general functions
# >>>>>>>>>>>>>>>>>>>>>>>>>>

# for fun
alias rot13="tr '[A-Za-z]' '[N-ZA-Mn-za-m]'"

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

function e()
{
    vim `ls -1rt * | tail -1`    
}

myscreen()
{
    echo "my screen is `tput cols` columns wide and `tput lines` lines tall."
}

function confirm
{
    read -r -p "$1 ... Are you sure? [y/N] " chars
    case $chars in  
        [yY][eE][sS]|[yY])
        true
        ;;  
    *)  
        false
        ;;  
    esac
}

hg()
{
    if [ -z $1 ]; then
        echo 'Usage: hg {search-term}'
        return
    fi
    history | grep "$1"
}

function editrc
{
  vi ~/.bashrc
  source ~/.bashrc
}

function reload
{
    source ~/.bashrc
}

function randomfile()
{
    if [ -z $1 ]; then
        echo 'Usage: randomfile {filename} [size]'

        echo ' .. generates a random file of printable chars of the given size (in bytes), '
        echo '  or 1000 bytes if not supplied.'
        return
    fi
  
    len=${2:"1000"}
    < /dev/urandom tr -dc "\t\n [:alnum:]" | head -c $len | base64 | head -c $len > "$1"
}

function myhosts()
{
    cat ~/.ssh/config | grep ^Host
}

function isrunning
{
    ps -ef | sed -n "1p; /$1/p;" | grep -v 'sed -n'
}

function findtext 
{
    grep -n -R "$1" * 2>/dev/null | grep -v "Binary file" 
}

########################################

# >>>>>>>>>>>>>>>>>>
# PATH stuff
# >>>>>>>>>>>>>>>>>>
function addhere
{
  export PATH=$PATH:`pwd`
  echo PATH is now $PATH
}

function delhere
{
  HERE=:`pwd`
  export PATH=$(echo $PATH | sed "s/$HERE//")
  echo PATH is now $PATH
}

function pyaddhere
{
    export PYTHONPATH="$PYTHONPATH":`pwd`
    echo PYTHONPATH="$PYTHONPATH"   
}

function pydelhere
{
    HERE=:`pwd`
    export PYTHONPATH=$(echo $PYTHONPATH | sed "s/$HERE//")
    echo PYTHONPATH="$PYTHONPATH"
}


# >>>>>>>>>>>>>>>>>>>
# Keyring stuff
# >>>>>>>>>>>>>>>>>>>
export config=~/.ssh/config

gpgdiagnose()
{
    if [ -z $1 ]; then
        echo "Usage: gpgdiagnose filename"
        return
    fi
    
    gpg --list-packets -vvv --show-session-key "$1" > "$1.diag" 2>&1
}

findkey()
{
    if [ -z $1 ]; then
        echo "Usage: findkey {ownername}"
        return
    fi
    gpg --list-keys | grep -a1 -b1 "$1"
}

function key
{
    if [ -z $1 ]; then
        cat - <<EOF
Usage: key {command} {keyname}"
   where command is one of:

        help -- get a lot of help!

        ur       -- creates an exportable copy of the UR key[s]
                    to send to another party. The file will be
                    named ur.key.pub in the current directory.
                    
        find     -- locate a key by user ID
        finger   -- print the complete finger print of the key and
                    all its subkeys.
        details  -- show everything about the key
        sign     -- sign the key with the UR key

EOF
        return
    fi

    case "$1" in
        
        help)
        cat - <<EOD | less
This utility shows information about a key. To use it, you need to know
the "user id" associated with the key, and that is usually the email 
address of the key's owner.

To locate a key: 

> key find presence

4784-pub   2048R/146FAEB8 2017-07-25
4816:uid                  Presence <hello@presence.io>
4866-sub   2048R/C295C0BA 2017-07-25

In the example, the top line contains `146FAEB8`. Those are the last eight
hex digits of the key's ID. 

To see the details of key 146FAEB8, do the following. Only the first few
lines are shown, and all keys should contain similar information near
the top of the listing of the details. Line numbers have been added on
the right for clarity.

**************************************************************************
ACHTUNG! The info can be long, so the output is routed to less so that you
can scroll it backwards and forwards.
**************************************************************************

> key details 146FAEB8

:public key packet:                                           1
    version 4, algo 1, created 1501003658, expires 0          2
    pkey[0]: [2048 bits]                                      3
    pkey[1]: [17 bits]                                        4
    keyid: AD0AD21B146FAEB8                                   5
:user ID packet: "Presence <hello@presence.io>"               6
:signature packet: algo 1, keyid AD0AD21B146FAEB8             7

[ .. deleted to save space .. ]

Line 1: the type of key "public".
Line 2: the creation date in seconds since Jan 1, 1970. 
    1501003658 is sometime on July 25th, 2017. Note that you
    can convert this exactly with the following command:

> date --date='@1501003658'

Tue Jul 25 13:27:38 EDT 2017

Line 5: the full sixteen hex digit ID of the key.
Line 6: the key's owner, in full.
Line 7: every valid key has at least one signature, and this
    is the self signature. 


If we believe the key is valid, we sign the key with the UR key.

> key sign 146FAEB8

EOD
            ;;

        ur)
            gpg -a --export 0x7ED95717 > ur.key.pub
            ;;


        find)
            if [ -z "$2" ]; then
                echo "You must give the name of the key you want to find."
                return
            fi

            gpg --list-keys | grep -a1 -b1 "$2"
            ;;
    
        details)
            if [ -z "$2" ]; then
                echo "You must give the name of the key to see its details."
                return
            fi
         
            gpg -a --export "$2" | gpg --list-packets | less
            ;;


        finger)
            if [ -z "$2" ]; then
                echo "You must give the name of the key to see its details."
                return
            fi

            gpg --fingerprint --fingerprint "$2"
            ;;

        sign)
            if [ -z "$2" ]; then
                echo "You must give the ID of the key to sign."
                return
            fi

            gpg -u 0x7ED95717 --yes --sign-key "$2" 
            ;;

        *)

            echo "Sorry, there is no command named $1"
            ;;

    esac
}

export LS_COLORS=$LS_COLORS:'di=0;35:'
export HISTTIMEFORMAT="%d/%m/%y %T "
PROMPT_COLOR=$PURPLE

# Find out if git is around.
if [ ! -z `which git` ]; then
    echo "git is installed on this system; loading shortcuts."
    source git.bash 2>&1 >/dev/null
fi

# Find out if slurm is present.
if [ ! -z `which sbatch` ]; then
    echo "slurm is installed on this system; loading shortcuts"
    source slurm.bash 2>&1 >/dev/null
    source slurm_completion.sh
fi

