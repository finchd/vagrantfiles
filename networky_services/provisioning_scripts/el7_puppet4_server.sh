#! /bin/bash

#EL7 Puppet Server installation

#Sources: 
# https://docs.puppetlabs.com/guides/puppetlabs_package_repositories.html#yum-based-systems
# https://docs.puppetlabs.com/puppet/4.2/reference/config_file_main.html
# http://docs.puppetlabs.com/hiera/3.0/configuring.html
# https://docs.puppetlabs.com/puppet/latest/reference/config_file_fileserver.html

echo "Checking to see if the Puppet Labs RHEL/CentOS repo needs to be added..."
if [ ! -f /home/vagrant/repos_added.txt ];
then    
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
sudo yum check-update
#Touch the repos_added file to skip this block the next time around
touch /home/vagrant/repos_added.txt
else
echo "Skipping repo addition..."
fi

if [ ! -f /home/vagrant/puppet_master_installed.txt ];
then
sudo yum -y install puppetserver
sudo sed -i 's/Xms2g/Xms512m/g' /etc/sysconfig/puppetserver
sudo sed -i 's/Xmx2g/Xmx512m/g' /etc/sysconfig/puppetserver
sudo systemctl enable puppetserver.service
sudo systemctl enable puppet.service

echo "cating sample puppet.conf into puppet.conf file..."
sudo cat > /etc/puppetlabs/puppet/puppet.conf <<"EOF"
# This file can be used to override the default puppet settings.
# See the following links for more details on what settings are available:
# - https://docs.puppetlabs.com/puppet/latest/reference/config_important_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_about_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_file_main.html
# - https://docs.puppetlabs.com/references/latest/configuration.html
[master]
vardir = /opt/puppetlabs/server/data/puppetserver
logdir = /var/log/puppetlabs/puppetserver
rundir = /var/run/puppetlabs/puppetserver
pidfile = /var/run/puppetlabs/puppetserver/puppetserver.pid
codedir = /etc/puppetlabs/code
dns_alt_names = puppet
EOF

sudo cat > /etc/puppetlabs/code/hiera.yaml <<"EOF"
---
#Our hierarcy
:hierarchy:
- node/%{fqdn}
- operatingsystem/%{operatingsystem}
- osfamily/%{osfamily}
- common
#List the backends we want to use
:backends:
- yaml
#For the YAML backend, specify the location of YAML data
:yaml:
:datadir: '/etc/puppetlabs/code/environments/%{environment}/hieradata'
EOF

sudo /opt/puppetlabs/puppet/bin/puppet cert clean --all
sudo /opt/puppetlabs/puppet/bin/puppet cert generate master --dns_alt_names=puppet,master,puppetmaster,puppet.local,master.local,puppetmaster.local

touch /home/vagrant/puppet_master_installed.txt
fi

if [ ! -f /home/vagrant/puppet_master_initial_run_complete.txt ];
then
  #Do an initial Puppet run to set up PuppetDB:
  /opt/puppetlabs/puppet/bin/puppet agent -t
  #Enable PuppetDB report storage...
  sudo echo 'reports = store,puppetdb' >> /etc/puppetlabs/puppet/puppet.conf
  #...and restart PuppetDB:
  sudo systemctl restart puppetserver.service
  #Touch the puppet_master_initial_run_complete.txt file to skip this block the next time around
  touch /home/vagrant/puppet_master_initial_run_complete.txt
else
  echo "Skipping initial Puppet run..."
fi
