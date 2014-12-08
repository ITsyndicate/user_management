#!/bin/bash

read -p "Type name of the new user: " USERNAME
if [ -z $USERNAME ]; then
	echo "Error: username could not be empty!"
	exit 1
fi

read -sp "Type password of the new user (will be not displayed): " USERPASS
echo

read -p "If you have SSH-key, type it: " SSHKEY
if [[ -z $USERPASS && -z $SSHKEY ]]; then
        echo "Error: you should provide a password and/or SSH-key for user!"
        exit 1
fi

read -p "Would you like grant sudo access for user? (y/N)" GRANTSUDO

for serv in $(cat ipfile.txt); do
	echo -n "Adding user ${USERNAME} to host ${serv}... "
	if ssh -q $serv id -u $USERNAME >/dev/null 2>&1; then
		echo
		echo "User ${USERNAME} exists on ${serv}, please select another username"
		exit 1
	fi
	ssh -q $serv /usr/sbin/useradd -m -s /bin/bash $USERNAME
	if [ -n "$USERPASS" ]; then
		ssh -q $serv 'echo "'${USERNAME}':'${USERPASS}'" | /usr/sbin/chpasswd'
	fi
	if [ -n "$SSHKEY" ]; then
		ssh -q $serv mkdir /home/${USERNAME}/.ssh
		ssh -q $serv 'echo "'$SSHKEY'" > /home/'${USERNAME}'/.ssh/authorized_keys'
		ssh -q $serv chown -R ${USERNAME}.${USERNAME} /home/${USERNAME}
	fi
	if [[ $GRANTSUDO = "y" || $GRANTSUDO = "Y" ]]; then
		ssh -q $serv 'echo "'${USERNAME}' ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
		ssh -q $serv 'echo "Defaults:'${USERNAME}' !requiretty" >> /etc/sudoers'
	fi
	echo 'Done'
done
