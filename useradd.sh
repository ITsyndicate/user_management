#!/bin/bash

#Empty check function
function empty_check {
	if [ -z $1 ]; then
		echo "Error: Variable could not be empty"
	exit 1
	fi
}

#Input data
read -p "Type name of the new user: " USERNAME
empty_check $USERNAME
read -sp "Type password of the new user (will be not displayed): " USERPASS
empty_check $USERPASS
echo
read -p "If you have SSH-key, type it: " SSHKEY

for serv in $(cat ipfile.txt); do
	echo -n "Adding user ${USERNAME} to host ${serv}... "
	if ssh -q $serv id -u $USERNAME >/dev/null 2>&1; then
		echo
		echo "User ${USERNAME} exists on ${serv}, please select another username"
		exit 1
	fi
	ssh -q $serv /usr/sbin/useradd -m -s /bin/bash $USERNAME
	ssh -q $serv 'echo "'${USERNAME}':'${USERPASS}'" | /usr/sbin/chpasswd'
	if [ -n "$SSHKEY" ]; then
		ssh -q $serv mkdir /home/${USERNAME}/.ssh
		ssh -q $serv 'echo "'$SSHKEY'" > /home/'${USERNAME}'/.ssh/authorized_keys'
		ssh -q $serv chown -R ${USERNAME}.${USERNAME} /home/${USERNAME}
	fi
	ssh -q $serv 'echo "'${USERNAME}' ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
	ssh -q $serv 'echo "Defaults:'${USERNAME}' !requiretty" >> /etc/sudoers'
	echo 'Done'
done
