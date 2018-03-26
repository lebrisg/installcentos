#export DOMAIN=
export USERNAME=${USERNAME:="gilles"}
#export PASSWORD=

ansible-playbook -i inventory.ini openshift-ansible/playbooks/byo/config.yml

htpasswd -b /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}
oc adm policy add-cluster-role-to-user cluster-admin ${USERNAME}

systemctl restart origin-master-api

oc login -u ${USERNAME} -p ${PASSWORD} https://console.$DOMAIN:8443/
