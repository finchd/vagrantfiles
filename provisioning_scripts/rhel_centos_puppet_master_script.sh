#! /bin/bash
echo Checking to see if the Puppet Labs RHEL/CentOS repo needs to be added...

if [ ! -f /home/vagrant/repos_added.txt ];
then    
    echo Adding repo...
	sudo rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
	echo DONE adding repo!
    echo Updating package lists with new repo...
	sudo yum check-update
	#Touch the repos_added file to skip this block the next time around
	touch /home/vagrant/repos_added.txt

else
	echo Skipping repo addition...
fi

if [ ! -f /home/vagrant/puppet_master_installed.txt ];
then
	echo Installing the Puppet master...
	sudo yum install puppet-server -y
	echo DONE installing the Puppet master packages!
	
	sudo chkconfig --levels 2345 puppetmaster on
	echo DONE adding the Puppet master daemon to start up on system boot!
	
	echo Starting the Puppet master daemon... 
	sudo /etc/init.d/puppetmaster start
	echo DONE starting the daemon!
	
	echo Disabling IP tables...
	sudo service iptables stop
	echo DONE disabling iptables!
	
	#Touch the puppet_installed.txt file to skip this block the next time around
	touch /home/vagrant/puppet_master_installed.txt
else
	echo Skipping Puppet master package installation...
fi

echo cating sample puppet.conf into puppet.conf file...
sudo cat <<EOF > /etc/puppet/puppet.conf
[main]
    # The Puppet log directory.
    # The default value is '$vardir/log'.
    logdir = /var/log/puppet

    # Where Puppet PID files are kept.
    # The default value is '$vardir/run'.
    rundir = /var/run/puppet

    # Where SSL certificates are kept.
    # The default value is '$confdir/ssl'.
    ssldir = /var/lib/puppet/ssl/
    dns_alt_names=puppet, master

[agent]
    # The file in which puppetd stores a list of the classes
    # associated with the retrieved configuratiion.  Can be loaded in
    # the separate ``puppet`` executable using the ``--loadclasses``
    # option.
    # The default value is '$confdir/classes.txt'.
    classfile = $vardir/classes.txt

    # Where puppetd caches the local configuration.  An
    # extension indicating the cache format is added automatically.
    # The default value is '$confdir/localconfig'.
    localconfig = $vardir/localconfig

EOF

sudo puppet cert clean master
sudo puppet cert generate master --dns_alt_names=puppet
sudo /etc/init.d/puppetmaster restart