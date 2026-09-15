## Choosing mode (graphical|text|cmdline [--non-interactive])
text

# repo --name="AppStream" --baseurl=file:///run/install/sources/mount-000-cdrom/AppStream

## Use network installation
# url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-36&arch=x86_64"
# url --mirrorlist="https://mirrors.centos.org/mirrorlist?repo=centos-stream-10&arch=aarch64"
# url --mirrorlist="https://mirrors.centos.org/mirrorlist?path=/10-stream/BaseOS/x86_64/iso/CentOS-Stream-10-latest-x86_64-dvd1.iso&redirect=1&protocol=https"

## Use CDROM installation media
cdrom

## Initial Setup Agent on first boot
firstboot --enable

## System language
lang en_CA.UTF-8

## Keyboard layout
keyboard --xlayouts="us(intl)"
# keyboard --xlayouts="us"

## System timezone
timezone America/Toronto --utc

## Network information
network --bootproto="dhcp" --device="link" --onboot="on"

## Hostname
network --hostname="alabelle.seclinux.lan"

## Root password
rootpw --lock

## User password
user --name="admin" --groups="wheel" --gecos="admin" --password="password"

## Firewall configuration
firewall --enabled --ssh

## SELinux
selinux --enforcing

## Partition layout
## Disk type
#ignoredisk --only-use="nvme0n1"
ignoredisk --only-use="sda"
## -----
clearpart --all --initlabel --disklabel="gpt"
autopart --nohome

## Packages
%packages
@^minimal-environment
nano
open-vm-tools
%end

## Services
services --enabled="sshd.service,vmtoolsd.service"

## Reboot the system after installation.
reboot

## Enable kdump
%addon com_redhat_kdump --enable --reserve-mb='auto'
%end

%pre
%end

%post
dnf update -y
dnf install epel-release -y
%end
