#!/bin/bash
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
