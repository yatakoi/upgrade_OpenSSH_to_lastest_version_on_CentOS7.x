#####################################################
#!/bin/bash

useradd rpmbuilder
mkdir -p /home/rpmbuilder/rpmbuild/{SOURCES,SPECS}

yum -y install wget epel-release
yum -y install rpm-build  gcc make
yum -y install openssl openssl-devel krb5-devel pam-devel libX11-devel xmkmf libXt-devel gtk2-devel

wget  https://mirror.yandex.ru/pub/OpenBSD/OpenSSH/portable/openssh-8.5p1.tar.gz
wget  https://src.fedoraproject.org/lookaside/pkgs/openssh/x11-ssh-askpass-1.2.4.1.tar.gz/8f2e41f3f7eaa8543a2440454637f3c3/x11-ssh-askpass-1.2.4.1.tar.gz

tar -zxf openssh-8.5p1.tar.gz
cp ./openssh-8.5p1/contrib/redhat/openssh.spec /home/rpmbuilder/rpmbuild/SPECS/
cp openssh-8.5p1.tar.gz /home/rpmbuilder/rpmbuild/SOURCES/
cp x11-ssh-askpass-1.2.4.1.tar.gz /home/rpmbuilder/rpmbuild/SOURCES/

chown -R rpmbuilder:rpmbuilder /home/rpmbuilder/
su - rpmbuilder <<'EOF'
cd /home/rpmbuilder/rpmbuild/SPECS/

sed -i "s/%global no_gnome_askpass 0/%global no_gnome_askpass 1/g" openssh.spec
sed -i "s/%global no_x11_askpass 0/%global no_x11_askpass 1/g" openssh.spec
sed -i "s/BuildRequires: openssl-devel >= 1.0.1/#BuildRequires: openssl-devel >= 1.0.1/g" openssh.spec
sed -i "s/BuildRequires: openssl-devel < 1.1/#BuildRequires: openssl-devel < 1.1/g" openssh.spec
exit
EOF
sed -i 's/^%__check_fil/#&/' /usr/lib/rpm/macros

su - rpmbuilder <<'EOF'
cd /home/rpmbuilder/rpmbuild/SPECS/
rpmbuild -bb openssh.spec
EOF

########################################################
