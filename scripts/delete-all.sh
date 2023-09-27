#HOSTS=(hypervisor ncn-h002 ncn-h003)
#VMS=(k8s-vm-master k8s-vm-worker)
#POOLS=()

# DELETE VMs
#function delete_vm() {
#  THIS_VM=${1}
#}
# DELETE Pools

virsh list --all
virsh list --all | grep -o -E "(kubernetes-\w*)" | xargs -I % sh -c 'virsh destroy %;'
virsh list --all | grep -o -E "(kubernetes-\w*)" | xargs -I % sh -c 'virsh undefine %;'
virsh pool-list --all | grep -o -E "(h0\w*)" | xargs -I % sh -c 'virsh pool-destroy % && virsh pool-undefine %;'
rm -rf /var/lib/libvirt/h*
