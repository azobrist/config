alias ll="ls -lhA"
alias histg="history | grep "
alias hist="history "
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias fd="find . -name "
alias cd..="cd .."
alias brc='source ~/.bashrc'
alias gitfilehist='git log -p --'
alias gitaligntoremote='git reset --hard @{u}'
qfind(){
	find . -name *$1*
}
cloneoffice(){
	IP="10.70.16.118"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		git clone git@$IP:/opt/git/$1.git
		cd $1
		git remote add office git@$IP:/opt/git/$1.git
	else
		echo "Server not online @$IP"
	fi
}
clonegithub(){
	git clone git@github.com:azobrist/$1.git
	cd $1
}
gitcreateremote(){
	set -e
	PROJ=$(basename $(pwd))
	if [ -d $PROJ.git ]; then
		rm -r $PROJ.git
	fi
	mkdir $PROJ.git && cd $PROJ.git
	git init --bare
	cd ..
	sendto git $PROJ.git
	rm -r $PROJ.git
	git init
	git remote add pi git@$(cat ~/netdevlist/git):~/$PROJ.git
	gitfixes
}
gitfixes(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "Fixing $BRANCH"
	gitshortdiff | sed /^.gitfixes/d > .gitfixes
	FILES=$(git diff --name-only)
	git add .
	STR=$'quick fix - see .gitfixes\n$FILES'
	git commit -m "$STR"
	git push origin $BRANCH
}
gitcommit(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "Finishing $BRANCH"
	git add .
	git commit -m "$1"
	git push pi $BRANCH
}
gitupdate(){
	if [ $# -eq 1 ]; then
		BRANCH=$1
		echo "Fetching $BRANCH"
		git fetch origin $BRANCH
	else
		BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
		echo "Updating $BRANCH"
		git pull origin $BRANCH
	fi
}
gitignore(){
	if [ -d .git ]; then
		if [ ! -f .gitignore ]; then
			touch .gitignore
		fi
		echo "Adding $1 to .gitignore"
		echo $1 >> .gitignore
	else
		echo "Not a git repo"
	fi
}
shellme(){
	echo "#!/bin/bash" > $1.sh
	chmod +x $1.sh
	if [ $# -gt 1 ]; then
		isnum $2
		if [ $? -eq 0 ]; then
			echo "history pulled"
			history $2 | cut -c 8- >> $1.sh
		else
			echo "need to enter number $2"
		fi	
	else
		vim $1.sh
	fi
}
knockknock(){
	IP="$1"
	if [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
		ping $IP -n 1 | grep "Destination Host Unreachable" > /dev/null
	else
		ping -q -c1 $IP | grep "Destination Host Unreachable" > /dev/null
	fi
	if [ $? -ne 0 ]; then
		echo "who's there??"
	else
		echo ""
	fi 
}
getfrom(){
	if [ $# -eq 0 ]; then
		echo "getfrom <device> <path/to/file>"
		exit 1
	fi
	DEV=$1
	DIR=$2
	OPT=$3
	IP=$(cat ~/netdevlist/$DEV)
	echo "getting $2 from $DEV@$IP:~/$DIR"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		scp $OPT $DEV@$IP:~/$DIR .
	else
		echo "Sever not online @$IP"
	fi
}
sendto(){
	DEV=$1
	IP=$(cat ~/netdevlist/$DEV)
	FILE=${2##*/}
	echo "sending $FILE to $DEV@$IP:~/$2"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		if [ -d $FILE ]; then
			scp -r $FILE  $DEV@$IP:~/$2
		else
			scp $FILE $DEV@$IP:~/$2
		fi
	else
		echo "Sever not online @$IP"
	fi
}
connect(){
	DEV=$1
	IP=$(cat ~/netdevlist/$DEV)
	echo "connecting to $DEV@$IP terminal"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		ssh $DEV@$IP
	else
		echo "Sever not online @$IP"
	fi	
}
addnetdev(){
	DEV=$1
	IP=$2
	if [ ! -d ~/netdevlist ]; then
		echo "creating netdevlist dir"
		mkdir ~/netdevlist
	fi
	echo "$IP" > ~/netdevlist/$DEV
}
addnetdir(){
	DIR=$1
	echo "$DIR" >> ~/netdevlist/common
}
gitshortdiff() {
	git diff | diff-lines
}
diff-lines() {
    local path=
    local line=
    while read; do
        esc=$'\033'
        if [[ $REPLY =~ ---\ (a/)?.* ]]; then
            continue
        elif [[ $REPLY =~ \+\+\+\ (b/)?([^[:blank:]$esc]+).* ]]; then
            path=${BASH_REMATCH[2]}
        elif [[ $REPLY =~ @@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+)(,[0-9]+)?\ @@.* ]]; then
            line=${BASH_REMATCH[2]}
        elif [[ $REPLY =~ ^($esc\[[0-9;]+m)*([\ +-]) ]]; then
            echo "$path:$line:$REPLY"
            if [[ ${BASH_REMATCH[2]} != - ]]; then
                ((line++))
            fi
        fi
    done
}
isnum(){
	echo $1 | grep "^[ [:digit:] ]*$"
}
