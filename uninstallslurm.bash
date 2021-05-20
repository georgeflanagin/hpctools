###
# This file will uninstall slurm on this node.
###
export __author__="George Flanagin"
export __version_date__=2021
export __version__=2.0 
export __maintainer__="George Flanagin"
export __email__="gflanagin@richmond.edu"
################################################################################
# Copyright (C) 2021 University of Richmond
# All Rights Reserved
################################################################################
echo "Loading installation utils."

################################################################################
# This file contains exports with the package lists and some
# utility functions to make this work easier.
################################################################################
if [ ! -f "$PWD/installutils.bash" ]; then
    echo "Cannot find ~/installutils.bash"
    exit
fi
source ~/installutils.bash

# >>>>>>>>>>
# Make sure this is bash, and stop if we are not.
# >>>>>>>>>>
if no_bash; then
    echo "You must run the installation from the *bash* shell, only."
    exit
fi

# >>>>>>>>>>
# Make sure this user can sudo
# >>>>>>>>>>
if no_sudo; then
    echo "You must be a sudoer to run this installation."
    exit
fi

# >>>>>>>>>>
# Collect info about this machine.
# >>>>>>>>>>
export HOST=`hostname`
ip=$(hostname -I)
export HOST_IP=$(for x in $ip; do echo $x; break; done)

# >>>>>>>>>>>
# set the variables for compute and head nodes.
# >>>>>>>>>>>
if [[ "$@" =~ "-v" ]]; then
    export verbose=1
else
    export verbose=0
fi

if [[ "$@" =~ "-i" ]]; then
    export interactive=1
else
    export interactive=0
fi

if [[ "$@" =~ "-u" ]]; then
    export remove_user=1
else
    export remove_user=0
fi

if [[ "$@" =~ "-c" ]]; then
    export run_checks=1
else
    export run_checks=0
fi

for node_type in $@; do :
    done

if (( $verbose == 1 )); then 
    echo "interactive is $interactive" 
    echo "run_checks is $run_checks" 
    echo "verbose is $verbose"
    echo "from_source is $from_source"
    echo "node_type is $node_type"
    echo "remove_user is $remove_user"
fi

# >>>>>>>>>>>>
# Find out what we are doing.
# >>>>>>>>>>>>
case "$node_type" in 
    "compute")
    export compute_node=1
    export head_node=0
    ;;

    "head")
    export computer_node=0
    export head_node=1
    ;;

    ""|"help"|*)
    cat - <<EOF
Usage:
    $0 [-c] [-i] [-s] [-u] [-v] {head | compute}

    This script will do its best to uninstall slurm, munge, and 
    the maria database, generally because it failed to install
    correctly.

    If you type > $0 compute

    you will get a no-questions asked, removal of the
    standard packages, skipping the checks at the end.

    -c => check to see that things are really gone at the end.
    -i => interactive. The script will ask you whether you
        want to continue after each step.
    -s => will remove the source code, too.
    -u => will remove the slurm/munge users, too.
    -v => verbose. Engage in haemorrhagic logorrhoea.

EOF
    exit
    ;;
    
esac


# >>>>>>>>>>
# Identify the right installer. We are going to call it
# dnf no matter what. Let's also make sure we have the
# correct version of dnf.
# >>>>>>>>>>
dnf=findinstaller $interactive

# >>>>>>>>>>>
# Avoid typos by setting this env variable to ensure
# we are uninstalling everything the same way.
# >>>>>>>>>>>
export removeit="sudo $dnf -y remove" 

# >>>>>>>>>>>>>>
# Stop the daemons that (are|may be) running.
# >>>>>>>>>>>>>>
echo "stopping munge daemon"
sudo systemctl stop munge
echo "stopping slurmd daemon"
sudo systemctl stop slurmd

if [ $node_type == "head" ]; then
    echo "stopping slurmdbd"
    sudo systemctl stop slurmdbd
    echo "stopping slurmctld"
    sudo systemctl stop slurmctld
fi 

# >>>>>>>>>>>>>>
# Remove slurm first.
# >>>>>>>>>>>>>>
$removeit $slurm_packages
$r=$?
if [ ! $? ]; then
    echo "There was a problem removing at least one of the packages: $r"
    exit
fi
sudo rm -f /etc/slurm/*
sudo rm -f /etc/munge/*

# >>>>>>>>>>>>>>
# Remove munge
# >>>>>>>>>>>>>>
$removeit $munge_packages
$r=$?
if [ ! $? ]; then
    echo "There was a problem removing at least one of the packages: $r"
    exit
fi


# >>>>>>>>>>
if (( $remove_user = 1 )); then
    if ! confirm "removing slurm and munge users"; then
        true 
    else
        sudo userdel --force munge
        sudo userdel --force slurm
    fi
fi

# >>>>>>>>>>
# Let's remove the database engine
# >>>>>>>>>>
if ! confirm "removing the database engine"; then exit; fi
v_echo "removing database packages"
$removeit mariadb-server mariadb-devel
v_echo "database packages removed"

# >>>>>>>>>>>>>
# Note that the return codes are defined in LSB 3.0.0, and the spec can
# be found here:
#   https://refspecs.linuxbase.org/LSB_3.0.0/LSB-PDA/LSB-PDA/iniscrptact.html
# >>>>>>>>>>>>>
if (( $run_checks == 1 )); then
    sudo systemctl status slurmd
    if [ $node_type == "head" ]; then
        sudo systemctl status slurmdbd
        sudo systemctl status slurmctld
    fi
fi

echo "We have done all we can to unslurm and unmunge this node."
