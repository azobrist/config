alias ll="ls -lhA"
alias histg="history | grep "
alias hist="history "
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias fd="find . -name "
alias cd..="cd .."
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
savefixes(){
	IP="10.70.56.40"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		git add .
		git commit -m "fixes - no time to explain"
		git push pi master
	else
		echo "Sever not online @$IP"
	fi
}
gitfinish(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($i=="On branch")print $(i+1)}')
	echo "On branch $BRANCH"
	git add .
	git commit -m "$1"
	git push pi $BRANCH
}
gitupdate(){
	BRANCH=$(git st | awk '{for(i=1;i<=NF;i++)if($(i-1)=="On"&&$i=="branch")print $(i+1)}')
	echo "On branch $BRANCH"
	git pull pi $BRANCH
}
savetesting(){
	IP="10.70.56.40"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		git add .
		git commit -m "fixes - no time to explain"
		git push pi testing
	else
		echo "Sever not online @$IP"
	fi
}
updatepi(){
	IP="10.70.56.40"
	if [ "$(knockknock $IP)" == "who's there??" ];then 
		git pull pi master
	else
		echo "Sever not online @$IP"
	fi
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
getnvidia(){
	IP="10.70.56.37"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		scp nvidia@$IP:~/$1 .
	else
		echo "Sever not online @$IP"
	fi
}
putnvidia(){
	IP="10.70.56.37"
	if [ "$(knockknock $IP)" == "who's there??" ];then
		scp $1 nvidia@$IP:~/$2
	else
		echo "Sever not online @$IP"
	fi
}
