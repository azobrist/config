alias ll="ls -lhA"
alias histg="history | grep "
alias hist="history "
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
#alias fd="find . -name "
alias cd..="cd .."
alias brc='source ~/.bashrc'
alias gitfilehist='git log -p --'
alias gitaligntoremote='git reset --hard @{u}'
alias notetake='vim $(date +%d-%m-%Y_%H%M%S)'
alias pip=pip3
alias python=python3
alias py=python3.10
alias psa='ps aux | grep'
alias workdir='basename $(pwd)'
alias gitdiffside='git -c delta.side-by-side=true show'
source ~/config/auto.bash
# wrapit(){ 
# 	echo $("$1" | tr --delete '\n') #sed '$!s/$/ \\/' 
# }
transfer(){ if [ $# -eq 0 ];then echo "No arguments specified.\nUsage:\n  transfer <file|directory>\n  ... | transfer <file_name>">&2;return 1;fi;if tty -s;then file="$1";file_name=$(basename "$file");if [ ! -e "$file" ];then echo "$file: No such file or directory">&2;return 1;fi;if [ -d "$file" ];then file_name="$file_name.zip" ,;(cd "$file"&&zip -r -q - .)|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null,;else cat "$file"|curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;fi;else file_name=$1;curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name"|tee /dev/null;fi;}
catcsv(){
	cat $1 | sed 's/,/ ,/g' | column -t -s, 
}
exportpath(){
	export PATH=$PATH:$1
}
txtcmp(){
	hash colordiff diff-highlight pv
	if [[ $? -ne 0 ]] || [[ $# -ne 2 ]]; then
		return
	fi
	diff -u $1 $2 | colordiff | diff-highlight
}
bincmp(){
	hash colordiff diff-highlight pv
	if [[ $? -ne 0 ]] || [[ $# -ne 2 ]]; then
		return
	fi
	pv $1 | od -x > $1.tmp
        pv $2 | od -x > $2.tmp	
	diff -u $1.tmp $2.tmp | colordiff | diff-highlight
	rm $1.tmp $2.tmp	
}
cleandockercontainers(){
	hash docker 2>/dev/null || { echo >&2 "I require docker but it's not installed.  Aborting."; return; }	
	read -p "This will wipe all containers off this machine!! Enter to continue..."
	docker rm $(docker ps -a -q)
}
cleandockerimages(){
	hash docker 2>/dev/null || { echo >&2 "I require docker but it's not installed.  Aborting."; return; }
	read -p "This will wipe all images off this machine!! Enter to continue..."
	docker rmi $(docker images -a -q)
}
qfind(){
	find . -name *$1*
}
clonework(){
	IP="10.70.16.118"
	if [[ "$(knockknock $IP)" == "who's there??" ]];then
		git clone git@$IP:/opt/git/$1.git
		cd $1
		git remote add office git@$IP:/opt/git/$1.git
	else
		echo "Server not online @$IP"
	fi
}
clonegithub(){
	git clone git@github.com:azobrist/$1.git
	if [[ $? -ne 0 ]]; then
		echo "device key not recognized"
		git clone git@github.com:azobrist/$1.git
	fi
	cd $1
}
gitworkcreate(){
	if [[ ! -f ~/netdevlist/gitwork ]]; then
		echo "need to add local server network to netdevlist"
		return
	fi
	name=$(basename $(pwd))
	if [[ -d $name.git ]]; then
		rm -r $name.git
	fi
	mkdir $name.git && cd $name.git
	git init --bare
	cd ..
	sendto gitwork /opt/git/$name.git
	rm -r $name.git
	git init
	git remote add origin git@$(cat ~/netdevlist/gitwork):~/$name.git
	gitfixes
}
startproject(){
	if [[ $# -eq 1 ]]; then
		name=$1
	else
		name=$(basename $(pwd))
	fi
	githubcreatepublic $name
	if [[ $? -ne 0 ]]; then
		git init
		git remote add origin git@github.com:azobrist/$name.git
		gitfixes
	else
		echo "failed to create github repo, local project untouched"
	fi
}
githubcreateprivate(){
	repo_name=$1
	test -z $repo_name && echo "Repo name required." 1>&2
	if [[ $? -ne 0 ]]; then
		echo "creating public repo $repo_name"
		curl -u 'azobrist' https://api.github.com/user/repos -d "{\"name\":\"$repo_name\",\"private\":\"true\"}" | grep "Bad credentials\|Repository creation failed"	
		return $?
	fi
}
githubcreatepublic(){
	repo_name=$1
	test -z $repo_name && echo "Repo name required." 1>&2
	if [[ $? -ne 0 ]]; then
		echo "creating public repo $repo_name"
		curl -u 'azobrist' https://api.github.com/user/repos -d "{\"name\":\"$repo_name\"}" | grep "Bad credentials\|Repository creation failed"	
		return $?
	fi
}
gitfixes(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "Fixing $BRANCH"
	gitlinediff | sed /^.gitfixes/d > .gitfixes
	FILES=$(git diff --name-only)
	git add .
	STR=$'quick fix - see .gitfixes\n'
	git commit -m "$STR$FILES"
	git push origin $BRANCH
}
gitsmartcommit(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "Smart Commiting $BRANCH"
	git diff --staged | diff-lines | sed /^.gitfixes/d > .gitfixes
	git add .gitfixes
	FILES=$(git diff --name-only --staged)
	STR=$'files modified - see .gitfixes for all modifications\n'
	git commit -m "$STR$FILES"
	if [[ $? -eq 0 ]]; then
		git commit --amend
	else
		echo "nothing staged to commit"
		git co -- .gitfixes
	fi
}
gitpushcommit(){
	if [[ $# -eq 0 ]]; then
		echo "need to give commit msg"
	fi
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "Finishing $BRANCH"
	git add .
	git commit -m "$1"
	git push pi $BRANCH
}
gitupdate(){
	if [[ $# -eq 1 ]]; then
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
	if [[ -d .git ]]; then
		if [[ ! -f .gitignore ]]; then
			touch .gitignore
		fi
		for i in $@
		do
			echo "Adding $i to .gitignore"
			echo $i >> .gitignore
		done
	else
		echo "Not a git repo"
	fi
}
shellme(){
	if [[ $# -eq 0 ]]; then
		echo "shellme name {#lines}"
		return
	fi
	echo "#!/bin/bash" > $1.sh
	chmod +x $1.sh
	if [[ $# -gt 1 ]]; then
		isnum $2 >/dev/null
		if [[ $? -eq 0 ]]; then
			echo "last $2 cmds in history pulled"
			let rng=$2+1
			history $rng | cut -c 8- >> $1.sh
			sed -i '$ d' $1.sh
			echo "$1 created"
		else
			echo "need to enter number not: $2"
		fi	
	else
		vim $1.sh
	fi
}
knockknock(){
	echo $1 | grep @ -q
	if [[ $? -eq 0 ]]; then
		IP=$(echo $1 | sed 's/.*@//')
	else
		IP=$1
	fi
	ping -c1 $IP | grep "Destination Host Unreachable" > /dev/null
	if [[ $? -ne 0 ]]; then
		echo "who's there??"
	else
		echo ""
	fi 
}
getfrom(){
	if [[ $# -eq 0 ]]; then
		echo "getfrom <device> </path/to/file>"
		return
	fi
	DEV=$1
	OPT=$3
	LOC=$(cat ~/netdevlist/$DEV)
	echo "getting $2 from $LOC"
	if [[ "$(knockknock $LOC)" == "who's there??" ]];then
		rsync -aP $OPT $LOC:$2 .
	else
		echo "Sever not online $LOC"
	fi
}
sendto(){
	DEV=$1
	LOC=$(cat ~/netdevlist/$DEV)
	USR=$(echo $LOC | sed 's/@.*//')
	FILE=${2}
	DEST=$LOC:/home/$USR/$2
	echo "sending $FILE to $DEST"	
	if [[ "$(knockknock $LOC)" == "who's there??" ]];then
		if [[ -d $FILE ]]; then
			scp -r $FILE $DEST
		else
			scp $FILE $DEST
		fi
	else
		echo "Sever not online $LOC"
	fi
}
connect(){
	DEV=$1
	LOC=$(cat ~/netdevlist/$DEV)
	echo "connecting to $LOC terminal"
	if [[ "$(knockknock $LOC)" == "who's there??" ]];then
		ssh $LOC
	else
		echo "Sever not online $LOC"
	fi	
}
addnetdev(){
	DEV=$1
	LOC=$2
	if [[ ! -d ~/netdevlist ]]; then
		echo "creating netdevlist dir"
		mkdir ~/netdevlist
	fi
	echo "$LOC" > ~/netdevlist/$DEV
}
addnetdir(){
	DIR=$1
	echo "$DIR" >> ~/netdevlist/common
}
aptrestoretools(){
	list=~/config/apttools
	sudo apt install -y $(grep -vE "^\s*#" $list | tr "\n" " ")
}
aptaddtool(){
	list=~/config/apttools
	if [[ ! -f $list ]]; then
		touch $list
	fi
	echo "$1" >> $list
	sudo apt install -y $1
}
gitlinediff() {
	if [[ $# -eq 2 ]]; then
		git diff $1 $2 --color=always | diff-lines
	elif [[ $# -eq 1 ]]; then
		git diff $1 --color=always | diff-lines
	else
		git diff --color=always | diff-lines
	fi
}
diff-lines() {
    local path=
    local line=
    while read; do
        esc=$'\033'
        if [[ $REPLY =~ "---\ (a/)?.*" ]]; then
            continue
        elif [[ $REPLY =~ "\+\+\+\ (b/)?([^[:blank:]$esc]+).*" ]]; then
            path=${BASH_REMATCH[2]}
        elif [[ $REPLY =~ "@@\ -[0-9]+(,[0-9]+)?\ \+([0-9]+)(,[0-9]+)?\ @@.*" ]]; then
            line=${BASH_REMATCH[2]}
        elif [[ $REPLY =~ "^($esc\[[0-9;]+m)*([\ +-])" ]]; then
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
