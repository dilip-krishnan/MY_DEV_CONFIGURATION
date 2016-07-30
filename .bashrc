# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

#Config Magicmonty prompt
# Set config variables first
GIT_PROMPT_ONLY_IN_REPO=1

# GIT_PROMPT_FETCH_REMOTE_STATUS=0   # uncomment to avoid fetching remote status
# GIT_PROMPT_SHOW_UPSTREAM=1 # uncomment to show upstream tracking branch
# GIT_PROMPT_SHOW_UNTRACKED_FILES=all # can be no, normal or all; determines counting of untracked files

# GIT_PROMPT_STATUS_COMMAND=gitstatus_pre-1.7.10.sh # uncomment to support Git older than 1.7.10
# GIT_PROMPT_START=...    # uncomment for custom prompt start sequence
# GIT_PROMPT_END=...      # uncomment for custom prompt end sequence

# as last entry source the gitprompt script
# GIT_PROMPT_THEME=Custom # use custom theme specified in file GIT_PROMPT_THEME_FILE (default ~/.git-prompt-colors.sh)
# GIT_PROMPT_THEME_FILE=~/.git-prompt-colors.sh
# GIT_PROMPT_THEME=Solarized # use theme optimized for solarized color scheme
source ~/.bash-git-prompt/gitprompt.sh
# Uncomment the following line if you don't like systemctl's auto-paging feature:

# export SYSTEMD_PAGER=

export PATH=/usr/local/git/bin/:/home/dilipk/.emacs.d/elpa/elpy-20160613.1005/:$PATH
export PYTHONPATH=/home/dilipk/.emacs.d/elpa/elpy-20160613.1005/:$PYTHONPATH
export PYTHONPATH=/home/dilipk/workspace/pbspro/test/tests/:$PYTHONPATH

# User specific aliases and functions
alias e='emacs -nw'
alias po='cd /home/dilipk/workspace/pbspro/target'
alias pp='cd /home/dilipk/workspace/pbspro-private/target'


#=========================================Functions===============================================================


po_dir='/home/dilipk/workspace/pbspro/target'
pp_dir='/home/dilipk/workspace/pbspro-private/target'

function pbs() {
    sudo service pbs $@;
}

function v_branch() {
    if [ $1 = 'po' ];
    then
	cd '/home/dilipk/workspace/pbspro/target'
    elif [ $1 = 'pp' ];
    then
	cd '/home/dilipk/workspace/pbspro-private/target';
    else
	echo 'Not a valid branch\n';
	return 1;
    fi
    return 0
}

function configure_pbs() {
    if [ -e './Makefile' ];
    then
	sudo make distclean > /dev/null 
    fi
    echo "Running configure"
    sudo ../configure --prefix=/opt/pbs/>/tmp/pbs_configure.log

    if [ $? -eq 0 ];
    then
	echo "Configure PASSED"
    else
	echo "Configure FAILED"
	echo ""
	tailf "/tmp/pbs_cofigure.log"
	echo "For full log check:"
	echo "/tmp/pbs_configure.log"
	exit 1
    fi

}

function pi(){

    cwd=$(pwd);

    if [ $cwd != $po_dir -a $cwd != $pp_dir  ];
    then
	echo 'Select to build: pp(pbspro private) po(pbspro public)';
	read branch
	v_branch $branch
	if [ $? -ne 0 ];
	then
	    return 1
	fi
    fi

    sudo service pbs stop
    if [ $? -ne 0 ];
    then
	echo unable to stop pbs
	return 1
    fi
    if [ $2 = 'd' ];
    then
	echo "Deleting old pbs directory"
	source /etc/pbs.conf
       	sudo rm -rf $PBS_EXEC
	sudo rm -rf $PBS_HOME
	sudo rm -f /etc/pbs.conf*
    fi

    if [ $1 = 'c' ];
    then
	echo "./configure PBS"
	configure_pbs
    else
	if [ ! -e 'Makefile' ];
	then
	    configure_pbs
	fi
    fi

    echo "Compiling source"
    sudo make>/tmp/pbs_make.log

    if [ $? -eq 0 ];
    then
	echo Compilation PASSED
    else
	echo Compilation FAILED
	tail -f "/tmp/pbs_make.log"
	echo "For full log check:"
	echo "/tmp/pbs_make.log"
	return 1
    fi

    echo "Installing PBS"
    sudo make install>/tmp/pbs_install.log
    if [ $? -eq 0 ] ;
    then
	echo "Installation PASSED -- HOORAY :)"
    else
	echo "Installation FAILED -- Oops :("
	tailf "/tmp/pbs_install.log"
	echo "For full log check:"
	echo "/tmp/pbs_install.log"
	return 1
    fi
    echo "" >> /tmp/pbs_install.log
    echo "Post installation steps">>/tmp/pbs_install.log
    sudo /opt/pbs/libexec/pbs_postinstall>>/tmp/pbs_install.log
    if [ $? -eq 0 ] ; then
	echo Post Install PASSED
    else
	echo Post Install FAILED
	tailf "/tmp/pbs_make.log"
	echo "For full log check:"
	echo "/tmp/pbs_make.log"
	return 1
    fi

    sudo chmod 4755 /opt/pbs/sbin/pbs_iff
    sudo chmod +x /etc/profile.d/pbs.sh

    echo "Editing pbs.conf file"
    sudo sed -i -e 's/\(SERVER=\)0/\11/' /etc/pbs.conf
    sudo sed -i -e 's/\(SCHED=\)0/\11/' /etc/pbs.conf
    sudo sed -i -e 's/\(MOM=\)0/\11/' /etc/pbs.conf
    sudo sed -i -e 's/\(COMM=\)0/\11/' /etc/pbs.conf
    cat '/etc/pbs.conf'

    sudo /etc/profile.d/pbs.sh
    sudo service pbs start
}

