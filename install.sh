#!/bin/bash

set -Eeuo pipefail

PUPPET_MODULES=( sensson-powerdns puppetlabs-stdlib puppetlabs-mysql puppetlabs-apt puppetlabs-vcsrepo puppet-python camptocamp-systemd puppet-nginx )

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi
echo "Upgrading the whole system"
apt-get update
apt-get -y dist-upgrade
echo "Install puppet agent repository"
wget https://apt.puppetlabs.com/puppet5-release-stretch.deb
dpkg -i puppet5-release-stretch.deb
apt-get update
echo "Install puppet agent and dependencies"
apt-get -y install puppet-agent git dirmngr apt-transport-https lsb-release
echo "Installing puppet modules"
for module in "${PUPPET_MODULES[@]}"
do
  /opt/puppetlabs/bin/puppet module install $module
done
git clone https://github.com/mstinsky/powerdns_admin.git /etc/puppetlabs/code/environments/production/modules/powerdns_admin

echo "Enter powerdns db password:"
read -s NEW_PDNS_DB_PASSWORD
sed -i -- "s/changeme_pdns_db_password/$NEW_PDNS_DB_PASSWORD/g" *.pp

echo "Enter powerdns db root password:"
read -s NEW_PDNS_DB_ROOT_PASSWORD
sed -i -- "s/changeme_pdns_db_root_password/$NEW_PDNS_DB_ROOT_PASSWORD/g" *.pp

echo "Enter powerdns api key (any random string):"
read -s NEW_PDNS_API_KEY
sed -i -- "s/changeme_api_key/$NEW_PDNS_API_KEY/g" *.pp

echo "Enter powerdns_admin db password:"
read -s NEW_PDNS_ADMIN_DB_PASSWORD
sed -i -- "s/changeme_pdns_admin_db_password/$NEW_PDNS_ADMIN_DB_PASSWORD/g" *.pp

echo "Enter domain name for the webserver (eg. pdns.example.com):"
read -s NEW_PDNS_DOMAIN_NAME
sed -i -- "s/changeme_domain_name/$NEW_PDNS_DOMAIN_NAME/g" *.pp

echo "Creating self signed certificates"
mkdir -p /etc/nginx/certs
openssl req -x509 -newkey rsa:4096 -keyout /etc/nginx/certs/key.pem -out /etc/nginx/certs/cert.pem -days 36500
echo "We are now removing the password from the key file, please enter the password again."
openssl rsa -in /etc/nginx/certs/key.pem -out /etc/nginx/certs/key.pem

echo "Applying puppet manifests"
/opt/puppetlabs/bin/puppet apply powerdns.pp
/opt/puppetlabs/bin/puppet apply powerdns_admin.pp
