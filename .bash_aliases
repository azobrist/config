alias ll="ls -lhA"
alias histg="history | grep "
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
gcsvr(){
	git clone git@10.70.16.118:/opt/git/$1.git
}
gcpi(){
	git clone git@10.70.56.20:~/$1.git
}
