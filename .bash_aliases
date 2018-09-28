alias ll="ls -lhA"
alias histg="history | grep "
alias hist="history "
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias fd="find . -name "
alias cd..="cd .."
cloneoffice(){
	IP="10.70.16.118"
	if [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
		ping $IP -n 1 > /dev/null
	else
		ping -q -c1 $IP > /dev/null
	fi
	if [ $? -eq 0 ]; then
		git clone git@$IP:~/$1.git
	else
		echo "Server not online @$IP"
	fi
}
clonepi(){
	IP="10.70.56.40"
	if [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
		ping $IP -n 1 > /dev/null
	else
		ping -q -c1 $IP > /dev/null
	fi 
	if [ $? -eq 0 ]; then
		git clone git@$IP:~/$1.git
	else
		echo "Server not online @$IP"
	fi
}
savepi(){
	IP="10.70.56.40"
	if [ "$(expr substr $(uname -s) 1 6)" == "CYGWIN" ]; then
		ping $IP -n 1 > /dev/null
	else
		ping -q -c1 $IP > /dev/null
	fi 
	if [ $? -eq 0 ] 
	then
		git add .
		git commit -m "saved: $1"
		git push pi master
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
