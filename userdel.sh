#!/bin/bash

#Empty check function
function empty_check {
	if [ -z $1 ]; then
		echo "Error: Variable could not be empty"
	exit 1
	fi
}

#Input data
read -p "Type username fot deletion: " USERNAME
empty_check $USERNAME

for serv in $(cat ipfile.txt); do
	echo "Deleting user ${USERNAME} from host ${serv}... "
	if ! ssh -q $serv id -u $USERNAME >/dev/null 2>&1; then
		echo
		echo "User ${USERNAME} does not exists on ${serv}, please select another username"
		exit 1
	fi
	ssh -q $serv /usr/sbin/userdel -rf $USERNAME
	ssh -q $serv 'sed -i "/'${USERNAME}'/d" /etc/sudoers'
	echo 'Done'
done
