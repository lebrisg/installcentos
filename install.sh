#export DOMAIN=
export USERNAME=${USERNAME:="gilles"}
#export PASSWORD=
export VERSION=${VERSION:="v3.7.1"}
export IP="$(ip route get 8.8.8.8 | awk '{print $NF; exit}')"
export METRICS="False"
export LOGGING="False"

echo "******"
echo "* Your domain is $DOMAIN "
echo "* Your username is $USERNAME "
echo "* Your password is $PASSWORD "
echo "* OpenShift version: $VERSION "
echo "******"

yum install -y epel-release

yum install -y git wget zile nano net-tools docker \
python-cryptography pyOpenSSL.x86_64 python2-pip \
openssl-devel python-devel httpd-tools NetworkManager python-passlib \
java-1.8.0-openjdk-headless "@Development Tools"

systemctl | grep "NetworkManager.*running"
if [ $? -eq 1 ]; then
        systemctl start NetworkManager
        systemctl enable NetworkManager
fi

which ansible || pip install -Iv ansible

[ ! -d openshift-ansible ] && git clone https://github.com/openshift/openshift-ansible.git

cd openshift-ansible && git fetch && git checkout release-3.7 && cd ..

cat <<EOD > /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
${IP}           $(hostname) console console.${DOMAIN}
EOD

systemctl restart docker
systemctl enable docker

if [ ! -f ~/.ssh/id_rsa ]; then
        ssh-keygen -q -f ~/.ssh/id_rsa -N ""
        cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
        ssh -o StrictHostKeyChecking=no root@$IP "pwd" < /dev/null
fi

curl -o inventory.download $SCRIPT_REPO/inventory.ini
envsubst < inventory.download > inventory.ini
