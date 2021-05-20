###
# This file contains lists of packages and utility functions to make
# installing munge and slurm a little easier.
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
export clock_packages="ntp chkconfig ntpdate"

export database_packages="mariadb-server mariadb-devel"

export devel_packages="python3 gcc openssl openssl-devel pam-devel \
    numactl numactl-devel hwloc lua readline-devel \
    ncurses-devel man2html libibmad libibumad rpm-build \
    perl-ExtUtils-MakeMaker.noarch rrdtool-devel lua-devel hwloc-devel"

export munge_packages="munge munge-libs munge-devel rng-tools"

export slurm_packages="slurm-libs \
        slurm \
        slurm-perlapi \
        slurm-pmi \
        slurm-gui \
        slurm-rrdtool \
        slurm-pmi-devel \
        slurm-contribs \
        slurm-openlava \
        slurm-torque \
        slurm-slurmdbd \
        slurm-slurmd \
        slurm-slurmctld \
        slurm-pam_slurm \
        slurm-nss_slurm \
        slurm-doc \
        slurm-devel"

function confirm
{
    if [ $interactive -eq 0 ]; then
        true
    fi
        
    read -r -p "Continue with $1 ? [y/N] " chars
    case $chars in
        [yY][eE][sS]|[yY])
        true
        ;;
    *)
        false
        ;;
    esac
}

function find_installer
{
    dnf=$(which dnf 2>/dev/null)
    if [ -z $dnf ]; then
        dnf=$(which yum)
    fi
    v_echo "dnf is $dnf"
    sudo $dnf -y upgrade $dnf
    r=$?
    if [ ! $? ]; then 
        echo "There was a problem upgrading dnf. exit code: $r"
        if (( $1 == 1 )); then
            exit
        fi
    fi
    return $dnf
}

function v_echo
{
    if (( $verbose == 1 )); then
        echo "***********************************************"
        echo $@
        echo "***********************************************"
    fi
}

function no_bash
{
    this_shell=$(basename $(readlink /proc/$$/exe))
    if [ ! "$this_shell" == "bash" ]; then
        return 0
    else
        return 1
    fi
}

function no_sudo
{
    a_sudoer=0
    for g in $(groups); do
        if [ $g == "wheel" ]; then
            a_sudoer=1
            break
        fi
    done
    return $a_sudoer
}

