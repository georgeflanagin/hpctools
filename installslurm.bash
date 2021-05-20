###
# THIS IS VERSION 2.0 of this script. It is based on the version mentioned
# in ni-sp.com's Copyright statement below.
# 
# Changes: 
#  1. New comments are marked with # >>>>>>>>>>> rather than the row of #.
#  2. Additionally, this is straight-up bash rather than ambiguously shell.
#  3. $result is used as a placeholder for string results from operations
#     that check for things.
###
export __author__="George Flanagin"
export __version_date__=2021
export __version__=2.0 
export __maintainer__="George Flanagin"
export __email__="gflanagin@richmond.edu"
################################################################################
# Copyright (C) 2019-2021 NI SP GmbH
# All Rights Reserved
#
# info@ni-sp.com / www.ni-sp.com
#
# We provide the information on an as is basis. 
# We provide no warranties, express or implied, related to the
# accuracy, completeness, timeliness, useability, and/or merchantability
# of the data and are not liable for any loss, damage, claim, liability,
# expense, or penalty, or for any direct, indirect, special, secondary,
# incidental, consequential, or exemplary damages or lost profit
# deriving from the use or misuse of this information.
################################################################################
# Version v1.1
#
# SLURM 20.11.3 Build and Installation script for Redhat/CentOS EL7 and EL8
# 
# See also https://www.slothparadise.com/how-to-install-slurm-on-centos-7-cluster/
# https://slurm.schedmd.com/quickstart_admin.html
# https://wiki.fysik.dtu.dk/niflheim/Slurm_installation
# https://slurm.schedmd.com/faq.html
# In case of version 7 "Compute Node" was the base for the installation
# In case of version 8 "Server" was the base for the installation
# SLURM accounting support
##################################################################################
# >>>>>>>>>>
# NOTE: update the default version if required.
# >>>>>>>>>>
VER="${VER:-"20.11.7"}"
echo "Loading installation utils."
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

if [[ "$@" =~ "-c" ]]; then
    export run_checks=1
else
    export run_checks=0
fi

if [[ "$@" =~ "-s" ]]; then
    export from_source=1
    export from_packages=0
else
    export from_source=0
    export from_packages=1
fi

for node_type in $@; do :
    done

if (( $verbose == 1 )); then 
    echo "interactive is $interactive" 
    echo "run_checks is $run_checks" 
    echo "verbose is $verbose"
    echo "from_source is $from_source"
    echo "node_type is $node_type"
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
    $0 [-i] [-c] [-v] [-s] {head | compute}

    This script will do its best to install and upgrade the 
    slurm/munge environment on this node of the cluster. At
    the very least, you must specify whether this is to be 
    compute node or the head node.

    If you type > $0 compute

    you will get a no-questions asked, installation from the
    standard packages, skipping the checks at the end.

    -i => interactive. The script will ask you whether you
        want to continue after each step.
    -c => perform sanity checks at the end.
    -s => from source; download the latest tarball, and recompile
        everything. Otherwise, we get packages from the repos,
        and start from that point.
    -v => verbose. Engage in haemorrhagic logorrhoea.

EOF
    exit
    ;;
    
esac


# >>>>>>>>>>
# Identify the right installer. We are going to call it
# dnf no matter what.
# >>>>>>>>>>
find_installer

# begin the anonymous function so we have hidden I/O 
# redirection. See last line of file.
{
echo "Install beginning: `date --iso-8601=minutes`"
# >>>>>>>>>>
# Identify the correct rpm package tool.
# >>>>>>>>>>
export rpmbuilder=$(which rpm-build 2>/dev/null)
if [ -z $rpmbuilder ]; then
    export rpmbuilder=$(which rpmbuild 2>/dev/null)
fi
v_echo "rpmbuilder is $rpmbuilder"

# >>>>>>>>>>>
# Avoid typos by setting this env variable to ensure
# we are installing everything the same way. Might as
# well get the latest and greatest.
# >>>>>>>>>>>
export installit="sudo $dnf -y install" 
export upgradeit="sudo $dnf -y upgrade" 

# >>>>>>>>>>
# Install the up to scratch database.
# >>>>>>>>>>
if ! confirm "Installing database"; then exit; fi
v_echo "installing database"
$installit $database_packages
$upgradeit $database_packages
v_echo "database installed"

# >>>>>>>>>>
# For all the nodes, before you install Slurm or Munge:
# >>>>>>>>>>
# Setup some defaults, and check for previously existing values
# for the slurm and munge users.
# >>>>>>>>>>
if ! confirm "creating slurm and munge users"; then exit; fi
echo "Checking for munge user"
export MUNGEUSER=996
result=$(id -u munge 2>/dev/null)
if [ -z $result ]; then
    sudo groupadd -g $MUNGEUSER munge
    sudo useradd  -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge  -s /sbin/nologin munge
else
    export MUNGEUSER=$result
fi
echo "munge user is $MUNGEUSER"
sudo chown munge:munge /var/log/munge
sudo chmod 700 /var/log/munge

# >>>>>>>>>>>>>>>>>>>
# And now the slurm user.
# >>>>>>>>>>>>>>>>>>>
echo "Checking for slurm user"
export SLURMUSER=967
result=$(id -u slurm 2>/dev/null)
if [ -z $result ]; then
    sudo groupadd -g $SLURMUSER slurm
    sudo useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm
else
    export SLURMUSER=$result
fi
echo "slurm user is $SLURMUSER"

# >>>>>>>>>>>>>>
# install munge
# >>>>>>>>>>>>>>
if ! confirm "installing munge"; then exit; fi
$installit $munge_packages
$upgradeit $munge_packages
sudo rngd -r /dev/urandom

# >>>>>>>>>>>>>>
# do not overwrite the mungekey if this step has been previously done.
# >>>>>>>>>>>>>>
echo "Checking to see if there is already a munge.key"
export mungekey="/etc/munge/munge.key"
key_exists=$(sudo ls $mungekey 2>/dev/null)
if [ -z $key_exists ]; then
    echo "munge.key not found; making one."
    sudo /usr/sbin/create-munge-key -r -f
    sudo chown munge: /etc/munge/munge.key
    sudo chmod 400 /etc/munge/munge.key
fi

# >>>>>>>>>>>>>>>
# Hang onto the hash of the key, and then start munge.
# >>>>>>>>>>>>>>>
key_hash=$(sudo sha1sum /etc/munge/munge.key)
export key_hash=$(for x in $key_hash; do echo $x; break; done)
echo "The hash of munge.key is $key_hash. Starting munge."
sudo systemctl enable munge
if confirm "start the munge daemon"; then
    sudo systemctl start munge
else
    echo "You will need to start the munge daemon later."
fi


# build and install SLURM 
if ! confirm "installing slurm"; then exit; fi

# >>>>>>>>>>>>>>>
# We need to keep these packages up to scratch regardless
# of our install method (source or package).
# >>>>>>>>>>>>>>>
$installit $devel_packages
$upgradeit $devel_packages

if (( $from_source == 1 )); then

    mkdir -p slurm-tmp
    cd slurm-tmp
    wget https://download.schedmd.com/slurm/slurm-$VER.tar.bz2

    $rpmbuilder -ta slurm-$VER.tar.bz2 2>&1 
    # and wait a few minutes until SLURM has been compiled

    cd ..
    rm -fr slurm-tmp 

    mkdir -p ~/rpmbuild/RPMS/x86_64
    cd ~/rpmbuild/RPMS/x86_64/

    # >>>>>>>>>>>>>>
    # Now install the rpms we just built. Our packages are unsigned
    # because we just built them ourselves, so skip that bit of checking
    # >>>>>>>>>>>>>>
    $installit --nogpgcheck localinstall \
        slurm-[0-9]*.x86_64.rpm \
        slurm-contribs-*.x86_64.rpm \
        slurm-devel-*.x86_64.rpm \
        slurm-example-configs-*.x86_64.rpm \
        slurm-libpmi-*.x86_64.rpm  \
        slurm-pam_slurm-*.x86_64.rpm \
        slurm-perlapi-*.x86_64.rpm \
        slurm-slurmctld-*.x86_64.rpm \
        slurm-slurmd-*.x86_64.rpm \
        slurm-slurmdbd-*.x86_64.rpm

else
    $installit $slurm_packages
    $upgradeit $slurm_packages
fi


# >>>>>>>>>>>>
# By this time, we should have slurmd installed, so let's use
# it to find out the config.
# >>>>>>>>>>>>
slurm_cfg=$(slurmd -C | head -1)
export slurm_cfg="$slurm_cfg NodeAddr=$HOST_IP"

if ! confirm "create the slurm.conf file[s]"; then exit; fi
# >>>>>>>>>>>
# create the SLURM default configuration with
# compute nodes called "NodeName=$HOST"
# in a cluster called "cluster"
# and a partition name called "test"
# Feel free to adapt to your needs
# >>>>>>>>>>>>
sudo bash -c "cat > /etc/slurm/slurm.conf" << EOF
# This file was generated on `date` by $0
# 
# slurm.conf file generated by configurator easy.html.
# Put this file on all nodes of your cluster.
# See the slurm.conf man page for more information.
#
SlurmctldHost=localhost
#
#MailProg=/bin/mail
MpiDefault=none
#MpiParams=ports=#-#
ProctrackType=proctrack/cgroup
ReturnToService=1
SlurmctldPidFile=/var/run/slurmctld.pid
#SlurmctldPort=6817
SlurmdPidFile=/var/run/slurmd.pid
#SlurmdPort=6818
SlurmdSpoolDir=/var/spool/slurm/slurmd
SlurmUser=slurm
#SlurmdUser=root
StateSaveLocation=/var/spool/slurm
SwitchType=switch/none
TaskPlugin=task/affinity
#
#
# TIMERS
#KillWait=30
#MinJobAge=300
#SlurmctldTimeout=120
#SlurmdTimeout=300
#
#
# SCHEDULING
SchedulerType=sched/backfill
SelectType=select/cons_res
SelectTypeParameters=CR_Core
#
#
# LOGGING AND ACCOUNTING
AccountingStorageType=accounting_storage/none
ClusterName=cluster
#JobAcctGatherFrequency=30
JobAcctGatherType=jobacct_gather/none
#SlurmctldDebug=info
#SlurmctldLogFile=
#SlurmdDebug=info
#SlurmdLogFile=
#
#
# COMPUTE NODES
#
$slurm_cfg
PartitionName=test Nodes=$HOST Default=YES MaxTime=INFINITE State=UP

# DefMemPerNode=1000
# MaxMemPerNode=1000
# DefMemPerCPU=4000 
# MaxMemPerCPU=4096
EOF

sudo bash -c "cat > /etc/slurm/cgroup.conf" << EOF
# This file was generated on `date` by $0
###
#
# Slurm cgroup support configuration file
#
# See man slurm.conf and man cgroup.conf for further
# information on cgroup configuration parameters
#--
CgroupAutomount=yes
ConstrainCores=no
ConstrainRAMSpace=no
EOF

# >>>>>>>>>>>>>>>>
# Set the ownerships and permissions as required. If they
# are already set, it will not hurt to set them again.
# >>>>>>>>>>>>>>>>

sudo mkdir -p /var/spool/slurm
sudo chown slurm:slurm /var/spool/slurm
sudo chmod 755 /var/spool/slurm
sudo mkdir -p /var/spool/slurm/slurmctld
sudo chown slurm:slurm /var/spool/slurm/slurmctld
sudo chmod 755 /var/spool/slurm/slurmctld
sudo mkdir -p /var/spool/slurm/cluster_state
sudo chown slurm:slurm /var/spool/slurm/cluster_state
sudo touch /var/log/slurmctld.log
sudo chown slurm:slurm /var/log/slurmctld.log
sudo touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
sudo chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

# firewall will block connections between nodes so in case of cluster
# with multiple nodes adapt the firewall on the compute nodes 
if [ $node_type == "compute" ]; then 
    sudo systemctl stop firewalld
    sudo systemctl disable firewalld
fi

# >>>>>>>>>>>>
# On the head node, we need to accept the incoming connections.
# >>>>>>>>>>>>
if [ $node_type == "head" ]; then
    sudo firewall-cmd --permanent --zone=public --add-port=6817/udp
    sudo firewall-cmd --permanent --zone=public --add-port=6817/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=6818/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=6818/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=7321/tcp
    sudo firewall-cmd --permanent --zone=public --add-port=7321/tcp
fi

# >>>>>>>>>>>>
# make the changes active.
# >>>>>>>>>>>>
sudo firewall-cmd --reload


# sync clock on master and every compute node 
$installit $clock_packages
$upgradeit $clock_packages
sudo chkconfig ntpd on
sudo ntpdate pool.ntp.org
sudo systemctl start ntpd

if [ $node_type == "head" ]; then
    sudo systemctl enable slurmctld
    sudo systemctl enable slurmdbd
fi

if [ $node_type == "compute" ]; then 
    sudo systemctl enable slurmd.service
    sudo systemctl start slurmd.service
fi

echo Sleep for a few seconds for slurmd to come up ...
sleep 3

if [ $node_type == "head" ]; then
    # hack for now as otherwise slurmctld is complaining
    sudo chmod 777 /var/spool   
    sudo systemctl start slurmctld.service
    echo Sleep for a few seconds for slurmctld to come up ...
    sleep 3
fi


if (( $run_checks == 1 )); then
    sudo systemctl status slurmd.service
    sudo journalctl -xe

# sudo slurmd -Dvvv -N YOUR_HOSTNAME 
# sudo slurmctld -D vvvvvvvv
# or tracing with sudo strace slurmctld -D vvvvvvvv

# echo Compute node bugs: tail /var/log/slurmd.log
# echo Server node bugs: tail /var/log/slurmctld.log

    # show cluster 
    echo 
    echo Output from: \"sinfo\"
    sinfo

    sinfo -Nle
    echo 
    echo Output from: \"scontrol show partition\"
    scontrol show partition

    # show host info as slurm sees it
    echo 
    echo Output from: \"slurmd -C\"
    slurmd -C

    # in case host is in drain status
    # scontrol update nodename=$HOST state=idle
 
    echo 
    echo Output from: \"scontrol show nodes\"
    scontrol show nodes

    # If jobs are running on the node:
    scontrol update nodename=$HOST state=resume

    # lets run our first job
    echo 
    echo Output from: \"srun hostname\"
    srun hostname

fi
} | tee > "$PWD/installslurm.`date --iso-8601=minutes`.out"
