alias ll="ls -lhA"
alias histg="history | grep "
alias hist="history "
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias fd="find . -name "
alias cd..="cd .."
alias brc='source ~/.bashrc'
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
clonepi(){
	IP="10.70.56.40"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		git clone git@$IP:~/$1.git
		cd $1
		git remote add pi git@$IP:~/$1.git
	else
		echo "Server not online @$IP"
	fi
}
gitcreate(){
	PROJ=$1
	mkdir $PROJ && cd $PROJ
	git init
}
gitremoteinit(){
	PROJ=$(basename $(pwd))
	mkdir $PROJ.git && cd $PROJ.git
	git init --bare
	cd ..
	sendto git $PROJ.git
	rm -r $PROJ.git
	git remote add pi git@$(cat ~/devicelist/git):~/$PROJ.git
}
gitstart(){
	git init
	git add .
	git commit -m "first commit"
	git push pi master
}
gitfixes(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "Fixing $BRANCH"
	IP="10.70.56.40"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		gitshortdiff | sed /^gitfixes/d > gitfixes.log
		FILES=$(git diff --name-only)
		git add .
		git commit -m "random fixes - $FILES"
		git push pi $BRANCH
	else
		echo "Sever not online @$IP"
	fi
}
gittest(){
	if [ $# -eq 1 ]; then
		BRANCH=$1
	else
		BRANCH="feature_test"
	fi
	echo "Testing $BRANCH"
	git branch $BRANCH
	git co $BRANCH
	git add .
	git commit -m "first commit of feature branch - $BRANCH"
	git push pi $BRANCH
}
gitfinish(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "Finishing $BRANCH"
	git add .
	git commit -m "$1"
	git push pi $BRANCH
}
gitupdate(){
	if [ $# -eq 1 ]; then
		BRANCH=$1
	else
		BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	fi
	echo "Updating $BRANCH"
	git pull pi $BRANCH	
}
gitignore(){
	if [ -d .git ]; then
		if [ ! -f ./.gitignore ]; then
			touch ./.gitignore
		fi
		echo "Adding $1 to .gitignore"
		echo $1 >> ./.gitignore
	else
		echo "Not a git repo"
	fi
}
shellme(){
	echo "#!/bin/bash" > $2.sh
	history | tail -$1 | cut -c 8- >> $2.sh
}
knockknock(){
	IP="$1"
	if [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
		ping $IP -n 1 > /dev/null
	else
		ping -q -c1 $IP > /dev/null
	fi
	if [ $? -eq 0 ] 
	then
		echo "who's there??"
	else
		echo ""
	fi 
}
getfrom(){
	if [ $# -eq 0 ]; then
		echo "getdev <device> <path/to/file>"
		exit 1
	fi
	DEV=$1
	IP=$(cat ~/devicelist/$DEV)
	echo "getting $2 from $DEV@$IP:~/$2"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		scp $DEV@$IP:~/$2 .
	else
		echo "Sever not online @$IP"
	fi
}
sendto(){
	DEV=$1
	IP=$(cat ~/devicelist/$DEV)
	echo "sending $2 to $DEV@$IP:~/$2"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		if [ -d $2 ]; then
			scp -r $2 $DEV@$IP:~/$2
		else
			scp $2 $DEV@$IP:~/$2
		fi
	else
		echo "Sever not online @$IP"
	fi
}
connect(){
	DEV=$1
	IP=$(cat ~/devicelist/$DEV)
	echo "connecting to $DEV@$IP terminal"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		ssh $DEV@$IP
	else
		echo "Sever not online @$IP"
	fi	
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
