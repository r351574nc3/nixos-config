# nixos-config
My NixOS Config


# Stages for Setting up NixOS for K8S

## Setup VM

`nixos.xml` will point to an ISO to run linux live cd from and handle installation. ISO can be found at https://channels.nixos.org/nixos-21.11/latest-nixos-minimal-x86_64-linux.iso

```shell
qemu-img create -f qcow2 nixos.qcow2 100g            # Creates NixOS disk image
virsh define nixos.xml                               # Creates virtual machine
virsh start nixos                                    # Starts Virtual Machine. Use real-vnc client to connect. 5900 port is opened on localhost.
virsh edit nixos                                     # Modify configuration. VM must not be running.
```



## Install NixOS

Once the connection has been made over real-vnc client to `nixos` live system. Prepare the system to install linux as VM guest

```shell
sudo -s                                           # Must be root
parted /dev/vda -- mktable msdos                  # Create a dos partition table. Remember, running in a VM here
parted /dev/vda -- mkpart primary ext4 1MiB 100%  # Use the entire disk. Running kubernetes.
mkfs.ext4 -L nixos /dev/vda1                      # Make sure to add a filesystem
mount /dev/vda1 /mnt
nixos-generate-config --root /mnt                 # Create base configuration. Going to overwrite anyway.
```

Copy [configuration.nix](configuration.nix) to /mnt/etc/nixos

```shell
cd /mnt/etc/nixos
nixos-install                      # This will install nixos. Only ever need to run this one time.
```


## Setup K8S

### Manually Create Certificates

At this time, kubernetes can only be accessed from within nixos. If we use `kubectl` outside nixos

```
Unable to connect to the server: x509: certificate is valid for 10.0.2.15, 10.43.0.1, 127.0.0.1, not xxx.xxx.xxx.xxx
```

To get passed this, we need to add a certificate for the VM host. [Instructions on Certificate Setup](https://kubernetes.io/docs/tasks/administer-cluster/certificates/)