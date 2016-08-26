#!/bin/bash
#
# Bring a headless VMWare box up

set -e

VM_PATH="${HOME}/src/dev_ppm/.vagrant/machines/default/vmware_fusion/a351d40d-9af2-48b2-a4b2-081632aa7959/packer-vmware-vmx-{{timestamp}}.vmx"

/Applications/VMware\ Fusion.app/Contents/Library/vmrun -T fusion start "${VM_PATH}" nogui
