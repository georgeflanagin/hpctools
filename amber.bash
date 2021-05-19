# Source this script to add the variables necessary to use Amber to your shell.
# This script must be located in the Amber root folder!

# Amber was configured on 2021-05-18 at 13:45:18

source installutils.bash
if no_bash; then
    echo 'You need to start the bash shell (by typing "bash"), and'
    echo " *then* source this file."
    exit
fi

this_script=$0
export AMBERHOME=$(cd "$(dirname "$this_script")"; pwd)
export PATH="$AMBERHOME/bin:$PATH"

# Add Amber lib folder to LD_LIBRARY_PATH (if your platform supports it)
# Note that LD_LIBRARY_PATH is only necessary to help Amber's Python 
# programs find their dynamic libraries, unless Amber has been moved 
# from where it was installed.

if [ -z "$LD_LIBRARY_PATH" ]; then
    export LD_LIBRARY_PATH="$AMBERHOME/lib"
else
    export LD_LIBRARY_PATH="$AMBERHOME/lib:$LD_LIBRARY_PATH"
fi

# Add location of Amber Perl modules to default Perl search path
if [ -z "$PERL5LIB" ]; then
    export PERL5LIB="$AMBERHOME/lib/perl"
else
    export PERL5LIB="$AMBERHOME/lib/perl:$PERL5LIB"
fi

# Add location of Amber Python modules to default Python search path (if your platform supports it)
if [ -z "$PYTHONPATH" ]; then
    export PYTHONPATH="$AMBERHOME/lib/python3.8/site-packages"
else
    export PYTHONPATH="$AMBERHOME/lib/python3.8/site-packages:$PYTHONPATH"
fi

# Tell QUICK where to find its data files
export QUICK_BASIS="$AMBERHOME/AmberTools/src/quick/basis"
