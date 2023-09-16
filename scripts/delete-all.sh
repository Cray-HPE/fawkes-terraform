#
# MIT License
#
# (C) Copyright 2023 Hewlett Packard Enterprise Development LP
#
# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
set -euo pipefail

echo >&2 "script is incomplete."
exit 1

if IFS=$'\n' read -rd '' -a hypervisors; then
    :
fi <<< "$(yq '.hypervisors | keys | join("\n")' inventory.yaml)"

for hypervisor in "${hypervisors[@]}"; do
    target="$hypervisor"
    if [ "$hypervisor" = "ncn-h001" ]; then
        target=hypervisor.local
    fi

    if IFS=$'\n' read -rd '' -a vms; then
        :
    fi <<< "$(yq '.hypervisors."'"${hypervisor}"'".vms | keys | join("\n")' inventory.yaml)"
    for vm in "${vms[@]}"; do

        if IFS=$'\n' read -rd '' -a roles; then
            :
        fi <<< "$(yq '.hypervisors."'"${hypervisor}"'".vms."'"${vm}"'".roles | join("\n")' inventory.yaml)"
        ssh "$target" virsh vol-delete --pool "kubernetes-${roles[0]}-${hypervisor}-${vm}-storage-pool" "kubernetes-${roles[0]}-${hypervisor}-${vm}_init.iso"

        for role in "${roles[@]}"; do

            if IFS=$'\n' read -rd '' -a volumes; then
                :
            fi <<< "$(yq '.volumes_defaults."'"${role}"'".[].name' inventory.yaml)"

            for volume_id in "${!volumes[@]}"; do
                ssh "$target" virsh vol-delete --pool "kubernetes-${roles[0]}-${hypervisor}-${vm}-storage-pool" "kubernetes-${roles[0]}-${hypervisor}-${vm}-${volume_id}-${volumes[$volume_id]}.qcow2"
            done

        ssh "$target" virsh vol-delete --pool "kubernetes-${roles[0]}-${hypervisor}-${vm}-storage-pool" "kubernetes-${roles[0]}-${hypervisor}-${vm}_init.iso"

        # FIXME: Pull correct prefix
        ssh "$target" rm -rf "/var/lib/libvirt/${hypervisor}*"

        ssh "$target" virsh pool-destroy "kubernetes-${roles[0]}-${hypervisor}-${vm}-storage-pool"
        ssh "$target" virsh pool-undefine "kubernetes-${roles[0]}-${hypervisor}-${vm}-storage-pool"
        done
    done
done
