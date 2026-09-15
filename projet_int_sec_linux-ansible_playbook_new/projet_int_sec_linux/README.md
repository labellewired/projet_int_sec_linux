# Projet intégrateur - Mandat ACME - Playbook Ansible

Travail réalisé par Arnaud Labelle dans le contexte du cours Administration des services Linux 420-733-AH.

Travail présenté à M. Fabrice Houle le 16 juin 2026.

Département d'informatique, Cégep Ahuntsic, Montréal, Québec, Canada

## Contenu

Ce playbook Ansible permet de configurer et mettre à jour un serveur vierge CentOS Stream 10 avec les services suivants:
- DHCP (kea-dhcp4)
- DNS (named)
- FTP (vsftpd)
- NTP (chronyd)
- Samba (smb)
- NFS (nfs-server)

Ce playbook Ansible configure et met à jour également:
- hostname
- DNF
- EPEL (epel-release)
- Pare-feu (firewald)
- SELinux pour le service Samba

## Table d'adressage de la boîte à sable

Adresse du réseau..........172.16.200.0/24
Adresse de la passerelle...172.16.200.2
Contrôleur Ansible.........172.16.200.X
Serveur cible..............172.16.200.12
Client Windows............(Adressage par DHCP)
Client Linux..............(Adressage par DHCP)

## Prérequis du contrôleur Ansible

- Ansible
- Python 3
- Client SSH

## Prérequis du serveur cible

- CentOS Stream 10
- Python 3
- Accès SSH
- Adresse IP statique 172.16.200.12/24
- Résolution DNS
- Utilisateur fabhoule
-- avec accès root
-- avec mot de passe spécifié dans l'énoncé de travail

## Exécution 

1. Transférer le répertoire "projetintegrateur/" fournis sur le contrôleur Ansible.

2. Échanger la clé publique SSH avec le serveur cible.

   ssh-copy-id -i /home/<repertoire_de_l_utilisateur>/.ssh/<cle_ssh>.pub fabhoule@172.16.200.12

3. Lancer le playbook Ansible.

   ansible-playbook -i inventory.ini run.yml --ask-become-pass --ask-vault-pass

## Notes 

Tous les mots de passe demandés sont les même que celui spécifié dans l'énoncé de travail.

Les shares Samba et NFS sont configurés sur le serveur cible selon cette arborescence: 

/mnt/monpartage/
	│
	├── samba_shares/
	└── nfs_shares/

nfs_shares/ est accessible depuis un client Windows 11 après avoir configuré celui-ci avec des registres équivalent à l'utilisateur nobody (UID = 65534, GID = 65534) ou de l'utilisateur fabhoule (généralement UID=1000, GID = 1000; peut-être trouvé avec la commande id fabhoule).

Si nfs_shares/ est accédé avec les UID et GID de l'utilisateur nobody (UID = 65534, GID = 65534) les droits d'écriture des fichiers créés sur le partage ne seront pas partagés avec l'utilisateur fabhoule. Les droits de lecture eux restent partagés. 
