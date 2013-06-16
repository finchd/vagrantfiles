#! /bin/bash
echo "Starting provisioning..."

echo "Adding Puppet Labs apt repository..."
sudo wget -N http://apt.puppetlabs.com/puppetlabs-release-quantal.deb
sudo dpkg -i puppetlabs-release-quantal.deb
sudo apt-get update
sudo apt-get -y install puppetmaster



#! /bin/bash
echo "Checking to see if the Puppet Labs apt repo needs to be added..."

if [ ! -f /home/vagrant/repos_added.txt ];
then    
	echo "Adding Puppet Labs apt repository..."
    sudo wget -N http://apt.puppetlabs.com/puppetlabs-release-quantal.deb
    sudo dpkg -i puppetlabs-release-quantal.deb
    echo "Updating apt..."
    sudo apt-get update
    echo "Installing the puppetmaster package..."
    sudo apt-get -y install puppetmaster
    #Touch the repos_added file to skip this block the next time around
	touch /home/vagrant/repos_added.txt

else
	echo "Skipping repo addition and package installation..."
fi

if [ ! -f /home/vagrant/puppet_master_installed.txt ];
then
	echo "Installing the Puppet master..."
	sudo apt-get -y install puppetmaster
	echo "DONE installing the Puppet master packages!"
	
	echo "Starting the Puppet master daemon..."
	sudo /etc/init.d/puppetmaster start
	echo "DONE starting the daemon!"
	
	echo "Stopping the UFW firewall..."
	sudo service ufw stop
	echo "DONE stopping ufw!"

    echo "Regenerating Puppet master certificate with the 'puppet' DNS altname..."
    sudo puppet cert clean master
    sudo puppet cert generate master --dns_alt_names=puppet,master,puppetmaster,puppet.local,master.local,puppetmaster.local
    sudo /etc/init.d/puppetmaster restart
    echo "DONE regenerating the master certificate!"

    echo "concatenating sample puppet.conf into puppet.conf file..."
    sudo cat << EOF > /etc/puppet/puppet.conf
    [main]
    logdir=/var/log/puppet
    vardir=/var/lib/puppet
    ssldir=/var/lib/puppet/ssl
    rundir=/var/run/puppet
    factpath=$vardir/lib/facter
    templatedir=$confdir/templates

    [master]
    # These are needed when the puppetmaster is run by passenger
    # and can safely be removed if webrick is used.
    ssl_client_header = SSL_CLIENT_S_DN 
    ssl_client_verify_header = SSL_CLIENT_VERIFY
    dns_alt_names = puppet,master,puppetmaster,puppet.local,master.local,puppetmaster.local

    EOF
    
    #Touch the puppet_installed.txt file to skip this block the next time around
	touch /home/vagrant/puppet_master_installed.txt
else
	echo Skipping Puppet master installation...
fi