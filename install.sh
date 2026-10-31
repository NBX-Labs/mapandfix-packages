#!/bin/sh
# Installe l'agent Map & Fix sur cette machine Linux (Debian, Ubuntu, RHEL, Amazon Linux…), tel
# que la console le propose :
#
#   curl -fsSL https://packages.mapandfix.com/install.sh | sudo MAPANDFIX_URL=<console> MAPANDFIX_ENROLL_TOKEN=mafe_… sh
#
# Il ajoute le dépôt signé de Map & Fix, avec sa clé publique écrite ci-dessous, installe le paquet
# par apt ou dnf, qui en vérifient la signature, inscrit la machine puis démarre le service. Le
# jeton ne sert qu'à l'inscription : il n'est écrit nulle part sur la machine.
#
# Pour qui préfère tout faire à la main ou vérifier la clé d'abord, la marche à suivre est sur
# https://packages.mapandfix.com.
set -eu

fingerprint="02649E625DB6F3847296E51C1C3608A7FFF7A718"
packages=${MAPANDFIX_PACKAGES_URL:-https://packages.mapandfix.com}

fail() {
	echo "mapandfix-agent : $*" >&2
	exit 1
}

[ -n "${MAPANDFIX_URL:-}" ] || fail "MAPANDFIX_URL manquant : l'adresse de la console Map & Fix"
[ -n "${MAPANDFIX_ENROLL_TOKEN:-}" ] || fail "MAPANDFIX_ENROLL_TOKEN manquant : le jeton d'inscription créé dans la console"
case "$MAPANDFIX_ENROLL_TOKEN" in mafe_*) ;; *) fail "MAPANDFIX_ENROLL_TOKEN n'est pas un jeton d'inscription (mafe_…)" ;; esac
[ "$(id -u)" -eq 0 ] || fail "à lancer en root (sudo)"
MAPANDFIX_URL=${MAPANDFIX_URL%/}
case "$MAPANDFIX_URL" in
https://*) ;;
*) [ "${MAPANDFIX_ALLOW_HTTP:-}" = 1 ] || fail "$MAPANDFIX_URL refusée : l'agent ne parle à Map & Fix qu'en HTTPS" ;;
esac
case "$(uname -m)" in
x86_64 | amd64 | aarch64 | arm64) ;;
*) fail "architecture $(uname -m) non prise en charge (amd64 ou arm64)" ;;
esac

public_key() {
	cat <<'KEY'
-----BEGIN PGP PUBLIC KEY BLOCK-----

mQINBGrl+JYBEADaQCIWluSBEgIj+VJI3a4oAR2XDK9Ytny1l4wLnemL0k1VKCsP
byeMgLPqEHXw4DLJr4NfFey066A0Y1zpSidCwsESlhAKQbUMxnZ2I1fkR5S/mIWj
QK8Yjw/OBuvPcvWDQvy4+tg42QmLMIblD+7PA4BPc6xullf/tZegvoh6I0wos4Z7
9CWzB6NrRxAfjg7ewVztrsrzgJUJ9L2/Mdhe1uiJhkV/P+xb84Nh7YmQqXYtIGnh
DBfNfuMwjuP+ALPXl6N9s/WwL4CfYZXRD07F/ZJOCEZ46RYLqLiq3XPu8jWDd/so
6Z7mERxTMSAUIRzGYtv8EMhLahZLXlDLLh2loXioCfJHNOpqjTQc27KjWQra6M79
I41B0nlphDLOCGC2AJPZqC3neEbd6wOTY3hEuVot4qq45Zw+aAdACGMyDQ581UfF
PC5EerHMtiyz51aYAMl5PAZDtWh04EHnepigORhsMGO5XrqzG5r2AJLUpPrLeMI/
4k4eVV2ws7t0JqB92UT7oI+xAJ4D8rQpKIlnMMorSQIPuBNfcxIel6Ff4lqQN5DX
7oL0tQitXV4wf0mhycBDHxmmQmiw4gnOG5DL2s+AGO5x/gjmdeWIfbOsOjtFWkPc
aMx30YofuNObXthW9EO0xsPKfe8JFOgVrQFO5/Oo5DJrscqPphOazaJ4YQARAQAB
tDVNYXAgJiBGaXggKHBhcXVldHMgZGUgbCdhZ2VudCkgPHN1cHBvcnRAbmJ4LWxh
YnMuY29tPokCVAQTAQoAPhYhBAJknmJdtvOEcpblHBw2CKf/96cYBQJq5fiWAhsD
BQkJZgGABQsJCAcCBhUKCQgLAgQWAgMBAh4BAheAAAoJEBw2CKf/96cYrG8QAKpZ
hgUJos+/Y7wH5edcHBxvur1T6pfOF/y6OHO/a/Pk3V84vGM3BT2TWijVJEpLpRtn
5fxfymr48A/QV5lipao+rl3hyouEfXGDZSOobKFoM7HRNWq7fwyPO7yq3viNtImm
2d/6+fHIJgEWPuAMRSX6PFBDp+i4/w7dpHlqngtaWYm07q2WbjO/YopeXPFFPTtz
Pprbn4ZBO2tQH1GC8ifchAQqZ3MsQYSXsWLDo6KWjGFqkWB5rgKuZ/kL4e0CIXwP
VR5T9ka5rYyI74r38Daim7/gtrvptPhU5l3YYBF6d9ZMULzOalU0xnCj2JdJUBlh
yrF/pR4vnt2cls3av9GG229lVJuxzcfu0RsmTwB+dYjxSNpStGqnlmS0Vqe2bleP
gy16/ymw1pCxwrzUcWLtPDGypFsw5uv7ADk2LJKd8dvzIvFhLUL6gYNWHrwCpClO
gc7+pQ78jEmrVzkZCUh49uVrgKcP9ApHZ+ZYJWyX5OIJpPw4ItX8n81WV0GU/6GF
D6/QMLQB2eVc+439xKTKT+GnKbCuKCHj+d5gaoxnqgHcZuipiqHSXdkv4ew8w2a+
osAKUldBSGCzfDTcQZ8vjDwA83FTdg9ra3jIt4uyHwSwj64ICaOVohsFIP473LJL
DOkuvw5vBHZv30OXVOGAv7SKwXCEugXACOcWShlw
=++DM
-----END PGP PUBLIC KEY BLOCK-----
KEY
}

echo "mapandfix-agent : dépôt signé $packages, clé $fingerprint"
if command -v apt-get >/dev/null 2>&1; then
	mkdir -p /etc/apt/keyrings
	public_key >/etc/apt/keyrings/mapandfix.asc
	chmod 644 /etc/apt/keyrings/mapandfix.asc
	echo "deb [signed-by=/etc/apt/keyrings/mapandfix.asc] $packages stable main" >/etc/apt/sources.list.d/mapandfix.list
	apt-get update -qq -o Dir::Etc::sourcelist=sources.list.d/mapandfix.list -o Dir::Etc::sourceparts=- -o APT::Get::List-Cleanup=0 ||
		fail "dépôt injoignable ou signature refusée"
	DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mapandfix-agent >/dev/null || fail "installation du paquet impossible"
elif command -v dnf >/dev/null 2>&1 || command -v yum >/dev/null 2>&1; then
	mkdir -p /etc/pki/rpm-gpg
	public_key >/etc/pki/rpm-gpg/RPM-GPG-KEY-mapandfix
	cat >/etc/yum.repos.d/mapandfix.repo <<REPO
[mapandfix]
name=Map & Fix
baseurl=$packages/rpm/\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-mapandfix
REPO
	if command -v dnf >/dev/null 2>&1; then
		dnf install -y -q mapandfix-agent || fail "installation du paquet impossible"
	else
		yum install -y -q mapandfix-agent || fail "installation du paquet impossible"
	fi
else
	fail "ni apt ni dnf ni yum sur cette machine"
fi

# Le jeton ne passe que par l'environnement de cette commande, et une erreur se voit ici.
/usr/bin/mapandfix-agent enroll || fail "inscription refusée : vérifiez le jeton (expiré ou révoqué ?) et l'adresse"

mkdir -p /etc/mapandfix
(
	umask 077
	{
		echo "# Configuration de l'agent Map & Fix (lisible de root seul)."
		echo "MAPANDFIX_URL=$MAPANDFIX_URL"
		if [ "${MAPANDFIX_ALLOW_HTTP:-}" = 1 ]; then echo "MAPANDFIX_ALLOW_HTTP=1"; fi
	} >/etc/mapandfix/agent.env
)
chmod 600 /etc/mapandfix/agent.env

if [ -d /run/systemd/system ]; then
	systemctl enable mapandfix-agent.service >/dev/null 2>&1
	systemctl restart mapandfix-agent.service
	echo "mapandfix-agent : installé et démarré. Il apparaît dans la console (Intégrations › Agents) dans la minute ; son premier inventaire suit."
	echo "mapandfix-agent : état avec « systemctl status mapandfix-agent », journal avec « journalctl -u mapandfix-agent »."
else
	echo "mapandfix-agent : installé et inscrit, mais cette machine n'a pas systemd : lancez « mapandfix-agent run » avec les variables de /etc/mapandfix/agent.env."
fi
