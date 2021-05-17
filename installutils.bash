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

