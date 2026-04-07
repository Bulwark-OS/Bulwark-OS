# modules/justfiles/bulwarkos.just
[group('bulwarkOS')]
setup-vfio VENDOR PCIIDS:
    rpm-ostree kargs \
      --append={{VENDOR}}_iommu=on \
      --append=iommu=pt \
      --append="vfio-pci.ids={{PCIIDS}}"
    rpm-ostree initramfs --enable --arg=--add-drivers --arg="vfio vfio_pci vfio_iommu_type1"
    echo "Reboot required to apply VFIO configuration."
