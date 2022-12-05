#!/bin/sh

chown sysadm:ftpadmin /home/ftp/public
chown sysadm:ftpadmin /home/ftp/upload
chown sysadm:ftpgroup /home/ftp/hidden

chmod 777 /home/ftp/public
chmod 1777 /home/ftp/upload
chmod 771 /home/ftp/hidden

mkdir /home/ftp/hidden/treasure
chown sysadm:ftpadmin /home/ftp/hidden/treasure

touch /home/ftp/hidden/treasure/secret
chown sysadm:ftpadmin /home/ftp/hidden/treasure/secret

mkdir /home/ftp/hidden/.exe
chown sysadm:ftpadmin /home/ftp/hidden/.exe
