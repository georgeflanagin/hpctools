export me=$(whoami)

myjobs()
{
    echo "Jobs for $me"
    squeue --me
}

nodes()
{
    case "$1" in
        "")
        # Let's assume help in required.
        cat - <<EOF
The nodes command allows you to get information about the
nodes in the cluster. The syntax is:

    nodes {what-you-want-to-know-about}

The options are:

    free    -- show the idle nodes available for assignment.
    avail   -- same as free
    info    -- a more nicely formatted output from <sinfo>
    queues  -- a more nicely formatted output from <squeue>

EOF
        ;;
 
        free|avail)
        sinfo | grep "idle"
        ;;

        info)
        sinfo -o "%20P %5D %14F %8z %10m %10d %11l %16f %N"
        ;;

        queues)
        squeue -o "%8i %12j %4t %10u %20q %20a %10g %20P %10Q %5D %11l %11L %R"
        ;;

    esac
}

submit()
{
    case "$1" in
        "")
        # Help out the user.
        cat - <<EOF
The submit command allows you to submit slurm jobs in
batch mode (the usual way of doing things). You can provide
the name of your job with or without the ".slurm" on the end
of the file name. You can also submit multiple jobs at the
same time. Here are some examples:

    submit myjob.slurm -- tells slurm to run myjob.slurm
    submit myjob  -- tells slurm to run myjob.slurm
    submit myjob* -- tells slurm to run any slurm jobs whose
        names start with "myjob"

Assuming something has been submitted, you will see your running
jobs summarized at the end of the command.
EOF
    return
    ;;
    esac

    script="$1"
    candidates=$(ls -1 $script)    
    if [ -z $candidates ]; then
        candidates=$(ls -1 $script.slurm)
    fi
    if [ -z $candidates ]; then 
        submit
        return
    fi

    for f in $candidates; do 
        echo "Submitting batch job $f"
        myname=`basename $f`
        sbatch -J $myname --parsable "$f"
    done;
    myjobs
}

slurm()
{
    case "$1" in 
        #######################
        "")
        cat - <<EOF
Usage:
    slurm {check|install|start|stop|restart|config}

        check     -- checks that the parts are all present.
        install   -- performs a basic install.
        start     -- starts the slurmd.
        stop      -- stops the slurmd.
        restart   -- stops, and then starts.
        config    -- shows the config info for this node.
EOF
        ;;

        #######################
        "check")
        echo "Checking for munge"
        find /usr -name munge 2>/dev/null | grep . 
        if [ ! $? ]; then 
            echo "munge not found"
            return
        fi

        echo "Checking for the mungekey"
        sudo ls -l /etc/munge/munge.key
        sudo sha1sum /etc/munge/munge.key
        if [ ! $? ]; then
            echo "munge.key not present." 
        fi

        echo "Checking for slurm user"
        found=`cat /etc/passwd | grep slurm` 
        if [ -z "$found" ]; then
            echo "slurm user not present"
            return
        else
            echo "$found"
        fi

        echo "Checking slurm.conf file."
        ls -l /etc/slurm/*conf

        echo "Checking slurm config"
        slurmd -C 
        if [ ! $? ]; then
            echo "Could not get config."
            return
        fi
        ;;



        #######################
        "install")
        f="/tmp/slurm.tombstone"
        rm -f "$f"
        touch "$f"
        ./slurm_install.bash 2>&1 | tee "$f"

#        r=`which sbatch`
#        if [ ! -z $r ]; then
#            echo 'Slurm is already installed.'
#            return
#        fi
#
#        sudo dnf install slurm slurm-devel 2>&1 >> "$f"
#        if [ ! $? ]; then
#            echo "Unable to install slurm"
#        fi
#
#        sudo dnf install mariadb-server mariadb-devel 2>&1 >> "$f"
#        if [ ! $? ]; then
#            echo "Unable to install mariadb."
#        fi 
#
#        if [ -z "$2" ]; then
#            sudo touch /var/log/slurmd.log
#            sudo chown slurm:slurm /var/log/slurmd.log
#        else
#            sudo touch /var/log/slurmctld.log
#            sudo chown slurm:slurm /var/log/slurmctld.log
#        fi
        ;;

        #######################
        "start")
        if [ -f "/var/log/slurmd.log" ]; then
            sudo systemctl start slurmd.service
            sudo systemctl status slurmd.service
        elif [ -f "/var/log/slurmctld.log" ]; then
            sudo systemctl start slurmctld.service
            sudo systemctl status slurmctld.service
        else
            echo "This CPU has not yet been configured."
            return
        fi
        ;;

        #######################
        "stop")
        if [ -f "/var/log/slurmctld.log" ]; then
            sudo systemctl stop slurmctld.service
        else
            sudo systemctl stop slurmd.service
        fi
        if [ ! $? ]; then 
            echo "Unable to stop slurm on this node."
            return
        fi
        ;;

        #######################
        "restart")
        slurm stop 
        sleep 1
        slurm start
        ;;

        #######################
        "config")
            case "$2" in
                "")
                cat - <<EOF
Usage:
    slurm config {compute|head|show} 

    where 
        compute -- configure a compute node.
        head    -- configure a head node.
        db      -- configure a db node.
        show    -- show the configuration of this node.

    NOTE: all the commands show the config at the end of their 
        operation.
EOF
                ;;


                # >>>>>>>>>>>>>>>>>>>>>>>>
                "compute")
                echo "Creating spool dirs and files"
                sudo mkdir -p /var/spool/slurmd
                sudo chown slurm:slurm /var/spool/slurmd
                sudo chmod 755 /var/spool/slurmd

                echo "Creating logfiles."
                sudo touch /var/log/slurmd.log
                sudo slurm:slurm /var/log/slurmd.log

                echo "Enabling the slurmd daemon."
                sudo systemctl enable slurmd.service
                ;;


                # >>>>>>>>>>>>>>>>>>>>>>>>
                "head")
                echo "Creating spool dirs and files"
                sudo mkdir -p /var/spool/slurmctld
                sudo chown slurm:slurm /var/spool/slurmctld
                sudo chmod 755 /var/spool/slurmctld

                echo "Creating logfiles."
                sudo touch /var/log/slurmctld.log
                sudo chown slurm:slurm /var/log/slurmctld.log

                echo "Creating the accouting file."
                sudo touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
                sudo chown slurm:slurm /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log

                echo "Enabling the slurmctld daemon."
                sudo systemctl enable slurmctld.service
                ;;


                # >>>>>>>>>>>>>>>>>>>>>>>>
                "db")
                ;;

                # >>>>>>>>>>>>>>>>>>>>>>>>
                "show")
                slurmd -C
                ;;


            esac
            ;;

    esac
}

