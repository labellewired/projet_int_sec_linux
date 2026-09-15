# ACME — Playbook CentOS Stream 10

## Avant execution

1. Installer les trois VM avec leurs deux IP statiques. Le segment public dispose de la passerelle NAT et de DNS externe pendant l'installation; admin n'a aucune route par defaut.
2. Placer ce dossier sur le bastion. Le compte initial `alabelle` doit exister avec sudo et un mot de passe; Python 3 et SSH doivent etre disponibles sur les cibles.
3. Adapter les interfaces dans `host_vars/` avec `ip -br address`.
4. Dans `group_vars/all/vars.yml`, remplacer les cles publiques. Inclure la cle du controleur dans les cles d'alabelle.
5. Copier le MODELE `secrets.yml.example` en `secrets.yml`, remplir les valeurs puis le chiffrer AVANT de le publier. Supprimer l'ancien `secret.yml` du nouveau dossier s'il appartient au mandat precedent. Aucun secret en clair ne doit etre publie.
6. Ajouter seulement les fichiers de cette nouvelle arborescence. L'ancien `run.yml` et ses services DHCP/FTP/Samba/NFS ne font plus partie du playbook.

### Outils du bastion — console avec sudo

```bash
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --set-enabled crb
sudo dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
sudo dnf install -y ansible-core git openssh-clients
ansible-galaxy collection install -r collections/requirements.yml
```

### Cle du controleur — alabelle sur le bastion

Si la cle n'existe pas deja :

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub
```

La cle privee reste sur le bastion. Pour un lancement interactif avec cle chiffree, utiliser `ssh-agent` et `ssh-add ~/.ssh/id_ed25519`. Copier la cle PUBLIQUE du controleur dans les cles d'alabelle dans `vars.yml`, puis installer cette cle sur les deux cibles initiales :

```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub alabelle@10.10.10.20
ssh-copy-id -i ~/.ssh/id_ed25519.pub alabelle@10.10.10.40
```

Lors des premieres connexions SSH, verifier les empreintes depuis les consoles des VM avant de les accepter. Le playbook conserve la verification des cles d'hotes.

### Hachages de mots de passe — generer une fois

```bash
openssl passwd -6
```

Le programme demande le mot de passe. Copier le resultat `$6$...` dans le champ Vault correspondant. Le mot de passe sudo initial d'alabelle est conserve; le playbook applique les hachages lors de la creation des nouveaux comptes.

### Graines TOTP — deux valeurs distinctes

Executer deux fois :

```bash
python3 -c 'import base64,secrets; print(base64.b32encode(secrets.token_bytes(20)).decode())'
```

Copier les graines dans le Vault. Ajouter manuellement chaque compte dans son application TOTP : base32, 6 chiffres, periode 30 secondes, SHA1. Le playbook conserve l'etat des codes deja utilises entre deux executions.

### Chiffrer le Vault

```bash
cp group_vars/all/secrets.yml.example group_vars/all/secrets.yml
nano group_vars/all/secrets.yml
ansible-vault encrypt group_vars/all/secrets.yml
head -n 1 group_vars/all/secrets.yml
```

La premiere ligne doit commencer par `$ANSIBLE_VAULT;`. Conserver le mot de passe Vault hors de GitHub. Le fichier `.example` ne contient que des valeurs a remplacer et n'est pas charge automatiquement. [Ansible Vault](https://docs.ansible.com/projects/ansible/latest/vault_guide/vault.html)

## Execution depuis le bastion

```bash
ansible-playbook run.yml --syntax-check --ask-vault-pass
ansible-playbook run.yml --ask-become-pass --ask-vault-pass
ansible-playbook run.yml --ask-become-pass --ask-vault-pass
```

La deuxieme execution de deploiement doit terminer sans changements si les VM et les depots n'ont pas change. Le mot de passe sudo initial utilise pour alabelle doit etre le meme sur les trois VM pour `--ask-become-pass`.

## HTTPS et administration

Le certificat est autosigne pour le laboratoire. Recuperer le certificat public avec `export.yml` puis le faire confiance sur les deux postes; aucun besoin de transferer sa cle privee.

- Poste public : `https://www.acme.lan` avec DNS `10.10.1.40`.
- Poste admin isole : `https://10.10.10.20/admin`, avec le compte web `admin`.
- Pour conserver le nom DNS depuis admin, utiliser une entree hosts `10.10.10.20 www.acme.lan` sur ce poste, ou `curl --resolve www.acme.lan:443:10.10.10.20`.
- SSH public entre sur bastion avec cle ed25519 + TOTP. Le rebond vers web/infra utilise leurs IP admin.

Exemples de rebond depuis le poste public :

```bash
ssh -J alabelle@10.10.1.10 alabelle@10.10.10.20
ssh -J alabelle@10.10.1.10 alabelle@10.10.10.40
```

## Export des configurations finales

```bash
ansible-playbook export.yml --ask-become-pass --ask-vault-pass
```

Les fichiers recuperes sont dans `exports/configurations/` sur le bastion. Les graines TOTP, hachages web, identifiants applicatifs et cles privees ne sont pas exportes.

## Audit OpenSCAP

Sur infra, examiner le contenu fourni par la version installee :

```bash
find /usr/share/xml/scap/ssg/content -name '*-ds.xml'
oscap info /chemin/vers/le-datastream-centos-compatible.xml
```

Choisir un datastream et un profil compatibles avec CentOS Stream 10. Ne pas utiliser aveuglement un contenu RHEL dont les controles seraient tous `notapplicable`. Renseigner ensuite `openscap_datastream` et `openscap_profile` dans `vars.yml`. Le meme fichier doit etre disponible sur les trois cibles.

```bash
ansible-playbook audit.yml --ask-become-pass --ask-vault-pass
```

Les rapports sont recuperes dans `exports/audit/`. Le code de sortie OpenSCAP 2 correspond a des regles en echec et ne bloque pas leur recuperation. Examiner les resultats, appliquer les correctifs et relancer l'audit pour documenter deux constats High/Medium.

## Perimetre

Le site PHP fourni est une application de demonstration qui lit un message dans MariaDB; ce n'est pas la recuperation d'une ancienne application qui n'etait pas dans le ZIP. Les IP et la passerelle initiales sont preparees lors de l'installation des VM. Les taches NetworkManager maintiennent ensuite les profils existants.

Verification locale de livraison : YAML, imports, notifications et rendu des templates pour les trois roles. L'execution sur VM et la demonstration des criteres restent a faire.
