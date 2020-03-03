#!/bin/bash

# Change listen port to 2122
sed -i 's/\#Port 22/Port 2122/' /etc/ssh/sshd_config

# Make privilege separation directory (needed for Ubuntu)
mkdir -p /var/run/sshd

# Generate any non-existing host keys
for KEY_TYPE in rsa dsa ecdsa ed25519; do
    KEY_PATH="/etc/ssh/ssh_host_${KEY_TYPE}_key"

    if [ ! -f $KEY_PATH ]; then
        ssh-keygen -N "" -t $KEY_TYPE -f $KEY_PATH
    fi
done

# Add user dev
useradd dev
mkdir -p /home/dev/.ssh
printf "\nAllowUsers dev" >> /etc/ssh/sshd_config

# Set folder permissions for dev
chown -R dev /home/dev
chown -R dev /opt/*

# Make sure shell is bash if chsh is an option
if [ -f "$(which chsh)" ]; then
    chsh dev -s /bin/bash
fi

# Have sshd launch on startup
printf "
if [ \$(pgrep -c sshd) -eq 0 ]; then
    /usr/sbin/sshd -D &
fi
" > /etc/profile.d/sshd_launch.sh
chmod 644 /etc/profile.d/sshd_launch.sh