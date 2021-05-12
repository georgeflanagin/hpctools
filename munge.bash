##############
# munge
##############

export mungepid="/run/munge/munged.pid"

munge()
{
    case "$1" in 
        "")
    cat - <<EOF

Usage: 
    munge {start|stop|restart|test}

Note that this script will do the job safely
and repeatably. `munge test` will ensure that
the software is correctly installed /locally/.

EOF
        ;;

        "stop")
        sudo systemctl stop munge
        if [ -f "$mungepid" ]; then
            echo "Munge not responding; sending SIGTERM"
            kill -SIGTERM `cat $mungepid`
            sleep 1
            if [ -f "$mungepid" ]; then
                echo "Munge is still not responding. Cannot continue."
                return
            fi
        fi
        ;;

        "start")
        sudo systemctl start munge
        result=$?
        if [ ! -f "$mungepid" ]; then
            echo "Munge did not start: reason is $result"
            return
        else
            ps -ef | sed -n "1p; /$1/p;" | grep -v 'sed -n'
        fi
        ;;

        "restart")
        munge stop
        munge start
        ;;

        "test")
        munge -n | unmunge
        if [ ! $? ]; then
            echo "There was a problem encoding and decoding credentials."
            return
        fi  

    esac
}

mungeinstall()
{
    r=`which munge`
    if [ ! -z "$r" ]; then
        echo "munge is already installed. You must remove it first."
        return
    fi
    
    f="/tmp/munge.tombstone"
    rm "$f"
    touch "$f"

    echo "Installing munge" 
    sudo dnf -y install munge 2>&1 >> $f
    if [ ! $? ]; then 
        echo "There was a problem installing munge."
        return
    fi

    sudo dnf -y install munge-libs munge-devel 2>&1 >> $f
    if [ ! $? ]; then 
        echo "There was a problem installing munge-libs and munge-devel."
        return
    fi

    sudo /usr/sbin/create-munge-key 2>&1 >> $f  
    if [ ! $? ]; then 
        echo "There was a problem creating the munge.key file."
        return
    fi

    echo "setting permissions for munge"
    sudo chmod 700 /etc/munge 2>&1 >> $f
    sudo chmod 700 /var/lib/munge 2>&1 >> $f
    sudo chmod 700 /var/log/munge 2>&1 >> $f
    sudo chmod 755 /run/munge 2>&1 >> $f
    
    echo "The results may be seen in $f"
}
