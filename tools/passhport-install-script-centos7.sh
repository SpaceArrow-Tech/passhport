#!/bin/bash -e 
echo 'Hi there ! Please read carefully the following (not long)'.
echo 'This script will attempt to install PaSSHport on this system.'
echo 'This script works on Centos 7, WITH EPEL repos configured !!'
echo ''
echo 'PLEASE enable EPEL repository BEFORE running this script !!'
echo ''
echo 'What this script will do to your existing system:'
echo '- install "python34-pip", "git" and "openssl" packages.'
echo '- update PIP via pip3 script, installed previously'
echo '- install virtualenv via pip3 script'
echo '- add a "passhport" system user'
echo '- create an "/etc/passhport" directory'
echo '- create a "/var/lib/passhport" directory'
echo '- create a "/var/log/passhport" directory'
echo ''
echo 'The remaining process will only create and/or modify files and'
echo 'directories WITHIN the directories mentionned above, so which includes:'
echo '- /home/passhport'
echo '- /etc/passhport'
echo '- /var/lib/passhport'
echo '- /var/log/passhport'
echo ''
echo 'If you want to remove passhportd from this system, run the following,'
echo 'as root:'
echo 'userdel passhport'
echo 'rm -rf /home/passhport'
echo 'rm -rf /etc/passhport'
echo 'rm -rf /var/lib/passhport'
echo 'rm -rf /var/log/passhport'
echo 'rm /usr/bin/passhport-admin'
echo 'rm /usr/sbin/passhportd'
echo 'rm /etc/bash_completion.d/passhport-admin'
echo ''
echo 'You may also remove virtualenv that has been installed by pip3 :'
echo '# pip3 uninstall virtualenv'
echo ''
echo 'Remove the systemd service :'
echo '# systemctl disable passhportd'
echo '# rm /etc/systemd/system/passhportd.service'
echo '# systemctl daemon-reload'
echo ''
echo "Finally you may also purge the following packages if you don't need them"
echo 'anymore:'
echo 'python34-pip git openssl (# yum remove python34-pip git openssl)'
echo ''
echo 'Once you read and understood the above lines, you may proceed by typing'
echo '"yes", or exit by the famous "CTRL+C" :'
read ANSWER;

while [ "${ANSWER}" != 'yes' ]
do
	echo 'Please type excatly "yes" or exit by pressing "CTRL+C".'
	read ANSWER
done

echo '##############################################################'
echo '# Installing EPEL repository…'
echo '##############################################################'
yum install -y epel-release
echo '##############################################################'
echo '# Installing python34-pip, git and openssl package…'
echo '##############################################################'
yum install -y python34-pip git openssl
echo '##############################################################'
echo '# Updating pip…'
echo '##############################################################'
pip3 install -U pip 
echo '##############################################################'
echo '# Installing virtualenv with pip…'
echo '##############################################################'
pip3 install virtualenv
echo '##############################################################'
echo '# Creating "passhport" system user'
echo '##############################################################'
useradd --home-dir /home/passhport --shell /bin/bash --create-home passhport
echo '##############################################################'
echo '# Creating the virtual-env for passhport…'
echo '##############################################################'
su - passhport -c "virtualenv -p python3 passhport-run-env"
echo '##############################################################'
echo '# Installing mandatory packages in the virtual environment…'
echo '##############################################################'
su - passhport -c "/home/passhport/passhport-run-env/bin/pip install pymysql sqlalchemy-migrate flask-migrate requests docopt configparser tabulate flask-login ldap3"
echo '##############################################################'
echo '# Cloning passhport git from github'
echo '##############################################################'
su - passhport -c "git clone https://github.com/LibrIT/passhport.git"
echo '##############################################################'
echo '# Creating "/var/log/passhport" log directory'
echo '##############################################################'
mkdir -p /var/log/passhport/
chown passhport:passhport /var/log/passhport/
echo '##############################################################'
echo '# Creating "/etc/passhport" conf directory '
echo '##############################################################'
mkdir /etc/passhport
cp /home/passhport/passhport/passhportd/passhportd.ini /etc/passhport/.
cp /home/passhport/passhport/passhport/passhport.ini /etc/passhport/.
cp /home/passhport/passhport/passhport-admin/passhport-admin.ini /etc/passhport/.
cp /home/passhport/passhport/passhportd/passhportd.ini /etc/passhport/.
echo '##############################################################'
echo '# Generating PaSSHport RSA (4096b) and ecdsa (521b) keys…'
echo '##############################################################'
su - passhport -c '/usr/bin/ssh-keygen -t rsa -b 4096 -N "" -f "/home/passhport/.ssh/id_rsa"'
su - passhport -c '/usr/bin/ssh-keygen -t ecdsa -b 521 -N "" -f "/home/passhport/.ssh/id_ecdsa"'
echo '##############################################################'
echo '# Creating PaSSHport database directory…'
echo '##############################################################'
mkdir -p /var/lib/passhport
chown -R passhport:passhport /var/lib/passhport/
echo '##############################################################'
echo '# Editing PaSSHport conf files…'
echo '##############################################################'
sed -i -e 's#SQLALCHEMY_DATABASE_DIR\s*=.*#SQLALCHEMY_DATABASE_DIR        = /var/lib/passhport/#' /etc/passhport/passhportd.ini
sed -i -e 's#LISTENING_IP\s*=.*#LISTENING_IP = 0.0.0.0#' /etc/passhport/passhportd.ini
sed -i -e 's#SQLALCHEMY_MIGRATE_REPO\s*=.*#SQLALCHEMY_MIGRATE_REPO        = /var/lib/passhport/db_repository#' /etc/passhport/passhportd.ini
sed -i -e 's#SQLALCHEMY_DATABASE_URI\s*=.*#SQLALCHEMY_DATABASE_URI        = sqlite:////var/lib/passhport/app.db#' /etc/passhport/passhportd.ini
sed -i -e "s#PASSHPORTD_HOSTNAME\s*=.*#PASSHPORTD_HOSTNAME = localhost#" /etc/passhport/passhport-admin.ini
sed -i -e "s#PASSHPORTD_HOSTNAME\s*=.*#PASSHPORTD_HOSTNAME = localhost#" /etc/passhport/passhport.ini
echo '##############################################################'
echo '# Creating database for PaSSHport (SQLite)…'
echo '##############################################################'
su - passhport -c "/home/passhport/passhport-run-env/bin/python /home/passhport/passhport/passhportd/db_create.py"
echo '##############################################################'
echo '# Creating bash_completion file for passhport-admin script…'
echo '##############################################################'
if [ ! -d "/etc/bash_completion.d/" ]
then
	mkdir "/etc/bash_completion.d/"
fi
cp /home/passhport/passhport/tools/passhport-admin.bash_completion /etc/bash_completion.d/passhport-admin
. /etc/bash_completion.d/passhport-admin
echo '##############################################################'
echo '# Creating symbolink links to binaries…'
echo '##############################################################'
ln -s /home/passhport/passhport/tools/passhport-admin.sh /usr/bin/passhport-admin
ln -s /home/passhport/passhport/tools/passhportd.sh /usr/sbin/passhportd
echo '##############################################################'
echo '# Creating Web-API cert directory…'
echo '##############################################################'
su - passhport -c "mkdir /home/passhport/certs"
su - passhport -c "chmod 700 /home/passhport/certs"
echo '##############################################################'
echo '# Generating Web-API RSA key (4096b)'
echo '##############################################################'
su - passhport -c "openssl genrsa -out "/home/passhport/certs/key.pem" 4096"
echo '##############################################################'
echo '# Adding choosen IP to the certificate…'
echo '##############################################################'
sed -i -e "s#^\(DNS.*\s*=\s*\)TO_CHANGE#\1`hostname -f`#g" /home/passhport/passhport/tools/openssl-for-passhportd.cnf 
echo '##############################################################'
echo '# Generating Web-API certificate…'
echo '##############################################################'
openssl req -new -key "/home/passhport/certs/key.pem" \
	-config "/home/passhport/passhport/tools/openssl-for-passhportd.cnf" \
	-out "/home/passhport/certs/cert.pem" \
	-subj "/C=FR/ST=Ile De France/L=Ivry sur Seine/O=LibrIT/OU=DSI/CN=passhport.librit.fr" \
	-x509 \
	-days 365 \
	-sha256 \
	-extensions v3_req
# We try to detect if we run on a systemd OS.
if (stat /proc/1/exe | head -n 1 | grep systemd &>/dev/null)
then
	echo '##############################################################'
	echo '# Importing passhportd service in systemd…'
	echo '##############################################################'
	cp /home/passhport/passhport/tools/passhportd.service /etc/systemd/system/passhportd.service
	systemctl daemon-reload
	systemctl enable passhportd
	echo "passhportd has been enabled at startup."
	systemctl start passhportd
	echo "passhportd has been started."
	echo 'Please use systemctl to start/stop service.'
fi
echo '##############################################################'
echo '# Adding root@localhost target…'
echo '##############################################################'
# Sleep 2 seconds so passhportd has enough time to start
sleep 2
cat "/home/passhport/.ssh/id_ecdsa.pub" >> "/root/.ssh/authorized_keys"
su - passhport -c 'passhport-admin target create root@localhost 127.0.0.1 --comment="Localhost target added during the PaSSHport installation process."'
echo 'Do you want to add your first user now ? Y/n'
read DO_CREATE_USER
while [ "${DO_CREATE_USER,,}" != "y" ] && [ ! -z "${DO_CREATE_USER}" ] && [ "${DO_CREATE_USER,,}" != "n" ]
do
	echo 'Do you want to add your first user now ? Y/n'
	read DO_CREATE_USER
done
if [ "${DO_CREATE_USER,,}" == "y" ] || [ -z "${DO_CREATE_USER}" ]
then
	echo 'Remember : no space in the user name!'
	su - passhport -c "passhport-admin user create"
	echo 'Do you want to link this user to the target root@localhost ? Y/n'
	read DO_LINK_USER
	while [ "${DO_LINK_USER,,}" != "y" ] && [ ! -z "${DO_LINK_USER}" ] && [ "${DO_LINK_USER,,}" != "n" ]
	do
		echo 'Do you want to link this user to the target root@localhost ? Y/n'
		read DO_LINK_USER
	done
	if [ "${DO_LINK_USER,,}" == "y" ] || [ -z "${DO_LINK_USER}" ]
	then
		FIRST_USER=`su - passhport -c "passhport-admin user list"`
		su - passhport -c "passhport-admin target adduser ${FIRST_USER} root@localhost"
	fi
fi

echo "PaSSHport is now installed on your system."

echo '##############################################################'
echo '# You can test that passhportd is running by running :'
echo '# curl -s --insecure https://localhost:5000'
echo '# if it displays : '
echo '# "passhportd is running, gratz!"'
echo '# you successfuly installed PaSSHport. Well done !'
echo '# If you created your first user, you can connect to PaSSHport'
echo '# using "ssh -i the_key_you_used passhport@PASSHPORT_HOST"'
echo '##############################################################'
