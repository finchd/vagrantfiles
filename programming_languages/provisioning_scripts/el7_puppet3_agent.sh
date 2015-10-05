#! /bin/bash
echo "Checking to see if the Puppet Labs RHEL/CentOS repo needs to be added..."
if [ ! -f /home/vagrant/repos_added.txt ];
then    
sudo rpm -Uvhi http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
sudo yum check-update
#Touch the repos_added file to skip this block the next time around
touch /home/vagrant/repos_added.txt
else
echo "Skipping repo addition..."
fi

echo "Checking to see if the Puppet agent package needs to be installed..."
if [ ! -f /home/vagrant/puppet_agent_installed.txt ];
then
sudo yum install --disablerepo=epel puppet -y
sudo cat > /etc/puppetlabs/puppet/puppet.conf <<"EOF"
# This file can be used to override the default puppet settings.
# See the following links for more details on what settings are available:
# - https://docs.puppetlabs.com/puppet/latest/reference/config_important_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_about_settings.html
# - https://docs.puppetlabs.com/puppet/latest/reference/config_file_main.html
# - https://docs.puppetlabs.com/references/latest/configuration.html

server=puppet
reports=true
pluginsync=true
EOF

sudo systemctl enable puppet.service
sudo systemctl start puppet.service

#Touch the puppet_installed.txt file to skip this block the next time around
touch /home/vagrant/puppet_agent_installed.txt
else
echo "Skipping Puppet agent package installation..."
fi