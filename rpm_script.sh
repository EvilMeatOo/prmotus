#!/bin/bash
sudo yum install -y redhat-lsb-core wget rpmdevtools rpm-build vim createrepo yum-utils gcc
sudo wget https://nginx.org/packages/centos/8/SRPMS/nginx-1.20.2-1.el8.ngx.src.rpm -O /root/nginx-1.20.2-1.el8.ngx.src.rpm
sudo rpm -i /root/nginx-1.*
sudo wget https://github.com/openssl/openssl/archive/refs/heads/OpenSSL_1_1_1-stable.zip -O /root/OpenSSL_1_1_1-stable.zip
sudo unzip /root/OpenSSL_1_1_1-stable.zip -d /root/
sudo yum-builddep /root/rpmbuild/SPECS/nginx.spec -y
sudo grep 'with-debug' -P -R -I -l /root/rpmbuild/SPECS/nginx.spec | sudo xargs sed -ri "s/with-debug/with-openssl=\/root\/openssl-OpenSSL_1_1_1-stable/g"
sudo rpmbuild -bb /root/rpmbuild/SPECS/nginx.spec
sudo ll /root/rpmbuild/RPMS/x86_64/
sudo yum localinstall -y \/root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm
sudo systemctl start nginx
sudo systemctl status nginx
sudo mkdir /usr/share/nginx/html/repo
sudo cp /root/rpmbuild/RPMS/x86_64/nginx-1.20.2-1.el8.ngx.x86_64.rpm /usr/share/nginx/html/repo/
sudo wget https://downloads.percona.com/downloads/percona-distribution-mysql-ps/percona-distribution-mysql-ps-8.0.28/binary/redhat/8/x86_64/percona-orchestrator-3.2.6-2.el8.x86_64.rpm -O /usr/share/nginx/html/repo/percona-orchestrator-3.2.6-2.el8.x86_64.rpm
sudo createrepo /usr/share/nginx/html/repo/
sudo grep 'index.htm;' -P -R -I -l /etc/nginx/conf.d/default.conf | sudo xargs sed -i "/index.htm;/ a autoindex on;"
sudo nginx -t
sudo nginx -s reload
sleep 10
sudo curl -a http://localhost/repo/
sudo cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
sudo yum repolist enabled
sudo yum install percona-orchestrator.x86_64 -y
sudo yum --enablerepo="otus" install nginx -y
