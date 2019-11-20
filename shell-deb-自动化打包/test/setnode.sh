#!/bin/bash
export LANG=UTF-8
if [ -f /tmp/addnode/nodes ];then
    . /tmp/addnode/nodes
fi
NODE_MAC=''
NODE_IP=''
BOND_SLAVE1=''
BOND_SLAVE2=''
VM_BASE_NETWOEK=''
MIR_NAME=''
MIR_IP=''

for node in "${nodes[@]}"
do
#   read -p "your info $node MAC: " NODE_MAC
    read -p "your info $node IP: " NODE_IP
#   read -p "your info $node BOND_SLAVE1: " BOND_SLAVE1
#   read -p "your info $node BOND_SLAVE2: " BOND_SLAVE2
    read -p "your info $node VM_BASE_NETWOEK: " VM_BASE_NETWOEK
    read -p "your info $node MIR_NAME: " MIR_NAME
    read -p "your info $node MIR_IP: " MIR_IP

    cp tk1r09n00 $node
#   sed -i '/^netinst_network_mac_addr/s/ec:f4:bb:c4:aa:f8/$NODE_MAC/' $node
    sed -i '/^netinst_network_address/s/172.10.24.10/'$NODE_IP'/' $node
    sed -i '/^hostname/s/tk1r09n00/'$node'/' $node
#   sed -i '/^mgmt_network_bond_slaves/s/em1/$BOND_SLAVE1/' $node
#   sed -i '/^mgmt_network_bond_slaves/s/em2/$BOND_SLAVE2/' $node
    sed -i '/^mgmt_network_address/s/172.10.24.10/'$NODE_IP'/' $node
    sed -i '/^vm_base_network/s/172.21.130.0/'$VM_BASE_NETWOEK'/' $node
    sed -i '/^vm_base_master_network/s/172.21.130.0/'$VM_BASE_NETWOEK'/' $node
    sed -i '/^ctn_mirror_hostname/s/tk1r10n00/'$MIR_NAME'/' $node
    sed -i '/^ctn_mirror_address/s/172.10.24.20/'$MIR_IP'/' $node
done
