## Choosing mode (graphical|text|cmdline [--non-interactive])
text

# repo --name="AppStream" --baseurl=file:///run/install/sources/mount-000-cdrom/AppStream
repo --name="epel" --baseurl=https://fedoraproject.org

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

# Static IPv4
network --bootproto=static --device=link --ip=10.10.1.10 --netmask=255.255.255.0 --gateway=10.10.1.2 --ipv6=ignore --onboot=on

## Hostname
network --hostname="bastion.acme.lan"

## DNS Servers
network --nameserver="10.10.10.40,9.9.9.9"

## Root password
rootpw --lock

## User password
user --name="alabelle" --groups="wheel" --gecos="alabelle" --password="ARZA-Pa$$w0rd/!"
user --name="zlizotte" --groups="wheel" --gecos="zlizotte" --password="ARZA-Pa$$w0rd/!"

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
epel-release
ansible
python3
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

# Disable IPv6 system-wide
grubby --update-kernel=ALL --args="ipv6.disable=1"

%end
