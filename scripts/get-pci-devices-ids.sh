#!/bin/bash

PCI_DEVICES="1077:* 17db:* 15b3:*"
OUTPUT_FILTER="{ hypervisors: { h001: { pci_mapping: . } } }"
YQ=yq
XQ="yq -pxml --xml-attribute-prefix="
JQ=jq

# find all PCI devices based on vendor_id
devices=$(for v in $PCI_DEVICES; do lspci -mnnD -d ${v} ; done | while read card info; do echo pci_${card//[:\.]/_} ; done)
# loop over all devices
res=$(for d in ${devices}; do virsh nodedev-dumpxml $d | $XQ '[.device.capability.iommuGroup.address]' ; done | $YQ -ojson)
echo -e "${res}" | $JQ -s "flatten|unique|${OUTPUT_FILTER}"
